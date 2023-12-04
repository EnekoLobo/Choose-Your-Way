-- ╔═╗╔═╦═══╦═══╗───────────────────────
-- ║║╚╝║║╔═╗║╔═╗║───────────────────────
-- ║╔╗╔╗║║─║║╚══╗───────────────────────
-- ║║║║║║║─║╠══╗║──By MacTavish <3──────
-- ║║║║║║╚═╝║╚═╝║───────────────────────
-- ╚╝╚╝╚╩══╗╠═══╝───────────────────────
-- ────────╚╝───────────────────────────

local Ln = MSD.GetPhrase

MSD.ObjeciveList = {}

MSD.ObjeciveList["Move to point"] = {
	icon = Material("mqs/map_markers/m10.png", "smooth"),
	tbl = {
		point = Vector(0, 0, 0),
		marker = 0,
	},
	builUI = function(id, object, panel, popupm)
		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("enter_description"), Ln("q_obj_des") .. ":", object.desc, function(self, value)
			object.desc = value
		end, true)

		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("def_units", "350"), Ln("q_dist_point"), object.dist, function(self, value)
			object.dist = tonumber(value) or nil
		end, true, nil, nil, true)

		MSD.VectorSelectorList(panel, Ln("movepoint"), object.point, nil, nil, nil, true, function(vec)
			object.point = vec
		end)

		MSD.Button(panel, "static", nil, 1, 50, Ln("map_marker"), function()
			local sub_list, _, plm = popupm(Ln("map_marker"), 2, 2.5, 50)

			if not object.marker then
				object.marker = 0
			end

			for ic_id, ic in pairs(MSD.PinPoints) do
				MSD.IconButton(sub_list, ic, "static", nil, 48, object.marker == ic_id and MSD.Config.MainColor.p or nil, nil, function()
					object.marker = ic_id
					plm.Close()
				end)
			end
		end)

		MSD.BoolSlider(panel, "static", nil, 1, 50, Ln("q_ignore_veh"), object.ignore_veh or false, function(self, value)
			object.ignore_veh = value
		end)

		MSD.BoolSlider(panel, "static", nil, 1, 50, Ln("mark_area"), object.mark_area or false, function(self, value)
			object.mark_area = value
		end)

		-- TO DO Add to lan. file
		MSD.BoolSlider(panel, "static", nil, 1, 50, "Vehicle must fully stop at the point", object.vehicle_stop or false, function(self, value)
			object.vehicle_stop = value
		end)
	end
}

MSD.ObjeciveList["Leave area"] = {
	icon = Material("mqs/map_markers/m14.png", "smooth"),
	tbl = {
		point = Vector(0, 0, 0),
		dist = 1000,
	},
	builUI = function(id, object, panel)
		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("enter_description"), Ln("q_obj_des") .. ":", object.desc, function(self, value)
			object.desc = value
		end, true)

		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("def_units", "1000"), Ln("q_dist_from_point") .. ":", object.dist, function(self, value)
			object.dist = tonumber(value) or nil
		end, true, nil, nil, true)

		MSD.VectorSelectorList(panel, Ln("leave_pnt"), object.point, nil, nil, nil, true, function(vec)
			object.point = vec
		end)

		MSD.BoolSlider(panel, "static", nil, 1, 50, Ln("q_ignore_veh"), object.ignore_veh or false, function(self, value)
			object.ignore_veh = value
		end)

		MSD.BoolSlider(panel, "static", nil, 1, 50, Ln("mark_area"), object.mark_area or false, function(self, value)
			object.mark_area = value
		end)
	end
}

MSD.ObjeciveList["Kill NPC"] = {
	icon = Material("mqs/map_markers/c2.png", "smooth"),
	tbl = {
		open_target = false,
		show_ents = false,
		marker = 0,
		dist = 300,
	},
	builUI = function(id, object, panel, popupm)
		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("enter_description"), Ln("q_obj_des") .. ":", object.desc, function(self, value)
			object.desc = value
		end, true)
		MSD.BoolSlider(panel, "static", nil, 1, 50, Ln("q_open_target"), object.open_target or false, function(self, value)
			object.open_target = value
		end)
		MSD.BoolSlider(panel, "static", nil, 1, 50, Ln("q_ent_pos_show"), object.show_ents or false, function(self, value)
			object.show_ents = value
		end)
		MSD.TextEntry(panel, "static", nil, 2, 50, Ln("def_units", "300"), Ln("q_npc_mind") .. ":", object.dist, function(self, value)
			object.dist = tonumber(value) or nil
		end, true, nil, nil, true)
		MSD.Button(panel, "static", nil, 2, 50, Ln("map_marker"), function()
			local sub_list, _, plm = popupm(Ln("map_marker"), 2, 2.5, 50)

			if not object.marker then
				object.marker = 0
			end

			for ic_id, ic in pairs(MSD.PinPoints) do
				MSD.IconButton(sub_list, ic, "static", nil, 48, object.marker == ic_id and MSD.Config.MainColor.p or nil, nil, function()
					object.marker = ic_id
					plm.Close()
				end)
			end
		end)
	end
}

