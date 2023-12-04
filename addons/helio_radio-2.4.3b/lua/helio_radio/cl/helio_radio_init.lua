hradio.debug = false
if GetConVar("developer"):GetInt() > 0 then hradio.debug = true end

local lply = LocalPlayer()

hradio = hradio or {}
lply.hradio = lply.hradio or {}

lply.hradio.MutedChannels = {}
lply.hradio.LastStartTime = lply.hradio.LastStartTime or SysTime()
lply.hradio.LastStopTime = lply.hradio.LastStopTime or SysTime()

surface.CreateFont("hRadio_Main", {
	font = "Open Sans Semibold",
	size = 24,
})
surface.CreateFont("hRadio_Small", {
	font = "Open Sans Semibold",
	size = 16,
})