--  _______               __          _______  __                   __          _______  ______  ______        
-- |   |   |.---.-..----.|  |.-----. |     __||__|.--------..-----.|  |.-----. |    |  ||   __ \|      |.-----.
-- |       ||  _  ||  __| |_||__ --| |__     ||  ||        ||  _  ||  ||  -__| |       ||    __/|   ---||__ --|
-- |__|_|__||___._||____|    |_____| |_______||__||__|__|__||   __||__||_____| |__|____||___|   |______||_____|
--                                                          |__|                                               
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////
--/////////////////////// Warning! Edit this only if you know what are you doing ///////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////
local blur = Material("pp/blurscreen")

function MCS.Blur(panel, inn, density, alpha, w, h)
	local x, y = panel:LocalToScreen(0, 0)
	surface.SetDrawColor(255, 255, 255, alpha)
	surface.SetMaterial(blur)

	for i = 1, 3 do
		blur:SetFloat("$blur", (i / inn) * density)
		blur:Recompute()
		render.UpdateScreenEffectTexture()

		if w and h then
			render.SetScissorRect(-x, -y, x + w, y + h, true)
			surface.DrawTexturedRect(-x, -y, ScrW(), ScrH())
			render.SetScissorRect(0, 0, 0, 0, false)
		else
			surface.DrawTexturedRect(-x, -y, ScrW(), ScrH())
		end
	end
end

function MCS.Frame(x, y, w, h, lw, color, otcolor)
	surface.SetDrawColor(color)
	surface.DrawOutlinedRect(x, y, w, h)
	surface.SetDrawColor(otcolor)

	if lw then
		surface.DrawLine(x, y, x + lw, y)
		surface.DrawLine(w + x - 1, y, w + x - lw - 1, y)
		surface.DrawLine(x, y + h - 1, x + lw, y + h - 1)
		surface.DrawLine(w + x - 1, y + h - 1, w + x - lw - 1, y + h - 1)
		surface.DrawLine(x, y, x, y + lw)
		surface.DrawLine(w + x - 1, y, w + x - 1, y + lw)
		surface.DrawLine(x, y, x, y + lw)
		surface.DrawLine(w + x - 1, y + h - 1, w + x - 1, y + h - lw - 1)
		surface.DrawLine(x, y + h - 1, x, y + h - lw - 1)
	end
end

function MCS.GetBoneOrientation(ent, bone, pos, ang, scale)

	if !pos or !ang then return end

	if !bone then return pos, ang end

	local m = ent:GetBoneMatrix(bone)

	if (m) then
		pos, ang = m:GetTranslation(), m:GetAngles()
	end

	return pos, ang
end