MSD.ObjeciveList["Kill random target"] = {
	icon = Material("mqs/map_markers/c3.png", "smooth"),
	tbl = {
		target_type = 1,
		target_class = "npc_zombie",
		target_count = 1,
	},
	builUI = function(id, object, panel, popupm)
		local update
		function update()
			panel:Clear()

			MSD.TextEntry(panel, "static", nil, 1, 50, Ln("enter_description"), Ln("q_obj_des") .. ":", object.desc, function(self, value)
				object.desc = value
			end, true)

			MSD.Button(panel, "static", nil, 1, 50, Ln("target") .. ": " .. (object.target_type == 1 and Ln("Kill NPC") or Ln("kill_player")), function(self)
				if (IsValid(self.Menu)) then
					self.Menu:Remove()
					self.Menu = nil
				end
				self.Menu = MSD.MenuOpen(false, self)
				self.Menu:AddOption(Ln("Kill NPC"), function()
					self:SetText(Ln("target") .. ": " .. Ln("Kill NPC"))
					object.target_type = 1
					object.target_class = "npc_zombie"
					update()
				end)
				self.Menu:AddOption(Ln("kill_player"), function()
					self:SetText(Ln("target") .. ": " .. Ln("kill_player"))
					object.target_type = 2
					object.target_class = nil
					update()
				end)
				local x, y = self:LocalToScreen(0, self:GetTall())
				self.Menu:SetMinimumWidth(self:GetWide())
				self.Menu:Open(x, y, false, self)
			end)

			if object.target_type == 1 then
				MSD.TextEntry(panel, "static", nil, 1, 50, Ln("e_class"), Ln("e_npc_class") .. ":", object.target_class, function(self, value)
					object.target_class = value
				end, true)
			else
				local ecls = MSD.TextEntry(panel, "static", nil, 1.5, 50, Ln("e_blank_dis"), Ln("s_team_whitelist") .. ":", object.target_class, function(self, value)
					object.target_class = value
				end, true)

				MSD.Button(panel, "static", nil, 3, 50, Ln("search"), function(self)
					if (IsValid(self.Menu)) then
						self.Menu:Remove()
						self.Menu = nil
					end
					self.Menu = MSD.MenuOpen(false, self)
					self.Menu:AddOption(Ln("none"), function()
						object.target_class = nil
						ecls:SetText("")
					end)

					for tid, tm in SortedPairsByMemberValue(team.GetAllTeams(), "Name", true) do
						if not tm.Joinable then continue end
						self.Menu:AddOption(tm.Name, function()
							object.target_class = tm.Name
							ecls:SetText(tm.Name)
						end)
					end
					local x, y = self:LocalToScreen(0, self:GetTall())
					self.Menu:SetMinimumWidth(self:GetWide())
					self.Menu:Open(x, y, false, self)
				end)
			end

			MSD.TextEntry(panel, "static", nil, 1, 50, Ln("e_number"), Ln("kill_amount") .. ":", object.target_count, function(self, value)
				object.target_count = tonumber(value) or 1

				if object.target_count < 1 then
					object.target_count = 1
				end
			end, true, nil, nil, true)
		end
		update()
	end
}

MSD.ObjeciveList["Collect quest ents"] = {
	icon = Material("mqs/map_markers/c4.png", "smooth"),
	tbl = {
		show_ents = true,
		point = Vector(0, 0, 0),
		dist = 500,
		marker = 0,
	},
	builUI = function(id, object, panel, popupm)
		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("enter_description"), Ln("q_obj_des") .. ":", object.desc, function(self, value)
			object.desc = value
		end, true)

		MSD.BoolSlider(panel, "static", nil, 1, 50, Ln("q_ent_pos_show"), object.show_ents, function(self, value)
			object.show_ents = value
		end)

		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("def_units", "500"), Ln("q_s_area_size") .. ":", object.dist, function(self, value)
			object.dist = tonumber(value) or nil
		end, true, nil, nil, true)

		MSD.VectorSelectorList(panel, Ln("q_s_area_pos"), object.point, nil, nil, nil, true, function(vec)
			object.point = vec
		end)

		MSD.Button(panel, "static", nil, 1, 50, Ln("map_marker"), function()
			local sub_list, _, plm = popupm(Ln("map_marker"), 2, 2.5, 50)

			if not object.marker then
				object.marker = 0
			end

			for ic_id, ic in pairs(MSD.PinPoints) do
				MSD.IconButton(sub_list, ic, "static", nil, 48, object.marker == ic_id and MSD.Config.MainColor.p or nil, nil, function()
					object.marker = ic_id
					plm.Close()
				end)
			end
		end)

		MSD.BoolSlider(panel, "static", nil, 1, 50, Ln("mark_area"), object.mark_area or false, function(self, value)
			object.mark_area = value
		end)

		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("e_number"), Ln("collect_only") .. ":", object.target_limit, function(self, value)
			object.target_limit = tonumber(value) or 0

			if object.target_limit < 1 then
				object.target_limit = nil
			end
		end, true, nil, nil, true)
	end
}

MSD.ObjeciveList["Wait time"] = {
	icon = Material("mqs/map_markers/c5.png", "smooth"),
	tbl = {
		time = 10,
		show_timer = true,
		stay_inarea = false,
		point = Vector(0, 0, 0),
	},
	builUI = function(id, object, panel)
		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("enter_description"), Ln("q_obj_des") .. ":", object.desc, function(self, value)
			object.desc = value
		end, true)

		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("def_seconds", "10"), Ln("time_wait") .. ":", object.time, function(self, value)
			object.time = tonumber(value) or nil
		end, true, nil, nil, true)

		MSD.BoolSlider(panel, "static", nil, 1, 50, Ln("q_timer_show"), object.show_timer, function(self, var)
			object.show_timer = var
		end)

		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("e_blank_dis"), Ln("q_area_stay"), object.stay_inarea, function(self, value)
			object.stay_inarea = tonumber(value) or nil
		end, true, nil, nil, true)

		MSD.VectorSelectorList(panel, Ln("q_area_pos"), object.point, nil, nil, nil, true, function(vec)
			object.point = vec
		end)

		MSD.BoolSlider(panel, "static", nil, 1, 50, Ln("q_ignore_veh"), object.ignore_veh or false, function(self, value)
			object.ignore_veh = value
		end)

		MSD.BoolSlider(panel, "static", nil, 1, 50, Ln("mark_area"), object.mark_area or false, function(self, value)
			object.mark_area = value
		end)
	end
}

