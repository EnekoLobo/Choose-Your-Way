--[[
!ThirdPerson
By Imperial Knight.
Copyright © Imperial Knight 2019: Do not redistribute.
(76561198087853030)

ServerGuard Plugin for !ThirdPerson Support
]]--

if serverguard then
	local plugin = plugin;

	plugin.name = "!ThirdPerson";
	plugin.author = "Imperial Knight";
	plugin.version = "33d948b1-4eb0-4962-833c-1c716cfe09b7";
	plugin.description = "!ThirdPerson support for ServerGuard.";
	plugin.permissions = {
		"thirdperson_view",
		"thirdperson_bind",
		"thirdperson_preventwallcollisions",
		"thirdperson_crosshair",
		"thirdperson_crosshaircolor",
		"thirdperson_scoping",
		"thirdperson_bulletcorrection",
		"thirdperson_distance",
		"thirdperson_viewangles",
		"thirdperson_entityview",
	};
end