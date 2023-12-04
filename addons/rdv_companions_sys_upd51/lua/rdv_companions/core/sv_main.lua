local function SendNotification(ply, msg)
    local CFG = {
		Appension = RDV.LIBRARY.GetConfigOption("COMP_prefix"),
		Color = RDV.LIBRARY.GetConfigOption("COMP_prefixColor"),
	}

	RDV.LIBRARY.AddText(ply, CFG.Color, "["..CFG.Appension.."] ", Color(255,255,255), msg)
end

--[[---------------------------------]]--
--	Network Pet Data
--[[---------------------------------]]--

local function NetworkPets(ply, char)
    local SID = ply:SteamID64()

    RDV.COMPANIONS.PLAYERS[SID].LIST[char] = RDV.COMPANIONS.PLAYERS[SID].LIST[char] or {}
    RDV.COMPANIONS.PLAYERS[SID].LIST[char].COMPANIONS = RDV.COMPANIONS.PLAYERS[SID].LIST[char].COMPANIONS or {}
    
    local TAB = RDV.COMPANIONS.PLAYERS[SID].LIST[char].COMPANIONS

    local COUNT = table.Count(TAB)

    net.Start("RDV_COMP_NetworkComps")
        net.WriteBool(true)
        net.WriteUInt(COUNT, 16)

        for k, v in pairs(TAB) do
            local SKIN = (v.SKIN or 0)
            
            net.WriteString(k)
            net.WriteUInt(SKIN, 8)
        end
        
    net.Send(ply)

    ply:SetNWString("RDV.COMPANIONS.EquippedClass", "")

    local EQUIPPED = RDV.COMPANIONS.PLAYERS[SID].LIST[char].EQUIPPED

    RDV.COMPANIONS.SetCompanionEquipped(ply, EQUIPPED, true, false)
end

--[[---------------------------------]]--    
--  Put Pet Data in appropriate tables.
--[[---------------------------------]]--

local function SetupPets(PLAYER, DATA)
    if not PLAYER or not DATA then
        return
    end
    
    if !IsValid(PLAYER) then return end

    if not DATA or DATA[1] == nil then
        return
    end

    local SID = PLAYER:SteamID64()
    
    for k, v in ipairs(DATA) do
        local COMPANIONS = util.JSONToTable( (v.COMPANIONS or {}) )
        local PCHAR = tonumber(v.PCHARACTER)

        RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR] = RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR] or {}
        RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR] = COMPANIONS
    end

    if !RDV.LIBRARY.GetCharacterEnabled() then
        NetworkPets(PLAYER, 1)
    end
end

--[[---------------------------------]]--    
--  Save Pet Data
--[[---------------------------------]]--

local function SaveCharacter(ply, PCHAR)
    if ply:IsBot() then return end

    local SID = ply:SteamID64()

    if !RDV.COMPANIONS.PLAYERS[SID].VALID then
        return
    end

    if not PCHAR then
        PCHAR =  ( RDV.LIBRARY.GetCharacterEnabled() and RDV.LIBRARY.GetCharacterID(ply, nil) or 1 )
    end

    RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR] = RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR] or {}
    RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR].COMPANIONS = RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR].COMPANIONS or {}
    
    local SID64 = ply:SteamID64()
    local COMPS = RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR]

    COMPS = util.TableToJSON(COMPS)

    local q = RDV_Mysql:Select("RDV_COMPANIONS")
        q:Where("CLIENT", SID64)
        q:Where("PCHARACTER", PCHAR)
        q:Callback(function(data)
            if data and data[1] ~= nil then
                local q = RDV_Mysql:Update("RDV_COMPANIONS")
                    q:Update("COMPANIONS", COMPS)
                    q:Where("CLIENT", SID64)
                    q:Where("PCHARACTER", PCHAR)
                q:Execute()
            else
                local q = RDV_Mysql:Insert("RDV_COMPANIONS")
                    q:Insert("COMPANIONS", COMPS)
                    q:Insert("CLIENT", SID64)
                    q:Insert("PCHARACTER", PCHAR)
                q:Execute()
            end
        end)
    q:Execute()
end

--[[---------------------------------]]--    
--  PlayerReadyForNetworking Hook
--[[---------------------------------]]--

hook.Add("PlayerReadyForNetworking", "RDV.COMPANIONS.RUN", function(ply)
    if ply:IsBot() then return end

    local SID64 = ply:SteamID64()

    timer.Create("RDV.COMPANIONS.SaveTimer."..SID64, RDV.LIBRARY.GetConfigOption("COMP_saveInterval"), 0, function()
        if !IsValid(ply) then timer.Remove("RDV.COMPANIONS.SaveTimer."..SID64) return end

        SaveCharacter(ply)
    end)

    local q = RDV_Mysql:Select("RDV_COMPANIONS")
        q:Select("PCHARACTER")
        q:Select("COMPANIONS")
        q:Where("CLIENT", SID64)
        q:Callback(function(data)
            RDV.COMPANIONS.PLAYERS[SID64] = {
                LIST = {},
                VALID = true,
            }
            
            SetupPets(ply, data)
        end)
    q:Execute()
end)

RDV.LIBRARY.OnCharacterLoaded(nil, function(ply, char)
    if !RDV.LIBRARY.GetCharacterEnabled() then return end 

    if ply:IsBot() then return end

    timer.Simple(0, function()
        NetworkPets(ply, char)
    end)
end)