MSD.ObjeciveList["Talk to NPC"] = {
	icon = Material("msd/icons/account-multiple.png", "smooth"),
	check = function() return MCS and true or false end,
	tbl = {
		npc = "",
		dialog = 1,
		marker = 0,
	},
	builUI = function(id, object, panel, popupm)
		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("enter_description"), Ln("q_obj_des") .. ":", object.desc, function(self, value)
			object.desc = value
		end, true)

		local bnt = MSD.Button(panel, "static", nil, 1, 50, Ln("npc_select"), function(self)
			if (IsValid(self.Menu)) then
				self.Menu:Remove()
				self.Menu = nil
			end

			self.Menu = MSD.MenuOpen(false, self)
			local sn_tbl = {}

			for _, ent in ipairs(ents.FindByClass("mcs_npc")) do
				local uid = ent:GetUID()
				sn_tbl[uid] = true

				self.Menu:AddOption("[" .. uid .. "] " .. ent:GetNamer(), function()
					self:SetText("[" .. uid .. "] " .. ent:GetNamer())
					object.npc = uid
				end)
			end

			for k, c in pairs(MCS.Spawns) do
				if sn_tbl[k] then continue end

				self.Menu:AddOption(k .. " (" .. Ln("not_spawned") .. ") ", function()
					self:SetText("[" .. k .. "]")
					object.npc = k
					sn_tbl[k] = true
				end)
			end

			local x, y = self:LocalToScreen(0, self:GetTall())
			self.Menu:SetMinimumWidth(self:GetWide())
			self.Menu:Open(x, y, false, self)
		end)

		if object.npc ~= "" then
			bnt:SetText("[" .. object.npc .. "]")
		end

		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("enter_id"), Ln("npc_did_open"), object.dialog, function(self, value)
			object.dialog = tonumber(value) or nil
		end, true, nil, nil, true)

		MSD.Button(panel, "static", nil, 1, 50, Ln("map_marker"), function()
			local sub_list, _, plm = popupm(Ln("map_marker"), 2, 2.5, 50)

			if not object.marker then
				object.marker = 0
			end

			for ic_id, ic in pairs(MSD.PinPoints) do
				MSD.IconButton(sub_list, ic, "static", nil, 48, object.marker == ic_id and MSD.Config.MainColor.p or nil, nil, function()
					object.marker = ic_id
					plm.Close()
				end)
			end
		end)
	end
}

MSD.ObjeciveList["Randomize"] = {
	icon = MSD.Icons48.reload,
	tbl = {
		objects = {},
	},
	builUI = function(id, object, panel, pp, quest)
		for oid, obj in pairs(quest.objects) do
			if id == oid then object.objects[id] = nil continue end
			MSD.BoolSlider(panel, "static", nil, 2, 50, "[" .. oid .. "] " .. obj.type, object.objects[oid], function(self, var)
				object.objects[oid] = var
			end)
		end
	end
}

MSD.ObjeciveList["End of quest"] = {
	icon = MSD.Icons48.reload_alert,
	tbl = {
		reward_multiply = 0,
	}
}

MSD.ObjeciveList["Skip to"] = {
	icon = MSD.Icons48.skip_to,
	tbl = {
		oid = 1,
	},
	builUI = function(id, object, panel, pp, quest)
		local lobj = quest.objects[object.oid] and quest.objects[object.oid].type or "Invalid"
		local combo = MSD.ComboBox(panel, "static", nil, 1, 50, Ln("q_needquest_menu") .. ":", "[" .. object.oid .. "] " .. lobj )

		for oid, obj in pairs(quest.objects) do
			if id == oid then object.oid = 1 continue end
			combo:AddChoice("[" .. oid .. "] " .. obj.type, oid)
		end

		combo.OnSelect = function(self, index, text, data)
			if text == Ln("none") then
				object.oid = 1
				return
			end
			object.oid = data
		end
	end
}

MSD.EventList = {}

MSD.EventList["Check for vehicle"] = {
	icon = Material("mqs/map_markers/m17.png", "smooth"),
	data = {
		[1] = Vector(0,0,0),
		[2] = 500,
	},
	builUI = function(event, panel)
		local data = event[2]
		MSD.VectorSelectorList(panel, "Check Position", data[1], nil, nil, nil, true, function(vec)
			data[1] = vec
		end)

		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("def_units", "350"), Ln("q_dist_point"), data[2], function(self, value)
			data[2] = tonumber(value) or 500
		end, true, nil, nil, true)
	end
}

MSD.EventList["Give weapon"] = {
	icon = Material("mqs/icons/pistol.png", "smooth"),
	data = "weapon_pistol",
	ui_h = 4,
	builUI = function(event, panel)
		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("e_wep_class"), Ln("weapon_name") .. ":", event[2], function(self, value)
			event[2] = value
		end, true)
	end
}

MSD.EventList["Give ammo"] = {
	icon = Material("mqs/icons/ammo.png", "smooth"),
	data = {
		[1] = "Pistol",
		[2] = 10,
	},
	ui_h = 1.1,
	builUI = function(event, panel)
		local btn = MSD.ButtonIcon(panel, "static", nil, 1, 50, Ln("select_ammo") .. ": " .. language.GetPhrase("#" .. event[2][1] .. "_ammo"), Material("mqs/icons/ammo.png", "smooth"), function() end)
		btn.hovered = true

		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("e_number"), Ln("amount_ammo") .. ":", event[2][2], function(self, value)
			event[2][2] = tonumber(value) or 0
		end, true, nil, nil, true)

		for _, ammo in ipairs(game.GetAmmoTypes()) do
			MSD.Button(panel, "static", nil, 3, 50, language.GetPhrase("#" .. ammo .. "_ammo"), function(self)
				event[2][1] = ammo
				btn:SetText(Ln("select_ammo") .. ": " .. language.GetPhrase("#" .. ammo .. "_ammo"))
			end)
		end
	end
}

MSD.EventList["Strip All Weapons"] = {
	icon = Material("mqs/icons/pistol_remove.png", "smooth"),
	data = false,
	ui_h = 6,
	builUI = function(event, panel)
		MSD.BoolSlider(panel, "static", nil, 1, 50, Ln("restore_wep"), event[2], function(self, var)
			event[2] = var
		end)
	end
}

MSD.EventList["Restore All Weapons"] = {
	icon = Material("msd/icons/account-convert.png", "smooth"),
	data = nil,
	builUI = false
}

