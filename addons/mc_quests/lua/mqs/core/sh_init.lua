-- ╔═╗╔═╦═══╦═══╗───────────────────────
-- ║║╚╝║║╔═╗║╔═╗║───────────────────────
-- ║╔╗╔╗║║─║║╚══╗───────────────────────
-- ║║║║║║║─║╠══╗║──By MacTavish <3──────
-- ║║║║║║╚═╝║╚═╝║───────────────────────
-- ╚╝╚╝╚╩══╗╠═══╝───────────────────────
-- ────────╚╝───────────────────────────

--──────────────────────────────────--
-------------- Events ---------------
--──────────────────────────────────--

MQS.Events["Spawn quest entity"] = function(id, ply, data, obj, task)

	local ent = ents.Create("mqs_ent")
	ent.model = data[1]
	ent.task = task
	ent.task_id = id
	ent.task_ply = ply
	ent.pointer = data[3]
	ent.enablephys = data[4]
	ent.allies = {}
	if data[9] and MQS.ActiveTask[id].vehicle then
		local veh = Entity(MQS.ActiveTask[id].vehicle)
		ent:SetParent(veh)
		ent:SetPos(veh:LocalToWorld(data[2]))
		local ang2 = data[5] or Angle(0,0,0)
		local ang = veh:GetAngles()
		ang:RotateAroundAxis(ang:Right(), ang2.p)
		ang:RotateAroundAxis(ang:Up(), ang2.y)
		ang:RotateAroundAxis(ang:Forward(), ang2.r)
		ent:SetAngles(ang)
	else
		ent:SetPos(data[2])
		if data[5] then
			ent:SetAngles(data[5])
		end
	end

	if data[6] then
		ent:SetMaterial(data[6])
	end

	if data[6] == "null" then
		ent:DrawShadow(false)
	end

	if data[7] then
		if data[7].a and  data[7].a < 255 then
			ent:SetRenderMode( RENDERMODE_TRANSCOLOR )
		end
		ent:SetColor(data[7])
	end

	if data[8] then
		ent:SetUseHold(data[8])
	end
	ent.IsMQS = true
	ent:Spawn()

	if not MQS.ActiveTask[id].ents then
		MQS.ActiveTask[id].ents = {}
	end

	table.insert(MQS.ActiveTask[id].ents, ent:EntIndex())

	if data[10] then
		ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
	end

	if data[11] then
		ent.updateobj = data[11]
	end

	for k,v in pairs( ents.FindInSphere(data[2], 10) ) do
		if not IsValid(v) or v:GetClass() ~= "mqs_ent" or v.task_ply == ply then continue end
		table.insert(ent.allies, v)
	end
end

MQS.Events["Spawn vehicle"] = function(task, ply, data)
	if MQS.ActiveTask[task].vehicle then return end
	local vehicle = MQS.SpawnQuestVehicle(ply, data[1], data[2], data[3], data[4])
	if not vehicle then return end

	if data[5] then
		vehicle:SetSkin(data[5])
	end

	if data[7] then
		vehicle:SetColor(data[7])
	end
	vehicle.isMQS = task
	vehicle.IsMQS = true
	vehicle = vehicle:EntIndex()

	if not MQS.ActiveTask[task].vehicle then
		MQS.ActiveTask[task].vehicle = vehicle
	end
end

MQS.Events["Remove vehicle"] = function(task, ply, data)
	if not MQS.ActiveTask[task].vehicle then return end
	local veh = Entity(MQS.ActiveTask[task].vehicle)
	MQS.ActiveTask[task].vehicle = nil

	if data and data > 0 then
		timer.Simple(data, function()
			if IsValid(veh) and veh.IsMQS then
				SafeRemoveEntity(veh)
			end
		end)
	else
		if IsValid(veh) and veh.IsMQS then
			SafeRemoveEntity(veh)
		end
	end
end

MQS.Events["Check for vehicle"] = function(task, ply, data)
	if not MQS.ActiveTask[task].vehicle then return end
	local veh = Entity(MQS.ActiveTask[task].vehicle)
	MQS.ActiveTask[task].vehicle = nil

	if IsValid(veh) and veh.IsMQS and data[1]:DistToSqr(veh:GetPos()) > data[2] ^ 2 then
		MQS.FailTask(ply, MSD.GetPhrase("vehicle_bum"))
	end
end

