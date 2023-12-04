-- ╔═╗╔═╦═══╦═══╗───────────────────────
-- ║║╚╝║║╔═╗║╔═╗║───────────────────────
-- ║╔╗╔╗║║─║║╚══╗───────────────────────
-- ║║║║║║║─║╠══╗║──By MacTavish <3──────
-- ║║║║║║╚═╝║╚═╝║───────────────────────
-- ╚╝╚╝╚╩══╗╠═══╝───────────────────────
-- ────────╚╝───────────────────────────

function MQS.Notify(a, b, c, d)
	if SERVER then
		net.Start("MQS.Notify")
		net.WriteString(b)
		net.WriteString(c)
		net.WriteInt(d, 16)
		net.Send(a)
	else
		MQS.DoNotify(a, b, c)
	end
end

function MQS.TaskNotify(a, b, c)
	if SERVER then
		net.Start("MQS.TaskNotify")
		net.WriteString(b)
		net.WriteInt(c, 16)
		net.Send(a)
	else
		MQS.DoTaskNotify(a, b)
	end
end

function MQS.SmallNotify(message, ply, type)
	if SERVER then
		if DarkRP then
			DarkRP.notify(ply, type, 5, message)
		elseif ix then
			ix.util.Notify(message, ply)
		else
			ply:ChatPrint(message)
		end
	else
		if GAMEMODE.AddNotify then
			GAMEMODE:AddNotify(message, type, 5)
		elseif ix then
			ix.util.Notify(message)
		else
			ply:ChatPrint(message)
		end
	end
end

function MQS.IsAdministrator(ply)
	return MQS.MasterAdmins[ply:SteamID()] or MQS.Config.Administrators[ply:GetUserGroup()]
	--return ply:IsSuperAdmin()
end

function MQS.IsEditor(ply)
	return MQS.Config.Editors[ply:GetUserGroup()] or MQS.IsAdministrator(ply)
	--return ply:IsSuperAdmin()
end

function MQS.GetActiveVehicle(ply)
	if (ply.GetSimfphys and ply:GetSimfphys()) and IsValid(ply:GetSimfphys()) then return ply:GetSimfphys() end

	local veh = ply:GetVehicle()

	if IsValid(veh) and IsValid(veh:GetOwner()) and veh:GetOwner().LFS and veh:GetOwner():GetDriver() == ply then return veh:GetOwner() end
	if IsValid(veh) and IsValid(veh:GetParent()) and veh:GetDriver() == ply then return veh:GetParent() end
	if IsValid(veh) then return ply:GetVehicle() end

	return nil
end

function MQS.CanPlayIntro(ply)
	return MQS.Config.IntoQuest and MQS.Config.IntoQuest ~= "" and MQS.Quests[MQS.Config.IntoQuest] and ply.MQSdata.Stored and ply.MQSdata.Stored.QuestList and not ply.MQSdata.Stored.QuestList[MQS.Config.IntoQuest]
end

function MQS.HasQuest(ply)
	if CLIENT and not ply then
		ply = LocalPlayer()
	end

	return MQS.GetNWdata(ply, "active_quest") and {quest = MQS.GetNWdata(ply, "active_quest"), id = MQS.GetNWdata(ply, "active_questid")} or nil
end

function MQS.GetNWdata(ply, id)
	if not ply.MQSdata or not ply.MQSdata[id] then return false end

	return ply.MQSdata[id]
end

function MQS.GetSelfNWdata(ply, id)
	if not ply.MQSdata_self or not ply.MQSdata_self[id] then return false end

	return ply.MQSdata_self[id]
end

function MQS.GetDataStored(ply, id)
	if not ply.MQSdata or not ply.MQSdata.Stored or not ply.MQSdata.Stored[id] then return false end

	return ply.MQSdata.Stored[id]
end

function MQS.ReQuest(quest, ply)
	if SERVER then
		if not MQS.Quests[quest] then return end
		local data = table.Copy(MQS.Quests[quest])

		local json_data = util.TableToJSON(data, false)
		local compressed_data = util.Compress(json_data)
		local bytes_number = string.len(compressed_data)
		net.Start("MQS.ReQuest")
		net.WriteString(quest)
		net.WriteInt(bytes_number, 32)
		net.WriteData(compressed_data, bytes_number)
		if ply then
			net.Send(ply)
		else
			net.Broadcast()
		end
	else
		net.Start("MQS.ReQuest")
			net.WriteString(quest)
		net.SendToServer()
	end
