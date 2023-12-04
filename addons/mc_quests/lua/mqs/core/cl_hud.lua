
local ply = LocalPlayer()
local ScrW, ScrH = ScrW, ScrH
local info_icon = Material("mqs/icons/info.png", "smooth")
local center_gradient = Material("gui/center_gradient.vtf", "smooth")
local veh_marker = Material("mqs/map_markers/v1.png", "smooth")

local w1, w2, w3, wm, ch, alpha, dist_m = 0, 0, 0, 0, 0, 0, 0
local icon_color = Color(241, 200, 0)
local color_red = Color(231, 0, 0)

local objective_draw = {}
local objective_text = {}

local vehicle_req_task = {
	["Move to point"] = true,
	["Leave area"] = true,
	["Wait time"] = true,
}

local notification_types = {
	[1] = {Color(241, 200, 0), "mqs/notify/1.mp3"}, -- quest start / loop update notification
	[2] = {Color(231, 0, 0), "mqs/fail/1.mp3"}, -- quest fail notification
	[3] = {Color(50, 250, 0), "mqs/notify/3.mp3"}, -- quest success notification
	[4] = {Color(0, 129, 250), "mqs/fail/2.mp3"}, -- only displayed when used player track event
}

local tasknotify_types = {
	[1] = {Color(241, 200, 0), "mqs/start/2.mp3"}, -- displayed on task updated (lower part of the screen)
	[2] = {Color(231, 0, 0), "mqs/fail/1.mp3"}, -- not used currently
	[3] = {Color(50, 250, 0), "mqs/done/4.mp3"}, -- not used currently
	[4] = {Color(255, 255, 255), "mqs/done/4.mp3"}, -- displayed to show quest-giving NPCs if enabled in config
}

objective_draw["Wait time"] = function(q, obj)
	if not obj.stay_inarea then return end
	local x, y = ScrW(), ScrH()
	local pl_pos = ply:GetPos()
	local dist = pl_pos:DistToSqr(obj.point)
	local t_dist = obj.stay_inarea / 3
	t_dist = t_dist * t_dist

	if dist < t_dist then
		alpha = Lerp(FrameTime() * 7, alpha, 0)
	else
		alpha = Lerp(FrameTime() * 7, alpha, 1)
	end

	surface.SetDrawColor(0, 0, 0, alpha * 170)
	surface.SetMaterial(center_gradient)
	surface.DrawTexturedRectRotated(x / 2, y / 8, 250, alpha * (x + 200), -90)
	local _, h = draw.SimpleTextOutlined(MSD.GetPhrase("warning"), "MSDFont.Biger", x / 2, y / 8 - 50, MSD.ColorAlpha(color_red, alpha * 255), TEXT_ALIGN_CENTER, 0, 1, MSD.ColorAlpha(color_black, alpha * 100))
	draw.SimpleTextOutlined(MSD.GetPhrase("q_must_stay_area"), "MSDFont.36", x / 2, y / 8 + h - 50, MSD.ColorAlpha(color_white, alpha * 255), TEXT_ALIGN_CENTER, 0, 1, MSD.ColorAlpha(color_black, alpha * 100))
end

