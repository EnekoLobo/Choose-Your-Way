util.AddNetworkString("RDV.VEHICLE_REQ.GRANT")
util.AddNetworkString("RDV_VR_CLEAR")
util.AddNetworkString("RDV.VEHICLE_REQ.DENY")
util.AddNetworkString("RDV.VEHICLE_REQ.MENU")
util.AddNetworkString("RDV.VEHICLE_REQ.START")
util.AddNetworkString("RDV_VR_ASK")
util.AddNetworkString("RDV.VEHICLE_REQ.RETURN")
util.AddNetworkString("RDV_VR_INITIAL")

RDV.VEHICLE_REQ.ACTIVE = {}

local vehTable = {}
local curVehicleCount = 0

--[[---------------------------------]]--
--  Requsition Request Received
--[[---------------------------------]]--

hook.Add("EntityRemoved", "RDV.REQUISITION.REMOVED", function(ent)
    if ent.ReqUID and vehTable[ent.ReqUID] then
        vehTable[ent.ReqUID] = ( vehTable[ent.ReqUID] - 1 )

        curVehicleCount = math.max((curVehicleCount - 1), 0)
    end
end )

local function SpawnVehicle(P, VEH_UID, H_TAB, V_TAB)
    vehTable[VEH_UID] = vehTable[VEH_UID] or 0

    if IsValid(P.CurrentRequestedVehicle) then
        P.CurrentRequestedVehicle:Remove()
    end

    local TAB = RDV.VEHICLE_REQ.ACTIVE[P:EntIndex()]
    local CFG = RDV.VEHICLE_REQ.CFG

    local VAL = hook.Run("RDV_VR_PreVehicleSpawned", P, TAB)

    if (VAL == false) then
        return
    end

    -- Check Details, like Max Vehicle Count.
    local DATA = RDV.VEHICLE_REQ.VEHICLES[VEH_UID]

    if DATA.MAX and ( DATA.MAX > 0 ) and ( vehTable[VEH_UID] + 1 ) > DATA.MAX then
        RDV.VEHICLE_REQ.SendNotification(P, RDV.LIBRARY.GetLang(nil, "VR_tooManyVehicles"))

        return
    end

    if curVehicleCount and CFG.MAX_VEH and ( CFG.MAX_VEH > 0 ) and ( ( curVehicleCount + 1 ) > CFG.MAX_VEH ) then
        RDV.VEHICLE_REQ.SendNotification(P, RDV.LIBRARY.GetLang(nil, "VR_tooManyVehicles"))

        return
    end

    -- Spawn the vehicle, supports Simphys too.

    local VEH_ENT

    if simfphys and list.Get( "simfphys_vehicles" )[V_TAB.CLASS] then
        VEH_ENT = simfphys.SpawnVehicleSimple( V_TAB.CLASS, H_TAB.POS, H_TAB.ANG )
    elseif list.Get("Vehicles")[V_TAB.CLASS] then
        local D = list.Get("Vehicles")[V_TAB.CLASS]

        if !D.Class or !D.Model then return end

        VEH_ENT = ents.Create(D.Class)
        VEH_ENT:SetModel(D.Model)
        VEH_ENT:SetPos(H_TAB.POS)

        VEH_ENT:SetKeyValue("vehiclescript",list.Get( "Vehicles" )[ V_TAB.CLASS ].KeyValues.vehiclescript) 
        VEH_ENT:SetAngles(H_TAB.ANG)

        VEH_ENT:Spawn()
        VEH_ENT:Activate()
    else
        VEH_ENT = ents.Create(V_TAB.CLASS)
        VEH_ENT:SetPos(H_TAB.POS)
        VEH_ENT:SetAngles(H_TAB.ANG)
        VEH_ENT:Spawn()
    end

    if TAB.SKIN then
        VEH_ENT:SetSkin(TAB.SKIN)
    end

    if V_TAB.LOADOUTS and V_TAB.LOADOUTS[TAB.LOADOUT] then
        local DATA = V_TAB.LOADOUTS[TAB.LOADOUT].OPTIONS

        if DATA then
            for k, v in ipairs(VEH_ENT:GetBodyGroups()) do
                if DATA[v.id] then
                    VEH_ENT:SetBodygroup(v.id, DATA[v.id])
                end
            end
        end
    end

    vehTable[VEH_UID] = vehTable[VEH_UID] + 1
    curVehicleCount = curVehicleCount + 1

    VEH_ENT.ReqUID = VEH_UID

    if !IsValid(VEH_ENT) then return end

    if VEH_ENT.CPPISetOwner then
        VEH_ENT:CPPISetOwner(P)
    end

    P.CurrentRequestedVehicle = VEH_ENT

    hook.Run("RDV_VR_VehicleSpawned", P, VEH_ENT, TAB)
