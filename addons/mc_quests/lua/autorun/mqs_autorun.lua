-- ╔═╗╔═╦═══╦═══╗───────────────────────
-- ║║╚╝║║╔═╗║╔═╗║───────────────────────
-- ║╔╗╔╗║║─║║╚══╗───────────────────────
-- ║║║║║║║─║╠══╗║──By MacTavish <3──────
-- ║║║║║║╚═╝║╚═╝║───────────────────────
-- ╚╝╚╝╚╩══╗╠═══╝───────────────────────
-- ────────╚╝───────────────────────────

MQS = {}
MQS.Config = {}

MQS.Quests = {}
MQS.Rewards = {}
MQS.Events = {}

MQS.TaskCount = {}
MQS.TaskQueue = {}
MQS.ActiveTask = {}

MQS.Version = "1.5.0"
MQS.ServerID = "MQS77656119808785303001ID"
MQS.MainUserID = "76561198087853030"
MQS.DB = {}

if SERVER then
	util.AddNetworkString( "MQS.Notify" )
	util.AddNetworkString( "MQS.TaskNotify" )
	util.AddNetworkString( "MQS.SetPData" )
	util.AddNetworkString( "MQS.GetBigData" )
	util.AddNetworkString( "MQS.DataShare" )
	util.AddNetworkString( "MQS.ReQuest" )
	util.AddNetworkString( "MQS.FixPickUP" )
	util.AddNetworkString( "MQS.GetPData" )
	util.AddNetworkString( "MQS.GetOtherQuests" )
	util.AddNetworkString( "MQS.OpenEditor" )
	util.AddNetworkString( "MQS.GetConfigData" )
	util.AddNetworkString( "MQS.SaveConfig" )
	util.AddNetworkString( "MQS.QuestRemove" )
	util.AddNetworkString( "MQS.QuestSubmit" )
	--util.AddNetworkString( "MQS.QuestUpdate" )
	util.AddNetworkString( "MQS.QuestStatus" )
	util.AddNetworkString( "MQS.CreateNPC" )
	util.AddNetworkString( "MQS.UpdateNPC" )
	util.AddNetworkString( "MQS.StartTask" )
	util.AddNetworkString( "MQS.UIEffect" )
	util.AddNetworkString( "MQS.GetPlayersQuests" )
	util.AddNetworkString( "MQS.SavePlayerQuestList" )

	resource.AddWorkshop( "2486994157" )
end

function MQS.Load()

	MsgC( Color(0, 255, 0), "[MQS] Initialization started\n" )
	if !MSD then
		MsgC( Color(255, 0, 0), "[MQS] FAILED To locate MSD module!\nPlease install MSD before using the addon\nLink: https://github.com/the-mactavish/MSD\n" )
	end

	if !file.Exists(MQS.ServerID, "DATA") then
		file.CreateDir(MQS.ServerID)
		MsgC( Color(0, 255, 0), "[MQS] Server DATA Dir created \n" )
	end

	if SERVER then
		MsgC( Color(0, 255, 0), "[MQS] Loading server files\n" )
		include("mqs/sh_config.lua")
		AddCSLuaFile("mqs/sh_config.lua")
		local core = file.Find( "mqs/core/*", "LUA" )
		for k,v in ipairs( core ) do
			if string.StartWith( v, "sh_" ) then
				include( "mqs/core/" .. v )
				AddCSLuaFile( "mqs/core/" .. v )
			elseif string.StartWith( v, "sv_" ) then
				include( "mqs/core/" .. v )
			elseif string.StartWith( v, "cl_" ) then
				AddCSLuaFile( "mqs/core/" .. v )
			end
		end

		local ui = file.Find( "mqs/ui/*", "LUA" )
		for k,v in ipairs( ui ) do
			AddCSLuaFile( "mqs/ui/" .. v )
		end

	else
		MsgC( Color(0, 255, 0), "[MQS] Loading client files\n" )
		include("mqs/sh_config.lua")

		local core = file.Find( "mqs/core/*", "LUA" )
		for k,v in ipairs( core ) do
			if string.StartWith( v, "sh_" ) then
				include( "mqs/core/" .. v )
			elseif string.StartWith( v, "cl_" ) then
				include( "mqs/core/" .. v )
			end
		end

		local ui = file.Find( "mqs/ui/*", "LUA" )
		for k,v in ipairs( ui ) do
			include( "mqs/ui/" .. v )
		end
	end

	MsgC( Color(0, 255, 0), "[MQS] Initialization done\n" )
end

if SERVER then
	MQS.Load()
	hook.Add("PostGamemodeLoaded", "MQS.Load.SV", function() MQS.Load() end)
else
	hook.Add("InitPostEntity", "MQS.Load.CL", function() MQS.Load() end)
end

if GAMEMODE then
	MQS.Load()
end