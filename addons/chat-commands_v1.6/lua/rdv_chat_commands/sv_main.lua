util.AddNetworkString("RDV_CHAT_COMMANDS_ADMIN")
util.AddNetworkString("RDV_CHAT_COMMANDS_CREATE")
util.AddNetworkString("RDV_CHAT_COMMANDS_DELETE")
util.AddNetworkString("RDV_CHAT_COMMANDS_NETWORK")
util.AddNetworkString("RDV_CHAT_COMMANDS_SendMSG")

local PATH = "rdv/chat_commands"

local function SendNotification(ply, msg)
    local CFG = NCS_CHATCOMMANDS.CFG
	local PC = CFG.prefixcolor
	local PT = CFG.prefixtext

    NCS_SHARED.AddText(ply, Color(PC.r, PC.g, PC.b), "["..PT.."] ", color_white, msg)
end

local function SAVE()
    local DATA = util.TableToJSON(NCS_CHATCOMMANDS.LIST)

    file.CreateDir(PATH)

    file.Write(PATH.."/data.json", DATA)
end

local function READ()
    if file.Exists(PATH.."/data.json", "DATA") then
        local DATA = file.Read(PATH.."/data.json", "DATA")

        if !DATA then return end

        NCS_CHATCOMMANDS.LIST = util.JSONToTable(DATA)
    end
end
READ()

hook.Add("NCS_SHARED_PlayerReadyForNetworking", "RDV_CHAT_COMMANDS_NETWORK", function(P)
    local DATA = NCS_CHATCOMMANDS.LIST

    if table.Count(DATA) > 0 then
        local COMPRESS = util.Compress(util.TableToJSON(DATA))

        local BYTES = #COMPRESS
        
        net.Start("RDV_CHAT_COMMANDS_NETWORK")
            net.WriteUInt( BYTES, 16 )
            net.WriteData( COMPRESS, BYTES )
        net.Broadcast()
    end

    local CONFIG = NCS_CHATCOMMANDS.CFG

    if CONFIG and istable(CONFIG) then
        local COMPRESS = util.Compress(util.TableToJSON(CONFIG))

        local BYTES = #COMPRESS
        
        net.Start("NCS_CHATCOMMANDS_UpdateSettings")
            net.WriteUInt( BYTES, 32 )
            net.WriteData( COMPRESS, BYTES )
        net.Send(P)
    end
end )

local DELAYS = {}

local function GetRank(P)
    local B, R = nil, nil
            
    if RDV.RANK then
        B = RDV.RANK.GetPlayerRankTree(P)
        R = RDV.RANK.GetPlayerRank(P)
    elseif MRS then
        B = MRS.GetPlayerGroup(P:Team())
        R = MRS.GetPlyRank(P, B)
    end

    return B, R
end

hook.Add("PlayerSay", "RDV_CHAT_COMMANDS_PlayerSay", function(P, TXT)
    if ( TXT == NCS_CHATCOMMANDS.CFG.command ) then
        NCS_CHATCOMMANDS.IsAdmin(P, function(ACCESS)
            if ACCESS then
                net.Start("RDV_CHAT_COMMANDS_ADMIN")
                net.Send(P)
            else
                NCS_SHARED.AddText(P, Color(255,0,0), "[COMMANDS] ", color_white, NCS_CHATCOMMANDS.GetLang(nil, "CHAT_noPerms"))
            end
        end )

        return ""
    end

    local SUB = string.Explode(" ", TXT)
    local CFG = NCS_CHATCOMMANDS.LIST

    if SUB[1] and CFG[SUB[1]] then
        DELAYS[P:SteamID64()] = DELAYS[P:SteamID64()] or {}

        if DELAYS[P:SteamID64()][SUB[1]] and DELAYS[P:SteamID64()][SUB[1]] > CurTime() then return "" end

        CFG = CFG[SUB[1]]

        DELAYS[P:SteamID64()][SUB[1]] = CurTime() + ( CFG.DELAY or 1 )

        if !CFG.LINK and #SUB <= 1 then return "" end

        if CFG.ALIVE and !P:Alive() then return "" end

        if CFG.DisWithRelay and RDV and RDV.COMMUNICATIONS and !RDV.COMMUNICATIONS.GetCommsEnabled(P) then
            NCS_SHARED.AddText(P, Color(255,0,0), "[COMMANDS] ", color_white, NCS_CHATCOMMANDS.GetLang(nil, "CHAT_relayDown"))

            return ""
        end

        local T_ENABLED = false
        local R_ENABLED = false

        if CFG.STEAMS and table.Count(CFG.STEAMS) >= 1 then
            T_ENABLED = true
        end

        if CFG.RANKS and table.Count(CFG.RANKS) >= 1 then
            R_ENABLED = true
        end

        if T_ENABLED and !CFG.STEAMS[team.GetName(P:Team())] then return "" end 

        if R_ENABLED then
            local B, R = GetRank(P)
    
            if CFG.RANKS[B] then
                if ( CFG.RANKS[B] > R ) then return "" end
            else
                return ""
            end
        end

        local FILTER = RecipientFilter()

        local MSG = table.concat(SUB, " ", 2)

        if CFG.LINK then
            FILTER:AddPlayer(P)
        else
            for k, v in ipairs(player.GetHumans()) do
                if !CFG.GLOBAL and v:GetPos():DistToSqr(P:GetPos()) > CFG.RADIUS then continue end

                NCS_CHATCOMMANDS.IsAdmin(v, function(ACCESS)
                    if CFG.NoTeamSee or ACCESS then
                        FILTER:AddPlayer(v)
                        return
                    end

                    if R_ENABLED then
                        local B, R = GetRank(v)
                
                        if CFG.RANKS[B] then
                            if ( CFG.RANKS[B] > R ) then return end
                        else
                            return
                        end
                    end

                    if T_ENABLED then
                        if CFG.STEAMS[team.GetName(v:Team())] then
                            FILTER:AddPlayer(v)
                        end
                    else
                        FILTER:AddPlayer(v)
                    end
                end )
            end
        end

        net.Start("RDV_CHAT_COMMANDS_SendMSG")
            net.WriteString(SUB[1])
            net.WriteString(MSG)
            net.WriteUInt(P:EntIndex(), 8)
        net.Send(FILTER)

        return ""
    end
end )

