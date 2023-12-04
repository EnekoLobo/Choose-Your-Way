--  _______               __          _______  __                   __          _______  ______  ______        
-- |   |   |.---.-..----.|  |.-----. |     __||__|.--------..-----.|  |.-----. |    |  ||   __ \|      |.-----.
-- |       ||  _  ||  __| |_||__ --| |__     ||  ||        ||  _  ||  ||  -__| |       ||    __/|   ---||__ --|
-- |__|_|__||___._||____|    |_____| |_______||__||__|__|__||   __||__||_____| |__|____||___|   |______||_____|
--                                                          |__|                                               
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////
--/////////////////////// Warning! Edit this only if you know what are you doing ///////////////////////////////
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////
local defnpc = {
	uid = "uid",
	name = "Alyx",
	model = "models/alyx.mdl",
	questNPC = false,
	pos = {
		["all"] = {Vector(0, 0, 0), Angle(0, 0, 0)}
	},
	bgr = {},
	skin = 0,
	scale = 1,
	uselimit = false,
	theme = "Default",
	namepos = 80,
	sequence = "",
	CLModels = "",
	dialogs = {}
}
local modulid = 0
local defclm = {
	model = "models/player/items/humans/top_hat.mdl",
	marge = true
}

local Ln = MSD.GetPhrase
local localnpc = table.Copy(defnpc)
MCS.PanelControll = {}

MCS.PanelControll.AnimationMenu = function(parent, te, ent, setanim)
	if IsValid(MCS.AnimationMenu) then MCS.AnimationMenu:Close() end
	local mx, my = gui.MousePos()
	local frame = vgui.Create("MSDSimpleFrame", parent)
	frame:SetSize(400, 600)
	frame:SetPos(mx - 400, my)
	frame:SetDraggable(true)
	frame:MakePopup()
	frame.Paint = function(self, w, h)
		MSD.DrawBG(self, w, h)
	end
	frame.Think = function(self)
		if not IsValid(parent) then
			self:Close()
		end
	end

	frame.clsBut = MSD.IconButton(frame, MSD.Icons48.cross, frame:GetWide() - 34, 1, 25, nil, MSD.Config.MainColor.p, function()
		frame:Close()
	end)

		-- if file.Exists("mac_npc/autosave.txt", "DATA") then
		-- 	jsontable = file.Read("mac_npc/autosave.txt", "DATA")
		-- 	localnpc = util.JSONToTable(jsontable)
		-- end

	local AnimList = vgui.Create("MSDPanelList", frame)
	AnimList:SetSize(390, 540)
	AnimList:SetPos(5, 40)
	AnimList:EnableVerticalScrollbar()
	AnimList.IgnoreVbar = false

	MSD.TextEntry(frame, 5, 5, 350, 35, "Search", "", "", function(self, value)
		AnimList.Search(string.lower(value))
	end, true)

	local seq_list = ent:GetSequenceList() or {}

	AnimList.Search = function(val)
		AnimList:Clear()
		for k, v in pairs(seq_list) do
			local seq = string.lower(v)
			if val and not string.find(seq, val) then continue end
			local but = MSD.ButtonSimple(AnimList, nil, nil, 300, 25, seq, 16, function()
				if te then
					te:SetValue(seq)
				end

				if setanim then
					ent:ResetSequence(seq)
					ent:SetCycle(0)
					localnpc.sequence = seq
				end
			end)

			but.Check = function()
				if localnpc.sequence == seq then
					return true
				end
				return false
			end

			if localnpc.sequence == seq then
				but.hover = true
				AnimList:ScrollToChild(but)
			end
		end
	end

	AnimList.Search()

	MCS.AnimationMenu = frame
	return frame
end

MCS.PanelControll.FileOpen = function(parent, func)
	local mx, my = gui.MousePos()
	local frame = vgui.Create("DFrame")
	frame:SetSize(300, 400)
	frame:SetPos(mx, my)
	frame:MakePopup()
	frame:SetTitle("File List")
	frame.StartT = CurTime() + 2

	frame.Think = function(self)
		if not IsValid(parent) or (not self:HasFocus() and self.StartT < CurTime()) then
			self:Close()
		end
	end

	local FileList = vgui.Create("DListView", frame)
	FileList:AddColumn("File name")
	FileList:Dock(FILL)
	FileList:SetMultiSelect(false)
	FileList:SetHideHeaders(false)
	local files = file.Find("mac_npc/*", "DATA")

	for k, v in pairs(files) do
		local line = FileList:AddLine(v)

		line.OnSelect = function()
			jsontable = file.Read("mac_npc/" .. v, "DATA")
			localnpc = util.JSONToTable(jsontable)
			frame:Close()
			func()
		end
	end

	return frame
end

net.Receive("MCS.SetupMenu", function()
	if not LocalPlayer():IsSuperAdmin() then return end
	MSD.OpenMenuManager(nil, modulid)
end)

