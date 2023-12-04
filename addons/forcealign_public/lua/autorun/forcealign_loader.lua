forceAlign = forceAlign or {}

-- Load the config
include("forcealign/forcealign_config.lua")
AddCSLuaFile("forcealign/forcealign_config.lua")

-- Load the correct language file
if forceAlign.language then
	local langPath = "forcealign/lang/forcealign_lang_" .. forceAlign.language .. ".lua"
	AddCSLuaFile(langPath)
	include(langPath)
end

if SERVER then
	-- Load server files
	local svPath = "forcealign/server/sv_forcealign_"
	include(svPath .. "core.lua")
	include(svPath .. "net.lua")
	include(svPath .. "wrappers.lua")
	include(svPath .. "hooks.lua")

	-- Load resources
	if forceAlign.fastDL then
		local matPath = "materials/forcealign/"
		local fType = ".png"
		local mats = {
			"coin", "meter", "meter_grad", -- Main HUD
			"switch", -- Switch background
			"fade_j", "fade_r", "active_r", "active_j", -- Faction logos
			"grad_j", "grad_r" -- gradients
		}
		for k,v in pairs(mats) do
			resource.AddFile(matPath .. v .. fType)
		end
	end
end

-- Load client files
local clPath = "forcealign/client/cl_forcealign_"
-- Main HUD
AddCSLuaFile(clPath .. "hud.lua")
include(clPath .. "hud.lua")
-- Switch HUD
AddCSLuaFile(clPath .. "switch.lua")
include(clPath .. "switch.lua")
-- Notification HUD
AddCSLuaFile(clPath .. "notify.lua")
include(clPath .. "notify.lua")
-- Halo rendering
AddCSLuaFile(clPath .. "halos.lua")
include(clPath .. "halos.lua")

print("[forceAlign] Finished loading!")