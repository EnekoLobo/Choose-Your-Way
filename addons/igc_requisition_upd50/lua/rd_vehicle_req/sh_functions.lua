--[[---------------------------------]]--
--  Granting a Vehicle
--[[---------------------------------]]--

function RDV.VEHICLE_REQ.CanGrant(ply, ship, hangar)
    local HANG = RDV.VEHICLE_REQ.SPAWNS[hangar]
    local VEH = RDV.VEHICLE_REQ.VEHICLES[ship]

    --[[
    --  Vehicles
    --]]

    local SUCCESS = hook.Run("RDV_VR_CanGrant", ply, ship, hangar)

    if (SUCCESS ~= nil) then
        return SUCCESS
    end
        
    if VEH.GTEAMS and !table.IsEmpty(VEH.GTEAMS) and !VEH.GTEAMS[team.GetName(ply:Team())] then
        return false
    end

    local B, R = nil, nil

    if RDV.RANK then
        B = RDV.RANK.GetPlayerRankTree(ply)
        R = RDV.RANK.GetPlayerRank(ply)
    elseif MRS then
        B = MRS.GetPlayerGroup(ply:Team())
        R = MRS.GetPlyRank(ply, B)
    end

    if VEH.GRANKS and table.Count(VEH.GRANKS) > 0 then
        if VEH.GRANKS[B] then
            if ( VEH.GRANKS[B] > R ) then return false end
        else
            return
        end
    end

    if VEH.CanGrant and VEH:CanGrant(ply) == false then
        return false
    end


    --[[
    --  Hangars
    --]]

    if HANG.GTEAMS and !table.IsEmpty(VEH.GTEAMS) and !HANG.GTEAMS[team.GetName(ply:Team())] then
        return false
    end

    if HANG.GRANKS and table.Count(HANG.GRANKS) > 0 then
        if HANG.GRANKS[B] then
            if ( HANG.GRANKS[B] > R ) then return false end
        else
            return
        end
    end

    if HANG.CanGrant and HANG:CanGrant(ply) == false then

        return false
    end

    return true
end

--[[---------------------------------]]--
--  Requesting a Vehicle
--[[---------------------------------]]--

function RDV.VEHICLE_REQ.CanRequest(ply, ship, hangar)
    local HANG = RDV.VEHICLE_REQ.SPAWNS[hangar]
    local VEH = RDV.VEHICLE_REQ.VEHICLES[ship]

    --[[
    --  Vehicles
    --]]
    
    local SUCCESS = hook.Run("RDV_VR_CanRequest", ply, ship, hangar)

    if (SUCCESS ~= nil) then
        return SUCCESS
    end

    if VEH.RTEAMS and !table.IsEmpty(VEH.RTEAMS) and !VEH.RTEAMS[team.GetName(ply:Team())] then
        return false
    end

    local B, R = nil, nil

    if RDV.RANK then
        B = RDV.RANK.GetPlayerRankTree(ply)
        R = RDV.RANK.GetPlayerRank(ply)
    elseif MRS then
        B = MRS.GetPlayerGroup(ply:Team())
        R = MRS.GetPlyRank(ply, B)
    end

    if VEH.RANKS and table.Count(VEH.RANKS) > 0 then
        if VEH.RANKS[B] then
            if ( VEH.RANKS[B] > R ) then return false end
        else
            return
        end
    end

    if VEH.CanRequest and VEH:CanRequest(ply) == false then
        return false
    end

    --[[
    --  Hangars
    --]]

    if VEH.SPAWNS and not table.IsEmpty(VEH.SPAWNS) then
        if not VEH.SPAWNS[hangar] then
            return false
        end
    end


    if HANG.RTEAMS and !table.IsEmpty(HANG.RTEAMS) and !HANG.RTEAMS[team.GetName(ply:Team())] then
        return false
    end

    if HANG.RANKS and table.Count(HANG.RANKS) > 0 then
        if HANG.RANKS[B] then
            if ( HANG.RANKS[B] > R ) then return false end
        else
            return
        end
    end

    if HANG.CanRequest and HANG:CanRequest(ply) == false then
        return false
    end

    if VEH.PRICE then
        if not RDV.LIBRARY.CanAfford(ply, nil, VEH.PRICE) then
            return false
        end
    end
        
    return true
end

--[[---------------------------------]]--
--  Checking if a Hangar is clear.
--[[---------------------------------]]--

function RDV.VEHICLE_REQ.IsHangarInUse(hangar)
    local LOC = RDV.VEHICLE_REQ.SPAWNS[hangar]

    if !LOC then 
        return 
    end

    local FOUND = false

    for k, v in ipairs(ents.GetAll()) do
        if v:GetPos():DistToSqr(LOC.POS) <= (RDV.VEHICLE_REQ.CFG.HAN_SIZE ^ 2) then
            if v:IsVehicle() or v:IsNPC() or v:IsNextBot() or v:IsPlayer() then
                FOUND = true
            end
        end
    end

    return FOUND
end

--[[---------------------------------]]--
--  Notification
--[[---------------------------------]]--

function RDV.VEHICLE_REQ.SendNotification(PLAYER, MSG)
    local PREFIX = RDV.VEHICLE_REQ.CFG.PRE_STRING
    local COL = RDV.VEHICLE_REQ.CFG.PRE_COLOR

    RDV.LIBRARY.AddText(PLAYER, Color(COL.r, COL.g, COL.b), "["..PREFIX.."] ", color_white, MSG)
end