RDV.LIBRARY.OnCharacterChanged(nil, function(ply, new, old)
    if !RDV.LIBRARY.GetCharacterEnabled() then return end 

    if ply:IsBot() then return end

    SaveCharacter(ply, old)

    local C_E = RDV.COMPANIONS.GetPlayerCompanion(ply)

    if IsValid(C_E) then
        C_E:Remove()
    end
end)

RDV.LIBRARY.OnCharacterDeleted(nil, function(ply, CHARACTER_ID)
    if !RDV.LIBRARY.GetCharacterEnabled() then return end 

    if ply:IsBot() then return end

    local q = RDV_Mysql:Delete("RDV_COMPANIONS")
        q:Where("CLIENT", ply:SteamID64())
        q:Where("PCHARACTER", CHARACTER_ID)
    q:Execute()
end)


hook.Add("PlayerDisconnected", "RDV.COMPANIONS.DISCONNECTED", function(ply)
    if ply:IsBot() then return end

    SaveCharacter(ply)

    local SID = ply:SteamID64()

    local C_E = RDV.COMPANIONS.GetPlayerCompanion(ply)

    if IsValid(C_E) then
        C_E:Remove()
    end

    if RDV.COMPANIONS.PLAYERS[SID] then
        RDV.COMPANIONS.PLAYERS[SID] = nil
    end
end)

hook.Add("ShutDown", "RDV.COMPANIONS.ShutDown", function()
    for k, v in ipairs(player.GetHumans()) do
        SaveCharacter(v)
    end
end)

--[[---------------------------------]]--    
--  Cleanup Pets
--[[---------------------------------]]--

hook.Add("PostCleanupMap", "RDV.COMPANIONS.PostCleanupMap", function()
	for k, v in ipairs(player.GetHumans()) do
        local C_E = RDV.COMPANIONS.GetPlayerCompanion(v)

		if not IsValid(C_E) then
			local C = RDV.COMPANIONS.GetPlayerCompanionClass(ply)

            if C and C ~= "" then
                RDV.COMPANIONS.SetCompanionEquipped(v, C, true, false)
            end
		end
	end
end)

hook.Add("PlayerEnteredVehicle", "RDV.COMPANIONS.EnterVehicle", function(ply)
    local C_E = RDV.COMPANIONS.GetPlayerCompanion(ply)

    if IsValid(C_E) then
        local LTRANS = RDV.LIBRARY.GetLang(nil, "COMP_exitVehicleWarning")

        SendNotification(ply, LTRANS)
	end
end)

hook.Add("PlayerLeaveVehicle", "RDV.COMPANIONS.ExitVehicle", function(ply)
    local C_E = RDV.COMPANIONS.GetPlayerCompanion(ply)

    if not IsValid(C_E) then
        local C = RDV.COMPANIONS.GetPlayerCompanionClass(ply)

        RDV.COMPANIONS.SetCompanionEquipped(ply, C, true, false)
    end
end)

--[[---------------------------------]]--    
--  DarkRP Cleanup Pets
--[[---------------------------------]]--

hook.Add("playerArrested", "RDV.COMPANIONS.playerArrested", function(ply)
    local C_E = RDV.COMPANIONS.GetPlayerCompanion(ply)

    if IsValid(C_E) then
        C_E:Remove()
    end
end)

hook.Add("playerUnArrested", "RDV.COMPANIONS.playerUnArrested", function(ply)
    local C_E = RDV.COMPANIONS.GetPlayerCompanion(ply)

    if not IsValid(C_E) then
        local C = RDV.COMPANIONS.GetPlayerCompanionClass(ply)

        RDV.COMPANIONS.SetCompanionEquipped(ply, C, true, false)
    end
end)

local q = [[
    CREATE TABLE IF NOT EXISTS RDV_COMPANIONS(
        CLIENT VARCHAR(255),
        PCHARACTER INT DEFAULT 1,
        COMPANIONS TEXT,
        PRIMARY KEY(CLIENT, PCHARACTER)
    )
]]

RDV_Mysql:RawQuery(q)

local COL_1 = Color(255,255,255)

concommand.Add("rdv_comps_dropdb", function(ply)
    if IsValid(ply) then
        ply:ChatPrint("This command can only be ran from server console.")
        return
    end

    local q = RDV_Mysql:Drop("RDV_COMPANIONS")
    q:Callback(function(data)
        local CFG = {
            Appension = RDV.LIBRARY.GetConfigOption("COMP_prefix"),
            Color = RDV.LIBRARY.GetConfigOption("COMP_prefixColor"),
        }

        MsgC(CFG.Color, "["..CFG.Appension.."] ", COL_1, "Database Dropped Successfully\n")
    end)
    q:Execute()
end)

hook.Add("OnPlayerChangedTeam", "RDV.COMPANIONS.PlayerCanUsePet", function(ply, before, after)
	timer.Simple(1, function()
        local C = RDV.COMPANIONS.GetPlayerCompanionClass(ply)

		if !C or C == "" then
			return
		end
		
		if !RDV.COMPANIONS.PlayerCanUseCompanion(ply, C) then
            RDV.COMPANIONS.SetCompanionEquipped(ply, C, false, true)
		end
	end)
end)