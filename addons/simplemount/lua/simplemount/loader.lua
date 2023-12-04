simplemount = simplemount or {}
simplemount.config = simplemount.config or {}
simplemount.config.adminRanksKey = simplemount.config.adminRanksKey or {}

local function client(file)
    if SERVER then AddCSLuaFile(file) end
    if CLIENT then
        return include(file)
    end
end

local function server(file)
    if SERVER then
        return include(file)
    end
end

local function shared(file)
    return client(file) or server(file)
end

shared("config.lua")
client("main/cl_fonts.lua")
client("vgui/menu.lua")
client("main/cl_init.lua")
client("vgui/admin.lua")
server("main/init.lua")

if SERVER then
    resource.AddFile("resource/fonts/Montserrat-Medium.ttf")
end

-- fix ranks --
if simplemount.config.adminRanks then
    for k,v in pairs(simplemount.config.adminRanks) do
        simplemount.config.adminRanksKey[v] = v
    end
end


function simplemount.isAdmin(pPlayer)
    return simplemount.config.adminRanksKey and simplemount.config.adminRanksKey[pPlayer:GetUserGroup()] and true or false
end

function simplemount.notify(strText, pPlayer)
    if not simplemount.config.chatPrints then return end
    if notification then
        notification.AddLegacy(strText, NOTIFY_HINT, 5)
    else
        pPlayer:ChatPrint(strText)
    end
end

MsgC(Color(0, 255, 0), "Loaded SimpleMount by Nykez!\n")

