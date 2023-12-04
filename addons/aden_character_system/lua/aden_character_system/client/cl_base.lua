surface.CreateFont("ADCFont::1", {
    font = "Tahoma",
    size = 35,
    weight = 0,
    extended = true
})

local function loadFont()
    surface.CreateFont("ADCFont::2", {
        font = "Tahoma",
        size = ScreenScale(10),
        weight = 0,
        extended = true
    })

    surface.CreateFont("ADCFont::3", {
        font = "Tahoma",
        size = ScreenScale(8),
        weight = 0,
        extended = true
    })

    surface.CreateFont("ADCFont::5", {
        font = "Tahoma",
        size = ScreenScale(12),
        weight = 0,
        extended = true
    })

    Aden_DC.ScrW = ScrW()
    Aden_DC.ScrH = ScrH()
end

loadFont()
hook.Add("OnScreenSizeChanged", "ADC::OnScreenSizeChanged::UpdateFont", loadFont)

surface.CreateFont("ADCFont::4", {
    font = "Tahoma",
    size = 100,
    weight = 0,
    extended = true
})

surface.CreateFont("ADCFont::6", {
    font = "Tahoma",
    size = 45,
    weight = 0,
    extended = true
})

Aden_DC.ClientSideMenu.Mat = {
    [1] = Material("materials/adc_materials/btn.png"),
    [2] = Material("materials/adc_materials/btn_hover.png"),
    [3] = Material("materials/adc_materials/plus.png"),
    [4] = Material("materials/adc_materials/background.png"),
    [5] = Material("materials/adc_materials/text.png"),
    [6] = Material("materials/adc_materials/user.png"),
    [7] = Material("materials/adc_materials/background2.png"),
    [8] = Material("materials/adc_materials/right.png"),
    [9] = Material("materials/adc_materials/background3.png"),
    [10] = Material("materials/adc_materials/icon.png"),
    [11] = Material("materials/adc_materials/icon_hover.png"),
    [12] = Material("materials/adc_materials/slide.png"),
    [13] = Material("materials/adc_materials/btn2.png"),
    [14] = Material("materials/adc_materials/btn2_hover.png"),
    [15] = Material("materials/adc_materials/body.png"),
    [16] = Material("materials/adc_materials/btn3.png"),
    [17] = Material("materials/adc_materials/btn3_hover.png"),
    [18] = Material("materials/adc_materials/y.png"),
    [19] = Material("materials/adc_materials/desc.png"),
    [20] = Material("materials/adc_materials/entry.png"),
    [21] = Material("materials/adc_materials/m.png"),
    [22] = Material("materials/adc_materials/entry2d.png"),
    [23] = Material("materials/adc_materials/entry2d2.png"),
    [24] = Material("materials/adc_materials/background4.png"),
    [25] = Material("materials/adc_materials/cadenas.png"),
    [26] = Material("materials/adc_materials/down.png"),
    [27] = Material("materials/adc_materials/background_round.png"),
    [28] = Material("materials/adc_materials/entry2d3.png"),
    [29] = Material("materials/adc_materials/entry2d4.png"),
    [30] = Material("materials/adc_materials/admin.png"),
    [31] = Material("materials/adc_materials/admin_hover.png"),
}

if Aden_DC.Config.customColorPackage then
    Aden_DC.ClientSideMenu.Mat[2] = Material(Aden_DC.Config.customColorPackage .. "btn_hover.png")
    Aden_DC.ClientSideMenu.Mat[12] = Material(Aden_DC.Config.customColorPackage .. "slide.png")
    Aden_DC.ClientSideMenu.Mat[14] = Material(Aden_DC.Config.customColorPackage .. "btn2_hover.png")
    Aden_DC.ClientSideMenu.Mat[17] = Material(Aden_DC.Config.customColorPackage .. "btn3_hover.png")
    Aden_DC.ClientSideMenu.Mat[18] = Material(Aden_DC.Config.customColorPackage .. "y.png")
    Aden_DC.ClientSideMenu.Mat[19] = Material(Aden_DC.Config.customColorPackage .. "desc.png")
    Aden_DC.ClientSideMenu.Mat[20] = Material(Aden_DC.Config.customColorPackage .. "entry.png")
    Aden_DC.ClientSideMenu.Mat[21] = Material(Aden_DC.Config.customColorPackage .. "m.png")
end

