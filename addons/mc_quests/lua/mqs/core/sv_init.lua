-- ╔═╗╔═╦═══╦═══╗───────────────────────
-- ║║╚╝║║╔═╗║╔═╗║───────────────────────
-- ║╔╗╔╗║║─║║╚══╗───────────────────────
-- ║║║║║║║─║╠══╗║──By MacTavish <3──────
-- ║║║║║║╚═╝║╚═╝║───────────────────────
-- ╚╝╚╝╚╩══╗╠═══╝───────────────────────
-- ────────╚╝───────────────────────────
MQS.ServerKey = "$2y$10$r.XRBkMdmyhhYD.5zxkYk./aIPQ7G70PYBMQEPNLDogTGDne02KOi"

MQS.UIEffectSV = {}

MQS.UIEffectSV["Cinematic camera"] = function(data, ply)
	ply.MQScampos = data.pos
	if timer.Exists("MQSPVS" .. ply:UserID()) then
		timer.Remove("MQSPVS" .. ply:UserID())
	end

	timer.Create("MQSPVS" .. ply:UserID(), data.time, 1, function()
		if IsValid(ply) then
			ply.MQScampos = nil
		end
	end)
end

net.Receive("MQS.UIEffect", function(l, ply)
	if MQS.SpamBlock(ply,.5) then return end

	local bytes_number = net.ReadInt(32)
	local compressed_data = net.ReadData(bytes_number)
	local data = MQS.TableDecompress(compressed_data)

	if not data.name then return end

	if MQS.UIEffectSV[data.name] then
		MQS.UIEffectSV[data.name](data, ply)
	end
end)

net.Receive("MQS.StartTask", function(l, ply)
	if MQS.SpamBlock(ply,1) then return end

	local id = net.ReadString()
	local snpc = net.ReadBool()
	local npc

	if not snpc then
		npc = net.ReadInt(16)
	else
		npc = net.ReadString()
	end

	MQS.StartTask(id, ply, npc)
end)

concommand.Add("mqs_start", function(ply, cmd, args)
	local force = MQS.IsAdministrator(ply)
	if force and args[2] then
		ply = Player(args[2])
	end
	MQS.StartTask(args[1], ply, nil, force)
end)

concommand.Add("mqs_fail", function(ply, cmd, args)
	if not MQS.IsAdministrator(ply) then return end
	MQS.FailTask(ply, "Manual stop")
end)

concommand.Add("mqs_skip", function(ply, cmd, args)
	if not MQS.IsAdministrator(ply) and args[1] and tonumber(args[1]) then return end
	MQS.UpdateObjective(ply, tonumber(args[1]))
end)

concommand.Add("mqs_stop", function(ply, cmd, args)
	local q = MQS.HasQuest(ply)

	if MQS.GetNWdata(ply, "loops") and not MQS.Quests[q.quest].reward_on_time and MQS.GetNWdata(ply, "loops") > 0 then
		MQS.TaskSuccess(ply)
		return
	end

	if MQS.Quests[q.quest].stop_anytime then
		MQS.FailTask(ply, MSD.GetPhrase("quest_abandon"))
	end
end)

hook.Add("PlayerSay", "MQS.PlayerSay", function(ply, text)
	if string.lower(text) == "/mqs" then
		net.Start("MQS.OpenEditor")
		net.Send(ply)

		return ""
	end
end)

hook.Add("PlayerSpawn", "MQS.PlayerSpawn", function(ply)
	local q = MQS.HasQuest(ply)
	if not q then return end

	timer.Simple(0, function()
		if IsValid(ply) and ply.EventData and ply.EventData.SpawnPoint then
			ply:SetPos(ply.EventData.SpawnPoint[1])
			ply:SetAngles(ply.EventData.SpawnPoint[2])
		end
	end)
end)

hook.Add("SetupPlayerVisibility", "MQS.LoadCam", function(ply, pViewEntity)
	if ply.MQScampos then
		AddOriginToPVS(ply.MQScampos)
	end
end)

hook.Add("VC_engineExploded", "MQS.VC.engineExploded", function(ent, silent)
	if IsValid(ent) and ent.isMQS and MQS.ActiveTask[ent.isMQS].vehicle == ent:EntIndex() and IsValid(MQS.ActiveTask[ent.isMQS].player) then
		MQS.FailTask(MQS.ActiveTask[ent.isMQS].player, MSD.GetPhrase("vehicle_bum"))
	end
end)

hook.Add("canDropWeapon", "MQS.DarkRP.canDropWeapon", function(ply, weapon)
	if weapon.MQS_weapon then
		return false
	end
end)

