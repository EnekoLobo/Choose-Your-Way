if (SERVER) then
	AddCSLuaFile("autorun/autorun_lounge_tab.lua")
	AddCSLuaFile("scoreboard/cl_scoreboard.lua")
	AddCSLuaFile("tab_config.lua")

	-- Set to false to use the FastDL for the content instead.
	local USE_WORKSHOP = true

	if (USE_WORKSHOP) then
		resource.AddWorkshop("873683460")
	else
		resource.AddFile("matmerials/shenesis/f4menu/earth.png")
		resource.AddFile("matmerials/shenesis/f4menu/list.png")
		resource.AddFile("matmerials/shenesis/f4menu/star.png")
		resource.AddFile("matmerials/shenesis/f4menu/user.png")
		resource.AddFile("matmerials/shenesis/f4menu/notebook.png")
		resource.AddFile("matmerials/shenesis/f4menu/previous.png")
		resource.AddFile("matmerials/shenesis/f4menu/settings.png")
		resource.AddFile("resource/fonts/circular.ttf")
		resource.AddFile("resource/fonts/circular_bold.ttf")
		resource.AddFile("resource/fonts/circular_italic.ttf")
	end

	-- Country flag feature
	util.AddNetworkString("TAB_LOUNGE_CountryFlag")
	local cachedIPs = {}
	
	hook.Add("PlayerInitialSpawn", "TAB_LOUNGE_PlayerInitialSpawn", function(ply)
		local raw = ply:IPAddress()
		local ip = string.Explode(":", raw)[1]
		if (ip and ip ~= "") then
			http.Fetch("http://freegeoip.net/json/" .. ip, function(body)
				if (!body or body == "") then
					return end

				local tbl = util.JSONToTable(body)
				if (!tbl or !tbl.country_code) then
					return end

				local country = tbl.country_code
				cachedIPs[raw] = country:lower()
			end)
		end
	end)

	net.Receive("TAB_LOUNGE_CountryFlag", function(_, ply)
		local target = net.ReadEntity()
		if (IsValid(target) and cachedIPs[target:IPAddress()]) then
			net.Start("TAB_LOUNGE_CountryFlag")
				net.WriteEntity(target)
				net.WriteString(cachedIPs[target:IPAddress()])
			net.Send(ply)
		end
	end)
else
	LOUNGE_TAB = {}

	include("tab_config.lua")
	include("scoreboard/cl_scoreboard.lua")
end