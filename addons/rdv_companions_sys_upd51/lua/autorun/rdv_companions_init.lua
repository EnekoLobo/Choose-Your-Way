timer.Simple(0, function()
    local VALID = RDV.LIBRARY.RegisterProduct("Companions", {
        {
            Name = "PixelUI (https://github.com/TomDotBat/pixel-ui)", 
            Check = function() 
                if !PIXEL then return false end 
            end
        },
    }, "8ZITXbK")

    if !VALID then return end

    RDV.COMPANIONS = RDV.COMPANIONS or {
        TARGETS = {},
        CFG = {},
        PLAYERS = {},
        ABILITIES = {},
    }

    local function AddFile(File, dir)
        local fileSide = string.lower(string.Left(File , 3))

        if SERVER and fileSide == "sv_" then
            include(dir..File)
        elseif fileSide == "sh_" then
            if SERVER then 
                AddCSLuaFile(dir..File)
            end
            include(dir..File)
        elseif fileSide == "cl_" then
            if SERVER then 
                AddCSLuaFile(dir..File)
            elseif CLIENT then
                include(dir..File)
            end
        end
    end

    local function IncludeDir(dir)
        dir = dir .. "/"
        local File, Directory = file.Find(dir.."*", "LUA")

        for k, v in ipairs(File) do
            if string.EndsWith(v, ".lua") then
                AddFile(v, dir)
            end
        end
        
        for k, v in ipairs(Directory) do
            IncludeDir(dir..v)
        end
    end

    IncludeDir("rdv_companions/core")

    AddFile("sh_pt_wrapper.lua", "rdv_companions/")
    AddFile("sh_ab_wrapper.lua", "rdv_companions/")
    
    IncludeDir("rdv_companions/config")
    IncludeDir("rdv_companions/plugins")
end)