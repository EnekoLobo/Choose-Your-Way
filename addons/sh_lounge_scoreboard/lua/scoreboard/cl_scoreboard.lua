local matList = Material("shenesis/f4menu/list.png", "noclamp smooth")
local matUser = Material("shenesis/f4menu/user.png", "noclamp smooth")
local matPrevious = Material("shenesis/f4menu/previous.png", "noclamp smooth")
local matClose = Material("shenesis/f4menu/close.png", "noclamp smooth")

local font = LOUNGE_TAB.Font
local font_bold = LOUNGE_TAB.FontBold
local font_italic = LOUNGE_TAB.FontItalic

--
local function GetUserGroup(ply)
	if (LOUNGE_TAB.UsergroupMode == 1) then
		return serverguard.player:GetRank(ply)
	else
		return ply:GetUserGroup()
	end
end

function LT_QuickLabel(t, f, c, p)
	local l = vgui.Create("DLabel", p)
	l:SetText(t)
	l:SetFont(f)
	l:SetColor(c)
	l:SizeToContents()

	return l
end

function LT_PaintScroll(panel)
	local styl = LOUNGE_TAB.Style

	local scr = panel:GetVBar()
	scr.Paint = function(_, w, h)
		draw.RoundedBox(4, 0, 0, w, h, styl.bg)
	end

	scr.btnUp.Paint = function(_, w, h)
		draw.RoundedBox(4, 2, 0, w - 4, h - 2, styl.inbg)
	end
	scr.btnDown.Paint = function(_, w, h)
		draw.RoundedBox(4, 2, 2, w - 4, h - 2, styl.inbg)
	end

	scr.btnGrip.Paint = function(me, w, h)
		draw.RoundedBox(4, 2, 0, w - 4, h, styl.inbg)

		if (me.Hovered) then
			draw.RoundedBox(4, 2, 0, w - 4, h, styl.hover2)
		end

		if (me.Depressed) then
			draw.RoundedBox(4, 2, 0, w - 4, h, styl.hover2)
		end
	end
end

function LT_Menu()
	local styl = LOUNGE_TAB.Style

	if (IsValid(_LOUNGE_TAB_MENU)) then
		_LOUNGE_TAB_MENU:Remove()
	end

	local th = 48 * _LOUNGE_TAB_SCALE
	local m = th * 0.25

	local cancel = vgui.Create("DPanel")
	cancel:SetDrawBackground(false)
	cancel:StretchToParent(0, 0, 0, 0)
	cancel:MoveToFront()
	cancel:MakePopup()

	local pnl = vgui.Create("DPanel")
	pnl:SetDrawBackground(false)
	pnl:SetSize(20, 1)
	pnl.AddOption = function(me, text, callback)
		surface.SetFont("TAB_LOUNGE_MediumB")
		local wi, he = surface.GetTextSize(text)
		wi = wi + m * 2
		he = he + m

		me:SetWide(math.max(wi, me:GetWide()))
		me:SetTall(pnl:GetTall() + he)

		local btn = vgui.Create("DButton", me)
		btn:SetText(text)
		btn:SetFont("TAB_LOUNGE_MediumB")
		btn:SetColor(styl.text)
		btn:Dock(TOP)
		btn:SetSize(wi, he)
		btn.Paint = function(me, w, h)
			surface.SetDrawColor(styl.menu)
			surface.DrawRect(0, 0, w, h)

			if (me.Hovered) then
				surface.SetDrawColor(styl.hover)
				surface.DrawRect(0, 0, w, h)
			end

			if (me:IsDown()) then
				surface.SetDrawColor(styl.hover)
				surface.DrawRect(0, 0, w, h)
			end
		end
		btn.DoClick = function(me)
			callback()
			pnl:Close()
		end
	end
	pnl.Open = function(me)
		_LOUNGE_TAB:KillFocus()
		_LOUNGE_TAB:SetMouseInputEnabled(false)
		_LOUNGE_TAB:SetKeyboardInputEnabled(false)
	
		me:SetPos(gui.MouseX(), gui.MouseY())
		me:SetDrawOnTop(true)
		me:MakePopup()
		me:MoveToFront()
	end
	pnl.Close = function(me)
		if (me.m_bClosing) then
			return end

		me.m_bClosing = true
		me:AlphaTo(0, 0.1, 0, function()
			me:Remove()
		end)

		if (IsValid(_LOUNGE_TAB)) then
			_LOUNGE_TAB:MakePopup()
			_LOUNGE_TAB:SetMouseInputEnabled(true)
			_LOUNGE_TAB:SetKeyboardInputEnabled(true)
		end
	end
	_LOUNGE_TAB_MENU = pnl

	cancel.OnMouseReleased = function(me, mc)
		pnl:Close()
	end
	cancel.Think = function(me)
		if (!IsValid(pnl)) then
			me:Remove()
		end
	end

	return pnl
