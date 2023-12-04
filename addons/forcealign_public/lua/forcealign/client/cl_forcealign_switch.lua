forceAlign = forceAlign or {}

local matPath = "materials/forcealign/"
local fType = ".png"
local mats = {
	"switch", "fade_j", "fade_r", "active_r", "active_j", "grad_j", "grad_r"
}
for k,v in pairs(mats) do
	mats[k] = Material(matPath .. mats[k] .. fType)
end

local function forceAlignHUD_switch()
	if LocalPlayer():InVehicle() or !LocalPlayer():GetNW2Bool("ForceSensitive") then return end

	local scrw, scrh = ScrW(), ScrH()
	local side = LocalPlayer():GetNW2Int("forceAlign_switch")

 	-- Background
	surface.SetDrawColor(255,255,255,255)
--	if side == 2 then
		surface.SetMaterial(mats[1])
--	else
--		surface.SetMaterial(Material(matPath .. mats[1] .. fType))
--	end
	surface.DrawTexturedRect(scrw / forceAlign.switch.hudPos.x, scrh / forceAlign.switch.hudPos.y, 149, 74)

	-- Dark Side
	local dark_offX = 24
	local dark_offY = 13
	surface.SetDrawColor(255,255,255,255)
	if side == 2 then
		surface.SetMaterial(mats[4])
	else
		surface.SetMaterial(mats[3])
	end
	surface.DrawTexturedRect(scrw / forceAlign.switch.hudPos.x + dark_offX, scrh / forceAlign.switch.hudPos.y + dark_offY, 48, 41)

	-- Light Side
	local lite_offX = 78.5
	local lite_offY = 12
	surface.SetDrawColor(255,255,255,255)
	if side == 1 then
		surface.SetMaterial(mats[5])
	else
		surface.SetMaterial(mats[2])
	end
	surface.DrawTexturedRect(scrw / forceAlign.switch.hudPos.x + lite_offX, scrh / forceAlign.switch.hudPos.y + lite_offY, 47, 44)
end

local function forceAlign_switchClicker(mouseCode)
	if mouseCode != 107 then return end -- Left clicks only

	local scrw, scrh = ScrW(), ScrH()
	local x, y = input.GetCursorPos()
	-- Get relative position to screen
	local x, y = scrw / x, scrh / y

	-- Calculate the top of the switch
	local limit = 0.02
	local xTop = forceAlign.switch.hudPos.x - limit
	local yTop = forceAlign.switch.hudPos.y - limit
	-- Calculate the bottom of the switch
	local xBot = xTop - 0.087
	local yBot = yTop - 0.04
	-- Calculate the center of the switch
	local ctr = xTop + xBot
	ctr = ctr / 2

	-- print("[forceAlign] Test: " .. x .. ", " .. y)

	if x > xTop or y > yTop then return end
	if x < xBot or y < yBot then return end
	-- print("[forceAlign] Test: In the switch zone!")

	if x > ctr then
		-- Left side switch
		net.Start("forceAlign_switch")
			net.WriteFloat(2)
		net.SendToServer()
	else
		-- Right side switch
		net.Start("forceAlign_switch")
			net.WriteFloat(1)
		net.SendToServer()
	end
end

hook.Add("VGUIMousePressed", "forceAlign_switchClick", function(pnl, mouseCode)
	if forceAlign.switch.enabled then forceAlign_switchClicker(mouseCode) end
end)

hook.Add("HUDPaint", "forceAlignHUD_switch", function()
	if forceAlign.switch.enabled then forceAlignHUD_switch() end
end)