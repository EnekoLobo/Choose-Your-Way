local defMaleInfos = {
	model = "models/kerry/player/citizen/male_01.mdl",
	name = "",
	surname = "",
	sex = 1,
	playerColor = Vector(1,1,1),
	bodygroups = {
		top = "polo",
		pant = "pant",
	},
	skin = 0,
	eyestexture = {
		basetexture = {
			["r"] = "eyes/eyes/amber_r",
			["l"] = "eyes/eyes/amber_l",
		},
	},
	hasCostume = false,
	teetexture = {
		basetexture = "models/citizen/body/citizen_sheet",
		hasCustomThings = false,
	},
	panttexture = {
		basetexture = "models/citizen/body/citizen_sheet",
	},
}

local defFemaleInfos = {
	model = "models/kerry/player/citizen/female_01.mdl",
	name = "",
	surname = "",
	sex = 0,
	playerColor = Vector(1,1,1),
	bodygroups = {
		top = "polo",
		pant = "pant",
	},
	skin = 0,
	eyestexture = {
		basetexture = {
			["r"] = "eyes/eyes/amber_r",
			["l"] = "eyes/eyes/amber_l",
		},
	},
	hasCostume = false,
	teetexture = {
		basetexture = "models/humans/modern/female/sheet_01",
		hasCustomThings = false,
	},
	panttexture = {
		basetexture = "models/humans/modern/female/sheet_01",
	},
}