end

function LT_StringRequest(title, text, callback, def)
	local styl = LOUNGE_TAB.Style

	if (IsValid(_LOUNGE_TAB_STRREQ)) then
		_LOUNGE_TAB_STRREQ:Remove()
	end

	local scale = _LOUNGE_TAB_SCALE
	local wi, he = 600 * scale, 160 * scale

	local cancel = vgui.Create("DPanel")
	cancel:SetDrawBackground(false)
	cancel:StretchToParent(0, 0, 0, 0)
	cancel:MoveToFront()
	cancel:MakePopup()

	local pnl = vgui.Create("EditablePanel")
	pnl:SetSize(wi, he)
	pnl:Center()
	pnl:MakePopup()
	pnl.m_fCreateTime = SysTime()
	pnl.Paint = function(me, w, h)
		Derma_DrawBackgroundBlur(me, me.m_fCreateTime)
		draw.RoundedBox(4, 0, 0, w, h, styl.bg)
	end
	pnl.Close = function(me)
		if (me.m_bClosing) then
			return end

		me.m_bClosing = true
		me:AlphaTo(0, 0.1, 0, function()
			me:Remove()
		end)
	end
	_LOUNGE_F4_STRREQ = pnl

	cancel.OnMouseReleased = function(me, mc)
		if (mc == MOUSE_LEFT) then
			pnl:Close()
		end
	end
	cancel.Think = function(me)
		if (!IsValid(pnl)) then
			me:Remove()
		end
	end

		local th = 48 * scale
		local m = th * 0.25

		local header = vgui.Create("DPanel", pnl)
		header:SetTall(th)
		header:Dock(TOP)
		header.Paint = function(me, w, h)
			draw.RoundedBoxEx(4, 0, 0, w, h, styl.header, true, true, false, false)
		end

			local titlelbl = LT_QuickLabel(title, "TAB_LOUNGE_Larger", styl.text, header)
			titlelbl:Dock(LEFT)
			titlelbl:DockMargin(m, 0, 0, 0)

			local close = vgui.Create("DButton", header)
			close:SetText("")
			close:SetWide(th)
			close:Dock(RIGHT)
			close.Paint = function(me, w, h)
				if (me.Hovered) then
					draw.RoundedBoxEx(4, 0, 0, w, h, styl.close_hover, false, true, false, false)
				end

				if (me:IsDown()) then
					draw.RoundedBoxEx(4, 0, 0, w, h, styl.hover, false, true, false, false)
				end

				surface.SetDrawColor(me:IsDown() and styl.text_down or styl.text)
				surface.SetMaterial(matClose)
				surface.DrawTexturedRectRotated(w * 0.5, h * 0.5, 16 * scale, 16 * scale, 0)
			end
			close.DoClick = function(me)
				pnl:Close()
			end

		local body = vgui.Create("DPanel", pnl)
		body:SetDrawBackground(false)
		body:Dock(FILL)
		body:DockPadding(m, m, m, m)

			local tx = LT_QuickLabel(text, "TAB_LOUNGE_Large", styl.text, body)
			tx:SetContentAlignment(5)
			tx:SetWrap(tx:GetWide() > wi - m * 2)
			tx:Dock(FILL)

			local apply = vgui.Create("DButton", body)
			apply:SetText("OK")
			apply:SetColor(styl.text)
			apply:SetFont("TAB_LOUNGE_Medium")
			apply:Dock(BOTTOM)
			apply.Paint = function(me, w, h)
				draw.RoundedBox(4, 0, 0, w, h, styl.inbg)

				if (me.Hovered) then
					surface.SetDrawColor(styl.hover)
					surface.DrawRect(0, 0, w, h)
				end

				if (me:IsDown()) then
					surface.SetDrawColor(styl.hover)
					surface.DrawRect(0, 0, w, h)
				end
			end

			local entry = vgui.Create("DTextEntry", body)
			entry:SetText(def or "")
			entry:RequestFocus()
			entry:SetFont("TAB_LOUNGE_Medium")
			entry:SetDrawLanguageID(false)
			entry:Dock(BOTTOM)
			entry:DockMargin(0, m, 0, m)
			entry.Paint = function(me, w, h)
				draw.RoundedBox(4, 0, 0, w, h, styl.textentry)
				me:DrawTextEntryText(me:GetTextColor(), me:GetHighlightColor(), me:GetCursorColor())
			end
			entry.OnEnter = function()
				apply:DoClick()
			end

			apply.DoClick = function()
				pnl:Close()
				callback(entry:GetValue())
			end

	pnl.OnFocusChanged = function(me, gained)
		if (!gained) then
			timer.Simple(0, function()
				if (!IsValid(me) or vgui.GetKeyboardFocus() == entry) then
					return end

				me:Close()
			end)
		end
	end

	pnl:SetWide(math.max(tx:GetWide() + m * 2, pnl:GetWide()))
	pnl:CenterHorizontal()

	pnl:SetAlpha(0)
	pnl:AlphaTo(255, 0.1)