objective_draw["Collect quest ents"] = function(q, obj, x, y, al1, al2)
	local pl_pos = ply:GetPos()

	if obj.show_ents then
		local ent_l = MQS.ActiveTask[q.id].ents
		if not ent_l then return end
		local pos
		local dt

		for i, v in pairs(ent_l) do
			local e = Entity(v)
			if not IsValid(e) then continue end
			local dist = pl_pos:DistToSqr(e:GetPos())

			if not dt or dt > dist then
				dt = dist
				pos = e:GetPos()
			end
		end

		if pos then
			local dist = pl_pos:Distance(pos) * 0.75 / 25.4

			if MQS.Config.UI.HUDBG == 2 then
				draw.RoundedBox(8, al1 and x - ch - 10 or x - 10, al2 and y - 105 or y + 80, ch + 20, 25, MSD.Theme["m"])
			end

			ch = draw.SimpleTextOutlined("- " .. MSD.GetPhrase("dist_to_close") .. ": " .. math.floor(dist) .. " m", "MSDFont.22", x, al2 and y - 105 or y + 80, color_white, al1 and TEXT_ALIGN_RIGHT or TEXT_ALIGN_LEFT, 0, 1, color_black)
		end
	end

	local pos = obj.point
	local dist = obj.dist or 500
	if dist ^ 2 > pl_pos:DistToSqr(pos) then return end
	dist = pl_pos:Distance(pos) * 0.75 / 25.4
	local screenpos = pos:ToScreen()
	x, y = screenpos.x, screenpos.y - 50
	local icon = obj.marker and MSD.PinPoints[obj.marker]
	MSD.DrawTexturedRect(x - 24, y - 22, 48, 48, icon or MSD.PinPoints[0], MSD.ColorAlpha(color_black, 100 + alpha * 125))
	MSD.DrawTexturedRect(x - 24, y - 24, 48, 48, icon or MSD.PinPoints[0], MSD.ColorAlpha(icon_color, 100 + alpha * 125))
	draw.SimpleTextOutlined(math.floor(dist) .. " m", "MSDFont.25", x, y + 35, MSD.ColorAlpha(color_white, 200), TEXT_ALIGN_CENTER, 0, 1,MSD.ColorAlpha(color_black, 200))
end

objective_draw["Kill NPC"] = function(q, obj, x, y, al1, al2)
	if not obj.show_ents then return end

	local pl_pos = ply:GetPos()
	local ent_l = MQS.ActiveTask[q.id].misc_ents
	if not ent_l then return end
	local pos
	local dt

	for _, v in pairs(ent_l) do
		local e = Entity(v)
		if not IsValid(e) then continue end
		if not e:GetNWBool("MQSTarget") then continue end

		local epos = e:GetPos()
		local dist = pl_pos:DistToSqr(epos)

		if not dt or dt > dist then
			dt = dist
			pos = epos
		end

		if dist > (obj.dist and obj.dist ^ 2 or 1000) then
			epos.z = epos.z + 50
			local screenpos = epos:ToScreen()
			local sx, sy = screenpos.x, screenpos.y
			local icon = obj.marker and MSD.PinPoints[obj.marker]
			MSD.DrawTexturedRect(sx - 12, sy - 10, 24, 24, icon or MSD.PinPoints[0],  MSD.ColorAlpha(color_black, 100))
			MSD.DrawTexturedRect(sx - 12, sy - 12, 24, 24, icon or MSD.PinPoints[0],  MSD.ColorAlpha(color_red, 100))
		end

	end

	if pos then
		local dist = pl_pos:Distance(pos) * 0.75 / 25.4

		if MQS.Config.UI.HUDBG == 2 then
			draw.RoundedBox(8, al1 and x - ch - 10 or x - 10, al2 and y - 105 or y + 80, ch + 20, 25, MSD.Theme["m"])
		end

		ch = draw.SimpleTextOutlined("- " .. MSD.GetPhrase("dist_to_close") .. ": " .. math.floor(dist) .. " m", "MSDFont.22", x, al2 and y - 105 or y + 80, color_white, al1 and TEXT_ALIGN_RIGHT or TEXT_ALIGN_LEFT, 0, 1, color_black)
	end
end

objective_draw["Move to point"] = function(q, obj)
	local pos = obj.point
	local screenpos = pos:ToScreen()
	local x, y = screenpos.x, screenpos.y - 50

	if x < ScrW() / 4 or x > ScrW() - ScrW() / 4 then
		alpha = Lerp(FrameTime() * 7, alpha, 0)

		if x < 30 then
			x = 30
		end
	else
		dist_m = ply:GetPos():Distance(pos) * 0.75 / 25.4
		alpha = Lerp(FrameTime() * 7, alpha, 1)
	end

	if y < 50 then
		y = 50
	end

	if x > ScrW() - 48 then
		x = ScrW() - 48
	end

	if y > ScrH() - 48 then
		y = ScrH() - 48
	end

	local icon = obj.marker and MSD.PinPoints[obj.marker]
	MSD.DrawTexturedRect(x - 24, y - 22, 48, 48, icon or MSD.PinPoints[0],  MSD.ColorAlpha(color_black, 100 + alpha * 125))
	MSD.DrawTexturedRect(x - 24, y - 24, 48, 48, icon or MSD.PinPoints[0],  MSD.ColorAlpha(icon_color, 100 + alpha * 125))
	draw.SimpleTextOutlined(math.floor(dist_m) .. " m", "MSDFont.25", x, y + 35, MSD.ColorAlpha(color_white, alpha * 200), TEXT_ALIGN_CENTER, 0, 1, MSD.ColorAlpha(color_black, alpha * 200))
