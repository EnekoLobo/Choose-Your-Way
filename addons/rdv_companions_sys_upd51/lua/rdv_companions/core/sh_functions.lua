function RDV.COMPANIONS.GetPlayerCompanion(ply)
	if !IsValid(ply) then return false end
	
	return ply:GetNWEntity("RDV.COMPANIONS.EQUIPPED", false)
end

function RDV.COMPANIONS.GetPlayerCompanionClass(ply)
	if !IsValid(ply) then return false end

	return ply:GetNWString("RDV.COMPANIONS.CLASS", false)
end

function RDV.COMPANIONS.HasCompanionPurchased(client, class)
	if SERVER then
		local PCHAR =  ( RDV.LIBRARY.GetCharacterEnabled() and RDV.LIBRARY.GetCharacterID(client, nil) or 1 )

		local SID = client:SteamID64()

		RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR] = RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR] or {}
		RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR].COMPANIONS = RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR].COMPANIONS or {}
		
		if !RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR].COMPANIONS[class] then
			return false
		else
			return true
		end
	else
		if !RDV.COMPANIONS.PLAYERS[class] then
			return false
		else
			return true
		end
	end
end

function RDV.COMPANIONS.PlayerCanUseCompanion(ply, PET)
	if !PET or PET == "" then
		return
	end
	
	local TAB = RDV.COMPANIONS.GetCompanion(PET)
	local TEAMS = TAB.Teams

	if TEAMS and !table.IsEmpty(TEAMS) then
		local TEAM = ply:Team()

		if not TEAMS[team.GetName(TEAM)] then
			return false
		end
	end
	
	local UserGroups = TAB.UserGroups

	if UserGroups and !table.IsEmpty(UserGroups) then
		if not UserGroups[ply:GetUserGroup()] then
			return false
		end
	end

	local CAN = hook.Run("RDV_COMP_CanHaveCompanion", ply, PET)

	if CAN ~= nil then
		return CAN
	end

	return true
end