MSD.EventList["Strip Weapon"] = {
	icon = Material("mqs/icons/pistol_remove.png", "smooth"),
	data = "",
	ui_h = 4,
	builUI = function(event, panel)
		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("e_wep_class"), Ln("weapon_name") .. ":", event[2], function(self, value)
			event[2] = value
		end, true)
	end
}

MSD.EventList["Spawn quest entity"] = {
	icon = Material("mqs/icons/box_open_star.png", "smooth"),
	check = "Collect quest ents",
	data = {
		[1] = "models/props_junk/cardboard_box001a.mdl",
		[2] = Vector(0, 0, 0),
		[3] = true,
		[4] = false,
		[5] = Angle(0, 0, 0)
	},
	builUI = function(event, panel)
		local data = event[2]

		local mdl = MSD.TextEntry(panel, "static", nil, 1.5, 50, Ln("e_model"), Ln("model") .. ":", data[1], function(self, value)
			data[1] = value
		end, true)

		MSD.Button(panel, "static", nil, 3, 50, Ln("copy_from_ent"), function()
			local md = LocalPlayer():GetEyeTrace().Entity
			if not md then return end
			md = md:GetModel()
			mdl:SetText(md)
			data[1] = md
		end)

		MSD.VectorSelectorList(panel, Ln("spawn_point"), data[2], true, data[5], Ln("spawn_ang"), true, function(vec, ang)
			data[2] = vec
			data[5] = ang
		end)

		MSD.BoolSlider(panel, "static", nil, 1, 50, Ln("ent_show_pointer"), data[3], function(self, var)
			data[3] = var
		end)

		MSD.DTextSlider(panel, "static", nil, 1, 50, Ln("ent_stnd_style"), Ln("ent_arcade_style"), data[4], function(self, value)
			data[4] = value
		end)

		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("e_blank_dis"), Ln("hold_use", "E") .. "(" .. Ln("in_sec") .. "):", data[8] or "", function(self, value)
			value = tonumber(value)
			if value then value = math.Clamp(value, 1, 60) end
			data[8] = value or nil
		end, true, nil, nil, true)

		local matp = MSD.TextEntry(panel, "static", nil, 1.5, 50, Ln("mat_default"), Ln("e_material") .. ":", data[6], function(self, value)
			data[6] = value or nil
		end, true)

		MSD.Button(panel, "static", nil, 3, 50, Ln("copy_from_ent"), function()
			local md = LocalPlayer():GetEyeTrace().Entity
			if not md then return end
			md = md:GetMaterial()
			matp:SetText(md)
			data[6] = md
		end)

		MSD.ColorSelector(panel, "static", nil, 1, 50, Ln("custom_color"), data[7] or color_white, function(self, color)
			data[7] = color
		end, true)

		MSD.BoolSlider(panel, "static", nil, 1, 50, "Attach to the quest Vehicle", data[9], function(self, var)
			data[9] = var
		end)

		MSD.BoolSlider(panel, "static", nil, 1, 50, Ln("collision"), data[10], function(self, var)
			data[10] = var
		end)

		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("e_blank_dis"), "Skip to objective ID on pickup:", data[11] or "", function(self, value)
			value = tonumber(value)
			data[11] = value or nil
		end, true, nil, nil, true)
	end
}

MSD.EventList["Spawn entity"] = {
	icon = Material("mqs/icons/box_open.png", "smooth"),
	data = {
		[1] = "",
		[2] = Vector(0, 0, 0),
		[3] = Angle(0, 0, 0),
		[4] = nil,
		[5] = false
	},
	builUI = function(event, panel)
		local data = event[2]

		local ecls = MSD.TextEntry(panel, "static", nil, 1.5, 50, Ln("e_ent_class"), Ln("e_class") .. ":", data[1], function(self, value)
			data[1] = value
		end, true)

		MSD.Button(panel, "static", nil, 3, 50, Ln("copy_from_ent"), function()
			local md = LocalPlayer():GetEyeTrace().Entity
			if not md then return end
			md = md:GetClass()
			ecls:SetText(md)
			data[1] = md
		end)

		local mdl = MSD.TextEntry(panel, "static", nil, 1.5, 50, Ln("e_blank_default"), Ln("e_model") .. ":", data[4], function(self, value)
			if value == "" then
				data[4] = nil
			end

			data[4] = value
		end, true)

		MSD.Button(panel, "static", nil, 3, 50, Ln("copy_from_ent"), function()
			local md = LocalPlayer():GetEyeTrace().Entity
			if not md then return end
			md = md:GetModel()
			mdl:SetText(md)
			data[4] = md
		end)

		MSD.VectorSelectorList(panel, Ln("spawn_point"), data[2], true, data[3], Ln("spawn_ang"), true, function(vec, ang)
			data[2] = vec
			data[3] = ang
		end)

		local matp = MSD.TextEntry(panel, "static", nil, 1.5, 50, Ln("mat_default"), Ln("e_material") .. ":", data[6], function(self, value)
			data[6] = value or nil
		end, true)

		MSD.Button(panel, "static", nil, 3, 50, Ln("copy_from_ent"), function()
			local md = LocalPlayer():GetEyeTrace().Entity
			if not md then return end
			md = md:GetMaterial()
			matp:SetText(md)
			data[6] = md
		end)

		MSD.ColorSelector(panel, "static", nil, 1, 50, Ln("custom_color"), data[7] or color_white, function(self, color)
			data[7] = color
		end, true)

		MSD.BoolSlider(panel, "static", nil, 1, 50, Ln("disable_phys"), data[5], function(self, var)
			data[5] = var
		end)

		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("e_blank_default"), Ln("custom_id") .. ":", data[8], function(self, value)
			data[8] = value or nil
		end, true)
	end
}

