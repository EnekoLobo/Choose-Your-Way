-- ╔═╗╔═╦═══╦═══╗───────────────────────
-- ║║╚╝║║╔═╗║╔═╗║───────────────────────
-- ║╔╗╔╗║║─║║╚══╗───────────────────────
-- ║║║║║║║─║╠══╗║──By MacTavish <3──────
-- ║║║║║║╚═╝║╚═╝║───────────────────────
-- ╚╝╚╝╚╩══╗╠═══╝───────────────────────
-- ────────╚╝───────────────────────────
function MQS.SendDataToClien(data, ply)
	local json_data = util.TableToJSON(data, false)
	local compressed_data = util.Compress(json_data)
	local bytes_number = string.len(compressed_data)
	net.Start("MQS.GetBigData")
	net.WriteInt(bytes_number, 32)
	net.WriteData(compressed_data, bytes_number)
	if ply then
		net.Send(ply)
	else
		net.Broadcast()
	end
end

function MQS.SavePlayerData(ply, data)
	data = data or ply.MQSdata.Stored
	local sid = isstring(ply) and ply or ply:SteamID()
	sid = MQS.DB.Escape(sid)

	local json = MQS.DB.Escape(util.TableToJSON(data))

	MQS.DB.Query("DELETE FROM mqs_player WHERE id=" .. sid, function()
		MQS.DB.Query("INSERT INTO mqs_player VALUES(" .. sid .. ", " .. json .. ")")
	end)

end

function MQS.SetSelfNWdata(ply, id, data)

	if not ply.MQSdata_self then ply.MQSdata_self = {} end

	ply.MQSdata_self[id] = data

	net.Start("MQS.SetPData")
		net.WriteString(id)
		net.WriteString(data or "")
	net.Send(ply)

end

function MQS.SetNWdata(ply, id, data)

	if not ply.MQSdata then ply.MQSdata = {} end

	net.Start("MQS.SetPData")
		net.WriteString(id)
		net.WriteString(data or "")
		net.WriteEntity(ply)
	net.Broadcast()

	ply.MQSdata[id] = data

end

function MQS.SetNWStoredData(ply, id, data)
	ply.MQSdata.Stored[id] = data

	MQS.SendDataToClien({index = id, data = data, isplayerdata = ply:UserID()}, ply)

	MQS.SavePlayerData(ply)
end

function MQS.QuestRemove(id)
	if not id or not MQS.Quests[id] then return end

	for k, v in pairs(MQS.ActiveTask) do
		if v.task == id and IsValid(v.player) then
			MQS.FailTask(v.player, "Quest removed")
		end
	end

	MQS.Quests[id] = nil
	net.Start("MQS.QuestRemove")
		net.WriteString(id)
	net.Broadcast()
	MQS.RemoveQuestData(id)
end

function MQS.SpamBlock(ply,t)
	if ply.MQSlasCkeck and ply.MQSlasCkeck + t > CurTime() then return true end
	ply.MQSlasCkeck = CurTime()
	return false
end

net.Receive("MQS.QuestSubmit", function(l, ply)
	if not MQS.IsEditor(ply) then return end
	if MQS.SpamBlock(ply,1) then return end

	local bytes_number = net.ReadInt(32)
	local compressed_data = net.ReadData(bytes_number)
	local json_data = util.Decompress(compressed_data)
	local quest = util.JSONToTable(json_data)

	if not quest then return end
	local id = quest.id

	if not MQS.CheckID(id) then
		MQS.SmallNotify(MSD.GetPhrase("inv_quest") .. " ID", ply, 1)
		return
	end

	if MQS.Quests[id] and MQS.Quests[id].active and not MQS.IsAdministrator(ply) then
		MQS.SmallNotify("You can't edit active quests", ply, 1)
		return
	end

	if quest.oldid and quest.oldid ~= id and MQS.Quests[quest.oldid] then
		MQS.QuestRemove(quest.oldid)
	end

	quest.id = nil
	quest.oldid = nil
	quest.new = nil
	quest.active = quest.active or false
	MQS.Quests[id] = quest
	MQS.ReQuest(id)
	MQS.SaveQuestData(id, quest)
end)

