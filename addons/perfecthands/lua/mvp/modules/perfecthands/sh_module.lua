local MODULE = MODULE
MODULE.systemID = 'ph'

MODULE.name = 'Perfect Hands'
MODULE.author = 'Kot'
MODULE.description = 'Perfect hands, addon which adds perfect hands SWEP, as its name says!'
MODULE.version = '2.1.1'

MODULE.icon = Material('mvp/m_icons/perfecthands.png')

MODULE.registerAsTable = true

MODULE:IncludeFolder('animations')
MODULE:IncludeFolder('wheel')

MODULE:Include('sh_confighelper.lua')
MODULE:Include('sh_animations.lua')
MODULE:Include('sh_themes.lua')

function MODULE:OnLoaded()
    mvp.utils.Print( self.name, 'loaded!')
end

hook.Add('RecivedMVPConfigs', 'MVP', function()
    local storedValue = mvp.config.Get('ph.iconsPerTeam', {})

    MODULE.config.iconsPerJob = {}

    for k, v in pairs(storedValue) do
        local teamIndex = _G[k]

        if not teamIndex then continue end -- this should never happen, but make sure to check
        MODULE.config.iconsPerJob[teamIndex] = v
    end
end)