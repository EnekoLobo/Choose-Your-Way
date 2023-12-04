local lply = LocalPlayer()
local imgui = include("libs/imgui.lua")
hradio = hradio or {}

hook.Add("VManipPostPlayAnim", "hRadio_OpenMenu", function(name)

	if (name == hradio.Config.AnimName) then

		timer.Simple(hradio.Config.OpenDelay, function()
			lply.hradio.ImguiRadioMenuOpen = true
			gui.EnableScreenClicker(true)
			input.SetCursorPos(ScrW() / 2 - 200, ScrH() / 2 + 100)
		end)

	end

end)

function hradio.GetAvailableChannels(ply)

	local channels = {}

	for k,channel in ipairs(hradio.Channels) do
		if channel.GetTalkers(ply) or channel.GetListeners(ply) or channel.Talkers[ply:Team()] or channel.Listeners[ply:Team()] then
			local chan = channel
			chan.ID = k
			if channel.GetTalkers(ply) or channel.Talkers[ply:Team()] then
				chan.PlyIsTalker = true
			else
				chan.PlyIsTalker = false
			end
			table.insert(channels, chan)
		end
	end

	return channels

end

local function DrawChannelMenuBox(index, x, y, chans)

	-- Channel Info

	local chanName = chans[index].Name
	local chanColor = chans[index].Color
	local isActive = lply.hradio.ActiveChannel == chans[index].ID
	local isMuted = lply.hradio.MutedChannels[chans[index].ID]
	local plyIsTalker = chans[index].PlyIsTalker

	if (!chanName) then hradio.errorcatcher.Catch("During channel drawing, the name was nil") return false end
	if (!chanColor) then hradio.errorcatcher.Catch("During channel " .. chanName .. " drawing, the color was nil") return false end
	if (isActive == nil) then isActive = false end
	if (isMuted == nil) then isMuted = false end
	if (plyIstalker == nil) then plyIstalker = false end

	-- Channel info UI

	draw.RoundedBox(10, x, y, 185, 60, hradio.Colors.Darker)
	draw.RoundedBox(10, x + 5, y + 5, 175, 20, hradio.Colors.Dark)
	draw.DrawText("Channel " .. chanName, "hRadio_Small", 93 + x, 6 + y, chanColor, TEXT_ALIGN_CENTER)

	-- Mute Button

	local PressedMute = false

	if chans[index].Mutable == nil then hradio.errorcatcher.Catch("During channel " .. chanName .. " drawing, the mutable status was nil (was the channel properly created?)") return false end

	if chans[index].Mutable then
		local muteText = "Mute"
		if isMuted then muteText = "Unmute" end
		draw.RoundedBox(10, x + 5, y + 32, 50, 20, hradio.Colors.Dark)
		PressedMute = imgui.xTextButton(muteText, "hRadio_Small", x + 5, y + 31, 50, 20, 0, hradio.Colors.Red, hradio.Colors.LightRed, hradio.Colors.Darkred)
	end

	-- Activate button

	local PressedActivate = false

	if plyIsTalker then
		local ActiveString = isActive and "Deactivate" or "Activate"
		local color = isActive and hradio.Colors.Green or hradio.Colors.Grayer

		draw.RoundedBox(10, x + 60, y + 32, 120, 20, color)
		PressedActivate = imgui.xTextButton(ActiveString, "hRadio_Small", x + 60, y + 31, 120, 20, 0, hradio.Colors.White, hradio.Colors.White, hradio.Colors.Grayer)
	end

	-- Mute button functionality

	if PressedMute and chans[index].Mutable then
		isMuted = !isMuted
		lply.hradio.MutedChannels[chans[index].ID] = isMuted

		if isMuted and isActive then
			hradio.ChangeActiveChannel(0)
		end

		hradio.ChangeMuteStatus(chans[index].ID, isMuted)
	end

	-- Activate button functionality

	if PressedActivate then
		isActive = !isActive

		if isActive and isMuted then
			hradio.ChangeMuteStatus(chans[index].ID, false)
		end

		if !isActive then
			hradio.ChangeActiveChannel(0)
		else
			hradio.ChangeActiveChannel(chans[index].ID)
			if hradio.Config.UISounds then surface.PlaySound("buttons/combine_button1.wav") end
		end
	end

	return true

