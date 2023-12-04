if (SERVER) then return end
forceAlign = forceAlign or {}
local matPath = "materials/forcealign/"
local fType = ".png"
local mats = {
	"switch", "fade_j", "fade_r", "active_r", "active_j", "grad_j", "grad_r"
}
for k,v in pairs(mats) do
	mats[k] = Material(matPath .. mats[k] .. fType)
end

local fontName = "Swtorfont"
surface.CreateFont( fontName, {
	font = "Old Republic Bold",
	extended = true,
	size = ScreenScale(8),
	weight = ScreenScale(420),
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = true,
	additive = true,
	outline = true,
})

local function showPoints_1()
	local scrw, scrh = ScrW(), ScrH()
	local lightPnts = LocalPlayer():GetNW2Float("forceAlign_" .. forceAlign.nwSides[1])
	lightPnts = tostring(lightPnts)
	local digits = #lightPnts * 1.4

	surface.SetTextColor( 200,200,200,255 ) 
	surface.SetTextPos( scrw / forceAlign.pointsHUD.x - digits, scrh / forceAlign.pointsHUD.y + 40) -- x = 1.032 y = -207.2
	surface.SetFont(fontName) 
	surface.DrawText(lightPnts) 
  	surface.SetDrawColor(255,255,255,255)
  -- Logo
	surface.SetMaterial(mats[5])
	surface.DrawTexturedRect(scrw / forceAlign.pointsHUD.x, scrh / forceAlign.pointsHUD.y, 48, 41)
end

local function showPoints_2()
	local scrw, scrh = ScrW(), ScrH()
	local darkPnts = LocalPlayer():GetNW2Float("forceAlign_" .. forceAlign.nwSides[2])
	darkPnts = tostring(darkPnts)
	local digits = #darkPnts * 1.4
	local yOffset = forceAlign.pointsHUD.y - 1.25

	surface.SetTextColor( 200,200,200,255 ) 
	surface.SetTextPos( scrw / forceAlign.pointsHUD.x - digits, scrh / yOffset + 40) -- x = 1.032 y = -207.2
	surface.SetFont(fontName) 
	surface.DrawText(darkPnts) 
  	surface.SetDrawColor(255,255,255,255)
  -- Logo
	surface.SetMaterial(mats[3])
	surface.DrawTexturedRect(scrw / forceAlign.pointsHUD.x, scrh / yOffset, 48, 41)
end

local function fAlign_notification()
	local scrw, scrh = ScrW(), ScrH()
	local iconX, iconY = forceAlign.notifyHUD.hudPos.x, forceAlign.notifyHUD.hudPos.y

	local ply = LocalPlayer()
	local sideString = ply.fAlignNotify_side
	local sideInt = table.KeyFromValue(forceAlign.sides, sideString)

	local validSides = {1,2}
	if !validSides[sideInt] then return end
	
	local sizeX, sizeY = 55, 47
	local sizeMulti = 1.5
	sizeX, sizeY = sizeX * sizeMulti, sizeY * sizeMulti
	local offset = 2

	local elapsed = CurTime() - ply.lastFAlignNotify
	local fadeTime = 255 / forceAlign.notifyHUD.fadeTime
	local fade = 0
	local maxAlpha = 120
	local deathFade = forceAlign.notifyHUD.dieTime - elapsed
	if elapsed > 0 and elapsed < forceAlign.notifyHUD.dieTime - forceAlign.notifyHUD.fadeTime then
		fade = math.Clamp(elapsed * fadeTime, 0, maxAlpha)
	end
	if deathFade > 0 and deathFade < forceAlign.notifyHUD.fadeTime then
		fade = math.Clamp(deathFade * fadeTime, 0, maxAlpha)
	end

	if sideInt == 1 then
		surface.SetDrawColor(255,255,255,fade)
		surface.SetMaterial(mats[6])    
		surface.DrawTexturedRect(scrw / scrw, scrh / scrh, scrw, scrh / 2)

		surface.SetDrawColor(255,255,255,fade)
		surface.SetMaterial(mats[5])
		surface.DrawTexturedRect(scrw / iconX - (sizeX / offset), scrh / iconY, sizeX, sizeY)

		showPoints_1()

	elseif sideInt == 2 then
		surface.SetDrawColor(255,255,255,fade)
		surface.SetMaterial(mats[7])
		surface.DrawTexturedRect(scrw / scrw, scrh / 3, scrw, scrh)

		surface.SetDrawColor(255,255,255,fade)
		surface.SetMaterial(mats[4])
		surface.DrawTexturedRect(scrw / iconX - (sizeX / offset), scrh / iconY, sizeX, sizeY)

		showPoints_2()
	end

	local amount = ply.fAlignNotify_amount
	local msg = "¡Has ganado " .. amount .. " puntos del " .. sideString .."!"
	surface.SetDrawColor(255,255,255,fade)
	surface.SetTextColor(236,180,42,fade)
--	if sideInt == 1 then surface.SetTextColor(42,210,255,fade)
--	elseif sideInt == 2 then surface.SetTextColor(255,0,0,fade) end
	surface.SetFont(fontName) -- Set the font
	local msgW, msgH = surface.GetTextSize(msg)
	msgW = msgW / offset
	surface.SetTextPos(scrw / iconX - msgW, scrh / iconY - msgH) -- Set text position, top left corner
	surface.DrawText(msg) -- Draw the text
end

hook.Add("HUDPaint", "forceAlignHUD_notify", function()
	local ply = LocalPlayer()

	-- Point check command
	if ply.fAlignPntCheck and ply.fAlignPntCheck > CurTime() then
		showPoints_1()
		showPoints_2()
	end

	-- Gradient notifications
	if !forceAlign.notifyHUD.enabled or !ply.lastFAlignNotify then return end

	-- This SHOULD hide the Notification HUD 
	if ply.lastFAlignNotify < CurTime() - forceAlign.notifyHUD.dieTime - forceAlign.notifyHUD.fadeTime then return end

	fAlign_notification()
end)

-- Make the Notification HUD visible
net.Receive("forceAlign_Notify", function(len)
	if !forceAlign.notifyHUD.enabled then return end
	local ply = LocalPlayer()

	ply.fAlignNotify_side = net.ReadString()
	ply.fAlignNotify_amount = net.ReadFloat()
	ply.lastFAlignNotify = CurTime()
end)

-- Make point totals visible
net.Receive("forceAlign_pointCheck", function(len)
	local ply = LocalPlayer()
	ply.fAlignPntCheck = CurTime() + forceAlign.notifyHUD.dieTime
end)