--  _______               __          _______  __                   __          _______  ______  ______        
-- |   |   |.---.-..----.|  |.-----. |     __||__|.--------..-----.|  |.-----. |    |  ||   __ \|      |.-----.
-- |       ||  _  ||  __| |_||__ --| |__     ||  ||        ||  _  ||  ||  -__| |       ||    __/|   ---||__ --|
-- |__|_|__||___._||____|    |_____| |_______||__||__|__|__||   __||__||_____| |__|____||___|   |______||_____|
--                                                          |__|                                               
----------------------------------------------------------------------------------------------------------------
------------------------- Warning! Edit this only if you know what are you doing -------------------------------
----------------------------------------------------------------------------------------------------------------

net.Receive("MCS.OpenMenu", function()
	local npc = net.ReadEntity()
	if not IsValid(npc) then return end
	local theme = MCS.Spawns[npc:GetUID()].theme
	MCS.OpenDialogue(npc, theme)
end)

MCS.OpenDialogue = function(npc, theme, test)
	if not IsValid(npc) and not test then return end

	if not theme then
		theme = "Default"
	end

	if MCS.Dialogue then return end

	local npc_table = test or MCS.Spawns[npc:GetUID()]

	if not npc_table.dialogs then return end

	theme = MCS.Themes[theme]
	theme.InProgress = true
	local testmode = MCS.Config.DebugMode

	if test then
		testmode = true
	end

	MCS.Dialogue = vgui.Create("DFrame")
	MCS.Dialogue:SetSize(ScrW(), ScrH())
	MCS.Dialogue:Center()
	MCS.Dialogue:MakePopup()
	MCS.Dialogue:SetDraggable(false)
	MCS.Dialogue:ShowCloseButton(testmode)
	MCS.Dialogue:SetTitle("")
	MCS.Dialogue.History = {}
	MCS.Dialogue.HtrProgress = 0
	MCS.Dialogue.Progress = 0
	MCS.Dialogue.ShowHint = true
	MCS.Dialogue.NPC = npc
	MCS.Dialogue.npc_table = npc_table
	MCS.Dialogue.dialogs = npc_table.dialogs

	MCS.Dialogue.DoClose = function()
		if theme.OnClose then
			theme.OnClose(MCS.Dialogue)
		end

		MCS.Dialogue:AlphaTo(0, 0.5, 0, function()
			MCS.Dialogue:Close()
		end)
	end

	MCS.Dialogue.OnClose = function()
		if MCS.Dialogue.Sound then
			MCS.Dialogue.Sound:Stop()
			MCS.Dialogue.Sound = nil
		end

		MCS.Dialogue = nil
		theme.InProgress = false

		if IsValid(npc) and npc:GetInputLimit() then
			net.Start("MCS.CloseMenu")
			net.WriteEntity(npc)
			net.SendToServer()
		end
	end

	MCS.Dialogue.Paint = function(self, w, h)
		theme.FramePaint(self, w, h)
	end

	MCS.Dialogue.Think = function()
		if theme.Process then
			theme.Process(MCS.Dialogue)
		end
	end

	if theme.FadeIn then
		MCS.Dialogue:SetAlpha(1)
		MCS.Dialogue:AlphaTo(255, 0.3)
	end

	theme.FrameBuild(MCS.Dialogue)

	MCS.Dialogue.OpenDialogue = function(dialog, id)
		if IsValid(MCS.Dialogue.Sound) then
			MCS.Dialogue.Sound:Stop()
			MCS.Dialogue.Sound = nil
		end

		MCS.Dialogue.HtrProgress = MCS.Dialogue.HtrProgress + 1

		MCS.Dialogue.History[MCS.Dialogue.HtrProgress] = {
			line = dialog["Line"],
			ans = ""
		}

		theme.FrameUpdate(MCS.Dialogue, dialog)

		if table.IsEmpty(dialog["Answers"]) then
			theme.PopulateAns(MCS.Dialogue, 1, {"...", "close"})
		else
			for k, ans in pairs(dialog["Answers"]) do
				if ans[4] and not ans[4]() then continue end
				theme.PopulateAns(MCS.Dialogue, k, ans, id)
			end
		end

		if npc_table.vos then
			dialog["Sound"] = npc_table.vos(id)
		end

		local dcalb = dialog["CallBack"]

		if dcalb and MCS.AddonList[dcalb.name] then
			if MCS.AddonList[dcalb.name]["function_sv"] then
				net.Start("MCS.Dialogue")
					net.WriteUInt(id, 15)
					net.WriteUInt(0, 15)
					net.WriteEntity(npc)
				net.SendToServer()
			end

			if MCS.AddonList[dcalb.name]["function"] then
				MCS.AddonList[dcalb.name]["function"](npc, dcalb.data)
			end
		end

		if dialog["Sound"] and dialog["Sound"] ~= "" then
			local url = false
			local soundpath = dialog["Sound"]
			if string.StartWith(soundpath, "http") then
				url = true
			end

			if not string.StartWith(soundpath, "sound/") and not url then
				soundpath = "sound/" .. soundpath
			end

			if url then
				sound.PlayURL(soundpath, "noplay", function(station)
					if IsValid(MCS.Dialogue) and IsValid(station) then
						MCS.Dialogue.Sound = station
						MCS.Dialogue.Sound:Play()
						MCS.Dialogue.Sound:SetVolume(dialog["SoundVolume"] or 1)
					else
						print("[MCS] Invalid sound URL", soundpath)
					end
				end)
			else
				sound.PlayFile(soundpath, "noplay", function(station, errCode, errStr)
					if (IsValid(station)) then
						MCS.Dialogue.Sound = station
						MCS.Dialogue.Sound:Play()
						MCS.Dialogue.Sound:SetVolume(dialog["SoundVolume"] or 1)
					else
						print("[MCS] Error playing sound", soundpath, errCode, errStr)
					end
				end)
			end
		end
	end

	MCS.Dialogue.DoAnswer = function(ans, sid, mid)
		if MCS.Dialogue:GetAlpha() < 255 then return end
		MCS.Dialogue.History[MCS.Dialogue.HtrProgress].ans = ans[1]

		if isnumber(ans[2]) and MCS.Dialogue.dialogs[ans[2]] then
			MCS.Dialogue.OpenDialogue(MCS.Dialogue.dialogs[ans[2]], ans[2])
		elseif istable(ans[2]) then
			if ans[2].id and MCS.AddonList[ans[2].id] and MCS.AddonList[ans[2].id]["enabled"] then
				local id = ans[2].id

				if MCS.AddonList[id]["function"] then
					MCS.AddonList[id]["function"](npc, ans[2].data)
				end

				if MCS.AddonList[id]["function_sv"] then
					net.Start("MCS.Dialogue")
						net.WriteUInt(mid, 15)
						net.WriteUInt(sid, 15)
						net.WriteEntity(npc)
					net.SendToServer()
				end

				if ans[2].openid then
					MCS.Dialogue.OpenDialogue(ans[2].openid)
					return
				end

				if not MCS.AddonList[id]["donotclose"] then
					MCS.Dialogue.DoClose()
				end

				return
			end

			local random_v = ans[2][math.random(#ans[2])]

			if MCS.Dialogue.dialogs[random_v] then
				MCS.Dialogue.OpenDialogue(MCS.Dialogue.dialogs[random_v], random_v)
			end
		else
			if MCS.AddonList[ans[2]] and MCS.AddonList[ans[2]]["enabled"] then
				if MCS.AddonList[ans[2]]["function"] then
					MCS.AddonList[ans[2]]["function"](npc)
				end

				if MCS.AddonList[ans[2]]["function_sv"] then
					net.Start("MCS.Dialogue")
						net.WriteUInt(mid, 15)
						net.WriteUInt(sid, 15)
						net.WriteEntity(npc)
					net.SendToServer()
				end
			end

			if MCS.AddonList[ans[2]] and MCS.AddonList[ans[2]]["donotclose"] then return end
			MCS.Dialogue.DoClose()
		end

		if ans[3] then
			ans[3](npc)
		end

		if npc and npc.GetInputLimit and npc:GetInputLimit() and ans[5] and isstring(ans[5]) then
			net.Start("MCS.SrartAnimation")
			net.WriteEntity(npc)
			net.WriteString(ans[5])
			net.SendToServer()
		end
	end

	if not npc then
		MCS.Dialogue.OpenDialogue(MCS.Dialogue.dialogs[1], 1)
		return
	end

	local npc_t = MCS.Spawns[npc:GetUID()]

	if MQS and MQS.HasQuest() then
		local q = MQS.HasQuest()
		local obj = MQS.GetNWdata(LocalPlayer(), "quest_objective")
		obj = MQS.Quests[q.quest].objects[obj]

		if obj.type == "Talk to NPC" and obj.npc == npc:GetUID() then
			if npc_t and npc_t.quest_random then
				local random_v = npc_t.quest_random[math.random(#npc_t.quest_random)]
				MCS.Dialogue.OpenDialogue(MCS.Dialogue.dialogs[random_v], random_v)
			else
				MCS.Dialogue.OpenDialogue(MCS.Dialogue.dialogs[obj.dialog], obj.dialog)
			end
			return
		end
	end

	if npc_table.teams and npc_table.teams[LocalPlayer():Team()] then
		MCS.Dialogue.OpenDialogue(MCS.Dialogue.dialogs[npc_table.teams[LocalPlayer():Team()]], npc_table.teams[LocalPlayer():Team()])
		return
	end

	if npc_t and npc_t.random_dialog then
		local random_v = npc_t.random_dialog[math.random(#npc_t.random_dialog)]
		MCS.Dialogue.OpenDialogue(MCS.Dialogue.dialogs[random_v], random_v)
	else
		MCS.Dialogue.OpenDialogue(MCS.Dialogue.dialogs[1], 1)
	end
end

MCS.Themes["Default"] = {}
local theme = MCS.Themes["Default"]

theme.Colors = {
	main = MCS.Config.Main.NPCColor,
	sub = MCS.Config.Main.PlayerColor,
	gray = Color(155,155,155),
}

theme.Mats = {
	grad = Material("gui/center_gradient.vtf"),
}

theme.FadeIn = true
theme.InProgress = false
theme.DrawPlayer = true

theme.Cam = {
	pos = Vector(0, 0, 0),
	ang = Angle(0, 0, 0),
	fov = 90,
	state = 1,
	rotate = 210,
	laste_change = 0,
	state_change = 10,
}

theme.Process = function(base)
	local ent
	local CT = CurTime()
	local npc = base.NPC
	local ply = LocalPlayer()

	if not IsValid(npc) then
		ent = ply
		theme.Cam.state = nil
	end

	if theme.Cam.state == 1 then
		ent = npc
	else
		ent = ply
	end

	local head = ent:LookupBone("ValveBiped.Bip01_Head1")
	if not head then return end
	local sPos, sAng = ent:GetBonePosition(head)
	if not sPos then return end

	if theme.Cam.laste_change < CT then
		theme.Cam.laste_change = CT + 30
		theme.Cam.state_change = -theme.Cam.state_change
		theme.Cam.rotate = math.Rand(20, 22) * theme.Cam.state_change
	end

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

	local speed = FrameTime() * 3
	if base.Closing then
		tr.HitPos = ply:EyePos()
		sAng = ply:GetAngles()
		speed = FrameTime() * 8
		theme.DrawPlayer = false
	end

	theme.Cam.pos = LerpVector(speed, theme.Cam.pos, tr.HitPos)
	theme.Cam.ang = LerpAngle(speed, theme.Cam.ang, sAng)
	theme.Cam.fov = Lerp(speed, theme.Cam.fov, theme.Cam.state == 1 and 55 or 90)
end

theme.OnClose = function(base)
	base.Closing = true
end

theme.FramePaint = function(self, w, h)
	if MCS.Config.Main.Vignette then
		MSD.DrawTexturedRect(0, 0, w, h, MSD.Materials.vignette, color_black)
	end
end

theme.FrameBuild = function(base)
	theme.DrawPlayer = true
	theme.Colors = {
		main = MCS.Config.Main.NPCColor,
		sub = MCS.Config.Main.PlayerColor,
		gray = Color(155,155,155),
	}

	local sw, sh = base:GetWide(), base:GetTall()
	local textspd = math.Clamp(MCS.Config.TextSpeed, 1, 10)
	base.panelPLY = vgui.Create("MSDPanelList", base)
	base.panelPLY:SetSize(sw - sw / 4, 200)
	base.panelPLY:SetPos(sw / 6, sh - sh / 3 + 10)
	base.panelPLY:EnableVerticalScrollbar()
	base.panelPLY:EnableHorizontal(true)
	base.panelPLY:SetSpacing(2)
	base.panelPLY:SetAlpha(1)
	base.panelPLY.IgnoreVbar = false
	base.panelPLY.Paint = function(self, w, lh)
		if MCS.Config.Main.Frame then
			local h = self:GetCanvas():GetTall() + 5
			if h > lh then h = lh end
			draw.RoundedBox(0, 0, 0, w, h, MSD.Theme.m)
			MCS.Blur(self, 2, 2, 255, w, h)
			MCS.Frame(0, 0, w, h, 10,  MSD.Theme.d, theme.Colors.gray)
		end
	end

	base.panelPLY.UpdateF = function()
		base.panelPLY:Clear()
		local plyName = vgui.Create("Panel")

		plyName.StaticScale = {
			w = 1,
			fixed_h = 45,
			minw = 200,
			minh = 45
		}

		plyName.Paint = function(self, w, h)
			draw.DrawText(LocalPlayer():GetName(), "MSDFont.32", w - 1, 1, color_black, TEXT_ALIGN_RIGHT)
			draw.DrawText(LocalPlayer():GetName(), "MSDFont.32", w, 0, theme.Colors.sub, TEXT_ALIGN_RIGHT)
		end

		base.panelPLY:AddItem(plyName)
	end

	base.panelNPC = vgui.Create("DPanel", base)
	base.panelNPC:SetSize(sw - sw / 4, 55)
	base.panelNPC:SetPos(sw / 6, sh - sh / 3)
	base.panelNPC.line = ""
	base.panelNPC.text = ""
	base.panelNPC.typepos = 0
	base.panelNPC.typetime = 0

	base.panelNPC.Paint = function(self, w, h)

		if MCS.Config.Main.Frame then
			draw.RoundedBox(0, 0, 0, w, h, MSD.Theme.m)
			MCS.Blur(self, 2, 2, 255, w, h)
			MCS.Frame(0, 0, w, h, 10,  MSD.Theme.d, theme.Colors.gray)
		end

		draw.DrawText(base.npc_table.name, "MSDFont.32", 11, 1, color_black, TEXT_ALIGN_LEFT)
		draw.DrawText(base.npc_table.name, "MSDFont.32", 10, 0, theme.Colors.main, TEXT_ALIGN_LEFT)
		local text = MSD.TextWrap(self.line, "MSDFont.25", w - 15)
		draw.DrawText(text, "MSDFont.25", 11, 46, color_black, TEXT_ALIGN_LEFT)
		draw.DrawText(text, "MSDFont.25", 10, 45, color_white, TEXT_ALIGN_LEFT)
		local _, th = surface.GetTextSize(text)

		if 55 + th > h then
			self:SetSize(w, 55 + th)
			local y = ScrH() / 2
			local sx = base.panelPLY:GetPos()
			base.panelPLY:SetSize(base.panelPLY:GetWide(), y - (self:GetTall()) - 35)
			base.panelPLY:SetPos(sx, y + self:GetTall() + 25)
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
			theme.Cam.state = 2
			base.panelPLY:AlphaTo(255, 0.3, 0.3)
			base.panelNPC:MoveTo(sw / 6, sh / 2, 0.3)
		end
	end
end

theme.FrameUpdate = function(base, dialog)
	base.panelNPC.typepos = 0
	base.panelNPC.typetime = 0
	base.panelNPC.changed = nil
	base.panelNPC.text = dialog["Line"]
	base.panelNPC.line = ""
	base.panelNPC:SetTall(55)
	base.panelPLY:SetAlpha(0)
	base.panelPLY.UpdateF()
	theme.Cam.laste_change = CurTime() + 30
	theme.Cam.state = 1
end

theme.PopulateAns = function(base, k, ans, mid)
	local button = vgui.Create("DButton", bg)

	button.StaticScale = {
		w = 1,
		fixed_h = 27,
		minw = 200,
		minh = 27
	}

	button:SetText("")
	button.fade = 0

	button.Paint = function(self, w, h)
		if self.hover then
			self.fade = Lerp(FrameTime() * 7, self.fade, 1)
		else
			self.fade = Lerp(FrameTime() * 7, self.fade, 0)
		end

		local text, _, texth = MSD.TextWrap(ans[1], "MSDFont.25", w - 5)

		if texth > self.StaticScale.minh and w > 200 then
			self.StaticScale.minh = texth
			self.StaticScale.fixed_h = texth
			base.panelPLY:PerformLayout()
		end

		draw.DrawText(text, "MSDFont.25", w - 1, 1, color_black, TEXT_ALIGN_RIGHT)
		draw.DrawText(text, "MSDFont.25", w, 0, MSD.ColorAlpha(color_white, 255 - self.fade * 255), TEXT_ALIGN_RIGHT)
		draw.DrawText(text, "MSDFont.25", w, 0,  MSD.ColorAlpha(theme.Colors.main, self.fade * 255), TEXT_ALIGN_RIGHT)
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

hook.Add("HUDShouldDraw", "MCS.DefaultTheme.HideHUD", function()
	if theme.InProgress then return false end
end)

hook.Add("CalcView", "MCS.DefaultTheme.CalcView", function(ply, pos, angles, fov)
	if not MCS.Config.EnableCamera then return end
	if theme.InProgress then
		local view = {
			origin = theme.Cam.pos,
			angles = theme.Cam.ang,
			fov = theme.Cam.fov,
			drawviewer = theme.DrawPlayer
		}

		return view
	else
		theme.Cam.fov = fov
	end
end)