/**
* General configuration
**/

-- Main title of the F4 menu. Can be your server's name or whatever.
LOUNGE_F4.Title = "My Server"

-- Pages to display on the F4 menu.
LOUNGE_F4.Pages = {
	-- {
	-- 	id = "dashboard", -- Used internally
	-- 	bg = Color(52, 73, 94), -- The background of the page. The default is 52, 73, 94
	-- 	text = "dashboard", -- The text to display on the left (links to the language table)
	-- 	icon = Material("shenesis/f4menu/house.png", "noclamp smooth"), -- The icon of the button
	-- 	enable = true, -- Whether this page should be listed or not
	-- },
	{
		id = "jobs",
		bg = Color(52, 73, 94),
		text = "jobs",
		icon = Material("shenesis/f4menu/user.png", "noclamp smooth"),
		enable = true,
	},
	-- {
	-- 	id = "commands",
	-- 	bg = Color(52, 73, 94),
	-- 	text = "commands",
	-- 	icon = Material("shenesis/f4menu/document.png", "noclamp smooth"),
	-- 	enable = true,
	-- },
	--  {
	-- 	id = "purchase",
	-- 	bg = Color(52, 73, 94),
	-- 	text = "purchase",
	-- 	icon = Material("shenesis/f4menu/basket.png", "noclamp smooth"),
	-- 	enable = true,
	-- },

	-- // Bottom buttons
	-- {id = "website", text = "website", icon = Material("shenesis/f4menu/earth.png", "noclamp smooth"),
	-- 	callback = function()
	-- 		gui.OpenURL(LOUNGE_F4.Website)
	-- 		return false
	-- 	end,
	-- 	display = function()
	-- 		return LOUNGE_F4.Website and LOUNGE_F4.Website ~= ""
	-- 	end,
	-- 	enable = true,
	-- 	bottom = true,
	-- },
	-- {id = "donate", text = "donate", icon = Material("shenesis/f4menu/star.png", "noclamp smooth"),
	-- 	callback = function()
	-- 		gui.OpenURL(LOUNGE_F4.Donate)
	-- 		return false
	-- 	end,
	-- 	display = function()
	-- 		return LOUNGE_F4.Donate and LOUNGE_F4.Donate ~= ""
	-- 	end,
	-- 	enable = true,
	-- 	bottom = true,
	-- },
	-- {id = "steamgroup", text = "steamgroup", icon = Material("shenesis/f4menu/steam.png", "noclamp smooth"),
	-- 	callback = function()
	-- 		gui.OpenURL(LOUNGE_F4.SteamGroup)
	-- 		return false
	-- 	end,
	-- 	display = function()
	-- 		return LOUNGE_F4.SteamGroup and LOUNGE_F4.SteamGroup ~= ""
	-- 	end,
	-- 	enable = true,
	-- 	bottom = true,
	-- },
}

-- (Advanced) Icon to display for custom pages added via the F4MenuTabs hook.
LOUNGE_F4.CustomTabNameIcon = {
	// Any custom tab called "Gangs" will have the user icon.
	["Gangs"] = Material("shenesis/f4menu/user.png", "noclamp smooth"),
}

-- Website to open when clicking on the "Website" button
-- Leave empty to hide the website button.
LOUNGE_F4.Website = "http://google.com/"

-- Website to open when clicking on the "Donate" button
-- Leave empty to hide the donate button.
LOUNGE_F4.Donate = "http://google.com/"

-- Website to open when clicking on the "Steam Group" button
-- Leave empty to hide the steam group button.
LOUNGE_F4.SteamGroup = "http://steamcommunity.com/"

-- Usergroups which are part of your server's staff.
-- Used to count the number of online staff members in the Dashboard.
LOUNGE_F4.StaffUsergroups = {
	["admin"] = true,
	["superadmin"] = true,
}

-- Display the "Food" tab (if possible) in the Purchase page.
LOUNGE_F4.EnableFoodTab = true

-- What method to use to retrieve the user group.
-- Leave to 0 if you use ULX or no special admin mode listed below
-- Set to 1 if you use ServerGuard
LOUNGE_F4.UsergroupMode = 0

-- If for some reason you don't use money on your server, set this to true to hide money displays in tabs
LOUNGE_F4.NoMoneyLabels = false

-- Set this to true to not hide JOBS with failed customChecks.
LOUNGE_F4.KeepFailedCustomCheckJobs = false

-- Set this to true to not hide ENTITIES with failed customChecks.
LOUNGE_F4.KeepFailedCustomCheckEnts = false