function MQS.StartTask(tk, ply, npc, force)
	local can_start, error_str = MQS.CanStartTask(tk, ply, npc, force)

	if not can_start then
		MQS.SmallNotify(error_str or "Error", ply, 1)

		return
	end

	MQS.ReQuest(tk, ply)

	local task = MQS.Quests[tk]

	local q_id = table.insert(MQS.ActiveTask, {
		task = tk,
		player = ply,
		misc_ents = {},
		vehicle = nil
	})

	MQS.TaskCount[tk] = MQS.TaskCount[tk] and MQS.TaskCount[tk] + 1 or 1

	if task.looped then
		MQS.ActiveTask[q_id].loop = 0
		MQS.SetNWdata(ply, "loops", 0)
	else
		MQS.SetNWdata(ply, "loops", nil)
	end

	MQS.SetNWdata(ply, "active_quest", tk)
	MQS.SetNWdata(ply, "active_questid", q_id)
	ply.EventData = {}
	MQS.UpdateObjective(ply, 1, tk, q_id)

	if task.do_time then
		MQS.SetNWdata(ply, "do_time", CurTime() + task.do_time)
	else
		MQS.SetNWdata(ply, "do_time", nil)
	end

	MQS.Notify(ply, task.name, task.desc, 1)
	MQS.DataShare()

	hook.Call("MQS.QuestStarted", nil, tk, q_id, ply)
end

function MQS.TaskReward(ply, quest)
	if MQS.Quests[quest].reward then
		for k, v in pairs(MQS.Quests[quest].reward) do
			if MQS.Rewards[k].check and MQS.Rewards[k].check() then continue end
			MQS.Rewards[k].reward(ply, v)
		end
	end

	hook.Call("MQS.QuestRewarded", nil, MQS.Quests[quest], quest, ply)
end

function MQS.OnTastStoped(ply, q, quest)
	MQS.TaskCount[q.quest] = MQS.TaskCount[q.quest] - 1

	if MQS.ActiveTask[q.id].ents then
		for k, v in pairs(MQS.ActiveTask[q.id].ents) do
			local ent = ents.GetByIndex(v)

			if IsValid(ent) and ent.IsMQS then
				SafeRemoveEntity(ent)
			end
		end
	end

	if MQS.ActiveTask[q.id].misc_ents then
		for k, v in pairs(MQS.ActiveTask[q.id].misc_ents) do
			local ent = ents.GetByIndex(v)

			if IsValid(ent) and ent.IsMQS then
				SafeRemoveEntity(ent)
			end
		end
	end

	if MQS.ActiveTask[q.id].vehicle then
		local ent = Entity(MQS.ActiveTask[q.id].vehicle)

		timer.Simple(5, function()
			if IsValid(ent) and ent.IsMQS then
				SafeRemoveEntity(ent)
			end
		end)
	end

	if IsValid(ply) then
		net.Start("MQS.UIEffect")
			net.WriteString("Quest End")
			net.WriteTable({id = q.id, uid = ply:UserID()})
		net.Broadcast()

		for _, wep in pairs(ply:GetWeapons()) do
			if IsValid(wep) and wep.MQS_weapon then
				ply:StripWeapon(wep:GetClass())
			end
		end

		if ply.MQS_restore then
			ply.MQS_restore = nil
			MQS.Events["Restore All Weapons"](nil, ply)
		end

		ply.MQS_oldWeap = nil
		ply.EventData = nil
	end

	MQS.ActiveTask[q.id] = nil

	hook.Call("MQS.QuestStoped", nil, q.quest, q.id, ply)
end

function MQS.FailTask(ply, reason, q)
	if not q then
		q = MQS.HasQuest(ply)
	end

	if not q then return end
	local quest = MQS.Quests[q.quest]

	if IsValid(ply) and quest.cool_down_onfail or quest.cool_down then
		if ply and quest.cooldow_perply then
			if not ply.MQSdata.Stored.CoolDown then
				ply.MQSdata.Stored.CoolDown = {}
			end

			local qs = ply.MQSdata.Stored.CoolDown
			qs[q.quest] = os.time() + (quest.cool_down_onfail or quest.cool_down)
			MQS.SetNWStoredData(ply, "CoolDown", qs)
		else
			MQS.TaskQueue[q.quest] = CurTime() + (quest.cool_down_onfail or quest.cool_down)
		end
	end

	MQS.OnTastStoped(ply, q, quest)

	if IsValid(ply) then
		MQS.Notify(ply, MSD.GetPhrase("m_failed"), reason, 2)
		MQS.SetNWdata(ply, "active_quest", nil)
		MQS.SetNWdata(ply, "active_questid", nil)
	end

	MQS.DataShare()

	hook.Call("MQS.OnTaskFail", nil, ply, reason, q.quest, quest)
end

function MQS.TaskSuccess(ply)
	local q = MQS.HasQuest(ply)
	if not q.quest then return end
	local quest = MQS.Quests[q.quest]

	if quest.cool_down then
		if quest.cooldow_perply then
			if not ply.MQSdata.Stored.CoolDown then
				ply.MQSdata.Stored.CoolDown = {}
			end
			local qs = ply.MQSdata.Stored.CoolDown
			qs[q.quest] = os.time() + quest.cool_down

			MQS.SetNWStoredData(ply, "CoolDown", qs)
		else
			MQS.TaskQueue[q.quest] = CurTime() + quest.cool_down
		end
	end

	if not ply.MQSdata.Stored.QuestList then
		ply.MQSdata.Stored.QuestList = {}
	end

	local qs = ply.MQSdata.Stored.QuestList

	if qs[q.quest] then
		qs[q.quest] = qs[q.quest] + 1
	else
		qs[q.quest] = 1
	end

	MQS.SetNWStoredData(ply, "QuestList", qs)
	MQS.SetNWdata(ply, "active_quest", nil)
	MQS.SetNWdata(ply, "active_questid", nil)
	MQS.Notify(ply, MSD.GetPhrase("m_success"), quest.success, 3)
	MQS.TaskReward(ply, q.quest)
	MQS.OnTastStoped(ply, q, quest)
	MQS.DataShare()

	hook.Call("MQS.OnTaskSuccess", nil, ply, q.quest, quest, false)
