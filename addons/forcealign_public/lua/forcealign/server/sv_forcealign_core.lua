forceAlign = forceAlign or {}
local ply = FindMetaTable("Player")

forceAlign.dbLang = {	-- Language for debug prints
	set = "Set",
	swtch = "alignment switch",
	noSet = "Could not set",
	giv = "Could not give",
	dec = "side not declared",
}

function ply:isForceSensitive()
	if !forceAlign.restricted then return true end
	if !forceAlign.usergroups[self:GetUserGroup()] then return false end

	if forceAlign.isFsens[ team.GetName(self:Team()) ] then return true
	elseif forceAlign.staticJobs[ team.GetName(self:Team()) ] then return true

	else return false end
end


function forceAlign.sendHUD(ply) -- Transmit data to the player HUDs
	if !IsValid(ply) or !ply.forceAlign then return end

	-- Get the data to send
	local hudAlign = ply.forceAlign[ forceAlign.sides[1] ] - ply.forceAlign[ forceAlign.sides[2] ]

	-- Update player data for the HUD
	ply:SetNW2Float("ForceAlignment", hudAlign)
	ply:SetNW2Int("forceAlign_tier", ply:getForceAlignTier())

--	ply:SetNW2Float("forceAlign_lightPoints", ply.forceAlign[ forceAlign.sides[1] ])
--	ply:SetNW2Float("forceAlign_darkPoints", ply.forceAlign[ forceAlign.sides[2] ])
	for k,v in pairs(forceAlign.nwSides) do
		if !forceAlign.sides[k] then continue end
		ply:SetNW2Float("forceAlign_" .. v, ply.forceAlign[ forceAlign.sides[k] ])
	end
end

-- After we're done messing with point values we update visual information for the player
local function forceAlign_postPointChange(ply, side, amount, notify, gave)
	-- Done messing with points, send it to the client!
	forceAlign.sendHUD(ply)

	if notify then
		if gave then
			if side == forceAlign.sides[1] or side == forceAlign.sides[2] then
				-- Send SWTOR Notifications across their screen
				net.Start("forceAlign_Notify")
					net.WriteString(side)
					net.WriteFloat(amount)
				net.Send(ply)
			else
				ply:PrintMessage(HUD_PRINTTALK, forceAlign.lang["have"] .. " " .. ply.forceAlign[side] .. " " .. side .. " " .. forceAlign.lang["pnts"] .. "!")
			end
		end
	end

	if forceAlign.debug then
		print("[forceAlign] " .. side .. " " .. forceAlign.lang["pnts"] .. ": " .. ply.forceAlign[side] .. " - " .. ply:Nick())
	end

	hook.Run("forceAlign_postPointChange", ply, side, amount, notify, gave)
end

-- Auxilary controls for balancing how players earn alignment points
local function forceAlign_balCtrls(ply, side, amount, notify, oldAlign, gave)

	if gave and forceAlign.balCtrls.fallFast then
		-- Reverse points from dominant side when approaching center alignment
		local almt = ply:getForceAlignment()
		local diff = oldAlign - almt

		local subAmt = diff * forceAlign.balCtrls.fFMulti

		if oldAlign > almt and oldAlign > 0 then
			-- A jedi is falling
			local baseAmt = ply.forceAlign[ forceAlign.sides[1] ]
			ply.forceAlign[ forceAlign.sides[1] ] = math.Clamp(baseAmt - subAmt, 0, forceAlign.limit)
		elseif oldAlign < almt and oldAlign < 0 then
			-- A sith is rising
			local baseAmt = ply.forceAlign[ forceAlign.sides[2] ]
			subAmt = subAmt * -1
			ply.forceAlign[ forceAlign.sides[2] ] = math.Clamp(baseAmt - subAmt, 0, forceAlign.limit)
		end
	end

	if forceAlign.balCtrls.resetOppOnV then
		-- Reset points for opposite side when their balance reaches meter max
		if ply:getForceAlignment()  == forceAlign.limit then
			ply.forceAlign[ forceAlign.sides[2] ] = 0
		elseif ply:getForceAlignment()  == forceAlign.limit * -1 then
			ply.forceAlign[ forceAlign.sides[1] ] = 0
		end
	end

	if forceAlign.balCtrls.resetOppOnMax then
		-- Reset points for opposite side when a side reaches forceAlign.limit
		if ply.forceAlign[ forceAlign.sides[1] ] == forceAlign.limit then
			ply.forceAlign[ forceAlign.sides[2] ] = 0
		end
		if ply.forceAlign[ forceAlign.sides[2] ] == forceAlign.limit then
			ply.forceAlign[ forceAlign.sides[1] ] = 0
		end
	end

	if forceAlign.balCtrls.rebalOnMax then
		-- Reset points for both sides when players reach forceAlign.limit
		if ply.forceAlign[ forceAlign.sides[1] ] == forceAlign.limit or ply.forceAlign[ forceAlign.sides[2] ] == forceAlign.limit then
			ply.forceAlign[ forceAlign.sides[1] ] = 0
			ply.forceAlign[ forceAlign.sides[2] ] = 0
		end
	end
end

