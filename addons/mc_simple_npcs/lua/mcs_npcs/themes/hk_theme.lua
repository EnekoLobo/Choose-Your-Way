MCS.Themes["Hollow Knight"] = {}

if SERVER then
	resource.AddWorkshop("1932352136") -- Content (Fonts and materials)
	return
end

local NewFont = surface.CreateFont

NewFont("MCS_HKMain", {
	font = "Kurale",
	extended = true,
	size = 35,
	antialias = true,
	weight = 800
})

NewFont("MCS_HKSub", {
	font = "Kurale",
	extended = true,
	size = 46,
	antialias = true,
	weight = 800,
	outline = true
})

local theme = MCS.Themes["Hollow Knight"]

theme.Mats = {
	top = Material("mcs_ui/hn_top.png", "smooth"),
	but = Material("mcs_ui/hn_but.png", "smooth"),
	grad = Material("gui/center_gradient.vtf"),
	opt = Material("mcs_ui/hn_opt.png", "smooth"),
}

theme.FadeIn = true
theme.InProgress = false
theme.Process = function(base) end

theme.FramePaint = function(self, w, h)
	MSD.DrawTexturedRect(0, 0, w, h, MSD.Materials.vignette, color_black)
	draw.DrawText(self.npc_table.name, "MCS_HKSub", w / 10, h / 2 + h / 4, color_white, TEXT_ALIGN_LEFT)
end

theme.FrameBuild = function(base)
	local sw, sh = base:GetWide(), base:GetTall()
	local textspd = math.Clamp(MCS.Config.TextSpeed, 1, 10)
	base.panelPLY = vgui.Create("MSDPanelList", base)
	base.panelPLY:SetSize(sw - sw / 4, 200)
	base.panelPLY:SetPos(sw / 6, sh - sh / 3)
	base.panelPLY:EnableVerticalScrollbar()
	base.panelPLY:EnableHorizontal(true)
	base.panelPLY:SetSpacing(2)
	base.panelPLY:SetAlpha(1)
	base.panelPLY.IgnoreVbar = true

	base.panelPLY.UpdateF = function()
		base.panelPLY:Clear()
	end

	base.panelNPC = vgui.Create("DPanel", base)
	base.panelNPC:SetSize(sw - sw / 4, 300)
	base.panelNPC:SetPos(sw / 6, 50)
	base.panelNPC.line = ""
	base.panelNPC.text = ""
	base.panelNPC.typepos = 0
	base.panelNPC.typetime = 0

	base.panelNPC.Paint = function(self, w, h)
		MSD.DrawTexturedRect(0, 0, w, h, theme.Mats.grad, color_black)
		MSD.DrawTexturedRect(w / 2 - 300, 0, 600, 80, theme.Mats.top, color_white)
		MSD.DrawTexturedRect(w / 2 - 200, h - 80, 400, 60, theme.Mats.but, color_white)
		local text = MSD.TextWrap(self.line, "MCS_HKMain", w - 5)
		draw.DrawText(text, "MCS_HKMain", 1, 86, color_black, TEXT_ALIGN_LEFT)
		draw.DrawText(text, "MCS_HKMain", 0, 85, color_white, TEXT_ALIGN_LEFT)
		local _, th = surface.GetTextSize(text)

		if 160 + th > h then
			self:SetSize(w, 160 + th)
			local sx = base.panelPLY:GetPos()
			base.panelPLY:SetSize(base.panelPLY:GetWide(), self:GetTall() - 80)
			base.panelPLY:SetPos(sx, self:GetTall() + 80)
		end
	end

	base.panelNPC.Think = function(self)
		local CT = CurTime()

		if (CT > self.typetime) and self.text ~= self.line and base:GetAlpha() > 150 then
			self.typepos = self.typepos + 1
			self.typetime = CT + FrameTime() * textspd
			self.line = string.subUTF8(self.text, 1, self.typepos)

			if input.IsMouseDown(MOUSE_FIRST) then
				self.typetime = CT + 10
				self.typepos = string.len(self.text)
				self.line = self.text
			end
		end

		if self.text == self.line and base.panelPLY and not self.changed then
			self.changed = true
			base.panelPLY:AlphaTo(255, 0.3, 0.3)
		end
	end
end

theme.FrameUpdate = function(base, dialog)
	base.panelNPC.typepos = 0
	base.panelNPC.typetime = 0
	base.panelNPC.changed = nil
	base.panelNPC.text = dialog["Line"]
	base.panelNPC.line = ""
	base.panelNPC:SetSize(base.panelNPC:GetSize(), 300)
	base.panelPLY:SetAlpha(0)
	base.panelPLY.UpdateF()
end

theme.PopulateAns = function(base, k, ans)
	local button = vgui.Create("DButton", bg)

	button.StaticScale = {
		w = 1,
		fixed_h = 50,
		minw = 200,
		minh = 50
	}

	button:SetText("")
	button.fade = 0

	button.Paint = function(self, w, h)
		if self.hover then
			self.fade = Lerp(FrameTime() * 7, self.fade, 1)
		else
			self.fade = Lerp(FrameTime() * 7, self.fade, 0)
		end

		if self.fade > 0.01 then
			surface.SetFont("MCS_HKMain")
			local tw = surface.GetTextSize(ans[1])
			MSD.DrawTexturedRect(w / 2 - tw, 0, tw * 2, h, theme.Mats.grad, MSD.ColorAlpha(color_black, 255 * self.fade))
			MSD.DrawTexturedRectRotated(180, (w / 2 - tw / 2) - 44 * self.fade, h / 2, 44 * self.fade, 35 * self.fade, theme.Mats.opt, color_white)
			MSD.DrawTexturedRectRotated(0, (w / 2 + tw / 2) + 44 * self.fade, h / 2, 44 * self.fade, 35 * self.fade, theme.Mats.opt, color_white)
		end

		draw.SimpleText(ans[1], "MCS_HKMain", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, 1)
	end

	button.DoClick = function()
		if base.panelPLY:GetAlpha() > 200 then
			base.DoAnswer(ans)
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