-- Order to use when sorting jobs.
-- 0: Do not sort jobs; display them in the order they're created.
-- 1: Sort them by NAME from A to Z.
-- 2: Sort them by NAME from Z to A.
-- 3: Sort them by SALARY from the highest to lowest.
-- 4: Sort them by SALARY from the lowest to highest.
LOUNGE_F4.JobsSortingOrder = 0

-- Order to use when sorting purchase items.
-- 0: Do not sort items; display them in the order they're created.
-- 1: Sort them by NAME from A to Z.
-- 2: Sort them by NAME from Z to A.
-- 3: Sort them by PRICE from the highest to lowest.
-- 4: Sort them by PRICE from the lowest to highest.
LOUNGE_F4.ItemsSortingOrder = 0

-- Job graph in Dashboard: Display the jobs by category rather than by each job
-- This will not work on older versions of DarkRP that do not support categories!
-- Note: You will also not be able to click on the bars to quickly switch jobs.
LOUNGE_F4.JobGraphCategories = false

-- Purchase tab: display entities by their category. Only available on recent DarkRP versions.
LOUNGE_F4.PurchaseByCategories = true

-- Jobs tab: always ask for model, even if there's only one in the job?
LOUNGE_F4.AlwaysModelPrompt = false

-- vrondakis Leveling-System: Hide JOBS with a level too high for the player.
LOUNGE_F4.HideHighLevelJobs = true

-- vrondakis Leveling-System: Hide ENTITIES with a level too high for the player.
LOUNGE_F4.HideHighLevelEnts = true

/**
* Style configuration
**/

-- Font to use for normal text throughout the F4 menu.
LOUNGE_F4.Font = "Circular Std Medium"

-- Font to use for bold text throughout the F4 menu.
LOUNGE_F4.FontBold = "Circular Std Bold"

-- Color sheet. Only modify if you know what you're doing
LOUNGE_F4.Style = {
	header = Color(25, 25, 25),
	bg = Color(52, 73, 94), -- Remember to change the color of the page backgrounds too!
	inbg = Color(44, 62, 80),

	close_hover = Color(231, 76, 60),
	hover = Color(255, 255, 255, 10),
	hover2 = Color(255, 255, 255, 5),

	text = Color(255, 255, 255),
	text_down = Color(0, 0, 0),
	textentry = Color(236, 240, 241),

	menu = Color(127, 140, 141),
}

-- Set this to true to alter the looks of jobs with failed customChecks.
-- Setting it to true will disable the normal looks of the job button.
LOUNGE_F4.DoPaintJobFailedCheck = false

-- Advanced: custom paint function for jobs with failed customChecks.
-- Only modify if you know what you're doing.
LOUNGE_F4.PaintJobFailedCheck = function(me, w, h)
	local b = LOUNGE_F4.DoPaintJobFailedCheck
	if (b) then
		draw.RoundedBox(4, 0, 0, w, h, LOUNGE_F4.Style.close_hover) -- Sets the background of the job to red if the customCheck is failed.
	end

	return b
end

/**
* Language configuration
**/

-- "Clean" Usergroup names to display on the dashboard.
-- Usergroups not in this table will be displayed directly, which may not look good.
LOUNGE_F4.CleanUsergroups = {
	["user"] = "User",
	["respected"] = "Respected",
	["donator"] = "Donator",
	["vip"] = "VIP",
	["admin"] = "Administrator",
	["superadmin"] = "Super Administrator",
}

-- Various strings used throughout the F4 Menu. Change them to your language here.
-- %s and %d are special strings replaced with relevant info, keep them in the string!

// FRENCH Translation: https://pastebin.com/6jYRtxYW

LOUNGE_F4.Language = {
	dashboard = "Dashboard",
	jobs = "Jobs",
	commands = "Commands",
	purchase = "Purchase",
	website = "Website",
	donate = "Donate",
	steamgroup = "Steam Group",
	players = "Players",
	staff_online = "Staff online",
	job_graph = "Job Graph",
	server_economy = "Server Economy",
	money_in_circulation = "Money in Circulation",
	richest_player_online = "Richest Player Online",
	model_selection = "Model Selection",
	entities = "Entities",
	shipments = "Bazar",
	vehicles = "Vehicles",
	ammo = "Ammo",
	food = "Food",
	level_x = "Level %d",

	toggle = "Toggle",
	click_to_become_x = "Click to become %s",
	salary = "Salary",
	weapons = "Weapons",
	vote_to_become_x = "Vote to become %s",
	become_x = "Become %s",
	free = "Free",
	search = "Search",
}