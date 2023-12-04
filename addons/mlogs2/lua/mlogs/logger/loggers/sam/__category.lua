--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2023 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

mLogs.addCategory(
	"SAM", -- Name
	"sam", 
	Color(255, 90, 0), -- Color
	function() -- Check
		return sam != nil
	end,
	true -- delayed
)

mLogs.addCategoryDefinitions("sam", {
	samcommand = function(data) return mLogs.doLogReplace({"^player1","ran the command:","^command","^args"},data) end,
})