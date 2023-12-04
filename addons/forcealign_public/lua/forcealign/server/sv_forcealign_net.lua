forceAlign = forceAlign or {}

-- Point reward notifications
util.AddNetworkString("forceAlign_Notify")
-- forceAlign.pointsHUD.cmd
util.AddNetworkString("forceAlign_pointCheck")
-- Alignment Switch
util.AddNetworkString("forceAlign_switch")

net.Receive("forceAlign_switch", function(len, pl)
	if !forceAlign.switch.enabled then return end
	local side = net.ReadFloat()
	side = math.Round(side)

	pl:toggleFAlignSwitch(side)
end)