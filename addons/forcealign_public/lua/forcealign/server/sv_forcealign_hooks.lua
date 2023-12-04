forceAlign = forceAlign or {}

-- This is an example of how to incorporate the alignment system into your other addons
-- To disable the Active Hooks, change disableHooks to true
local disableHooks = false

--[[ - - - - - - - - - - Active Hooks - - - - - - - - - - ]]

hook.Add("PlayerDeath", "forceAlign_plyDeath", function(victim, inflictor, attacker)
	if disableHooks or !IsValid(victim) or !victim:IsPlayer() or !IsValid(attacker) or !attacker:IsPlayer() or victim == attacker then return end

	-- Give forceAlign.sides[2] for killing other players
	if forceAlign.balCtrls.karmaKills then
		attacker:giveFAlignPoints(forceAlign.balCtrls.karmaKills, 2, false)
	end

	-- Give points for killing players with the opposite alignment
	if forceAlign.balCtrls.PvP then
		if attacker:hasOpposingAlignment(victim) then
			attacker:giveFAlignPoints(forceAlign.balCtrls.PvP, true, true)
		end
	end
end)

hook.Add("OnNPCKilled", "forceAlign_npcKills", function(ent, ply, inf)
	if disableHooks or !forceAlign.balCtrls.NPCs or !IsValid(ent) or !IsValid(ply) or !ent:IsNPC() or !ply:IsPlayer() then return end

	-- Give points for killing NPCs based on alignment switch
	ply:giveFAlignPoints(forceAlign.balCtrls.NPCs, true, true)
end)

local testEnts = {
	["falign_50_lightside"] = true,
	["falign_150_lightside"] = true,
	["falign_250_lightside"] = true,
	["falign_500_lightside"] = true,
	["falign_1000_lightside"] = true,
	["falign_50_darkside"] = true,
	["falign_150_darkside"] = true,
	["falign_250_darkside"] = true,
	["falign_500_darkside"] = true,
	["falign_1000_darkside"] = true,
	["falign_test_reset"] = true,
}
-- This hook runs the testEnts above for debugging
-- Remove the // from the beginning of the first line to disable this hook as well
hook.Add("PlayerUse", "forceAlign_plyUse", function(ply, ent)
//	if disableHooks then return end

	if !IsValid(ply) or !IsValid(ent) or !testEnts[ent:GetClass()] then return end
	if ent.lastUse and ent.lastUse > CurTime() - 2 then return end
	ent.lastUse = CurTime()


	if ent:GetClass() == "falign_50_lightside" then
		ply:giveFAlignPoints(50, 1, true)

	elseif ent:GetClass() == "falign_150_lightside" then
		ply:giveFAlignPoints(150, 1, true)

	elseif ent:GetClass() == "falign_250_lightside" then
		ply:giveFAlignPoints(250, 1, true)

	elseif ent:GetClass() == "falign_500_lightside" then
		ply:giveFAlignPoints(500, 1, true)
	
	elseif ent:GetClass() == "falign_1000_lightside" then
		ply:giveFAlignPoints(1000, 1, true)

	elseif ent:GetClass() == "falign_50_darkside" then
		ply:giveFAlignPoints(50, 2, true)
	
	elseif ent:GetClass() == "falign_150_darkside" then
		ply:giveFAlignPoints(150, 2, true)
	
	elseif ent:GetClass() == "falign_250_darkside" then
		ply:giveFAlignPoints(250, 2, true)
	
	elseif ent:GetClass() == "falign_500_darkside" then
		ply:giveFAlignPoints(500, 2, true)
		
	elseif ent:GetClass() == "falign_1000_darkside" then
		ply:giveFAlignPoints(1000, 2, true)

	elseif ent:GetClass() == "falign_test_reset" then
		ply:setForceAlignment(0, 1, true)
		ply:setForceAlignment(0, 2, true)
		ply:PrintMessage(HUD_PRINTCENTER, "¡Has reiniciado tus puntos!")
	
	end
end )

--[[ - - - - - - - - - jobRestrict Hooks - - - - - - - - - ]]

hook.Add("PlayerCanJoinTeam", "forceAlign_joinTeam", function(ply, team)
	if !forceAlign.jobRestrict[ team.GetName(team) ] then return end
	
	local tbl = forceAlign.jobRestrict[ team.GetName(team) ]
	
	if ply.forceAlign[forceAlign.sides[1]] < tbl[1] or ply.forceAlign[forceAlign.sides[2]] < tbl[2] then
		ply:PrintMessage(HUD_PRINTTALK, forceAlign.lang["noJob"] .. " - " .. forceAlign.lang["req"] .. " " .. tbl[1] .. " " .. forceAlign.sides[1] .. " " .. forceAlign.lang["pnts"])
		return false
	end
end)

-- DarkRP job support
hook.Add("playerCanChangeTeam", "forceAlign_changeTeam", function(ply, job, force)
	if !forceAlign.jobRestrict[ team.GetName(job) ] then return end
	
	local tbl = forceAlign.jobRestrict[ team.GetName(job) ]
	
	if ply.forceAlign[forceAlign.sides[1]] < tbl[1] then
		return false, forceAlign.lang["noJob"] .. " - " .. forceAlign.lang["req"] .. " " .. tbl[1] .. " " .. forceAlign.sides[1] .. " " .. forceAlign.lang["pnts"]
	end

	if ply.forceAlign[forceAlign.sides[2]] < tbl[2] then
		return false, forceAlign.lang["noJob"] .. " - " .. forceAlign.lang["req"] .. " " .. tbl[2] .. " " .. forceAlign.sides[2] .. " " .. forceAlign.lang["pnts"]
	end
end)

--[[ - - - - - - - - - Additional Hooks - - - - - - - - - ]]

hook.Add("forceAlign_preSave", "forceAlign_preSaveHook", function(ply)
	-- A hook for modules to update data right before being saved
end)

hook.Add("forceAlign_saved", "forceAlign_postSave", function(ply)
	-- If you have a character creation system, you can utilize this hook to sync player data
end)

hook.Add("forceAlign_prePointChange", "forceAlign_pointsChanging", function(ply, side, amount, notify, gave)
	-- Called right before point values change

	-- ply = the player (duh)
	-- side = string; the forceAlign.sides string name
	-- amount = int; the amount that was given. Called for both setForceAlignment and giveFAlignPoints
	-- notify = boolean; whether the player was notified of the change
	-- gave = boolean; whether or not we used giveFAlignPoints for the change
end)

hook.Add("forceAlign_postPointChange", "forceAlign_pointsChanged", function(ply, side, amount, notify, gave)
	-- Called right after point values have been changed

	-- ply = the player (duh)
	-- side = string; the forceAlign.sides string name
	-- amount = int; the amount that was given. Called for both setForceAlignment and giveFAlignPoints
	-- notify = boolean; whether the player was notified of the change
	-- gave = boolean; whether or not we used giveFAlignPoints for the change
end)