-- Set a player's points
function ply:setForceAlignment(amount, side, notify)
	if !side or !amount then print("[forceAlign] " .. forceAlign.dbLang.noSet .. " " .. forceAlign.lang["pnts"] .. ": " .. self:Nick()) return end
--	if !self:isForceSensitive() then return end
	if !self.forceAlign then self.forceAlign = {} end

	-- Get the side from their alignment toggle switch
	if type(side) == "boolean" and side == true then
		if !forceAlign.switch.enabled then print("[forceAlign] " .. forceAlign.dbLang.noSet .. " " .. forceAlign.lang["pnts"] .. ": " .. self:Nick() .. " - " .. forceAlign.dbLang.dec) return end
		side = forceAlign.sides[self:GetNW2Int("forceAlign_switch")]

	elseif type(side) == "number" then side = forceAlign.sides[side] end

	-- Make sure the side is valid
	if type(side) != "string" or !table.HasValue(forceAlign.sides, side) then print("[forceAlign] " .. forceAlign.dbLang.noSet .. " " .. forceAlign.lang["pnts"] .. ": " .. self:Nick() .. " - " .. forceAlign.dbLang.dec) return end

	if !self:isForceSensitive() or forceAlign.staticJobs[ team.GetName(self:Team()) ] then
		if forceAlign.sides[1] == side or forceAlign.sides[2] == side then return end
	end

	-- Gather some data before changing values
	local oldAlign = self:getForceAlignment()
	hook.Run("forceAlign_prePointChange", ply, side, amount, notify)

	-- Change values
	self.forceAlign[side] = math.Clamp(amount, 0, forceAlign.limit)

	-- Run some forceAlign.balCtrls stuff
	forceAlign_balCtrls(self, side, amount, notify, oldAlign)

	-- Run notifications and HUD changes
	forceAlign_postPointChange(self, side, amount, notify)
end

-- Get a player's alignment ( forceAlign.sides[1] - forceAlign.sides[2] )
function ply:getForceAlignment(side)
	if !self.forceAlign then return 0 end
--	if !self:isForceSensitive() then return 0 end

	if !side then
		if !self:isForceSensitive() then return 0 end

		if forceAlign.staticJobs[ team.GetName(self:Team()) ] then
			local tbl = forceAlign.staticJobs[ team.GetName(self:Team()) ]
			local statAlign = tbl[1] - tbl[2]
			return statAlign
		end

		local fAlign = self.forceAlign[forceAlign.sides[1]] - self.forceAlign[forceAlign.sides[2]]

		return fAlign

	elseif type(side) == "number" then 
		if forceAlign.staticJobs[ team.GetName(self:Team()) ] then
			local tbl = forceAlign.staticJobs[ team.GetName(self:Team()) ]
			return tbl[side]
		end

		side = forceAlign.sides[side]

	elseif type(side) == "string" and forceAlign.staticJobs[ team.GetName(self:Team()) ] then
		local sideInt = table.KeyFromValue(forceAlign.tiers, side)
		local tbl = forceAlign.staticJobs[ team.GetName(self:Team()) ]
		return tbl[sideInt]
	end

	return self.forceAlign[side]
end

-- Get the alignment tier of a player
function ply:getForceAlignTier()
	if !self.forceAlign then return 0 end
	if !self:isForceSensitive() then return 0 end

	local almt = self:getForceAlignment()

	local tier = 0
	for k,v in pairs(forceAlign.tiers) do
		if almt > 0 then
			if v > almt then continue end
			tier = k
		else
			if v * -1 < almt then continue end
			tier = k * -1
		end
	end

	return tier
end

-- Modify existing point values on a player
function ply:giveFAlignPoints(amount, side, notify)
	if !side or !amount then print("[forceAlign] " .. forceAlign.dbLang.giv .. " " .. forceAlign.lang["pnts"] .. ": " .. self:Nick()) return end
--	if !self:isForceSensitive() then return end
	if !self.forceAlign then self.forceAlign = {} end

	-- Get the side from their alignment toggle switch
	if type(side) == "boolean" and side == true then
		if !self:isForceSensitive() then return end
		if !forceAlign.switch.enabled then print("[forceAlign] " .. forceAlign.dbLang.noSet .. " " .. forceAlign.lang["pnts"] .. ": " .. self:Nick() .. " - " .. forceAlign.dbLang.dec) return end
		side = forceAlign.sides[self:GetNW2Int("forceAlign_switch")]

	elseif type(side) == "number" then side = forceAlign.sides[side] end

	-- Make sure the side is valid
	if type(side) != "string" or !table.HasValue(forceAlign.sides, side) then print("[forceAlign] " .. forceAlign.dbLang.noSet .. " " .. forceAlign.lang["pnts"] .. ": " .. self:Nick() .. " - " .. forceAlign.dbLang.dec) return end

	if !self:isForceSensitive() or forceAlign.staticJobs[ team.GetName(self:Team()) ] then
		if forceAlign.sides[1] == side or forceAlign.sides[2] == side then return end
	end

	-- Let the rest of the system know we're using giveFAlignPoints
	local gave = true

	-- Gather some data before changing values
	local oldAlign = self:getForceAlignment()

	hook.Run("forceAlign_prePointChange", ply, side, amount, notify, gave)

	-- Change values
	self.forceAlign[side] = math.Clamp(self:getForceAlignment(side) + amount, 0, forceAlign.limit)

	-- Run some forceAlign.balCtrls stuff
	forceAlign_balCtrls(self, side, amount, notify, oldAlign, gave)

	-- Run notifications and HUD changes
	forceAlign_postPointChange(self, side, amount, notify, gave)