end

objective_draw["Move to any point"] = function(q, obj)
	for _,v in pairs(obj.points) do
		local pos = v.point

		local screenpos = pos:ToScreen()
		local x, y = screenpos.x, screenpos.y - 50

		if x < ScrW() / 4 or x > ScrW() - ScrW() / 4 then
			alpha = Lerp(FrameTime() * 7, alpha, 0)

			if x < 30 then
				x = 30
			end
		else
			dist_m = ply:GetPos():Distance(pos) * 0.75 / 25.4
			alpha = Lerp(FrameTime() * 7, alpha, 1)
		end

		if y < 50 then
			y = 50
		end

		if x > ScrW() - 48 then
			x = ScrW() - 48
		end

		if y > ScrH() - 48 then
			y = ScrH() - 48
		end

		local icon = v.marker and MSD.PinPoints[v.marker]
		MSD.DrawTexturedRect(x - 24, y - 22, 48, 48, icon or MSD.PinPoints[0],  MSD.ColorAlpha(color_black, 100 + alpha * 125))
		MSD.DrawTexturedRect(x - 24, y - 24, 48, 48, icon or MSD.PinPoints[0],  MSD.ColorAlpha(icon_color, 100 + alpha * 125))
		draw.SimpleTextOutlined(math.floor(dist_m) .. " m", "MSDFont.25", x, y + 35, MSD.ColorAlpha(color_white, alpha * 200), TEXT_ALIGN_CENTER, 0, 1, MSD.ColorAlpha(color_black, alpha * 200))
	end
end

objective_draw["Talk to NPC"] = function(q, obj)
	local npc, pos

	if MQS.NPCPositions and MQS.NPCPositions[obj.npc] then
		pos = MQS.NPCPositions[obj.npc]
	else
		for _, ent in ipairs(ents.FindByClass("mcs_npc")) do
			if ent:GetUID() == obj.npc then
				npc = ent
				break
			end
		end
		if not npc then return end
		pos = npc:GetPos()
	end

	if ply:GetPos():DistToSqr(pos) < 20000 then return end
	local screenpos = pos:ToScreen()
	local x, y = screenpos.x, screenpos.y - 20

	if x < ScrW() / 4 or x > ScrW() - ScrW() / 4 then
		alpha = Lerp(FrameTime() * 7, alpha, 0)

		if x < 30 then
			x = 30
		end
	else
		dist_m = ply:GetPos():Distance(pos) * 0.75 / 25.4
		alpha = Lerp(FrameTime() * 7, alpha, 1)
	end

	if y < 50 then
		y = 50
	end

	if x > ScrW() - 48 then
		x = ScrW() - 48
	end

	if y > ScrH() - 48 then
		y = ScrH() - 48
	end

	local icon = obj.marker and MSD.PinPoints[obj.marker]
	MSD.DrawTexturedRect(x - 24, y - 22, 48, 48, icon or MSD.PinPoints[0],  MSD.ColorAlpha(color_black, 100 + alpha * 125))
	MSD.DrawTexturedRect(x - 24, y - 24, 48, 48, icon or MSD.PinPoints[0],  MSD.ColorAlpha(icon_color, 100 + alpha * 125))
	draw.SimpleTextOutlined(math.floor(dist_m) .. " m", "MSDFont.25", x, y + 35, MSD.ColorAlpha(color_white, alpha * 200), TEXT_ALIGN_CENTER, 0, 1, MSD.ColorAlpha(color_black, alpha * 200))
end

