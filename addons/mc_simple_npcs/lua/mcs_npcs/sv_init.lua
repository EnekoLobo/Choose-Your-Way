--  _______               __          _______  __                   __          _______  ______  ______        
-- |   |   |.---.-..----.|  |.-----. |     __||__|.--------..-----.|  |.-----. |    |  ||   __ \|      |.-----.
-- |       ||  _  ||  __| |_||__ --| |__     ||  ||        ||  _  ||  ||  -__| |       ||    __/|   ---||__ --|
-- |__|_|__||___._||____|    |_____| |_______||__||__|__|__||   __||__||_____| |__|____||___|   |______||_____|
--                                                          |__|      
--
util.AddNetworkString("MCS.OpenMenu")
util.AddNetworkString("MCS.SetupMenu")
util.AddNetworkString("MCS.CloseMenu")
util.AddNetworkString("MCS.SrartSvFunc")
util.AddNetworkString("MCS.Dialogue")
util.AddNetworkString("MCS.SrartAnimation")
util.AddNetworkString("MCS.GetConfigData")
util.AddNetworkString("MCS.SaveConfig")

function MCS.SpawnNPC(npc, uid, pos, ang)
	npc.uselimit = npc.uselimit or false
	local ent = ents.Create("mcs_npc")
	ent:SetModel(npc.model)
	ent:SetModelScale(npc.scale or 1)
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:SetNamer(npc.name)
	ent:SetUID(uid)
	ent:SetInputLimit(npc.uselimit)
	ent:SetUseType(SIMPLE_USE)
	ent:SetSolid(SOLID_BBOX)
	ent:PhysicsInit(SOLID_BBOX)
	ent:SetMoveType(MOVETYPE_NONE)

	ent.canscare = npc.scare_timer and npc.scare_timer > 0

	if npc.submat then
		for k, v in pairs(npc.submat) do
			ent:SetSubMaterial(k, v)
		end
	end

	if npc.bgr then
		for k, v in pairs(npc.bgr) do
			ent:SetBodygroup(k, v)
		end
	end

	if npc.skin then
		ent:SetSkin(npc.skin)
	end
	ent:Spawn()

	if npc.invisible then
		ent:SetNoDraw(true)
	end

	if npc.sequence then
		local sequence = npc.sequence

		if istable(sequence) then
			ent.randSequence = sequence
			sequence = table.Random(sequence)
		end

		ent.AutomaticFrameAdvance = true
		ent:SetDefAnimation(sequence)
		ent:ResetSequence(sequence)
		ent:SetCycle(0)
	end

	return ent
end

function MCS.SpawnAllNPCs()
	print( "[MCS NPCs] Spawning NPCs" )
	for _, ent in pairs(ents.FindByClass("mcs_npc")) do
		if IsValid(ent) then
			ent:Remove()
			print( "[MCS NPCs] Old npc found removing..." )
		end
	end

	for uid, npc in pairs(MCS.Spawns) do
		local spawnpos = npc.pos[string.lower(game.GetMap())] or npc.pos["all"]
		if not spawnpos then continue end
		MCS.SpawnNPC(npc, uid, spawnpos[1], spawnpos[2])

		print( "[MCS NPCs] Spawning npc - " .. npc.name .. " [" .. uid .. "]" )
	end
end

concommand.Add("mcs_npcrespawn", function(ply)
	if not ply:IsSuperAdmin() then return end
	MCS.SpawnAllNPCs()
end)

hook.Add("PostCleanupMap", "MCS.PostCleanupMap", function()
	MCS.SpawnAllNPCs()
end)

-- Fix for addons that add custom animations, to avoid floating animation. We need to respawn npcs after loading there models for the first time
timer.Simple(5, function() MCS.SpawnAllNPCs() end)
timer.Simple(10, function() MCS.SpawnAllNPCs() end)

concommand.Add("mcs_setup", function(ply)
	if not ply:IsSuperAdmin() then return end
	net.Start("MCS.SetupMenu")
	net.Send(ply)
end)

net.Receive("MCS.Dialogue", function(l, ply)
	if  MCS.SpamBlock(ply, 0.5) then return end
	local lid = net.ReadUInt(15)
	local aid = net.ReadUInt(15)
	local npc = net.ReadEntity()

	if not aid or not lid or not IsValid(npc) or not npc.GetUID or not MCS.Spawns[npc:GetUID()] then return end

	local dialog = MCS.Spawns[npc:GetUID()].dialogs

	if not dialog or not dialog[lid] then return end

	local fa = " "
	local data

	if aid == 0 and dialog[lid]["CallBack"] then
		fa = dialog[lid]["CallBack"].name
		data = dialog[lid]["CallBack"].data
	else
		if not dialog[lid]["Answers"] or not dialog[lid]["Answers"][aid] or not dialog[lid]["Answers"][aid][2] then return end

		fa = dialog[lid]["Answers"][aid][2]
		if istable(fa) then
			data = fa.data
			fa = fa.id
		end
	end

	if MCS.AddonList[fa] and MCS.AddonList[fa]["enabled"] and MCS.AddonList[fa]["function_sv"] then
		MCS.AddonList[fa]["function_sv"](ply, npc, data)
	end
end)

net.Receive("MCS.CloseMenu", function(l, ply)
	local npc = net.ReadEntity()
	if not npc or not IsValid(npc) then return end
	npc.UsingPlayer = false

	if npc.LastAnim and npc.LastAnim + 1 > CurTime() then return end
	local seq = npc:GetDefAnimation()
	if npc.randSequence then seq =  table.Random(npc.randSequence) end
	npc:ResetSequence(seq)
	npc:SetCycle(0)
end)

net.Receive("MCS.SrartAnimation", function(l, ply)
	if  MCS.SpamBlock(ply, 0.1) then return end
	local npc = net.ReadEntity()
	local anim = net.ReadString()
	if not npc or not IsValid(npc) or not anim then return end
	npc:ResetSequence(anim)
	npc:SetCycle(0)
	npc.LastAnim = CurTime()
end)

function MCS.SpamBlock(ply, t)
	if not IsValid(ply) then return true end
	if ply.MCSCkeck and ply.MCSCkeck + t > CurTime() then return true end
	ply.MCSCkeck = CurTime()

	return false
end