local function IsEquipped(ply, wep)
    local TAB = ply.ixPermaWeapons

    if !TAB or !TAB[wep] then
        return
    end

    return TAB[wep].Equipped
end

local function SendNotification(ply, msg)
    local CFG = RDV.PERMAWEAPONS.CFG.Prefix

    RDV.LIBRARY.AddText(ply, CFG.Color, "["..CFG.Appension.."] ", Color(255,255,255), msg)
end

function RDV.PERMAWEAPONS.Give(ply, wep, char)
    if !IsValid(ply) then return false end

    if !RDV.PERMAWEAPONS.CFG.Weapons[wep] then 
        return false 
    end

    local SID64 = ply:SteamID64()

    if !char then
	    char =  ( RDV.PERMAWEAPONS.CFG.Character and RDV.LIBRARY.GetCharacterID(ply, RDV.PERMAWEAPONS.CFG.Character) or 1 )
    end

    local q = RDV_Mysql:Insert("ixPermaWeapons")
        q:Insert("client", SID64)
        q:Insert("pchar", char)
        q:Insert("weapon", wep)
        q:Insert("equipped", 0)
    q:Execute()

    ply.ixPermaWeapons[wep] = {
        Equipped = false,
    }
    
    hook.Run("RDV_PMW_PostGiveWeapon", ply, wep, char)

    return true
end

function RDV.PERMAWEAPONS.Take(ply, wep, char)
    if !IsValid(ply) then return false end

    if !RDV.PERMAWEAPONS.CFG.Weapons[wep] then 
        return false 
    end

    local SID64 = ply:SteamID64()

    if !char then
	    char =  ( RDV.PERMAWEAPONS.CFG.Character and RDV.LIBRARY.GetCharacterID(ply, RDV.PERMAWEAPONS.CFG.Character) or 1 )
    end

    ply.ixPermaWeapons[wep] = nil

    local q = RDV_Mysql:Delete("ixPermaWeapons")
        q:Where("client", SID64)
        q:Where("pchar", char)
        q:Where("weapon", wep)
    q:Execute()

    hook.Run("RDV_PMW_PostTakeWeapon", ply, wep, char)

    return true
end

function RDV.PERMAWEAPONS.Toggle(ply, wep, char)
    local TAB = RDV.PERMAWEAPONS.CFG.Weapons[wep]
    if !TAB then return end

    if !ply.ixPermaWeapons or !ply.ixPermaWeapons[wep] then
        return false
    end

    if RDV.PERMAWEAPONS.CanUse(ply, wep) then
        local NVAL = !IsEquipped(ply, wep)

        local SID64 = ply:SteamID64()

        if !char then
            char =  ( RDV.PERMAWEAPONS.CFG.Character and RDV.LIBRARY.GetCharacterID(ply, RDV.PERMAWEAPONS.CFG.Character) or 1 )
        end

        local CATS = RDV.PERMAWEAPONS.CATS[SID64]

        if RDV.PERMAWEAPONS.CFG.OneCat then
            if NVAL then    
                if CATS[TAB.Category] then 
                    SendNotification(ply, RDV.LIBRARY.GetLang(nil, "PMW_oneCat"))
                    return 
                end
            
                CATS[TAB.Category] = wep
            else
                if ( CATS[TAB.Category] and CATS[TAB.Category] == wep ) then
                    CATS[TAB.Category] = nil
                end
            end
        end

        ply.ixPermaWeapons[wep] = {
            Equipped = NVAL,
        }

        local STAT = NVAL and 1 or 0

        local q = RDV_Mysql:Update("ixPermaWeapons")
            q:Update("equipped", STAT)
            q:Where("client", SID64)
            q:Where("pchar", char)
            q:Where("weapon", wep)
        q:Execute()

        if NVAL then
            ply:Give(wep)
        else
            ply:StripWeapon(wep)
        end
    else
        ply:ChatPrint("You cannot use this weapon!")
    end
end