function Aden_DC.ClientSideMenu:OpenModelClothes(frame, arrayCharacter)
    Aden_DC.Buttons:removeView("Informations")
    Aden_DC.Buttons:addView(vector_zero, angle_zero, "Informations", false)

    arrayCharacter.info = defMaleInfos
    local first

    local layoutMenu = Aden_DC.Buttons:createButton()
    layoutMenu:SetSize(460, 835)
    layoutMenu:SetPos(20, 60)
    layoutMenu:SetIdView("Informations")
    layoutMenu:CreateLayout(frame, 175, 125, 15, 10, 25)
    layoutMenu.Paint = function(self, w, h, x, y)
        surface.SetDrawColor(255, 255, 255, 245)
        surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[7])
        surface.DrawTexturedRect(x, y, w, h)
        draw.DrawText(Aden_DC:GetPhrase("pm"), "ADCFont::6", x+w/2, y+20, color_white, TEXT_ALIGN_CENTER)
    end

    if Aden_DC.Config.ModelScale then
        local Slide = Aden_DC.Buttons:createButton()
        Slide:SetSize(10, 50)
        Slide:SetPos(245, 150)
        Slide:SetIdView("Informations")
        Slide.Paint = function(self, w, h, x, y)
            surface.SetDrawColor(255, 255, 255, 225)
            surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[12])
            surface.DrawTexturedRect(50, y+7, 400, 40)
            draw.RoundedBox(16, x, y, w, h, Aden_DC.ClientSideMenu.Colors["blue"])
            if self.IsDragging then
                self.x = math.Clamp(Aden_DC.Buttons:getXCursor() - 5, 50, 440)
                if !input.IsMouseDown(MOUSE_LEFT) then
                    self.IsDragging = false
                end
            end
            if self:IsHovered() or self.IsDragging then
                frame:SetCursor("sizewe")
            end
            local mScale = ((self.x-50)/390)*(Aden_DC.Config.ModelMax-Aden_DC.Config.ModelMin) + Aden_DC.Config.ModelMin
            Aden_DC.ClientSideMenu.playerRagdoll:SetModelScale(mScale, 0)
            arrayCharacter.mScale = math.Round(mScale, 3)
        end
        Slide.DoClick = function(self)
            self.IsDragging = true
        end
    end
    local posY = 1
    local idArrow = 0
    for head, v in pairs(CLOTHESMOD.Male.ListDefaultPM) do
        for k, skin in pairs(v.skins) do
            idArrow = idArrow + 1
            Aden_DC.Model:GenerateSpawnIcon(head, skin)
            local background = Aden_DC.Buttons:createButton()
            background:SetSize(115, 115)
            background:SetPos(70 + ((posY-1)%3) * 125, 0)
            background.line = idArrow%3 != 0
            background.DoClick = function()
                arrayCharacter.cModel = head
                self.playerRagdoll:SetModel(head)
                self.playerRagdoll:SetSkin(skin)
                local idSeq = self.playerRagdoll:LookupSequence("walk_all")
                self.playerRagdoll:ResetSequence(idSeq)
                arrayCharacter.info = defMaleInfos
                arrayCharacter.info.model = head
                arrayCharacter.info.skin = skin
            end

            local model = Aden_DC.Model:GetSpawnIcon(head .. skin)
            model:SetPos(50 + ((posY-1)%3) * 125, 190 + math.floor((posY-1)/3) * 125)
            model.Think = function(self)
                local x, y = background:GetPos()
                self:SetPos(x-20, y-45)
            end
            background.Paint = function(self, w, h, x, y)
                surface.SetDrawColor(255, 255, 255)
                if self:IsHovered() then
                    surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[11])
                    frame:SetCursor("hand")
                else
                    surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[10])
                end
                surface.DrawTexturedRect(x, y, w, h)
                model:PaintManual()
            end
            layoutMenu:AddToLayout(background)
            posY = posY + 1
            if !first then
                background:DoClick()
                first = true
            end
        end
    end
    for head, v in pairs(CLOTHESMOD.Female.ListDefaultPM) do
        for k, skin in pairs(v.skins) do
            idArrow = idArrow + 1
            Aden_DC.Model:GenerateSpawnIcon(head, skin)
            local background = Aden_DC.Buttons:createButton()
            background:SetSize(115, 115)
            background:SetPos(70 + ((posY-1)%3) * 125, 0)
            background.line = idArrow%3 != 0
            background.DoClick = function()
                arrayCharacter.cModel = head
                self.playerRagdoll:SetModel(head)
                self.playerRagdoll:SetSkin(skin)
                local idSeq = self.playerRagdoll:LookupSequence("walk_all")
                self.playerRagdoll:ResetSequence(idSeq)
                arrayCharacter.info = defFemaleInfos
                arrayCharacter.info.model = head
                arrayCharacter.info.skin = skin
            end

            local model = Aden_DC.Model:GetSpawnIcon(head .. skin)
            model:SetPos(50 + ((posY-1)%3) * 125, 190 + math.floor((posY-1)/3) * 125)
            model.Think = function(self)
                local x, y = background:GetPos()
                self:SetPos(x-20, y-45)
            end
            background.Paint = function(self, w, h, x, y)
                surface.SetDrawColor(255, 255, 255)
                if self:IsHovered() then
                    surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[11])
                    frame:SetCursor("hand")
                else
                    surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[10])
                end
                surface.DrawTexturedRect(x, y, w, h)
                model:PaintManual()
            end
            layoutMenu:AddToLayout(background)
            posY = posY + 1
        end
    end

    local valideButton = Aden_DC.Buttons:createButton()
    valideButton:SetSize(200, 60)
    valideButton:SetPos(150, 800)
    valideButton:SetIdView("Informations")
    valideButton.Paint = function(self, w, h, x, y)
        surface.SetDrawColor(255, 255, 255, 225)
        if self:IsHovered() then
            surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[17])
            frame:SetCursor("hand")
        else
            surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[16])
        end
        surface.DrawTexturedRect(x, y, w, h)
        draw.DrawText(Aden_DC:GetPhrase("valide"), "ADCFont::1", x+w/2, y+h/5,color_white, TEXT_ALIGN_CENTER)
    end
    valideButton.DoClick = function()
        self:OpenClothes(frame, arrayCharacter)
    end
end

