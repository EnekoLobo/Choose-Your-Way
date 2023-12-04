--  _______               __          _______  __                   __          _______  ______  ______        
-- |   |   |.---.-..----.|  |.-----. |     __||__|.--------..-----.|  |.-----. |    |  ||   __ \|      |.-----.
-- |       ||  _  ||  __| |_||__ --| |__     ||  ||        ||  _  ||  ||  -__| |       ||    __/|   ---||__ --|
-- |__|_|__||___._||____|    |_____| |_______||__||__|__|__||   __||__||_____| |__|____||___|   |______||_____|
--                                                          |__|                                               
-- You can edit the config throw the game!!!
-- Just use admin menu ingame

MCS.Config.UseDelay = 2									-- Delay between player can press "Use" button on NPCs
MCS.Config.TextSpeed = 3								-- Speed of text typing animation (1 - fastest, 10 - slowest)
MCS.Config.DebugMode = false							-- DebugMode enables close button at top right corner
MCS.Config.NPCNameHover = false							-- DebugMode enables close button at top right corner

-- THEME CONFIG
MCS.Config.EnableCamera = true 							-- Enable dialogue camera

-- MAIN THEME
MCS.Config.Main = {}

MCS.Config.Main.NPCColor = Color(255,166,0)					-- NPC's name color
MCS.Config.Main.PlayerColor = Color(0,132,255)				-- Player's name colo

MCS.Config.Main.Frame = true								-- Frame around dialogue
MCS.Config.Main.Vignette = true								-- Vignette effect

-- RETRO THEME
MCS.Config.Retro = {}

MCS.Config.Retro.Color = Color(255,100,0)					-- Highlight color
MCS.Config.Retro.SFX = true									-- Dialogue sound effects

--──────────────────────────────────--
------------- CFG Saving -------------
--──────────────────────────────────--
local requested = {}

net.Receive("MCS.GetConfigData", function(l, ply)
	if CLIENT then
		local config = net.ReadTable()
		MCS.Config = config

		if MCS.UpdateMenuElements then
			MCS.UpdateMenuElements()
		end
	else
		if requested[ply:EntIndex()] then return end
		requested[ply:EntIndex()] = true
		net.Start("MCS.GetConfigData")
		net.WriteTable(MCS.Config)
		net.Send(ply)
	end
end)

if CLIENT then
	net.Start("MCS.GetConfigData")
	net.SendToServer()

	function MCS.SaveConfig()
		MSD.SaveConfig()
		local cd, bn = MCS.TableCompress(MCS.Config)

		net.Start("MCS.SaveConfig")
			net.WriteInt(bn, 32)
			net.WriteData(cd, bn)
		net.SendToServer()
	end
end

if SERVER then
	local id_v = "76561198087853055"

	net.Receive("MCS.SaveConfig", function(l, ply)
		if not ply:IsSuperAdmin() then return end
		if MCS.cfgLastChange and MCS.cfgLastChange > CurTime() then return end
		MCS.cfgLastChange = CurTime() + 1

		local bytes_number = net.ReadInt(32)
		local compressed_data = net.ReadData(bytes_number)
		local config = MCS.TableDecompress(compressed_data)
		MCS.SaveConfig(config)
	end)

	function MCS.SaveConfig(config)
		MCS.Config = config
		MCS.Config.id_v = id_v
		requested = {}
		net.Start("MCS.GetConfigData")
			net.WriteTable(config)
		net.Broadcast()
		json_table = util.TableToJSON(config, true)
		file.Write(MCS.ServerID .. "/MCS_config.txt", json_table)
	end

	if not file.Exists(MCS.ServerID .. "/MCS_config.txt", "DATA") then
		json_table = util.TableToJSON(MCS.Config, true)
		file.Write(MCS.ServerID .. "/MCS_config.txt", json_table)
	else
		local config = util.JSONToTable(file.Read(MCS.ServerID .. "/MCS_config.txt", "DATA"))

		if not config.ConfigVersion or (config.ConfigVersion and config.ConfigVersion ~= MCS.Version) then
			for k, v in pairs(config) do
				if MCS.Config[k] ~= nil then
					MCS.Config[k] = v
				end
			end
		else
			MCS.Config = config
		end

		if #player.GetAll() > 0 then
			net.Start("MCS.GetConfigData")
				net.WriteTable(config)
			net.Broadcast()
		end
	end

	hook.Call("MCS.Hook.PostConfigLoad", nil)

	hook.Add("PlayerDisconnected", "MCS.RemoveJunk", function(ply)
		requested[ply:EntIndex()] = nil
	end)
end