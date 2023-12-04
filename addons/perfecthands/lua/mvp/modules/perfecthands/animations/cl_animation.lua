local MODULE = MODULE
MODULE.config = MODULE.config or {}

MODULE.config.animations = MODULE.config.animations or {}

local function applyAnimation(ply, targetValue, id)
    if not IsValid(ply) then return end

    if ply.mvpPHAnimationAngle ~= targetValue then
        ply.mvpPHAnimationAngle = Lerp(FrameTime() * (mvp.config.Get('animationsSpeed') or 5), ply.mvpPHAnimationAngle, targetValue)
    end

    local oldanimationID = ply:GetNWString('mvp.oldanimationID')

    if oldanimationID ~= id and MODULE.config.animations[id] then
        for boneName, angle in pairs(MODULE.config.animations[id].bones) do
            local bone = ply:LookupBone(boneName)

            if bone then
                ply:ManipulateBoneAngles(bone, angle * 0)
            end
        end
    end

    ply:SetNWString('mvp.oldanimationID', id)

    if MODULE.config.animations[id] then
        for boneName, angle in pairs(MODULE.config.animations[id].bones) do
            local bone = ply:LookupBone(boneName)

            if bone then
                ply:ManipulateBoneAngles(bone, angle * ply.mvpPHAnimationAngle)
            end
        end
    end
end

hook.Add('Think', 'MODULE.AnimThink', function()
    if not mvp.config.Get('ph.animationSystem') then
        hook.Remove('Think', 'MODULE.AnimThink')
        return 
    end
    for _, ply in pairs(player.GetHumans()) do
        local animationID = ply:GetNWString('mvp.animationID')

        if animationID ~= '' then
            if not ply.mvpPHAnimationAngle then
                ply.mvpPHAnimationAngle = 0
            end

            if ply:GetNWBool('mvp.animationStatus') then
                applyAnimation(ply, 1, animationID)
            else
                applyAnimation(ply, 0, animationID)
                
            end
        end
    end
end)

net.Receive('mvpPH.startAnimation', function()
    MODULE.camera.Create()
end)

net.Receive('mvpPH.stopAnimation', function()
    MODULE.camera.Destroy()
end)