hradio.debug = false
if GetConVar("developer"):GetInt() > 0 then hradio.debug = true end

-------------------
-- Network Setup --
-------------------

util.AddNetworkString("hRadio_PlyStartTalking")
util.AddNetworkString("hRadio_PlyStopTalking")

util.AddNetworkString("hRadio_PlyOwnRadioStart")
util.AddNetworkString("hRadio_PlyOwnRadioEnd")

util.AddNetworkString("hRadio_IncomingTransmissionStart")
util.AddNetworkString("hRadio_IncomingTransmissionEnd")

util.AddNetworkString("hRadio_PlyChangeChannel")
util.AddNetworkString("hRadio_PlyChangeChannelFeedback")

util.AddNetworkString("hRadio_PlyMuteUnmuteChannel")
util.AddNetworkString("hRadio_PlyMuteUnmuteChannelFeedback")

--------------------
-- Initialization --
--------------------

hook.Add("PlayerInitialSpawn", "hRadio_InitializeTable", function(ply)
	ply.hradio = ply.hradio or {} -- Give all players hradio tables, or skip if they rejoined.
end)

-----------------------
-- Utility Functions --
-----------------------

function hradio.CheckTalkers(ply, chanID)
	if !hradio.Channels[chanID] then return end -- Check if channel exists
	local chan = hradio.Channels[chanID]
	if chan.GetTalkers(ply) or chan.Talkers[ply:Team()] then
		return true
	else
		return false
	end
end

function hradio.StartTalking(ply)
	if !(ply.hradio and ply.hradio.ActiveChannel) then ply.hradio.ActiveChannel = 0 end
	if ply.hradio.ActiveChannel == 0 then return end
	if hradio.debug then print("Player " .. ply:Name() .. " started talking on channel " .. ply.hradio.ActiveChannel) end

	local chanID = ply.hradio.ActiveChannel
	local chan = hradio.Channels[chanID]

	if chan and !chan.GetTalkers(ply) and !chan.Talkers[ply:Team()] then -- Reset invalid channels to 0
		ply.hradio.ActiveChannel = 0
		return
	end

	ply.hradio.IsTalking = true

	if !chan then

		print(string.format("[heliOS][RADIOSYS] %s tried to use the radio with an invalid channel: %s", ply:Name(), chanID))
		return

	end -- make sure the channel exists

	net.Start("hRadio_IncomingTransmissionStart")
	net.WriteUInt(chanID, hradio.ChannelMaxBitSize)  -- Using 32 bits as fallback
	net.WriteString(ply:SteamID64())

	local recip = {}

	for k,v in ipairs(player.GetAll()) do
		if ((v.hradio.MutedChannels and !v.hradio.MutedChannels[chan]) or !v.hradio.MutedChannels) and (chan.GetListeners(v) or chan.Listeners[v:Team()]) then
			table.insert(recip, v)
		end
	end

	net.Send(recip)

end

function hradio.StopTalking(ply)
	if ply.hradio.ActiveChannel == 0 then return end
	timer.Simple(0.2, function() ply.hradio.IsTalking = false end)

	if hradio.debug then print("Player " .. ply:Name() .. " stopped talking on channel " .. ply.hradio.ActiveChannel) end

	local chan = ply.hradio.ActiveChannel
	if !chan then return end
	if !hradio.Channels[chan] then

		hradio.errorcatcher.Catch(string.format("%s has tried to use the radio with an invalid channel: %s", ply:Name(), tostring(chan)))
		ply.hradio.ActiveChannel = 0
		return

	end -- make sure the channel exists

	local key = chan
	chan = hradio.Channels[chan]

	for k,v in ipairs(player.GetAll()) do
		if chan.GetListeners(v) or chan.Listeners[v:Team()] then
			net.Start("hRadio_IncomingTransmissionEnd")
			net.WriteUInt(key, hradio.ChannelMaxBitSize)  -- Using 32 bits as fallback
			net.WriteString(ply:SteamID64())
			net.Send(v)
		end
	end

end

----------------
-- Networking --
----------------