net.Receive("MQS.ReQuest", function(l, ply)
	if MQS.SpamBlock(ply,0.5) then return end
	local quest = net.ReadString()
	MQS.ReQuest(quest, ply)
end)

net.Receive("MQS.QuestRemove", function(l, ply)
	if not MQS.IsAdministrator(ply) then return end
	if MQS.SpamBlock(ply,1) then return end
	local id = net.ReadString()
	MQS.QuestRemove(id)
end)

net.Receive("MQS.GetOtherQuests", function(l, ply)
	if MQS.SpamBlock(ply,1) then return end

	local map = net.ReadString()
	if not map then return end
	local data_mod = MQS.DB.GetMapData(map)
	if not data_mod then return end

	MQS.SendDataToClien({
		index = "Quests",
		data = data_mod,
		isaltdata = true
	}, ply)
end)

net.Receive("MQS.GetPlayersQuests", function(l, ply)
	if MQS.SpamBlock(ply,1) then return end
	if not MQS.IsAdministrator(ply) then return end
	local sid = net.ReadString()
	local tbl = MQS.DB.GetPlayerData(sid)

	if tbl then
		local json_data = util.TableToJSON(tbl, false)
		local compressed_data = util.Compress(json_data)
		local bytes_number = string.len(compressed_data)
		net.Start("MQS.GetPlayersQuests")
			net.WriteString(sid)
			net.WriteInt(bytes_number, 32)
			net.WriteData(compressed_data, bytes_number)
		net.Send(ply)
	end
end)

net.Receive("MQS.SavePlayerQuestList", function(l, ply)
	if MQS.SpamBlock(ply,1) then return end
	if not MQS.IsAdministrator(ply) then return end
	local sid = net.ReadString()
	local bytes_number = net.ReadInt(32)
	local data = net.ReadData(bytes_number)
	data = util.Decompress(data)
	data = util.JSONToTable(data)

	for k,v in pairs(data) do
		if tonumber(v) < 1 then data[k] = nil continue end
		data[k] = tonumber(v) or 0
	end

	local pl = player.GetBySteamID(sid)

	if pl then
		MQS.SetNWStoredData(pl, "QuestList", data)
	else
		local tbl = MQS.DB.GetPlayerData(sid)

		if tbl then
			tbl.QuestList = data
			MQS.SavePlayerData(sid, tbl)
		end
	end

end)

-- Send request quest and player data from server to new players
net.Receive("MQS.GetPData", function(l, ply)
	if ply.MQSgotData then return end

	for _, pl in ipairs(player.GetAll()) do
		for k, v in pairs(pl.MQSdata) do
			if istable(v) then continue end
			net.Start("MQS.SetPData")
				net.WriteString(k)
				net.WriteString(v or "")
				net.WriteEntity(ply)
			net.Send(ply)
		end
	end

	MQS.SendDataToClien({index = "none", data = ply.MQSdata, isplayerdata = ply:UserID()}, ply)

	ply.MQSgotData = true

	if MQS.Config.IntoQuestAutogive and MQS.CanPlayIntro(ply) then
		MQS.StartTask(MQS.Config.IntoQuest, ply, nil, true)
	end
end)

net.Receive("MQS.DataShare", function(l, ply)
	MQS.DataShare(ply, true)
end)

hook.Add("PlayerInitialSpawn", "MQS.PlayerInitialSpawn", function(ply)

	if not ply.MQSdata then ply.MQSdata = {} end

	if not ply.MQSdata.Stored then ply.MQSdata.Stored = {initdata = 0} end

	local sid = MQS.DB.Escape(ply:SteamID())

	print("[MQS] Player's data tabes setup finish")

	MQS.DB.Query("SELECT * FROM mqs_player WHERE id=" .. sid, function(result)
		if result ~= nil and #result > 0 then

			local tbl = util.JSONToTable(result[1].value)

			if tbl and istable(tbl) then
				print("[MQS] Player's stored data loaded")
				ply.MQSdata.Stored = tbl
			end
		else
			MQS.DB.Query("INSERT INTO mqs_player VALUES(" .. sid .. ", '[]')")
			print("[MQS] No player stored data, creating one")
		end
	end)
end)