end


function MQS.DataShare(ply, initial)
	if SERVER then
		local data_mod = table.Copy(MQS.ActiveTask)

		for k, v in pairs(data_mod) do
			v.player = v.player:UserID()
		end

		if initial then
			local quests = table.Copy(MQS.Quests)

			for k,v in pairs(quests) do
				v.objects = nil
				v.notloaded = true
			end

			MQS.SendDataToClien({
				index = "Quests",
				data = quests
			}, ply)
		end

		MQS.SendDataToClien({
			index = "ActiveTask",
			data = data_mod,
			mod = "player"
		}, ply)

		MQS.SendDataToClien({
			index = "TaskQueue",
			data = table.Copy(MQS.TaskQueue)
		}, ply)

		MQS.SendDataToClien({
			index = "TaskCount",
			data = table.Copy(MQS.TaskCount)
		}, ply)
	else
		net.Start("MQS.DataShare")
		net.SendToServer()
	end
end

function MQS.ActiveDataShare(ply)
	if SERVER then
		local data_mod = table.Copy(MQS.ActiveTask)

		for k, v in pairs(data_mod) do
			v.player = v.player:UserID()
		end

		MQS.SendDataToClien({
			index = "ActiveTask",
			data = data_mod,
			mod = "player"
		}, ply)
	else
		net.Start("MQS.DataShare")
		net.SendToServer()
	end
end

if CLIENT then
	net.Receive("MQS.GetBigData", function(l, ply)
		local bytes_number = net.ReadInt(32)
		local compressed_data = net.ReadData(bytes_number)
		local real_data = MQS.TableDecompress(compressed_data)

		if real_data.isaltdata then
			if not MQS.AltDate then
				MQS.AltDate = {}
			end

			MQS.AltDate[real_data.index] = real_data.data

			if MQS.AltDateUpdate then
				MQS.AltDateUpdate()
			end

			return
		end

		if real_data.isplayerdata then
			local pl_d = Player(real_data.isplayerdata)
			if not IsValid(pl_d) then return end

			if not pl_d.MQSdata then
				pl_d.MQSdata = {}
				pl_d.MQSdata.Stored = {}
			end

			if not pl_d.MQSdata.Stored then
				pl_d.MQSdata.Stored = {}
			end

			if real_data.index == "none" then
				pl_d.MQSdata = real_data.data
			else
				pl_d.MQSdata.Stored[real_data.index] = real_data.data
			end

			return
		end

		MQS[real_data.index] = real_data.data

		if real_data.mod then
			for k, v in pairs(MQS[real_data.index]) do
				if v[real_data.mod] then
					v[real_data.mod] = Player(v[real_data.mod])
				end
			end
		end
	end)

	net.Receive("MQS.SetPData", function()
		local id = net.ReadString()
		local data = net.ReadString()
		local ply = net.ReadEntity()

		if tonumber(data) then data = tonumber(data) end

		if ply and IsValid(ply) and ply:IsPlayer() then
			if not ply.MQSdata then
				ply.MQSdata = {}
			end

			if data == "" then
				ply.MQSdata[id] = nil
			else
				ply.MQSdata[id] = data
			end

		else
			if not LocalPlayer().MQSdata_self then
				LocalPlayer().MQSdata_self = {}
			end

			if data == "" then
				LocalPlayer().MQSdata_self[id] = nil
			else
				LocalPlayer().MQSdata_self[id] = data
			end
		end
	end)

	net.Receive("MQS.ReQuest", function()
		local id = net.ReadString()
		local bytes_number = net.ReadInt(32)
		local compressed_data = net.ReadData(bytes_number)
		local real_data = MQS.TableDecompress(compressed_data)

		if not id then return end
		MQS.Quests[id] = real_data

		if MQS.SetupMenu then
			MQS.SetupMenu.OnQuestUpdate(id)
		end
	end)

	net.Receive("MQS.QuestRemove", function()
		local id = net.ReadString()
		MQS.Quests[id] = nil

		if MQS.SetupMenu then
			MQS.SetupMenu.OnQuestUpdate(id)
		end
	end)

	-- Request quest and player data from server
	net.Start("MQS.GetPData")
	net.SendToServer()

	MQS.DataShare(nil, true)
end