end

local function AutoGrant(R_PLAYER, SHIP, H_TAB, V_TAB)
    local ACTIVE = RDV.VEHICLE_REQ.ACTIVE[R_PLAYER:EntIndex()]

    if V_TAB.PRICE then
        local canAfford = RDV.LIBRARY.CanAfford(R_PLAYER, nil, V_TAB.PRICE)

        if ( !canAfford ) then
            local LcannotAfford = RDV.LIBRARY.GetLang(nil, "VR_cannotAfford")

            RDV.VEHICLE_REQ.SendNotification(R_PLAYER, LcannotAfford)

            RDV.VEHICLE_REQ.ACTIVE[R_PLAYER:EntIndex()] = nil

            return false
        end

        RDV.LIBRARY.AddMoney(R_PLAYER, nil, -V_TAB.PRICE)
    end
    
    SpawnVehicle(R_PLAYER, SHIP, H_TAB, V_TAB)

    local LautoGranted = RDV.LIBRARY.GetLang(nil, "VR_autoGranted")

    RDV.VEHICLE_REQ.SendNotification(R_PLAYER, LautoGranted)

    RDV.LIBRARY.PlaySound(R_PLAYER, "reality_development/ui/ui_accept.ogg")

    -- Remove
    timer.Stop("VR_"..R_PLAYER:SteamID64())

    RDV.VEHICLE_REQ.ACTIVE[R_PLAYER:EntIndex()] = nil
end

net.Receive("RDV.VEHICLE_REQ.START", function(len, P)
    local V_UID = net.ReadString()
    local H_UID = net.ReadString()
    local V_INFO = net.ReadTable()

    local H_TAB = RDV.VEHICLE_REQ.SPAWNS[H_UID]
    local V_TAB = RDV.VEHICLE_REQ.VEHICLES[V_UID]

    if H_TAB and V_TAB then
        local DATA = RDV.VEHICLE_REQ.VEHICLES[V_UID]
        local CFG = RDV.VEHICLE_REQ.CFG

        if DATA.MAX and ( DATA.MAX > 0 ) and vehTable[V_UID] and ( vehTable[V_UID] + 1 ) > DATA.MAX then
            RDV.VEHICLE_REQ.SendNotification(P, RDV.LIBRARY.GetLang(nil, "VR_tooManyVehicles"))

            return
        end

        if curVehicleCount and CFG.MAX_VEH and ( CFG.MAX_VEH > 0 ) and ( ( curVehicleCount + 1 ) > CFG.MAX_VEH ) then
            RDV.VEHICLE_REQ.SendNotification(P, RDV.LIBRARY.GetLang(nil, "VR_tooManyVehicles"))
    
            return
        end

        --
        --  Handle Map Check
        --

        if H_TAB.MAP and H_TAB.MAP ~= game.GetMap() then
            return
        end

        --
        --  Handle Distance Check
        --

        local POS = H_TAB.POS

        if RDV.VEHICLE_REQ.CFG.MAX_DIST then
            local DISTANCE = (string.Explode(".", POS:Distance(P:GetPos()) / 52.49))[1]

            if tonumber(DISTANCE) >= (RDV.VEHICLE_REQ.CFG.MAX_DIST or 500) then
                return
            end
        end

        --
        --  Handle Blacklists
        --
        if V_TAB.SPAWNS and !table.IsEmpty(V_TAB.SPAWNS) then
            if !V_TAB.SPAWNS[H_UID] then 
                return 
            end
        end

        --
        --  Handle Skins
        --

        local SKIN = 0

        if V_INFO.SKIN then
            SKIN = V_INFO.SKIN
        elseif V_TAB.SKIN then
            SKIN = V_TAB.SKIN
        end
        
        --
        --  Handle Loadouts
        --

        local LOADOUT = false

        if V_INFO.LOADOUT then
            LOADOUT = V_INFO.LOADOUT
        end

        --
        --  Handle Active Requests
        --

        if RDV.VEHICLE_REQ.ACTIVE and RDV.VEHICLE_REQ.ACTIVE[P:EntIndex()] then
            local LrequestOpen = RDV.LIBRARY.GetLang(nil, "VR_requestOpen")

            RDV.VEHICLE_REQ.SendNotification(P, LrequestOpen)

            return
        end

        --
        --  Handle Checking Availability
        --

        local CAN_REQUEST, REASON = RDV.VEHICLE_REQ.CanRequest(P, V_UID, H_UID)

        if (CAN_REQUEST == false) then
            local cannotRequest = RDV.LIBRARY.GetLang(nil, "VR_cannotRequest")

            RDV.VEHICLE_REQ.SendNotification(P, (REASON or cannotRequest))
            return
        end
        
        --
        --  Handle Hangar in use
        --

        if RDV.VEHICLE_REQ.IsHangarInUse(H_UID) then
            local hangarOccupied = RDV.LIBRARY.GetLang(nil, "VR_hangarOccupied")

            RDV.VEHICLE_REQ.SendNotification(P, hangarOccupied)
            return 
        end

        --
        --  Create Request
        --

        if !TIME then TIME = ( RDV.VEHICLE_REQ.CFG.DEN_TIME or 60 ) end
    
        timer.Create("VR_"..P:SteamID64(), TIME, 1, function()
            if RDV.VEHICLE_REQ.ACTIVE[P:EntIndex()] then
                RDV.VEHICLE_REQ.ACTIVE[P:EntIndex()] = nil
            end
        end )

        RDV.VEHICLE_REQ.ACTIVE[P:EntIndex()] = {
            VEHICLE = V_UID,
            SPAWN = H_UID,
            OWNER = P,
            SKIN = (SKIN or 0),
            LOADOUT = LOADOUT,
        }
        
        --
        --  Request or Auto Grant
        --
        
        if ( V_TAB.AutoGrant and RDV.VEHICLE_REQ.CanGrant(P, V_UID, H_UID) ) then
            AutoGrant(P, V_UID, H_TAB, V_TAB)

            return
        end
        
        if V_TAB.REQUEST then
            --
            --  Create Filter and Network
            --

            local COUNT = 0

            local FILTER = RecipientFilter()

            for k, v in ipairs(player.GetAll()) do
                if ( v == P ) and !RDV.VEHICLE_REQ.CFG.SG_PERM then
                    continue
                end

                if RDV.VEHICLE_REQ.CanGrant(v, V_UID, H_UID) then
                    COUNT = COUNT + 1

                    FILTER:AddPlayer(v)
                end
            end

            if COUNT <= 0 and ( V_TAB.SpawnAlone == true ) then
                AutoGrant(P, V_UID, H_TAB, V_TAB)
            elseif COUNT >= 1 then
                net.Start("RDV_VR_ASK")
                    net.WriteString(V_UID)
                    net.WriteString(H_UID)
                    net.WriteUInt(P:EntIndex(), 8)
                net.Send(FILTER)
            end

            local NAME = ( V_TAB.NAME or V_UID )
            
            local startedRequest = RDV.LIBRARY.GetLang(nil, "VR_startedRequest", {
                NAME,
            })

            RDV.VEHICLE_REQ.SendNotification(P, startedRequest)
        else

            --
            --  Auto Grant
            --

            AutoGrant(P, V_UID, H_TAB, V_TAB)
        end
    end
end)

