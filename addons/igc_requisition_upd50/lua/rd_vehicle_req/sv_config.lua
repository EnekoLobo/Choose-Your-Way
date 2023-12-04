util.AddNetworkString("RDV_REQUISITION_ADMIN")
util.AddNetworkString("RDV_REQUISITION_AddSpawn")
util.AddNetworkString("RDV_REQUISITION_AddVehicle")
util.AddNetworkString("RDV_REQUISITION_BatchSend")
util.AddNetworkString("RDV_REQUISITION_SaveSettings")
util.AddNetworkString("RDV_VR_RetrieveModel")

local function SendNotification(P, MSG)
    local PREFIX = RDV.VEHICLE_REQ.CFG.PRE_STRING
    local COL = RDV.VEHICLE_REQ.CFG.PRE_COLOR

    RDV.LIBRARY.AddText(P, Color(COL.r, COL.g, COL.b), "["..PREFIX.."] ", color_white, MSG)
end

local OVERFLOW = {}
net.Receive("RDV_VR_RetrieveModel", function(_, P)
    if OVERFLOW[P] and OVERFLOW[P] > CurTime() then return end

    local CLASS = net.ReadString()

    local F_ENT

    if simfphys and list.Get( "simfphys_vehicles" )[CLASS] then
        F_ENT = simfphys.SpawnVehicleSimple( CLASS, Vector(0,0,0), Angle(0,0,0) )
    elseif list.Get("Vehicles")[CLASS] then
        local D = list.Get("Vehicles")[CLASS]

        if !D.Class or !D.Model then return end

        F_ENT = ents.Create(D.Class)
        F_ENT:SetModel(D.Model)
        F_ENT:Spawn()
    else
        F_ENT = ents.Create(CLASS) -- Get the Model of the Vehicle!
        F_ENT:Spawn()
    end

    local MODEL = F_ENT:GetModel()
    
    F_ENT:Remove()

    net.Start("RDV_VR_RetrieveModel")
        net.WriteString(MODEL)
    net.Send(P)
    
    OVERFLOW[P] = CurTime() + 1
end )

net.Receive("RDV_REQUISITION_SaveSettings", function(_, P)
    if !RDV.VEHICLE_REQ.CFG.Admins[P:GetUserGroup()] then return end

    local LEN = net.ReadUInt(32)
    local DATA = net.ReadData(LEN)

    local DECOMP = util.JSONToTable(util.Decompress(DATA))
    
    RDV.VEHICLE_REQ.CFG = DECOMP

    local S_PATH = "rdv/requisition/settings.json"
    
    file.Write(S_PATH, util.TableToJSON(DECOMP))

    local S_COMPRESS = util.Compress(util.TableToJSON(RDV.VEHICLE_REQ.CFG))
    local S_BYTES = #S_COMPRESS

    net.Start("RDV_REQUISITION_SaveSettings")
        net.WriteUInt(LEN, 32)
        net.WriteData(DATA, LEN)
    net.Send(P)
end )

hook.Add("PlayerSay", "RDV_REQUISITION_ADMIN", function(P, TXT)
    if string.lower(TXT) == "!vconfig" then
        if !RDV.VEHICLE_REQ.CFG.Admins[P:GetUserGroup()] then return "" end

        net.Start("RDV_REQUISITION_ADMIN")
        net.Send(P)
        return ""
    elseif string.lower(TXT) == "!vsave" then
        if !RDV.VEHICLE_REQ.CFG.Admins[P:GetUserGroup()] then return "" end

        local SAVE = {}

        for k, v in ipairs(ents.GetAll()) do
            if v:GetClass() == "eps_aircraft_npc" then
                table.insert(SAVE, {P = v:GetPos(), A = v:GetAngles()})
            end
        end

        local JSON = util.TableToJSON(SAVE)

        file.CreateDir("rdv/requisition/")
        file.Write("rdv/requisition/vendors_"..game.GetMap()..".json", JSON)

        SendNotification(P, RDV.LIBRARY.GetLang(nil, "VR_CFG_savedVendors"))
        
        RDV.LIBRARY.PlaySound(P, "reality_development/ui/ui_accept.ogg")
        return ""
    end
end )