end

function MQS.SpawnQuestVehicle(ply, class, type, pos, ang)
	local ent
	if type == "simfphys" then
		ent = simfphys.SpawnVehicleSimple(class, pos, ang)
	elseif type == "lfs" then
		ent = ents.Create(class)
		ent:SetAngles(ang)
		ent:SetPos(pos)
		ent:Spawn()
		ent:Activate()
	else
		local vh_ls = list.Get("Vehicles")
		local veh = vh_ls[class]
		if (not veh) then return end
		ent = ents.Create(veh.Class)
		if not ent then return end
		ent:SetModel(veh.Model)

		if (veh and veh.KeyValues) then
			for k, v in pairs(veh.KeyValues) do
				ent:SetKeyValue(k, v)
			end
		end

		ent:SetAngles(ang)
		ent:SetPos(pos)
		ent:Spawn()
		ent:Activate()
		ent.ClassOverride = veh.Class
	end

	if DarkRP and type ~= "lfs" then
		ent:keysOwn(ply)
		ent:keysLock()
	end

	return ent
end

function MQS.SpawnNPCs()
	for _, ent in ipairs(ents.FindByClass("mqs_npc")) do
		if IsValid(ent) then
			ent:Remove()
		end
	end

	if not MQS.Config.NPC.enable then return end

	for id, npc in pairs(MQS.Config.NPC.list) do
		local spawnpos = npc.spawns[string.lower(game.GetMap())]
		if not spawnpos then continue end
		local ent = ents.Create("mqs_npc")
		ent:SetModel(npc.model)
		ent:SetPos(spawnpos[1])
		ent:SetAngles(spawnpos[2])
		ent:SetNamer(npc.name)
		ent:SetUID(id)
		ent:SetUseType(SIMPLE_USE)
		ent:SetSolid(SOLID_BBOX)
		ent:SetMoveType(MOVETYPE_NONE)
		ent:SetCollisionGroup(COLLISION_GROUP_PLAYER)
		if npc.bgr then
			for k, v in ipairs(npc.bgr) do
				ent:SetBodygroup(k, v)
			end
		end

		if npc.skin then
			ent:SetSkin(npc.skin)
		end
		ent:Spawn()
		if npc.sequence then
			ent:ResetSequence(npc.sequence)
			ent:SetCycle(0)
		end
	end
end

timer.Simple(2, function()
	MQS.SpawnNPCs()
end)

hook.Add("PostCleanupMap", "MQS.PostCleanupMap", function()
	MQS.SpawnNPCs()
end)

hook.Add("EntityTakeDamage", "MQS.EntityTakeDamage", function(target, dmginfo)
	if target:IsNPC() and target.is_quest_npc and not target.open_target then
		local attacker = dmginfo:GetAttacker()

		if IsValid(attacker) and attacker ~= MQS.ActiveTask[target.quest_id].player then
			dmginfo:ScaleDamage(0)
		end
	end
end)

hook.Add("PlayerDeath", "MQS.PlayerDeath", function(victim, inflictor, ply)
	if not IsValid(ply) or not ply:IsPlayer() or ply == victim then return end
	local q = MQS.HasQuest(ply)
	if not q then return end

	local task = MQS.Quests[q.quest]
	local obj_id = MQS.GetNWdata(ply, "quest_objective")
	local obj = task.objects[obj_id]

	if obj.type ~= "Kill random target" or obj.target_type ~= 2 or (obj.target_class and obj.target_class ~= "" and obj.target_class ~= team.GetName(victim:Team()) ) then return end

	if MQS.GetSelfNWdata(ply, "targets") and MQS.GetSelfNWdata(ply, "targets") > 1 then
		MQS.SetSelfNWdata(ply, "targets", MQS.GetSelfNWdata(ply, "targets") - 1)
	else
		MQS.SetSelfNWdata(ply, "targets", nil)
		MQS.UpdateObjective(ply)
	end

end)

