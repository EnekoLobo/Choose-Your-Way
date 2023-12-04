timer.Simple(0, function()
    local VALID = RDV.LIBRARY.RegisterProduct("Vehicle Requisition", {
        {
            Name = "RDV Library (https://steamcommunity.com/sharedfiles/filedetails/?id=2146897844)",
            Check = function()
                if !RDV then return false end
            end,
        },
    })

    if !VALID then return end

    RDV.VEHICLE_REQ = RDV.VEHICLE_REQ or {
        ACTIVE = {},
        Active = {},
        SActive = {},
        NSVehicles = {},
        CFG = {},
        CachedLocations = {},
    }

    local INDEX = {}

    function RDV.VEHICLE_REQ.GetTeamIndex(name)
        if INDEX[name] then
            return INDEX[name]
        else
            return false
        end
    end

    for k, v in ipairs(team.GetAllTeams()) do
        INDEX[v.Name] = k
    end

    local rootDir = "rd_vehicle_req"

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
    IncludeDir(rootDir)
end)