objective_draw["Enter vehicle"] = function(vehicle)
	local pos = vehicle:GetPos()
	local screenpos = pos:ToScreen()
	local x, y = screenpos.x, screenpos.y - 50

	if x < ScrW() / 4 or x > ScrW() - ScrW() / 4 then
		alpha = Lerp(FrameTime() * 7, alpha, 0)

		if x < 30 then
			x = 30
		end
	else
		alpha = Lerp(FrameTime() * 7, alpha, 1)
		dist_m = ply:GetPos():Distance(pos) * 0.75 / 25.4
	end

	if y < 50 then
		y = 50
	end

	if x > ScrW() - 48 then
		x = ScrW() - 48
	end

	if y > ScrH() - 48 then
		y = ScrH() - 48
	end

	MSD.DrawTexturedRect(x - 24, y - 22, 48, 48, veh_marker, MSD.ColorAlpha(color_black, 100 + alpha * 125))
	MSD.DrawTexturedRect(x - 24, y - 24, 48, 48, veh_marker, MSD.ColorAlpha(icon_color, 100 + alpha * 125))
	draw.SimpleTextOutlined(math.floor(dist_m) .. " m", "MSDFont.25", x, y + 35, MSD.ColorAlpha(color_white, alpha * 200), TEXT_ALIGN_CENTER, 0, 1, MSD.ColorAlpha(color_black, alpha * 200))
end

objective_text["Collect quest ents"] = function() return MQS.GetSelfNWdata(ply, "quest_colected") .. "/" .. MQS.GetSelfNWdata(ply, "quest_ent") end

objective_text["Wait time"] = function(q, obj) return obj.show_timer and os.date("%M:%S", tonumber(MQS.GetSelfNWdata(ply, "quest_wait") - CurTime())) or "" end

objective_text["Kill random target"] = function(q, obj) return obj.target_count - MQS.GetSelfNWdata(ply, "targets") .. "/" .. obj.target_count end

function MQS.DoNotify(text1, text2, type)
	local startt = CurTime()
	local x, y = ScrW(), ScrH()
	local color = notification_types[type][1]
	local anim = 0
	surface.PlaySound(notification_types[type][2])

	MQS.HudNotification = function()
		surface.SetDrawColor(0, 0, 0, anim * 170)
		surface.SetMaterial(center_gradient)
		surface.DrawTexturedRectRotated(x / 2, y / 8, 250, anim * (x + 200), -90)
		local _, h = draw.SimpleTextOutlined(text1, "MSDFont.Biger", x / 2, y / 8 - 50, MSD.ColorAlpha(color, anim * 255), TEXT_ALIGN_CENTER, 0, 1, MSD.ColorAlpha(color_black, anim * 255))
		text2 = MSD.TextWrap(text2, "MSDFont.28", y)
		draw.DrawText(text2, "MSDFont.36", x / 2 + 1, y / 8 + h - 49,  MSD.ColorAlpha(color_black, anim * 255), TEXT_ALIGN_CENTER, 0)
		draw.DrawText(text2, "MSDFont.36", x / 2, y / 8 + h - 50,  MSD.ColorAlpha(color_white, anim * 255), TEXT_ALIGN_CENTER, 0)

		if startt + 8 < CurTime() then
			anim = Lerp(FrameTime() * 3, anim, 0)
		else
			anim = Lerp(FrameTime() * 5, anim, 1)
		end

		if startt + 10 < CurTime() then
			MQS.HudNotification = function() end
		end
	end
end

function MQS.DoTaskNotify(text, type)
	local startt = CurTime()
	local x, y = ScrW(), ScrH()
	local color = tasknotify_types[type][1]
	local anim = 0
	surface.PlaySound(tasknotify_types[type][2])

	MQS.HudTaskNotify = function()
		surface.SetDrawColor(0, 0, 0, anim * 100)
		surface.SetMaterial(center_gradient)
		surface.DrawTexturedRectRotated(x / 2, y - anim * (y / 8), 250, x + 200, -90)
		draw.SimpleTextOutlined(text, "MSDFont.Big", x / 2, y - anim * (y / 8 + 10), MSD.ColorAlpha(color, anim * 255), TEXT_ALIGN_CENTER, 0, 1, MSD.ColorAlpha(color_black, anim * 255))

		if startt + 5 < CurTime() then
			anim = Lerp(FrameTime() * 3, anim, 0)
		else
			anim = Lerp(FrameTime() * 5, anim, 1)
		end

		if startt + 10 < CurTime() then
			MQS.HudTaskNotify = function() end
		end
	end
