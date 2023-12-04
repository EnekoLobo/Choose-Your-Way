hook.Add("PlayerReadyForNetworking", "RDV_VR_RetrieveRequests", function(P)
    local DATA = {}

    for k, v in pairs(RDV.VEHICLE_REQ.ACTIVE) do
        local R_PLAYER = v.OWNER

        if !IsValid(R_PLAYER) then continue end

        local VEHICLE = TAB[i].VEHICLE
        local SPAWN = TAB[i].SPAWN

        if RDV.VEHICLE_REQ.CanGrant(P, VEHICLE, SPAWN) then
            DATA[k] = v
            DATA[k].OWNER = nil
            DATA[k].SKIN = nil
            DATA[k].TIME = timer.TimeLeft("VR_"..R_PLAYER:SteamID64())
        end
    end

    net.Start("RDV_VR_INITIAL")
        net.WriteTable(DATA)
    net.Send(P)
end)

hook.Add("PlayerDisconnected", "RDV_VR_ClearDisconnected", function(P)
    local E_INDEX = P:EntIndex()

    if IsValid(P.CurrentRequestedVehicle) then
        P.CurrentRequestedVehicle:Remove()
    end
    
    if RDV.VEHICLE_REQ.ACTIVE[E_INDEX] then
        net.Start("RDV_VR_CLEAR")
            net.WriteUInt(E_INDEX, 8)
        net.Broadcast()

        RDV.VEHICLE_REQ.ACTIVE[E_INDEX] = nil
    end
end)