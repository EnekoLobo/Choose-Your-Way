-- ╔═╗╔═╦═══╦═══╗───────────────────────
-- ║║╚╝║║╔═╗║╔═╗║───────────────────────
-- ║╔╗╔╗║║─║║╚══╗───────────────────────
-- ║║║║║║║─║╠══╗║──By MacTavish <3──────
-- ║║║║║║╚═╝║╚═╝║───────────────────────
-- ╚╝╚╝╚╩══╗╠═══╝───────────────────────
-- ────────╚╝───────────────────────────
local ply = LocalPlayer()
local AlphaMask = Color(0, 0, 0, 0)
local icon_color = Color(241, 200, 0)
local n_loop = 0
local scrw, scrh = ScrW(), ScrH()
local scrw_10 = scrw / 10
local time_precc = nil

local cam_effect, cam_newdata, cam_inprogress = 2, false, nil

MQS.UIEffect = {}
MQS.CCList = {}
MQS.NPCPositions = {}

MQS.UIEffect["Cinematic camera"] = function(data)
	data.cam_speed = data.cam_speed / 10
	data.fov_speed = data.fov_speed / 10

	table.insert(MQS.CCList, data)

	cam_newdata = true
end

MQS.UIEffect["Quest End"] = function(data)
	if MQS.Music and ply:UserID() == data.uid then
		MQS.Music:Stop()
		MQS.Music = nil
	end
	if timer.Exists("MQS.PlayerTracker" .. data.id) then
		timer.Remove("MQS.PlayerTracker" .. data.id)
	end
end

MQS.UIEffect["Music"] = function(data)
	if MQS.Music then
		MQS.Music:Stop()
		MQS.Music = nil
	end

	local url = false
	local soundpath = data.path
	if soundpath == "" then return end

	if string.StartWith(soundpath, "http") then
		url = true
	end

	if not string.StartWith(soundpath, "sound/") and not url then
		soundpath = "sound/" .. soundpath
	end

	if url then
		sound.PlayURL(soundpath, "noplay", function(station)
			if (IsValid(station)) then
				MQS.Music = station
				MQS.Music:Play()
			else
				LocalPlayer():ChatPrint("[MQS] Invalid sound URL", soundpath)
			end
		end)
	else
		sound.PlayFile(soundpath, "noplay", function(station, errCode, errStr)
			if (IsValid(station)) then
				MQS.Music = station
				MQS.Music:Play()
			else
				print("[MQS] Error playing sound", soundpath, errCode, errStr)
			end
		end)
	end
end

MQS.UIEffect["UnTrack"] = function(data)
	if timer.Exists("MQS.PlayerTracker" .. data.id) then
		timer.Remove("MQS.PlayerTracker" .. data.id)
	end
end

MQS.UIEffect["Track"] = function(data)
	local rply = Player(data.uid)
	local icon = MSD.PinPoints[data.icon or 0]
	local text = data.text
	local teams = data.teams

	MQS.DoNotify(MSD.GetPhrase("warning"), text, 4)

	timer.Create("MQS.PlayerTracker" .. data.id, 7, 0, function()
		if not IsValid(rply) or not teams[team.GetName(ply:Team())] then timer.Remove("MQS.PlayerTracker" .. data.id) return end
		MQS.UdpateTracking(rply:GetPos(), icon)
	end)
end

MQS.UIEffect["NPCPosition"] = function(data)
	MQS.NPCPositions[data.id] = data.pos
end

local function UpdateCam(cid)
	cam_newdata = false

	if not MQS.CCList[cid] then
		MQS.CCList = {}
		cam_newdata, cam_inprogress = false, nil
		timer.Simple(1, function()
			MQS.CCameraData = nil
			MQS.CCam = nil
		end)
		return
	end

	local data = MQS.CCList[cid]

	local function camProcess()
		if data.effect then cam_effect = 1 else cam_effect = 2 end
		MQS.CCameraData = data
		MQS.CCameraData.starttime = CurTime()

		local cd, bn = MQS.TableCompress({name = "Cinematic camera", pos = data.cam_start.pos, time = data.endtime})

		net.Start("MQS.UIEffect")
			net.WriteInt(bn, 32)
			net.WriteData(cd, bn)
		net.SendToServer()
	end

	if data.delay then
		timer.Simple(tonumber(data.delay) or 1,camProcess)
		timer.Simple(0.9, function()
			MQS.CCameraData = nil
			MQS.CCam = nil
		end)
	else
		camProcess()
	end
end

function MQS.HudNotification() end