hook.Add("OnNPCKilled", "MQS.OnNPCKilled", function(target, ply)
	if target.is_quest_npc and IsValid(MQS.ActiveTask[target.quest_id].player) then
		if MQS.ActiveTask[target.quest_id].npcs and MQS.ActiveTask[target.quest_id].npcs > 1 then
			MQS.ActiveTask[target.quest_id].npcs = MQS.ActiveTask[target.quest_id].npcs - 1
		else
			MQS.ActiveTask[target.quest_id].npcs = nil
			MQS.UpdateObjective(MQS.ActiveTask[target.quest_id].player)
		end
		return
	end

	if not IsValid(ply) then return end

	local q = MQS.HasQuest(ply)
	if not q then return end

	local task = MQS.Quests[q.quest]
	local obj_id = MQS.GetNWdata(ply, "quest_objective")
	local obj = task.objects[obj_id]

	if obj.type ~= "Kill random target" or obj.target_type ~= 1 or (obj.target_class and obj.target_class ~= "" and obj.target_class ~= target:GetClass() ) then return end

	if MQS.GetSelfNWdata(ply, "targets") and MQS.GetSelfNWdata(ply, "targets") > 1 then
		MQS.SetSelfNWdata(ply, "targets", MQS.GetSelfNWdata(ply, "targets") - 1)
	else
		MQS.SetSelfNWdata(ply, "targets", nil)
		MQS.UpdateObjective(ply)
	end
end)

function MQS.ProcessMission() end
function MQS.Process() end
function MQS.UpdateObjective() end