MSD.EventList["Spawn npc"] = {
	icon = Material("mqs/icons/user_plus.png", "smooth"),
	data = {
		[1] = "npc_citizen",
		[2] = Vector(0, 0, 0),
		[3] = Angle(0, 0, 0),
		[4] = false,
		[5] = nil,
		[6] = nil,
		[7] = true,
		[8] = nil,
		[9] = nil,
	},
	builUI = function(event, panel, t_id, object)
		local data = event[2]

		local ecls = MSD.TextEntry(panel, "static", nil, 1.5, 50, Ln("e_npc_class"), Ln("e_class") .. ":", data[1], function(self, value)
			data[1] = value
		end, true)

		MSD.Button(panel, "static", nil, 3, 50, Ln("copy_from_ent"), function()
			local md = LocalPlayer():GetEyeTrace().Entity
			if not md then return end
			md = md:GetClass()
			ecls:SetText(md)
			data[1] = md
		end)

		local mdl = MSD.TextEntry(panel, "static", nil, 1.5, 50, Ln("e_blank_default"), Ln("e_model") .. ":", data[5], function(self, value)
			if value == "" then
				data[5] = nil
			end

			data[5] = value
		end, true)

		MSD.Button(panel, "static", nil, 3, 50, Ln("copy_from_ent"), function()
			local md = LocalPlayer():GetEyeTrace().Entity
			if not md then return end
			md = md:GetModel()
			mdl:SetText(md)
			data[5] = md
		end)

		MSD.VectorSelectorList(panel, Ln("spawn_point"), data[2], true, data[3], Ln("spawn_ang"), true, function(vec, ang)
			data[2] = vec
			data[3] = ang
		end)

		if object and object.type == "Kill NPC" then
			MSD.BoolSlider(panel, "static", nil, 1, 50, Ln("npc_q_target"), data[4], function(self, var)
				data[4] = var
			end)
		end

		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("e_blank_default"), Ln("e_wep_class") .. ":", data[6], function(self, value)
			if value == "" then
				data[6] = nil
			end

			data[6] = value
		end, true)

		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("e_blank_default"), Ln("Custom HP") .. ":", data[9], function(self, value)
			data[9] = tonumber(value) or nil
		end, true, nil, nil, true)

		MSD.BoolSlider(panel, "static", nil, 1, 50, Ln("npc_hostile"), data[7], function(self, var)
			data[7] = var
		end)

		MSD.BoolSlider(panel, "static", nil, 1, 50, Ln("NextBot NPC"), data[8], function(self, var)
			data[8] = var
		end)
	end
}

MSD.EventList["Manage do time"] = {
	icon = Material("mqs/map_markers/c5.png", "smooth"),
	data = {
		[1] = 1,
		[2] = 0,
	},
	ui_h = 4,
	builUI = function(event, panel)
		local data = event[2]

		if isbool(data[1]) then data[1] = 1 end
		local datatbl = {
			[1] = Ln("q_dotime_reset"),
			[2] = Ln("q_dotime_add"),
			[3] = Ln("q_dotime_set"),
		}

		local combo = MSD.ComboBox(panel, "static", nil, 1, 50, "", datatbl[data[1]] )

		for k, v in pairs(datatbl) do
			combo:AddChoice(v, k)
		end

		combo.OnSelect = function(self, index, text, d)
			data[1] = d
		end

		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("e_number"), Ln("e_number") .. "(" .. Ln("in_sec") .. "):", data[2], function(self, value)
			data[2] = tonumber(value) or 0
		end, true, nil, nil, true)
	end
}

MSD.EventList["Spawn vehicle"] = {
	icon = Material("mqs/map_markers/v1.png", "smooth"),
	data = {
		[1] = "",
		[2] = "default",
		[3] = Vector(0, 0, 0),
		[4] = Angle(0, 0, 0),
		[5] = 0,
	},
	builUI = function(event, panel)
		local data = event[2]

		MSD.TextEntry(panel, "static", nil, 1.5, 50, Ln("e_veh_class"), Ln("e_class") .. ":", data[1], function(self, value)
			data[1] = value
		end, true)

		MSD.Button(panel, "static", nil, 3, 50, Ln("type") .. ": " .. data[2], function(self)
			if (IsValid(self.Menu)) then
				self.Menu:Remove()
				self.Menu = nil
			end

			self.Menu = MSD.MenuOpen(false, self)

			self.Menu:AddOption("default", function()
				data[2] = "default"
				self:SetText(Ln("type") .. ": " .. data[2])
			end)

			self.Menu:AddOption("simfphys", function()
				data[2] = "simfphys"
				self:SetText(Ln("type") .. ": " .. data[2])
			end)

			self.Menu:AddOption("LFS / SW vehicles", function()
				data[2] = "lfs"
				self:SetText(Ln("type") .. ": " .. data[2])
			end)

			local x, y = self:LocalToScreen(0, self:GetTall())
			self.Menu:SetMinimumWidth(self:GetWide())
			self.Menu:Open(x, y, false, self)
		end)

		MSD.VectorSelectorList(panel, Ln("spawn_point"), data[3], true, data[4], Ln("spawn_ang"), true, function(vec, ang)
			data[3] = vec
			data[4] = ang
		end)

		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("e_number"), Ln("Skin ID") .. ":", data[5] or 0, function(self, value)
			data[5] = tonumber(value) or 0
		end, true, nil, nil, true)

		MSD.ColorSelector(panel, "static", nil, 1, 50, Ln("custom_color"), data[7] or color_white, function(self, color)
			data[7] = color
		end)

	end
}

MSD.EventList["Remove vehicle"] = {
	icon = Material("mqs/map_markers/v7.png", "smooth"),
	data = nil,
	ui_h = 5,
	builUI = function(event, panel)
		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("e_blank_dis"), Ln("delay") .. "(" .. Ln("in_sec") .. "):", event[2] or "", function(self, value)
			event[2] = tonumber(value) or nil
		end, true, nil, nil, true)
	end
}

MSD.EventList["Remove all entites"] = {
	icon = MSD.Icons48.layers_remove,
	data = nil,
}

MSD.EventList["Remove entites by ID"] = {
	icon = MSD.Icons48.layers_remove,
	data = {
		[1] = "",
	},
	ui_h = 5,
	builUI = function(event, panel)
		local data = event[2]
		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("e_value"), Ln("custom_id") .. ":", data[1], function(self, value)
			data[1] = value
		end, true)
	end
}

