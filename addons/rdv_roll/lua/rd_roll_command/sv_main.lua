util.AddNetworkString("RD_ROLL_COMMAND_SEND_ROLL")

hook.Add("PlayerSay", "RD_ROLL_COMMAND", function(ply, text)
	if string.sub(string.lower(text), 1, 5) == "/roll" then
		local roll = math.random(0, 100)
		local radius = ents.FindInSphere(ply:GetPos(), RD_ROLL_COMMAND_CFG_SH.Radius)

		for k, v in ipairs(radius) do
			if v:IsPlayer() then
				net.Start("RD_ROLL_COMMAND_SEND_ROLL")
					net.WriteUInt(roll, 7)
					net.WriteEntity(ply)
				net.Send(v)
			end
		end

		return ""
	end
	if string.sub(string.lower(text), 1, 5) == "/dado" then
		local roll = math.random(0, 100)
		local radius = ents.FindInSphere(ply:GetPos(), RD_ROLL_COMMAND_CFG_SH.Radius)

		for k, v in ipairs(radius) do
			if v:IsPlayer() then
				net.Start("RD_ROLL_COMMAND_SEND_ROLL")
					net.WriteUInt(roll, 7)
					net.WriteEntity(ply)
				net.Send(v)
			end
		end

		return ""
	end
	if string.sub(string.lower(text), 1, 5) == "/dados" then
		local roll = math.random(0, 100)
		local radius = ents.FindInSphere(ply:GetPos(), RD_ROLL_COMMAND_CFG_SH.Radius)

		for k, v in ipairs(radius) do
			if v:IsPlayer() then
				net.Start("RD_ROLL_COMMAND_SEND_ROLL")
					net.WriteUInt(roll, 7)
					net.WriteEntity(ply)
				net.Send(v)
			end
		end

		return ""
	end
end)