function MQS.HudTaskNotify() end

function MQS.HudHint() end

function MQS.TrackPlayer() end

function MQS.HUDPaint()
	MQS.HudNotification()
	MQS.HudTaskNotify()
	MQS.HudHint()
	MQS.TrackPlayer()
	MQS.EntInfo()
	local x, y, of1, of2 = 25 + (scrw * MQS.Config.UI.HudOffsetX), 25 + (scrh * MQS.Config.UI.HudOffsetY), false, false

	if MQS.Config.UI.HudAlignX then
		x = scrw - 25 - (scrw * MQS.Config.UI.HudOffsetX)
		of1 = true
	end

	if MQS.Config.UI.HudAlignY then
		y = scrh - 25 - (scrw * MQS.Config.UI.HudOffsetY)
		of2 = true
	end

	MQS.DrawQuestInfo(x, y, of1, of2)
	MQS.PendingQuest(x, y, of1, of2)
end

function MQS.Draw3DZone(pos, rad, clr, detail, thicc)
	render.SetStencilEnable(true)
	render.SetStencilWriteMask( 0xFF )
	render.SetStencilTestMask( 0xFF )
	render.SetStencilReferenceValue( 0 )
	render.SetStencilCompareFunction( STENCIL_ALWAYS )
	render.SetStencilPassOperation( STENCIL_KEEP )
	render.SetStencilFailOperation( STENCIL_KEEP )
	render.SetStencilZFailOperation( STENCIL_KEEP )
	render.SetColorMaterial()
	render.ClearStencil()
	--All
	render.SetStencilReferenceValue(7)
	render.SetStencilZFailOperation(STENCILOPERATION_REPLACE)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
	render.DrawSphere(pos, -rad, detail, detail, AlphaMask)
	--Under
	render.SetStencilReferenceValue(7)
	render.SetStencilZFailOperation(STENCILOPERATION_DECR)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
	render.DrawSphere(pos, rad, detail, detail, AlphaMask)
	--Inner
	render.SetStencilReferenceValue(7)
	render.SetStencilZFailOperation(STENCILOPERATION_INCR)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
	render.DrawSphere(pos, -math.max(rad - thicc, 0), detail, detail, AlphaMask)
	render.SetStencilZFailOperation(STENCILOPERATION_DECR)
	-- Overall
	render.SetStencilReferenceValue(7)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
	render.DrawSphere(pos, math.max(rad - thicc, 0), detail, detail, AlphaMask)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)

	cam.IgnoreZ(true)
	render.SetStencilReferenceValue(7)
	render.DrawSphere(pos, rad + thicc, detail, detail, clr)
	render.DrawSphere(pos, -rad, detail, detail, clr)
	cam.IgnoreZ(false)
	render.SetStencilEnable(false)
end

hook.Add("HUDPaint", "MQS.HUDPaint", MQS.HUDPaint)

hook.Add("DrawOverlay", "MQS.DrawOverlay", function()
	if MQS.CCam then
		if MQS.Config.CamFix then
			cam.Start2D()
				render.RenderView({
					origin = MQS.CCam.pos,
					angles = MQS.CCam.ang,
					fov = MQS.CCam.fov,
					drawviewmodel = false,
					drawhud = false,
					x = 0,
					y = 0,
					w = ScrW(),
					h = ScrH()
				})
			cam.End2D()
		end
		draw.RoundedBox(0, 0, 0, scrw, scrh / 10, color_black)
		draw.RoundedBox(0, 0, scrh - scrh / 10, scrw, scrh / 10, color_black)
		if not MQS.PreCC then
			draw.SimpleTextOutlined(MQS.CCameraData.text, "MSDFont.Big", scrw / 2, scrh - scrh / 10 + 10, icon_color, TEXT_ALIGN_CENTER, 0, 1, color_black)
		end
	end

	if MQS.PreCC then
		if not time_precc then
			time_precc = CurTime() + 1
		end

		if cam_effect == 1 then
			for i = 0, scrw_10 - 1 do
				draw.RoundedBox(0, scrw_10 * i, 0, MQS.PreCC * (scrw_10 + 20), scrh, color_black)
			end
		else
			draw.RoundedBox(0, 0, 0, scrw, scrh, MSD.ColorAlpha(color_black, MQS.PreCC * 260))
		end

		if time_precc > CurTime() then
			MQS.PreCC = Lerp(FrameTime() * 5, MQS.PreCC, 1)
		else
			MQS.PreCC = Lerp(FrameTime() * 5, MQS.PreCC, 0)

			if MQS.PreCC < 0.01 then
				MQS.PreCC = nil
				time_precc = nil
			end
		end
	end
end)

