forceAlign = forceAlign or {} --[[
 _______   ______   .______        ______  _______     ___       __       __    _______ .__   __. 
|   ____| /  __  \  |   _  \      /      ||   ____|   /   \     |  |     |  |  /  _____||  \ |  | 
|  |__   |  |  |  | |  |_)  |    |  ,----'|  |__     /  ^  \    |  |     |  | |  |  __  |   \|  | 
|   __|  |  |  |  | |      /     |  |     |   __|   /  /_\  \   |  |     |  | |  | |_ | |  . `  | 
|  |     |  `--'  | |  |\  \----.|  `----.|  |____ /  _____  \  |  `----.|  | |  |__| | |  |\   | 
|__|      \______/  | _| `._____| \______||_______/__/     \__\ |_______||__|  \______| |__| \__| 
                                                                                                  
-- 			Brought to you by Dank
--			Need help? https://discord.gg/svY4AdSEtm
-----------------------------------------------------------------------------------------------]]


-- First, here is a list of helpful functions that can help you customize your experience!

--[[ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ]]
--[[ - - - - - - - - - Giving alignment points - - - - - - - - - ]]
--[[ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ]]

-- To give a player points within specific forceAlign.sides
//		ply:giveFAlignPoints(amount, side, notify)
-- This internally takes the current amount of points from the side and adds to it

-- amount = number; Points to give the player
-- notify = true/false; Toggles notifying the player

-- side = string/number/true; The team from forceAlign.sides to give points towards
-- It can be the string name from forceAlign.sides
//		ply:giveFAlignPoints(69, "Lado Luminoso", false)
-- or the corresponding number from forceAlign.sides
//		ply:giveFAlignPoints(69, 1, false)
-- or replace side with true to default to the player's alignment toggle switch
//		ply:giveFAlignPoints(69, true, false)

--[[ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  ]]
--[[ - - - - - - - - - Getting player alignment - - - - - - - - - ]]
--[[ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  ]]

-- To get a specific alignment of a player from forceAlign.sides
--	ply:getForceAlignment(side)
-- side = string/number; Use the string name from forceAlign.sides or it's corresponding number
--	ply:getForceAlignment("Lado Luminoso")
	--	ply:getForceAlignment(1)

-- To get the overall alignment of a player based on the first two forceAlign.sides
--	ply:getForceAlignment()

-- By default, a player's alignment is calculated simply as
--		forceAlign.sides[1] - forceAlign.sides[2]

-- To get a player's alignment toggle switch setting
--	ply:GetNW2Int("forceAlign_switch")
-- Returns a number based on forceAlign.sides

--[[ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  ]]
--[[ - - - - - - - - - Setting player alignment - - - - - - - - - ]]
--[[ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  ]]

-- To set the alignment of a player
--ply:setForceAlignment(amount, side, notify)

-- amount = number; Points to give the player
-- notify = true/false; Toggles notifying the player

-- side = string/number/true; The team from forceAlign.sides to give points towards
-- It can be the string name from forceAlign.sides
//		ply:setForceAlignment(42, "Lado Oscuro", false)
-- or the corresponding number from forceAlign.sides
//		ply:setForceAlignment(42, 2, false)
-- or replace side with true to default to the player's alignment toggle switch
//		ply:setForceAlignment(42, true, false)

--[[ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ]]

-- Get the alignment tier of a player, returns a negative int for forceAlign.sides[2]
//		ply:GetNW2Int("forceAlign_tier")

-- Get the average alignment of all players on the server
//		forceAlign.galAlignment()

--[[-------------------------------------------------------------------------------------------]]

forceAlign.language = "en"		-- "en" = English; More translations coming soon!
forceAlign.debug = false			-- A metric fuck ton of dev prints
forceAlign.fastDL = false		-- Make players download materials when they join
forceAlign.noData = false		-- Prevent data saving and reset alignments on rejoin or restart
forceAlign.saveTime = 300		-- Autosave time, set to nil to disable
forceAlign.strictSave = false	-- Save data as soon as it's set
forceAlign.limit = 10000		-- The max points for alignments (top and bottom of the hud)
forceAlign.restricted = true	-- Restrict the system to the isForceSensitive check

forceAlign.halos = true			-- Give players a colored aura based on their alignment
forceAlign.haloClrs = {
	[1] = Color(50, 130, 255),
	[2] = Color(200, 0, 0, 255),
}

-- The current player HUD only checks the first two entries
forceAlign.sides = {
	[1] = "Lado Luminoso",
	[2] = "Lado Oscuro",

	-- You can create and track whatever you want after this point
}

-- Create NWFloats to be referenced clientside; forceAlign.sides[key] = "floatName"
-- Call these as ply:GetNW2Float("forceAlign_floatName"), replacing 'floatName' with each value
forceAlign.nwSides = {
	[1] = "lightPoints",
	[2] = "darkPoints",
}

-- The amount of points between alignment tiers, there can only be 5
forceAlign.tiers = {
	[1] = 1000,
	[2] = 2000,
	[3] = 4000,
	[4] = 6750,
	[5] = forceAlign.limit,	-- 10000, same thing
}

--[[-------------------------------------------------------------------------------------------]]

-- Auxilary controls for balancing how players earn alignment points
forceAlign.balCtrls = {
	resetOppOnV = false,		-- Reset points for opposite side when alignment meter hits max
	resetOppOnMax = false,	-- Reset points for opposite side when forceAlign.limit is reached
	rebalOnMax = false,		-- Reset points for both sides when forceAlign.limit is reached

	fallFast = true,		-- Reverse points from dominant side when approaching center alignment
	fFMulti = 0.5,			-- Multiplier for reversing points with fallFast

	karmaKills = false,		-- Give forceAlign.sides[2] for killing other players
	PvP = 10,				-- Give points for killing players with the opposite alignment
	NPCs = 5,				-- Give points for killing NPCs based on alignment switch
}

--[[-------------------------------------------------------------------------------------------]]

forceAlign.sithEyes = {		-- Set eye materials on players when using the dark side of the switch
	enabled = false,

	-- reqType = 1, Set mats when under the req threshold based on total dark side points
	-- reqType = 2, Set mats when under the req threshold based on alignment
	reqType = 2,
	req = 100,		-- The requirement for the reqType of choice, set false to disable

	mats = {		-- Eye materials
		["Default"] = "models/vortigaunt/vort_eye",
--		["STEAM_0:1:00000000"] = "models/player/starwars/maulkiller/playermaulkillereyeball_c",
--		["STEAM_0:1:00000001"] = "models/grealms/characters/malgus/eye_malgus_non_a01_c01_d",
	}
}

--[[-------------------------------------------------------------------------------------------]]

forceAlign.hudEnabled = true	-- Toggle the Player HUD
forceAlign.hudPos = {			-- Player HUD Position
	x = 1.032,		-- Horizontal
	y = 2.8,		-- Vertical
}

--[[-------------------------------------------------------------------------------------------]]

forceAlign.switch = {		-- The alignment switcher HUD at the bottom
	enabled = false, 		-- Enable players switching sides
	cmd = "!alignswitch",	-- Command to toggle the switch (can also be clicked in context menu)
	cd = 5, -- 3600 * 24,			-- Cooldown for switching sides to prevent flip-flopping
	saveCD = false,			-- Save cooldowns to a data file for longer periods of time
	hudPos = {				-- HUD Position
		x = 1.2,	-- Horizontal
		y = 1.07,	-- Vertical
	}
}

--[[-------------------------------------------------------------------------------------------]]

forceAlign.notifyHUD = {	-- The notifications when receiving points
	enabled = true,			-- Enable notifications when receiving points calls for it
	dieTime = 5,
	fadeTime = 1.5,
	hudPos = {				-- Faction logo position
		x = 2,		-- Horizontal
		y = 1.5,	-- Vertical
	}
}

forceAlign.pointsHUD = {	-- The display for total point values
	cmd = "!fuerza",	-- The command to show both total point values
	x = 1.036,		-- Horizontal Position
	y = 4.8,		-- Vertical Position
}

--[[-------------------------------------------------------------------------------------------]]

forceAlign.usergroups = {	-- Force Sensitive usergroups if forceAlign.restricted == true
	["user"] = true,
	["VIP"] = true,
	["Event Master"] = true,
	["admin"] = true,
	["superadmin"] = true,
}
forceAlign.jobRestrict = {	-- Jobs that require a minimum point threshold
	-- Requires 9k points on both sides to get access to this job
	--["Anakin Skywalker"] = {[1] = 9000, [2] = 9000},
	-- Requires max dark side points to get access to this job. No light side threshold
	--["Darth Sidious"] = {[1] = 0, [2] = 10000},
}

forceAlign.staticJobs = {	-- Force Sensitive jobs with fixed scores that can't be changed
	--["Maestro Jedi"] = {[1] = 10000, [2] = 0},
	--["Maestro Neverlander"] = {[1] = 10000, [2] = 0},

}

-- Force Sensitive jobs if forceAlign.restricted == true
forceAlign.isFsens = {	-- Job Name = Switch Default

	["Iniciado Jedi"] = 1,
	["Padawan Jedi"] = 1,
	["Caballero Jedi"] = 1,
	["Guardián Jedi"] = 1,
	["Cónsul Jedi"] = 1,
	["Centinela Jedi"] = 1,
	["Sombra Jedi"] = 1,
	["Maestro Jedi"] = 1,
	["Gran Maestro Neverlander"] = 1,
	["Maestro Cónsul Xiv Si'xer"] = 1,
	["Allen Valentine"] = 1,

}