end

function forceAlign.checkSithEyes(ply)
	if !forceAlign.sithEyes.enabled then return end

	local mats = ply:GetMaterials()
	if !mats then return end

	-- Clear submaterials first
	for k,v in pairs(mats) do
	--	if string.find(v, "eye") then
			ply:SetSubMaterial(k - 1, nil)
			-- Dev print for locating eye materials
			// if ply:IsSuperAdmin() then print("[forceAlign] " .. ply:Nick() .. " - " .. v) end
	--	end
	end

	local rt = forceAlign.sithEyes.reqType
	local r = forceAlign.sithEyes.req

	local setEyes = false
	-- Allow anyone to use sith eyes
	if !r then setEyes = true
	-- Set mats when under the req threshold based on total dark side points
	elseif rt == 1 and ply:getForceAlignment(2) > r then setEyes = true
	-- Set mats when under the req threshold based on alignment
	elseif rt == 2 and ply:getForceAlignment() < r then setEyes = true end

	if setEyes and ply:GetNW2Int("forceAlign_switch") == 2 then
		for k,v in pairs(mats) do
			if string.find(v, "eye") then
				local eyeMat = forceAlign.sithEyes.mats[ply:SteamID()] or forceAlign.sithEyes.mats["Default"]
				ply:SetSubMaterial(k - 1, eyeMat)
			end
		end
	end
end

-- Toggle the alignment switch on the player HUD
function ply:toggleFAlignSwitch(side)
	if !forceAlign.switch.enabled then return end
	if !side then
		if self:GetNW2Int("forceAlign_switch") > 1 then side = 1 else side = 2 end

	elseif side == self:GetNW2Int("forceAlign_switch") then
		self:PrintMessage(HUD_PRINTTALK, forceAlign.lang["swtch"])
		return
	end

	if self.forceAlign_lastSwitch and self.forceAlign_lastSwitch > os.time() - forceAlign.switch.cd then
		--	self:SetNW2Int("forceAlign_switch", self:GetNW2Int("forceAlign_switch"))
		local timer = self.forceAlign_lastSwitch - os.time() + forceAlign.switch.cd
		self:PrintMessage(HUD_PRINTTALK, forceAlign.dbLang.noSet .. " " .. forceAlign.dbLang.swtch .. ". " .. forceAlign.lang["wait"] .. " " .. timer)

	else
		self.forceAlign_lastSwitch = os.time()
		self:SetNW2Int("forceAlign_switch", side)
		forceAlign.checkSithEyes(self)
		print("[forceAlign] " .. forceAlign.dbLang.set .. " " .. forceAlign.dbLang.swtch .. ": " .. forceAlign.sides[side] .. " - " .. self:Nick())

		if forceAlign.switch.saveCD then
			local sid = self:SteamID64()
			if !sid then sid = "singleplayer" end
			file.Write("forcealign/switch/" .. sid .. ".txt", self.forceAlign_lastSwitch)
		end
	end
end

-- Check to see if the target player has the opposite alignment
function ply:hasOpposingAlignment(target)
	if !IsValid(target) or !target:isForceSensitive() then return false

	elseif ply:getForceAlignment() > 0 and target:getForceAlignment() < 0 then return true
	elseif ply:getForceAlignment() < 0 and target:getForceAlignment() > 0 then return true end
end

-- Get the average alignment of all force sensitive players on the server
function forceAlign.galAlignment()
	local galAlign = 0
	local plyCount = 0

	for k,v in pairs(player.GetAll()) do
		if !v:isForceSensitive() then continue end

		galAlign = galAlign + v:getForceAlignment()
		plyCount = plyCount + 1
	end

	galAlign = galAlign / plyCount

	return galAlign
end

hook.Add("PlayerSay", "fAlign_chatCmds", function(ply, text)
	if !IsValid(ply) then return end
	if string.lower(text) == forceAlign.pointsHUD.cmd then
		if ply.lastFAlignPntCheck and ply.lastFAlignPntCheck > CurTime() - forceAlign.notifyHUD.dieTime then return end

		ply.lastFAlignPntCheck = CurTime()
		net.Start("forceAlign_pointCheck")
		net.Send(ply)

		for k,v in pairs(forceAlign.sides) do
			if k < 3 then continue end
			local amt = ply:getForceAlignment(k)
			if !amt or amt <= 0 then continue end
			ply:PrintMessage(HUD_PRINTTALK, v .. " points: " .. amt)
		end

	elseif string.lower(text) == forceAlign.switch.cmd then
		ply:toggleFAlignSwitch()
	end
end)

print("[forceAlign] Finished loading core!")