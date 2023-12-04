MCS.Themes["Backbone"] = {}
if SERVER then return end

local theme = MCS.Themes["Backbone"]
theme.FadeIn = true
theme.InProgress = false

theme.BGMat = Material("msd/stains.png", "smooth noclamp")

theme.Cam = {
	pos = Vector(0, 0, 0),
	ang = Angle(0, 0, 0),
	fov = 90,
	rotate = 180,
}

theme.Colors = {
	[1] = Color(196,173,124),
	[2] = Color(248,232,196),
	[3] = Color(117,112,98),
}

theme.Process = function(base)
	if not MCS.Config.EnableCamera then return end
	local ent
	local npc = base.NPC
	local ply = LocalPlayer()

	if not IsValid(npc) then
		ent = ply
	end

	ent = npc
	local head = ent:LookupBone("ValveBiped.Bip01_Head1")
	if not head then return end
	local sPos, sAng = ent:GetBonePosition(head)
	if not sPos then return end
	sAng = Angle(0, ent:GetAngles().y, 0)
	sAng:RotateAroundAxis(sAng:Up(), theme.Cam.rotate)

	if not base.AnimInit then
		base.AnimInit = true
		theme.Cam.pos = ply:EyePos()
		theme.Cam.ang = ply:GetAngles()
	end

	local tr = util.TraceLine({
		start = sPos,
		endpos = sPos - sAng:Forward() * 45 + sAng:Right() * 12,
		filter = ent
	})

	theme.Cam.pos = LerpVector(FrameTime() * 3, theme.Cam.pos, tr.HitPos)
	theme.Cam.ang = LerpAngle(FrameTime() * 3, theme.Cam.ang, sAng)
	theme.Cam.fov = Lerp(FrameTime() * 3, theme.Cam.fov, 60)
end

theme.FramePaint = function(self, w, h) end

theme.FrameBuild = function(base)
	local sw, sh = base:GetWide(), base:GetTall()

	base.panelNPC = vgui.Create("DPanel", base)
	base.panelNPC:SetSize(sw / 3, sh - 100)
	base.panelNPC:SetPos(sw - sw / 3 - 100, 0)
	base.panelNPC.line = ""
	base.panelNPC.text = ""
	base.panelNPC.typepos = 0
	base.panelNPC.typetime = 0
	base.panelNPC.spacer = 0

	base.panelPLY = vgui.Create("MSDPanelList", base)
	base.panelPLY:SetSize(sw / 3 - 10, (sh - 120) - (sh / 2 + 100))
	base.panelPLY:SetPos(sw - sw / 3 - 95, sh / 2 + 100)
	base.panelPLY:EnableVerticalScrollbar()
	base.panelPLY:EnableHorizontal(true)
	base.panelPLY:SetSpacing(5)
	base.panelPLY.IgnoreVbar = true

	base.panelPLY.UpdateF = function()
		base.panelPLY:Clear()
	end

	base.panelNPC.Paint = function(self, w, h)
		if base:GetAlpha() > 250 then
			draw.RoundedBoxEx(12, 0, 0, w, h, theme.Colors[3], false, false, true, true)
		end
		draw.RoundedBoxEx(12, 1, 0, w - 2, h - 1, color_black, false, false, true, true)
		local mp = h / 2 + 100
		surface.SetMaterial(theme.BGMat)
		surface.SetDrawColor(color_white)
		surface.DrawTexturedRectUV(0, 0, w, mp, 0, 0, w / 500, mp / 800)
		surface.SetDrawColor(theme.Colors[3])
		surface.DrawLine(25, mp, w - 50, mp)
		local text, _, hd = MSD.TextWrap(self.text, "MSDFont.28", w - 50)
		surface.DrawLine(25, h / 2 - hd, w - 50, h / 2 - hd)
		draw.DrawText(base.npc_table.name, "MSDFont.32", 25, (h / 2 + 40) - hd, theme.Colors[2], TEXT_ALIGN_LEFT)
		draw.DrawText(text, "MSDFont.28", 25, (h / 2 + 90 ) - hd, theme.Colors[1], TEXT_ALIGN_LEFT)
	end

	base.panelHst = vgui.Create("MSDPanelList", base)
	base.panelHst:SetSize(sw / 3 - 10, sh / 2)
	base.panelHst:SetPos(sw - sw / 3 - 95, 0)
	base.panelHst:EnableVerticalScrollbar()
	base.panelHst:EnableHorizontal(true)
	base.panelHst:SetSpacing(2)
	base.panelHst.IgnoreVbar = true
	base.panelHst.Paint = function(self, w, h)

	end