hook.Add("PlayerReadyForNetworking", "RDV_REQUISITION_SendStuff", function(P)
    -- Vehicles
    
    RDV.VEHICLE_REQ.VEHICLES = RDV.VEHICLE_REQ.VEHICLES or {}

    local V_COMPRESS = util.Compress(util.TableToJSON(RDV.VEHICLE_REQ.VEHICLES))
    local V_BYTES = #V_COMPRESS

    -- Spawns

    RDV.VEHICLE_REQ.SPAWNS = RDV.VEHICLE_REQ.SPAWNS or {}

    local H_COMPRESS = util.Compress(util.TableToJSON(RDV.VEHICLE_REQ.SPAWNS))
    local H_BYTES = #H_COMPRESS

    net.Start("RDV_REQUISITION_BatchSend")
        net.WriteUInt(V_BYTES, 32)
        net.WriteData(V_COMPRESS, V_BYTES)
        net.WriteUInt(H_BYTES, 32)
        net.WriteData(H_COMPRESS, H_BYTES)
    net.Send(P)

    local S_COMPRESS = util.Compress(util.TableToJSON(RDV.VEHICLE_REQ.CFG))
    local S_BYTES = #S_COMPRESS

    net.Start("RDV_REQUISITION_SaveSettings")
        net.WriteUInt(S_BYTES, 32)
        net.WriteData(S_COMPRESS, S_BYTES)
    net.Send(P)
end )

local function ReadData()
    local PATH = "rdv/requisition/spawns/"..game.GetMap()..".json"

    if file.Exists(PATH, "DATA") then
        local TXT = file.Read(PATH, "DATA")

        if !TXT then return end

        local TBL = util.JSONToTable(TXT)

        for k, v in pairs(TBL) do
            if !v.UID then
                TBL[k] = nil
            end

            local DATA = TBL[k]

            for k, v in pairs(RDV.VEHICLE_REQ.DF_SPAWN) do
                if ( DATA[k] == nil ) then DATA[k] = v end
            end
        end

        RDV.VEHICLE_REQ.SPAWNS = TBL
    end

    local V_PATH = "rdv/requisition/vehicles.json"

    if file.Exists("rdv/requisition/", "DATA") then
        local TXT = file.Read(V_PATH, "DATA")

        if !TXT then return end

        local TBL = util.JSONToTable(TXT)

        for k, v in pairs(TBL) do
            if !v.UID then
                TBL[k] = nil
            end

            local DATA = TBL[k]

            for k, v in pairs(RDV.VEHICLE_REQ.DF_VEHICLE) do
                if ( DATA[k] == nil ) then DATA[k] = v end
            end
        end

        RDV.VEHICLE_REQ.VEHICLES = TBL
    end

    local S_PATH = "rdv/requisition/settings.json"

    if file.Exists(S_PATH, "DATA") then
        local TXT = file.Read(S_PATH, "DATA")

        if !TXT then return end

        local TBL = util.JSONToTable(TXT)

        for k, v in pairs(TBL) do
            if ( RDV.VEHICLE_REQ.CFG[k] ~= nil ) then
                RDV.VEHICLE_REQ.CFG[k] = v
            end
        end
    end

    MsgC(Color(255,0,0), "[Requisition]", color_white, " Reading Saved Data!\n")
end
ReadData()

local function SaveData()
    -- Spawns

    local PATH = "rdv/requisition/spawns/"..game.GetMap()..".json"
    
    file.CreateDir("rdv/requisition/spawns/")

    file.Write(PATH, util.TableToJSON(RDV.VEHICLE_REQ.SPAWNS))

    local V_PATH = "rdv/requisition/vehicles.json"
    
    file.Write(V_PATH, util.TableToJSON(RDV.VEHICLE_REQ.VEHICLES))
end

net.Receive("RDV_REQUISITION_AddSpawn", function(_, P)
    if !RDV.VEHICLE_REQ.CFG.Admins[P:GetUserGroup()] then return end

    local LEN = net.ReadUInt(32)
    local DATA = net.ReadData(LEN)

    local UID = ( os.time().."_"..P:EntIndex() )

    local DECOMP = util.JSONToTable(util.Decompress(DATA))

    if !DECOMP.CREATOR then
        DECOMP.CREATOR = P:SteamID64()
    end

    if !DECOMP.UID then
        DECOMP.UID = UID
    else
        UID = DECOMP.UID
    end

    if DECOMP.RTEAMS and table.Count(DECOMP.RTEAMS) <= 0 then
        DECOMP.RTEAMS = nil
    end

    if DECOMP.GTEAMS and table.Count(DECOMP.GTEAMS) <= 0 then
        DECOMP.GTEAMS = nil
    end

    DECOMP.MAP = game.GetMap()

    RDV.VEHICLE_REQ.SPAWNS[UID] = DECOMP

    local COMPRESS = util.Compress(util.TableToJSON(DECOMP))
    local BYTES = #COMPRESS

    net.Start("RDV_REQUISITION_AddSpawn")
        net.WriteUInt(BYTES, 32)
        net.WriteData(COMPRESS, BYTES)
    net.Broadcast()

    SaveData()
end )

util.AddNetworkString("RDV_REQUISITION_DelSpawn")

