-- ╔═╗╔═╦═══╦═══╗───────────────────────
-- ║║╚╝║║╔═╗║╔═╗║───────────────────────
-- ║╔╗╔╗║║─║║╚══╗───────────────────────
-- ║║║║║║║─║╠══╗║──By MacTavish <3──────
-- ║║║║║║╚═╝║╚═╝║───────────────────────
-- ╚╝╚╝╚╩══╗╠═══╝───────────────────────
-- ────────╚╝───────────────────────────
--──────────────────────────────────--
---------- Util functions ------------
--──────────────────────────────────--
function MQS.CheckID(id)
	id = string.match( id, "^[a-zA-Z0-9_]*$" )
	if tonumber(id) then return false end
	return id
end

function MQS.TableCompress(data)
	local json_data = util.TableToJSON(data, false)
	local compressed_data = util.Compress(json_data)
	local bytes_number = string.len(compressed_data)

	return compressed_data, bytes_number
end

function MQS.TableDecompress(compressed_data)
	local json_data = util.Decompress(compressed_data) or "[]"
	local data = util.JSONToTable(json_data)

	return data
end

function MQS.HasNPCLink(link, npc)
	if istable(link) then return link.id == npc end

	return link == npc
end

function MQS.QuestStatusCheck(tk, ply)
	if CLIENT and not ply then ply = LocalPlayer() end
	if ply.MQSdata and ply.MQSdata.Stored and ply.MQSdata.Stored.QuestList and ply.MQSdata.Stored.QuestList[tk] then return ply.MQSdata.Stored.QuestList[tk] end
	return false
end

function MQS.CanStartTask(tk, ply, npc, force)
	if CLIENT then
		ply = LocalPlayer()
	end

	local task = MQS.Quests[tk]

	if not task then return false, MSD.GetPhrase("inv_quest") end

	if not ply or not IsValid(ply) or not ply:Alive() then return false, MSD.GetPhrase("dead") end

	if MQS.HasQuest(ply) then return false, MSD.GetPhrase("active_quest") end

	if not force then
		local block, reason = hook.Call("MQS.PreventTaskStart", nil, ply, tk, task)
		if block then return false, reason or MSD.GetPhrase("inactive_quest") end

		if not MQS.IsEditor(ply) and not task.active and not MQS.Config.NPC.enable then return false, MSD.GetPhrase("inactive_quest") end

		if (CLIENT or not MQS.IsEditor(ply)) and MQS.Config.NPC.enable and (not npc or not task.link or not MQS.HasNPCLink(task.link, npc)) then return false, MSD.GetPhrase("inactive_quest") end

		local tm = ply:Team()

		if not task.team_blacklist and task.team_whitelist and not task.team_whitelist[tm] then return false, MSD.GetPhrase("team_bl") end

		if task.team_blacklist and task.team_whitelist and task.team_whitelist[tm] then return false, MSD.GetPhrase("team_bl") end

		if task.need_players and #player.GetAll() < task.need_players then return false, MSD.GetPhrase("no_players") end

		if task.cant_replay and ply.MQSdata.Stored and ply.MQSdata.Stored.QuestList and ply.MQSdata.Stored.QuestList[tk] then return false, MSD.GetPhrase("q_noreplay") end

		if task.quest_needed and MQS.Quests[task.quest_needed] and not MQS.Quests[task.quest_needed].looped and (not ply.MQSdata.Stored.QuestList or not ply.MQSdata.Stored.QuestList[task.quest_needed]) then return false, MSD.GetPhrase("q_needquest") end

		if not task.cooldow_perply and MQS.TaskQueue[tk] and MQS.TaskQueue[tk] > CurTime() then return false, MSD.GetPhrase("q_time_wait") end

		if task.cooldow_perply and ply.MQSdata.Stored.CoolDown and ply.MQSdata.Stored.CoolDown[tk] and ply.MQSdata.Stored.CoolDown[tk] > os.time() then return false, MSD.GetPhrase("q_time_wait") end

		if task.limit and MQS.TaskCount[tk] and MQS.TaskCount[tk] >= task.limit then return false, MSD.GetPhrase("q_play_limit") end

		if task.conflictlist then
			for qst, _ in pairs(task.conflictlist) do
				if MQS.TaskCount[qst] and MQS.TaskCount[qst] > 0 then
					return false, MSD.GetPhrase("q_play_limit")
				end
			end
		end

		if task.quest_blacklist and ply.MQSdata.Stored.QuestList then
			for qst, _ in pairs(task.quest_blacklist) do
				if ply.MQSdata.Stored.QuestList[qst] then
					return false, MSD.GetPhrase("inactive_quest")
				end
			end
		end

		if task.need_teamplayers then
			for tms, num in pairs(task.need_teamplayers) do
				if team.NumPlayers(tms) < tonumber(num) then return false, MSD.GetPhrase("no_players_team") end
			end
		end
	end

	return true
end

function MQS.ActiveQuestLists(npc, ply)
	if CLIENT and not ply then ply = LocalPlayer() end

	local a_quests = {}

	for k, v in pairs(MQS.Quests) do
		if MQS.CanStartTask(k, ply, npc) then
			a_quests[k] = true
		end
	end

	return a_quests
end