Aden_DC.ClientSideMenu.Colors = {
    ["grey"] = Color(100, 100, 100),
    ["blue"] = Color(17, 140, 255),
    ["red"] = Color(255, 0, 0),
}

local saveAngles
local frame

function Aden_DC.ClientSideMenu:OpenMenu(arrayCharacter)
    if IsValid(self.frame) then
        self:reOpen() // Dont duplicate entities
        local oldframe = self.frame
        oldframe.OnRemove = nil
        oldframe:Remove()
        self.playerRagdoll = nil
    end
    saveAngles = Aden_DC.LocalPlayer:EyeAngles()
    if !self.playerRagdoll or !IsValid(self.playerRagdoll) then
        self.playerRagdoll = ClientsideModel(Aden_DC.Config.Model[1], RENDERGROUP_OTHER)
        self.playerRagdoll:SetIK(false)
        local idSeq = self.playerRagdoll:LookupSequence("walk_all")
        self.playerRagdoll:ResetSequence(idSeq)
        self.playerRagdoll:SetPos(Aden_DC.LocalPlayer:GetPos() + Vector(120, 0, 0))
        self.playerRagdoll:SetAngles(Angle(0, 150, 0))
        self.playerRagdoll:SetNoDraw(true)
        self.playerRagdoll:DrawShadow(false)

        self.showRoom = {}
        for k, v in ipairs(istable(Aden_DC.Config.showRoom) and Aden_DC.Config.showRoom or {}) do
            self.showRoom[k] = ClientsideModel(v.model)
            self.showRoom[k]:SetPos(Aden_DC.LocalPlayer:GetPos() + v.pos)
            self.showRoom[k]:SetAngles(v.ang)
            self.showRoom[k]:SetNoDraw(true)
            self.showRoom[k]:DrawShadow(false)
            self.showRoom[k]:SetParent(self.playerRagdoll)
        end
    end

    self.mStatus = 0
    self.npcOffset = Vector(0, 0, 0)
    local posOffest = Vector(-20, 0, 20)
    local angOffset = Angle(0, 20, 0)
    local angMenu = angle_zero
    if IsValid(self.playerRagdoll) then
        angMenu = self.playerRagdoll:GetAngles()
        angMenu:RotateAroundAxis(angMenu:Forward(), 90)
        angMenu:RotateAroundAxis(angMenu:Right(), -130)
        self.playerRagdoll:SetPos(posOffest + Aden_DC.LocalPlayer:GetPos() + Vector(100, 0, 0))
        self.playerRagdoll:SetAngles(angOffset + Angle(0, 150, 0))
    end

    hook.Add("PostDrawHUD", "PostDrawHUD::ADC::renderModelView", function()
        Aden_DC.LocalPlayer:SetEyeAngles(angle_zero)
        if !istable(Aden_DC.Config.showRoom) then
            surface.SetDrawColor(255,255,255,255)
            surface.SetMaterial(Aden_DC.Config.showRoom)
            surface.DrawTexturedRect(-1, -1, ScrW()+1, ScrH()+1)
        end
        cam.Start3D(Aden_DC.LocalPlayer:EyePos(), Aden_DC.LocalPlayer:EyeAngles(), 115) // Override the Calc View
        if IsValid(self.playerRagdoll) then
            render.SuppressEngineLighting(true)
            render.ResetModelLighting(Aden_DC.Config.lightMode, Aden_DC.Config.lightMode, Aden_DC.Config.lightMode)
            if Aden_DC.Config.spotLight then
                render.SetLightingOrigin(self.playerRagdoll:GetPos() + Vector(-10, 0, 20))
                render.SetColorModulation(1, 1, 1)
                render.SetModelLighting(BOX_BACK, 1.5, 1.5, 1.5)
            end
            self.playerRagdoll:DrawModel()
            self.playerRagdoll:CreateShadow()
            if !self.isExit then
                self.playerRagdoll:SetPos(posOffest + Aden_DC.LocalPlayer:GetPos() + Vector(100, 0, 0) + self.npcOffset)
                self.playerRagdoll:SetAngles(angOffset + Angle(0, 150, 0))
            end
            if istable(Aden_DC.Config.showRoom) then
                for k, v in ipairs(self.showRoom) do
                    if IsValid(v) then
                        v:DrawModel()
                    end
                end
            end
            render.SuppressEngineLighting(false)
            render.SetColorModulation(1, 1, 1)

            local angInformations = angle_zero
            if IsValid(self.playerRagdoll) then
                angInformations = self.playerRagdoll:GetAngles()
                angInformations:RotateAroundAxis(angInformations:Forward(), 90)
                angInformations:RotateAroundAxis(angInformations:Right(), -60)
            end

            local draw = angMenu + angOffset
            Aden_DC.Buttons:addView(self.playerRagdoll:GetPos() + self.playerRagdoll:GetRight()*50 + self.playerRagdoll:GetForward()*10 + Vector(0, 0, 60), draw, "Menu", false, 0.07)

            draw = angInformations + angOffset
            Aden_DC.Buttons:addView(self.playerRagdoll:GetPos() + self.playerRagdoll:GetRight()*-20 + self.playerRagdoll:GetForward()*10 + Vector(0, 0, 70), draw, "Informations", false, 0.07)
        end
        Aden_DC.Buttons:drawView(Aden_DC.LocalPlayer:EyePos(), Aden_DC.LocalPlayer:EyeAngles(), 115)
        cam.End3D()
    end)

    Aden_DC.Buttons:addView(vector_zero, angle_zero, "Informations", false)
    Aden_DC.Buttons:addView(vector_zero, angle_zero, "Menu", false)

    frame = vgui.Create("DFrame")
    frame:SetSize(ScrW(), ScrH())
    frame:MakePopup()
    frame:ShowCloseButton(Aden_DC.Config.DebugMode)
    frame:SetTitle("")
    frame.Paint = function(self)
        self:MoveToBack()
    end
    frame.OnRemove = function()
        self:exitMenu()
    end
    timer.Simple(1, function() // I need to wait when the player respawn
        if !IsValid(frame) then return end
        frame.Think = function(self)
            if !Aden_DC.LocalPlayer:Alive() then
                self:Remove()
            end
        end
    end)
    self.frame = frame
    if Aden_DC.Config.Music and !IsValid(self.StationMusic) then
        Aden_DC.Config.SoundFunc(Aden_DC.Config.Music, "noblock noplay", function(station, errCode, errStr)
        	if (IsValid(station)) then
                station:SetVolume(Aden_DC.Config.Volume or 1)
        		station:Play()
                station:EnableLooping(true)
                self.StationMusic = station
        	else
        		print("Error playing sound !", errCode, errStr)
        	end
        end)
    end
    if self.selectedCharacter and arrayCharacter[self.selectedCharacter] then
        local button = Aden_DC.Buttons:createButton()
        button:SetSize(70, 70)
        button:SetPos(530, 0)
        button:SetIdView("Menu")
        button.Paint = function(self, w, h, x, y)
            surface.SetDrawColor(255, 255, 255, 235)
            if self:IsHovered() then
                frame:SetCursor("hand")
                surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[21])
            else
                surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[21])
            end
            surface.DrawTexturedRect(x, y, w, h)
            if self:IsHovered() then
                draw.DrawText("X", "ADCFont::6", x+w/2, y+h/5, Aden_DC.ClientSideMenu.Colors["red"], TEXT_ALIGN_CENTER)
            else
                draw.DrawText("X", "ADCFont::6", x+w/2, y+h/5, color_white, TEXT_ALIGN_CENTER)
            end
        end
        button.DoClick = function()
            frame:Remove()
        end
    end

    local layoutMenu = Aden_DC.Buttons:createButton()
    layoutMenu:SetSize(550, 595)
    layoutMenu:SetPos(0, 0)
    layoutMenu:SetIdView("Menu")
    layoutMenu:CreateLayout(frame, 0, 0, 10, 10, 40)
    layoutMenu.Paint = function(self, w, h, x, y)
    end

    local idSelected
    local firstMenu
    for k, v in ipairs(arrayCharacter) do
        local button = Aden_DC.Buttons:createButton()
        button:SetSize(500, 110)
        button:SetPos(0, 0)
        button.Paint = function(self, w, h, x, y)
            surface.SetDrawColor(255, 255, 255, 235)
            if self:IsHovered() then
                surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[2])
                frame:SetCursor("hand")
                if idSelected == k then
                    surface.SetDrawColor(255, 255, 255, 255)
                end
            elseif idSelected == k then
                surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[2])
            else
                surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[1])
            end
            surface.DrawTexturedRect(x, y, w, h)

            surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[6])
            surface.DrawTexturedRect(x + w/15, y+h/4, h/2, h/2)
            draw.DrawText(v.firstName .. " " .. v.lastName, "ADCFont::1", x+w/4, y+h/2.85,color_white, TEXT_ALIGN_LEFT)
        end
        button.DoClick = function()
            idSelected = k
            self:SelectionMenu(frame, v, k)
            if Aden_DC.Config.enableFaction and Aden_DC.Config.listFaction[v.cFaction] then
                Aden_DC.Config.showRoom = Aden_DC.Config.listFaction[v.cFaction].background and Aden_DC.Config.listFaction[v.cFaction].background or Aden_DC.Config.baseRoom
                self.npcOffset = Aden_DC.Config.listFaction[v.cFaction].npcOffset and Aden_DC.Config.listFaction[v.cFaction].npcOffset or Vector(0, 0, 0)
            end
            if v.nAvailable then
                self:RequestMenu(frame, function(firstName, lastName)
                    net.Start("ADC::UpdateName")
                    net.WriteUInt(2, 8)
                    net.WriteString(firstName)
                    net.WriteString(lastName)
                    net.SendToServer()
                    self.NeedRequest = false
                end)
            end
            firstMenu = true
        end

        if !firstMenu then
            button:DoClick()
        end
        layoutMenu:AddToLayout(button)
    end

    for k, v in ipairs(Aden_DC.Config.maxCharacter) do
        if arrayCharacter[k] then continue end
        local button = Aden_DC.Buttons:createButton()
        button:SetSize(500, 110)
        button:SetPos(0, 0)
        button.Paint = function(self, w, h, x, y)
            surface.SetDrawColor(255, 255, 255, 235)
            if self:IsHovered() then
                surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[2])
                frame:SetCursor("hand")
                if idSelected == k then
                    surface.SetDrawColor(255, 255, 255, 255)
                end
            elseif idSelected == k then
                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[2])
            else
                surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[1])
            end
            surface.DrawTexturedRect(x, y, w, h)

            if istable(v) and v.usergroups then
                if !v.usergroups[Aden_DC.LocalPlayer:GetUserGroup()] then
                    surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[25])
                else
                    surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[3])
                end
            else
                surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[3])
            end
            surface.DrawTexturedRect(x + w/15, y+h/4, h/2, h/2)
            if isstring(v) then
                draw.DrawText(v .. " #" .. (k), "ADCFont::1", x+w/4, y+h/2.85, color_white, TEXT_ALIGN_LEFT)
            else
                draw.DrawText(v.name .. " #" .. (k), "ADCFont::1", x+w/4, y+h/2.85, v.color, TEXT_ALIGN_LEFT)
            end
        end
        button.DoClick = function()
            if istable(v) and v.usergroups then
                if !v.usergroups[Aden_DC.LocalPlayer:GetUserGroup()] then
                    self:sendPopup(v.msg)
                    return
                end
            end
            idSelected = k
            self:CreationMenu(frame)
            firstMenu = true
        end
        if !firstMenu then
            button:DoClick()
        end
        layoutMenu:AddToLayout(button)
    end

    if self.NeedRequest then
        idSelected = #arrayCharacter
        self:SelectionMenu(frame, arrayCharacter[#arrayCharacter], #arrayCharacter) // Select the playermodel
        self:RequestMenu(frame, function(firstName, lastName)
            net.Start("ADC::UpdateName")
            net.WriteUInt(2, 8)
            net.WriteString(firstName)
            net.WriteString(lastName)
            net.SendToServer()
            self.NeedRequest = false
        end)
    end
    RunConsoleCommand("-forward")
    RunConsoleCommand("-back")
    RunConsoleCommand("-moveleft")
    RunConsoleCommand("-moveright")
    RunConsoleCommand("-duck")
end

function Aden_DC.ClientSideMenu:sendPopup(reason, type)
    type = type != "" and type or nil
    local time = SysTime()
    local frame = vgui.Create("DFrame")
    frame:SetSize(ScrW()/3, ScrH()/4)
    frame:Center()
    frame:SetTitle("")
    frame:MakePopup()
    frame:ShowCloseButton(false)
    frame.Paint = function(self, w, h)
        self:MoveToFront()
        Derma_DrawBackgroundBlur(self, time)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[24])
        surface.DrawTexturedRect(0, 0, w, h)

        if type and Aden_DC:GetPhrase(type) then
            draw.DrawText(Aden_DC:GetPhrase("notif") .. "\n" .. Aden_DC:GetPhrase(type), "ADCFont::2", w/2, h/14, color_white, TEXT_ALIGN_CENTER)
        else
            draw.DrawText(Aden_DC:GetPhrase("notif"), "ADCFont::2", w/2, h/14, color_white, TEXT_ALIGN_CENTER)
        end
    end

    local Close = vgui.Create("DButton", frame)
    Close:SetSize(ScrW()/60, ScrW()/60)
    Close:SetPos(frame:GetWide() - Close:GetWide() - ScrW()/100, ScrW()/100)
    Close:SetText("")
    Close.Paint = function(self, w, h)
        surface.SetDrawColor(255, 255, 255)
        if self:IsHovered() then
            surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[13])
        else
            surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[14])
        end
        surface.DrawTexturedRect(0, 0, w, h)

        draw.DrawText("X", "ADCFont::2", w/2, h/30, color_white, TEXT_ALIGN_CENTER)
    end
    Close.DoClick = function()
        frame:Remove()
    end

    local Reason = vgui.Create("DTextEntry", frame)
    Reason:SetSize(frame:GetWide()/1.26, frame:GetTall()/4)
    Reason:Center()
    Reason:SetText("   " .. reason)
    Reason:SetFont("ADCFont::3")
    Reason:SetDrawLanguageID(false)
    Reason:SetEditable(false)
    Reason.Paint = function(self, w, h)
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[29])
        surface.DrawTexturedRect(0, 0, w, h)

        self:DrawTextEntryText(color_white, color_white, color_white)
    end

    local Validate = vgui.Create("DButton", frame)
    Validate:SetSize(frame:GetWide()/3, frame:GetTall()/5)
    Validate:SetPos(frame:GetWide()/2 - Validate:GetWide()/2, frame:GetTall()/1.4)
    Validate:SetText("")
    Validate.Paint = function(self, w, h)
        surface.SetDrawColor(255, 255, 255, 225)
        if self:IsHovered() then
            surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[17])
        else
            surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[16])
        end
        surface.DrawTexturedRect(0, 0, w, h)
        draw.DrawText(Aden_DC:GetPhrase("valide"), "ADCFont::2", w/2, h/5, color_white, TEXT_ALIGN_CENTER)
    end
    Validate.DoClick = function()
        frame:Remove()
    end