function MSD.OpenAdminMenu(panel, mainPanel)
	if not panel then return end

	local function AutoSave()
		file.Write("mac_npc/autosave.txt", util.TableToJSON(localnpc))
	end

	if not file.Exists("mac_npc", "DATA") then
		file.CreateDir("mac_npc")
	end

	if file.Exists("mac_npc/autosave.txt", "DATA") then
		jsontable = file.Read("mac_npc/autosave.txt", "DATA")
		localnpc = util.JSONToTable(jsontable)
	end

	function mainPanel.ModuleSwitch()
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

	local buttons = {}

	buttons[1] = {
		"NPC setup", MSD.Icons48.account, function()
			openPage("npc", true)
		end,
		true
	}

	buttons[2] = {
		"Model setup", MSD.Icons48.box, function()
			openPage("model", true)
		end
	}

	buttons[3] = {
		"Dialogue setup", MSD.Icons48.layers, function()
			openPage("dialog", true)
		end
	}

	buttons[4] = {
		"Final setup", MSD.Icons48.submit, function()
			openPage("final", true)
		end
	}

	buttons[5] = {
		Ln("settings"), MSD.Icons48.cog, function()
			openPage("settings", true)
		end
	}

	panel.Menu = vgui.Create("MSDPanelList", panel)
	panel.Menu:SetSize(250, panel:GetTall())
	panel.Menu:SetPos(0, 0)
	panel.Menu:EnableVerticalScrollbar()
	panel.Menu:EnableHorizontal(false)
	panel.Menu:SetSpacing(0)
	panel.Menu.IgnoreVbar = true

	panel.Menu.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, MSD.Theme["l"])
	end

	panel.Menu.Deselect = function(but)
		but.hovered = true

		for k, v in pairs(panel.Menu:GetItems()) do
			if v and v:IsValid() and v ~= but then
				v.hovered = false
			end
		end
	end

	local MainM = panel
	localnpc.oldid = localnpc.uid

	pages["npc"] = function()
		panel.Canvas:Clear()
		MSD.Header(panel.Canvas, "NPC Editor")

		MSD.TextEntry(panel.Canvas, "static", nil, 1, 50, "Enter npc name", "NPC name: (NPC's name will be shown to players above the NPC and via the dialogue.)", localnpc.name, function(self, value)
			localnpc.name = value
		end, true)

		MSD.TextEntry(panel.Canvas, "static", nil, 1, 50, "Enter NPC ID", "Unique name: (Unique name must be UNIQUE. Two or more NPCs with identical unique name will not work.)", localnpc.uid, function(self, value)
			if value == "" or value == " " then
				self.error = "Enter the ID"

				return
			end

			localnpc.uid = value

			if MCS.Spawns[value] and localnpc.oldid ~= value then
				self.error = "ID must be unique for each NPC"

				return
			end

			self.error = nil
		end, true)

		MSD.TextEntry(panel.Canvas, "static", nil, MQS and 2 or 1, 50, "Leave blank to use default value", "NPC's name position: (NPC's name position can be useful if you use bigger or smaller model than the standat player models.)", localnpc.namepos, function(self, value)
			localnpc.namepos = tonumber(value) or 77
		end, true, nil, nil, true)

		if MQS then
			MSD.BoolSlider(panel.Canvas, "static", nil, 2, 50, "[MQS] Use this NPC for the quest system", localnpc.questNPC or false, function(self, value)
				localnpc.questNPC = value
			end)
		end

		MSD.BoolSlider(panel.Canvas, "static", nil, 2, 50, "Allow only one player to speak to the npc at the same time", localnpc.uselimit or false, function(self, value)
			localnpc.uselimit = value
		end)

		local combo = MSD.ComboBox(panel.Canvas, "static", nil, 2, 50, "UI theme:", localnpc.theme or "Default")
		combo.OnSelect = function(_, _, value)
			localnpc.theme = value
		end

		for k, v in pairs(MCS.Themes) do
			combo:AddChoice(k)
		end

		local map = string.lower(game.GetMap())

		if not localnpc.pos[map] then
			localnpc.pos[map] = {Vector(0, 0, 0), Angle(0, 0, 0)}
		end

		local data = localnpc.pos[map]
		local vecd = MSD.VectorDisplay(panel.Canvas, "static", nil, 1, 50, "Spawn point", data[1])
		local amgl = MSD.AngleDisplay(panel.Canvas, "static", nil, 1, 50, "Spawn angle", data[2])

		MSD.Button(panel.Canvas, "static", nil, 3, 50, "Set to your position", function()
			local vec = LocalPlayer():GetPos()
			vecd.vector = vec
			data[1] = vec
			local ang = Angle(0, LocalPlayer():GetAngles().y, 0)
			amgl.angle = ang
			data[2] = ang
		end)

		MSD.Button(panel.Canvas, "static", nil, 3, 50, "Set to looking poit", function()
			local vec = LocalPlayer():GetEyeTrace().HitPos
			if not vec then return end
			vecd.vector = vec
			data[1] = vec
			local ang = Angle(0, LocalPlayer():GetAngles().y, 0)
			amgl.angle = ang
			data[2] = ang
		end)

		MSD.Button(panel.Canvas, "static", nil, 3, 50, "Copy from looking entity", function()
			local vec = LocalPlayer():GetEyeTrace().Entity
			if not vec then return end
			local ang = vec:GetAngles()
			amgl.angle = ang
			data[2] = ang
			vec = vec:GetPos()
			vecd.vector = vec
			data[1] = vec
		end)
	end

	pages["model"] = function()
		if not localnpc.model then
			localnpc.model = "models/Humans/Group01/Male_01.mdl"
		end

		panel.Canvas:Clear()
		MSD.Header(panel.Canvas, "Model Editor")

		local ops_panel = vgui.Create("DPanel")
		ops_panel:SetSize(panel.Canvas:GetWide(), panel.Canvas:GetTall() - 52)
		ops_panel.Paint = function(self, w, h)
			draw.RoundedBox(MSD.Config.Rounded, 0, 0, w / 2 - 2, h, MSD.Theme["l"])
			draw.RoundedBox(MSD.Config.Rounded, w / 2, 0, w / 2 - 2, h, MSD.Theme["l"])
		end

		local model_panel, set_list
		set_list = vgui.Create("MSDPanelList", ops_panel)
		set_list:SetSize(ops_panel:GetWide() / 2 - 2, ops_panel:GetTall())
		set_list:SetPos(0, 0)
		set_list:EnableVerticalScrollbar()
		set_list:EnableHorizontal(true)
		set_list:SetSpacing(2)
		set_list:SetPadding(0)
		set_list.IgnoreVbar = true

		local updatemdl = function(value)
			if value == "" then return end
			model_panel:SetModel(value)
			if model_panel.Entity then
				model_panel.Entity:ResetSequence("idle")
				model_panel.Entity:SetPos(Vector(-100, 0, -61))
			end
			animation:SetText("idle")
			localnpc.model = value
			localnpc.skin = 1
			localnpc.bgr = {}

			model_panel.Update(true)
		end

		set_list.MainMenu = function()
			set_list:Clear()

			MSD.InfoHeader(set_list, "Drag model to rotate, double click to zoom")

			local mdl = MSD.TextEntry(set_list, "static", nil, 1.5, 50, "Enter model path", "NPC model:", localnpc.model, function(self, value)
				updatemdl(value)
			end, true)

			MSD.Button(set_list, "static", nil, 3, 50, "Copy from looking entity", function()
				local md = LocalPlayer():GetEyeTrace().Entity
				if not md then return end
				md = md:GetModel()
				mdl:SetText(md)
				updatemdl(md)
			end)

			animation = MSD.TextEntry(set_list, "static", nil, 1.5, 50, "Enter animation name", "NPC animation:", localnpc.sequence or "idle", function(self, value)
				local iSeq = model_panel.Entity:LookupSequence(value)
				if (iSeq > 0) then
					model_panel.Entity:ResetSequence(iSeq)
				end
				localnpc.sequence = string.lower(value)
			end, true)

			MSD.Button(set_list, "static", nil, 3, 50, "Get animations", function()
				MCS.PanelControll.AnimationMenu(panel, animation, model_panel.Entity, true)
			end)

			MSD.BoolSlider(set_list, "static", nil, 1, 50, "Make NPC invisible", localnpc.invisible, function(self, value)
				localnpc.invisible = value
			end)

			MSD.VolumeScale(set_list, "static", nil, 1, 50, "NPC Model Scale", localnpc.scale or 1, function(self, var)
				localnpc.scale = var
			end)

			MSD.BigButton(set_list, "static", nil, 1, 80, "Body Groups", MSD.Icons48.account_edit, function()
				set_list.BodyGroups()
			end)

			MSD.BigButton(set_list, "static", nil, 1, 80, "Cosmetics", MSD.Icons48.box, function()
				set_list.Cosmetics()
			end)
		end

		set_list.BodyGroups = function()
			set_list:Clear()
			MSD.Header(set_list, "Body Groups", function()
				set_list.MainMenu()
			end)

			local nskins = model_panel.Entity:SkinCount() - 1

			if (nskins > 0) then
				MSD.InfoHeader(set_list, "Skin")

				MSD.NumberWang(set_list, "static", nil, 1, 50, 0, nskins, localnpc.skin or 1, "Skin", function(self)
					model_panel.Entity:SetSkin(self:GetValue())
					localnpc.skin = self:GetValue()
				end)
			end

			local hrd

			for k = 0, model_panel.Entity:GetNumBodyGroups() - 1 do
				if (model_panel.Entity:GetBodygroupCount(k) <= 1) then continue end

				if not hrd then
					hrd = MSD.InfoHeader(set_list, "Body Groups")
				end

				MSD.NumberWang(set_list, "static", nil, 2, 50, 0, model_panel.Entity:GetBodygroupCount(k) - 1, localnpc.bgr[k] or 0, model_panel.Entity:GetBodygroupName(k), function(self)
					model_panel.Entity:SetBodygroup(k, self:GetValue())
					localnpc.bgr[k] = self:GetValue()
				end)
			end
		end

		set_list.MainMenu()

		model_panel = vgui.Create("MSDModelPanel", ops_panel)
		model_panel:SetSize(ops_panel:GetWide() / 2 - 2, ops_panel:GetTall())
		model_panel:SetPos(ops_panel:GetWide() / 2, 0)
		model_panel:SetModel(localnpc.model)
		model_panel.Entity:ResetSequence(localnpc.sequence or "idle")
		model_panel.Entity:SetPos(Vector(-100, 0, -61))

		model_panel.CreateItem = function(model, k, data)

			model_panel.SubEntitys[k] = ClientsideModel( model, RENDERGROUP_OTHER )
			model_panel.SubEntitys[k]:SetNoDraw( true )
			model_panel.SubEntitys[k]:SetParent(model_panel.Entity)

			if data.marge then
				model_panel.SubEntitys[k]:AddEffects(EF_BONEMERGE)
				model_panel.SubEntitys[k]:AddEffects(EF_BONEMERGE_FASTCULL)
				model_panel.SubEntitys[k]:AddEffects(EF_PARENT_ANIMATES)
			else
				model_panel.SubEntitys[k]:SetPos(model_panel.Entity:GetPos() + data.pos)
				model_panel.SubEntitys[k]:SetAngles(model_panel.Entity:GetAngles() + data.ang)
				model_panel.SubEntitys[k].pos = data.pos
				model_panel.SubEntitys[k].ang = data.ang
				model_panel.SubEntitys[k].bone = data.bone
				-- local mat = Matrix()
				-- mat:Scale(Vector(data.scale,data.scale,data.scale))
				-- model_panel.SubEntitys[k]:EnableMatrix("RenderMultiply", mat)
			end

		end


		model_panel.Update = function(rmv)
			for k,v in pairs(model_panel.SubEntitys) do
				if IsValid(v) then
					v:Remove()
				end
			end
			if rmv then
				localnpc.ClModels = {}
				return
			end
			if localnpc.ClModels then
				for k, v in pairs(localnpc.ClModels) do
					model_panel.CreateItem(v.model, k, v)
				end
			end
		end

		set_list.Cosmetics = function()
			set_list:Clear()
			MSD.Header(set_list, "Cosmetics", function()
				set_list.MainMenu()
			end)

			MSD.BigButton(set_list, "static", nil, 1, 80, "Add cosmetics", MSD.Icons48.plus, function()
				if not localnpc.ClModels then localnpc.ClModels = {} end
				table.insert(localnpc.ClModels, table.Copy(defclm))
				model_panel.Update()
				set_list.Cosmetics()
			end)

			if not localnpc.ClModels then return end

			for k, v in pairs(localnpc.ClModels) do
				MSD.BigButton(set_list, "static", nil, 1, 80, v.model, MSD.Icons48.box, function()
					set_list.PropEdit(k, v)
				end, nil, nil, function(self)
					if (IsValid(self.Menu)) then self.Menu:Remove() self.Menu = nil end
					self.Menu = MSD.MenuOpen(false, self)
					self.Menu:AddOption(Ln("remove"), function()
						table.remove(localnpc.ClModels, k)
						set_list.Cosmetics()
					end)
					local x, y = self:LocalToScreen(0, self:GetTall())
					self.Menu:SetMinimumWidth(self:GetWide())
					self.Menu:Open(x, y, false, self)
				end)
			end
		end

		set_list.PropEdit = function(k, v)
			set_list:Clear()
			MSD.Header(set_list, "Cosmetic editor", function()
				set_list.Cosmetics()
			end)

			MSD.TextEntry(set_list, "static", nil, 1, 50, "Enter model path", "Model:", v.model, function(self, value)
				v.model = value
				if value == "" then return end
				if IsValid(model_panel.SubEntitys[k]) then
					model_panel.SubEntitys[k]:SetModel(value)
				end
			end, true)

			MSD.BoolSlider(set_list, "static", nil, 1, 50, "Enable BoneMarge effect", v.marge, function(self, value)
				v.marge = value
				if value then
					v.pos = nil
					v.ang = nil
					v.bone = nil
				else
					v.pos = Vector(0,0,0)
					v.ang = Angle(0,0,0)
					v.bone = 0
				end
				set_list.PropEdit(k, v)
				model_panel.Update()
			end)

			if v.marge then return end

			MSD.VectorDisplay(set_list, "static", nil, 1, 50, Ln("spawn_point"), v.pos, function() end)
			MSD.AngleDisplay(set_list, "static", nil, 1, 50, Ln("spawn_ang"), v.ang, function() end)

			local combo = MSD.ComboBox(set_list, "static", nil, 1, 50, "Attachment bone" .. ":", model_panel.Entity:GetBoneName( v.bone or 0 ))
			combo.OnSelect = function(self, index, text, data)
				v.bone = data
				model_panel.SubEntitys[k].bone = data
			end
			for i = 0, model_panel.Entity:GetBoneCount() - 1 do
				combo:AddChoice(model_panel.Entity:GetBoneName( i ), i)
			end

		end

		if localnpc.ClModels then
			for k, v in pairs(localnpc.ClModels) do
				model_panel.CreateItem(v.model, k, v)
			end
		end

		panel.Canvas:AddItem(ops_panel)
	end

	pages["dialog"] = function()
		panel.Canvas:Clear()
		MSD.Header(panel.Canvas, "Dialogue Editor")

		MSD.BigButton(panel.Canvas, "static", nil, 4, 120, "Add new line", MSD.Icons48.layers_plus, function()
			table.insert(localnpc.dialogs, {
				["Line"] = "",
				["Sound"] = "",
				["Answers"] = {
					{"", "close", nil, nil, ""}
				},
			})

			openPage("dialog")
		end)

		for k, v in pairs(localnpc.dialogs) do
			MSD.BigButton(panel.Canvas, "static", nil, 4, 120, "Dialog Line:" .. k, MSD.Icons48.layers, function()
				openPage("line_edit", true, k, v)
			end)
		end
	end

	pages["line_edit"] = function(k, v)
		MSD.Header(panel.Canvas, "Dialog like #" .. k, function()
			openPage("dialog", true)
		end)

		local ops_panel = vgui.Create("DPanel")
		ops_panel:SetSize(panel.Canvas:GetWide(), panel.Canvas:GetTall() - 52)

		ops_panel.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w / 2 - 2, h, MSD.Theme["l"])
			draw.RoundedBox(0, w / 2, 0, w / 2 - 2, h, MSD.Theme["l"])
			draw.DrawText(MSD.GetPhrase("Line options"), "MSDFont.25", 12, 12, color_white, TEXT_ALIGN_LEFT)
			draw.DrawText(MSD.GetPhrase("Answers"), "MSDFont.25", w / 2 + 12, 12, color_white, TEXT_ALIGN_LEFT)
		end

		local rwd_set, rwd_list
		rwd_list = vgui.Create("MSDPanelList", ops_panel)
		rwd_list:SetSize(ops_panel:GetWide() / 2, ops_panel:GetTall() - 52)
		rwd_list:SetPos(0, 52)
		rwd_list:EnableVerticalScrollbar()
		rwd_list:EnableHorizontal(true)
		rwd_list:SetSpacing(2)
		rwd_list:SetPadding(2)
		rwd_list.IgnoreVbar = true

		rwd_list.Populate = function()
			rwd_list:Clear()

			MSD.TextEntry(rwd_list, "static", nil, 1, 350, "Enter NPC speech line", nil, localnpc.dialogs[k]["Line"], function(self, value)
				localnpc.dialogs[k]["Line"] = value
			end, true, nil, true)

			MSD.TextEntry(rwd_list, "static", nil, 1, 50, "Enter sound path or URL", "Sound: (path or URL)", localnpc.dialogs[k]["Sound"], function(self, value)
				localnpc.dialogs[k]["Sound"] = value
			end, true)

			if k ~= 1 then
				MSD.BigButton(rwd_list, "static", nil, 1, 120, "Remove this dialogue line", MSD.Icons48.layers_remove, function()
					table.remove(localnpc.dialogs, k)
					openPage("dialog", true)
				end)
			end
		end

		rwd_set = vgui.Create("MSDPanelList", ops_panel)
		rwd_set:SetSize(ops_panel:GetWide() / 2 - 2, ops_panel:GetTall() - 52)
		rwd_set:SetPos(ops_panel:GetWide() / 2, 52)
		rwd_set:EnableVerticalScrollbar()
		rwd_set:EnableHorizontal(true)
		rwd_set:SetSpacing(2)
		rwd_set:SetPadding(2)
		rwd_set.IgnoreVbar = true
		rwd_set.MakeAnswer = function(c, a)
			MSD.InfoHeader(rwd_set, "Answer ID: " .. c)

			MSD.TextEntry(rwd_set, "static", nil, 1, 50, "Enter answer text", "Answer text:", a[1], function(self, value)
				a[1] = value
			end, true)

			MSD.Button(rwd_set, "static", nil, localnpc.uselimit and 3 or 2, 50, isnumber(a[2]) and "Open line: " .. a[2] or "Action: " .. a[2], function(self)
				local cdmenu = MSD.MenuOpen(false, self)

				for i = 1, #localnpc.dialogs do
					cdmenu:AddOption("#" .. i, function()
						a[2] = i
						self:SetText("Open line: " .. i)
					end)
				end

				cdmenu:AddOption("close", function()
					a[2] = "close"
					self:SetText("Action: close")
				end)

				local cdsub = cdmenu:AddSubMenu("Supportet addons:")

				for id, addon in pairs(MCS.AddonList) do
					if not addon["enabled"] or addon["hide"] then continue end
					cdsub:AddOption(id, function()
						a[2] = '"' .. id .. '"'
						self:SetText("Action: " .. a[2])
					end)
				end

				cdmenu:Open()
			end)

			if localnpc.uselimit then
				MSD.TextEntry(rwd_set, "static", nil, 3, 50, "Leave blank to disable", "Change animation:", a[5] or "", function(self, value)
					a[5] = value
				end, true)
			end

			MSD.Button(rwd_set, "static", nil, localnpc.uselimit and 3 or 2, 50, "Remove answer", function()
				table.remove(v["Answers"], c)
				rwd_set.Populate()
			end)
		end
		rwd_set.Populate = function()
			rwd_set:Clear()

			for c, a in pairs(v["Answers"]) do
				rwd_set.MakeAnswer(c, a)
			end

			MSD.BigButton(rwd_set, "static", nil, 1, 80, "Add answer line", MSD.Icons48.layers_plus, function()
				table.insert(v["Answers"], {"", "close"})

				rwd_set.Populate()
			end)
		end

		panel.Canvas:AddItem(ops_panel)
		rwd_list.Populate()
		rwd_set.Populate()
	end

	pages["final"] = function()
		MSD.Header(panel.Canvas, "Main options")

		MSD.BigButton(panel.Canvas, "static", nil, 2, 120, "Copy NPC Lua code", MSD.Icons48.copy, function()
			surface.PlaySound("mqs/done/1.mp3")
			RunConsoleCommand("mcs_generate")
		end)

		MSD.BigButton(panel.Canvas, "static", nil, 2, 120, "Save NPC preset", MSD.Icons48.save, function()
			surface.PlaySound("mqs/done/4.mp3")
			file.Write("mac_npc/" .. localnpc.uid .. ".txt", util.TableToJSON(localnpc))
		end)

		MSD.BigButton(panel.Canvas, "static", nil, 2, 120, "Open NPC preset", MSD.Icons48.folder_open, function()
			if not IsValid(oframe) then
				oframe = MCS.PanelControll.FileOpen(MainM, function()
					surface.PlaySound("mqs/done/1.mp3")
				end)
			end
		end)

		MSD.BigButton(panel.Canvas, "static", nil, 2, 120, "New NPC preset", MSD.Icons48.account_plus, function()
			surface.PlaySound("mqs/done/1.mp3")
			localnpc = table.Copy(defnpc)
		end)

		MSD.BigButton(panel.Canvas, "static", nil, 2, 120, "Test the dialogue", MSD.Icons48.calendar_check, function()
			if localnpc.theme and localnpc.theme ~= "Default" and MCS.Themes[localnpc.theme] then
				if MCS.Themes[localnpc.theme].Menu then
					MCS.Themes[localnpc.theme].Menu(nil, localnpc)
				elseif MCS.Themes[localnpc.theme].Paint then
					MCS.OpenDialogue(nil, localnpc.theme, localnpc)
				else
					MCS.OpenDialogue(nil, nil, localnpc)
				end
			else
				MCS.OpenDialogue(nil, nil, localnpc)
			end
		end)

		MSD.BigButton(panel.Canvas, "static", nil, 2, 120, "Respawn all NPCs", MSD.Icons48.account_convert, function()
			surface.PlaySound("mqs/done/1.mp3")
			RunConsoleCommand("mcs_npcrespawn")
		end)

		MSD.Header(panel.Canvas, "Help")

		MSD.BigButton(panel.Canvas, "static", nil, 2, 80, "Full documentation", MSD.Icons48.file_document, function()
			gui.OpenURL("http://info.macnco.one/books/macs-simple-npcs")
		end)

		MSD.BigButton(panel.Canvas, "static", nil, 2, 80, "Get support", MSD.Icons48.face_agent, function()
			gui.OpenURL("https://www.gmodstore.com/market/view/6696/")
		end)
	end

	pages["settings"] = function()
		local oldcfg = table.Copy(MCS.Config)
		MSD.Header(panel.Canvas, Ln("settings"))
		local ops_panel = vgui.Create("DPanel")
		ops_panel:SetSize(panel.Canvas:GetWide(), panel.Canvas:GetTall() - 135)

		ops_panel.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w / 2 - 2, h, MSD.Theme["l"])
			draw.RoundedBox(0, w / 2, 0, w / 2 - 2, h, MSD.Theme["l"])
		end

		local rwd_set, rwd_list
		rwd_list = vgui.Create("MSDPanelList", ops_panel)
		rwd_list:SetSize(ops_panel:GetWide() / 2, ops_panel:GetTall() - 2)
		rwd_list:SetPos(0, 2)
		rwd_list:EnableVerticalScrollbar()
		rwd_list:EnableHorizontal(true)
		rwd_list:SetSpacing(2)
		rwd_list:SetPadding(2)
		rwd_list.IgnoreVbar = true

		rwd_list.Populate = function()
			rwd_list:Clear()

			MSD.Button(rwd_list, "static", nil, 1, 50, Ln("Default Theme settings"), function()
				rwd_set.Populate("def_ui")
			end)

			MSD.Button(rwd_list, "static", nil, 1, 50, Ln("Retro Theme settings"), function()
				rwd_set.Populate("ret_ui")
			end)

			MSD.Button(rwd_list, "static", nil, 1, 50, Ln("set_server"), function()
				rwd_set.Populate("server")
			end)
		end

		rwd_set = vgui.Create("MSDPanelList", ops_panel)
		rwd_set:SetSize(ops_panel:GetWide() / 2 - 2, ops_panel:GetTall() - 2)
		rwd_set:SetPos(ops_panel:GetWide() / 2, 2)
		rwd_set:EnableVerticalScrollbar()
		rwd_set:EnableHorizontal(true)
		rwd_set:SetSpacing(2)
		rwd_set:SetPadding(2)
		rwd_set.IgnoreVbar = true
		rwd_set.SetingList = {}

		rwd_set.Populate = function(seting)
			if not rwd_set.SetingList[seting] then return end
			rwd_set:Clear()
			rwd_set.SetingList[seting]()
			last_sm = seting
		end

		rwd_set.SetingList["def_ui"] = function()
			MSD.Header(rwd_set, Ln("Default Theme"))

			MSD.BoolSlider(rwd_set, "static", nil, 1, 50, "Enable dialogue camera animations", MCS.Config.EnableCamera, function(self, value)
				MCS.Config.EnableCamera = value
			end)

			MSD.BoolSlider(rwd_set, "static", nil, 1, 50, "Enable dialogue frames", MCS.Config.Main.Frame, function(self, value)
				MCS.Config.Main.Frame = value
			end)

			MSD.BoolSlider(rwd_set, "static", nil, 1, 50, Ln("set_ui_vignette"), MCS.Config.Main.Vignette, function(self, value)
				MCS.Config.Main.Vignette = value
			end)

			MSD.ColorSelector(rwd_set, "static", nil, 1, 50, "NPC name color", MCS.Config.Main.NPCColor, function(self, color)
				MCS.Config.Main.NPCColor = color
			end)

			MSD.ColorSelector(rwd_set, "static", nil, 1, 50, "Player's name color", MCS.Config.Main.PlayerColor, function(self, color)
				MCS.Config.Main.PlayerColor = color
			end)
		end

		rwd_set.SetingList["ret_ui"] = function()
			MSD.Header(rwd_set, Ln("Default Theme"))

			MSD.BoolSlider(rwd_set, "static", nil, 1, 50, "Enable dialogue camera animations", MCS.Config.EnableCamera, function(self, value)
				MCS.Config.EnableCamera = value
			end)

			MSD.BoolSlider(rwd_set, "static", nil, 1, 50, "Enable sound effects", MCS.Config.Retro.SFX, function(self, value)
				MCS.Config.Retro.SFX = value
			end)

			MSD.InfoHeader(rwd_set, "Accent color")
			local spanel = vgui.Create("DPanel")
			spanel.StaticScale = { w = 1, fixed_h = 15, minw = 150, minh = 15 }
			spanel.Paint = function(self, w, h)
				draw.RoundedBox(0, 0, 0, w, h, MCS.Config.Retro.Color)
			end
			rwd_set:AddItem(spanel)

			MSD.VolumeSlider(rwd_set, "static", nil, 3, 50, "red", MCS.Config.Retro.Color.r / 255, function(self, var)
				local c = math.Round(var * 255)
				MCS.Config.Retro.Color.r = c
			end, Color(255, 0, 0))

			MSD.VolumeSlider(rwd_set, "static", nil, 3, 50, "green", MCS.Config.Retro.Color.g / 255, function(self, var)
				local c = math.Round(var * 255)
				MCS.Config.Retro.Color.g = c
			end, Color(0, 255, 0))

			MSD.VolumeSlider(rwd_set, "static", nil, 3, 50, "blue", MCS.Config.Retro.Color.b / 255, function(self, var)
				local c = math.Round(var * 255)
				MCS.Config.Retro.Color.b = c
			end, Color(0, 0, 255))
		end

		rwd_set.SetingList["server"] = function()
			MSD.Header(rwd_set, Ln("set_server"))

			MSD.TextEntry(rwd_set, "static", nil, 1, 50, Ln("e_number"), "Use delay (in seconds):", MCS.Config.UseDelay, function(self, value)
				value = tonumber(value) or 2
				MCS.Config.UseDelay = math.Clamp(value, 1, 10)
			end, true, nil, nil, true)

			MSD.TextEntry(rwd_set, "static", nil, 1, 50, Ln("e_number"), "Typewriter effect delay", MCS.Config.TextSpeed, function(self, value)
				value = tonumber(value) or 2
				MCS.Config.TextSpeed = math.Clamp(value, 1, 10)
			end, true, nil, nil, true)

			MSD.BoolSlider(rwd_set, "static", nil, 1, 50, Ln("Debug Mode"), MCS.Config.DebugMode, function(self, value)
				MCS.Config.DebugMode = value
			end)

			MSD.BoolSlider(rwd_set, "static", nil, 1, 50, "NPC name hover effect", MCS.Config.NPCNameHover, function(self, value)
				MCS.Config.NPCNameHover = value
			end)
		end

		panel.Canvas:AddItem(ops_panel)
		rwd_list.Populate()
		rwd_set.Populate(last_sm)

		if LocalPlayer():IsSuperAdmin() then
			MSD.BigButton(panel.Canvas, "static", nil, 2, 80, Ln("upl_changes"), MSD.Icons48.save, function()
				MCS.SaveConfig()
				openPage("settings", true)
			end)

			MSD.BigButton(panel.Canvas, "static", nil, 2, 80, Ln("res_changes"), MSD.Icons48.cross, function()
				MCS.Config = oldcfg
				openPage("settings", true)
			end)
		end
	end

	for k, v in pairs(buttons) do
		local button = MSD.MenuButton(panel.Menu, v[2], nil, nil, 250, 50, v[1], function(self)
			panel.Menu.Deselect(self)
			v[3]()
		end)

		if v[4] then
			panel.Menu.Deselect(button)
			v[3]()
		end
	end
