Aden_DC = Aden_DC or {}
Aden_DC.Config = Aden_DC.Config or {}
Aden_DC.Lang = Aden_DC.Lang or {}
Aden_DC.Func = Aden_DC.Func or {}
Aden_DC.Version = "1.3.6"
Aden_DC.OnDate = true
if SERVER then
    Aden_DC.SQL = Aden_DC.SQL or {}
    Aden_DC.NPC = Aden_DC.NPC or {}
else
    Aden_DC.Buttons = Aden_DC.Buttons or {}
    Aden_DC.ClientSideMenu = Aden_DC.ClientSideMenu or {}
end

// Owner 76561198087853030

local dir = "aden_character_system"

include(dir .. "/config/sh_config.lua")
include(dir .. "/shared/sh_lang.lua")
include(dir .. "/shared/sh_nets.lua")
include(dir .. "/shared/sh_string.lua")

if SERVER then
    include(dir .. "/config/sv_config_mysql.lua")
    AddCSLuaFile(dir .. "/config/sh_config.lua")
    AddCSLuaFile(dir .. "/shared/sh_lang.lua")
    AddCSLuaFile(dir .. "/shared/sh_nets.lua")
    AddCSLuaFile(dir .. "/shared/sh_string.lua")
    AddCSLuaFile(dir .. "/client/cl_admin.lua")
    AddCSLuaFile(dir .. "/client/cl_anims.lua")
    AddCSLuaFile(dir .. "/client/cl_base.lua")
    AddCSLuaFile(dir .. "/client/cl_buttons.lua")
    AddCSLuaFile(dir .. "/client/cl_creation.lua")
    AddCSLuaFile(dir .. "/client/cl_model.lua")
    AddCSLuaFile(dir .. "/client/cl_request.lua")
    AddCSLuaFile(dir .. "/client/cl_selection.lua")
    AddCSLuaFile(dir .. "/client/cl_spawn.lua")
    AddCSLuaFile(dir .. "/client/cl_clothes_mod.lua")
    include(dir .. "/server/sv_hooks.lua")
    include(dir .. "/server/sv_meta.lua")
    include(dir .. "/server/sv_mysql.lua")
    include(dir .. "/server/sv_nets.lua")
    include(dir .. "/server/sv_support.lua")
else
    include(dir .. "/client/cl_admin.lua")
    include(dir .. "/client/cl_anims.lua")
    include(dir .. "/client/cl_base.lua")
    include(dir .. "/client/cl_buttons.lua")
    include(dir .. "/client/cl_creation.lua")
    include(dir .. "/client/cl_model.lua")
    include(dir .. "/client/cl_request.lua")
    include(dir .. "/client/cl_selection.lua")
    include(dir .. "/client/cl_spawn.lua")
    include(dir .. "/client/cl_clothes_mod.lua")
end