end

function MQS.DoHint(text, type)
	MQS.DoTaskNotify(text, type)
	local startt = CurTime()
	local anim = 0
	local npc_table = ents.FindByClass("mqs_npc")

	if MCS then
		for _, ent in pairs(ents.FindByClass("mcs_npc")) do
			if IsValid(ent) and MCS.Spawns[ent:GetUID()] and MCS.Spawns[ent:GetUID()].questNPC then
				table.insert(npc_table, ent)
			end
		end
	end

	MQS.HudHint = function()
		for _, ent in pairs(npc_table) do
			if not IsValid(ent) then continue end

			if not ent.uialpha then
				ent.uialpha = 0.3
			end

			if not ent.uidist then
				ent.uidist = 0
			end

			local pos = ent:GetPos()
			local screenpos = pos:ToScreen()
			local sx, sy = screenpos.x, screenpos.y - 50
			local x, y = ScrW() / 2, ScrH() / 2
			x = Lerp(anim, x, sx)
			y = Lerp(anim, y, sy)

			if startt + 28 > CurTime() then
				if x < ScrW() / 3 or x > ScrW() - ScrW() / 3 then
					ent.uialpha = Lerp(FrameTime() * 7, ent.uialpha, 0.2)

					if x < 30 then
						x = 30
					end
				else
					ent.uialpha = Lerp(FrameTime() * 7, ent.uialpha, 1)
					ent.uidist = ply:GetPos():Distance(pos) * 0.75 / 25.4
				end

				if anim > 0.9 then
					draw.SimpleTextOutlined(math.floor(ent.uidist) .. " m", "MSDFont.25", x, y + 35, MSD.ColorAlpha(color_white, ent.uialpha * 255 - 55), TEXT_ALIGN_CENTER, 0, 1, MSD.ColorAlpha(color_black, ent.uialpha * 255 - 55))
				end
			else
				ent.uialpha = Lerp(FrameTime() * 7, ent.uialpha, 0)
			end

			if y < 50 then
				y = 50
			end

			if x > ScrW() - 48 then
				x = ScrW() - 48
			end

			if y > ScrH() - 48 then
				y = ScrH() - 48
			end

			MSD.DrawTexturedRect(x - 24, y - 22, 48, 48, MSD.Icons48.account, MSD.ColorAlpha(color_black, ent.uialpha * 255))
			MSD.DrawTexturedRect(x - 24, y - 24, 48, 48, MSD.Icons48.account, MSD.ColorAlpha(color_white, ent.uialpha * 255))
		end

		if startt + 1.5 <= CurTime() then
			anim = Lerp(FrameTime() * 2, anim, 1)
		end

		if startt + 30 < CurTime() then
			MQS.HudHint = function() end
		end
	end
end

function MQS.UdpateTracking(pos, icon)
	local startt = CurTime()
	local anim = 0
	local dist = 0
	local alp = 0

	MQS.TrackPlayer = function()
		local screenpos = pos:ToScreen()
		local x, y = screenpos.x, screenpos.y - 50

		if x < ScrW() / 4 or x > ScrW() - ScrW() / 4 then
			alp = Lerp(FrameTime() * 7, alp, 0)

			if x < 30 then
				x = 30
			end
		else
			dist = ply:GetPos():Distance(pos) * 0.75 / 25.4
			alp = Lerp(FrameTime() * 7, alp, 1)
		end

		local a = alp * 200

		if y < 50 then
			y = 50
		end

		if x > ScrW() - 48 then
			x = ScrW() - 48
		end

		if y > ScrH() - 48 then
			y = ScrH() - 48
		end

		MSD.DrawTexturedRect(x - 24, y - 22, 48, 48, icon or MSD.PinPoints[0], MSD.ColorAlpha(color_black, 55 + a * anim))
		MSD.DrawTexturedRect(x - 24, y - 24, 48, 48, icon or MSD.PinPoints[0], MSD.ColorAlpha(color_red, 55 + a * anim))
		draw.SimpleTextOutlined(math.floor(dist) .. " m", "MSDFont.25", x, y + 35, MSD.ColorAlpha(color_white, a * anim), TEXT_ALIGN_CENTER, 0, 1,  MSD.ColorAlpha(color_black, a * anim))

		if startt + 6 < CurTime() then
			anim = Lerp(FrameTime() * 3, anim, 0)
		else
			anim = Lerp(FrameTime() * 3, anim, 1)
		end

		if startt + 7 < CurTime() then
			MQS.TrackPlayer = function() end
		end
	end