end

function hradio.DrawMenuImgui(x,y, w,h, page)

	local availableChannels = hradio.GetAvailableChannels(lply)

	if (!availableChannels || #availableChannels == 0) then

	draw.RoundedBox(10,-50,165,285,50, hradio.Colors.Darker)
	local noChannels = imgui.xTextButton("There are no channels available to you.", "hRadio_Small", 8,165,165,50, 0)
	return false end

	local minIndex = page * 4 - 3
	local vOffset = 3

	draw.RoundedBox(10, 200, 5, 20, 165, hradio.Colors.Darker)
	local PressedUp = imgui.xTextButton("↑", "hRadio_Small", 200, 0, 20, 165, 0)
	draw.RoundedBox(10, 200, 160, 20, 165, hradio.Colors.Darker)
	local PressedDown = imgui.xTextButton("↓", "hRadio_Small", 200, 165, 20, 165, 0)

	for i = minIndex, minIndex + 4 do
		if i <= #availableChannels then
			local err = DrawChannelMenuBox(i, 8, vOffset, availableChannels) -- err = false if something went wrong
			if (!err) then
				continue
			end
			vOffset = vOffset + 66
		end
	end

	if PressedUp and page > 1 then
		return page - 1
	elseif PressedDown and page < math.ceil(#availableChannels / 4) then
		return page + 1
	else
		return page
	end

end

hook.Add("PostDrawPlayerHands", "hRadio_MenuPaint1STPerson", function()
	if lply.hradio.ImguiRadioMenuOpen then

		local pos
		local ent

		ent = lply:GetHands()

		if hradio.Config.UseMasterHands then

			ent:SetModel(hradio.Config.UseMasterHands)

		end

		local handsModel = ent:GetModel()
		local index = 4

		if hradio.Config.IndividualBoneIndexes[handsModel] then
			index = hradio.Config.IndividualBoneIndexes[handsModel]
		elseif hradio.Config.BoneIndex then
			index = hradio.Config.BoneIndex
		end

		if hradio.Config.OverrideIndexWithBoneName then
			index = ent:LookupBone(hradio.Config.OverrideIndexWithBoneName)
		end

		local pos = ent:GetBonePosition(index)

		if pos == ent:GetPos() and ent:GetBoneMatrix(index) != nil then
			pos = ent:GetBoneMatrix(index):GetTranslation()
		end

		pos = pos + EyeAngles():Up() * hradio.Config.MenuPosition.Up
		pos = pos + EyeAngles():Forward() * hradio.Config.MenuPosition.Forward
		pos = pos + EyeAngles():Right() * hradio.Config.MenuPosition.Right

		local ang = EyeAngles():Forward():Angle()

		ang:RotateAroundAxis(EyeAngles():Forward(), hradio.Config.MenuPosition.FwdRot)
		ang:RotateAroundAxis(EyeAngles():Up(), hradio.Config.MenuPosition.UpRot)
		ang:RotateAroundAxis(EyeAngles():Right(), hradio.Config.MenuPosition.RgtRot)

		debugoverlay.Axis(translateViewModelPosition(54, pos, true), Angle(0,0,0), 1, 1, false)

		imgui.Start3D2D(pos, ang, hradio.Config.MenuScale)
			if !hradio.MenuPage then hradio.MenuPage = 1 end
			hradio.MenuPage = hradio.DrawMenuImgui(0,0,200,365, hradio.MenuPage)
			imgui.xCursor(0, 0, 230, 330)
		imgui.End3D2D()

	elseif hradio.Config.UseCloseAnim then
		VManip:PlaySegment(hradio.Config.AnimClose, true) -- Return the hand if key is released before anim finishes
	end
end)