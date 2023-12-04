local lply = LocalPlayer()
hradio = hradio or {}

concommand.Add("+hradio_talk", function(ply, cmd, args)
	permissions.EnableVoiceChat(true)
	if !lply.hradio.ActiveChannel then lply.hradio.ActiveChannel = 0 end
	if lply.hradio.ActiveChannel == 0 then lply:ConCommand("-voicerecord") return end
	local chan = hradio.Channels[lply.hradio.ActiveChannel]
	if !chan then return end
	if !chan.GetTalkers(ply) and !chan.Talkers[ply:Team()] then lply:ConCommand("-voicerecord") return end

	if hradio.debug then print("You started talking") end

	lply.hradio.IsTalking = true
	hradio.RemoveOriginalVCHud(lply)
	timer.Simple(RealFrameTime() * 2, function() hradio.RemoveOriginalVCHud(lply) end) -- until https://github.com/Facepunch/garrysmod/pull/1752 gets merged
	lply.hradio.LastStartTime = SysTime()
	if hradio.Config.UISounds then sound.Play("buttons/button19.wav", lply:EyePos(), 75, 100, 0.5) end

	net.Start("hRadio_PlyStartTalking")
	net.SendToServer()
end)

concommand.Add("-hradio_talk", function(ply, cmd, args)
	permissions.EnableVoiceChat(false)
	if !lply.hradio.ActiveChannel then lply.hradio.ActiveChannel = 0 end
	if lply.hradio.ActiveChannel == 0 then return end
	local chan = hradio.Channels[lply.hradio.ActiveChannel]
	if !chan then return end
	if !chan.GetTalkers(ply) and !chan.Talkers[ply:Team()] then return end

	if hradio.debug then print("You stopped talking") end

	lply.hradio.IsTalking = false

	lply.hradio.LastStopTime = SysTime()
	if hradio.Config.UISounds then sound.Play("buttons/button18.wav", lply:EyePos(), 75, 100, 0.5) end
	net.Start("hRadio_PlyStopTalking")
	net.SendToServer()
end)

concommand.Add("+hradio_menu", function(ply, cmd, args)

	if hradio.ThirdPerson or hradio.Config.AlwaysUse3PMenu or (IsValid(ply:GetActiveWeapon()) and hradio.Config.ExemptFrom1PMenu[ply:GetActiveWeapon():GetClass()]) then
		lply.hradio.RadioMenu = hradio.OpenMenu2D()
		return
	end

	if !VManip and !hradio.Config.AlwaysUse3PMenu and !hradio.Config.ExemptFrom1PMenu[ply:GetActiveWeapon():GetClass()] then

		print("[heliOS][RADIOSYS] WARNING!!! V-MANIP NOT DETECTED! (https://steamcommunity.com/sharedfiles/filedetails/?id=2155366756)")
		print("[heliOS][RADIOSYS] WARNING!!! V-MANIP NOT DETECTED! (https://steamcommunity.com/sharedfiles/filedetails/?id=2155366756)")
		print("[heliOS][RADIOSYS] WARNING!!! V-MANIP NOT DETECTED! (https://steamcommunity.com/sharedfiles/filedetails/?id=2155366756)")
		print("[heliOS][RADIOSYS] WARNING!!! V-MANIP NOT DETECTED! (https://steamcommunity.com/sharedfiles/filedetails/?id=2155366756)")
		print("[heliOS][RADIOSYS] WARNING!!! V-MANIP NOT DETECTED! (https://steamcommunity.com/sharedfiles/filedetails/?id=2155366756)")
		hradio.errorcatcher.CatchLater("No VManip Found (https://steamcommunity.com/sharedfiles/filedetails/?id=2155366756)")

	end

	if VManip and !hradio.Config.AlwaysUse3PMenu and !hradio.Config.ExemptFrom1PMenu[ply:GetActiveWeapon():GetClass()] then
		if VManip:IsActive() and hradio.Config.UseCloseAnim then
			VManip:PlaySegment(hradio.Config.AnimClose, true)
		elseif VManip:IsActive() then
			VManip:QuitHolding(hradio.Config.AnimName)
		else
			VManip:PlayAnim(hradio.Config.AnimName)
		end
	end

end)

concommand.Add("-hradio_menu", function(ply, cmd, args)

	if IsValid(lply.hradio.RadioMenu) then
		lply.hradio.RadioMenu:Remove()
	end

	if lply.hradio.ImguiRadioMenuOpen then

		if hradio.Config.UseCloseAnim then
			VManip:PlaySegment(hradio.Config.AnimClose, true)
		else
			VManip:QuitHolding(hradio.Config.AnimName)
		end

		lply.hradio.ImguiRadioMenuOpen = false
		gui.EnableScreenClicker(false)
	end

end)