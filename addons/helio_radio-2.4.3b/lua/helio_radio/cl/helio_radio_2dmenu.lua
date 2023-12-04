local SKIN = {}
local lply = LocalPlayer()
hradio = hradio or {}

function SKIN:PaintCheckBox(panel, w, h)

	if ( panel:GetChecked() ) then

		if ( panel:GetDisabled() ) then
			draw.RoundedBox(6, 0, 0, w, h, hradio.Colors.Gray)
			draw.RoundedBox(7, 2, 2, w-4, h-4, hradio.Colors.Grayer)
		else
			draw.RoundedBox(6, 0, 0, w, h, hradio.Colors.Grayer)
			draw.RoundedBox(7, 2, 2, w-4, h-4, hradio.Colors.Darkred)
		end

	else

		if ( panel:GetDisabled() ) then
			draw.RoundedBox(6, 0, 0, w, h, hradio.Colors.Gray)
		else
			draw.RoundedBox(6, 0, 0, w, h, hradio.Colors.Grayer)
		end

	end

end
derma.DefineSkin( "hRadio_Black", "hRadio_Black", SKIN )

function hradio.OpenMenu2D()

	input.SetCursorPos(ScrW() * 0.06, ScrH() * 0.1)

	main = vgui.Create("DFrame")
	main:MakePopup()
	main:SetSize(ScrW() * 0.1,ScrH() * 0.4)
	main:SetPos(ScrW() * 0.01, ScrH() * 0.02)
	main:ShowCloseButton(false)
	main:SetTitle("")
	main.Paint = function(pnl, w, h)
		draw.RoundedBox(10, 0, 0, w, h, Color(0,0,0,0))
	end

	scpn = vgui.Create("DScrollPanel", main)
	scpn:Dock(FILL)

	local sbar = scpn:GetVBar()

	function sbar:Paint(w, h)
		draw.RoundedBox(6, 1, 0, w-1, h-1, hradio.Colors.Dark)
	end

	function sbar.btnGrip:Paint(w, h)
		draw.RoundedBox(6, 1, 1, w-1, h-2, hradio.Colors.Gray)
	end

	sbar:SetHideButtons(true)

	lbl = vgui.Create("DLabel", main)
	lbl:Dock(TOP)
	lbl:SetText("No channels available")
	lbl:SetContentAlignment(5)
	lbl:SizeToContents()
	lbl:SetSize(lbl:GetWide() * 2, lbl:GetTall() * 2)
	lbl.Paint = function(pnl, w, h)
		draw.RoundedBox(10, 0, 0, w, h, hradio.Colors.Dark)
	end

	for k,v in pairs(hradio.Channels) do

		if !v.Name or !v.Talkers or !v.Listeners or !v.GetTalkers or !v.GetListeners or v.Mutable == nil or !v.Color then continue end
		if !v.GetListeners(lply) and !v.Listeners[lply:Team()] then continue end

		lbl:Remove()

		-- Frame

		local frm = scpn:Add("DPanel")
		frm:Dock(TOP)
		frm:DockMargin(0, 0, 3, 5)
		frm:SetTall(80)
		frm.Paint = function(pnl, w, h)
			draw.RoundedBox(6, 0, 0, w, h, hradio.Colors.Darker)
		end

		-- Channel name label

		local lbl = frm:Add("DLabel")
		lbl:SetText( "" .. v.Name )
		lbl:SetTextColor(hradio.Colors.White)
		lbl:SetFont("hRadio_Small")
		if hradio.Channels[k].Color then lbl:SetTextColor(hradio.Channels[k].Color) end
		lbl:SetContentAlignment(5)
		lbl:Dock( TOP )
		lbl:DockMargin( 0, 0, 0, 5 )
		lbl.Paint = function(pnl, w, h)
			draw.RoundedBox(6, 0, 0, w, h, hradio.Colors.Dark)
		end

		-- Mute button

		local mte = frm:Add("DCheckBoxLabel")
		mte:SetSkin("hRadio_Black")
		mte:Dock(TOP)
		mte:DockMargin(0, 3, 3, 5)
		mte:SetText("Ensordecer")
		mte:SetFont("hRadio_Small")
		mte:SetTextColor(hradio.Colors.White)
		mte:SetIndent(10)
		if !v.Mutable then mte:SetEnabled(false) end
		if lply.hradio.MutedChannels and lply.hradio.MutedChannels[k] then mte:SetChecked(true) end

		-- De/Activate button

		local act = frm:Add("DButton")
		act.BGcolor = hradio.Colors.Dark
		act:Dock(TOP)
		act:DockMargin(10, 3, 5, 5)
		act:SetText("Activar")
		act:SetFont("hRadio_Small")
		act:SetTextColor(hradio.Colors.White)

		local channel = hradio.Channels[k]

		if !channel.GetTalkers(lply) and !channel.Talkers[lply:Team()] or mte:GetChecked() then
			act:SetDisabled(true)
			act:SetTextColor(hradio.Colors.Gray)
		end

		hook.Add("hRadio_PlyChangeChannelFeedback", "ListenForChannelChange" .. tostring(k), function(chan) -- Handle changing channels without reopening the menu
			
			if !IsValid(act) then return end
			if k == chan then
				act:SetText("Desactivar") act:SetTextColor(hradio.Colors.White) -- Make the button more recognizable if the channel is active
				act.BGcolor = hradio.Colors.Green
			else
				if !IsValid(act) then return end
				act:SetText("Activar") act:SetTextColor(hradio.Colors.White)
				act.BGcolor = hradio.Colors.Dark
				if act:GetDisabled() then act:SetTextColor(hradio.Colors.Gray) end
			end
		end)

		if lply.hradio.ActiveChannel == k then
			act:SetText("Desactivar")
			act:SetTextColor(hradio.Colors.Gray)
			act.BGcolor = hradio.Colors.Green
		end -- Activate the channel button that we are currently using

		-- De/Activate button action

		act.DoClick = function()
			surface.PlaySound("buttons/combine_button1.wav")
			if act:GetText() == "Desactivar" then
				hradio.ChangeActiveChannel(0)
			else
				hradio.ChangeActiveChannel(k)
			end
		end

		act.Paint = function(pnl, w, h)
			draw.RoundedBox(6, 0, 0, w, h, act.BGcolor)
		end

		-- Mute button action

		mte.OnChange = function()
			if !lply.hradio.MutedChannels then lply.hradio.MutedChannels = {} end
			lply.hradio.MutedChannels[k] = mte:GetChecked()

			if IsValid(act) and mte:GetChecked() and lply.hradio.ActiveChannel == k then -- Deactivate muted channel
				act:SetText("Activar")
				act:SetDisabled(true)
				hradio.ChangeActiveChannel(0)
			elseif IsValid(act) and mte:GetChecked() then -- Do not activate after unmuting

				act:SetDisabled(true)
				act:SetTextColor(hradio.Colors.Gray)

			elseif IsValid(act) and !mte:GetChecked() then

				act:SetDisabled(false)
				act:SetTextColor(hradio.Colors.White)

				if !channel.GetTalkers(lply) and channel.Talkers[lply:Team()] then
					act:SetDisabled(true) -- Disable channels in which the player cannot talk
					act:SetTextColor(hradio.Colors.Gray)
				end

			end

			hradio.ChangeMuteStatus(k, mte:GetChecked())
		end

	end

	return main

end

hook.Add("PostDrawOpaqueRenderables", "hRadio_MenuPaint3RDPerson", function()
	hradio.ThirdPerson = lply:ShouldDrawLocalPlayer()
end)