end

modulid = MSD.AddModule("Simple NPCs", MSD.OpenAdminMenu, MSD.Icons48.account_multiple)

concommand.Add("mcs_generate", function(ply, cmd, args)
	if MCS.Spawns[localnpc.uid] then
		chat.AddText(Color(255, 0, 0), "Unique name is already used!")
	end

	if not localnpc then return end
	local uselimit_bool = "false"
	local questNPC = "false"

	if localnpc.uselimit then
		uselimit_bool = "true"
	end

	if localnpc.questNPC then
		questNPC = "true"
	end

	localnpc.scale = localnpc.scale or 1

	local text = [[MCS.Spawns["]] .. localnpc.uid .. [["] = {
	name = "]] .. localnpc.name .. [[",
	model = "]] .. localnpc.model .. [[",
	namepos = ]] .. localnpc.namepos .. [[,
	theme = "]] .. localnpc.theme .. [[",
	scale = ]] .. localnpc.scale .. [[,
	questNPC = ]] .. questNPC .. [[,
	pos = {
]]

	for k, v in pairs(localnpc.pos) do
		text = text .. [[		["]] .. k .. [["] = { Vector(]] .. v[1].x .. [[,]] .. v[1].y .. [[,]] .. v[1].z .. [[ ), Angle(]] .. v[2].p .. [[,]] .. v[2].y .. [[,]] .. v[2].r .. [[ )},
]]
	end

	text = text .. [[	},
	sequence = "]] .. localnpc.sequence .. [[",
	uselimit = ]] .. uselimit_bool .. [[,
]]

	if localnpc.skin then
		text = text .. [[	skin = ]] .. localnpc.skin .. [[,
]]
	end

	if localnpc.bgr then
		text = text .. [[	bgr = {]]

		for k, v in pairs(localnpc.bgr) do
			text = text .. "[" .. k .. "] = " .. v .. ","
		end
		text = text .. [[},
]]
	end

	if localnpc.ClModels then
		text = text .. [[	ClModels = {
]]
		for k, v in pairs(localnpc.ClModels) do
			text = text .. [[		{ model = "]] .. v.model .. [[",]]
			if v.marge then
				text = text .. " marge = true"
			else
				text = text .. " pos = " .. "Vector(" .. v.pos.x .. "," .. v.pos.y .. "," .. v.pos.z .. "), ang = Angle(" .. v.ang.p .. "," .. v.ang.y .. "," .. v.ang.r .. "), bone = " .. v.bone
			end
			text = text .. [[},
]]
		end
		text = text .. [[	},
]]
	end

	text = text .. [[	dialogs = {
]]

	for k, v in pairs(localnpc.dialogs) do
		text = text .. [[		[]] .. k .. [[] = {
			["Line"] = ]] .. "[[" .. string.Replace(v["Line"], '"', "'") .. "]],\n" .. [[
			["Sound"] = "]] .. v["Sound"] .. [[",
			["Answers"] = {
]]

		for _, a in pairs(v["Answers"]) do
			local at = a[2]
			local an = a[5] or ""

			if at == "close" then
				at = "\"close\""
			end

			if an ~= "" then
				an = " nil, nil, \"" .. an .. "\""
			end

			text = text .. [[
				{"]] .. string.Replace(a[1], '"', "'") .. [[", ]] .. at .. [[,]] .. an .. [[},
]]
		end

		text = text .. [[
			},
		},
]]
	end

	text = text .. [[	}
}]]
	SetClipboardText(text)
end)