net.Receive("RDV_REQUISITION_DelSpawn", function(_, P)
    if !RDV.VEHICLE_REQ.CFG.Admins[P:GetUserGroup()] then return end

    local UID = net.ReadString()

    if RDV.VEHICLE_REQ.SPAWNS[UID] then
        RDV.VEHICLE_REQ.SPAWNS[UID] = nil
    end

    net.Start("RDV_REQUISITION_DelSpawn")
        net.WriteString(UID)
    net.Broadcast()

    SaveData()
end )


--[[
--  Vehicles
--]]

net.Receive("RDV_REQUISITION_AddVehicle", function(_, P)
    if !RDV.VEHICLE_REQ.CFG.Admins[P:GetUserGroup()] then return end

    local LEN = net.ReadUInt(32)
    local DATA = net.ReadData(LEN)

    local UID = ( os.time().."_"..P:EntIndex() )

    local DECOMP = util.JSONToTable(util.Decompress(DATA))

    if DECOMP.LOADOUTS then
        for k, v in pairs(DECOMP.LOADOUTS) do
            if !v.NAME or v.NAME == "" then
                return
            end
        end
    end

    if DECOMP.PRICE then
        DECOMP.PRICE = tonumber(DECOMP.PRICE)
    end

    if DECOMP.MAX then
        DECOMP.MAX = tonumber(DECOMP.MAX)

        if DECOMP.MAX and DECOMP.MAX <= 0 then
            DECOMP.MAX = nil
        end
    end

    if !DECOMP.CREATOR then
        DECOMP.CREATOR = P:SteamID64()
    end
    
    if DECOMP.SKIN then
        DECOMP.SKIN = tonumber(DECOMP.SKIN)
    end

    if !DECOMP.UID then
        DECOMP.UID = UID
    else
        UID = DECOMP.UID
    end

    if DECOMP.RTEAMS and table.Count(DECOMP.RTEAMS) <= 0 then
        DECOMP.RTEAMS = nil
    end

    if DECOMP.GTEAMS and table.Count(DECOMP.GTEAMS) <= 0 then
        DECOMP.GTEAMS = nil
    end

    local F_ENT

    if simfphys and list.Get( "simfphys_vehicles" )[DECOMP.CLASS] then
        F_ENT = simfphys.SpawnVehicleSimple( DECOMP.CLASS, Vector(0,0,0), Angle(0,0,0) )
    elseif list.Get("Vehicles")[DECOMP.CLASS] then
        local D = list.Get("Vehicles")[DECOMP.CLASS]

        if !D.Class or !D.Model then return end
        
        F_ENT = ents.Create(D.Class)
        F_ENT:SetModel(D.Model)
        F_ENT:Spawn()
    else
        F_ENT = ents.Create(DECOMP.CLASS) -- Get the Model of the Vehicle!
        F_ENT:Spawn()
    end

    local MODEL = F_ENT:GetModel()

    DECOMP.MODEL = MODEL
    
    F_ENT:Remove()

    RDV.VEHICLE_REQ.VEHICLES[UID] = DECOMP

    local COMPRESS = util.Compress(util.TableToJSON(DECOMP))
    local BYTES = #COMPRESS

    net.Start("RDV_REQUISITION_AddVehicle")
        net.WriteUInt(BYTES, 32)
        net.WriteData(COMPRESS, BYTES)
    net.Broadcast()

    SaveData()
end )

util.AddNetworkString("RDV_RDV_REQUISITION_DelVehicle")
net.Receive("RDV_RDV_REQUISITION_DelVehicle", function(_, P)
    if !RDV.VEHICLE_REQ.CFG.Admins[P:GetUserGroup()] then return end

    local UID = net.ReadString()

    if RDV.VEHICLE_REQ.VEHICLES[UID] then
        RDV.VEHICLE_REQ.VEHICLES[UID] = nil
    end

    net.Start("RDV_RDV_REQUISITION_DelVehicle")
        net.WriteString(UID)
    net.Broadcast()

    SaveData()
end )


local function ReadVendors()
    if file.Exists("rdv/requisition/vendors_"..game.GetMap()..".json", "DATA") then
        local TXT = file.Read("rdv/requisition/vendors_"..game.GetMap()..".json", "DATA")

        if !TXT then return end

        local TBL = util.JSONToTable(TXT)

        for k, v in ipairs(TBL) do
            local E = ents.Create("eps_aircraft_npc")
            E:SetPos(v.P)
            E:SetAngles(v.A)
            E:Spawn()

            E:SetMoveType(MOVETYPE_NONE)
            local P = E:GetPhysicsObject()
            if IsValid(P) then
                P:EnableMotion(false)
            end
        end
    end
end
ReadVendors()

hook.Add("PostCleanupMap", "RDV_VR_VENDORS", function()
    ReadVendors()
end )