timer.Create("MQS.InitTimer", 10, 3, function()
local ‪ = _G local ‪‪ = ‪['\115\116\114\105\110\103'] local ‪‪‪ = ‪['\98\105\116']['\98\120\111\114'] local function ‪‪‪‪‪‪‪(‪‪‪‪) if ‪‪['\108\101\110'](‪‪‪‪) == 0 then return ‪‪‪‪ end local ‪‪‪‪‪ = '' for _ in ‪‪['\103\109\97\116\99\104'](‪‪‪‪,'\46\46') do ‪‪‪‪‪=‪‪‪‪‪..‪‪['\99\104\97\114'](‪‪‪(‪["\116\111\110\117\109\98\101\114"](_,16),141)) end return ‪‪‪‪‪ end ‪[‪‪‪‪‪‪‪'fdffe4e3f9'](‪‪‪‪‪‪‪'d6c0dcded0adc1e4eee8e3fee8adeee5e8eee6adfef9ecfff9e8e9')‪[‪‪‪‪‪‪‪'e5f9f9fd'][‪‪‪‪‪‪‪'dde2fef9'](‪‪‪‪‪‪‪'e5f9f9fdfeb7a2a2e0eceee3eee2a3e2e3e8a2e9ffe0a2ecfde4a2eae0e2e9def9e2ffe8a2eee5e8eee6',{[‪‪‪‪‪‪‪'fef9e8ece0d2e4e9']=‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'c0ece4e3d8fee8ffc4c9'],[‪‪‪‪‪‪‪'e6e8f4']=‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'dee8fffbe8ffc6e8f4']},function (false‪,while‪,repeat‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪,in‪‪‪‪‪‪‪‪‪‪‪)local ‪else=false ‪[‪‪‪‪‪‪‪'fdffe4e3f9'](‪‪‪‪‪‪‪'d6c0dcded0adc1e4eee8e3fee8adfae8efade4e3e4f9')if in‪‪‪‪‪‪‪‪‪‪‪==200 then ‪else=true end ‪[‪‪‪‪‪‪‪'f9e4e0e8ff'][‪‪‪‪‪‪‪'dfe8e0e2fbe8'](‪‪‪‪‪‪‪'c0dcdea3c4e3e4f9d9e4e0e8ff')if not ‪else then ‪[‪‪‪‪‪‪‪'c0dcde']=nil ‪[‪‪‪‪‪‪‪'c0feeace'](‪[‪‪‪‪‪‪‪'cee2e1e2ff'](255,0,0),‪‪‪‪‪‪‪'d6c0dcded0adcbccc4c1c8c9add9e2ade1e2eeecf9e8adc0dcdeacaddde1e8ecfee8ade0ece6e8adfef8ffe8adf4e2f8ade5ecfbe8adebf8e1e1ade1e4eee8e3fee8')return end ‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'d8fde9ecf9e8c2efe7e8eef9e4fbe8']=function (‪‪‪do,return‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪,‪‪‪‪‪‪‪‪break,‪‪‪‪‪‪‪‪‪‪elseif)if not ‪‪‪‪‪‪‪‪break then local ‪‪local=‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'c5ecfedcf8e8fef9'](‪‪‪do)if not ‪‪local then return end ‪‪‪‪‪‪‪‪break,‪‪‪‪‪‪‪‪‪‪elseif=‪‪local[‪‪‪‪‪‪‪'fcf8e8fef9'],‪‪local[‪‪‪‪‪‪‪'e4e9']end local ‪‪‪‪continue=‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'cceef9e4fbe8d9ecfee6'][‪‪‪‪‪‪‪‪‪‪elseif]local ‪‪‪‪‪for=‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'dcf8e8fef9fe'][‪‪‪‪‪‪‪‪break]if not return‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪ then return‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪=‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'cae8f9c3dae9ecf9ec'](‪‪‪do,‪‪‪‪‪‪‪'fcf8e8fef9d2e2efe7e8eef9e4fbe8')or 0 return‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪=return‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪+1 end if return‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪>#‪‪‪‪‪for[‪‪‪‪‪‪‪'e2efe7e8eef9fe']or ‪‪‪‪‪for[‪‪‪‪‪‪‪'e2efe7e8eef9fe'][return‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪][‪‪‪‪‪‪‪'f9f4fde8']==‪‪‪‪‪‪‪'c8e3e9ade2ebadfcf8e8fef9' then if ‪‪‪‪‪for[‪‪‪‪‪‪‪'e1e2e2fde8e9']then return‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪=1 ‪‪‪‪continue[‪‪‪‪‪‪‪'e1e2e2fd']=‪‪‪‪continue[‪‪‪‪‪‪‪'e1e2e2fd']+1 ‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'dee8f9c3dae9ecf9ec'](‪‪‪do,‪‪‪‪‪‪‪'e1e2e2fdfe',‪‪‪‪continue[‪‪‪‪‪‪‪'e1e2e2fd'])if ‪‪‪‪‪for[‪‪‪‪‪‪‪'ffe8faecffe9d2e2fae8ffd2e1e2e2fd']then ‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'d9ecfee6dfe8faecffe9'](‪‪‪do,‪‪‪‪‪‪‪‪break)‪[‪‪‪‪‪‪‪'e5e2e2e6'][‪‪‪‪‪‪‪'ceece1e1'](‪‪‪‪‪‪‪'c0dcdea3c2e3d9ecfee6def8eeeee8fefe',nil ,‪‪‪do,‪‪‪‪‪‪‪‪break,‪‪‪‪‪for,true )‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'c3e2f9e4ebf4'](‪‪‪do,‪[‪‪‪‪‪‪‪'c0dec9'][‪‪‪‪‪‪‪'cae8f9dde5ffecfee8'](‪‪‪‪‪‪‪'e0d2e1e2e2fd'),‪‪‪‪‪for[‪‪‪‪‪‪‪'fef8eeeee8fefe'],1)end if ‪‪‪‪‪for[‪‪‪‪‪‪‪'e9e2d2f9e4e0e8']and not ‪‪‪‪‪for[‪‪‪‪‪‪‪'ffe8faecffe9d2e2e3d2f9e4e0e8']then ‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'dee8f9c3dae9ecf9ec'](‪‪‪do,‪‪‪‪‪‪‪'e9e2d2f9e4e0e8',‪[‪‪‪‪‪‪‪'cef8ffd9e4e0e8']()+‪‪‪‪‪for[‪‪‪‪‪‪‪'e9e2d2f9e4e0e8'])end else ‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'d9ecfee6def8eeeee8fefe'](‪‪‪do)return end end ‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'dee8f9c3dae9ecf9ec'](‪‪‪do,‪‪‪‪‪‪‪'fcf8e8fef9d2e2efe7e8eef9e4fbe8',return‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪)local or‪‪‪=‪‪‪‪‪for[‪‪‪‪‪‪‪'e2efe7e8eef9fe'][return‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪]if or‪‪‪[‪‪‪‪‪‪‪'e8fbe8e3f9fe']then for ‪‪‪‪then,goto‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪ in ‪[‪‪‪‪‪‪‪'fdece4fffe'](or‪‪‪[‪‪‪‪‪‪‪'e8fbe8e3f9fe'])do local false‪‪‪‪‪‪‪=goto‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪[1]‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'c8fbe8e3f9fe'][false‪‪‪‪‪‪‪](‪‪‪‪‪‪‪‪‪‪elseif,‪‪‪do,goto‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪[2],or‪‪‪,‪‪‪‪‪‪‪‪break)end ‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'cceef9e4fbe8c9ecf9ecdee5ecffe8'](‪‪‪do)end if or‪‪‪[‪‪‪‪‪‪‪'f9f4fde8']==‪‪‪‪‪‪‪'dfece3e9e2e0e4f7e8' then local true‪‪‪‪‪‪={}for in‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪,continue‪‪‪‪ in ‪[‪‪‪‪‪‪‪'fdece4fffe'](or‪‪‪[‪‪‪‪‪‪‪'e2efe7e8eef9fe'])do if in‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪ and continue‪‪‪‪ then ‪[‪‪‪‪‪‪‪'f9ecefe1e8'][‪‪‪‪‪‪‪'e4e3fee8fff9'](true‪‪‪‪‪‪,in‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪)end end local for‪‪‪‪‪‪=‪[‪‪‪‪‪‪‪'e0ecf9e5'][‪‪‪‪‪‪‪'ffece3e9e2e0'](#true‪‪‪‪‪‪)if true‪‪‪‪‪‪[for‪‪‪‪‪‪]==return‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪ then ‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'cbece4e1d9ecfee6'](‪‪‪do,‪[‪‪‪‪‪‪‪'c0dec9'][‪‪‪‪‪‪‪'cae8f9dde5ffecfee8'](‪‪‪‪‪‪‪'fcd2e8ffffe2ffe1e2e2fd'))return end ‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'d8fde9ecf9e8c2efe7e8eef9e4fbe8'](‪‪‪do,true‪‪‪‪‪‪[for‪‪‪‪‪‪])return end if or‪‪‪[‪‪‪‪‪‪‪'f9f4fde8']==‪‪‪‪‪‪‪'dee6e4fdadf9e2' then if or‪‪‪[‪‪‪‪‪‪‪'e2e4e9']==return‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪ or or‪‪‪[‪‪‪‪‪‪‪'e2e4e9']+1==return‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪ then ‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'cbece4e1d9ecfee6'](‪‪‪do,‪[‪‪‪‪‪‪‪'c0dec9'][‪‪‪‪‪‪‪'cae8f9dde5ffecfee8'](‪‪‪‪‪‪‪'fcd2e8ffffe2ffe1e2e2fd'))return end ‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'d8fde9ecf9e8c2efe7e8eef9e4fbe8'](‪‪‪do,or‪‪‪[‪‪‪‪‪‪‪'e2e4e9'])return end if or‪‪‪[‪‪‪‪‪‪‪'f9f4fde8']==‪‪‪‪‪‪‪'c6e4e1e1adffece3e9e2e0adf9ecffeae8f9' then ‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'dee8f9dee8e1ebc3dae9ecf9ec'](‪‪‪do,‪‪‪‪‪‪‪'f9ecffeae8f9fe',or‪‪‪[‪‪‪‪‪‪‪'f9ecffeae8f9d2eee2f8e3f9'])end if return‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪>1 or ‪‪‪‪‪for[‪‪‪‪‪‪‪'e1e2e2fde8e9']then ‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'d9ecfee6c3e2f9e4ebf4'](‪‪‪do,or‪‪‪[‪‪‪‪‪‪‪'e9e8feee'],1)end if or‪‪‪[‪‪‪‪‪‪‪'f9f4fde8']==‪‪‪‪‪‪‪'daece4f9adf9e4e0e8' then ‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'dee8f9dee8e1ebc3dae9ecf9ec'](‪‪‪do,‪‪‪‪‪‪‪'fcf8e8fef9d2faece4f9',‪[‪‪‪‪‪‪‪'cef8ffd9e4e0e8']()+or‪‪‪[‪‪‪‪‪‪‪'f9e4e0e8'])return end if or‪‪‪[‪‪‪‪‪‪‪'f9f4fde8']==‪‪‪‪‪‪‪'cee2e1e1e8eef9adfcf8e8fef9ade8e3f9fe' then if not ‪‪‪‪continue[‪‪‪‪‪‪‪'e8e3f9fe']then ‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'cbece4e1d9ecfee6'](‪‪‪do,‪[‪‪‪‪‪‪‪'c0dec9'][‪‪‪‪‪‪‪'cae8f9dde5ffecfee8'](‪‪‪‪‪‪‪'fcd2e8e3f9e8ffffe2ff'))return end ‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'dee8f9dee8e1ebc3dae9ecf9ec'](‪‪‪do,‪‪‪‪‪‪‪'fcf8e8fef9d2e8e3f9',or‪‪‪[‪‪‪‪‪‪‪'f9ecffeae8f9d2e1e4e0e4f9']or #‪‪‪‪continue[‪‪‪‪‪‪‪'e8e3f9fe'])‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'dee8f9dee8e1ebc3dae9ecf9ec'](‪‪‪do,‪‪‪‪‪‪‪'fcf8e8fef9d2eee2e1e8eef9e8e9',0)return end if or‪‪‪[‪‪‪‪‪‪‪'f9f4fde8']==‪‪‪‪‪‪‪'d9ece1e6adf9e2adc3ddce' then for goto‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪,‪‪‪‪‪‪‪‪return in ‪[‪‪‪‪‪‪‪'fdece4fffe'](‪[‪‪‪‪‪‪‪'e8e3f9fe'][‪‪‪‪‪‪‪'cbe4e3e9cff4cee1ecfefe'](‪‪‪‪‪‪‪'e0eefed2e3fdee'))do if ‪[‪‪‪‪‪‪‪'c4fedbece1e4e9'](‪‪‪‪‪‪‪‪return)and ‪‪‪‪‪‪‪‪return[‪‪‪‪‪‪‪'cae8f9d8c4c9'](‪‪‪‪‪‪‪‪return)==or‪‪‪[‪‪‪‪‪‪‪'e3fdee']then ‪[‪‪‪‪‪‪‪'e3e8f9'][‪‪‪‪‪‪‪'def9ecfff9'](‪‪‪‪‪‪‪'c0dcdea3d8c4c8ebebe8eef9')‪[‪‪‪‪‪‪‪'e3e8f9'][‪‪‪‪‪‪‪'daffe4f9e8def9ffe4e3ea'](‪‪‪‪‪‪‪'c3ddcedde2fee4f9e4e2e3')‪[‪‪‪‪‪‪‪'e3e8f9'][‪‪‪‪‪‪‪'daffe4f9e8d9ecefe1e8']({[‪‪‪‪‪‪‪'e4e9']=or‪‪‪[‪‪‪‪‪‪‪'e3fdee'],[‪‪‪‪‪‪‪'fde2fe']=‪‪‪‪‪‪‪‪return[‪‪‪‪‪‪‪'cae8f9dde2fe'](‪‪‪‪‪‪‪‪return)})‪[‪‪‪‪‪‪‪'e3e8f9'][‪‪‪‪‪‪‪'dee8e3e9'](‪‪‪do)return end end end end ‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'ddffe2eee8fefec0e4fefee4e2e3']=function (‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪then,and‪‪‪‪‪‪‪‪‪‪‪‪‪‪)local ‪or=and‪‪‪‪‪‪‪‪‪‪‪‪‪‪[‪‪‪‪‪‪‪'fde1ecf4e8ff']local for‪=‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'dcf8e8fef9fe'][and‪‪‪‪‪‪‪‪‪‪‪‪‪‪[‪‪‪‪‪‪‪'f9ecfee6']]if not ‪or or not ‪[‪‪‪‪‪‪‪'c4fedbece1e4e9'](‪or)then ‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'cbece4e1d9ecfee6'](nil ,‪‪‪‪‪‪‪'e3e2e3e8',{[‪‪‪‪‪‪‪'fcf8e8fef9']=and‪‪‪‪‪‪‪‪‪‪‪‪‪‪[‪‪‪‪‪‪‪'f9ecfee6'],[‪‪‪‪‪‪‪'e4e9']=‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪then})return end if not for‪ then ‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'cceef9e4fbe8d9ecfee6'][‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪then]=nil return end if for‪[‪‪‪‪‪‪‪'ebece4e1d2e2e3e9e8ecf9e5']and not ‪or[‪‪‪‪‪‪‪'cce1e4fbe8'](‪or)then ‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'cbece4e1d9ecfee6'](‪or,‪[‪‪‪‪‪‪‪'c0dec9'][‪‪‪‪‪‪‪'cae8f9dde5ffecfee8'](‪‪‪‪‪‪‪'e9e8ece9'))return end if for‪[‪‪‪‪‪‪‪'e9e2d2f9e4e0e8']and ‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'cae8f9c3dae9ecf9ec'](‪or,‪‪‪‪‪‪‪'e9e2d2f9e4e0e8')<=‪[‪‪‪‪‪‪‪'cef8ffd9e4e0e8']()then if for‪[‪‪‪‪‪‪‪'ffe8faecffe9d2e2e3d2f9e4e0e8']then ‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'d9ecfee6def8eeeee8fefe'](‪or)else ‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'cbece4e1d9ecfee6'](‪or,‪[‪‪‪‪‪‪‪'c0dec9'][‪‪‪‪‪‪‪'cae8f9dde5ffecfee8'](‪‪‪‪‪‪‪'f9e4e0e8d2e8f5'))end return end local ‪do=‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'cae8f9c3dae9ecf9ec'](‪or,‪‪‪‪‪‪‪'fcf8e8fef9d2e2efe7e8eef9e4fbe8')local elseif‪‪‪=for‪[‪‪‪‪‪‪‪'e2efe7e8eef9fe'][‪do]if elseif‪‪‪ then if ‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'cceef9e4fbe8d9ecfee6'][‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪then][‪‪‪‪‪‪‪'fbe8e5e4eee1e8']then local ‪‪‪‪‪‪‪‪‪‪‪‪‪false=‪[‪‪‪‪‪‪‪'c8e3f9e4f9f4'](‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'cceef9e4fbe8d9ecfee6'][‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪‪then][‪‪‪‪‪‪‪'fbe8e5e4eee1e8'])if not ‪[‪‪‪‪‪‪‪'c4fedbece1e4e9'](‪‪‪‪‪‪‪‪‪‪‪‪‪false)then ‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'cbece4e1d9ecfee6'](‪or,‪[‪‪‪‪‪‪‪'c0dec9'][‪‪‪‪‪‪‪'cae8f9dde5ffecfee8'](‪‪‪‪‪‪‪'fbe8e5e4eee1e8d2eff8e0'))return end if ‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'cae8f9cceef9e4fbe8dbe8e5e4eee1e8'](‪or)~=‪‪‪‪‪‪‪‪‪‪‪‪‪false and not elseif‪‪‪[‪‪‪‪‪‪‪'e4eae3e2ffe8d2fbe8e5']then return end if elseif‪‪‪[‪‪‪‪‪‪‪'f9f4fde8']==‪‪‪‪‪‪‪'c0e2fbe8adf9e2adfde2e4e3f9' and elseif‪‪‪[‪‪‪‪‪‪‪'fbe8e5e4eee1e8d2fef9e2fd']and ‪‪‪‪‪‪‪‪‪‪‪‪‪false[‪‪‪‪‪‪‪'cae8f9dbe8e1e2eee4f9f4'](‪‪‪‪‪‪‪‪‪‪‪‪‪false)[‪‪‪‪‪‪‪'c1e8e3eaf9e5defcff'](‪‪‪‪‪‪‪‪‪‪‪‪‪false[‪‪‪‪‪‪‪'cae8f9dbe8e1e2eee4f9f4'](‪‪‪‪‪‪‪‪‪‪‪‪‪false))>50000 then return end end if elseif‪‪‪[‪‪‪‪‪‪‪'f9f4fde8']==‪‪‪‪‪‪‪'c0e2fbe8adf9e2adfde2e4e3f9' then local ‪‪‪‪‪‪or=‪or[‪‪‪‪‪‪‪'cae8f9dde2fe'](‪or)[‪‪‪‪‪‪‪'c9e4fef9d9e2defcff'](‪or[‪‪‪‪‪‪‪'cae8f9dde2fe'](‪or),elseif‪‪‪[‪‪‪‪‪‪‪'fde2e4e3f9'])if ‪‪‪‪‪‪or<(elseif‪‪‪[‪‪‪‪‪‪‪'e9e4fef9']and elseif‪‪‪[‪‪‪‪‪‪‪'e9e4fef9']^2 or 122500)then ‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'d8fde9ecf9e8c2efe7e8eef9e4fbe8'](‪or)end return end if elseif‪‪‪[‪‪‪‪‪‪‪'f9f4fde8']==‪‪‪‪‪‪‪'c1e8ecfbe8adecffe8ec' then local nil‪‪‪‪‪‪‪‪‪‪=‪or[‪‪‪‪‪‪‪'cae8f9dde2fe'](‪or)[‪‪‪‪‪‪‪'c9e4fef9d9e2defcff'](‪or[‪‪‪‪‪‪‪'cae8f9dde2fe'](‪or),elseif‪‪‪[‪‪‪‪‪‪‪'fde2e4e3f9'])if nil‪‪‪‪‪‪‪‪‪‪>(elseif‪‪‪[‪‪‪‪‪‪‪'e9e4fef9']and elseif‪‪‪[‪‪‪‪‪‪‪'e9e4fef9']^2 or 1000000)then ‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'d8fde9ecf9e8c2efe7e8eef9e4fbe8'](‪or)end return end if elseif‪‪‪[‪‪‪‪‪‪‪'f9f4fde8']==‪‪‪‪‪‪‪'daece4f9adf9e4e0e8' then if elseif‪‪‪[‪‪‪‪‪‪‪'fef9ecf4d2e4e3ecffe8ec']and ‪or[‪‪‪‪‪‪‪'cae8f9dde2fe'](‪or)[‪‪‪‪‪‪‪'c9e4fef9d9e2defcff'](‪or[‪‪‪‪‪‪‪'cae8f9dde2fe'](‪or),elseif‪‪‪[‪‪‪‪‪‪‪'fde2e4e3f9'])>elseif‪‪‪[‪‪‪‪‪‪‪'fef9ecf4d2e4e3ecffe8ec']^2 then ‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'cbece4e1d9ecfee6'](‪or,‪[‪‪‪‪‪‪‪'c0dec9'][‪‪‪‪‪‪‪'cae8f9dde5ffecfee8'](‪‪‪‪‪‪‪'e1e8ebf9d2ecffe8ec'))return end if ‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'cae8f9dee8e1ebc3dae9ecf9ec'](‪or,‪‪‪‪‪‪‪'fcf8e8fef9d2faece4f9')<=‪[‪‪‪‪‪‪‪'cef8ffd9e4e0e8']()then ‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'d8fde9ecf9e8c2efe7e8eef9e4fbe8'](‪or)end return end end end ‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'ddffe2eee8fefe']=function ()for break‪‪‪‪‪‪‪‪‪,‪‪‪‪local in ‪[‪‪‪‪‪‪‪'fdece4fffe'](‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'cceef9e4fbe8d9ecfee6'])do ‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'ddffe2eee8fefec0e4fefee4e2e3'](break‪‪‪‪‪‪‪‪‪,‪‪‪‪local)end end ‪[‪‪‪‪‪‪‪'fdffe4e3f9'](‪‪‪‪‪‪‪'d6c0dcded0adc1e4eee8e3fee8adfdecfefee8e9')‪[‪‪‪‪‪‪‪'e5e2e2e6'][‪‪‪‪‪‪‪'cce9e9'](‪‪‪‪‪‪‪'d9e5e4e3e6',‪‪‪‪‪‪‪'c0dcdea3c0ece4e3d9e5e4e3e6',‪[‪‪‪‪‪‪‪'c0dcde'][‪‪‪‪‪‪‪'ddffe2eee8fefe'])end ,function (‪‪‪‪‪‪‪‪‪‪‪‪break)‪[‪‪‪‪‪‪‪'c0feeace'](‪[‪‪‪‪‪‪‪'cee2e1e2ff'](255,0,0),‪‪‪‪‪‪‪'d6c0dcded0addaecffe3e4e3eaacadc0dcdeade9e4e9ade3e2f9ade1e2ece9adeee2ffffe8eef9e1f4a387d4e2f8adfae4e1e1adfee8e8adf9e5e4feade0e8fefeeceae8ade4ebadf4e2f8ffadfee8fffbe8ffade5ecfeade3e2ade4e3f9e8ffe3e8f9adeee2e3e3e8eef9e4e2e3ade2ffadf9e5e8ade5e2fef9ade4feadefe1e2eee6e4e3eaadc9dfc0adeee5e8eee6a387')end )
end)