hradio = hradio or {}

hradio.OffsetOff = 200
hradio.OffsetOn = -190
hradio.OffsetCur = 200
hradio.AnimTime = 0.3

local lply = LocalPlayer()
local mutemat = Material("icon16/sound_mute.png")
local SpeakerSpeakMat = Material("vgui/hradio/speaker.png")

lply.hradio = lply.hradio or {}

hradio.AnimateIn = function(timeDelta, ply)
	ply = ply or lply
	ply.hradio = ply.hradio or {}
	ply.hradio.OffsetCur = ply.hradio.OffsetCur or 200
	if timeDelta <= hradio.AnimTime then
		ply.hradio.OffsetCur = Lerp(timeDelta / hradio.AnimTime, hradio.OffsetOff, hradio.OffsetOn)
		return ply.hradio.OffsetCur
	else
		return hradio.OffsetOn
	end
end

hradio.AnimateOut = function(timeDelta, ply)
	ply = ply or lply
	ply.hradio = ply.hradio or {}
	ply.hradio.OffsetCur = ply.hradio.OffsetCur or 200
	if timeDelta <= hradio.AnimTime then
		return Lerp(timeDelta / hradio.AnimTime, ply.hradio.OffsetCur, hradio.OffsetOff)
	else
		return hradio.OffsetOff
	end
end

local function DrawRadioBoxOwn(color, chan, h, offset) -- For you

	local posx = ScrW() + offset - 50
	local posy = ScrH() * h
	local volume = Lerp(player.GetBySteamID64(lply:SteamID64()):VoiceVolume() / 0.5, 85, 255)

	draw.RoundedBox(10, posx, posy, 250, 60, hradio.Colors.Dark)
	draw.RoundedBox(9, posx + 3, posy + 3, 250 - 6, 60 - 6, Color(color.r, color.g, color.b ,volume))
	draw.RoundedBox(9, posx + 5, posy + 5, 250 - 10, 60 - 10, hradio.Colors.Dark)
	surface.SetDrawColor(hradio.Colors.Grayer.r,hradio.Colors.Grayer.g,hradio.Colors.Grayer.b, 255)
	surface.SetMaterial(SpeakerSpeakMat)
	surface.DrawTexturedRect(posx + 17, posy + 10, 38, 38)
	draw.DrawText("Talking to:", "hRadio_Small", posx + 64, posy + 10, hradio.Colors.Grayer, TEXT_ALIGN_LEFT)
	draw.DrawText(chan, "hRadio_Main", posx + 64, posy + 24, hradio.Colors.Grayer, TEXT_ALIGN_LEFT)

end

local function DrawRadioBox(color, ply, chan, h, offset) -- For other people

	local posx = ScrW() + offset - 50
	local posy = ScrH() * 0.8 - 100 - h
	local volume = Lerp(ply:VoiceVolume() / 0.5, 85, 255)

	draw.RoundedBox(10, posx, posy, 250, 65, hradio.Colors.Dark)
	draw.RoundedBox(9, posx + 3, posy + 3, 250 - 6, 65 - 6, Color(color.r, color.g, color.b ,volume))
	draw.RoundedBox(9, posx + 5, posy + 5, 250 - 10, 65 - 10, hradio.Colors.Dark)

	if lply.hradio.MutedChannels[chan] then

		surface.SetDrawColor(255,255,255)
		surface.SetMaterial(mutemat)
		surface.DrawTexturedRect(posx + 15, posy + 17, 16, 16)

		posx = posx + 23

	end

	draw.DrawText("Channel: " .. hradio.Channels[chan].Name, "hRadio_Small", posx + 67, posy + 15, hradio.Colors.Grayish, TEXT_ALIGN_LEFT)
	draw.DrawText(ply:Name(), "hRadio_Main", posx + 67, posy + 27, hradio.Colors.Grayish, TEXT_ALIGN_LEFT)

	local panel = ply.hradio.modelpanel

	if IsValid(panel) then
		panel:SetPos(posx + 17, posy + 15)
		panel:SetSize(38, 38)
		panel:SetModel(ply:GetModel())
		panel:SetLookAng(Angle(-5.807, 163.145, -0.007))
		panel:SetFOV(10)
		panel:SetCamPos(Vector(70.344353,-20.515793, 59.814095))
		panel:PaintManual()
	end

end

hook.Add("HUDPaint", "hRadioHud", function()

	local voffset = 0

	for _,v in ipairs(hradio.IncomingTransmissions) do

		local offset = hradio.OffsetOff
		local ply = v[1]
		local chan = v[2]

		if !IsValid(ply) then continue end
		if ply.hradio.IsTalking then
			offset = hradio.AnimateIn(SysTime() - ply.hradio.LastStartTime)
		else
			offset = hradio.AnimateOut(SysTime() - ply.hradio.LastStopTime)
		end

		DrawRadioBox(hradio.Channels[chan].Color or hradio.Colors.White, ply, chan, voffset, offset)
		voffset = voffset + 60

	end

	local chan = lply.hradio.ActiveChannel
	chan = hradio.Channels[chan]
	if !chan then return end

	offset = hradio.OffsetOff

	if lply.hradio.IsTalking then
		offset = hradio.AnimateIn(SysTime() - lply.hradio.LastStartTime)
	else
		offset = hradio.AnimateOut(SysTime() - lply.hradio.LastStopTime)
	end

	local color = chan.Color or hradio.Colors.White

	DrawRadioBoxOwn(color, chan.Name, 0.8, offset)

end)
