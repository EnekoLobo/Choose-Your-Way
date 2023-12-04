-- ╔═╗╔═╦═══╦═══╗───────────────────────
-- ║║╚╝║║╔═╗║╔═╗║───────────────────────
-- ║╔╗╔╗║║─║║╚══╗───────────────────────
-- ║║║║║║║─║╠══╗║──By MacTavish <3──────
-- ║║║║║║╚═╝║╚═╝║───────────────────────
-- ╚╝╚╝╚╩══╗╠═══╝───────────────────────
-- ────────╚╝───────────────────────────

function MQS.PreCheckQuest(quest, PopupMenu)
	local errorlist
	local alertlist
	MsgC(Color(0, 0, 255), "Quest check start\n")

	local function AddError(error)
		if not errorlist then
			errorlist = {}
		end

		table.insert(errorlist, error)
	end

	local function AddAllert(alert)
		if not alertlist then
			alertlist = {}
		end

		table.insert(alertlist, alert)
	end

	if quest.desc == "" or quest.desc == " " then
		AddAllert("You miss quest description")
	end

	if quest.success == "" or quest.success == " " then
		AddAllert("You miss quest complete message")
	end

	if #quest.objects < 2 then
		AddAllert("Ain't it too short of a quest?")
	end

	-- Check for valid objectives order
	local pre_object
	local car_valid = false

	for id, object in pairs(quest.objects) do
		if object.events then
			for id_e, event in pairs(object.events) do
				if event[1] == "Spawn vehicle" then
					car_valid = true
				end
			end
		end

		if object.events then
			for id_e, event in pairs(object.events) do
				if event[1] == "Remove vehicle" then
					if not car_valid then
						AddError("There is no vehicle to remove by 'Remove vehicle' event. Objective id: " .. id)
						continue
					end

					car_valid = false
				end
			end
		end

		if object.type == "Collect quest ents" then
			if pre_object and pre_object == object.type then
				AddError("You have 'Collect quest ents' objectives starting one after another, this may break your quest. Objective id: " .. id)
			end

			local found = false

			if object.events then
				for id_e, event in pairs(object.events) do
					if event[1] == "Spawn quest entity" then
						found = true
						break
					end
				end
			end

			if not found then
				AddError("'Collect quest ents' objectives has no 'Spawn quest entity' event, this will break your quest. Objective id: " .. id)
			end
		end

		if object.type == "Kill NPC" then
			local found = false

			if object.events then
				for id_e, event in pairs(object.events) do
					if event[1] == "Spawn npc" and event[2][4] then
						found = true
						break
					end
				end
			end

			if not found then
				AddError("'Kill NPC' has no target NPC. You need to create a target NPC. Objective id: " .. id)
			end
		end

		pre_object = object.type
	end

	if errorlist then
		MsgC(Color(255, 0, 0), "Errors:\n")
		PrintTable(errorlist)
	end

	if alertlist then
		MsgC(Color(255, 187, 0), "Alerts:\n")
		PrintTable(alertlist)
	end

	if not errorlist and not alertlist then
		MsgC(Color(0, 255, 0), "No error found!\n")
	end

	if PopupMenu then
		local sub_list = PopupMenu("Quest troubleshoot", 1.2, 1.5, 50)

		if errorlist then
			for k, v in ipairs(errorlist) do
				MSD.ButtonIcon(sub_list, "static", nil, 1, 50, v, MSD.Icons48.alert, nil, nil, Color(255, 0, 0))
			end
		end

		if alertlist then
			for k, v in ipairs(alertlist) do
				MSD.ButtonIcon(sub_list, "static", nil, 1, 50, v, MSD.Icons48.alert, nil, nil, Color(255, 187, 0))
			end
		end

		if not errorlist and not alertlist then
			MSD.ButtonIcon(sub_list, "static", nil, 1, 50, "No error found!", MSD.Icons48.submit, nil, nil, Color(0, 255, 0))
		end
	end
end

function MQS.QuestSubmit(quest)
	local cd, bn = MQS.TableCompress(quest)

	net.Start("MQS.QuestSubmit")
		net.WriteInt(bn, 32)
		net.WriteData(cd, bn)
	net.SendToServer()
end