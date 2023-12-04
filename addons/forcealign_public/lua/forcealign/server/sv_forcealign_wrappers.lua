forceAlign = forceAlign or {}
local ply = FindMetaTable("Player")

function ply:saveForceAlignment()
	if forceAlign.noData or forceAlign.staticJobs[ team.GetName(self:Team()) ] then return end

	if !self.forceAlign then
		self:fetchForceAlignment()
	end

	local sid = self:SteamID64() -- To name the data file
	if !sid then sid = "singleplayer" end

	-- Last minute for modules to save data
	hook.Run("forceAlign_preSave", self)

	local fAlignData = util.TableToJSON(self.forceAlign) -- The data to save

	file.Write("forcealign/points/" .. sid .. ".txt", fAlignData)
--	if forceAlign.debug then print("[forceAlign] Saved data for " .. self:Nick()) end

	-- For character creation systems
	hook.Run("forceAlign_saved", self)
end

function ply:fetchForceAlignment()
	if !forceAlign.noData and !file.Exists("forcealign", "DATA") then file.CreateDir("forcealign") end
	if !forceAlign.noData and !file.Exists("forcealign/points", "DATA") then file.CreateDir("forcealign/points") end
	local sid = self:SteamID64()
	if !sid then sid = "singleplayer" end

	if !forceAlign.noData and file.Exists("forcealign/points/" .. sid .. ".txt", "DATA") then
		local alignment = file.Read("forcealign/points/" .. sid .. ".txt", "DATA")
		if alignment then
			self.forceAlign = util.JSONToTable(alignment)
			forceAlign.sendHUD(self) -- Give HUD the alignment
			if forceAlign.debug then print("[forceAlign] Completed data fetch for " .. self:Nick()) end

		else
			-- Something broke!
			print("[forceAlign] Could not fetch data for " .. self:Nick())
			print("[forceAlign] Please try manually repairing or deleting their data file in data/forcealign/points/" .. sid .. ".txt")
		end

	else
		-- You must be new here! Let's make you a save file...
		self.forceAlign = self.forceAlign or {}
		for k,v in pairs(forceAlign.sides) do
			self.forceAlign[v] = 0
			self:SetNW2Float("ForceAlignment", 0) -- Give HUD the alignment
		end
		forceAlign.sendHUD(self) -- Give HUD the alignment
		if forceAlign.noData then return end

		local fAlignData = util.TableToJSON(self.forceAlign) -- Compile data for save
		file.Write("forcealign/points/" .. sid .. ".txt", fAlignData)
		if forceAlign.debug then print("[forceAlign] New file made for " .. self:Nick()) end
	end
end

function ply:fetchAlignmentSwitch()
	if !forceAlign.switch.saveCD then return end
	if !file.Exists("forcealign/switch", "DATA") then file.CreateDir("forcealign/switch") end

	local sid = self:SteamID64()
	if !sid then sid = "singleplayer" end
	if !file.Exists("forcealign/switch/" .. sid .. ".txt", "DATA") then return end

	local lastSwitch = file.Read("forcealign/switch/" .. sid .. ".txt", "DATA")
	if lastSwitch then
		self.forceAlign_lastSwitch = tonumber(lastSwitch)
		if forceAlign.debug then print("[forceAlign] Completed switch cooldown data fetch for " .. self:Nick()) end

	else
		-- Something broke!
		print("[forceAlign] Could not fetch switch cooldown data for " .. self:Nick())
		print("[forceAlign] Please try manually repairing or deleting their data file in data/forcealign/switch/" .. sid .. ".txt")
	end
end

function forceAlign.autoSave()
	if !forceAlign.noData and forceAlign.saveTime and !timer.Exists("forceAlign_autoSave") then
		-- Trigger the auto save feature on all players!
		timer.Create("forceAlign_autoSave", forceAlign.saveTime, 0, function()
			for _, ply in pairs(player.GetAll()) do
			--	if forceAlign.debug then print("[forceAlign] Autosaving data for " .. ply:Nick()) end
				ply:saveForceAlignment()
			end
		end)
	end
end

hook.Add("PlayerInitialSpawn", "forceAlign_initSpawn", function(ply)
	ply:fetchForceAlignment()

	-- Default the alignment switch
	local side = ply:getForceAlignment()
	if side < 0 then side = 2
	else side = forceAlign.isFsens[ team.GetName(ply:Team()) ] or 1 end

	ply:SetNW2Int("forceAlign_switch", side)
	ply:fetchAlignmentSwitch() -- forceAlign.switch.saveCD

	forceAlign.autoSave()

	if !forceAlign.galCmd or !forceAlign.galCmd.enabled or !forceAlign.galCmd.IsOn or forceAlign.galCmd.activeRound then return end
	if false then forceAlign.startGCRound() end
end)

hook.Add("PlayerSpawn", "forceAlign_spawnCheck", function(ply)
	ply:SetNW2Bool("ForceSensitive", ply:isForceSensitive())
	if !ply:isForceSensitive() then return end
	-- Save their data on spawn IF they're on a Force Sensitive job and usergroup!
	ply:saveForceAlignment()
	forceAlign.checkSithEyes(ply)
end)

-- You're not getting away that easy! Save their data before they escape!
hook.Add("PlayerDisconnected", "forceAlign_disconnect", function(ply) ply:saveForceAlignment() end)