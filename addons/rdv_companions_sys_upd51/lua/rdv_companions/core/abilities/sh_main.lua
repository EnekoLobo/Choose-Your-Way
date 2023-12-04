function RDV.COMPANIONS.HasPurchasedAbility(ply, ABILITY, PET)
    if not ABILITY then return end
    if not PET then PET = RDV.COMPANIONS.GetPlayerCompanionClass(ply) end

    if SERVER then
        local PCHAR =  ( RDV.LIBRARY.GetCharacterEnabled() and RDV.LIBRARY.GetCharacterID(ply, nil) or 1 )

        local SID = ply:SteamID64()

        local TAB = RDV.COMPANIONS.PLAYERS[SID]
    
        if !TAB.LIST[PCHAR] or !TAB.LIST[PCHAR].COMPANIONS or !TAB.LIST[PCHAR].COMPANIONS[PET] then
            return false
        end
    
        local TAB = TAB.LIST[PCHAR].COMPANIONS[PET].ABILITIES

        if TAB and TAB[ABILITY] then
            return true
        else
            return false
        end
    else
        local TAB_CLI = RDV.COMPANIONS.PLAYERS[PET]

        if !TAB_CLI or !TAB_CLI.ABILITIES or !TAB_CLI.ABILITIES[ABILITY] then
            return false
        else
            return true
        end
    end
end

function RDV.COMPANIONS.IsAbilityEnabled(ability)
    local TAB = RD_GLOBAL_PETS_UNAVAILABLE_ABILITIES

    if TAB and TAB[ability] then
        return false
    end

    return true
end

function RDV.COMPANIONS.GetActiveAbility(C)
    local CFG = RDV.COMPANIONS.ABILITIES

    if not CFG or not CFG[C:GetCurrentAbility()] then
        return
    end
    
    return CFG[C:GetCurrentAbility()]
end

hook.Add("Tick", "RDV.PETS.ABILITIES.THINK", function()
    for k, v in ipairs(player.GetHumans()) do
        local C_E = RDV.COMPANIONS.GetPlayerCompanion(v)

        if !IsValid(C_E) then continue end

        local A = RDV.COMPANIONS.GetActiveAbility(C_E)

        if A and A.Think then
            A:Think(v, C_E)
        end
    end
end)