end

function MQS.PendingQuest(x, y, right, bottom)
	local q = MQS.HasQuest()
	if q or not (not MQS.Config.IntoQuestAutogive and MQS.CanPlayIntro(ply)) then return end
	local qw = MQS.Quests[MQS.Config.IntoQuest]

	if MQS.Config.UI.HUDBG == 1 then
		MSD.DrawTexturedRect(right and x - wm - 75 or x - 25, bottom and y - 55 or y - 10, wm + 100, 65, right and MSD.Materials.gradient_right or MSD.Materials.gradient, MSD.Theme["m"])
		MSD.DrawTexturedRect(right and x - wm - 75 or x - 25, bottom and y - 107 or y + 55, wm + 100, 52, right and MSD.Materials.gradient_right or MSD.Materials.gradient, MSD.Theme["d"])
	end

	if MQS.Config.UI.HUDBG == 2 then
		draw.RoundedBox(8, right and x - wm - 80 or x - 10, bottom and y - 55 or y - 10, wm + 90, 65, MSD.Theme["d"])
		draw.RoundedBox(8, right and x - w3 - 10 or x - 10, bottom and y - 80 or y + 55, w3 + 20, 25, MSD.Theme["m"])
	end

	MSD.DrawTexturedRect(right and x - 48 or x, bottom and y - 48 or y, 48, 48, qw.custom_icon and MSD.ImgLib.GetMaterial(qw.custom_icon) or info_icon, color_white)

	local tw = draw.SimpleTextOutlined(qw.desc, "MSDFont.28", right and x - 55 or x + 55, bottom and y - 38 or y + 10, color_white, right and TEXT_ALIGN_RIGHT or TEXT_ALIGN_LEFT, 0, 1, color_black)
	local tw2 = draw.SimpleTextOutlined(MSD.GetPhrase("into_quest_start", string.upper(input.GetKeyName(MQS.Config.StopKey))), "MSDFont.25", right and x - 70 - tw or x + 70 + tw, bottom and y - 36 or y + 12, icon_color, right and TEXT_ALIGN_RIGHT or TEXT_ALIGN_LEFT, 0, 1, color_black)
	if MQS.KeyHOLD then
		draw.RoundedBox(2, right and x - 70 - tw or x + 70 + tw, bottom and y - 36 or y + 42, tw2 * ((MQS.KeyHOLD - CurTime()) / 2), 5, icon_color)
	end
end

