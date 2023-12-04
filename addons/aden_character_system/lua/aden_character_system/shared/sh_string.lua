function Aden_DC.Func:StringSeparate(text, pos) // 3D2D TextEntry cursor position
    return utf8.sub(text, 1, pos), utf8.sub(text, pos+1)
end

function Aden_DC.Func:IsBlackList(firstName, lastName) // Check is the name is avaible
    firstName, lastName = string.lower(firstName), string.lower(lastName)
    return Aden_DC.Config.blackListName[firstName] or Aden_DC.Config.blackListName[lastName] or Aden_DC.Config.blackListName[firstName .. " " .. lastName]
end

local stringChar = [[\[\]\"\'{}|\\?.,<>!()_=+*&^%$#@;:/]]
local arrayChar = {}
for k, v in ipairs(string.Explode("", stringChar)) do
    arrayChar[v] = true
end

function Aden_DC.Func:AvailableChar(stringValue)
    return arrayChar[stringValue]
end

// https://github.com/Facepunch/garrysmod/pull/1868/files/c0eda76561198087853030484adc94229038fdb783684f19ec53632d4
function Aden_DC.Func:ModuleAvailable(name)
    local realm = CLIENT and "cl" or "sv"
    local ops = system.IsWindows() and "win" or (system.IsOSX() and "osx" or "linux")
    local arch = ops == "linux" and "" or string.sub(jit.arch, 2)
    local f = string.format("lua/bin/gm%s_%s_%s%s.dll", realm, name, ops, arch)

    return file.Exists(f, "GAME")
end

function Aden_DC:isAdmin(ply)
    return self.Config.Open.Acces[ply:SteamID()] or self.Config.Open.Acces[ply:SteamID64()] or self.Config.Open.Acces[ply:GetUserGroup()]
end

function Aden_DC:havePermission(ply, perm)
    local userPerm = self:isAdmin(ply)
    return userPerm and (userPerm[perm] or userPerm["all"])
end
