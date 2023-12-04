local NET_STRINGS = {
    "RDV_COMP_PurchaseAbility",
    "RDV_COMP_SelectAbility",
}

for k, v in ipairs(NET_STRINGS) do
    util.AddNetworkString(v)    
end

--]]------------------------------------------------]]--
--	Local Functions
--]]------------------------------------------------]]--

local function SendNotification(ply, msg)
    local CFG = {
		Appension = RDV.LIBRARY.GetConfigOption("COMP_prefix"),
		Color = RDV.LIBRARY.GetConfigOption("COMP_prefixColor"),
	}

	RDV.LIBRARY.AddText(ply, CFG.Color, "["..CFG.Appension.."] ", Color(255,255,255), msg)
end

local function CheckCooldown(C_E, ABILITY)
    if not IsValid(C_E) then return false end
    if not C_E.AbilityCooldown then return true end
    if not C_E.AbilityCooldown[ABILITY] then return true end

    if C_E.AbilityCooldown[ABILITY] > CurTime() then
        local LTRANS = RDV.LIBRARY.GetLang(nil, "COMP_onCooldown")

        SendNotification(C_E:GetPetOwner(), LTRANS)
        return false
    end

    return true
end

--]]------------------------------------------------]]--
--	Net Messages
--]]------------------------------------------------]]--

net.Receive("RDV_COMP_PurchaseAbility", function(len, ply)
    local ABILITY = net.ReadString()
    local C = RDV.COMPANIONS.GetPlayerCompanionClass(ply)

    if RDV.COMPANIONS.HasPurchasedAbility(ply, ABILITY, C) then
        local LANG = RDV.LIBRARY.GetLang(nil, "COMP_alreadyPurchased")
        SendNotification(ply, LANG)

        return
    end

    if not RDV.COMPANIONS.IsAbilityEnabled(ABILITY) then
        return
    end

    local PRICE = RDV.COMPANIONS.ABILITIES[ABILITY]

    if PRICE then
        PRICE = (PRICE.Price or 0)
    end

    if RDV.LIBRARY.CanAfford(ply, nil, PRICE) then
        local CAN = hook.Run("RDV_COMP_CanPurchaseAbility", ply, ABILITY, PRICE)

        if CAN ~= false then
            RDV.COMPANIONS.GiveAbility(ply, ABILITY, C)

            RDV.LIBRARY.PlaySound(ply, "addoncontent/shared/purchase.ogg")

            RDV.LIBRARY.AddMoney(ply, nil, -PRICE)

            local LANG = RDV.LIBRARY.GetLang(nil, "COMP_purchasedAbility", {
                ABILITY,
                C,
            })

            SendNotification(ply, LANG)
        end
    else
        local LANG = RDV.LIBRARY.GetLang(nil, "COMP_cannotAfford")
        SendNotification(ply, LANG)
    end
end)

hook.Add("RDV_COMP_CanPurchaseAbility", "PlayerCanPurchasePetAbility_DEFAULT", function(ply, ability, price)
    local TAB = RDV.COMPANIONS.ABILITIES
    
    if not TAB[ability] then
        return false
    else
        TAB = TAB[ability]

        if TAB.Groups and not TAB.Groups[ply:GetUserGroup()] then
            return false
        end
    end
end)

net.Receive("RDV_COMP_SelectAbility", function(len, ply)
	local ABILITY = net.ReadString()

    if not ABILITY or ABILITY == "" then
        return
    end

    local C = RDV.COMPANIONS.GetPlayerCompanionClass(ply)
    
	local PCHAR =  ( RDV.LIBRARY.GetCharacterEnabled() and RDV.LIBRARY.GetCharacterID(ply, nil) or 1 )
    local SID = ply:SteamID64()

    local LIST = RDV.COMPANIONS.PLAYERS[SID].LIST

    if !LIST[PCHAR] or !LIST[PCHAR].COMPANIONS or !LIST[PCHAR].COMPANIONS[C] then
        return
    end

    LIST[PCHAR].COMPANIONS[C].ABILITIES = LIST[PCHAR].COMPANIONS[C].ABILITIES or {}

    local TAB = LIST[PCHAR].COMPANIONS[C].ABILITIES

	if TAB then
        if not RDV.COMPANIONS.HasPurchasedAbility(ply, ABILITY, C) then
            local LANG = RDV.LIBRARY.GetLang(nil, "COMP_dontOwn")
            SendNotification(ply, LANG)

            return
        end

        if not RDV.COMPANIONS.IsAbilityUsable(ABILITY, C) then
            return
        end

        local C_E = RDV.COMPANIONS.GetPlayerCompanion(ply)

        if IsValid(C_E) then
            local CAN = CheckCooldown(C_E, ABILITY)

            if not CAN then 
                return false 
            end

            if RDV.COMPANIONS.GetOption(C_E, "stayCommand") then
                local LSTATION = RDV.LIBRARY.GetLang(nil, "COMP_inStationaryMode")

                SendNotification(ply, LSTATION)
                return
            end
            
            local CFG = RDV.COMPANIONS.ABILITIES

            if CFG[ABILITY] then
                if CFG[ABILITY].Initialize then
                    CFG[ABILITY]:Initialize(ply, C_E, ABILITY)
                end
                
                C_E:SetCurrentAbility(ABILITY)

                local COOLDOWN = RDV.COMPANIONS.ABILITIES[ABILITY].AbilityCooldown

                if not COOLDOWN then
                    return
                end

                C_E.AbilityCooldown = C_E.AbilityCooldown or {}
                C_E.AbilityCooldown[ABILITY] = CurTime() + COOLDOWN

                SendNotification(ply, RDV.LIBRARY.GetLang(nil, "COMP_startAbility"))
            end
        end
	end
end)