function Aden_DC.ClientSideMenu:OpenClothes(frame, arrayCharacter)
    Aden_DC.Buttons:removeView("Informations")
    Aden_DC.Buttons:addView(vector_zero, angle_zero, "Informations", false)
    local layoutMenu = Aden_DC.Buttons:createButton()
    layoutMenu:SetSize(460, 835)
    layoutMenu:SetPos(20, 60)
    layoutMenu:SetIdView("Informations")
    layoutMenu.Paint = function(self, w, h, x, y)
        surface.SetDrawColor(255, 255, 255, 245)
        surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[7])
        surface.DrawTexturedRect(x, y, w, h)
        draw.DrawText(Aden_DC:GetPhrase("pm"), "ADCFont::6", x+w/2, y+20, color_white, TEXT_ALIGN_CENTER)
    end

    local layoutTop = Aden_DC.Buttons:createButton()
    layoutTop:SetSize(460, 290)
    layoutTop:SetPos(20, 160)
    layoutTop:SetIdView("Informations")
    layoutTop:CreateLayout(frame, 0, 0, 15, 10, 25)
    layoutTop.Paint = function(self, w, h, x, y)
        //surface.SetDrawColor(255, 255, 255, 255)
        //surface.DrawRect(x, y, w, h)
    end

    local posY = 1
    local idArrow = 0
    local list
    if arrayCharacter.info.sex == 1 then
        list = CLOTHESMOD.Male.ListTops
    else
        list = CLOTHESMOD.Female.ListTops
    end
    for pant, tables in pairs(list) do
        if not tables.default then continue end

        local datas
        if arrayCharacter.info.sex == 1 then
            datas = CLOTHESMOD.Male.ListDefaultPM[arrayCharacter.cModel]
        else
            datas = CLOTHESMOD.Female.ListDefaultPM[arrayCharacter.cModel]
        end

        local tindex = datas.bodygroupstop[tables.bodygroup].tee
		local bodygroups = {
			datas.bodygroupstop[tables.bodygroup].group,
		}

        idArrow = idArrow + 1
        local background = Aden_DC.Buttons:createButton()
        background:SetSize(115, 50)
        background:SetPos(70 + ((posY-1)%3) * 125, 0)
        background.line = idArrow%3 != 0
        background.index = idArrow
        background.DoClick = function()
            arrayCharacter.cModel = head
            for k, v in pairs(bodygroups) do
                self.playerRagdoll:SetBodygroup(v[1], v[2])
            end

            local tops = tables.texture
            for k, v in pairs(tindex) do
                self.playerRagdoll:SetSubMaterial(v, tops)
            end

            arrayCharacter.info.bodygroups.top = tables.bodygroup
            arrayCharacter.info.teetexture.basetexture = tops
        end
        background.Paint = function(self, w, h, x, y)
			if self:IsHovered() then
                surface.SetDrawColor(255, 255, 255, 100)
                frame:SetCursor("hand")
            else
                surface.SetDrawColor(255, 255, 255)
            end
			surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[18])
            surface.DrawTexturedRect(x, y, w, h)
            draw.DrawText(self.index, "ADCFont::1", x+w/2, y+h/5,color_white, TEXT_ALIGN_CENTER)
        end
        layoutTop:AddToLayout(background)
        posY = posY + 1
    end

    local layoutPant = Aden_DC.Buttons:createButton()
    layoutPant:SetSize(460, 290)
    layoutPant:SetPos(20, 480)
    layoutPant:SetIdView("Informations")
    layoutPant:CreateLayout(frame, 0, 0, 15, 10, 25)
    layoutPant.Paint = function(self, w, h, x, y)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawRect(x+w/4, y - 15, w/2, 1)
    end

    local posY = 1
    local idArrow = 0
    local list
    if arrayCharacter.info.sex == 1 then
        list = CLOTHESMOD.Male.ListBottoms
    else
        list = CLOTHESMOD.Female.ListBottoms
    end
    for pant, tables in pairs(list) do
        if not tables.default then continue end

        local datas
        if arrayCharacter.info.sex == 1 then
            datas = CLOTHESMOD.Male.ListDefaultPM[arrayCharacter.cModel]
        else
            datas = CLOTHESMOD.Female.ListDefaultPM[arrayCharacter.cModel]
        end

        local tindex = datas.bodygroupsbottom[tables.bodygroup].pant
        local bodygroups = {
            datas.bodygroupsbottom[tables.bodygroup].group,
        }

        idArrow = idArrow + 1
        local background = Aden_DC.Buttons:createButton()
        background:SetSize(115, 50)
        background:SetPos(70 + ((posY-1)%3) * 125, 0)
        background.line = idArrow%3 != 0
        background.index = idArrow
        background.DoClick = function()
            arrayCharacter.cModel = head
            for k, v in pairs(bodygroups) do
                self.playerRagdoll:SetBodygroup(v[1], v[2])
            end

            local pants = tables.texture
            for k, v in pairs(tindex) do
                self.playerRagdoll:SetSubMaterial(v, pants)
            end

            arrayCharacter.info.bodygroups.pant = tables.bodygroup
            arrayCharacter.info.panttexture.basetexture = pants
        end
        background.Paint = function(self, w, h, x, y)
            if self:IsHovered() then
                surface.SetDrawColor(255, 255, 255, 100)
                frame:SetCursor("hand")
            else
                surface.SetDrawColor(255, 255, 255)
            end
			surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[18])
            surface.DrawTexturedRect(x, y, w, h)
            draw.DrawText(self.index, "ADCFont::1", x+w/2, y+h/5,color_white, TEXT_ALIGN_CENTER)
        end
        layoutPant:AddToLayout(background)
        posY = posY + 1
    end

    local valideButton = Aden_DC.Buttons:createButton()
    valideButton:SetSize(200, 60)
    valideButton:SetPos(150, 800)
    valideButton:SetIdView("Informations")
    valideButton.Paint = function(self, w, h, x, y)
        surface.SetDrawColor(255, 255, 255, 225)
        if self:IsHovered() then
            surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[17])
            frame:SetCursor("hand")
        else
            surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[16])
        end
        surface.DrawTexturedRect(x, y, w, h)
        draw.DrawText(Aden_DC:GetPhrase("valide"), "ADCFont::1", x+w/2, y+h/5,color_white, TEXT_ALIGN_CENTER)
    end
    valideButton.DoClick = function()
        arrayCharacter.info.name = arrayCharacter.firstName
        arrayCharacter.info.surname = arrayCharacter.lastName
        net.Start("ClothesMod:ReceiveCharacterCreated")
            net.WriteTable(arrayCharacter.info)
        net.SendToServer()
        arrayCharacter.cModel = arrayCharacter.info.model
        self:runExit(false, function()
            net.Start("ADC::CharacterNetwork")
            net.WriteUInt(1, 8);
            Aden_DC.Nets:WriteTable(arrayCharacter)
            net.SendToServer()
        end)
    end