hook.Add("Think", "MQS.ProcessClient", function()
	if n_loop < CurTime() and MQS.HasQuest() then
		local q = MQS.HasQuest()
		if MQS.Quests[q.quest].stop_anytime or (MQS.GetNWdata(ply, "loops") and not MQS.Quests[q.quest].reward_on_time and MQS.GetNWdata(ply, "loops") > 0) then
			if input.IsKeyDown(MQS.Config.StopKey) then
				if not MQS.KeyHOLD then
					MQS.KeyHOLD = CurTime() + 2
				elseif MQS.KeyHOLD < CurTime() then
					MQS.KeyHOLD = nil
					n_loop = CurTime() + 5
					RunConsoleCommand("mqs_stop")
				end
			else
				MQS.KeyHOLD = nil
			end
		end
	end

	if not MQS.HasQuest() and not MQS.Config.IntoQuestAutogive and MQS.CanPlayIntro(ply) then
		if input.IsKeyDown(MQS.Config.StopKey) then
			if not MQS.KeyHOLD then
				MQS.KeyHOLD = CurTime() + 2
			elseif MQS.KeyHOLD < CurTime() then
				MQS.KeyHOLD = nil
				n_loop = CurTime() + 5
				RunConsoleCommand("mqs_start", MQS.Config.IntoQuest)
			end
		else
			MQS.KeyHOLD = nil
		end
	end

	if cam_newdata and not cam_inprogress then
		cam_newdata = false
		cam_inprogress = 1
		UpdateCam(1)
	end

	if MQS.CCameraData then
		local cc = MQS.CCameraData
		local CT = CurTime()

		if cc.starttime + 1 > CT then
			if not MQS.PreCC then
				MQS.PreCC = 0
			end

			return
		end

		cc.cam_start.pos = LerpVector(FrameTime() * cc.cam_speed, cc.cam_start.pos, cc.cam_end.pos)
		cc.cam_start.ang = LerpAngle(FrameTime() * cc.cam_speed, cc.cam_start.ang, cc.cam_end.ang)
		cc.cam_start.fov = Lerp(FrameTime() * cc.fov_speed, cc.cam_start.fov, cc.cam_end.fov)

		MQS.CCam = {
			pos = cc.cam_start.pos,
			ang = cc.cam_start.ang,
			fov = cc.cam_start.fov,
		}

		if cc.endtime and cc.endtime + cc.starttime < CT then
			cc.endtime = nil

			if not MQS.PreCC then
				MQS.PreCC = 0
			end

			cam_inprogress = cam_inprogress + 1
			UpdateCam(cam_inprogress)

		end
	end
end)

hook.Add("HUDShouldDraw", "MQS.HUDShouldDraINTRO", function(name)
	if MQS.CCam then return false end
end)

hook.Add("CalcView", "MQS.GetCamData", function(_, pos, angles, fov)
	if MQS.CCam and not MQS.Config.CamFix then
		local view = {
			origin = MQS.CCam.pos,
			angles = MQS.CCam.ang,
			fov = MQS.CCam.fov,
			drawviewer = true
		}

		return view
	end
end)

hook.Add("PostDrawTranslucentRenderables", "MQS.PostDrawTranslucentRenderables", function()
	local q = MQS.HasQuest()

	if not q then return end


	local obj = MQS.GetNWdata(ply, "quest_objective")
	obj = MQS.Quests[q.quest].objects[obj]
	if not obj.mark_area or not obj.point then return end
	if obj.point:DistToSqr(LocalPlayer():GetPos()) > (MQS.Config.QuestEntDrawDist * 5) ^ 2 then return end
	local dist = obj.dist or obj.stay_inarea or 350
	MQS.Draw3DZone(obj.point, dist, icon_color, 50, 5)
end)

net.Receive("MQS.UIEffect", function()
	local ef_name = net.ReadString()
	local ef_data = net.ReadTable()
	if MQS.UIEffect[ef_name] then
		MQS.UIEffect[ef_name](ef_data)
	end
end)

net.Receive("MQS.TaskNotify", function()
	local text = net.ReadString()
	local type = net.ReadInt(16)
	MQS.DoTaskNotify(text, type)
end)

net.Receive("MQS.Notify", function()
	local text1 = net.ReadString()
	local text2 = net.ReadString()
	local type = net.ReadInt(16)
	MQS.DoNotify(text1, text2, type)
end)