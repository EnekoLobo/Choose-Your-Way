local Ln = MSD.GetPhrase
local mouleid = 0

local blank_quest = {
	name = Ln("q_new"),
	desc = "",
	success = "",
	active = false,
	new = true,
}

local blank_quest_new = table.Copy(blank_quest)

local blank_npc = {
	name = Ln("npc_new"),
	model = "models/Humans/Group01/Male_0" .. math.random(1, 9) .. ".mdl",
	text = "",
	text_notask = "",
	answer_yes = "",
	answer_no = "",
	answer_notask = "",
	skin = 0,
	bgr = {},
	spawns = {},
}

local active_quest
local last_sm = "ui"

if not file.Exists("mqs", "DATA") then
	file.CreateDir("mqs")
end

local function AutoSave()
	if not active_quest or not active_quest.new then return end
	file.Write("mqs/autosave.txt", util.TableToJSON(active_quest))
end

local function LoadAutoSave()
	if file.Exists("mqs/autosave.txt", "DATA") then
		local jsontable = file.Read("mqs/autosave.txt", "DATA")
		blank_quest = util.JSONToTable(jsontable)
		active_quest = blank_quest
	end
end

local function QuestListPanel(parent, k, v, openPage)
	local qpnl = vgui.Create("DPanel")
	qpnl.StaticScale = {
		w = 4,
		fixed_h = 120,
		minw = 200,
		minh = 120
	}

	qpnl.Paint = function(self, w, h)
		draw.RoundedBox(MSD.Config.Rounded, 0, 0, w, h, MSD.Theme["d"])
		draw.DrawText(v.name, "MSDFont.25", 10, 10, color_white, TEXT_ALIGN_LEFT)
		local active = MQS.Config.NPC.enable and v.link or v.active
		MSD.DrawTexturedRect(w - 32, h - 32, 32, 32, MSD.Icons48.dot, active and MSD.Config.MainColor["p"] or MSD.Text.n)
		draw.DrawText(Ln(active and "active" or "inactive"), "MSDFont.16", w - 28, h - 25, MSD.Text.d, TEXT_ALIGN_RIGHT)
	end

	local bpnl = vgui.Create("MSDPanelList", qpnl)
	bpnl:SetSize(200, 36)
	bpnl:DockMargin(5, 5, 5, 5)
	bpnl:SetSpacing(2)
	bpnl:EnableHorizontal(true)
	bpnl:Dock(BOTTOM)

	MSD.IconButtonBG(bpnl, MSD.Icons48.play, nil, nil, 36, nil, MSD.Config.MainColor.p, function()
		RunConsoleCommand("mqs_start", k)
	end)

	MSD.IconButtonBG(bpnl, v.notloaded and MSD.Icons48.save or MSD.Icons48.pencil, nil, nil, 36, nil, MSD.Config.MainColor.p, function()
		openPage("edit", true, true, k, v)
		if v.notloaded then MQS.ReQuest(k) end
	end)

	parent:AddItem(qpnl)
end

function MQS.OpenMenuManager(parrent, editor, npc)
	if MQS.IsEditor(LocalPlayer()) then
		MSD.OpenMenuManager(nil, mouleid)
	elseif not editor then
		if MQS.Config.NPC.enable and not npc then
			local found = false

			for _, e in ipairs(ents.FindByClass("mqs_npc")) do
				if IsValid(e) then
					found = true
					break
				end
			end

			MQS.DoHint(found and Ln("q_get") or Ln("q_noquests"), found and 4 or 2)
		else
			MQS.OpenPlayerMenu(parrent)
		end
	else
		MQS.SmallNotify(Ln("need_admin"), nil, 1)
	end
end

net.Receive("MQS.GetPlayersQuests", function()
	if not IsValid(MQS.PlayerDataPanel) then return end
	local sid = net.ReadString()
	local bytes_number = net.ReadInt(32)
	local compressed_data = net.ReadData(bytes_number)
	local data = MQS.TableDecompress(compressed_data)
	MQS.PlayerDataPanel.Update(data, sid)
end)

net.Receive("MQS.OpenEditor", function()
	MQS.OpenMenuManager()
end)

concommand.Add("mqs_editor", function(pl, cmd, args)
	MQS.OpenMenuManager()
end)

function MQS.NPCAnimationMenu(parent, ent, setanim)
	local mx, my = gui.MousePos()
	local frame = vgui.Create("DFrame")
	frame:SetSize(300, 400)
	frame:SetPos(mx - 300, my - 400)
	frame:SetDraggable(true)
	frame:ShowCloseButton(true)
	frame:MakePopup()
	frame:SetTitle("Animations List")
	frame.StartT = CurTime() + 2

	frame.Think = function(self)
		if not IsValid(parent) or (not self:HasFocus() and self.StartT < CurTime()) then
			self:Close()
		end
	end

	local AnimList = vgui.Create("DListView", frame)
	AnimList:AddColumn("name")
	AnimList:Dock(FILL)
	AnimList:SetMultiSelect(false)
	AnimList:SetHideHeaders(true)

	for k, v in SortedPairsByValue(ent:GetSequenceList() or {}) do
		local line = AnimList:AddLine(string.lower(v))

		line.OnSelect = function()
			setanim(v)
		end
	end

	return frame
end

