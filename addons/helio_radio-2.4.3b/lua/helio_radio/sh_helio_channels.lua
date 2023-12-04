AddCSLuaFile()

hradio.Channels = {}
hradio.Channelcount = 0
hradio.ChannelMaxBitSize = 32 -- fallback value

function hradio.AddChannel(input)

	hradio.Channels = hradio.Channels or {}

	if (!isstring(input.Name) or !istable(input.Talkers) or !istable(input.Listeners) or !isfunction(input.GetTalkers) or !isfunction(input.GetListeners) or !isbool(input.Mutable) or !IsColor(input.Colour)) then
		hradio.errorcatcher.CatchLater([[
		It appears that you tried to add a channel, but there is a syntax error or typo
		Here's what we know about it:
		Name: ]] .. tostring(input.Name) or "UNKNOWN" .. [[
		Talker Teams: ]] .. tostring(input.Talkers) or "UNKNOWN" .. [[
		Listener Teams: ]] .. tostring(input.Listeners) or "UNKNOWN" .. [[
		"Talker Function: ]] .. tostring(input.GetTalkers) or "UNKNOWN" .. [[
		"Listener Function: ]] .. tostring(input.GetListeners) or "UNKNOWN" .. [[
		"Is Mutable: ]] .. tostring(input.Mutable) .. [[
		"Color: ]] .. tostring(input.Colour) or "UNKNOWN")
	return end

	data = {}
	data.Name = input.Name

	data.Listeners = {}

	for k,v in ipairs(input.Listeners) do
		data.Listeners[v] = true -- Convert user-readable tables into a more efficient version
	end

	data.Talkers = {}

	for k,v in ipairs(input.Talkers) do
		data.Talkers[v] = true -- Convert user-readable tables into a more efficient version
	end

	data.GetTalkers = input.GetTalkers
	data.GetListeners = input.GetListeners
	data.Mutable = input.Mutable
	data.Color = input.Colour

	print("-----------===heliOS===------------")
	print("RADIO SYSTEM CHANNEL ADDED")
	print("Here's what we know about it:")
	print("Name: " .. tostring(input.Name) or "UNKNOWN")
	print("Talker Teams: ")
	PrintTable(input.Talkers)
	print("Listener Teams: ")
	PrintTable(input.Listeners)
	print("Talker Function: " .. tostring(input.GetTalkers) or "UNKNOWN")
	print("Listener Function: " .. tostring(input.GetListeners) or "UNKNOWN")
	print("Is Mutable: " .. tostring(input.Mutable))
	print("Color: " .. tostring(input.Colour) or "UNKNOWN")
		print("-----------===------===------------")

	table.insert(hradio.Channels, data)

	hradio.Channelcount = hradio.Channelcount + 1 or 0
	hradio.ChannelMaxBitSize = math.ceil(math.log(hradio.Channelcount) / math.log(2) + 1) -- Recalculate this whenever we add a new channel
	print("[hRadio] Channel count: " .. hradio.Channelcount .. ", message bitsize: " .. hradio.ChannelMaxBitSize)
end