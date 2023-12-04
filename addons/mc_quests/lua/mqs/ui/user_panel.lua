function MQS.OpenPlayerMenu()
	if MQS.SetupMenu then
		MQS.SetupMenu:AlphaTo(0, 0.4, 0, function()
			MQS.SetupMenu:Close()
		end)

		return
	end

	local tasks = MQS.ActiveQuestLists()
	local pnl_w, pnl_h = ScrW(), ScrH()
	pnl_w, pnl_h = pnl_w - pnl_w / 4, pnl_h - pnl_h / 6
	panel = vgui.Create("MSDSimpleFrame")
	panel:SetSize(pnl_w, pnl_h)
	panel:SetDraggable(false)
	panel:Center()
	panel:MakePopup()
	panel:SetAlpha(0)
	panel:AlphaTo(255, 0.3)

	panel.OnClose = function()
		MQS.SetupMenu = nil
	end

	panel:SetAlpha(1)
	panel:AlphaTo(255, 0.4)

	panel.Paint = function(self, w, h)
		MSD.DrawBG(self, w, h)

		draw.RoundedBox(MSD.Config.Rounded, 0, 0, w, 50, MSD.Theme["d"])
		draw.RoundedBox(MSD.Config.Rounded, 0, 52, w, h - 52, MSD.Theme["l"])

		draw.DrawText(string.upper(MSD.GetPhrase("quests")), "MSDFont.25", 12, 12, color_white, TEXT_ALIGN_LEFT)
	end

	panel.clsBut = MSD.IconButton(panel, MSD.Icons48.cross, panel:GetWide() - 34, 10, 25, nil, MSD.Config.MainColor.p, function()
		if panel.OnPress then
			panel.OnPress()

			return
		end

		panel:AlphaTo(0, 0.4, 0, function()
			panel:Close()
		end)
	end)

	panel.Canvas = vgui.Create("MSDPanelList", panel)
	panel.Canvas:SetSize(panel:GetWide(), panel:GetTall() - 52)
	panel.Canvas:SetPos(0, 52)
	panel.Canvas:EnableVerticalScrollbar()
	panel.Canvas:EnableHorizontal(true)
	panel.Canvas:SetSpacing(5)
	panel.Canvas.IgnoreVbar = true

	for k, v in pairs(MQS.Quests) do
		if not tasks[k] then continue end
		local qpnl = vgui.Create("DButton")
		qpnl:SetText("")
		qpnl.alpha = 0
		qpnl.title = 0
		qpnl.StaticScale = {
			w = 2,
			h = 5,
			minw = 200,
			minh = 120
		}

		qpnl.Paint = function(self, w, h)
			if self.hover then
				self.alpha = Lerp(FrameTime() * 5, self.alpha, 1)
			else
				self.alpha = Lerp(FrameTime() * 5, self.alpha, 0)
			end

			draw.RoundedBox(MSD.Config.Rounded, 0, 0, w, h, MSD.Theme["d"])

			draw.RoundedBox(MSD.Config.Rounded, 0, 0, self.title + 16, 45, MSD.Theme["d"])
			self.title = draw.SimpleText(v.name, "MSDFont.25", 8, 8, color_white, TEXT_ALIGN_LEFT)

			draw.DrawText(MSD.GetPhrase("q_start"), "MSDFont.25", 26 + self.title, 8, MSD.ColorAlpha(MSD.Config.MainColor["p"], self.alpha * 255), TEXT_ALIGN_LEFT)
			draw.DrawText(MSD.GetPhrase("q_start"), "MSDFont.25", 26 + self.title, 8, MSD.ColorAlpha(MSD.Text["d"], 255 - self.alpha * 255), TEXT_ALIGN_LEFT)

			local text = MSD.TextWrap(v.desc, "MSDFont.28", w - 16)
			draw.DrawText(text, "MSDFont.22", 8, 50, MSD.Text["d"], TEXT_ALIGN_LEFT)

			return true
		end

		qpnl.OnCursorEntered = function(self)
			self.hover = true
		end

		qpnl.OnCursorExited = function(self)
			self.hover = false
		end

		qpnl.DoClick = function(self)
			panel:Close()
			net.Start("MQS.StartTask")
			net.WriteString(k)
			net.SendToServer()
		end

		panel.Canvas:AddItem(qpnl)
	end

	MQS.SetupMenu = panel

	return panel
end