net.Receive("RDV_CHAT_COMMANDS_DELETE", function(_, P)
    NCS_CHATCOMMANDS.IsAdmin(P, function(ACCESS)
        if !ACCESS then return end

        local UID = net.ReadString()

        if NCS_CHATCOMMANDS.LIST and NCS_CHATCOMMANDS.LIST[UID] then
            NCS_CHATCOMMANDS.LIST[UID] = nil

            net.Start("RDV_CHAT_COMMANDS_DELETE")
                net.WriteString(UID)
            net.Broadcast()

            SAVE()
        end
    end )
end )

net.Receive("RDV_CHAT_COMMANDS_CREATE", function(_, P)
    NCS_CHATCOMMANDS.IsAdmin(P, function(ACCESS)
        if !ACCESS then return end

        --[[
        --  Read Data
        --]]

        local BYTES = net.ReadUInt( 16 )
        local DATA = net.ReadData(BYTES)

        local DECOMPRESSED = util.Decompress(DATA)
        local TAB = util.JSONToTable(DECOMPRESSED)

        TAB.CREATOR = P:SteamID64()
        TAB.COMMAND = string.lower(TAB.COMMAND)

        NCS_CHATCOMMANDS.LIST[TAB.COMMAND] = TAB

        --[[
        --  Send Data
        --]]

        local COMPRESS = util.Compress(util.TableToJSON(TAB))

        local BYTES = #COMPRESS

        net.Start("RDV_CHAT_COMMANDS_CREATE")
            net.WriteUInt( BYTES, 16 )
            net.WriteData( COMPRESS, BYTES )
        net.Broadcast()

        SAVE()
    end )
end )

local function ReadSettings()
    local DATA = file.Read("rdv/chat_commands/settings.json", "DATA")

    if DATA then
        DATA = util.JSONToTable(DATA)

        if !DATA then return end

        for k, v in pairs(DATA) do
            if NCS_CHATCOMMANDS.CFG[k] ~= nil then
                NCS_CHATCOMMANDS.CFG[k] = v
            end
        end
    end
end
ReadSettings()

local function SaveSettings()
    local DATA = NCS_CHATCOMMANDS.CFG

    if DATA then DATA = util.TableToJSON(DATA) end

    file.CreateDir("rdv/chat_commands")
    
    file.Write("rdv/chat_commands/settings.json", DATA)
end

util.AddNetworkString("NCS_CHATCOMMANDS_UpdateSettings")

net.Receive("NCS_CHATCOMMANDS_UpdateSettings", function(_, P)
    NCS_CHATCOMMANDS.IsAdmin(P, function(ACCESS)
        if !ACCESS then SendNotification(P, NCS_CHATCOMMANDS.GetLang(nil, "noPermsAccess")) return end

        local length = net.ReadUInt(32)
        local data = net.ReadData(length)
        local uncompressed = util.Decompress(data)

        if (!uncompressed) then
            return
        end

        local D = util.JSONToTable(uncompressed)

        for k, v in pairs(D) do
            if ( NCS_CHATCOMMANDS.CFG[k] ~= nil ) then
                NCS_CHATCOMMANDS.CFG[k] = v
            end
        end

        if !D.admins["superadmin"] then
            D.admins["superadmin"] = "World"
        end

        local json = util.TableToJSON(D)
        local compressed = util.Compress(json)
        local length = compressed:len()

        net.Start("NCS_CHATCOMMANDS_UpdateSettings")
            net.WriteUInt(length, 32)
            net.WriteData(compressed, length)
        net.Broadcast()

        SaveSettings()

        SendNotification(P, NCS_CHATCOMMANDS.GetLang(nil, "savedSettings"))
    end )
end )