end

theme.FrameUpdate = function(base, dialog)
	base.panelNPC.typepos = 0
	base.panelNPC.typetime = 0
	base.panelNPC.changed = nil
	base.panelNPC.text = dialog["Line"]
	base.panelNPC.line = ""
	base.panelPLY.UpdateF()

	local _, _, shd = MSD.TextWrap(dialog["Line"], "MSDFont.28", base.panelNPC:GetWide() - 50)
	base.panelHst:SetSize(base.panelHst:GetWide(), base.panelNPC:GetTall() / 2 - shd)

	if base.History[base.HtrProgress - 1] then
		local pnl = vgui.Create("DPanel")
		pnl.StaticScale = {
			w = 1,
			fixed_h = 50,
			minw = 200,
			minh = 50
		}
		pnl.htr = base.History[base.HtrProgress - 1]
		pnl.Paint = function(self, w, h)
			local text, _, hd = MSD.TextWrap(self.htr.line, "MSDFont.28", w - 50)
			draw.DrawText(text, "MSDFont.28", 25, 25, theme.Colors[3], TEXT_ALIGN_LEFT)
			draw.DrawText("- " .. self.htr.ans, "MSDFont.28", w - 25, hd + 30, theme.Colors[3], TEXT_ALIGN_RIGHT)

			hd = hd + 70
			if hd > self.StaticScale.minh and w > 100 then
				self.StaticScale.fixed_h = hd
				self.StaticScale.minh = hd
				base.panelHst:PerformLayout()
			end
		end
		base.panelHst:AddItem(pnl)
		timer.Simple(0, function()
			if not IsValid(base) or not IsValid(base.panelHst) or not IsValid(pnl) then return end
			base.panelHst:ScrollToChild(pnl)
		end)
	end
end

theme.PopulateAns = function(base, k, ans, mid)
	local button = vgui.Create("DButton", bg)

	button.StaticScale = {
		w = 1,
		fixed_h = 35,
		minw = 200,
		minh = 35
	}

	button:SetText("")
	button.fade = 0

	button.Paint = function(self, w, h)
		if self.hover then
			self.fade = Lerp(FrameTime() * 7, self.fade, 1)
		else
			self.fade = Lerp(FrameTime() * 7, self.fade, 0)
		end

		local text, _, texth = MSD.TextWrap("- " .. ans[1], "MSDFont.28", w - 50)
		draw.DrawText(text, "MSDFont.28", w - 25, h / 2 - texth / 2, MSD.ColorAlpha(theme.Colors[1], 255 - self.fade * 255), TEXT_ALIGN_RIGHT)
		draw.DrawText(text, "MSDFont.28", w - 25, h / 2 - texth / 2, MSD.ColorAlpha(theme.Colors[2], self.fade * 255), TEXT_ALIGN_RIGHT)

		texth = texth + 25
		if texth > self.StaticScale.minh and w > 200 then
			self.StaticScale.minh = texth
			self.StaticScale.fixed_h = texth
			base.panelPLY:PerformLayout()
		end

		if self.fade > 0.1 then
			surface.SetDrawColor(MSD.ColorAlpha(theme.Colors[2], self.fade * 255))
			local hd = (h / 2) * self.fade
			surface.DrawLine(25, h / 2 - hd, w - 25, h / 2 - hd)
			surface.DrawLine(25, h / 2 + hd - 1, w - 25, h / 2 + hd - 1)
		end


	end

	button.DoClick = function()
		if base.panelPLY:GetAlpha() > 200 then
			base.DoAnswer(ans, k, mid)
		end
	end

	button.OnCursorEntered = function(self)
		self.hover = true
	end

	button.OnCursorExited = function(self)
		self.hover = false
	end

	base.panelPLY:AddItem(button)
end

hook.Add("HUDShouldDraw", "MCS.Backbone.HideHUD", function()
	if theme.InProgress then return false end
end)

hook.Add("CalcView", "MCS.Backbone.CalcView", function(ply, pos, angles, fov)
	if not MCS.Config.EnableCamera then return end
	if theme.InProgress then
		local view = {
			origin = theme.Cam.pos,
			angles = theme.Cam.ang,
			fov = theme.Cam.fov,
			drawviewer = true
		}

		return view
	else
		theme.Cam.fov = fov
	end
end)