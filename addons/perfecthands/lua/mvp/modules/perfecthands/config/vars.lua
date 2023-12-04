local MODULE = MODULE
local iconsSets = MODULE.GetThemes

mvp.config.Add('ph.iconsTheme', 'clonePhaseI', 'ph#iconsTheme', nil, {
    category = 'Perfect Hands',
    type = 'select',
    from = iconsSets
}, false, false)

mvp.config.Add('ph.animationSystem', true, 'ph#animationSystem', nil, {
    category = 'Perfect Hands',
    type = 'bool'
}, false, false)

mvp.config.Add('ph.animationSpeed', 5, 'ph#animationSpeed', nil, {
    category = 'Perfect Hands',
    type = 'number'
}, false, false)

mvp.config.Add('ph.pulsateSpeed', 0.5, 'ph#pulsateSpeed', nil, {
    category = 'Perfect Hands',
    type = 'number'
}, false, false)

mvp.config.Add('ph.animationFreelook', true, 'ph#animationFreelook', nil, {
    category = 'Perfect Hands',
    type = 'bool'
}, false, false)

mvp.config.Add('ph.animationMaxVelocity', 5, 'ph#animationMaxVelocity', nil, {
    category = 'Perfect Hands',
    type = 'number'
}, false, false)

mvp.config.Add('ph.weightMultiplier', 1, 'ph#weightMultiplier', nil, {
    category = 'Perfect Hands',
    type = 'number'
}, false, false)

mvp.config.Add('ph.iconsPerTeam', {}, 'ph#iconsPerTeam', function(oldValue, newValue)
    mvp.ph.config.iconsPerJob = {}

    for k, v in pairs(newValue) do
        local teamIndex = _G[k]
        if not teamIndex then continue end -- this should never happen, but make sure to check
        mvp.ph.config.iconsPerJob[teamIndex] = v
    end
end, {
    category = 'Perfect Hands',
    type = 'keyvaluetable',
    tableStructure = {
        key = {
            type = 'string',
            default = 'TEAM_variable Example > TEAM_CLONE',
            validator = function(value)
                local globalValue = _G[value]

                return _G[value] ~= nil and type(globalValue) == 'number'
            end
        },
        value = {
            type = 'select',
            default = 'clonePhaseI',
            from = iconsSets
        }
    }
}, false, false)