MQS.Events["Spawn entity"] = function(id, ply, data, obj, task)
	if data[1] == "worldspawn" then return end
	local ent = ents.Create(data[1])

	if not ent:IsValid() then
		MsgC(Color(255, 0, 0), "[MQS] Quest id: " .. task .. " failed to create " .. data[1] .. "!\n")

		return
	end

	ent:SetPos(data[2])
	ent:SetAngles(data[3])

	if data[4] then
		ent:SetModel(data[4])
	end

	if data[6] then
		ent:SetMaterial(data[6])
	end

	if data[7] then
		if data[7].a and  data[7].a < 255 then
			ent:SetRenderMode( RENDERMODE_TRANSCOLOR )
		end
		ent:SetColor(data[7])
	end

	ent.IsMQS = data[8] or "default"
	ent:Spawn()

	table.insert(MQS.ActiveTask[id].misc_ents, ent:EntIndex())

	if data[5] then
		local phys = ent:GetPhysicsObject()

		if phys:IsValid() then
			phys:EnableMotion(false)
		end
	end
end

MQS.Events["Remove entites by ID"] = function(task, ply, data)
	if MQS.ActiveTask[task].misc_ents then
		for k, v in pairs(MQS.ActiveTask[task].misc_ents) do
			local ent = ents.GetByIndex(v)
			if IsValid(ent) and ent.IsMQS == data[1] then
				SafeRemoveEntity(ent)
				MQS.ActiveTask[task].misc_ents[k] = nil
			end
		end
	end
end

MQS.Events["Remove all entites"] = function(task, ply, data)
	if MQS.ActiveTask[task].misc_ents then
		for k, v in pairs(MQS.ActiveTask[task].misc_ents) do
			local ent = ents.GetByIndex(v)
			if IsValid(ent) and ent.IsMQS then
				SafeRemoveEntity(ent)
			end
		end
	end
	MQS.ActiveTask[task].misc_ents = {}
end

MQS.Events["Spawn npc"] = function(id, ply, data, obj, task)
	local ent = ents.Create(data[1])

	if not ent:IsValid() then
		MsgC(Color(255, 0, 0), "[MQS] Quest id: " .. task .. " failed to create " .. data[1] .. "!\n")
		return
	end

	data[2].z = data[2].z + 30
	ent:SetPos(data[2])
	ent:SetAngles(data[3])

	if data[4] then
		ent.is_quest_npc = task
		ent:SetNWBool( "MQSTarget", true )
		MQS.ActiveTask[id].npcs = MQS.ActiveTask[id].npcs and MQS.ActiveTask[id].npcs + 1 or 1
	end
	ent.IsMQS = true
	ent.quest_id = id
	ent:Spawn()
	ent:Activate()

	if data[5] then
		ent:SetModel(data[5])
	end

	if data[6] then
		ent:Give(data[6])
	end

	if data[9] then
		ent:SetHealth(data[9])
	end

	if not data[8] then
		local gr = "D_HT"
		if data[7] then
			ent:AddEntityRelationship(ply, 1, 99)
			ent:SetNPCState(NPC_STATE_COMBAT)
		else
			ent:AddEntityRelationship(ply, 4, 99)
			gr = "D_LI"
		end
		if obj.open_target then
			ent:AddRelationship("player " .. gr .. " 99")
			ent.open_target = true
		else
			ent:AddRelationship("player D_NU 99")
		end
		ent:SetKeyValue("spawnflags", bit.bor(SF_NPC_NO_WEAPON_DROP))
	end
	table.insert(MQS.ActiveTask[id].misc_ents, ent:EntIndex())
end

MQS.Events["Give weapon"] = function(task, ply, data)
	local weapon = ply:Give(data)
	if IsValid(weapon) and weapon ~= NULL then
		weapon.MQS_weapon = true
	end
end

MQS.Events["Give ammo"] = function(task, ply, data)
	ply:GiveAmmo(data[2], data[1], false)
end

MQS.Events["Strip Weapon"] = function(task, ply, data)
	ply:StripWeapon(data)
end

MQS.Events["Strip All Weapons"] = function(task, ply, data)
	ply.MQS_oldWeap = ply.MQS_oldWeap or {}

	if data then
		ply.MQS_restore = true
	end

	for _, wep in pairs(ply:GetWeapons()) do
		if wep.MQS_weapon then continue end
		ply.MQS_oldWeap[wep:GetClass()] = true
	end

	ply:StripWeapons()
end

MQS.Events["Restore All Weapons"] = function(task, ply)
	for wep, _ in pairs(ply.MQS_oldWeap) do
		ply:Give(wep)
	end
end

MQS.Events["Manage do time"] = function(task, ply, data)
	if not MQS.GetNWdata(ply, "do_time") then return end
	if isbool(data[1]) then data[1] = 1 end

	if data[1] == 1 then
		local q = MQS.ActiveTask[task].task
		MQS.SetNWdata(ply, "do_time", CurTime() + MQS.Quests[q].do_time)
	elseif data[1] == 2 then
		MQS.SetNWdata(ply, "do_time", MQS.GetNWdata(ply, "do_time") + data[2])
	else
		MQS.SetNWdata(ply, "do_time", CurTime() + data[2])
	end

