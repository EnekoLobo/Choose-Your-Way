local plyMeta = FindMetaTable("Player")

function RDV.COMPANIONS.GiveAbility(ply, ab, comp)
    if not ab then return end
    if not comp then comp = RDV.COMPANIONS.GetPlayerCompanionClass(ply) end

    if RDV.COMPANIONS.IsAbilityUsable(ab, comp) then
        local PCHAR =  ( RDV.LIBRARY.GetCharacterEnabled() and RDV.LIBRARY.GetCharacterID(ply, nil) or 1 )
        local SID = ply:SteamID64()

        local TAB = RDV.COMPANIONS.PLAYERS[SID]

        if !TAB.LIST[PCHAR] or !TAB.LIST[PCHAR].COMPANIONS or !TAB.LIST[PCHAR].COMPANIONS[comp] then
            return
        end

        TAB.LIST[PCHAR].COMPANIONS[comp].ABILITIES = TAB.LIST[PCHAR].COMPANIONS[comp].ABILITIES or {}
        TAB.LIST[PCHAR].COMPANIONS[comp].ABILITIES[ab] = true

        net.Start("RDV_COMP_NetworkAbility")
            net.WriteString(comp)
            net.WriteBool(false)
            net.WriteString(ab)
        net.Send(ply)
    end
end

hook.Add("PlayerButtonDown", "RDV_COMP_CallBackPet", function(P, KEY)
    if KEY == KEY_G then
        local C_E = RDV.COMPANIONS.GetPlayerCompanion(P)

        if !IsValid(C_E) then return end

        local ABILITY = C_E:GetCurrentAbility()

        if !ABILITY or ABILITY == "" then return end

        ABILITY = RDV.COMPANIONS.ABILITIES[ABILITY]

        if !ABILITY then return end

        if ABILITY.AbilityEnded then
            ABILITY:AbilityEnded(P, C_E)
            P:EmitSound("rdv/companions/misc/whistle.ogg")

            C_E:SetCurrentAbility("")
        end
    end
end )

util.AddNetworkString("RDV_COMP_NetworkAbility")

hook.Add("RDV_COMP_OnEquipped", "RDV.COMPANION.EQUIPPED.SEND", function(ply, PET)
    local CLASS = PET:GetPetType()

    local ABILITIES = {}

    local PCHAR =  ( RDV.LIBRARY.GetCharacterEnabled() and RDV.LIBRARY.GetCharacterID(ply, nil) or 1 )

    local SID = ply:SteamID64()

    local TAB = RDV.COMPANIONS.PLAYERS[SID]

    if TAB.LIST[PCHAR] and TAB.LIST[PCHAR].COMPANIONS and TAB.LIST[PCHAR].COMPANIONS[CLASS] then
        ABILITIES = ( TAB.LIST[PCHAR].COMPANIONS[CLASS].ABILITIES or {} )
    end

    local COUNT = table.Count(ABILITIES)

    net.Start("RDV_COMP_NetworkAbility")
        net.WriteString(CLASS)
            net.WriteBool(true)
            net.WriteUInt(COUNT, 8)

        for k, v in pairs(ABILITIES) do
            net.WriteString(k)
        end
    net.Send(ply)
end)