-- Make sure the client has the files they need
AddCSLuaFile("helio_radio/sh_helio_errorcatcher.lua")
AddCSLuaFile("helio_radio/sh_helio_channels.lua")
AddCSLuaFile("helio_radio/sh_helio_config_general.lua")
AddCSLuaFile("helio_radio/sh_helio_config_channels.lua")
AddCSLuaFile("helio_radio/cl/helio_radio_init.lua")
AddCSLuaFile("helio_radio/cl/helio_radio_2dmenu.lua")
AddCSLuaFile("helio_radio/cl/helio_radio_3d2dmenu.lua")
AddCSLuaFile("helio_radio/cl/helio_radio_commands.lua")
AddCSLuaFile("helio_radio/cl/helio_radio_networking.lua")
AddCSLuaFile("helio_radio/cl/helio_radio_notifications.lua")
AddCSLuaFile("helio_radio/cl/helio_radio_oldvcremoval.lua")
AddCSLuaFile("libs/imgui.lua")

if SERVER then

	local function Load()
		hradio = {}
		include("helio_radio/sh_helio_errorcatcher.lua")
		include("helio_radio/sh_helio_channels.lua")
		include("helio_radio/sh_helio_config_general.lua")
		include("helio_radio/sv_helio_radio.lua")
		print("[heliOS][RADIOSYS] HeliosRadios loaded!") -- And notify the server that we succeeded.
	end

	hook.Add("PostGamemodeLoaded", "hRadio_Load", Load)
	concommand.Add("sv_hRadio_Reload", Load)

end


if CLIENT then

	local Colors = {
			Darker = Color(33,33,33),
			Dark = Color(44,44,44),
			Darkred = Color(255,66,66),
			Gray = Color(66,66,66),
			Grayer = Color(88,88,88),
			Grayish = Color(104,104,104),
			Green = Color(0,125,0),
			White = Color(255,255,255), -- For readability
			Red = Color(255,125,125),
			LightRed = Color(255,175,175),
		}

	local function Load()
		hradio = {}

		hradio.Colors = hradio.Colors or Colors

		include("helio_radio/sh_helio_errorcatcher.lua")

		include("helio_radio/sh_helio_channels.lua")
		include("helio_radio/sh_helio_config_general.lua")

		include("helio_radio/cl/helio_radio_init.lua")
		include("helio_radio/cl/helio_radio_oldvcremoval.lua")
		include("helio_radio/cl/helio_radio_networking.lua")
		include("helio_radio/cl/helio_radio_commands.lua")
		include("helio_radio/cl/helio_radio_3d2dmenu.lua")
		include("helio_radio/cl/helio_radio_2dmenu.lua")
		include("helio_radio/cl/helio_radio_notifications.lua")

		print("[heliOS][RADIOSYS] HeliosRadios loaded!")

		if (table.Count(hradio.errorcatcher.startupErrors) > 0) then
			hradio.errorcatcher.open()
		end

	end

	hook.Add("InitPostEntity", "hRadio_Radio", Load)
	concommand.Add("cl_hRadio_Reload", Load)

end

print("[heliOS][RADIOSYS] Loader finished!")