end

MQS.Events["Set HP"] = function(task, ply, data)
	if data[1] then
		ply:SetHealth(ply:GetMaxHealth())
	else
		ply:SetHealth(data[2])
	end
end

MQS.Events["Set Armor"] = function(task, ply, data)
	ply:SetArmor(math.Clamp(data[1], 0, 255))
end

MQS.Events["Teleport player"] = function(task, ply, data)
	ply:SetPos( data[1] )
	ply:SetEyeAngles( data[2] )
	ply:SetLocalVelocity( Vector( 0, 0, 0 ) )
end

MQS.Events["Set spawn point"] = function(task, ply, data)
	if data[1] then
		ply.EventData.SpawnPoint = data
	else
		ply.EventData.SpawnPoint = nil
	end
end

MQS.Events["Cinematic camera"] = function(task, ply, data)
	net.Start("MQS.UIEffect")
		net.WriteString("Cinematic camera")
		net.WriteTable(data)
	net.Send(ply)
end

MQS.Events["Music player"] = function(task, ply, data)
	net.Start("MQS.UIEffect")
		net.WriteString("Music")
		net.WriteTable(data)
	net.Send(ply)
end

MQS.Events["[MCS] Spawn npc"] = function(task, ply, data)
	local npc = MCS.Spawns[data[1]]
	if not npc then return end

	local ent = MCS.SpawnNPC(npc, data[1], data[2], data[3])
	ent.IsMQS = true
	ent:SetCollisionGroup(COLLISION_GROUP_PLAYER)

	table.insert(MQS.ActiveTask[task].misc_ents, ent:EntIndex())

	MQS.ActiveTask[task].LastPoint = ent:GetPos()

	net.Start("MQS.UIEffect")
		net.WriteString("NPCPosition")
		net.WriteTable({id = data[1], pos = ent:GetPos()})
	net.Send(ply)
end

MQS.Events["Run Console Command"] = function(task, ply, data)
	local cmd = data[1]
	local args = data[2]
	local cmd_arg = ""
	args = string.Explode(" ", args)

	for _, arg in pairs(args) do
		if arg == "$uid" then
			arg = ply:UserID()
		end

		if arg == "$sid" then
			arg = ply:SteamID()
		end

		if arg == "$s64" then
			arg = ply:SteamID64()
		end

		if arg == "$n" then
			arg = "\"" .. ply:Name() .. "\""
		end

		cmd_arg = cmd_arg .. " " .. arg
	end
	game.ConsoleCommand(cmd .. cmd_arg .. "\n")
end

MQS.Events["Track player"] = function(task, ply, data)
	local ntable = {
		id = task,
		uid = ply:UserID(),
		text = data[1],
		icon = data[2],
		teams = data[3]
	}

	local filter = RecipientFilter()

	for _, p in pairs(player.GetAll()) do
		if p == ply then continue end
		if data[3][team.GetName(p:Team())] then
			filter:AddPlayer(p)
		end
	end

	net.Start("MQS.UIEffect")
		net.WriteString("Track")
		net.WriteTable(ntable)
	net.Send(filter)

	MQS.Notify(ply, MSD.GetPhrase("warning"), MSD.GetPhrase("youaretracked"), 4)
end

MQS.Events["End track player"] = function(task, ply, data)
	net.Start("MQS.UIEffect")
		net.WriteString("UnTrack")
		net.WriteTable({id = task})
	net.Broadcast()

	MQS.Notify(ply, MSD.GetPhrase("m_loop"), MSD.GetPhrase("nolongertracked"), 4)
end

--──────────────────────────────────--
-------------- Rewards ---------------
--──────────────────────────────────--

MQS.Rewards["Give Weapon"] = {
	reward = function(ply, val)
		ply:Give(val[1])
	end,
}

MQS.Rewards["DarkRP money"] = {
	check = function()
		if DarkRP then return false end

		return true
	end,
	reward = function(ply, val)
		ply:addMoney(val[1])
	end,
}

MQS.Rewards["DarkRP karma"] = {
	check = function()
		if DarkRP then return false end

		return true
	end,
	reward = function(ply, val)
		ply:addKarma(val[1])
	end,
}

MQS.Rewards["PointShop2 Standard Points"] = {
	check = function()
		if Pointshop2 then return false end

		return true
	end,
	reward = function(ply, val)
		ply:PS2_AddStandardPoints(val[1])
	end,
}

