/**
* General configuration
**/

-- Title to display on the scoreboard.
-- Leave empty to show the server name.
LOUNGE_TAB.Title = ""

-- Display style of the list.
-- 0: All players in the same list
-- 1: Separate players by team
-- 2: Separate players by user group
-- 3: Separate players by alive/dead status
-- 4: Separate players by free/in jail status
-- 5: Separate players by TTT categories (terrorists, spectators, MIA and confirmed)
--	  Don't use in any gamemode other than TTT!
LOUNGE_TAB.DisplayStyle = 1

-- Display the player count on the top of the menu?
LOUNGE_TAB.DisplayPlayerCount = true

-- Display the player's country flag.
LOUNGE_TAB.DisplayFlag = true

-- Only admins (or above) should see other players' flag.
-- (Players can still see their own flag)
LOUNGE_TAB.OnlyAdminsSeeFlags = false

-- Custom flag icon for specific players.
-- Supports SteamID and SteamID64 and usergroup
-- Use the first column in this list: https://en.wikipedia.org/wiki/ISO_3166-2#Current_codes to find the country code
-- Some flags will not display!
LOUNGE_TAB.PlayerFlags = {
	-- ["STEAM_0:0:0"] = "gb",
	-- ["STEAM_0:1:8039869"] = "jp",
}

-- Columns to display in a player's row.
-- To enable a column, remove the -- before the lines corresponding to it.
-- To disable it, either erase the column from the table or add the -- to all lines corresponding to it
LOUNGE_TAB.PlayerColumns = {
	/*
	* TTT columns
	*/

	// COLUMN: Role
	-- {text = "", ttt = true,
		-- func = function(ply)
			-- local rol, col = "", nil
			-- if (ply:IsTraitor()) then
				-- rol, col = LOUNGE_TAB.Language.traitor or "", Color(231, 76, 60)
			-- elseif (ply:IsDetective()) then
				-- rol, col = LOUNGE_TAB.Language.detective or "", Color(52, 152, 219)
			-- end

			-- return rol, col
		-- end
	-- },

	// COLUMN: Karma
	-- {text = "karma", ttt = true,
		-- func = function(ply)
			-- return math.Round(ply:GetBaseKarma())
		-- end,
		-- candisplay = function()
			-- return KARMA and KARMA.IsEnabled()
		-- end
	-- },

	/*
	* DarkRP columns
	*/
	
	// COLUMN: Cash
	-- {text = "cash", darkrp = true,
		-- func = function(ply)
			-- if (!DarkRP) then
				-- return end

			-- return DarkRP.formatMoney(ply:getDarkRPVar("money"))
		-- end
	-- },

	// COLUMN: Job
	-- {text = "job", wi = 150, darkrp = true,
	-- 	func = function(ply)
	-- 		// Set this to true to show the custom job
	-- 		local custom_job = true
		
	-- 		// Set this to true to show the team color
	-- 		local team_color = false

	-- 		local n = team.GetName(ply:Team())
	-- 		if (custom_job and ply.getDarkRPVar) then
	-- 			n = ply:getDarkRPVar("job") or n
	-- 		end
			
	-- 		if (team_color) then
	-- 			return n, team.GetColor(ply:Team())
	-- 		else
	-- 			return n
	-- 		end
	-- 	end
	-- },

	// UTeam column
	-- {text = "team", wi = 150, func = function(ply)
		-- return team.GetName(ply:Team()), team.GetColor(ply:Team())
	-- end},

	// UTime columns
	-- {text = "playtime", wi = 120, func = function(ply)
		-- return LT_FormatTime(ply:GetUTime() + CurTime() - ply:GetUTimeStart())
	-- end},
	-- {text = "session", wi = 120, func = function(ply)
		-- return LT_FormatTime(CurTime() - ply:GetUTimeStart())
	-- end},

	// aTags column
	-- {text = "", wi = 120, func = function(ply)
		-- local tx, col = hook.Call("aTag_GetScoreboardTag", nil, ply)
		-- return tx or "", col or color_white
	-- end},

	{text = "kills", func = function(ply)
		return ply:Frags()
	end},
	{text = "deaths", func = function(ply)
		return ply:Deaths()
	end},
	{text = "ping", func = function(ply)
		return ply:IsBot() and "BOT" or ply:Ping()
	end},
}

