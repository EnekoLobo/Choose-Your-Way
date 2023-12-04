local MODULE = MODULE
MODULE.config = {}

MODULE.config.animations = {}
MODULE.config.themes = {}
MODULE.config.blacklist = {}
MODULE.config.iconsPerJob = MODULE.config.iconsPerJob or {}

function MODULE.config.AddAnimation(id, title, description, bones)
    MODULE.config.animations[#MODULE.config.animations + 1] = {
        id = id,
        title = title,
        description = description,
        bones = bones 
    }
end

function MODULE.config.AddBlaclistedEntity(class)
    MODULE.config.blacklist[class] = true
end

function MODULE.config.AddTheme(id, name, iconsSet)
    MODULE.config.themes[id] = {
        name = name,
        icons = iconsSet
    }
end

function MODULE.GetThemes()
    local result = {}
    
    for k, v in pairs(MODULE.config.themes) do
        result[k] = v.name
    end

    return result
end

function MODULE.AddTheme(id, name, iconsSet)
    MODULE.config.AddTheme(id, name, iconsSet)
end