end

net.Receive("ADC::Popup", function()
    Aden_DC.ClientSideMenu:sendPopup(net.ReadString(), net.ReadString())
end)

function Aden_DC.ClientSideMenu:exitMenu()
    hook.Remove("PostDrawHUD", "PostDrawHUD::ADC::renderModelView")
    Aden_DC.Buttons:removeView("Menu")
    Aden_DC.Buttons:removeView("Informations")
    if IsValid(self.playerRagdoll) then
        self.playerRagdoll:Remove()
    end
    for k, v in ipairs(self.showRoom) do
        if IsValid(v) then
            v:Remove()
        end
    end
    if IsValid(self.frame) then
        self.frame:Remove()
    end
    if saveAngles then
        Aden_DC.LocalPlayer:SetEyeAngles(saveAngles)
    end
    if IsValid(self.StationMusic) then
        self.StationMusic:Stop()
    end
    Aden_DC.Config.showRoom = Aden_DC.Config.baseRoom
end

function Aden_DC.ClientSideMenu:reOpen()
    hook.Remove("PostDrawHUD", "PostDrawHUD::ADC::renderModelView")
    Aden_DC.Buttons:removeView("Menu")
    Aden_DC.Buttons:removeView("Informations")
    if IsValid(self.playerRagdoll) then
        self.playerRagdoll:Remove()
        self.playerRagdoll = nil
    end
    for k, v in ipairs(self.showRoom) do
        if IsValid(v) then
            v:Remove()
        end
    end
    if saveAngles then
        Aden_DC.LocalPlayer:SetEyeAngles(saveAngles)
    end
    Aden_DC.Config.showRoom = Aden_DC.Config.baseRoom
end

function Aden_DC.ClientSideMenu:NewMaterial(path_color)
    local factionMat = {}
    factionMat[1] = Material(path_color .. "btn_hover.png")
    factionMat[2] = Material(path_color .. "slide.png")
    factionMat[3] = Material(path_color .. "btn2_hover.png")
    factionMat[4] = Material(path_color .. "btn3_hover.png")
    factionMat[5] = Material(path_color .. "y.png")
    factionMat[6] = Material(path_color .. "desc.png")
    factionMat[7] = Material(path_color .. "entry.png")
    factionMat[8] = Material(path_color .. "m.png")
    return factionMat
end