--[[---------------------------------]]--
--  Requisition Request Granted
--[[---------------------------------]]--

net.Receive("RDV.VEHICLE_REQ.GRANT", function(_, G_PLAYER)
    local E_INDEX = net.ReadUInt(8)
    local R_PLAYER = Entity(E_INDEX)

    if !IsValid(R_PLAYER) then
        return
    end
    
    if ( R_PLAYER == G_PLAYER ) and !RDV.VEHICLE_REQ.CFG.SG_PERM then
        return
    end

    local tab = RDV.VEHICLE_REQ.ACTIVE[E_INDEX]
    local SEQ = tab.SEQUENTIAL

    local V_TAB = RDV.VEHICLE_REQ.VEHICLES[tab.VEHICLE]
    local H_TAB = RDV.VEHICLE_REQ.SPAWNS[tab.SPAWN]

    if not V_TAB then
        return
    end

    if tab and RDV.VEHICLE_REQ.CanGrant(G_PLAYER, tab.VEHICLE, tab.SPAWN) then
        local spawn_pos = H_TAB.POS
        local SHIP_NAME = RDV.VEHICLE_REQ.VEHICLES[tab.VEHICLE].NAME

        net.Start("RDV_VR_CLEAR")
            net.WriteUInt(E_INDEX, 8)
        net.Broadcast()

        if V_TAB.PRICE then
            if not RDV.LIBRARY.CanAfford(R_PLAYER, nil, V_TAB.PRICE) then
                local LcannotAfford = RDV.LIBRARY.GetLang(nil, "VR_cannotAfford")

                RDV.VEHICLE_REQ.SendNotification(R_PLAYER, LcannotAfford)

                RDV.VEHICLE_REQ.ACTIVE[E_INDEX] = nil


                return false
            end
                
            RDV.LIBRARY.AddMoney(R_PLAYER, nil, -V_TAB.PRICE)
        end

        SpawnVehicle(R_PLAYER, tab.VEHICLE, H_TAB, V_TAB)

        RDV.VEHICLE_REQ.ACTIVE[E_INDEX] = nil


        timer.Stop("VR_"..R_PLAYER:SteamID64())

        if R_PLAYER ~= G_PLAYER then
            local spawnAccRequester = RDV.LIBRARY.GetLang(nil, "VR_spawnAccRequester", {
                SHIP_NAME,
                G_PLAYER:Name(),
            })

            RDV.VEHICLE_REQ.SendNotification(R_PLAYER, spawnAccRequester)

            local spawnAccRequester = RDV.LIBRARY.GetLang(nil, "VR_spawnAccAccepter", {
                SHIP_NAME,
                R_PLAYER:Name(),
            })

            RDV.VEHICLE_REQ.SendNotification(G_PLAYER, spawnAccAccepter)
        else
            local spawnAccSelf = RDV.LIBRARY.GetLang(nil, "VR_spawnAccSelf", {
                SHIP_NAME,
            })

            RDV.VEHICLE_REQ.SendNotification(G_PLAYER, spawnAccSelf)
        end

        RDV.LIBRARY.PlaySound(R_PLAYER, "reality_development/ui/ui_accept.ogg")

        hook.Run("RDV_VR_RequestGranted", R_PLAYER, G_PLAYER, tab)
    end
end)

