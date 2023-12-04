net.Receive("RD_ROLL_COMMAND_SEND_ROLL", function()
	local roll = net.ReadUInt(7)
	local player = net.ReadEntity()
	local config = RD_ROLL_COMMAND_CFG_SH

	if roll and player:IsValid() then
		LocalPlayer():RD_SendNotification(config.PrefixColor, "["..config.Prefix.."] ", Color(160,160,160), player:Name().." ha lanzado un dado, su puntuación es de ", config.RollColor, tostring(roll)..".")
	end
end)