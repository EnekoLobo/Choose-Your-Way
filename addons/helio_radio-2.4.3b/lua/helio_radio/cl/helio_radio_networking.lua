hradio = hradio or {}
local lply = LocalPlayer()

-- Outgoing

function hradio.ChangeMuteStatus(chan, status)
	if hradio.Config.UISounds then surface.PlaySound("buttons/button16.wav") end

	net.Start("hRadio_PlyMuteUnmuteChannel") -- It is safe to call net messages here, they will be created only once per click
	net.WriteUInt(chan, hradio.ChannelMaxBitSize)
	net.WriteBool(status)
	net.SendToServer()
end

function hradio.ChangeActiveChannel(newchan)
	lply.hradio.ActiveChannel = newchan

	net.Start("hRadio_PlyChangeChannel") -- It is safe to call net messages here, they will be created only once per click
	net.WriteUInt(newchan, hradio.ChannelMaxBitSize)
	net.SendToServer()
end

-- Incoming

hradio.IncomingTransmissions = {}

net.Receive("hRadio_IncomingTransmissionStart", function()

	local chan = net.ReadUInt(hradio.ChannelMaxBitSize)  -- Using 32 bits as fallback
	local steamid = net.ReadString()
	local from = player.GetBySteamID64(steamid)
	if !from then return end

	from.hradio = from.hradio or {}
	if lply.hradio.MutedChannels[chan] and !hradio.Config.ShowMutedNotifications then return end

	if !hradio.debug and from == lply then return end -- Do not display backwards loop unless its developer
	from.hradio.IsTalking = true
	if !lply.hradio.MutedChannels[chan] and hradio.Config.IncomingTransmissionSounds then surface.PlaySound("buttons/blip1.wav") end

	from.hradio.LastStartTime = SysTime()
	hradio.RemoveOriginalVCHud(from)

	from.hradio.modelpanel = vgui.Create("DModelPanel")
	from.hradio.modelpanel:SetPaintedManually(true)
	function from.hradio.modelpanel:LayoutEntity() return end

	for k,v in ipairs(hradio.IncomingTransmissions) do -- Duplicate protection
		if v[1] == from then
			table.remove(hradio.IncomingTransmissions, k)
		end
	end

	table.insert(hradio.IncomingTransmissions, {from, chan})

end)

net.Receive("hRadio_IncomingTransmissionEnd", function()

	local chan = net.ReadUInt(hradio.ChannelMaxBitSize)  -- Using 32 bits as fallback
	local from = player.GetBySteamID64( net.ReadString())
	if !from then return end
	if lply.hradio.MutedChannels[chan] and !hradio.Config.ShowMutedNotifications then return end

	if !hradio.debug and from == lply then return end -- Do not display backwards loop unless its developer
	from.hradio.IsTalking = false
	if !lply.hradio.MutedChannels[chan] and hradio.Config.IncomingTransmissionSounds then surface.PlaySound("buttons/button5.wav") end

	from.hradio = from.hradio or {}
	from.hradio.LastStopTime = SysTime()

	timer.Simple(0.2, function()
		for k,v in ipairs(hradio.IncomingTransmissions) do
			if v[1] == from and v[2] == chan then
				table.remove(hradio.IncomingTransmissions, k)
				return
			end
		end
	end)

	if from.hradio.modelpanel then from.hradio.modelpanel:Remove() end

end)

net.Receive("hRadio_PlyOwnRadioStart", function()
	lply.hradio.IsTalking = true
	lply.hradio.LastStartTime = SysTime()
	surface.PlaySound("buttons/button19.wav")
end)

net.Receive("hRadio_PlyOwnRadioEnd", function()

	lply.hradio.IsTalking = false
	lply.hradio.LastStopTime = SysTime()
	surface.PlaySound("buttons/button18.wav")
end)

net.Receive("hRadio_PlyChangeChannelFeedback", function()

	local channel = net.ReadUInt(hradio.ChannelMaxBitSize)
	lply.hradio.ActiveChannel = channel

	hook.Run("hRadio_PlyChangeChannelFeedback", channel)  -- Using 32 bits as fallback

end)

net.Receive("hRadio_PlyMuteUnmuteChannelFeedback", function()

	local channel = net.ReadUInt(hradio.ChannelMaxBitSize)
	local status = net.ReadBool()

	lply.hradio.MutedChannels[channel] = status

end)