MQS.Rewards["PointShop2 Premium Points"] = {
	check = function()
		if Pointshop2 then return false end

		return true
	end,
	reward = function(ply, val)
		ply:PS2_AddPremiumPoints(val[1])
	end,
}

MQS.Rewards["PointShop2 Give Item"] = {
	check = function()
		if Pointshop2 then return false end

		return true
	end,
	reward = function(ply, val)
		ply:PS2_EasyAddItem(val[1])
	end,
}

MQS.Rewards["PointShop Points"] = {
	check = function()
		if PS then return false end

		return true
	end,
	reward = function(ply, val)
		ply:PS_GivePoints(val[1])
	end,
}

MQS.Rewards["PointShop Give Item"] = {
	check = function()
		if PS then return false end

		return true
	end,
	reward = function(ply, val)
		ply:PS_GiveItem(val[1])
	end,
}

MQS.Rewards["DarkRP Leveling System"] = {
	check = function()
		if LevelSystemConfiguration then return false end

		return true
	end,
	reward = function(ply, val)
		ply:addXP(val[1])
	end,
}

MQS.Rewards["Glorified Leveling"] = {
	check = function()
		if GlorifiedLeveling then return false end

		return true
	end,
	reward = function(ply, val)
		GlorifiedLeveling.AddPlayerXP(ply, val[1])
		if val[2] then
			GlorifiedLeveling.AddPlayerLevels(ply, val[2])
		end
	end,
}

MQS.Rewards["Helix money"] = {
	check = function()
		if ix then return false end

		return true
	end,
	reward = function(ply, val)
		ply:GetCharacter():GiveMoney(val[1])
	end,
}

MQS.Rewards["Run Console Command"] = {
	reward = function(ply, val)
		local cmd = val[1]
		local args = val[2]
		local cmd_arg = ""
		args = string.Explode(" ", args)

		for _, arg in pairs(args) do
			if arg == "$uid" then
				arg = ply:UserID()
			end

			if arg == "$sid" then
				arg = "\"" .. ply:SteamID() .. "\""
			end

			if arg == "$s64" then
				arg = ply:SteamID64()
			end

			if arg == "$n" then
				arg = "\"" .. ply:Name() .. "\""
			end

			cmd_arg = cmd_arg .. " " .. arg
		end
		game.ConsoleCommand(cmd .. cmd_arg .. "\n")
	end,
}

MQS.Rewards["Wiltos skill XP"] = {
	check = function()
		if wOS then return false end
		return true
	end,
	reward = function(ply, val)
		ply:AddSkillXP(val[1])
	end,
}

MQS.Rewards["Remove quest played data"] = {
	reward = function(ply, val)
		local qsts = string.Explode(",", val[1])

		local qs = ply.MQSdata.Stored.QuestList

		for k,v in ipairs(qsts) do
			if not qs[v] then continue end
			qs[v] = nil
		end

		MQS.SetNWStoredData(ply, "QuestList", qs)
	end,
}

MQS.Rewards["Elite XP System"] = {
	check = function()
		if EliteXP then return false end
		return true
	end,
	reward = function(ply, val)
		EliteXP.CheckXP(ply, val[1])
	end,
}

MQS.Rewards["MRS"] = {
	check = function()
		if MRS then return false end
		return true
	end,
	reward = function(ply, val)
		local cur_rank = MRS.GetPlyRank(ply, val[1])
		if val[3] == 1 and cur_rank < val[2] then
			MRS.SetPlayerRank(ply, val[1], val[2], true)
		elseif val[3] == 2 then
			MRS.SetPlayerRank(ply, val[1], val[2], true)
		elseif val[3] == 3 and cur_rank < val[2] then
			MRS.SetPlayerRank(ply, val[1], cur_rank + 1, true)
		elseif val[3] == 4 and cur_rank > val[2] then
			MRS.SetPlayerRank(ply, val[1], cur_rank - 1, true)
		end
	end,
}

MQS.Rewards["WCD Give car"] = {
	check = function()
		if WCD then return false end
		return true
	end,
	reward = function(ply, val)
		ply:WCD_AddVehicle( val[1] )
	end,
}

MQS.Rewards["GAS Job Whitelist"] = {
	check = function()
		if GAS and GAS.JobWhitelist then return false end
		return true
	end,
	reward = function(ply, val)
		if GAS.JobWhitelist:IsWhitelisted( ply, val[1], true ) then return end
		GAS.JobWhitelist:AddToWhitelist( val[1], GAS.JobWhitelist.LIST_TYPE_STEAMID, ply:AccountID())
	end,
}