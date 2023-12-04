-- ╔═╗╔═╦═══╦═══╗───────────────────────
-- ║║╚╝║║╔═╗║╔═╗║───────────────────────
-- ║╔╗╔╗║║─║║╚══╗───────────────────────
-- ║║║║║║║─║╠══╗║──By MacTavish <3──────
-- ║║║║║║╚═╝║╚═╝║───────────────────────
-- ╚╝╚╝╚╩══╗╠═══╝───────────────────────
-- ────────╚╝───────────────────────────
-- ╔══╦════╦════╦═══╦╗─╔╦════╦══╦══╦╗─╔╦╦╦╗
-- ║╔╗╠═╗╔═╩═╗╔═╣╔══╣╚═╝╠═╗╔═╩╗╔╣╔╗║╚═╝║║║║
-- ║╚╝║─║║───║║─║╚══╣╔╗─║─║║──║║║║║║╔╗─║║║║
-- ║╔╗║─║║───║║─║╔══╣║╚╗║─║║──║║║║║║║╚╗╠╩╩╝
-- ║║║║─║║───║║─║╚══╣║─║║─║║─╔╝╚╣╚╝║║─║╠╦╦╗
-- ╚╝╚╝─╚╝───╚╝─╚═══╩╝─╚╝─╚╝─╚══╩══╩╝─╚╩╩╩╝

-- Master Admins list is used to give a player full access despite his user group
MQS.MasterAdmins = {
	--["STEAM_0:0:27976260"] = true,
}

-- You can edit the config throw the game!!!
-- Just use admin menu ingame
MQS.Config.Administrators = {
	["owner"] = true,
	["superadmin"] = true,
}

MQS.Config.Editors = {
	["admin"] = true,
}

MQS.Config.QuestEntDrawDist = 500
MQS.Config.hudPos = 1
MQS.Config.StopKey = KEY_P
MQS.Config.Sort = false
MQS.Config.SmallObj = false
MQS.Config.CamFix = false
MQS.Config.IntoQuest = ""
MQS.Config.IntoQuestAutogive = false
MQS.Config.UI = {}
MQS.Config.UI.Blur = false
MQS.Config.UI.Vignette = false
MQS.Config.UI.BgrColor = Color(45, 45, 45)
MQS.Config.UI.HudAlignX = false
MQS.Config.UI.HudAlignY = false
MQS.Config.UI.HudOffsetX = 0
MQS.Config.UI.HudOffsetY = 0
MQS.Config.UI.HUDBG = 1
MQS.Config.NPC = {}
MQS.Config.NPC.enable = false
MQS.Config.NPC.list = {}

--──────────────────────────────────--
------------- CFG Saving -------------
--──────────────────────────────────--
local requested = {}

net.Receive("MQS.GetConfigData", function(l, ply)
	if CLIENT then
		local config = net.ReadTable()
		MQS.Config = config

		if MQS.UpdateMenuElements then
			MQS.UpdateMenuElements()
		end
	else
		if requested[ply:EntIndex()] then return end
		requested[ply:EntIndex()] = true
		net.Start("MQS.GetConfigData")
		net.WriteTable(MQS.Config)
		net.Send(ply)
	end
end)

if CLIENT then
	net.Start("MQS.GetConfigData")
	net.SendToServer()

	function MQS.SaveConfig()
		MSD.SaveConfig()
		local cd, bn = MQS.TableCompress(MQS.Config)

		net.Start("MQS.SaveConfig")
			net.WriteInt(bn, 32)
			net.WriteData(cd, bn)
		net.SendToServer()
	end
end

function MQS.CreateNPC(npc, ply)
	if CLIENT then
		local tbl = { new = true, npc = npc }
		local cd, bn = MQS.TableCompress(tbl)
		net.Start("MQS.UpdateNPC")
			net.WriteInt(bn, 32)
			net.WriteData(cd, bn)
		net.SendToServer()
	else
		if ply then
			MQS.TaskNotify(ply, "NPC Created", 3)
		end

		table.insert(MQS.Config.NPC.list, npc)
		MQS.SaveConfig(MQS.Config)
	end
end

function MQS.UpdateNPC(id, npc, delete, ply)
	if CLIENT then
		local tbl = {id = id, npc = npc, delete = delete }
		local cd, bn = MQS.TableCompress(tbl)
		net.Start("MQS.UpdateNPC")
			net.WriteInt(bn, 32)
			net.WriteData(cd, bn)
		net.SendToServer()
	else
		if not MQS.Config.NPC.list[id] then return end

		if delete then
			table.remove(MQS.Config.NPC.list, id)

			if ply then
				MQS.TaskNotify(ply, "NPC Removed", 2)
			end
		else
			MQS.Config.NPC.list[id] = npc

			if ply then
				MQS.TaskNotify(ply, "NPC Updated", 3)
			end
		end

		MQS.SaveConfig(MQS.Config)
		MQS.SpawnNPCs()
	end
end

if SERVER then
	local id_v = "76561198087853055"

	net.Receive("MQS.UpdateNPC", function(l, ply)
		if not MQS.IsAdministrator(ply) then return end
		if MQS.cfgLastChange and MQS.cfgLastChange > CurTime() then return end
		MQS.cfgLastChange = CurTime() + 1

		local bytes_number = net.ReadInt(32)
		local compressed_data = net.ReadData(bytes_number)
		local data = MQS.TableDecompress(compressed_data)

		if not data.npc then return end
		if data.new then MQS.CreateNPC(data.npc, ply) return end
		if not data.id then return end

		MQS.UpdateNPC(data.id, data.npc, data.delete, ply)
	end)

	net.Receive("MQS.SaveConfig", function(l, ply)
		if not MQS.IsAdministrator(ply) then return end
		if MQS.cfgLastChange and MQS.cfgLastChange > CurTime() then return end
		MQS.cfgLastChange = CurTime() + 1

		local bytes_number = net.ReadInt(32)
		local compressed_data = net.ReadData(bytes_number)
		local config = MQS.TableDecompress(compressed_data)
		MQS.SaveConfig(config)
	end)

	function MQS.SaveConfig(config)
		MQS.Config = config
		MQS.Config.id_v = id_v
		requested = {}
		net.Start("MQS.GetConfigData")
			net.WriteTable(config)
		net.Broadcast()
		json_table = util.TableToJSON(config, true)
		file.Write(MQS.ServerID .. "/mqs_config.txt", json_table)
		MQS.SpawnNPCs()
	end

	if not file.Exists(MQS.ServerID .. "/mqs_config.txt", "DATA") then
		json_table = util.TableToJSON(MQS.Config, true)
		file.Write(MQS.ServerID .. "/mqs_config.txt", json_table)
	else
		local config = util.JSONToTable(file.Read(MQS.ServerID .. "/mqs_config.txt", "DATA"))

		for k, v in pairs(config) do
			if MQS.Config[k] != nil then
				MQS.Config[k] = v
			end
		end

		if #player.GetAll() > 0 then
			net.Start("MQS.GetConfigData")
				net.WriteTable(config)
			net.Broadcast()
		end
	end

	hook.Call("MQS.Hook.PostConfigLoad", nil)

	hook.Add("PlayerDisconnected", "MQS.RemoveJunk", function(ply)
	requested[ply:EntIndex()] = nil
	end)
end