-- Column ID to sort players by.
-- For example, if it's 1, it will sort by the first column, which is the kills (normally)
LOUNGE_TAB.PlayerSortBy = 1

-- Set to true to sort from lowest to highest instead of highest to lowest.
LOUNGE_TAB.SortAsc = false

-- Display the "user" user group text for default users.
LOUNGE_TAB.DisplayUserLabel = false

-- Display the F4 button on the left
LOUNGE_TAB.ShowF4Button = true

-- When left-clicking a player row, should a specific admin menu appear?
-- 0: None
-- 1: FAdmin
-- 2: ULX
LOUNGE_TAB.UsePlayerAdminMenu = 0

-- Website to open when clicking on the "Website" button
-- Leave empty to hide the website button.
LOUNGE_TAB.Website = "http://google.com/"

-- Website to open when clicking on the "Donate" button
-- Leave empty to hide the donate button.
LOUNGE_TAB.Donate = "http://google.com/"

-- Buttons to show on the left of the menu.
LOUNGE_TAB.Buttons = {
	{id = "f4", text = "F4", icon = Material("shenesis/f4menu/notebook.png", "noclamp smooth"),
		callback = function()
			if (LOUNGE_F4) then
				LOUNGE_F4:Show()
			else
				RunConsoleCommand("gm_showspare2")
			end
		end,
		display = function()
			return LOUNGE_TAB.ShowF4Button
		end,
	},
	{id = "website", text = "website", icon = Material("shenesis/f4menu/earth.png", "noclamp smooth"),
		callback = function()
			gui.OpenURL(LOUNGE_TAB.Website)
		end,
		display = function()
			return LOUNGE_TAB.Website and LOUNGE_TAB.Website ~= ""
		end,
	},
	{id = "donate", text = "donate", icon = Material("shenesis/f4menu/star.png", "noclamp smooth"),
		callback = function()
			gui.OpenURL(LOUNGE_TAB.Donate)
		end,
		display = function()
			return LOUNGE_TAB.Donate and LOUNGE_TAB.Donate ~= ""
		end,
	},
	{id = "fadminsettings", text = "server_settings", icon = Material("shenesis/f4menu/settings.png", "noclamp smooth"),
		callback = function()
			if (!FAdmin or !FAdmin.ScoreBoard) then
				return end

			FAdmin.ScoreBoard.ShowScoreBoard()
			FAdmin.ScoreBoard.ChangeView("Server")

			LOUNGE_TAB.ScoreboardCursor = false
			gui.EnableScreenClicker(true)

			if (IsValid(FAdmin.ScoreBoard.Controls.BackButton)) then
				FAdmin.ScoreBoard.Controls.BackButton.DoClick = function()
					FAdmin.ScoreBoard.HideScoreBoard()
				end
			end
		end,
		display = function()
			return FAdmin and FAdmin.ScoreBoard and LOUNGE_TAB.ShowFAdminSettings and LocalPlayer():IsAdmin()
		end,
	},
}

-- What method to use to retrieve the user group.
-- Leave to 0 if you use ULX or no special admin mode listed below
-- Set to 1 if you use ServerGuard
LOUNGE_TAB.UsergroupMode = 0

-- Always bring up the cursor when opening the scoreboard.
-- if false, players have to right-click to bring up the cursor.
LOUNGE_TAB.CursorOnOpen = false

-- Show the Server settings (FAdmin only!) button on the left.
LOUNGE_TAB.ShowFAdminSettings = true