end

function LT_FormatTime(time)
	local t = {}

	local w = math.floor(time / (86400 * 7))
	if (w > 0) then
		table.insert(t, w .. "w")
		time = time - w * (86400 * 7)
	end

	local d = math.floor(time / 86400)
	if (d > 0) then
		table.insert(t, d .. "d")
		time = time - d * 86400
	end

	local h = math.floor(time / 3600)
	if (h > 0) then
		table.insert(t, h .. "h")
		time = time - h * 3600
	end

	local m = math.floor(time / 60)
	if (m > 0) then
		table.insert(t, m .. "m")
		time = time - m * 60
	end

	local s = math.floor(time)
	if (s > 0) then
		table.insert(t, s .. "s")
	end

	return table.concat(t, " ")
end

local function rainbowThink(me)
	me.m_iHue = (me.m_iHue + FrameTime() * math.min(150, me.m_iRate)) % 360
	me:SetFGColor(HSVToColor(me.m_iHue, 1, 1))
end

function LOUNGE_TAB:Show()
	if (IsValid(_LOUNGE_TAB)) then
		_LOUNGE_TAB:Remove()
	end

	local curpage

	local scale = math.Clamp(ScrH() / 1080, 0.7, 1)
	_LOUNGE_TAB_SCALE = scale

	surface.CreateFont("TAB_LOUNGE_Small", {font = font, size = 14 * scale})
	surface.CreateFont("TAB_LOUNGE_Medium", {font = font, size = 16 * scale})
	surface.CreateFont("TAB_LOUNGE_Large", {font = font, size = 20 * scale})
	surface.CreateFont("TAB_LOUNGE_Larger", {font = font, size = 24 * scale})
	surface.CreateFont("TAB_LOUNGE_SmallB", {font = font_bold, size = 14 * scale})
	surface.CreateFont("TAB_LOUNGE_MediumB", {font = font_bold, size = 16 * scale})
	surface.CreateFont("TAB_LOUNGE_LargeB", {font = font_bold, size = 20 * scale})
	surface.CreateFont("TAB_LOUNGE_LargerB", {font = font_bold, size = 24 * scale})
	surface.CreateFont("TAB_LOUNGE_MediumI", {font = font_italic, size = 16 * scale})
	surface.CreateFont("TAB_LOUNGE_LargeI", {font = font_italic, size = 20 * scale})
	surface.CreateFont("TAB_LOUNGE_LargerI", {font = font_italic, size = 24 * scale})

	local wi, he = (900 * self.WidthScale) * scale, (700 * self.HeightScale) * scale

	local pnl = vgui.Create("EditablePanel")
	pnl:SetSize(wi, he)
	pnl:Center()
	pnl.m_fCreateTime = SysTime()
	pnl:MoveToFront()
	pnl:SetZPos(99)
	pnl.Paint = function(me, w, h)
		if (self.DrawBackgroundBlur) then
			Derma_DrawBackgroundBlur(me, me.m_fCreateTime - 0.1)
		end

		draw.RoundedBox(4, 0, 0, w, h, self.Style.bg)
		me:MoveToFront()
		me:RequestFocus()
	end
	pnl.Close = function(me)
		if (me.m_bClosing) then
			return end

		me.m_bClosing = true
		me:AlphaTo(0, 0.1, 0, function()
			me:Remove()
			_TAB_LOUNGE_RESIZING = false
		end)
	end
	_LOUNGE_TAB = pnl

		local th = 48 * scale
		local m = th * 0.25
		local m5 = m * 0.5

		local header = vgui.Create("DPanel", pnl)
		header:SetTall(th)
		header:Dock(TOP)
		header.Paint = function(me, w, h)
			draw.RoundedBoxEx(4, 0, 0, w, h, self.Style.header, true, true, false, false)
		end

			local titlelbl = LT_QuickLabel(self.Title ~= "" and self.Title or GetHostName(), "TAB_LOUNGE_Larger", self.Style.text, header)
			titlelbl:Dock(FILL)
			titlelbl:DockMargin(m, 0, 0, 0)

			local lbl_playercount
			if (self.DisplayPlayerCount) then
				local pnl = vgui.Create("DPanel", header)
				pnl:Dock(RIGHT)
				pnl:DockMargin(0, m, m, m)

					local tx = LT_QuickLabel("0", "TAB_LOUNGE_LargerB", self.Style.text, pnl)
					tx:Dock(RIGHT)
					tx.Update = function(me)
						local cnt, max = #player.GetAll(), game.MaxPlayers()

						me:SetText(cnt .. "/" .. max)
						me:SetTextColor(cnt >= max and self.Style.full or self.Style.text)
						me:SizeToContents()

						pnl:SetWide(24 * scale + tx:GetWide() + m5)
					end
					lbl_playercount = tx

					tx:Update()

				pnl.Paint = function(me, w, h)
					surface.SetDrawColor(tx:GetTextColor())
					surface.SetMaterial(matUser)
					surface.DrawTexturedRectRotated(h * 0.5, h * 0.5, h, h, 0)
				end
			end

		local body = vgui.Create("DPanel", pnl)
		body:SetDrawBackground(false)
		body:Dock(FILL)

			local contents = vgui.Create("DScrollPanel", body)
			LT_PaintScroll(contents)
			contents:SetWide(wi - th)
			contents:Dock(FILL)
			contents:GetCanvas():DockPadding(m5, m5, m5, m5)

			local toggled = cookie.GetNumber("LoungeTab_ToggleOff", 1) == 1

			local navbar = vgui.Create("DPanel", body)
			navbar:SetWide(toggled and th or th * 3)
			navbar:Dock(LEFT)
			navbar:DockPadding(0, th, 0, 0)
			navbar.Paint = function(me, w, h)
				draw.RoundedBoxEx(4, 0, 0, w, h, self.Style.inbg, false, false, true, false)
			end

				local togglenavbar = vgui.Create("DButton", navbar)
				togglenavbar:SetText("")
				togglenavbar:SetToolTip(LOUNGE_TAB.Language.toggle)
				togglenavbar:SetSize(th, th)
				togglenavbar.Paint = function(me, w, h)
					surface.SetDrawColor(self.Style.text)
					surface.SetMaterial(matList)
					surface.DrawTexturedRectRotated(w * 0.5, h * 0.5, 24 * scale, 24 * scale, 0)
				end
				togglenavbar.DoClick = function()
					toggled = !toggled
					cookie.Set("LoungeTab_ToggleOff", toggled and 1 or 0)

					_TAB_LOUNGE_RESIZING = true
					navbar:Stop()
					navbar:SizeTo(toggled and th or th * 3, -1, 0.1, 0, 0.2, function()
						_TAB_LOUNGE_RESIZING = false
					end)
				end

				for _, page in ipairs (LOUNGE_TAB.Buttons) do
					if (page.display and !page.display()) then
						continue end

					local tx = LOUNGE_TAB.Language[page.text] or page.text

					local btn = vgui.Create("DButton", navbar)
					btn:SetText("")
					btn:SetToolTip(tx)
					btn:SetTall(th)
					btn:Dock(TOP)
					btn.Paint = function(me, w, h)
						if (me.Hovered) then
							surface.SetDrawColor(self.Style.hover)
							surface.DrawRect(0, 0, w, h)
						end

						if (me:IsDown()) then
							surface.SetDrawColor(self.Style.hover)
							surface.DrawRect(0, 0, w, h)
						end

						surface.SetDrawColor(self.Style.text)
						surface.SetMaterial(page.icon)
						surface.DrawTexturedRectRotated(24 * scale, 24 * scale, 24 * scale, 24 * scale, 0)
					end
					btn.DoClick = function()
						page.callback()
					end

						local lbl = LT_QuickLabel(tx, "TAB_LOUNGE_Medium", self.Style.text, btn)
						lbl:Dock(LEFT)
						lbl:DockMargin(th, 0, 0, 0)
				end

			local paint_line = function(me, w, h)
				if (me.m_Player ~= nil and !IsValid(me.m_Player)) then
					me:Close()
				end

				draw.RoundedBox(4, 0, 0, w, h, self.Style.inbg)

				if (me.Hovered) then
					surface.SetDrawColor(self.Style.hover2)
					surface.DrawRect(0, 0, w, h)
				end

				if (me:IsDown()) then
					surface.SetDrawColor(self.Style.hover2)
					surface.DrawRect(0, 0, w, h)
				end
			end

			local function PopulatePlayerList(ilist, filter)
				local players = {}
				for _, v in ipairs (player.GetAll()) do
					if (filter and !filter(v)) then
						continue end

					table.insert(players, v)
				end

				local colSort = self.PlayerColumns[self.PlayerSortBy]
				table.sort(players, function(a, b)
					if (self.SortAsc) then
						return colSort.func(a) < colSort.func(b)
					else
						return colSort.func(a) > colSort.func(b)
					end
				end)

				for _, v in ipairs (players) do
					if (self.DisplayFlag) and ((!self.OnlyAdminsSeeFlags or LocalPlayer():IsAdmin()) or v == LocalPlayer()) then
						if (!v.m_CountryCode) and (!v.m_fNextFlagRequest or CurTime() >= v.m_fNextFlagRequest) then
							v.m_fNextFlagRequest = CurTime() + 30

							net.Start("TAB_LOUNGE_CountryFlag")
								net.WriteEntity(v)
							net.SendToServer()
						end
					end

					local link, steamid = "http://steamcommunity.com/profiles/" .. (v:SteamID64() or "0"), v:SteamID()

					local line = vgui.Create("DButton", ilist)
					line:SetText("")
					line:SetTall((32 + m5 * 2) * scale)
					line:Dock(TOP)
					line:DockMargin(0, 0, 0, m5)
					line:DockPadding(m5, m5, m5, m5)
					line.m_Player = v
					line.Paint = paint_line
					line.Close = function(me)
						if (me.m_bClosing) then
							return end

						me.m_bClosing = true
						me:AlphaTo(0, 0.2, 0, function()
							me:SizeTo(-1, 0, 0.1, nil, nil, function()
								ilist:InvalidateLayout(true)
								me:Remove()

								if (IsValid(lbl_playercount)) then
									lbl_playercount:Update()
								end
							end)
						end)
					end
					line.DoClick = function(me)
						if (me.m_bClosing) then
							return end

						if (self.UsePlayerAdminMenu > 0) then
							local pnl = vgui.Create("DPanel", body)
							pnl:StretchToParent(navbar:GetWide(), 0, 0, 0)
							pnl:AlignLeft(navbar:GetWide() - pnl:GetWide())
							pnl:DockPadding(m5, m5, m5, m5)
							pnl:MoveToBefore(navbar)
							pnl.Paint = function(me, w, h)
								surface.SetDrawColor(self.Style.bg)
								surface.DrawRect(0, 0, w, h)
							end

								local top = vgui.Create("DPanel", pnl)
								top:SetDrawBackground(false)
								top:SetTall(32 * scale)
								top:Dock(TOP)

									local bak = vgui.Create("DButton", top)
									bak:SetText("")
									bak:SetWide(top:GetTall())
									bak:Dock(LEFT)
									bak.Paint = function(me, w, h)
										surface.SetDrawColor(color_white)
										surface.SetMaterial(matPrevious)
										surface.DrawTexturedRect(-m5, 0, w, h)
									end
									bak.DoClick = function()
										if (pnl.m_bClosing) then
											return end

										pnl.m_bClosing = true
										pnl:Stop()
										pnl.Think = function() end
										pnl:MoveTo(-pnl:GetWide(), -1, 0.3, nil, nil, function()
											pnl:Remove()
										end)
									end

								local pinfo = vgui.Create("DPanel", pnl)
								pinfo:SetTall(64 * scale + m5 * 2)
								pinfo:Dock(TOP)
								pinfo:DockMargin(0, m5, 0, 0)
								pinfo:DockPadding(m5, m5, m5, m5)
								pinfo.Paint = function(me, w, h)
									draw.RoundedBox(4, 0, 0, w, h, self.Style.inbg)
								end

									local av = vgui.Create("AvatarImage", pinfo)
									av:SetWide(64 * scale)
									av:SetPlayer(v, 64)
									av:Dock(LEFT)

									local info = vgui.Create("DIconLayout", pinfo)
									info:SetSpaceX(m5)
									info:SetLayoutDir(LEFT)
									info:Dock(FILL)
									info:DockMargin(m5, 0, 0, 0)

									if (self.UsePlayerAdminMenu == 1 and FAdmin) then
										for _, inf in pairs (FAdmin.ScoreBoard.Player.Information) do
											local val = inf.func(v)
											if (val) then
												LT_QuickLabel(inf.name .. ": " .. val, "TAB_LOUNGE_Medium", self.Style.text, info)
											end
										end
									elseif (self.UsePlayerAdminMenu == 2) then
										LT_QuickLabel(v:Nick(), "TAB_LOUNGE_Medium", self.Style.text, info)
										LT_QuickLabel(v:SteamID(), "TAB_LOUNGE_Medium", self.Style.text, info)
									end

								local acts = vgui.Create("DIconLayout", pnl)
								acts:SetSpaceX(m5)
								acts:SetSpaceY(m5)
								acts:Dock(FILL)
								acts:DockMargin(0, m5, 0, 0)

									local function CreateButton(tx, cb)
										local btn = vgui.Create("DButton", acts)
										btn:SetText(tx)
										btn:SetFont("TAB_LOUNGE_Medium")
										btn:SetColor(color_transparent)
										btn:SizeToContents()
										btn:SetWide(btn:GetWide() + m5 * 2)
										btn.Paint = function(me, w, h)
											paint_line(me, w, h)

											if (me.m_Image1) then
												surface.SetMaterial(me.m_Image1)
												surface.SetDrawColor(color_white)
												surface.DrawTexturedRect(m5, m5, 16, 16)
											end

											if (me.m_Image2) then
												surface.SetMaterial(me.m_Image2)
												surface.SetDrawColor(color_white)
												surface.DrawTexturedRect(m5, m5, 16, 16)
											end

											if (me.m_Image1 or me.m_Image2) then
												draw.SimpleText(me:GetText(), me:GetFont(), w - m5, h * 0.5, self.Style.text, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
											else
												draw.SimpleText(me:GetText(), me:GetFont(), w * 0.5, h * 0.5, self.Style.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
											end
										end
										btn.DoClick = function(s)
											local im = 0
											if (s.m_Image1 or s.m_Image2) then
												im = m5 + 18
											end

											cb(v, s)
											s:SizeToContentsX()
											s:SetWide(s:GetWide() + m5 * 2 + im)

											acts:Layout()
										end

										return btn
									end

									if (self.UsePlayerAdminMenu == 1 and FAdmin) then
										for _, inf in pairs (FAdmin.ScoreBoard.Player.ActionButtons) do
											if not (inf.Visible == true or (type(inf.Visible) == "function" and inf.Visible(v) == true)) then
												continue end

											local name = inf.Name
											if (isfunction(name)) then name = name(v) end

											local btn = CreateButton(DarkRP.deLocalise(name), function(v, s)
												inf.Action(v, s)
											end)
											btn.SetImage = function(me, im)
												me.m_Image1 = Material(im)
											end
											btn.SetImage2 = function(me, im)
												me.m_Image2 = Material(im)
											end

											if (inf.Image and LOUNGE_TAB.ShowFAdminIcons) then
												if (isstring(inf.Image)) then
													btn:SetImage(inf.Image)
												elseif (istable(inf.Image)) then
													btn:SetImage(inf.Image[1])
													if (inf.Image[2]) then
														btn:SetImage2(inf.Image[2])
													end
												elseif (isfunction(inf.Image)) then
													local img1, img2 = inf.Image(v)
													btn:SetImage(img1)
													if (img2) then btn:SetImage2(img2) end
												end

												btn:SetWide(btn:GetWide() + 16)
												btn:SetTall(math.max(btn:GetTall(), 16 + m5 * 2))
											end

											if (inf.OnButtonCreated) then
												inf.OnButtonCreated(v, btn)
											end
										end
									elseif (self.UsePlayerAdminMenu == 2 and ULib) then
										for cmd, data in pairs (ULib.cmds.translatedCmds) do
											-- local opposite = data.opposite
											if (opposite ~= cmd and (LocalPlayer():query(data.cmd) or (opposite and LocalPlayer():query(opposite)))) then
												local say = cmd
												local dat = ULib.cmds.translatedCmds[say]
												if not (dat.args[2] and (dat.args[2].type == ULib.cmds.PlayersArg or dat.args[2].type == ULib.cmds.PlayerArg)) then
													continue end

												local btn = CreateButton(string.gsub(cmd, "ulx ", ""), function(v, s)
													local torun = string.Explode(" ", cmd)
													table.insert(torun, "$" .. ULib.getUniqueIDForPlayer(v))

													if (dat.args[3]) and (dat.args[3].type == ULib.cmds.StringArg or dat.args[3].type == ULib.cmds.NumArg) then
														LT_StringRequest(cmd .. " -> " .. v:Nick(), dat.args[3].hint or cmd, function(tx)
															table.insert(torun, tx)
															RunConsoleCommand(unpack(torun))
														end, dat.args[3].default)
													else
														RunConsoleCommand(unpack(torun))
													end
												end)
											end
										end
									end

							pnl:MoveTo(navbar:GetWide(), -1, 0.3, nil, nil, function()
								pnl.Think = function(s)
									if (!IsValid(v)) then
										bak:DoClick()
									end

									s:StretchToParent(navbar:GetWide(), 0, 0, 0)
								end
							end)
						else
							me:DoRightClick()
						end
					end
					line.DoRightClick = function()
						local m = LT_Menu()

							m:AddOption(self.Language.view_steam_profile, function()
								gui.OpenURL(link)
							end)
							m:AddOption(self.Language.copy_steamid, function()
								SetClipboardText(steamid)
							end)

							if (v ~= LocalPlayer()) then
								m:AddOption(v:IsMuted() and self.Language.unmute or self.Language.mute, function()
									v:SetMuted(!v:IsMuted())
								end)
							end

						m:Open()
					end

						--
						local av = vgui.Create("AvatarImage", line)
						av:SetPlayer(v)
						av:SetWide(32 * scale)
						av:Dock(LEFT)
						av:DockMargin(0, 0, m5, 0)

							local btn = vgui.Create("DButton", av)
							btn:SetText("")
							btn:Dock(FILL)
							btn.Paint = function() end
							btn.DoClick = function()
								v:ShowProfile()
							end

						--
						local cc = self.PlayerFlags[v:SteamID()] or self.PlayerFlags[v:SteamID64()] or self.PlayerFlags[GetUserGroup(v)]
						if (!cc) and ((!self.OnlyAdminsSeeFlags or LocalPlayer():IsAdmin()) or v == LocalPlayer()) then
							cc = v.m_CountryCode
						end
						if (self.DisplayFlag and cc and file.Exists("materials/flags16/" .. cc .. ".png", "GAME")) then
							local mat = Material("flags16/" .. cc .. ".png", "noclamp")

							local img = vgui.Create("DPanel", line)
							img:SetMouseInputEnabled(false)
							img:SetWide(16)
							img:Dock(LEFT)
							img:DockMargin(0, 0, m5, 0)
							img.Paint = function(me, w, h)
								surface.SetDrawColor(color_white)
								surface.SetMaterial(mat)
								surface.DrawTexturedRectRotated(w * 0.5, h * 0.5, 16, 11, 0)
							end
						end

						--
						local usergroup = GetUserGroup(v)
						if (usergroup ~= "user" or self.DisplayUserLabel) then
							local rainbow = false
							local col = self.UsergroupColors[usergroup] or self.Style.text
							if (col == "rainbow") then
								col = self.Style.text
								rainbow = true
							end

							local ug = LT_QuickLabel(self.CleanUsergroups[usergroup] or usergroup, self.ItalicUsergroup and "TAB_LOUNGE_LargeI" or "TAB_LOUNGE_Large", col, line)
							ug:Dock(LEFT)
							if (ug:GetText() == "") then
								ug:DockMargin(0, 0, 0, 0)
							else
								ug:DockMargin(0, 0, m5, 0)
							end
							if (rainbow) then
								ug.m_iHue = 0
								ug.m_iRate = 360
								ug.Think = rainbowThink
							end
						end

						--
						local rainbow = false
						local col = self.PlayerColors[v:SteamID()] or self.PlayerColors[v:SteamID64()] or self.PlayerColors[GetUserGroup(v)] or self.Style.text
						if (col == "rainbow") then
							col = self.Style.text
							rainbow = true
						end

						local nick = LT_QuickLabel(v:Nick(), "TAB_LOUNGE_LargeB", col, line)
						nick:Dock(FILL)
						if (rainbow) then
							nick.m_iHue = 0
							nick.m_iRate = 360
							nick.Think = rainbowThink
						end

						--
						local wi = 80

						local function addColumn(tx, func, width, font)
							local col = vgui.Create("DPanel", line)
							col:SetMouseInputEnabled(false)
							col:SetDrawBackground(false)
							col:SetWide(width * scale)
							col:Dock(RIGHT)

								local lbl = LT_QuickLabel(self.Language[tx] or tx or "", "TAB_LOUNGE_Small", self.Style.subtext, col)
								lbl:SetContentAlignment(5)
								lbl:Dock(BOTTOM)

								if (lbl:GetText() == "") then
									lbl:Remove()
								end

								local val = LT_QuickLabel("", font or "TAB_LOUNGE_LargeB", self.Style.text, col)
								val:SetContentAlignment(5)
								val:Dock(FILL)

							col.m_fNextUpdate = CurTime() + 3
							col.Think = function(me)
								if (CurTime() >= me.m_fNextUpdate) then
									me:Update()
									me.m_fNextUpdate = CurTime() + 3
								end
							end
							col.Update = function(me)
								if (!IsValid(v)) then
									return end

								local va, co = func(v)
								co = co or self.Style.text
								val:SetTextColor(co)
								val:SetText(string.Comma(va))
							end
							col:Update()
						end

						for _, col in SortedPairs (self.PlayerColumns, true) do
							if (col.darkrp and !DarkRP) then
								continue end

							if (col.ttt and !DetectiveMode) then
								continue end

							if (col.candisplay and !col.candisplay()) then
								continue end

							addColumn(col.text or "", col.func, col.wi or wi, col.font)
						end
				end

				return #players > 0
			end

			local function AddGroup(tx, fil)
				local lbl = LT_QuickLabel(tx, "TAB_LOUNGE_Larger", self.Style.text, contents)
				lbl:Dock(TOP)

				local plist = vgui.Create("DScrollPanel", contents)
				plist:Dock(TOP)

				local added = PopulatePlayerList(plist, fil)
				plist:GetCanvas():InvalidateLayout(true)
				plist:SetTall(plist:GetCanvas():GetTall())

				if (!added) then
					lbl:Remove()
					plist:Remove()
				end

				return plist
			end

			if (self.DisplayStyle == 0) then -- all in same list
				PopulatePlayerList(contents)
			elseif (self.DisplayStyle == 1) then -- separate by team
				local teamz = {}
				for _, v in pairs (player.GetAll()) do
					if (!teamz[v:Team()]) then
						teamz[v:Team()] = true
					end
				end

				for t in SortedPairs (teamz) do
					AddGroup(team.GetName(t), function(ply)
						return ply:Team() == t
					end)
				end
			elseif (self.DisplayStyle == 2) then -- separate by usergroup
				local ugz = {}
				for _, v in pairs (player.GetAll()) do
					if (!ugz[GetUserGroup(v)]) then
						ugz[GetUserGroup(v)] = true
					end
				end

				for u in SortedPairs (ugz) do
					AddGroup(self.CleanUsergroups[u] or u, function(ply)
						return GetUserGroup(ply) == u
					end)
				end
			elseif (self.DisplayStyle == 3) then -- separate by alive/dead
				AddGroup(self.Language.alive, function(ply)
					return ply:Alive()
				end)

				AddGroup(self.Language.dead, function(ply)
					return !ply:Alive()
				end)
			elseif (self.DisplayStyle == 4) then -- separate by alive/dead
				AddGroup(self.Language.free, function(ply)
					return !ply:isArrested()
				end)

				AddGroup(self.Language.arrested, function(ply)
					return ply:isArrested()
				end)
			elseif (self.DisplayStyle == 5) then -- TTT separation
				local groups = {}

				groups[GROUP_TERROR] = AddGroup(self.Language.terrorists, function(ply)
					return ScoreGroup(ply) == GROUP_TERROR
				end)

				groups[GROUP_SPEC] = AddGroup(self.Language.spectators, function(ply)
					return ScoreGroup(ply) == GROUP_SPEC
				end)

				if (DetectiveMode and DetectiveMode()) then
					groups[GROUP_NOTFOUND] = AddGroup(self.Language.mia, function(ply)
						return ScoreGroup(ply) == GROUP_NOTFOUND
					end)

					groups[GROUP_FOUND] = AddGroup(self.Language.confirmed, function(ply)
						return ScoreGroup(ply) == GROUP_FOUND
					end)
				end
			end

	pnl:SetAlpha(0)
	pnl:AlphaTo(255, 0.1)

	_LOUNGE_TAB:MakePopup()
	_LOUNGE_TAB:KillFocus()
	_LOUNGE_TAB:SetMouseInputEnabled(false)
	_LOUNGE_TAB:SetKeyboardInputEnabled(false)
	gui.EnableScreenClicker(false)
end

hook.Add("ScoreboardShow", "LOUNGE_TAB_ScoreboardShow", function()
	LOUNGE_TAB:Show()

	if (LOUNGE_TAB.CursorOnOpen) then
		gui.EnableScreenClicker(true)
		_LOUNGE_TAB:SetMouseInputEnabled(true)
		LOUNGE_TAB.ScoreboardCursor = true
	end

	return false
end)

hook.Add("ScoreboardHide", "LOUNGE_TAB_ScoreboardHide", function()
	if (IsValid(_LOUNGE_TAB)) then
		_LOUNGE_TAB:Close()
	end
	if (IsValid(_LOUNGE_TAB_STRREQ)) then
		_LOUNGE_TAB_STRREQ:Close()
	end

	if (LOUNGE_TAB.ScoreboardCursor) then
		gui.EnableScreenClicker(false)
	end
end)

hook.Add("KeyRelease", "Scoreboard.DoCursorOnRMB", function(ply, key)
	if (key == IN_ATTACK2 and IsValid(_LOUNGE_TAB)) then
		gui.EnableScreenClicker(true)
		_LOUNGE_TAB:SetMouseInputEnabled(true)
		LOUNGE_TAB.ScoreboardCursor = true
	end
end)

hook.Add("InitPostEntity", "LOUNGE_TAB_InitPostEntity", function()
	hook.Remove("ScoreboardShow", "FAdmin_scoreboard")
	hook.Remove("ScoreboardHide", "FAdmin_scoreboard")
end)

net.Receive("TAB_LOUNGE_CountryFlag", function()
	local ent = net.ReadEntity()
	local cc = net.ReadString()
	if (IsValid(ent)) then
		ent.m_CountryCode = cc
	end
end)