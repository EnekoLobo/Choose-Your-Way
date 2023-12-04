local MODULE = MODULE
MODULE.animations = MODULE.animations or {}

util.AddNetworkString('mvpPH.startAnimation')
util.AddNetworkString('mvpPH.stopAnimation')

local function VelocityIsHigher(ply, value)
    local x, y, z = math.abs(ply:GetVelocity().x), math.abs(ply:GetVelocity().y), math.abs(ply:GetVelocity().z)

    if x > value or y > value or z > value then
        return true
    else
        return false
    end
end

hook.Add('SetupMove', 'MODULE.CheckVelocity', function(ply, moveData, cmd)
    if not mvp.config.Get('ph.animationSystem') then
        hook.Remove('SetupMove', 'MODULE.CheckVelocity') 
        return 
    end
    if ply:GetNWBool('mvp.animationStatus') then
            local deactivateOnMove = ply:GetNWInt('mvp.deactivateOnMove', mvp.config.Get('ph.animationMaxVelocity') or 5)
        
            if VelocityIsHigher(ply, deactivateOnMove) then
                MODULE.animations.Toggle(ply, false)
            end

            if ply:KeyDown(IN_DUCK) then
                MODULE.animations.Toggle(ply, false)
            end

            if ply:KeyDown(IN_USE) then
                MODULE.animations.Toggle(ply, false)
            end

            if ply:KeyDown(IN_JUMP) then
                MODULE.animations.Toggle(ply, false)
            end
    end
end)

function MODULE.animations.Toggle(ply, crossing, id, deactivateOnMove)
    if not mvp.config.Get('ph.animationSystem') then
        return 
    end

    if crossing then
        ply:SetNWBool('mvp.animationStatus', true)
        
        if id then
            ply:SetNWString('mvp.animationID', id)
        end
        
        ply:SetNWInt('mvp.deactivateOnMove', deactivateOnMove)

        net.Start('mvpPH.startAnimation')
        net.Send(ply)
    else
        ply:SetNWBool('mvp.animationStatus', false)
        ply:SetNWInt('mvp.deactivateOnMove', 5)

        net.Start('mvpPH.stopAnimation')
        net.Send(ply)
    end
end

net.Receive('mvpPH.startAnimation', function(_, ply)
    if not mvp.config.Get('ph.animationSystem') then
        return 
    end

    local animID = net.ReadInt(8)

    if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() != 'mvp_hands' then return end

    if not ply:GetNWBool('animationStatus') then
        if not ply:Crouching() and ply:GetVelocity():LengthSqr() < 25 and not ply:InVehicle() then
            MODULE.animations.Toggle(ply, true, animID, mvp.config.Get('ph.animationMaxVelocity') or 5)
        end
    else
        MODULE.animations.Toggle(ply, false)
    end
end)