MSD.EventList["Set HP"] = {
	icon = Material("mqs/icons/heart.png", "smooth"),
	data = {
		[1] = true,
		[2] = 0,
	},
	ui_h = 4,
	builUI = function(event, panel)
		local data = event[2]

		MSD.DTextSlider(panel, "static", nil, 1, 50, Ln("set_hp_full"), Ln("custom_val"), data[1], function(self, value)
			data[1] = value
		end)

		MSD.TextEntry(panel, "static", nil, 1, 50, "", Ln("e_value"), data[2], function(self, value)
			data[2] = tonumber(value) or 0
		end, true, nil, nil, true)
	end
}

MSD.EventList["Set Armor"] = {
	icon = Material("mqs/map_markers/a1.png", "smooth"),
	data = {
		[1] = 0,
	},
	ui_h = 6,
	builUI = function(event, panel)
		local data = event[2]
		MSD.TextEntry(panel, "static", nil, 1, 50, "", Ln("e_value"), data[1], function(self, value)
			data[1] = tonumber(value) or 0
		end, true, nil, nil, true)
	end
}

MSD.EventList["Teleport player"] = {
	icon = Material("mqs/map_markers/m17.png", "smooth"),
	data = {
		[1] = Vector(0,0,0),
		[2] = Angle(0,0,0),
	},
	builUI = function(event, panel)
		local data = event[2]
		MSD.VectorSelectorList(panel, Ln("spawn_point"), data[2], true, data[3], Ln("spawn_ang"), true, function(vec, ang)
			data[1] = vec
			data[2] = ang
		end)
	end
}

MSD.EventList["Set spawn point"] = {
	icon = Material("mqs/map_markers/m19.png", "smooth"),
	data = {
		[1] = Vector(0,0,0),
		[2] = Angle(0,0,0),
	},
	ui_h = 3,
	builUI = function(event, panel)
		local data = event[2]
		local update
		function update()
			panel:Clear()
			MSD.DTextSlider(panel, "static", nil, 1, 50, Ln("add_new_spawn"), Ln("remove_all_spawn"), data[1] and true or false, function(self, value)
				if value then
					data[1] = Vector(0,0,0)
				else
					data[1] = nil
				end
				update()
			end)

			if data[1] then
				MSD.VectorSelectorList(panel, Ln("spawn_point"), data[2], true, data[3], Ln("spawn_ang"), true, function(vec, ang)
					data[1] = vec
					data[2] = ang
				end)
			end
		end
		update()
	end
}

MSD.EventList["Cinematic camera"] = {
	icon = Material("mqs/map_markers/s1.png", "smooth"),
	data = {
		delay = nil,
		endtime = 7,
		text = "",
		cam_start = {
			pos = Vector(0, 0, 0),
			ang = Angle(0, 0, 0),
			fov = 90,
		},
		cam_end = {
			pos = Vector(0, 0, 0),
			ang = Angle(0, 0, 0),
			fov = 90,
		},
		cam_speed = 5,
		fov_speed = 5,
		effect = true,
	},
	builUI = function(event, panel)
		local data = event[2]

		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("e_blank_dis"), Ln("delay"), data.delay, function(self, value)
			data.delay = tonumber(value) or nil
		end, true, nil, nil, true)

		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("e_text"), Ln("dis_text") .. ":", data.text, function(self, value)
			data.text = value
		end, true)

		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("e_value"), Ln("duration") .. "(" .. Ln("in_sec") .. "):", data.endtime, function(self, value)
			data.endtime = math.max(tonumber(value) or 3, 3)
		end, true, nil, nil, true)

		MSD.BoolSlider(panel, "static", nil, 1, 50, Ln("cam_effect"), data.effect or false, function(self, value)
			data.effect = value
		end)

		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("e_value"), Ln("cam_speed") .. "(" .. Ln("in_sec") .. "):", data.cam_speed, function(self, value)
			data.cam_speed = tonumber(value) or 5
		end, true, nil, nil, true)

		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("e_value"), Ln("fov_speed") .. "(" .. Ln("in_sec") .. "):", data.fov_speed, function(self, value)
			data.fov_speed = tonumber(value) or 5
		end, true, nil, nil, true)

		MSD.Header(panel, Ln("cam_start"))
		local vec1 = MSD.VectorDisplay(panel, "static", nil, 2, 50, Ln("cam_pos"), data.cam_start.pos, function(vec)
			data.cam_start.pos = vec
		end)
		local amg1 = MSD.AngleDisplay(panel, "static", nil, 2, 50, Ln("cam_ang"), data.cam_start.ang, function(ang)
			data.cam_start.ang = ang
		end)

		MSD.TextEntry(panel, "static", nil, 2, 50, Ln("e_value"), Ln("cam_fov") .. ":", data.cam_start.fov, function(self, value)
			data.cam_start.fov = tonumber(value) or 90
		end, true, nil, nil, true)

		MSD.Button(panel, "static", nil, 2, 50, Ln("set_pos_self"), function()
			local vec = LocalPlayer():EyePos()
			vec1.vector = vec
			data.cam_start.pos = vec
			local ang = Angle(LocalPlayer():GetAngles().p, LocalPlayer():GetAngles().y, 0)
			amg1.angle = ang
			data.cam_start.ang = ang
		end)

		MSD.Header(panel, Ln("cam_end"))
		local vec2 = MSD.VectorDisplay(panel, "static", nil, 2, 50, Ln("cam_pos"), data.cam_end.pos, function(vec)
			data.cam_end.pos = vec
		end)
		local amg2 = MSD.AngleDisplay(panel, "static", nil, 2, 50, Ln("cam_ang"), data.cam_end.ang, function(ang)
			data.cam_end.ang = ang
		end)

		MSD.TextEntry(panel, "static", nil, 2, 50, Ln("e_value"), Ln("cam_fov") .. ":", data.cam_end.fov, function(self, value)
			data.cam_end.fov = tonumber(value) or 90
		end, true, nil, nil, true)

		MSD.Button(panel, "static", nil, 2, 50, Ln("set_pos_self"), function()
			local vec = LocalPlayer():EyePos()
			vec2.vector = vec
			data.cam_end.pos = vec
			local ang = Angle(LocalPlayer():GetAngles().p, LocalPlayer():GetAngles().y, 0)
			amg2.angle = ang
			data.cam_end.ang = ang
		end)
	end
}

