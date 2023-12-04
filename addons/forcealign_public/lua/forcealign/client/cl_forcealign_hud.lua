forceAlign = forceAlign or {}

local matPath = "materials/forcealign/"
local fType = ".png"
local mats = {
	"coin", "meter", "meter_grad"
}
for k,v in pairs(mats) do
	mats[k] = Material(matPath .. mats[k] .. fType)
end

local function forceAlignHUD_meter()
	local ply = LocalPlayer()
	if ply:InVehicle() or !ply:GetNW2Bool("ForceSensitive") then return end

	local scrw, scrh = ScrW(), ScrH()
	-- HUD size in pixels
	local sizeX, sizeY = 59, 279

	-- Draw background
	surface.SetDrawColor(255,255,255,255)
	surface.SetMaterial(mats[2])
	surface.DrawTexturedRect(scrw / forceAlign.hudPos.x, scrh / forceAlign.hudPos.y, sizeX, sizeY)

	-- Gold meter size in pixels
	local meterSizeX = 29
	local meterSizeY = 5
	-- Meter position offset
	local offsetX = (sizeX - meterSizeX) / 2
	local offsetY = sizeY / 2

	-- Find the top and bottom of the meter
	local maxedOut = sizeY / 2.5

	-- Track player alignment to the meter
	local balance = ply:GetNW2Float("ForceAlignment")
	local mod = forceAlign.limit / maxedOut

	-- Cap it just in case so it doesnt run away
	balance = math.min(balance / mod, maxedOut)
	-- Now apply it to the offset
	offsetY = offsetY - balance

	-- Draw balance meter
	surface.SetDrawColor(255,255,255,255)
	surface.SetMaterial(mats[1])
	surface.DrawTexturedRect(scrw / forceAlign.hudPos.x + offsetX, scrh / forceAlign.hudPos.y + offsetY, meterSizeX, meterSizeY)

	-- Draw faded foreground
	surface.SetDrawColor(255,255,255,255)
	surface.SetMaterial(mats[3])
	surface.DrawTexturedRect(scrw / forceAlign.hudPos.x, scrh / forceAlign.hudPos.y, sizeX, sizeY)
end

hook.Add("HUDPaint", "forceAlign_HUD", function()
	if !forceAlign.hudEnabled then return end
	forceAlignHUD_meter()
end)