--[[---------------------------------]]--
--  Requsition Request Denied
--[[---------------------------------]]--

net.Receive("RDV.VEHICLE_REQ.DENY", function(len, P)
    local E_INDEX = net.ReadUInt(8)

    local NPLAYER = Entity(E_INDEX)

    if !IsValid(NPLAYER) then
        return
    end

    if ( NPLAYER == P ) and !RDV.VEHICLE_REQ.CFG.SG_PERM then
        return
    end
    
    local R_TAB = RDV.VEHICLE_REQ.ACTIVE[E_INDEX]

    if R_TAB and RDV.VEHICLE_REQ.CanGrant(P, R_TAB.VEHICLE, R_TAB.SPAWN) ~= false then
        local SHIP_NAME = RDV.VEHICLE_REQ.VEHICLES[R_TAB.VEHICLE].NAME

        net.Start("RDV_VR_CLEAR")
            net.WriteUInt(E_INDEX, 8)
        net.Broadcast()

        RDV.VEHICLE_REQ.ACTIVE[E_INDEX] = nil


        if NPLAYER ~= P then
            local spawnDenRequester = RDV.LIBRARY.GetLang(nil, "VR_spawnDenRequester", {
                SHIP_NAME,
                P:Name(),
            })

            RDV.VEHICLE_REQ.SendNotification(NPLAYER, spawnDenRequester)

            local spawnDenDenier = RDV.LIBRARY.GetLang(nil, "VR_spawnDenDenier", {
                SHIP_NAME,
                NPLAYER:Name(),
            })

            RDV.VEHICLE_REQ.SendNotification(P, spawnDenDenier)
        else   
            local spawnDenSelf = RDV.LIBRARY.GetLang(nil, "VR_spawnDenSelf", {
                SHIP_NAME,
            })

            RDV.VEHICLE_REQ.SendNotification(P, spawnDenSelf)
        end

        RDV.LIBRARY.PlaySound(NPLAYER, "reality_development/ui/ui_denied.ogg")

        hook.Run("RDV_VR_RequestDenied", NPLAYER, P, R_TAB)
    end
end)

net.Receive("RDV.VEHICLE_REQ.RETURN", function(len, P)
    local VEHICLE = P.CurrentRequestedVehicle

    if VEHICLE and IsValid(VEHICLE) then
        local CLASS = VEHICLE:GetClass()

        hook.Run("RDV_VR_PreVehicleReturn", P, VEHICLE)

        VEHICLE:Remove()

        local returnedVehicle = RDV.LIBRARY.GetLang(nil, "VR_returnedVehicle")

        RDV.VEHICLE_REQ.SendNotification(P, returnedVehicle)

        hook.Run("RDV_VR_PostVehicleReturn", P, CLASS)
    else
        local noCurrentVehicle = RDV.LIBRARY.GetLang(nil, "VR_noCurrentVehicle")

        RDV.VEHICLE_REQ.SendNotification(P, noCurrentVehicle)
    end
end)