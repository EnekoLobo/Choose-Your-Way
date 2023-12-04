--[[---------------------------------]]--
--	Network Strings
--[[---------------------------------]]--

util.AddNetworkString("RDV_COMP_OpenPetMenu")
util.AddNetworkString("RDV_COMP_PurchaseComp")
util.AddNetworkString("RDV_COMP_NetworkComps")
util.AddNetworkString("RDV_COMP_ChangeSkin")
util.AddNetworkString("RDV_COMP_TogglePet")
util.AddNetworkString("RDV_COMP_VendorMenu")

--[[---------------------------------]]--
--	Local Helpers & Vars
--[[---------------------------------]]--

local COL_WHITE = Color(255,255,255)

local function SendNotification(ply, msg)
    local CFG = {
		Appension = RDV.LIBRARY.GetConfigOption("COMP_prefix"),
		Color = RDV.LIBRARY.GetConfigOption("COMP_prefixColor"),
	}

	RDV.LIBRARY.AddText(ply, CFG.Color, "["..CFG.Appension.."] ", COL_WHITE, msg)
end

local function PetSkinExists(PET, SKIN)
	local CFG = RDV.COMPANIONS.COMPANIONS

	if not CFG[PET] then
		return false
	end 

	CFG = CFG[PET]

	if not CFG.Skins then
		return false
	end

	CFG = CFG.Skins

	if not CFG[SKIN] then
		return false
	end

	return true
end

--[[---------------------------------]]--
--	Net Receivers
--[[---------------------------------]]--

net.Receive("RDV_COMP_TogglePet", function(len, ply)
    local C = net.ReadString()
	
	if not RDV.COMPANIONS.HasCompanionPurchased(ply, C) then
		local LTRANS = RDV.LIBRARY.GetLang(nil, "COMP_dontOwnCompanion")

		SendNotification(ply, LTRANS)
		return
	end

	if C then
		if !RDV.COMPANIONS.PlayerCanUseCompanion(ply, C) then
			return
		end
	end

    local EQUIPPED = RDV.COMPANIONS.GetPlayerCompanionClass(ply)

	-- Remove Companion
	local C_E = RDV.COMPANIONS.GetPlayerCompanion(ply)

    if IsValid(C_E) then
        C_E:Remove()
    end

    if C == EQUIPPED then
        local SUCCESS = RDV.COMPANIONS.SetCompanionEquipped(ply, C, false, true)

		if SUCCESS then
			local LTRANS = RDV.LIBRARY.GetLang(nil, "COMP_unequippedCompanion", {
				C, 
			})

			SendNotification(ply, LTRANS)
		end
    else
        local SUCCESS = RDV.COMPANIONS.SetCompanionEquipped(ply, C, true, true)

		if SUCCESS then
			local LTRANS = RDV.LIBRARY.GetLang(nil, "COMP_equippedCompanion", {
				C, 
			})

			SendNotification(ply, LTRANS)
		end
    end
end)

net.Receive("RDV_COMP_PurchaseComp", function(len, ply)
    local PCHAR =  ( RDV.LIBRARY.GetCharacterEnabled() and RDV.LIBRARY.GetCharacterID(ply, nil) or 1 )
	
    local SID = ply:SteamID64()

    RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR] = RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR] or {}

    local C = net.ReadString()

	if RDV.COMPANIONS.HasCompanionPurchased(ply, C) then
		local TRANS = RDV.LIBRARY.GetLang(nil, "COMP_alreadyOwnPet")

		SendNotification(ply, TRANS)
		return
	end

	local TAB = RDV.COMPANIONS.GetCompanion(C)

	if !TAB.Purchaseable then return end
	
	local PRICE = TAB.Price

	if C then
		if !RDV.COMPANIONS.PlayerCanUseCompanion(ply, C) then
			local TRANS = RDV.LIBRARY.GetLang(nil, "COMP_cannotPurchaseTeam")
			SendNotification(ply, TRANS)

			return
		end
	end

	if RDV.LIBRARY.CanAfford(ply, nil, PRICE) then
		local SUCCESS = RDV.COMPANIONS.GiveCompanion(ply, C)

		if SUCCESS then
			local TRANS = RDV.LIBRARY.GetLang(nil, "COMP_purchasedPet", {
				C, 
				RDV.LIBRARY.FormatMoney(nil, PRICE),
			})

			RDV.LIBRARY.PlaySound(ply, "addoncontent/shared/purchase.ogg")

			RDV.LIBRARY.AddMoney(ply, nil, -PRICE)

			SendNotification(ply, TRANS)

			hook.Run("RDV_COMP_OnCompanionPurchased", ply, C)
		end
	else
		local LTRANS = RDV.LIBRARY.GetLang(nil, "COMP_cannotAffordPet")

		SendNotification(ply, LTRANS)
	end
end)

net.Receive("RDV_COMP_ChangeSkin", function(len, ply)
    local C = net.ReadString()

	if not RDV.COMPANIONS.HasCompanionPurchased(ply, C) then
		return
	end

	local SKIN = net.ReadUInt(8)

	if not PetSkinExists(C, SKIN) then
		return
	end
	
    local PCHAR =  ( RDV.LIBRARY.GetCharacterEnabled() and RDV.LIBRARY.GetCharacterID(ply, nil) or 1 )

	local SID = ply:SteamID64()

    RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR] = RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR] or {}
	RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR].COMPANIONS = RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR].COMPANIONS or {}
	RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR].COMPANIONS[C] = RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR].COMPANIONS[C] or {}

	if RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR].COMPANIONS[C] then
		if tonumber(RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR].COMPANIONS[C].SKIN) == tonumber(SKIN) then
			return
		end
	end

	local PRICE = RDV.COMPANIONS.COMPANIONS[C].Skins[SKIN].Price

	if RDV.LIBRARY.CanAfford(ply, nil, PRICE) then
		RDV.LIBRARY.PlaySound(ply, "addoncontent/shared/purchase.ogg")

		local C_E = RDV.COMPANIONS.GetPlayerCompanion(ply)

		if IsValid(C_E) then
			C_E:SetSkin(SKIN)
			C_E:EmitSound("addoncontent/shared/spray.ogg")
		end

		RDV.LIBRARY.AddMoney(ply, nil, -PRICE)

		RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR].COMPANIONS[C].SKIN = SKIN

		local LANG = RDV.LIBRARY.GetLang(nil, "COMP_changeSkin", {
			RDV.LIBRARY.FormatMoney(nil, PRICE), 
		})

		SendNotification(ply, LANG)

		hook.Run("RDV_COMP_OnSkinChanged", ply, C, SKIN)
	else
		local LANG = RDV.LIBRARY.GetLang(nil, "COMP_cannotAffordSkin")

		SendNotification(ply, LANG)
	end
end)