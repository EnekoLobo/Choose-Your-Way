--[[---------------------------------]]--    
--  Local Helpers & Vars
--[[---------------------------------]]--

local COL_WHITE = Color(255,255,255)

local function SendNotification(ply, msg)
    local CFG = {
		Appension = RDV.LIBRARY.GetConfigOption("COMP_prefix"),
		Color = RDV.LIBRARY.GetConfigOption("COMP_prefixColor"),
	}
	
	RDV.LIBRARY.AddText(ply, CFG.Color, "["..CFG.Appension.."] ", COL_WHITE, msg)
end

--[[---------------------------------]]--    
--  Functions
--[[---------------------------------]]--

function RDV.COMPANIONS.GiveCompanion(ply, PET)
	if not PET then return end

	if not RDV.COMPANIONS.GetCompanion(PET) then
		return false
	end

	if !RDV.COMPANIONS.PlayerCanUseCompanion(ply, PET) then
		return
	end

	local PCHAR =  ( RDV.LIBRARY.GetCharacterEnabled() and RDV.LIBRARY.GetCharacterID(ply, nil) or 1 )

	local SID = ply:SteamID64()

	RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR] = RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR] or {}
	RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR].COMPANIONS = RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR].COMPANIONS or {}
	
	RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR].COMPANIONS[PET] = {
		SKIN = 0,
	}

	net.Start("RDV_COMP_NetworkComps")
		net.WriteBool(false)
		net.WriteString(PET)
		net.WriteUInt(0, 8)
	net.Send(ply)

	return true
end

function RDV.COMPANIONS.SetCompanionEquipped(ply, PET, TOG, UPDATE)
	if not PET then return end
	if not isbool(TOG) then return end

	if not RDV.COMPANIONS.GetCompanion(PET) then
		return false
	end

	if TOG then
		if !RDV.COMPANIONS.PlayerCanUseCompanion(ply, PET) then
			local TRANS = RDV.LIBRARY.GetLang(nil, "COMP_cannotPurchaseTeam")
			SendNotification(ply, TRANS)
			return
		end

		--
		-- Check Restrictions
		--

		local TAB = RDV.COMPANIONS.CFG.Restriction

		if TAB and !table.IsEmpty(TAB) then
			if TAB[ply:GetUserGroup()] then
				goto success
			end

			SendNotification(ply, RDV.LIBRARY.GetLang(nil, "COMP_noMarketAccess"))

			return
		end
	end

    ::success::

	--
	-- Cache
	--

	local PCHAR =  ( RDV.LIBRARY.GetCharacterEnabled() and RDV.LIBRARY.GetCharacterID(ply, nil) or 1 )

	local SID = ply:SteamID64()

	RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR] = RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR] or {}
	RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR].COMPANIONS = RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR].COMPANIONS or {}
	
	if UPDATE then
		if !TOG then
			RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR].EQUIPPED = ""
		else
			RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR].EQUIPPED = PET
		end
	end

	--
	-- Remove Existing Pet
	--

	local C = RDV.COMPANIONS.GetPlayerCompanion(ply)

	if IsValid(C) then
		C:Remove()
	end

	--
	-- Create new Pet and call Hooks or just remove it entirely.
	--

	if TOG then
		local CFG = RDV.COMPANIONS.GetCompanion(PET).Model

		local TAB = RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR].COMPANIONS
		local SKIN = false
		

		if TAB then
			SKIN = ( TAB[PET].SKIN or 0 )
		end

		
		local PET_ENT = ents.Create("eps_cwapet")
		PET_ENT:SetPetType(PET)
		PET_ENT:SetPetOwner(ply)
		PET_ENT:SetPos(ply:GetPos())
		PET_ENT:Spawn()
		PET_ENT:Activate()
		
		PET_ENT:SetModel(CFG)

		if SKIN then
			PET_ENT:SetSkin(SKIN)
		end

		ply:SetNWEntity("RDV.COMPANIONS.EQUIPPED", PET_ENT)
		ply:SetNWString("RDV.COMPANIONS.CLASS", PET)

		hook.Run("RDV_COMP_OnEquipped", ply, PET_ENT, SKIN)
	else
		ply:SetNWString("RDV.COMPANIONS.CLASS", "")

		hook.Run("RDV_COMP_OnUnequipped", ply, PET)
	end

	return true
end