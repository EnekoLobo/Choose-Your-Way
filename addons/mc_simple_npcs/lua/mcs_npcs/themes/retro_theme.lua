MCS.Themes["Retro"] = {}
if SERVER then return end
local NewFont = surface.CreateFont

NewFont("MCS_RetroMain", {
	font = "DPix_8pt",
	extended = true,
	size = 25,
	antialias = true,
	weight = 800
})

NewFont("MCS_RetroSub", {
	font = "DPix_8pt",
	extended = true,
	size = 32,
	antialias = true,
	weight = 800
})

local theme = MCS.Themes["Retro"]
theme.FadeIn = true
theme.InProgress = false

theme.Cam = {
	pos = Vector(0, 0, 0),
	ang = Angle(0, 0, 0),
	fov = 90,
	rotate = 180,
}

theme.Process = function(base)
	if not MCS.Config.EnableCamera then return end
	local ent
	local npc = base.NPC
	local ply = LocalPlayer()

	if not IsValid(npc) then
		ent = ply
	else
		ent = npc
	end

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
		endpos = sPos - sAng:Forward() * 45,
		filter = ent
	})

	theme.Cam.pos = LerpVector(FrameTime() * 3, theme.Cam.pos, tr.HitPos)
	theme.Cam.ang = LerpAngle(FrameTime() * 3, theme.Cam.ang, sAng)
	theme.Cam.fov = Lerp(FrameTime() * 3, theme.Cam.fov, 60)
end

theme.FramePaint = function(self, w, h) end

theme.FrameBuild = function(base)
	local sw, sh = base:GetWide(), base:GetTall()
	local textspd = math.Clamp(MCS.Config.TextSpeed, 1, 10)
	base.panelPLY = vgui.Create("MSDPanelList", base)
	base.panelPLY:SetSize(sw - sw / 4, 200)
	base.panelPLY:SetPos(sw / 6, sh / 2 + 100)
	base.panelPLY:EnableVerticalScrollbar()
	base.panelPLY:EnableHorizontal(true)
	base.panelPLY:SetSpacing(2)
	base.panelPLY:SetAlpha(1)
	base.panelPLY.IgnoreVbar = true

	base.panelPLY.UpdateF = function()
		base.panelPLY:Clear()
	end

	base.panelNPC = vgui.Create("DPanel", base)
	base.panelNPC:SetSize(sw - sw / 4, 50)
	base.panelNPC:SetPos(sw / 6, sh / 2 + 100)
	base.panelNPC.line = ""
	base.panelNPC.text = ""
	base.panelNPC.typepos = 0
	base.panelNPC.typetime = 0

	base.panelNPC.Paint = function(self, w, h)
		draw.RoundedBox(8, 0, 0, w, h, color_black)
		draw.DrawText(base.npc_table.name, "MCS_RetroSub", 10, 5, MCS.Config.Retro.Color, TEXT_ALIGN_LEFT)
		local text = MSD.TextWrap(self.line, "MCS_RetroMain", w - 20)
		draw.DrawText(text, "MCS_RetroMain", 10, 35, color_white, TEXT_ALIGN_LEFT)
		local _, th = surface.GetTextSize(text)

		if 50 + th > h then
			self:SetSize(w, 50 + th)
			local y = ScrH() / 2 + 100
			local sx = base.panelPLY:GetPos()
			base.panelPLY:SetSize(base.panelPLY:GetWide(), y - self:GetTall() - 20)
			base.panelPLY:SetPos(sx, y + self:GetTall() + 20)
		end
	end

	base.panelNPC.Think = function(self)
		local CT = CurTime()

		if (CT > self.typetime) and self.text ~= self.line and base:GetAlpha() > 150 then
			self.typepos = self.typepos + 1
			self.typetime = CT + FrameTime() * textspd
			self.line = string.subUTF8(self.text, 1, self.typepos)

			if MCS.Config.Retro.SFX then
				CreateSound(LocalPlayer(), "weapons/grenade/tick1.wav"):PlayEx(0.1, math.random(177, 200))
			end

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
	base.panelNPC:SetSize(base.panelNPC:GetSize(), 50)
	base.panelPLY:SetAlpha(0)
	base.panelPLY.UpdateF()
end

theme.PopulateAns = function(base, k, ans, mid)
	local button = vgui.Create("DButton", bg)

	button.StaticScale = {
		w = 1,
		fixed_h = 50,
		minw = 200,
		minh = 50
	}

	button:SetText("")

	button.Paint = function(self, w, h)
		draw.RoundedBox(8, 0, 0, w, h, color_black)

		if self.hover then
			draw.RoundedBox(8, 0, 0, w, h, MCS.Config.Retro.Color)
		end

		draw.RoundedBox(6, 2, 2, w - 4, h - 4, color_black)
		draw.DrawText(ans[1], "MCS_RetroSub", w / 2, 6, color_white, TEXT_ALIGN_CENTER)
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

hook.Add("HUDShouldDraw", "MCS.Retro.HideHUD", function()
	if theme.InProgress then return false end
end)

hook.Add("CalcView", "MCS.Retro.CalcView", function(ply, pos, angles, fov)
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