function MQS.DrawQuestInfo(x, y, right, bottom)
	local q = MQS.HasQuest()
	local string_add = ""
	local time = ""
	if not q or not IsValid(ply) then return end
	local obj = MQS.GetNWdata(ply, "quest_objective")
	if not obj then return end
	obj = MQS.Quests[q.quest].objects[obj]

	if MQS.Config.UI.HUDBG == 1 then
		MSD.DrawTexturedRect(right and x - wm - 75 or x - 25, bottom and y - 55 or y - 10, wm + 100, 65, right and MSD.Materials.gradient_right or MSD.Materials.gradient, MSD.Theme["m"])
		MSD.DrawTexturedRect(right and x - wm - 75 or x - 25, bottom and y - 107 or y + 55, wm + 100, 52, right and MSD.Materials.gradient_right or MSD.Materials.gradient, MSD.Theme["d"])
	end

	if MQS.Config.UI.HUDBG == 2 then
		draw.RoundedBox(8, right and x - wm - 80 or x - 10, bottom and y - 55 or y - 10, wm + 90, 65, MSD.Theme["d"])
		draw.RoundedBox(8, right and x - w3 - 10 or x - 10, bottom and y - 80 or y + 55, w3 + 20, 25, MSD.Theme["m"])
	end

	MSD.DrawTexturedRect(right and x - 48 or x, bottom and y - 48 or y, 48, 48, MQS.Quests[q.quest].custom_icon and MSD.ImgLib.GetMaterial(MQS.Quests[q.quest].custom_icon) or info_icon, color_white)

	if MQS.GetNWdata(ply, "do_time") then
		time = ". " .. MSD.GetPhrase("q_time_left") .. " - " .. os.date("%M:%S", MQS.GetNWdata(ply, "do_time") - CurTime())
	end

	w1 = draw.SimpleTextOutlined(MSD.GetPhrase("q_in_progress") .. time, "MSDFont.28", right and x - 55 or x + 55, bottom and y - 38 or y + 10, color_white, right and TEXT_ALIGN_RIGHT or TEXT_ALIGN_LEFT, 0, 1, color_black)

	if MQS.Quests[q.quest].stop_anytime or (MQS.GetNWdata(ply, "loops") and not MQS.Quests[q.quest].reward_on_time and MQS.GetNWdata(ply, "loops") > 0) then
		w2 = draw.SimpleTextOutlined(MSD.GetPhrase("q_hold_key_stop", string.upper(input.GetKeyName(MQS.Config.StopKey))), "MSDFont.25", right and x - 70 - w1 or x + 70 + w1, bottom and y - 36 or y + 12, icon_color, right and TEXT_ALIGN_RIGHT or TEXT_ALIGN_LEFT, 0, 1, color_black)

		if MQS.KeyHOLD then
			draw.RoundedBox(2, right and x - 70 - w1 or x + 70 + w1, bottom and y - 36 or y + 42, w2 * ((MQS.KeyHOLD - CurTime()) / 2), 5, icon_color)
		end
	end

	if objective_text[obj.type] then
		string_add = " " .. objective_text[obj.type](q, obj)
	end

	local vehicle = MQS.ActiveTask[q.id].vehicle and Entity(MQS.ActiveTask[q.id].vehicle)

	if IsValid(vehicle) and MQS.GetActiveVehicle(ply) ~= vehicle and vehicle_req_task[obj.type] and not obj.ignore_veh then
		w3 = draw.SimpleTextOutlined("- " .. MSD.GetPhrase("q_enter_veh"), "MSDFont.22", x, bottom and y - 80 or y + 55, color_white, right and TEXT_ALIGN_RIGHT or TEXT_ALIGN_LEFT, 0, 1, color_black)
		objective_draw["Enter vehicle"](vehicle)
	else
		w3 = draw.SimpleTextOutlined("- " .. obj.desc .. string_add, "MSDFont.22", x, bottom and y - 80 or y + 55, color_white, right and TEXT_ALIGN_RIGHT or TEXT_ALIGN_LEFT, 0, 1, color_black)

		if objective_draw[obj.type] then
			objective_draw[obj.type](q, obj, x, y, right, bottom)
		end
	end

	wm = math.max(w1 + w2, w3)
end

local fix

function MQS.EntInfo()
	local ent = LocalPlayer():GetEyeTrace().Entity

	if not IsValid(ent) or ent:GetClass() ~= "mqs_ent" then return end

	if not ent:GetUseHold() or ent:GetTPly() ~= LocalPlayer() then
		ent = fix
		if not IsValid(fix) or LocalPlayer() ~= ent:GetTPly() then
			return
		end
	end

	local ent_p = ent:GetPickProgress()

	if ent_p and ent_p > 0 then
		local x, y = ScrW() / 2, ScrH() / 2 + 100
		local wd = draw.SimpleTextOutlined(MSD.GetPhrase("hold_use", string.upper(input.LookupBinding("+use"))), "MSDFont.25", x, y, color_white, TEXT_ALIGN_CENTER, 0, 1,color_black)
		local pr =  wd * ent_p
		draw.RoundedBox(2, (x - wd / 2) - 1, y + 24, wd + 2, 7, color_black)
		draw.RoundedBox(2, x - wd / 2, y + 25, pr, 5, icon_color)
	end
end

net.Receive("MQS.FixPickUP", function()
	fix = net.ReadEntity()
end)