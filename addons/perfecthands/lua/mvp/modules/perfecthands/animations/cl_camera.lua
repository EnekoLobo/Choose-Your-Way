local MODULE = MODULE
MODULE.camera = MODULE.camera or {}

MODULE.camera.isActive = false

function MODULE.camera.Create()
    local ply = LocalPlayer()
    local cameraAng = ply:EyeAngles()
    local savedAngles = nil
    
    local conX = 0
    local conY = -15
    local conZ = 0

    MODULE.camera.isActive = true

    hook.Add('Think', 'MODULE.LookThink', function()
        if not ply:Alive() then
            MODULE.camera.Destroy()
            return 
        end

        if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() ~= 'mvp_hands' then
            MODULE.camera.Destroy() 
            return 
        end

        if (mvp.config.Get('ph.animationFreelook') and not ply:KeyDown(IN_RELOAD)) then
            if (savedAngles) then
                cameraAng = savedAngles
            end

            savedAngles = nil
            return
        end
        
        savedAngles = savedAngles or ply:EyeAngles()
        ply:SetEyeAngles(savedAngles)
    end)

    hook.Add('CalcView', 'MODULE.ModifyView', function(ply, camPos, ang, fov, znear, zfar)
        if (not ply or not cameraAng) then return end


        local camTr = util.TraceLine({
            start = camPos,
            endpos = camPos + (cameraAng:Forward() * 9999999),
            filter = ply
        })

        local trace = util.TraceHull({
            start = camPos,
            endpos = camPos - cameraAng:Forward() * (100 + conZ) - cameraAng:Right() * conX - cameraAng:Up() * conY,
            filter = { ply:GetActiveWeapon(), ply },
            mins = Vector(-6, -4, -4),
            maxs = Vector(6, 4, 4)
        })

        local pos

        if (trace.Hit) then
            pos = trace.HitPos
        else
            pos = camPos - cameraAng:Forward() * (100 + conZ)
            pos = pos - cameraAng:Right() * (conX)
            pos = pos - cameraAng:Up() * (conY)
        end

        ply:SetEyeAngles( (camTr.HitPos - ply:EyePos()):Angle() )

        return {
            fov = fov,
            drawviewer = true,
            origin = pos,
            angles = cameraAng
        }
    end)

    hook.Add('InputMouseApply', 'MODULE.ModifyMouseInput', function(cmd, x, y, ang)
        if (not cameraAng) then
            cameraAng = Angle(0, 0, 0)
        end

        cameraAng.p = math.NormalizeAngle(cameraAng.p + y / 50)
        cameraAng.y = math.NormalizeAngle(cameraAng.y - x / 50)

        cameraAng.p = math.Clamp(cameraAng.p, -60, 80)

        return true
    end)
end

function MODULE.camera.Destroy()
    MODULE.camera.isActive = false

    hook.Remove('Think', 'MODULE.LookThink')
    hook.Remove('CalcView', 'MODULE.ModifyView')
    hook.Remove('InputMouseApply', 'MODULE.ModifyMouseInput')
end