MSD.EventList["[MCS] Spawn npc"] = {
	icon = Material("msd/icons/account.png", "smooth"),
	check = function() return not MCS and true or false end,
	ui_h = 3,
	data = {
		[1] = "",
		[2] = Vector(0, 0, 0),
		[3] = Angle(0, 0, 0),
	},
	builUI = function(event, panel, t_id, object)
		local data = event[2]

		local bnt = MSD.Button(panel, "static", nil, 1, 50, Ln("npc_select"), function(self)
			if (IsValid(self.Menu)) then
				self.Menu:Remove()
				self.Menu = nil
			end

			self.Menu = MSD.MenuOpen(false, self)

			for k, v in pairs(MCS.Spawns) do
				self.Menu:AddOption(k, function()
					self:SetText(k)
					data[1] = k
				end)
			end

			local x, y = self:LocalToScreen(0, self:GetTall())
			self.Menu:SetMinimumWidth(self:GetWide())
			self.Menu:Open(x, y, false, self)
		end)

		if data[1] ~= "" then
			bnt:SetText(data[1])
		end

		MSD.VectorSelectorList(panel, Ln("spawn_point"), data[2], true, data[3], Ln("spawn_ang"), true, function(vec, ang)
			data[2] = vec
			data[3] = ang
		end)
	end
}

MSD.EventList["Music player"] = {
	icon = Material("mqs/icons/music_circle.png", "smooth"),
	data = {
		path = "",
	},
	ui_h = 4,
	builUI = function(event, panel)
		local data = event[2]
		MSD.TextEntry(panel, "static", nil, 1, 50, "", "Music: (path or URL)", data.path, function(self, value)
			data.path = value
		end, true)
	end
}

MSD.EventList["Run Console Command"] = {
	icon = Material("msd/icons/console.png", "smooth"),
	data = {
		[1] = "",
		[2] = "",
	},
	ui_h = 3,
	builUI = function(event, panel)
		local data = event[2]
		MSD.TextEntry(panel, "static", nil, 1, 50, "", Ln("e_cmd"), data[1], function(self, value)
			data[1] = value
		end, true)
		MSD.InfoText(panel, Ln("hint_cmd"))
		MSD.TextEntry(panel, "static", nil, 1, 50, "", Ln("e_args"), data[2], function(self, value)
			data[2] = value
		end, true)
	end
}

MSD.EventList["Track player"] = {
	icon = Material("mqs/map_markers/m5.png", "smooth"),
	data = {
		[1] = "",
		[2] = 0,
		[3] = {}
	},
	builUI = function(event, panel)
		local data = event[2]
		local update
		-- MSD.Button(panel, "static", nil, 1, 50, Ln("map_marker"), function()
		-- 	local sub_list, _, _ = popupm(Ln("map_marker"), 2, 2.5, 50)
		-- 	for tid, tm in SortedPairsByMemberValue(team.GetAllTeams(), "Name", true) do
		-- 		if not tm.Joinable then continue end

		-- 		MSD.TextEntry(sub_list, "static", nil, 2, 50, "", tm.Name, data[3][tm.Name], function(self, val)
		-- 			data[3][tm.Name] = val ~= "" and val or nil
		-- 		end, true, nil, nil, true)
		-- 	end
		-- end)
		function update()
			panel:Clear()
			MSD.TextEntry(panel, "static", nil, 1, 50, "", Ln("dis_text"), data[1], function(self, value)
				data[1] = value
			end, true)

			MSD.InfoHeader(panel, Ln("map_marker"))
			if not data[2] then	data[2] = 0	end
			for ic_id, ic in pairs(MSD.PinPoints) do
				MSD.IconButton(panel, ic, "static", nil, 32, data[2] == ic_id and MSD.Config.MainColor.p or nil, nil, function()
					data[2] = ic_id
					update()
				end)
			end

			MSD.InfoHeader(panel, Ln("s_team_whitelist"))
			for tid, tm in SortedPairsByMemberValue(team.GetAllTeams(), "Name", true) do
				if not tm.Joinable then continue end

				MSD.BoolSlider(panel, "static", nil, 2, 50, tm.Name, data[3][tm.Name], function(self, var)
					data[3][tm.Name] = var
				end)
			end
		end
		update()
	end
}

MSD.EventList["End track player"] = {
	icon = Material("mqs/map_markers/m9.png", "smooth"),
	data = nil,
}

MQS.RewardsList = {}

MQS.RewardsList["Give Weapon"] = {
	data = {
		[1] = "",
	},
	builUI = function(data, panel)
		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("e_value"), Ln("e_wep_class") .. ":", data[1], function(self, value)
			data[1] = value
		end, true)
	end
}

MQS.RewardsList["DarkRP money"] = {
	data = {
		[1] = 1000,
	},
	builUI = function(data, panel)
		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("e_value"), Ln("q_money_give") .. ":", data[1], function(self, value)
			data[1] = tonumber(value) or 0
		end, true, nil, nil, true)
	end
}

MQS.RewardsList["DarkRP karma"] = {
	data = {
		[1] = 5,
	},
	builUI = function(data, panel)
		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("e_value"), Ln("karma") .. ":", data[1], function(self, value)
			data[1] = tonumber(value) or 0
		end, true, nil, nil, true)
	end
}

MQS.RewardsList["PointShop2 Standard Points"] = {
	data = {
		[1] = 100,
	},
	builUI = function(data, panel)
		MSD.TextEntry(panel, "static", nil, 1, 50, "", Ln("e_number") .. ":", data[1], function(self, value)
			data[1] = tonumber(value) or 0
		end, true, nil, nil, true)
	end
}