function MQS.OpenAdminMenu(panel, mainPanel)

	if not panel then return end
	MQS.SetupMenu = panel

	function mainPanel.ModuleSwitch()
		MQS.SetupMenu = nil
		MQS.UpdateMenuElements = nil
		AutoSave()
	end

	panel.Canvas = vgui.Create("MSDPanelList", panel)
	panel.Canvas:SetSize(panel:GetWide() - 252, panel:GetTall())
	panel.Canvas:SetPos(252, 0)
	panel.Canvas:EnableVerticalScrollbar()
	panel.Canvas:EnableHorizontal(true)
	panel.Canvas:SetSpacing(2)
	panel.Canvas.IgnoreVbar = true
	panel.Canvas.Paint = function() end
	local pages = {}
	local cur_page = nil

	local function openPage(id, animate, ...)
		panel.Canvas:Clear()
		back_page = cur_page
		pages[id](...)
		cur_page = id

		if animate then
			panel.Canvas:SetAlpha(1)
			panel.Canvas:AlphaTo(255, 0.2)
		end
	end

	panel.OnQuestUpdate = function(qid)
		if cur_page == "quests" then
			openPage("quests", true)

			return
		end

		if active_quest and active_quest.id == qid then
			openPage("quests", true)

			return
		end
	end

	local buttons = {}

	buttons[1] = {
		Ln("quests"), MSD.Icons48.layers, function()
			openPage("quests", true)
		end,
		true
	}
	if MQS.IsAdministrator(LocalPlayer()) then
		buttons[2] = {
			Ln("npc_editor"), MSD.Icons48.account_multiple, function()
				openPage("npcs", true)
			end
		}
		buttons[3] = {
			Ln("settings"), MSD.Icons48.cog, function()
				openPage("settings", true)
			end
		}
	end

	panel.Menu = vgui.Create("MSDPanelList", panel)
	panel.Menu:SetSize(250, panel:GetTall())
	panel.Menu:SetPos(0, 0)
	panel.Menu:EnableVerticalScrollbar()
	panel.Menu:EnableHorizontal(false)
	panel.Menu:SetSpacing(0)
	panel.Menu.IgnoreVbar = true

	panel.Menu.Paint = function(self, w, h)
		draw.RoundedBox(MSD.Config.Rounded, 0, 0, w, h, MSD.Theme["l"])
	end

	panel.Menu.Deselect = function(but)
		if not but then return end
		but.hovered = true

		for k, v in pairs(panel.Menu:GetItems()) do
			if v and v:IsValid() and v ~= but then
				v.hovered = false
			end
		end
	end

	local function PopupMenu(text, x, y, w, dwd)
		local pl, child = MSD.WorkSpacePanel(mainPanel, text, x, y, false)
		local sub_list = vgui.Create("MSDPanelList", child)
		sub_list:SetSize(dwd and child:GetWide() / dwd or child:GetWide() - 10, child:GetTall() - w)
		sub_list:SetPos(5, w)
		sub_list:EnableVerticalScrollbar()
		sub_list:EnableHorizontal(true)
		sub_list:SetSpacing(2)
		sub_list.IgnoreVbar = true

		return sub_list, child, pl
	end

	pages["quests"] = function()
		if MQS.Config.Sort then
			local catgr = {}
			MSD.Header(panel.Canvas, Ln("unsorted"), function()
				openPage("search")
			end, MSD.Icons48.search)

			MSD.BigButton(panel.Canvas, "static", nil, 4, 120, Ln("q_addnew"), MSD.Icons48.layers_plus, function()
				openPage("edit", true, true, true)
			end)

			for k, v in pairs(MQS.Quests) do
				if not v.category then
					QuestListPanel(panel.Canvas, k, v, openPage)
					continue
				end
				if catgr[v.category] then
					catgr[v.category][k] = true
				else
					catgr[v.category] = { [k] = true }
				end
			end

			for name, qlist in pairs(catgr) do
				MSD.Header(panel.Canvas, name)
				for k, _ in pairs(qlist) do
					QuestListPanel(panel.Canvas, k, MQS.Quests[k], openPage)
				end
			end
		else
			MSD.Header(panel.Canvas, Ln("quest_list"), function()
				openPage("search")
			end, MSD.Icons48.search)

			MSD.BigButton(panel.Canvas, "static", nil, 4, 120, Ln("q_addnew"), MSD.Icons48.layers_plus, function()
				openPage("edit", true, true, true)
			end)

			for k, v in pairs(MQS.Quests) do
				QuestListPanel(panel.Canvas, k, v, openPage)
			end
		end
	end

	pages["search"] = function()
		local obj_sets

		MSD.Header(panel.Canvas, Ln("search"), function()
			openPage("quests")
		end)

		MSD.TextEntry(panel.Canvas, "static", nil, 1, 50, Ln("enter_name") .. "/ID", Ln("search_q") .. ":", "", function(self, value)
			obj_sets.Update(value)
		end, true)

		obj_sets = vgui.Create("MSDPanelList")
		obj_sets:SetSize(panel.Canvas:GetWide(), panel.Canvas:GetTall() - 110)
		obj_sets:EnableVerticalScrollbar()
		obj_sets:EnableHorizontal(true)
		obj_sets:SetSpacing(2)
		obj_sets:SetPadding(0)
		obj_sets.IgnoreVbar = true
		obj_sets.Update = function(value)
			obj_sets:Clear()
			for k, v in pairs(MQS.Quests) do
				if not value then continue end
				if not string.find(string.lower(k), string.lower(value), 1, true) and not string.find(string.lower(v.name), string.lower(value), 1, true) then continue end
			 	QuestListPanel(obj_sets, k, v, openPage)
			end
		end
		obj_sets.Update("")
		panel.Canvas:AddItem(obj_sets)
	end

	pages["edit"] = function(open, id, quest)
		if open then
			if not quest and id == true then
				quest = blank_quest
				id = blank_quest.id or "new_quest"

				if not quest.edited then
					local pl, _, plm = PopupMenu(Ln("load_autosave"), 3, 5, 55)

					MSD.Button(pl, "static", nil, 1, 50, Ln("load_save"), function()
						LoadAutoSave()
						plm.Close()
					end)

					MSD.Button(pl, "static", nil, 1, 50, Ln("create_new"), function()
						active_quest = table.Copy(blank_quest_new)
						active_quest.id = "new_quest"
						plm.Close()
					end)
				end
				quest.edited = true
			end
			active_quest = quest
			active_quest.id = id
		end

		MSD.Header(panel.Canvas, Ln("quest_editor"), function()
			openPage("quests", true)
			AutoSave()
		end)

		MSD.BigButton(panel.Canvas, "static", nil, 3, 180, Ln("main_opt"), MSD.Icons48.playlist_edit, function()
			openPage("edit_page1", true)
		end)

		MSD.BigButton(panel.Canvas, "static", nil, 3, 180, Ln("q_editobj"), MSD.Icons48.calendar_check, function()
			openPage("edit_page2", true)
		end)

		MSD.BigButton(panel.Canvas, "static", nil, 3, 180, Ln("q_editrwd"), MSD.Icons48.seal, function()
			openPage("edit_page3", true)
		end)

		if active_quest.new then
			MSD.BigButton(panel.Canvas, "static", nil, 3, 100, Ln("q_submit"), MSD.Icons48.submit, function()
				if MQS.Quests[active_quest.id] then
					local pl, _, plm = PopupMenu(Ln("q_id_unique"), 3, 5, 55)

					MSD.Button(pl, "static", nil, 1, 50, Ln("ok"), function()
						plm.Close()
					end)
					return
				end
				openPage("quests", true)
				active_quest.temp_data = nil
				active_quest.edited = nil

				MQS.QuestSubmit(active_quest)
			end)

			MSD.BigButton(panel.Canvas, "static", nil, 3, 100, Ln("copy_data"), MSD.Icons48.copy, function()
				openPage("quests_copy", true)
			end)
		else
			MSD.BigButton(panel.Canvas, "static", nil, 3, 100, Ln("save_chng"), MSD.Icons48.save, function()
				active_quest.temp_data = nil
				openPage("quests", true)
				MQS.QuestSubmit(active_quest)
			end)

			MSD.BigButton(panel.Canvas, "static", nil, 3, 100, Ln("remove"), MSD.Icons48.layers_remove, function()
				local pl, _, plm = PopupMenu(Ln("confirm_action"), 3, 5, 55)

				MSD.Button(pl, "static", nil, 1, 50, Ln("q_remove"), function()
					openPage("quests", true)
					net.Start("MQS.QuestRemove")
					net.WriteString(active_quest.id)
					net.SendToServer()
					plm.Close()
				end)

				MSD.Button(pl, "static", nil, 1, 50, Ln("cancel"), function()
					plm.Close()
				end)
			end)
		end

		MSD.BigButton(panel.Canvas, "static", nil, 3, 100, Ln("check_fpr_errors"), MSD.Icons48.alert, function()
			MQS.PreCheckQuest(active_quest, PopupMenu)
		end)
	end

	pages["edit_page1"] = function()
		MSD.Header(panel.Canvas, Ln("main_opt"), function()
			openPage("edit", true)
		end)

		MSD.TextEntry(panel.Canvas, "static", nil, MQS.Config.Sort and 3 or 2, 50, Ln("enter_name"), Ln("name") .. ":", active_quest.name, function(self, value)
			active_quest.name = value
		end, true)

		if not active_quest.oldid then
			active_quest.oldid = active_quest.id
		end

		MSD.TextEntry(panel.Canvas, "static", nil, MQS.Config.Sort and 3 or 2, 50, Ln("enter_id"), "ID:", active_quest.id, function(self, value)
			if not MQS.CheckID(value) then
				self.error = Ln("inv_quest") .. " ID"
				return
			end

			if MQS.Quests[value] and active_quest.oldid ~= value then
				self.error = Ln("q_id_unique")
				return
			end

			active_quest.id = value
			self.error = nil
		end, true)

		if MQS.Config.Sort then
			MSD.TextEntry(panel.Canvas, "static", nil, 3, 50, Ln("category_des"), Ln("category"), active_quest.category, function(self, value)
				active_quest.category = value ~= "" and value or nil
			end, true)
		end

		MSD.TextEntry(panel.Canvas, "static", nil, 1, 200, Ln("enter_description"), nil, active_quest.desc, function(self, value)
			active_quest.desc = value
		end, true, nil, true)

		MSD.TextEntry(panel.Canvas, "static", nil, 1, 50, Ln("e_text"), Ln("q_complete_msg") .. ":", active_quest.success, function(self, value)
			active_quest.success = value
		end, true)

		local sld1, sld2

		MSD.TextEntry(panel.Canvas, "static", nil, 3, 50, Ln("e_blank_dis"), Ln("q_dotime") .. "(" .. Ln("in_sec") .. "):", active_quest.do_time, function(self, value)
			active_quest.do_time = tonumber(value) or nil

			if not active_quest.do_time then
				sld1.disabled = true
			else
				sld1.disabled = nil
			end
		end, true, nil, nil, true)

		MSD.DTextSlider(panel.Canvas, "static", nil, 3, 50, Ln("q_dotime_ok"), Ln("q_dotime_fail"), active_quest.reward_on_time, function(self, value)
			active_quest.reward_on_time = value
		end)

		MSD.BoolSlider(panel.Canvas, "static", nil, 3, 50, Ln("q_stop_anytime"), active_quest.stop_anytime, function(self, value)
			active_quest.stop_anytime = value
		end)

		sld1 = MSD.BoolSlider(panel.Canvas, "static", nil, 2, 50, Ln("q_loop"), active_quest.looped, function(self, value)
			active_quest.looped = value
			sld2.disabled = not value
		end)

		if not active_quest.do_time then
			sld1.disabled = true
		else
			sld1.disabled = nil
		end

		sld2 = MSD.BoolSlider(panel.Canvas, "static", nil, 2, 50, Ln("q_loop_reward"), active_quest.reward_ower_loop, function(self, value)
			active_quest.reward_ower_loop = value
		end)

		sld2.disabled = not active_quest.looped

		MSD.BoolSlider(panel.Canvas, "static", nil, 2, 50, Ln("q_death_fail"), active_quest.fail_ondeath, function(self, value)
			active_quest.fail_ondeath = value
		end)

		MSD.DTextSlider(panel.Canvas, "static", nil, 2, 50, Ln("q_cooldow_publick"), Ln("q_cooldow_perply"), active_quest.cooldow_perply, function(self, value)
			active_quest.cooldow_perply = value
		end)

		MSD.TextEntry(panel.Canvas, "static", nil, 2, 50, Ln("e_blank_dis"), Ln("cooldown_ok") .. "(" .. Ln("in_sec") .. "):", active_quest.cool_down, function(self, value)
			active_quest.cool_down = tonumber(value) or nil
		end, true, nil, nil, true)

		MSD.TextEntry(panel.Canvas, "static", nil, 2, 50, Ln("e_blank_dis"), Ln("cooldown_fail") .. "(" .. Ln("in_sec") .. "):", active_quest.cool_down_onfail, function(self, value)
			active_quest.cool_down_onfail = tonumber(value) or nil
		end, true, nil, nil, true)

		MSD.TextEntry(panel.Canvas, "static", nil, 3, 50, Ln("e_blank_dis"), Ln("q_ply_limit") .. ":", active_quest.limit, function(self, value)
			active_quest.limit = tonumber(value) or nil
		end, true, nil, nil, true)

		MSD.TextEntry(panel.Canvas, "static", nil, 3, 50, Ln("e_blank_dis"), Ln("q_ply_need") .. ":", active_quest.need_players, function(self, value)
			active_quest.need_players = tonumber(value) or nil
		end, true, nil, nil, true)

		MSD.Button(panel.Canvas, "static", nil, 3, 50, Ln("q_ply_team_limit"), function()
			local sub_list, child = PopupMenu(Ln("q_ply_team_need"), 2, 1.2, 102)
			local update

			MSD.BoolSlider(child, 5, 50, child:GetWide() - 10, 50, Ln("enable_option"), active_quest.need_teamplayers and true or false, function(self, var)
				if var then
					active_quest.need_teamplayers = {}
				else
					active_quest.need_teamplayers = nil
				end

				update()
			end)

			update = function()
				if not sub_list then return end
				sub_list:Clear()
				if not active_quest.need_teamplayers then return end
				MSD.InfoHeader(sub_list, Ln("e_blank_dis"))

				for tid, tm in SortedPairsByMemberValue(team.GetAllTeams(), "Name", true) do
					if not tm.Joinable then continue end

					MSD.TextEntry(sub_list, "static", nil, 2, 50, "", tm.Name, active_quest.need_teamplayers[tid], function(self, val)
						active_quest.need_teamplayers[tid] = val ~= "" and val or nil
					end, true, nil, nil, true)
				end
			end

			update()
		end)

		local combo = MSD.ComboBox(panel.Canvas, "static", nil, 2, 50, Ln("q_needquest_menu") .. ":", Ln("none"))
		combo:AddChoice(Ln("none"))

		combo.OnSelect = function(self, index, text, data)
			if text == Ln("none") then
				active_quest.quest_needed = nil
				return
			end
			if active_quest.quest_blacklist and active_quest.quest_blacklist[data] then return end
			active_quest.quest_needed = data
		end

		for k, v in pairs(MQS.Quests) do
			if active_quest.id == k then continue end
			if v.quest_needed and v.quest_needed == active_quest.id then continue end
			if v.looped then continue end

			if active_quest.quest_needed == k then
				combo:SetValue(v.name)
			end

			combo:AddChoice(v.name, k)
		end

		MSD.BoolSlider(panel.Canvas, "static", nil, 2, 50, Ln("q_dis_replay"), active_quest.cant_replay, function(self, value)
			active_quest.cant_replay = value
		end)

		MSD.Button(panel.Canvas, "static", nil, 2, 50, Ln("s_team_whitelist"), function()
			local sub_list, child = PopupMenu(Ln("s_team_whitelist"), 2, 1.2, 102)
			local update

			MSD.BoolSlider(child, 5, 50, child:GetWide() - 10, 50, Ln("enable_option"), active_quest.team_whitelist and true or false, function(self, var)
				if var then
					active_quest.team_whitelist = {}
				else
					active_quest.team_whitelist = nil
				end

				update()
			end)

			update = function()
				if not sub_list then return end
				sub_list:Clear()
				if not active_quest.team_whitelist then return end

				for id, tm in SortedPairsByMemberValue(team.GetAllTeams(), "Name", true) do
					if not tm.Joinable then continue end

					MSD.BoolSlider(sub_list, "static", nil, 2, 50, tm.Name, active_quest.team_whitelist[id], function(self, var)
						active_quest.team_whitelist[id] = var
					end)
				end
			end

			update()
		end)

		MSD.BoolSlider(panel.Canvas, "static", nil, 2, 50, Ln("whitelist_blacklist"), active_quest.team_blacklist, function(self, value)
			active_quest.team_blacklist = value
		end)

		if MQS.Config.NPC.enable then
			local npclist = MSD.ComboBox(panel.Canvas, "static", nil, 2, 50, Ln("q_npc_link") .. ":", Ln("none"))
			npclist:AddChoice(Ln("none"))

			npclist.OnSelect = function(self, index, text, data)
				if text == Ln("none") then
					active_quest.link = nil

					return
				end

				active_quest.link = data
			end

			for k, v in pairs(MQS.Config.NPC.list) do
				if not istable(active_quest.link) and active_quest.link == k then
					npclist:SetValue(v.name)
				end

				npclist:AddChoice(v.name, k)
			end

			if MCS then
				for k, v in pairs(MCS.Spawns) do
					if istable(active_quest.link) and active_quest.link.id == k then
						npclist:SetValue("[MCS] " .. v.name)
					end

					if not v.questNPC then continue end

					npclist:AddChoice("[MCS] " .. v.name, {
						id = k,
						base = "mcs"
					})
				end
			end
		elseif MQS.IsAdministrator(LocalPlayer()) then
			MSD.BoolSlider(panel.Canvas, "static", nil, 2, 50, Ln("q_enable"), active_quest.active or false, function(self, value)
				active_quest.active = value
			end)
		end

		MSD.Button(panel.Canvas, "static", nil, 2, 50, Ln("custom_icon"), function()
			local sub_list, child = PopupMenu(Ln("custom_icon"), 2, 3, 102)
			local update

			MSD.BoolSlider(child, 5, 50, child:GetWide() - 10, 50, Ln("enable_option"), active_quest.custom_icon and true or false, function(self, var)
				if var then
					active_quest.custom_icon = ""
				else
					active_quest.custom_icon = nil
				end

				update()
			end)

			update = function()
				if not sub_list then return end
				sub_list:Clear()
				if not active_quest.custom_icon then return end

				MSD.TextEntry(sub_list, "static", nil, 1, 50, Ln("q_icon68"), Ln("e_url"), active_quest.custom_icon, function(self, val)
					if val ~= "" then
						active_quest.custom_icon = val
					end
				end, true)

				local ops_panel = vgui.Create("DPanel")
				ops_panel:SetSize(sub_list:GetWide(), sub_list:GetTall() - 50)

				ops_panel.Paint = function(self, w, h)
					MSD.DrawTexturedRect(5, 5, 68, 68, MSD.ImgLib.GetMaterial(active_quest.custom_icon), color_white)
				end

				sub_list:AddItem(ops_panel)
			end

			update()
		end)
		local update_bl, update_cl
		MSD.Button(panel.Canvas, "static", nil, 2, 50, Ln("s_quest_blacklist"), function()
			local _, child = MSD.WorkSpacePanel(mainPanel, Ln("s_quest_blacklist_desc"), 1, 1.2, false)

			local q_list = vgui.Create("MSDPanelList", child)
			q_list:SetSize(child:GetWide() / 2 - 15, child:GetTall() - 102)
			q_list:SetPos(5, 102)
			q_list:EnableVerticalScrollbar()
			q_list:EnableHorizontal(true)
			q_list:SetSpacing(2)
			q_list.IgnoreVbar = true

			local b_list = vgui.Create("MSDPanelList", child)
			b_list:SetSize(child:GetWide() / 2 - 15, child:GetTall() - 102)
			b_list:SetPos(10 + child:GetWide() / 2 - 15, 102)
			b_list:EnableVerticalScrollbar()
			b_list:EnableHorizontal(true)
			b_list:SetSpacing(2)
			b_list.IgnoreVbar = true

			local status = active_quest.quest_blacklist and true or false
			MSD.BoolSlider(child, 5, 50, child:GetWide() - 10, 50, Ln("enable_option"), status, function(self, var)
				if var then
					active_quest.quest_blacklist = {}
				else
					active_quest.quest_blacklist = nil
				end

				update_bl(var, q_list, b_list)
			end)
			update_bl(status, q_list, b_list)
		end)

		MSD.Button(panel.Canvas, "static", nil, 2, 50, Ln("s_quest_conflictlist"), function()
			local _, child = MSD.WorkSpacePanel(mainPanel, Ln("s_quest_conflictlist_desc"), 1, 1.2, false)

			local q_list = vgui.Create("MSDPanelList", child)
			q_list:SetSize(child:GetWide() / 2 - 15, child:GetTall() - 102)
			q_list:SetPos(5, 102)
			q_list:EnableVerticalScrollbar()
			q_list:EnableHorizontal(true)
			q_list:SetSpacing(2)
			q_list.IgnoreVbar = true

			local b_list = vgui.Create("MSDPanelList", child)
			b_list:SetSize(child:GetWide() / 2 - 15, child:GetTall() - 102)
			b_list:SetPos(10 + child:GetWide() / 2 - 15, 102)
			b_list:EnableVerticalScrollbar()
			b_list:EnableHorizontal(true)
			b_list:SetSpacing(2)
			b_list.IgnoreVbar = true

			local status = active_quest.conflictlist and true or false
			MSD.BoolSlider(child, 5, 50, child:GetWide() - 10, 50, Ln("enable_option"), status, function(self, var)
				if var then
					active_quest.conflictlist = {}
				else
					active_quest.conflictlist = nil
				end

				update_cl(var, q_list, b_list)
			end)
			update_cl(status, q_list, b_list)
		end)

		update_bl = function(upd, q_list, b_list)
			q_list:Clear()
			b_list:Clear()

			if not upd then return end

			MSD.InfoHeader(q_list, Ln("quest_list"))
			MSD.InfoHeader(b_list, Ln("blacklist"))
			for k, v in pairs(MQS.Quests) do
				if active_quest.id == k then continue end
				if active_quest.quest_needed == k then continue end

				local sts = active_quest.quest_blacklist[k]
				local paretnt = sts and b_list or q_list
				MSD.Button(paretnt, "static", nil, 1, 50, v.name, function()
					if sts then
						active_quest.quest_blacklist[k] = nil
					else
						active_quest.quest_blacklist[k] = true
					end
					update_bl(upd, q_list, b_list)
				end)
			end
		end

		update_cl = function(upd, q_list, b_list)
			q_list:Clear()
			b_list:Clear()

			if not upd then return end

			MSD.InfoHeader(q_list, Ln("quest_list"))
			MSD.InfoHeader(b_list, Ln("blacklist"))
			for k, v in pairs(MQS.Quests) do
				if active_quest.id == k then continue end

				local sts = active_quest.conflictlist[k]
				local paretnt = sts and b_list or q_list
				MSD.Button(paretnt, "static", nil, 1, 50, v.name, function()
					if sts then
						active_quest.conflictlist[k] = nil
					else
						active_quest.conflictlist[k] = true
					end
					update_cl(upd, q_list, b_list)
				end)
			end
		end
	end

	pages["edit_page2"] = function()
		local SwapEvents = false

		MSD.Header(panel.Canvas, Ln("q_editobj"), function()
			openPage("edit", true)
		end)

		if not active_quest.objects then active_quest.objects = {} end

		local ccl = MQS.Config.SmallObj
		local obj_panels = {}
		for t_id, object in pairs(active_quest.objects) do
			if not MSD.ObjeciveList[object.type] then
				MSD.BigButton(panel.Canvas, "static", nil, ccl and 6 or 4, ccl and 80 or 120, Ln("q_incvobj"), MSD.Icons48.alert, function()
					table.remove(active_quest.objects, t_id)
					openPage("edit_page2", true)
				end, MSD.Config.MainColor["r"])
				continue
			end

			obj_panels[t_id] = MSD.BigButton(panel.Canvas, "static", nil, ccl and 6 or 4, ccl and 80 or 120, object.type, MSD.ObjeciveList[object.type].icon, function()
				if SwapEvents then
					local new_object = table.Copy(active_quest.objects[SwapEvents])
					active_quest.objects[SwapEvents] = object
					active_quest.objects[t_id] = new_object
					openPage("edit_page2", true)
					return
				end

				if not MSD.ObjeciveList[object.type].builUI then return end

				panel.Canvas:Clear()

				openPage("edit_objective", true, t_id, object)

			end, nil, t_id, function(self)

				if SwapEvents then return end

				if (IsValid(self.Menu)) then
					self.Menu:Remove()
					self.Menu = nil
				end

				self.Menu = MSD.MenuOpen(false, self)

				if t_id > 1 then
					self.Menu:AddOption(Ln("moveup"), function()
						local new_object = table.Copy(active_quest.objects[t_id - 1])
						active_quest.objects[t_id - 1] = object
						active_quest.objects[t_id] = new_object
						openPage("edit_page2", true)
					end)
				end

				if t_id ~= #active_quest.objects then
					self.Menu:AddOption(Ln("movedown"), function()
						local new_object = table.Copy(active_quest.objects[t_id + 1])
						active_quest.objects[t_id + 1] = object
						active_quest.objects[t_id] = new_object
						openPage("edit_page2", true)
					end)
				end

				self.Menu:AddOption(Ln("swap"), function()
					local hd = MSD.BigButton(panel.Canvas, "static", nil, 1, 80, Ln("swapmod"), MSD.Icons48.swap, function()
						openPage("edit_page2", true)
					end)

					panel.Canvas:InsertAtTop(hd)
					SwapEvents = t_id
					self.disable = true
					self.color_idle = MSD.Config.MainColor["r"]
				end)

				self.Menu:AddOption(Ln("duplicate"), function()
					table.insert(active_quest.objects, table.Copy(object))
					openPage("edit_page2", true)
				end)

				self.Menu:AddOption(Ln("editmod"), function()
					openPage("edit_objmod", true)
				end)

				self.Menu:AddOption(Ln("remove"), function()
					table.remove(active_quest.objects, t_id)
					openPage("edit_page2", true)
				end)

				local x, y = self:LocalToScreen(0, self:GetTall())
				self.Menu:SetMinimumWidth(self:GetWide())
				self.Menu:Open(x, y, false, self)
			end, (object.desc ~= object.type and not ccl) and object.desc or "", function(s, wd, hd)
				if object.type == "Skip to" and s.hover and object.oid then
					if not IsValid(obj_panels[object.oid]) then return end
					obj_panels[object.oid].hl = true
					return
				end

				if s.hl then
					draw.RoundedBox(MSD.Config.Rounded, 0, 0, wd, hd, MSD.Text["a"])
					s.hl = nil
				end

				if object.type ~= "Randomize" or not s.hover or not object.objects then return end
				for k,v in pairs(object.objects) do
					if not IsValid(obj_panels[k]) then continue end
					obj_panels[k].hl = v
				end
			end)
		end

		MSD.BigButton(panel.Canvas, "static", nil, ccl and 6 or 4, ccl and 80 or 120, Ln("q_newobj"), MSD.Icons48.plus, function(self)
			if (IsValid(self.Menu)) then
				self.Menu:Remove()
				self.Menu = nil
			end

			self.Menu = MSD.MenuOpen(false, self)

			for k, v in pairs(MSD.ObjeciveList) do
				if v.check and not v.check() then continue end
				if k == "Collect quest ents" and active_quest.objects and active_quest.objects[#active_quest.objects] and active_quest.objects[#active_quest.objects].type == k then continue end

				self.Menu:AddOption(Ln(k), function()
					if not active_quest.objects then
						active_quest.objects = {}
					end

					local ix = table.insert(active_quest.objects, table.Copy(v.tbl))
					active_quest.objects[ix].desc = k
					active_quest.objects[ix].type = k

					if active_quest.objects[ix].point then
						active_quest.objects[ix].point = LocalPlayer():GetPos()
					end

					openPage("edit_page2", true)
				end, v.icon)
			end

			local x, y = self:LocalToScreen(0, self:GetTall())
			self.Menu:SetMinimumWidth(self:GetWide())
			self.Menu:Open(x, y, false, self)
		end)
	end

	pages["edit_objmod"] = function()

		MSD.Header(panel.Canvas, Ln("edit_objmod"), function()
			openPage("edit_page2", true)
		end)

		local ccl = MQS.Config.SmallObj
		local qstart = nil
		local qend = nil

		local function copy_obj()
			local count = (qend - qstart)
			for i = 0,count do
				table.insert(active_quest.objects, table.Copy(active_quest.objects[qstart + i]))
			end
			openPage("edit_objmod", false)
		end

		local function remove_obj()
			local count = (qend - qstart)
			for i = 0,count do
				table.remove(active_quest.objects, qstart)
			end
			openPage("edit_objmod", false)
		end

		local function move_obj_to(t_id)
			local count = (qend - qstart)
			local temp_t = {}
			for i = 0,count do
				table.insert(temp_t, table.Copy(active_quest.objects[qstart + i]))
			end
			for i = 0,count do
				table.remove(active_quest.objects, qstart)
			end
			local add = t_id > qend and count or 0
			for i = 0,count do
				table.insert(active_quest.objects, t_id + i - add, table.Copy(temp_t[1 + i]))
			end
			openPage("edit_objmod", false)
		end

		for t_id, object in pairs(active_quest.objects) do
			local valid = MSD.ObjeciveList[object.type]

			MSD.BigButton(panel.Canvas, "static", nil, ccl and 6 or 4, ccl and 80 or 120, object.type, valid and valid.icon or MSD.Icons48.alert, function()
				if not qstart or not qend then
					qstart = t_id
					qend = t_id
					return
				end

				if t_id > qend then
					qend = t_id
					return
				end

				if t_id < qstart then
					qstart = t_id
					return
				end

				qstart = nil
				qend = nil
			end, nil, t_id, function(self)
				if not qstart or not qend then return end
				if (IsValid(self.Menu)) then
					self.Menu:Remove()
					self.Menu = nil
				end

				self.Menu = MSD.MenuOpen(false, self)

				if t_id >= qstart and t_id <= qend then
					self.Menu:AddOption(Ln("duplicate"), function()
						copy_obj()
					end)
					self.Menu:AddOption(Ln("remove"), function()
						remove_obj()
					end)
				else
					self.Menu:AddOption(Ln("move"), function()
						move_obj_to(t_id)
					end)
				end

				local x, y = self:LocalToScreen(0, self:GetTall())
				self.Menu:SetMinimumWidth(self:GetWide())
				self.Menu:Open(x, y, false, self)
			end, (object.desc ~= object.type and not ccl) and object.desc or "", function(s, wd, hd)
				if qstart and qend and t_id >= qstart and t_id <= qend then
					draw.RoundedBox(MSD.Config.Rounded, 0, 0, wd, hd, MSD.Text["a"])
				end
			end)
		end
	end

	pages["edit_objective"] = function(t_id, object)

		if not object.events then object.events = {} end

		MSD.Header(panel.Canvas, Ln(object.type), function() openPage("edit_page2", true) end)

		local ops_panel = vgui.Create("DPanel")
		ops_panel:SetSize(panel.Canvas:GetWide(), panel.Canvas:GetTall() - 52)

		ops_panel.Paint = function(self, w, h)
			draw.RoundedBox(MSD.Config.Rounded, 0, 0, w / 2 - 2, h, MSD.Theme["l"])
			draw.RoundedBox(MSD.Config.Rounded, w / 2, 0, w / 2 - 2, h, MSD.Theme["l"])
			draw.DrawText(Ln("q_setobj"), "MSDFont.25", 12, 12, color_white, TEXT_ALIGN_LEFT)
			draw.DrawText(Ln("q_events"), "MSDFont.25", w / 2 + 12, 12, color_white, TEXT_ALIGN_LEFT)
		end

		local obj_sets = vgui.Create("MSDPanelList", ops_panel)
		obj_sets:SetSize(ops_panel:GetWide() / 2, ops_panel:GetTall() - 52)
		obj_sets:SetPos(0, 52)
		obj_sets:EnableVerticalScrollbar()
		obj_sets:EnableHorizontal(true)
		obj_sets:SetSpacing(2)
		obj_sets:SetPadding(0)
		obj_sets.IgnoreVbar = true

		local obj_events = vgui.Create("MSDPanelList", ops_panel)
		obj_events:SetSize(ops_panel:GetWide() / 2 - 2, ops_panel:GetTall() - 52)
		obj_events:SetPos(ops_panel:GetWide() / 2, 52)
		obj_events:EnableVerticalScrollbar()
		obj_events:EnableHorizontal(true)
		obj_events:SetSpacing(2)
		obj_events:SetPadding(0)
		obj_events.IgnoreVbar = true

		obj_sets.Populate = function()
			obj_sets:Clear()
			MSD.ObjeciveList[object.type].builUI(t_id, object, obj_sets, PopupMenu, active_quest, obj_events)
		end

		obj_events.Populate = function()
			obj_events:Clear()

			MSD.Button(obj_events, "static", nil, 1, 50, Ln("q_eventadd"), function(self)
				if (IsValid(self.Menu)) then
					self.Menu:Remove()
					self.Menu = nil
				end

				self.Menu = MSD.MenuOpen(false, self, false)

				for k, v in pairs(MSD.EventList) do
					if v.check and ((isstring(v.check) and v.check ~= object.type) or (isfunction(v.check) and v.check())) then continue end

					self.Menu:AddOption(Ln(k), function()

						local ix = table.insert(object.events, {k})

						object.events[ix][2] = istable(v.data) and table.Copy(v.data) or v.data
						obj_events.Populate()
					end, v.icon)
				end

				local x, y = self:LocalToScreen(0, self:GetTall())
				self.Menu:SetMinimumWidth(self:GetWide())
				self.Menu:Open(x, y, false, self)
			end)

			if not object.events then return end

			for eid, event in pairs(object.events) do

				MSD.ButtonIcon(obj_events, "static", nil, 1, 50, Ln(event[1]), MSD.EventList[event[1]].icon, function(self)
					if not MSD.EventList[event[1]].builUI then return end
					local sub_list = PopupMenu("\"" .. Ln(event[1]) .. "\" " .. Ln("q_eventedit"), 2, MSD.EventList[event[1]].ui_h or 1.2, 50)
					sub_list:Clear()
					MSD.EventList[event[1]].builUI(event, sub_list, t_id, object)
				end, function(self)
					if (IsValid(self.Menu)) then self.Menu:Remove() self.Menu = nil end

					self.Menu = MSD.MenuOpen(false, self)

					self.Menu:AddOption(Ln("duplicate"), function()
						table.insert(object.events, table.Copy(event))
						obj_events.Populate()
					end)

					self.Menu:AddOption(Ln("q_eventremove"), function()
						table.remove(object.events, eid)
						obj_events.Populate()
					end)

					local prev_ent = object.events[eid - 1]

					self.Menu:AddOption(Ln("moveup"), function()
						object.events[eid] = table.Copy(prev_ent)
						object.events[eid - 1] = table.Copy(event)
						obj_events.Populate()
					end, nil, function()
						return prev_ent
					end)


					local next_ent = object.events[eid + 1]

					self.Menu:AddOption(Ln("movedown"), function()
						object.events[eid] = table.Copy(next_ent)
						object.events[eid + 1] = table.Copy(event)
						obj_events.Populate()
					end, nil, function()
						return next_ent
					end)


					local x, y = self:LocalToScreen(0, self:GetTall())
					self.Menu:SetMinimumWidth(self:GetWide())
					self.Menu:Open(x, y, false, self)
				end)
			end
		end

		panel.Canvas:AddItem(ops_panel)
		obj_sets.Populate()
		obj_events.Populate()
	end

	pages["edit_page3"] = function()
		MSD.Header(panel.Canvas, Ln("q_rwdeditor"), function()
			openPage("edit", true)
		end)

		if not MQS.IsAdministrator(LocalPlayer()) then
			local pnl = vgui.Create("DPanel")
			pnl.StaticScale = {
				w = 1,
				h = 1.1,
				minw = 150,
				minh = 150
			}
			pnl.Paint = function(self, w, h)
				MSD.DrawTexturedRect(w / 2 - 24, h / 2 - 50, 48, 48, MSD.Icons48.cancel, MSD.Text["n"])
				draw.DrawText(MSD.GetPhrase("need_admin"), "MSDFont.25", w / 2, h / 2 + 10, MSD.Text["n"], TEXT_ALIGN_CENTER)
			end

			panel.Canvas:AddItem(pnl)
			return
		end

		local ops_panel = vgui.Create("DPanel")
		ops_panel:SetSize(panel.Canvas:GetWide(), panel.Canvas:GetTall() - 52)

		ops_panel.Paint = function(self, w, h)
			draw.RoundedBox(MSD.Config.Rounded, 0, 0, w / 2 - 2, h, MSD.Theme["l"])
			draw.RoundedBox(MSD.Config.Rounded, w / 2, 0, w / 2 - 2, h, MSD.Theme["l"])
			draw.DrawText(Ln("q_rwdlist"), "MSDFont.25", 12, 12, color_white, TEXT_ALIGN_LEFT)
			draw.DrawText(Ln("q_rwdsets"), "MSDFont.25", w / 2 + 12, 12, color_white, TEXT_ALIGN_LEFT)
		end

		local rwd_set, rwd_list
		rwd_list = vgui.Create("MSDPanelList", ops_panel)
		rwd_list:SetSize(ops_panel:GetWide() / 2, ops_panel:GetTall() - 52)
		rwd_list:SetPos(0, 52)
		rwd_list:EnableVerticalScrollbar()
		rwd_list:EnableHorizontal(true)
		rwd_list:SetSpacing(2)
		rwd_list:SetPadding(0)
		rwd_list.IgnoreVbar = true

		rwd_list.Populate = function()
			rwd_list:Clear()

			if not active_quest.reward then
				active_quest.reward = {}
			end

			for rw_name, rw_data in pairs(MQS.Rewards) do
				if not MQS.RewardsList[rw_name] then continue end
				if rw_data.check and rw_data.check() then continue end

				MSD.BoolSlider(rwd_list, "static", nil, 1, 50, Ln("enable") .. " '" .. Ln(rw_name) .. "'", active_quest.reward[rw_name] and true or false, function(self, var)
					if var then
						active_quest.reward[rw_name] = istable(MQS.RewardsList[rw_name].data) and table.Copy(MQS.RewardsList[rw_name].data) or MQS.RewardsList[rw_name].data
					else
						active_quest.reward[rw_name] = nil
					end

					rwd_set.Populate()
				end)
			end
		end

		rwd_set = vgui.Create("MSDPanelList", ops_panel)
		rwd_set:SetSize(ops_panel:GetWide() / 2 - 2, ops_panel:GetTall() - 52)
		rwd_set:SetPos(ops_panel:GetWide() / 2, 52)
		rwd_set:EnableVerticalScrollbar()
		rwd_set:EnableHorizontal(true)
		rwd_set:SetSpacing(2)
		rwd_set:SetPadding(0)
		rwd_set.IgnoreVbar = true

		rwd_set.Populate = function()
			rwd_set:Clear()
			if not active_quest.reward then return end

			for rid, rdata in pairs(active_quest.reward) do
				if MQS.Rewards[rid].check and MQS.Rewards[rid].check() then continue end
				MSD.InfoHeader(rwd_set, rid)
				MQS.RewardsList[rid].builUI(active_quest.reward[rid], rwd_set)
			end
		end

		panel.Canvas:AddItem(ops_panel)
		rwd_list.Populate()
		rwd_set.Populate()
	end

	pages["quests_copy"] = function()
		MSD.Header(panel.Canvas, Ln("copy_data"), function()
			openPage("edit", true)
		end)

		local ops_panel = vgui.Create("DPanel")
		ops_panel:SetSize(panel.Canvas:GetWide(), panel.Canvas:GetTall() - 52)

		ops_panel.Paint = function(self, w, h)
			draw.RoundedBox(MSD.Config.Rounded, 0, 0, w / 2 - 2, h, MSD.Theme["l"])
			draw.RoundedBox(MSD.Config.Rounded, w / 2, 0, w / 2 - 2, h, MSD.Theme["l"])
			draw.DrawText(Ln("quest_list"), "MSDFont.25", 12, 12, color_white, TEXT_ALIGN_LEFT)
			draw.DrawText(Ln("q_findmap"), "MSDFont.25", w / 2 + 12, 12, color_white, TEXT_ALIGN_LEFT)
		end

		local rwd_set, rwd_list
		rwd_list = vgui.Create("MSDPanelList", ops_panel)
		rwd_list:SetSize(ops_panel:GetWide() / 2, ops_panel:GetTall() - 52)
		rwd_list:SetPos(0, 52)
		rwd_list:EnableVerticalScrollbar()
		rwd_list:EnableHorizontal(true)
		rwd_list:SetSpacing(2)
		rwd_list:SetPadding(0)
		rwd_list.IgnoreVbar = true

		rwd_list.Populate = function()
			rwd_list:Clear()

			for k, v in pairs(MQS.Quests) do
				MSD.Button(rwd_list, "static", nil, 1, 50, "[" .. k .. "] " .. v.name, function()
					active_quest = table.Copy(v)
					active_quest.id = k .. "_copy"
					active_quest.name = v.name .. " Copy"
					active_quest.new = true
					openPage("edit", true)
				end, true)
			end
		end

		rwd_set = vgui.Create("MSDPanelList", ops_panel)
		rwd_set:SetSize(ops_panel:GetWide() / 2 - 2, ops_panel:GetTall() - 52)
		rwd_set:SetPos(ops_panel:GetWide() / 2, 52)
		rwd_set:EnableVerticalScrollbar()
		rwd_set:EnableHorizontal(true)
		rwd_set:SetSpacing(2)
		rwd_set:SetPadding(0)
		rwd_set.IgnoreVbar = true

		rwd_set.Populate = function()
			rwd_set:Clear()

			MSD.TextEntry(rwd_set, "static", nil, 1, 50, Ln("e_text"), Ln("map") .. ":", "", function(self, value)
				net.Start("MQS.GetOtherQuests")
				net.WriteString(value)
				net.SendToServer()
			end, false)

			if MQS.AltDate and MQS.AltDate.Quests then
				for k, v in pairs(MQS.AltDate.Quests) do
					MSD.Button(rwd_set, "static", nil, 1, 50, "[" .. k .. "] " .. v.name, function()
						active_quest = table.Copy(v)
						active_quest.id = k .. "_copy"
						active_quest.name = v.name .. " Copy"
						active_quest.new = true
						openPage("edit", true)
					end, true)
				end
			end
		end

		MQS.AltDateUpdate = function(arguments)
			if IsValid(rwd_set) then
				rwd_set.Populate()
			end
		end

		panel.Canvas:AddItem(ops_panel)
		rwd_list.Populate()
		rwd_set.Populate()
	end

	pages["npcs"] = function()
		if not MQS.Config.NPC.enable then
			local pnl = vgui.Create("DPanel")

			pnl.StaticScale = {
				w = 1,
				h = 1,
				minw = 150,
				minh = 150
			}

			pnl.Paint = function(self, w, h)
				MSD.DrawTexturedRect(w / 2 - 24, h / 2 - 50, 48, 48, MSD.Icons48.account, MSD.Text["n"])
				draw.DrawText(Ln("Quest NPCs are disabled"), "MSDFont.25", w / 2, h / 2 + 10, MSD.Text["n"], TEXT_ALIGN_CENTER)
				draw.DrawText(Ln("You can enable them in settings"), "MSDFont.25", w / 2, h / 2 + 35, MSD.Text["n"], TEXT_ALIGN_CENTER)
			end

			panel.Canvas:AddItem(pnl)

			return
		end

		local npctab = MSD.Header(panel.Canvas, Ln("npc_editor"))

		MQS.UpdateMenuElements = function()
			if IsValid(npctab) then
				openPage("npcs", true)
			end
		end

		local function EditNPC(id, npc)
			local rwd_list, child, pn = PopupMenu(Ln("npc_editor"), 1, 1.1, 50, 1.5)

			if not id then
				npc = table.Copy(blank_npc)
			end

			local map = string.lower(game.GetMap())

			if not npc.spawns[map] then
				npc.spawns[map] = {Vector(0, 0, 0), Angle(0, 0, 0),}
			end

			local pnw = child:GetWide()
			local mdlp = MSD.NPCModelFrame(child, pnw - pnw / 3, 50, pnw / 3 - 10, child:GetTall() - 100, npc.model, npc.sequence)
			MSD.Button(child, pnw - pnw / 3, child:GetTall() - 50, pnw / 3 - 10, 50, Ln("set_anim"), function()
				MQS.NPCAnimationMenu(pn, mdlp.Entity, function(v)
					mdlp.Entity:ResetSequence(v)
					mdlp.Entity:SetCycle(0)
					npc.sequence = string.lower(v)
				end)
			end)

			MSD.TextEntry(rwd_list, "static", nil, 1, 50, Ln("enter_name"), Ln("name") .. ":", npc.name, function(self, value)
				npc.name = value
			end, true)

			local mdl = MSD.TextEntry(rwd_list, "static", nil, 1.5, 50, Ln("e_model"), Ln("model") .. ":", npc.model, function(self, value)
				npc.model = value
				mdlp:UpdateModelValue(value)
			end, true)

			MSD.Button(rwd_list, "static", nil, 3, 50, Ln("copy_from_ent"), function()
				local md = LocalPlayer():GetEyeTrace().Entity
				if not md then return end
				md = md:GetModel()
				mdl:SetText(md)
				npc.model = md
			end)

			MSD.TextEntry(rwd_list, "static", nil, 1, 150, Ln("npc_e_speech"), "", npc.text, function(self, value)
				npc.text = value
			end, true, nil, true)

			MSD.TextEntry(rwd_list, "static", nil, 1, 50, Ln("e_text"), Ln("q_npc_answer_ok") .. ":", npc.answer_yes, function(self, value)
				npc.answer_yes = value
			end, true)

			MSD.TextEntry(rwd_list, "static", nil, 1, 50, Ln("e_text"), Ln("q_npc_answer_no") .. ":", npc.answer_no, function(self, value)
				npc.answer_no = value
			end, true)

			MSD.TextEntry(rwd_list, "static", nil, 1, 50, Ln("e_text"), Ln("q_npc_quest_no") .. ":", npc.text_notask, function(self, value)
				npc.text_notask = value
			end, true)

			MSD.TextEntry(rwd_list, "static", nil, 1, 50, Ln("e_text"), Ln("q_npc_answer_noq") .. ":", npc.answer_notask, function(self, value)
				npc.answer_notask = value
			end, true)

			local vecd = MSD.VectorDisplay(rwd_list, "static", nil, 1, 50, Ln("spawn_point"), npc.spawns[map][1], function() end)
			local amgl = MSD.AngleDisplay(rwd_list, "static", nil, 1, 50, Ln("spawn_ang"), npc.spawns[map][2], function() end)

			MSD.Button(rwd_list, "static", nil, 3, 50, Ln("set_pos_self"), function()
				local vec = LocalPlayer():GetPos()
				vecd.vector = vec
				npc.spawns[map][1] = vec
				local ang = Angle(0, LocalPlayer():GetAngles().y, 0)
				amgl.angle = ang
				npc.spawns[map][2] = ang
			end)

			MSD.Button(rwd_list, "static", nil, 3, 50, Ln("set_pos_aim"), function()
				local vec = LocalPlayer():GetEyeTrace().HitPos
				if not vec then return end
				vecd.vector = vec
				npc.spawns[map][1] = vec
				local ang = Angle(0, LocalPlayer():GetAngles().y, 0)
				amgl.angle = ang
				npc.spawns[map][2] = ang
			end)

			MSD.Button(rwd_list, "static", nil, 3, 50, Ln("copy_from_ent"), function()
				local vec = LocalPlayer():GetEyeTrace().Entity
				if not vec then return end
				local ang = vec:GetAngles()
				amgl.angle = ang
				npc.spawns[map][2] = ang
				vec = vec:GetPos()
				vecd.vector = vec
				npc.spawns[map][1] = vec
			end)

			if not id then
				MSD.BigButton(rwd_list, "static", nil, 1, 80, Ln("npc_submit"), MSD.Icons48.submit, function()
					MQS.CreateNPC(npc)
					pn.Close()
				end)
			else
				MSD.BigButton(rwd_list, "static", nil, 2, 80, Ln("npc_update"), MSD.Icons48.save, function()
					openPage("npcs", true)
					MQS.UpdateNPC(id, npc)
					pn.Close()
				end)

				MSD.BigButton(rwd_list, "static", nil, 2, 80, Ln("npc_remove"), MSD.Icons48.layers_remove, function()
					openPage("npcs", true)
					MQS.UpdateNPC(id, npc, true)
					pn.Close()
				end)
			end
		end

		MSD.BigButton(panel.Canvas, "static", nil, 4, 120, Ln("npc_new"), MSD.Icons48.account_edit, function()
			EditNPC()
		end)

		for k, v in pairs(MQS.Config.NPC.list) do
			MSD.BigButton(panel.Canvas, "static", nil, 4, 120, v.name, MSD.Icons48.account, function()
				EditNPC(k, v)
			end, nil, nil, function(self)
				if (IsValid(self.Menu)) then
					self.Menu:Remove()
					self.Menu = nil
				end

				self.Menu = MSD.MenuOpen(false, self)

				self.Menu:AddOption(Ln("remove"), function()
					MQS.UpdateNPC(k, v, true)
					openPage("npcs", true)
				end)

				local x, y = self:LocalToScreen(0, self:GetTall())
				self.Menu:SetMinimumWidth(self:GetWide())
				self.Menu:Open(x, y, false, self)
			end)
		end
	end

	pages["settings"] = function()
		local oldcfg = table.Copy(MQS.Config)
		MSD.Header(panel.Canvas, Ln("settings"))
		local ops_panel = vgui.Create("DPanel")
		ops_panel:SetSize(panel.Canvas:GetWide(), panel.Canvas:GetTall() - 135)

		ops_panel.Paint = function(self, w, h)
			draw.RoundedBox(MSD.Config.Rounded, 0, 0, w / 2 - 2, h, MSD.Theme["l"])
			draw.RoundedBox(MSD.Config.Rounded, w / 2, 0, w / 2 - 2, h, MSD.Theme["l"])
		end

		local rwd_set, rwd_list
		rwd_list = vgui.Create("MSDPanelList", ops_panel)
		rwd_list:SetSize(ops_panel:GetWide() / 2, ops_panel:GetTall() - 2)
		rwd_list:SetPos(0, 0)
		rwd_list:EnableVerticalScrollbar()
		rwd_list:EnableHorizontal(true)
		rwd_list:SetSpacing(2)
		rwd_list:SetPadding(0)
		rwd_list.IgnoreVbar = true

		rwd_list.Populate = function()
			rwd_list:Clear()

			MSD.Button(rwd_list, "static", nil, 1, 50, Ln("set_hud"), function()
				rwd_set.Populate("hud")
			end)

			MSD.Button(rwd_list, "static", nil, 1, 50, Ln("set_server"), function()
				rwd_set.Populate("server")
			end)

			MSD.Button(rwd_list, "static", nil, 1, 50, Ln("access_editors"), function()
				rwd_set.Populate("access_editors")
			end)

			MSD.Button(rwd_list, "static", nil, 1, 50, Ln("access_admins"), function()
				rwd_set.Populate("access_admins")
			end)

			MSD.Button(rwd_list, "static", nil, 1, 50, Ln("user_data"), function()
				rwd_set.Populate("user_data")
			end)

			MSD.Button(rwd_list, "static", nil, 1, 50, Ln("Export") .. "/" .. Ln("Import"), function()
				rwd_set.Populate("export")
			end)
		end

		rwd_set = vgui.Create("MSDPanelList", ops_panel)
		rwd_set:SetSize(ops_panel:GetWide() / 2 - 2, ops_panel:GetTall() - 2)
		rwd_set:SetPos(ops_panel:GetWide() / 2, 0)
		rwd_set:EnableVerticalScrollbar()
		rwd_set:EnableHorizontal(true)
		rwd_set:SetSpacing(2)
		rwd_set:SetPadding(0)
		rwd_set.IgnoreVbar = true
		rwd_set.SetingList = {}

		rwd_set.Populate = function(seting)
			if not rwd_set.SetingList[seting] then return end
			MQS.PlayerDataPanel = nil
			rwd_set:Clear()
			rwd_set.SetingList[seting]()
			last_sm = seting
		end

		rwd_set.SetingList["hud"] = function()
			MSD.Header(rwd_set, Ln("set_hud_pos"))

			MSD.DTextSlider(rwd_set, "static", nil, 1, 50, Ln("set_ui_align_right"), Ln("set_ui_align_left"), MQS.Config.UI.HudAlignX, function(self, value)
				MQS.Config.UI.HudAlignX = value
			end)

			MSD.DTextSlider(rwd_set, "static", nil, 1, 50, Ln("set_ui_align_top"), Ln("set_ui_align_bottom"), MQS.Config.UI.HudAlignY, function(self, value)
				MQS.Config.UI.HudAlignY = value
			end)

			MSD.VolumeSlider(rwd_set, "static", nil, 1, 50, Ln("set_ui_offset_h"), MQS.Config.UI.HudOffsetX, function(self, var)
				MQS.Config.UI.HudOffsetX = math.Round(var, 3)
			end)

			MSD.VolumeSlider(rwd_set, "static", nil, 1, 50, Ln("set_ui_offset_v"), MQS.Config.UI.HudOffsetY, function(self, var)
				MQS.Config.UI.HudOffsetY = math.Round(var, 3)
			end)

			MSD.Header(rwd_set, Ln("set_hud_themes"))
			local tm1, tm2, tm3

			tm1 = MSD.Button(rwd_set, "static", nil, 3, 50, Ln("theme") .. " 1", function()
				MQS.Config.UI.HUDBG = 0
				tm1.hovered = true
				tm2.hovered = false
				tm3.hovered = false
			end)

			tm2 = MSD.Button(rwd_set, "static", nil, 3, 50, Ln("theme") .. " 2", function()
				MQS.Config.UI.HUDBG = 1
				tm1.hovered = false
				tm2.hovered = true
				tm3.hovered = false
			end)

			tm3 = MSD.Button(rwd_set, "static", nil, 3, 50, Ln("theme") .. " 3", function()
				MQS.Config.UI.HUDBG = 2
				tm1.hovered = false
				tm2.hovered = false
				tm3.hovered = true
			end)

			if MQS.Config.UI.HUDBG == 0 then
				tm1.hovered = true
			elseif MQS.Config.UI.HUDBG == 1 then
				tm2.hovered = true
			else
				tm3.hovered = true
			end
		end

		rwd_set.SetingList["server"] = function()
			MSD.Header(rwd_set, Ln("set_server"))

			MSD.TextEntry(rwd_set, "static", nil, 1, 50, Ln("e_number"), Ln("q_ent_draw"), MQS.Config.QuestEntDrawDist, function(self, value)
				MQS.Config.QuestEntDrawDist = tonumber(value) or 500
			end, true, nil, nil, true)

			MSD.Binder(rwd_set, "static", nil, 1, 50, Ln("q_loop_stop_key"), MQS.Config.StopKey, function(num)
				MQS.Config.StopKey = num
			end)

			MSD.BoolSlider(rwd_set, "static", nil, 1, 50, Ln("npc_q_enable"), MQS.Config.NPC.enable, function(self, value)
				MQS.Config.NPC.enable = value
			end)

			MSD.BoolSlider(rwd_set, "static", nil, 1, 50, Ln("sortquests_cat"), MQS.Config.Sort, function(self, value)
				MQS.Config.Sort = value
			end)

			MSD.BoolSlider(rwd_set, "static", nil, 1, 50, Ln("compact_obj"), MQS.Config.SmallObj, function(self, value)
				MQS.Config.SmallObj = value
			end)

			MSD.BoolSlider(rwd_set, "static", nil, 1, 50, Ln("mqs_fix_cam"), MQS.Config.CamFix, function(self, value)
				MQS.Config.CamFix = value
			end)

			local combo = MSD.ComboBox(rwd_set, "static", nil, 1, 50, Ln("into_quest") .. ":", Ln("none"))
			combo:AddChoice(Ln("none"), "")

			combo.OnSelect = function(self, index, text, data)
				MQS.Config.IntoQuest = data
			end

			for k, v in pairs(MQS.Quests) do
				if v.quest_needed or v.looped then continue end

				if MQS.Config.IntoQuest == k then
					combo:SetValue(v.name)
				end

				combo:AddChoice(v.name, k)
			end

			MSD.BoolSlider(rwd_set, "static", nil, 1, 50, Ln("into_quest_auto"), MQS.Config.IntoQuestAutogive, function(self, value)
				MQS.Config.IntoQuestAutogive = value
			end)

		end

		rwd_set.SetingList["access_admins"] = function()
			MSD.Header(rwd_set, Ln("access_admins"))

			local entr = MSD.TextEntry(rwd_set, "static", nil, 1.5, 50, Ln("e_usergroup"), Ln("add_usergroup"), "", function(self, value)
				MQS.Config.Administrators[value] = true
				if MQS.Config.Editors[value] then MQS.Config.Editors[value] = nil end
				rwd_set.Populate("access_admins")
			end)

			MSD.Button(rwd_set, "static", nil, 3, 50, Ln("add_usergroup"), function()
				entr:OnEnter(entr:GetValue())
			end)

			for ugr, stat in pairs(MQS.Config.Administrators) do
				MSD.Header(rwd_set, ugr, function()
					MQS.Config.Administrators[ugr] = nil
					rwd_set.Populate("access_admins")
				end, MSD.Icons48.cancel, true)
			end
		end

		rwd_set.SetingList["access_editors"] = function()
			MSD.Header(rwd_set, Ln("access_editors"))

			local entr = MSD.TextEntry(rwd_set, "static", nil, 1.5, 50, Ln("e_usergroup"), Ln("add_usergroup"), "", function(self, value)
				if MQS.Config.Administrators[value] then
					self.error = Ln("ug_isanadmin")
					return
				end
				MQS.Config.Editors[value] = true
				rwd_set.Populate("access_editors")
				self.error = nil
			end)

			MSD.Button(rwd_set, "static", nil, 3, 50, Ln("add_usergroup"), function()
				entr:OnEnter(entr:GetValue())
			end)

			for ugr, stat in pairs(MQS.Config.Editors) do
				MSD.Header(rwd_set, ugr, function()
					MQS.Config.Editors[ugr] = nil
					rwd_set.Populate("access_editors")
				end, MSD.Icons48.cancel, true)
			end
		end

		rwd_set.SetingList["user_data"] = function()
			MQS.PlayerDataPanel = rwd_set

			MQS.PlayerDataPanel.Update = function(data, sid)
				rwd_set:Clear()
				MSD.Header(rwd_set, Ln("user_data"))

				MSD.TextEntry(rwd_set, "static", nil, 1, 50, "STEAM_0:0:0000", Ln("find_player_id32"), sid or "", function(self, value)
					net.Start("MQS.GetPlayersQuests")
						net.WriteString(value)
					net.SendToServer()
				end)

				if not data or not data.QuestList then return end
				MSD.InfoHeader(rwd_set, "Quest ID", 2)
				MSD.InfoHeader(rwd_set, "Data", 2)
				for k, v in pairs(data.QuestList) do
					MSD.InfoHeader(rwd_set, k, 2)
					MSD.TextEntry(rwd_set, "static", nil, 2, 25, "", "", v, function(self, value)
						data.QuestList[k] = value
					end, true, nil, nil, true)
				end

				MSD.BigButton(rwd_set, "static", nil, 1, 75, Ln("save_chng"), MSD.Icons48.save, function()
					local cd, bn = MQS.TableCompress(data.QuestList)

					net.Start("MQS.SavePlayerQuestList")
					net.WriteString(sid)
						net.WriteInt(bn, 32)
						net.WriteData(cd, bn)
					net.SendToServer()
					MQS.PlayerDataPanel.Update()
				end)
			end

			MQS.PlayerDataPanel.Update()
		end

		rwd_set.SetingList["export"] = function()
			MSD.Header(rwd_set, Ln("Export") .. "/" .. Ln("Import"))
			MSD.InfoHeader(rwd_set, "Data saves to garrysmod/data/mqs/")

			local export_quest, import_quest
			local combo = MSD.ComboBox(rwd_set, "static", nil, 1, 50, Ln("quest_list") .. ":", Ln("none"))
			combo.OnSelect = function(self, index, text, data)
				export_quest = data
			end
			for k, v in pairs(MQS.Quests) do
				combo:AddChoice(v.name, k)
			end

			MSD.Button(rwd_set, "static", nil, 1, 50, Ln("Export"), function()
				if not export_quest then return end
				if not MQS.Quests[export_quest] then return end

				if file.Exists("mqs/" .. export_quest .. ".txt", "DATA") then
					local pl, _, plm = PopupMenu(Ln("file_exist"), 3, 4, 55)

					MSD.Button(pl, "static", nil, 1, 50, Ln("Replace"), function()
						file.Write("mqs/" .. export_quest .. ".txt", util.TableToJSON(MQS.Quests[export_quest]))
						surface.PlaySound("garrysmod/save_load2.wav")
						plm.Close()
					end)

					MSD.Button(pl, "static", nil, 1, 50, Ln("Save as") .. " " .. export_quest .. os.time(), function()
						file.Write("mqs/" .. export_quest .. os.time() .. ".txt", util.TableToJSON(MQS.Quests[export_quest]))
						surface.PlaySound("garrysmod/save_load1.wav")
						plm.Close()
					end)

					MSD.Button(pl, "static", nil, 1, 50, Ln("cancel"), function()
						plm.Close()
					end)

					return
				end

				file.Write("mqs/" .. export_quest .. ".txt", util.TableToJSON(MQS.Quests[export_quest]))
				surface.PlaySound("garrysmod/save_load1.wav")
			end)

			local import = MSD.ComboBox(rwd_set, "static", nil, 1, 50, Ln("file_list") .. ":", Ln("none"))
			import.OnSelect = function(self, index, text, data)
				import_quest = data
			end
			local files = file.Find( "mqs/*.txt", "DATA" )
			if files then
				for k, v in pairs(files) do
					import:AddChoice(v, v)
				end
			else
				import:AddChoice(Ln("none"), false)
			end

			MSD.Button(rwd_set, "static", nil, 1, 50, Ln("Import"), function()
				if not import_quest then return end
				if not file.Exists("mqs/" .. import_quest, "DATA" ) then return end
				local filename = string.Explode(".", import_quest)
				local quest_id = filename[1]
				local imported_quest = util.JSONToTable(file.Read("mqs/" .. import_quest, "DATA"))
				imported_quest.id = MQS.Quests[quest_id] and quest_id .. os.time() or quest_id
				MQS.QuestSubmit(imported_quest)
				surface.PlaySound("garrysmod/content_downloaded.wav")
			end)
		end

		panel.Canvas:AddItem(ops_panel)
		rwd_list.Populate()
		rwd_set.Populate(last_sm)

		if MQS.IsAdministrator(LocalPlayer()) then
			MSD.BigButton(panel.Canvas, "static", nil, 2, 80, Ln("upl_changes"), MSD.Icons48.save, function()
				MQS.SaveConfig()
				openPage("settings", true)
			end)

			MSD.BigButton(panel.Canvas, "static", nil, 2, 80, Ln("res_changes"), MSD.Icons48.cross, function()
				MQS.Config = oldcfg
				openPage("settings", true)
			end)
		end
	end

	for k, v in pairs(buttons) do
		local button = MSD.MenuButton(panel.Menu, v[2], nil, nil, 250, 50, v[1], function(self)
			panel.Menu.Deselect(not v[5] and self or false)
			v[3]()
		end)

		if v[4] then
			panel.Menu.Deselect(button)
			v[3]()
		end
	end
end

mouleid = MSD.AddModule("MQS", MQS.OpenAdminMenu, Material("mqs/logo_msd.png", "smooth"))