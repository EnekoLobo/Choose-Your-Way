--   __  __                  _            _____   _                       _            _   _   _____     _____       
--  |  \/  |                ( )          / ____| (_)                     | |          | \ | | |  __ \   / ____|      
--  | \  / |   __ _    ___  |/   ___    | (___    _   _ __ ___    _ __   | |   ___    |  \| | | |__) | | |       ___ 
--  | |\/| |  / _` |  / __|     / __|    \___ \  | | | '_ ` _ \  | '_ \  | |  / _ \   | . ` | |  ___/  | |      / __|
--  | |  | | | (_| | | (__      \__ \    ____) | | | | | | | | | | |_) | | | |  __/   | |\  | | |      | |____  \__ \
--  |_|  |_|  \__,_|  \___|     |___/   |_____/  |_| |_| |_| |_| | .__/  |_|  \___|   |_| \_| |_|       \_____| |___/
--                                                               | |                                                 
--                                                               |_|       V 1.5.3                        
MCS = {}
MCS.Spawns = {}
MCS.Config = {}
MCS.Themes = {}
MCS.Version = "1.5.4"
MCS.ServerID = "MCS77656119808785303001ID"
MCS.MainUserID = "76561198087853030"

function MCS.Load()
	if !file.Exists(MCS.ServerID, "DATA") then
		file.CreateDir(MCS.ServerID)
		print( "[MCS NPCs] Server DATA Dir created" )
	end

	if SERVER then
		print( "[MCS NPCs] Server init starting" )
		include("mcs_npcs/sh_addonsup.lua")
		include("mcs_npcs/sh_config.lua")
		include("mcs_npcs/sh_npcspawn.lua")
		include("mcs_npcs/sv_init.lua")
		AddCSLuaFile("mcs_npcs/sh_addonsup.lua")
		AddCSLuaFile("mcs_npcs/sh_config.lua")
		AddCSLuaFile("mcs_npcs/sh_npcspawn.lua")
		AddCSLuaFile("mcs_npcs/cl_init.lua")
		AddCSLuaFile("mcs_npcs/cl_util.lua")
		AddCSLuaFile("mcs_npcs/cl_menu.lua")
	else
		print( "[MCS NPCs] Client init starting" )
		include("mcs_npcs/sh_addonsup.lua")
		include("mcs_npcs/sh_config.lua")
		include("mcs_npcs/sh_npcspawn.lua")
		include("mcs_npcs/cl_init.lua")
		include("mcs_npcs/cl_util.lua")
		include("mcs_npcs/cl_menu.lua")
	end

	local files = file.Find("mcs_npcs/themes/*", "LUA")

	for k, v in pairs(files) do
		if SERVER then
			print("[MCS NPCs] Adding theme " .. k .. " " .. v)
			include("mcs_npcs/themes/" .. v)
			AddCSLuaFile("mcs_npcs/themes/" .. v)
		else
			include("mcs_npcs/themes/" .. v)
		end
	end

	files = file.Find("mcs_npcs/npcs/*", "LUA")

	for k, v in pairs(files) do
		if SERVER then
			include("mcs_npcs/npcs/" .. v)
			AddCSLuaFile("mcs_npcs/npcs/" .. v)
		else
			include("mcs_npcs/npcs/" .. v)
		end
		print( "[MCS NPCs] Added file " .. v)
	end

	print( "[MCS NPCs] Init done" )
end

if SERVER then
	hook.Add("PostGamemodeLoaded", "MCS.Load.SV", function() MCS.Load() end)
else
	hook.Add("InitPostEntity", "MCS.Load.CL", function() MCS.Load() end)
end

if GAMEMODE then
	MCS.Load()
end