MQS.RewardsList["PointShop2 Premium Points"] = {
	data = {
		[1] = 10,
	},
	builUI = function(data, panel)
		MSD.TextEntry(panel, "static", nil, 1, 50, "", Ln("e_number") .. ":", data[1], function(self, value)
			data[1] = tonumber(value) or 0
		end, true, nil, nil, true)
	end
}

MQS.RewardsList["PointShop2 Give Item"] = {
	data = {
		[1] = "",
	},
	builUI = function(data, panel)
		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("e_ent_class"), Ln("e_class") .. ":", data[1], function(self, value)
			data[1] = value
		end, true)
	end
}

MQS.RewardsList["PointShop Points"] = {
	data = {
		[1] = 100,
	},
	builUI = function(data, panel)
		MSD.TextEntry(panel, "static", nil, 1, 50, "", Ln("e_number") .. ":", data[1], function(self, value)
			data[1] = tonumber(value) or 0
		end, true, nil, nil, true)
	end
}

MQS.RewardsList["PointShop Give Item"] = {
	data = {
		[1] = "",
	},
	builUI = function(data, panel)
		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("e_ent_class"), Ln("e_class") .. ":", data[1], function(self, value)
			data[1] = value
		end, true)
	end
}

MQS.RewardsList["DarkRP Leveling System"] = {
	data = {
		[1] = 1000,
	},
	builUI = function(data, panel)
		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("e_value"), "Give XP:", data[1], function(self, value)
			data[1] = tonumber(value) or 0
		end, true, nil, nil, true)
	end
}

MQS.RewardsList["Run Console Command"] = {
	data = {
		[1] = "",
		[2] = "",
	},
	builUI = function(data, panel)
		MSD.InfoText(panel, Ln("hint_cmd"))
		MSD.TextEntry(panel, "static", nil, 1, 50, "", Ln("e_cmd"), data[1], function(self, value)
			data[1] = value
		end, true)
		MSD.TextEntry(panel, "static", nil, 1, 50, "", Ln("e_args"), data[2], function(self, value)
			data[2] = value
		end, true)
	end
}

MQS.RewardsList["Helix money"] = {
	data = {
		[1] = 1000,
	},
	builUI = function(data, panel)
		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("e_value"), Ln("q_money_give") .. ":", data[1], function(self, value)
			data[1] = tonumber(value) or 0
		end, true, nil, nil, true)
	end
}

MQS.RewardsList["Glorified Leveling"] = {
	data = {
		[1] = 1000,
		[2] = nil,
	},
	builUI = function(data, panel)
		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("e_value"), "Give XP:", data[1], function(self, value)
			data[1] = tonumber(value) or 0
		end, true, nil, nil, true)

		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("e_blank_dis"), "Give Level:", data[2], function(self, value)
			data[2] = tonumber(value) or nil
		end, true, nil, nil, true)
	end
}

MQS.RewardsList["Wiltos skill XP"] = {
	data = {
		[1] = 100,
	},
	builUI = function(data, panel)
		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("e_value"), "Give XP:", data[1], function(self, value)
			data[1] = tonumber(value) or 0
		end, true, nil, nil, true)
	end
}

MQS.RewardsList["Remove quest played data"] = {
	data = {
		[1] = "",
	},
	builUI = function(data, panel)
		MSD.TextEntry(panel, "static", nil, 1, 50, "qid1,qid2", "Enter quest id list use ',' for separation", data[1], function(self, value)
			data[1] = value
		end, true)
	end
}

MQS.RewardsList["Elite XP System"] = {
	data = {
		[1] = 1000,
	},
	builUI = function(data, panel)
		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("e_value"), "Give XP:", data[1], function(self, value)
			data[1] = tonumber(value) or 0
		end, true, nil, nil, true)
	end
}

MQS.RewardsList["MRS"] = {
	data = {
		[1] = "",
		[2] = 1,
		[3] = 1,
	},
	builUI = function(data, panel)
		local selected_g = MRS.Ranks[data[1]]
		local groupc = MSD.ComboBox(panel, "static", nil, 1, 50, Ln("group_list") .. ":", selected_g and data[1] or Ln("none") )
		local rankc = MSD.ComboBox(panel, "static", nil, 1, 50, Ln("rank_list") .. ":", (selected_g and selected_g.ranks[data[2]].name) or Ln("none") )

		rankc.OnSelect = function(self, index, text, sel)
			data[2] = sel
		end

		for gname, _ in pairs(MRS.Ranks) do
			groupc:AddChoice(gname)
		end

		groupc.OnSelect = function(self, index, text)
			if text == Ln("none") then
				data[1] = ""
				return
			end
			data[1] = text
			data[2] = 1
			rankc:Clear()
			rankc:SetText(MRS.Ranks[text].ranks[1].name or Ln("none"))

			for id, r in pairs(MRS.Ranks[text].ranks) do
				rankc:AddChoice(r.name, id)
			end
		end

		local cvals = {
			Ln("action_set_rank"),
			Ln("action_set_rank_force"),
			Ln("action_promote_rank"),
			Ln("action_demote_rank"),
		}

		local combo = MSD.ComboBox(panel, "static", nil, 1, 50, Ln("action_select") .. ":", cvals[data[3]] )
		combo.OnSelect = function(self, index, text, sel)
			data[3] = sel
		end
		for id, option in pairs(cvals) do
			combo:AddChoice(option, id)
		end
	end
}

MQS.RewardsList["WCD Give car"] = {
	data = {
		[1] = "",
	},
	builUI = function(data, panel)
		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("e_value"), "CAR ID:", data[1], function(self, value)
			data[1] = value
		end, true)
	end
}

MQS.RewardsList["GAS Job Whitelist"] = {
	data = {
		[1] = 1,
	},
	builUI = function(data, panel)
		MSD.TextEntry(panel, "static", nil, 1, 50, Ln("e_value"), "Team Index:", data[1], function(self, value)
			data[1] = tonumber(value) or 1
		end, true, nil, nil, true)
	end
}