net.Receive("hRadio_PlyMuteUnmuteChannel", function(_, ply) -- Manage muting of channels

	local chan = net.ReadUInt(hradio.ChannelMaxBitSize)
	local status = net.ReadBool()

	if !chan or !hradio.Channels[chan] then hradio.errorcatcher.Catch("Player " .. ply:Name() .. " tried to un/mute an invalid channel") return end -- Check if channel exists
	if !hradio.Channels[chan].Mutable then return end -- Prevent muting of immutable channels

	ply.hradio.MutedChannels = ply.hradio.MutedChannels or {} -- Create the table if it doesn't exist
	ply.hradio.MutedChannels[chan] = status

	net.Start("hRadio_PlyMuteUnmuteChannelFeedback") -- Tell the client whether they succeeded in muting the channel
	net.WriteUInt(chan, hradio.ChannelMaxBitSize)
	net.WriteBool(status)
	net.Send(ply)

end)

net.Receive("hRadio_PlyChangeChannel", function(_, ply)

	local chan = net.ReadUInt(hradio.ChannelMaxBitSize)

	if !hradio.Channels[chan] and chan != 0 then return end -- Check if channel exists
	if !hradio.CheckTalkers(ply, chan) and chan != 0 then return end -- Check if permissions are correct

	ply.hradio.ActiveChannel = chan
	net.Start("hRadio_PlyChangeChannelFeedback") -- Tell the player whether they successfully changed the channel and what they changed it to
	net.WriteUInt(chan,hradio.ChannelMaxBitSize)
	net.Send(ply)

end)

net.Receive("hRadio_PlyStartTalking", function(ln, ply)
	hradio.StartTalking(ply)
end)

net.Receive("hRadio_PlyStopTalking", function(ln, ply)
	hradio.StopTalking(ply)
end)

-----------
-- Logic --
-----------

local function canHear(listener, talker)
	if !talker.hradio then talker.hradio = {} end

	if talker.hradio.IsTalking then
		local chan = talker.hradio.ActiveChannel

		if !chan then print("chan1") return end -- Only if the channel exists
		if chan == 0 then return end
		if !hradio.Channels[chan] then

			hradio.errorcatcher.Catch(String.format("%s tried to use the radio with an invalid channel: %s", talker:Name(), tostring(chan)))
			return

		end -- Only if the channel exists, can't be too safe
		if listener.hradio.MutedChannels and listener.hradio.MutedChannels[chan] then return false end

		chan = hradio.Channels[chan]
		if chan.GetListeners(listener) or chan.Listeners[listener:Team()] then
			return true, false
		else
			return false, false
		end

	end
end

hook.Add("PlayerCanHearPlayersVoice", "hRadio_Think", canHear)

-- VoiceBox FX Integration
-- https://www.gmodstore.com/market/view/voicebox-fx
local function voiceboxCanHear(listener, talker)
	VoiceBox.FX.IsRadioComm(listener:EntIndex(), talker:EntIndex(), false)

	if !talker.hradio then talker.hradio = {} end

	if talker.hradio.IsTalking then
		local chan = talker.hradio.ActiveChannel

		if !chan then print("chan1") return end -- Only if the channel exists
		if chan == 0 then return end
		if !hradio.Channels[chan] then

			hradio.errorcatcher.Catch(String.format("%s tried to use the radio with an invalid channel: %s", talker:Name(), tostring(chan)))
			return

		end -- Only if the channel exists, can't be too safe
		if listener.hradio.MutedChannels and listener.hradio.MutedChannels[chan] then return false end

		chan = hradio.Channels[chan]
		if chan.GetListeners(listener) or chan.Listeners[listener:Team()] then
			VoiceBox.FX.IsRadioComm(listener:EntIndex(), talker:EntIndex(), not VoiceBox.FX.__PlayerCanHearPlayersVoice(listener, talker))
			return true, false
		else
			return false, false
		end

	end
end
if VoiceBox and VoiceBox.FX then
	print("[heliOS][RADIOSYS] VoiceBox FX integration active!")
	hook.Add("PlayerCanHearPlayersVoice", "hRadio_Think", voiceboxCanHear)
else
	hook.Add("VoiceBox.FX", "hRadio", function()
		print("[heliOS][RADIOSYS] VoiceBox FX integration active!")
		hook.Add("PlayerCanHearPlayersVoice", "hRadio_Think", voiceboxCanHear)
	end)
end

print("[heliOS][RADIOSYS] SV File finished.")