end

function Aden_DC.ClientSideMenu:SetClothes(arrayCharacter)
	if arrayCharacter.infoClothes.hasCostume then
		self:SetModel(arrayCharacter.infoClothes.model)
		return
	end

	local tab
	if arrayCharacter.infoClothes.sex == 1 then
		tab = CLOTHESMOD.Male
	else
		tab = CLOTHESMOD.Female
	end

	if not tab.ListDefaultPM or not tab.ListDefaultPM[arrayCharacter.infoClothes.model] then return end
	local mdli = tab.ListDefaultPM[arrayCharacter.infoClothes.model]

	self.playerRagdoll:SetModel(arrayCharacter.infoClothes.model)
	local bodygroups = {
		mdli.bodygroupstop[arrayCharacter.infoClothes.bodygroups.top].group,
		mdli.bodygroupsbottom[arrayCharacter.infoClothes.bodygroups.pant].group
	}

	for k, v in pairs(bodygroups) do
		self.playerRagdoll:SetBodygroup(unpack(v))
	end
	self.playerRagdoll:SetModel(arrayCharacter.infoClothes.model)
	self.playerRagdoll:SetSkin(arrayCharacter.infoClothes.skin)

	self.playerRagdoll:SetSubMaterial(mdli.eyes["r"], arrayCharacter.infoClothes.eyestexture.basetexture["r"])
	self.playerRagdoll:SetSubMaterial(mdli.eyes["l"], arrayCharacter.infoClothes.eyestexture.basetexture["l"])

	local topgroup = arrayCharacter.infoClothes.bodygroups.top or "polo"
	local teeindex = mdli.bodygroupstop[topgroup].tee or -1

	if teeindex == -1 then return end
	for k, v in pairs(teeindex) do
		if not arrayCharacter.infoClothes.teetexture.hasCustomThings then
			self.playerRagdoll:SetSubMaterial(v, arrayCharacter.infoClothes.teetexture.basetexture)
		end
	end

	local botgroup = arrayCharacter.infoClothes.bodygroups.pant or "pant"
	local pantindex = mdli.bodygroupsbottom[botgroup].pant or -1
	if pantindex == -1 then return end

	for k, v in pairs(pantindex) do
		self.playerRagdoll:SetSubMaterial(v, arrayCharacter.infoClothes.panttexture.basetexture)
	end
end