-- Show the icons for FAdmin player commands.
LOUNGE_TAB.ShowFAdminIcons = true

/**
* Style configuration
**/

-- Scoreboard width multiplier
LOUNGE_TAB.WidthScale = 1

-- Scoreboard height multiplier
LOUNGE_TAB.HeightScale = 1

-- Blur the blackground in black when the scoreboard is open
LOUNGE_TAB.DrawBackgroundBlur = false

-- Font to use for normal text throughout the Tab menu.
LOUNGE_TAB.Font = "Circular Std Medium"

-- Font to use for bold text throughout the Tab menu.
LOUNGE_TAB.FontBold = "Circular Std Bold"

-- Font to use for italic text throughout the Tab menu.
LOUNGE_TAB.FontItalic = "Circular Std Medium Italic"

-- Color sheet. Only modify if you know what you're doing
LOUNGE_TAB.Style = {
	header = Color(25, 25, 25),
	bg = Color(52, 73, 94),
	inbg = Color(44, 62, 80),

	full = Color(231, 76, 60),
	close_hover = Color(231, 76, 60),
	hover = Color(255, 255, 255, 10),
	hover2 = Color(255, 255, 255, 5),

	text = Color(255, 255, 255),
	subtext = Color(149, 165, 166),
	text_down = Color(0, 0, 0),
	textentry = Color(236, 240, 241),

	menu = Color(127, 140, 141),
}

-- Display the Usergroup text in italic?
LOUNGE_TAB.ItalicUsergroup = true

-- Usergroup colors to use on the player rows.
-- Set to "rainbow" instead of a Color for, well, a rainbow animated text.
-- Usergroups not in this table will be displayed in white, which may clash with the player name!
LOUNGE_TAB.UsergroupColors = {
	["respected"] = Color(26, 188, 156),
	["donator"] = Color(241, 196, 15),
	["mod"] = Color(241, 196, 15),
	["admin"] = Color(52, 152, 219),
	["superadmin"] = Color(231, 76, 60),
	["owner"] = "rainbow",
}

-- Set players with a custom colored name here.
-- Supports SteamID and SteamID64 and usergroup
-- Set to "rainbow" for, well, a rainbow animated text.
LOUNGE_TAB.PlayerColors = {
	-- ["STEAM_0:0:0"] = Color(255, 0, 0),
	-- ["STEAM_0:1:8039869"] = "rainbow",
}

/**
* Language configuration
**/

-- "Clean" Usergroup names to display on the player rows.
-- Usergroups not in this table will be displayed directly, which may not look good.
LOUNGE_TAB.CleanUsergroups = {
	["user"] = "User",
	["respected"] = "Respected",
	["donator"] = "Donator",
	["mod"] = "Mod",
	["admin"] = "Admin",
	["superadmin"] = "Super Admin",
}

-- Various strings used throughout the Tab menu. Change them to your language here.
-- %s and %d are special strings replaced with relevant info, keep them in the string!

// FRENCH Translation: http://pastebin.com/raw/6JmrebWP
// JAPANESE Translation: http://pastebin.com/raw/VypMFbcm

LOUNGE_TAB.Language = {
	toggle = "Toggle",
	website = "Website",
	donate = "Donate",
	server_settings = "Server settings",

	cash = "Cash",
	job = "Job",
	team = "Team",
	playtime = "Total Time",
	session = "Session",
	kills = "Kills",
	deaths = "Deaths",
	ping = "Ping",

	alive = "Alive",
	dead = "Dead",
	free = "Free",
	arrested = "In Jail",

	view_steam_profile = "View Steam profile",
	copy_steamid = "Copy SteamID",
	mute = "Mute",
	unmute = "Unmute",

	-- TTT
	karma = "Karma",
	terrorists = "Terrorists",
	spectators = "Spectators",
	mia = "Missing in Action",
	confirmed = "Confirmed Dead",
	traitor = "Traitor",
	detective = "Detective",
}