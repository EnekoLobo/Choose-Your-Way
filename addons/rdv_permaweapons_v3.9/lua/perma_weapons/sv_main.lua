RDV_Mysql:RawQuery([[
    CREATE TABLE IF NOT EXISTS ixPermaWeapons(
        client VARCHAR(80),
        pchar INT,
        weapon VARCHAR(255),
        equipped TINYINT,
        PRIMARY KEY(client, pchar, weapon)
    )
]])

concommand.Add("rdv_pw_dropdb", function(ply)
    if IsValid(ply) then
        ply:ChatPrint("This command can only be ran from server console.")
        return
    end

    local q = RDV_Mysql:Drop("ixPermaWeapons")
    q:Callback(function(data)
        local CFG = RDV.PERMAWEAPONS.CFG.Prefix

        MsgC(CFG.Color, "["..CFG.Appension.."] ", COL_1, "Database Dropped Successfully\n")
    end)
    q:Execute()
end)

local function SendNotification(ply, msg)
    local CFG = RDV.PERMAWEAPONS.CFG.Prefix

    RDV.LIBRARY.AddText(ply, CFG.Color, "["..CFG.Appension.."] ", Color(255,255,255), msg)
end

hook.Add("PlayerLoadout", "RDV.PERMAWEAPONS.PlayerLoadout", function(ply)
    if !IsValid(ply) or !ply.ixPermaWeapons then
        return
    end

    local SID64 = ply:SteamID64()

    local CATS = RDV.PERMAWEAPONS.CATS[SID64]

    for k, v in pairs(ply.ixPermaWeapons) do
        local TAB = RDV.PERMAWEAPONS.CFG.Weapons[k]

        if !v.Equipped or !TAB then continue end
        
        if RDV.PERMAWEAPONS.CanUse(ply, k) then
            if RDV.PERMAWEAPONS.CFG.OneCat then
                if ( CATS[TAB.Category] and CATS[TAB.Category] ~= k ) then 
                    continue
                end
            end
            
            CATS[TAB.Category] = k

            ply:Give(k)
        end
    end
end)

util.AddNetworkString("ix.PermaWeapons.Menu")
util.AddNetworkString("ix.PermaWeapons.Purchase")
util.AddNetworkString("ix.PermaWeapons.Equip")
util.AddNetworkString("ix.PermaWeapons.Admin")
util.AddNetworkString("ix.PermaWeapons.Receive")

net.Receive("ix.PermaWeapons.Purchase", function(len, ply)
    local WEP = net.ReadString()

    local CFG = RDV.PERMAWEAPONS.CFG.Weapons[WEP]

    if !CFG then
        return
    end

    if !CFG.BUYABLE then return end

    if RDV.PERMAWEAPONS.CanUse(ply, WEP) then
        local CURRENCY = RDV.PERMAWEAPONS.CFG.Currency

        if !RDV.LIBRARY.CanAfford(ply, CURRENCY, CFG.Price) then
            return
        else
            RDV.LIBRARY.AddMoney(ply, CURRENCY, -CFG.Price)
        end

        RDV.PERMAWEAPONS.Give(ply, WEP)

        SendNotification(ply, RDV.LIBRARY.GetLang(nil, "PMW_YouPurchased", {CFG.Name, RDV.LIBRARY.FormatMoney(CURRENCY, CFG.Price)}))
    else
        ply:ChatPrint("You cannot use this weapon!")
    end 
end)

net.Receive("ix.PermaWeapons.Equip", function(len, ply)
    local WEP = net.ReadString()

    RDV.PERMAWEAPONS.Toggle(ply, WEP)
end)

local function SelectData(ply, slot)
    ply.ixPermaWeapons = {}

    local SID64 = ply:SteamID64()
    local CATS = RDV.PERMAWEAPONS.CATS[SID64]

    local q = RDV_Mysql:Select("ixPermaWeapons")
        q:Select("weapon")
        q:Select("equipped")
        q:Where("client", SID64)
        q:Where("pchar", slot)
        q:Callback(function(data)
            if !data or !data[1] then return end

            for k, v in pairs(data) do
                local TAB = RDV.PERMAWEAPONS.CFG.Weapons[v.weapon]
                if !TAB then continue end

                local VAL = tobool(v.equipped)

                if RDV.PERMAWEAPONS.CFG.OneCat then
                    if VAL and CATS[TAB.Category] then 
                        VAL = false

                        RDV.PERMAWEAPONS.Toggle(ply, v.weapon) 
                    end
                end

                ply.ixPermaWeapons[v.weapon] = {
                    Equipped = VAL
                }
                
                if VAL and TAB then
                    timer.Simple(0, function() 
                        if RDV.PERMAWEAPONS.CanUse(ply, v.weapon) then
                            CATS[TAB.Category] = v.weapon

                            ply:Give(v.weapon)
                        end
                    end )
                end
            end
        end)
    q:Execute()
end

if RDV.PERMAWEAPONS.CFG.Character then
    RDV.LIBRARY.OnCharacterLoaded(RDV.PERMAWEAPONS.CFG.Character, function(ply, slot)
        RDV.PERMAWEAPONS.CATS[ply:SteamID64()] = {}

        SelectData(ply, slot)
    end)

    RDV.LIBRARY.OnCharacterDeleted(RDV.PERMAWEAPONS.CFG.Character, function(ply, charid)
        local SID64 = ply:SteamID64()

        local q = RDV_Mysql:Delete("ixPermaWeapons")
            q:Where("client", SID64)
            q:Where("pchar", charid)
        q:Execute()
    end)
else
	hook.Add("PlayerReadyForNetworking", "RDV.PERMAWEAPONS.PlayerReadyForNetworking", function(ply)
        RDV.PERMAWEAPONS.CATS[ply:SteamID64()] = {}

		SelectData(ply, 1)
	end)
end

net.Receive("ix.PermaWeapons.Admin", function(len, ply)
    if !RDV.PERMAWEAPONS.CFG.Admins[ply:GetUserGroup()] then return end

    local PLAYER = net.ReadPlayer()

    if !IsValid(PLAYER) then return end

    local WEP = net.ReadString()

    local TAB = RDV.PERMAWEAPONS.CFG.Weapons[WEP]

    if !TAB then return end

    local SID64 = PLAYER:SteamID64()
    local CHARACTER =  ( RDV.PERMAWEAPONS.CFG.Character and RDV.LIBRARY.GetCharacterID(PLAYER, RDV.PERMAWEAPONS.CFG.Character) or 1 )

    if PLAYER.ixPermaWeapons and PLAYER.ixPermaWeapons[WEP] then
        RDV.PERMAWEAPONS.Take(PLAYER, WEP)

        SendNotification(ply, RDV.LIBRARY.GetLang(nil, "PMW_YouTook", {TAB.Name, PLAYER:Name()}))
    else
        RDV.PERMAWEAPONS.Give(PLAYER, WEP)
        
        SendNotification(ply, RDV.LIBRARY.GetLang(nil, "PMW_YouGave", {TAB.Name, PLAYER:Name()}))
    end
end)

net.Receive("ix.PermaWeapons.Receive", function(len, ply)
    if !RDV.PERMAWEAPONS.CFG.Admins[ply:GetUserGroup()] then return end

    local PLAYER = net.ReadPlayer()

    if !IsValid(PLAYER) then return end

    net.Start("ix.PermaWeapons.Receive")
        net.WritePlayer(PLAYER)

        if PLAYER.ixPermaWeapons then
            net.WriteTable(PLAYER.ixPermaWeapons)
        else
            net.WriteTable({})
        end
    net.Send(ply)
end)