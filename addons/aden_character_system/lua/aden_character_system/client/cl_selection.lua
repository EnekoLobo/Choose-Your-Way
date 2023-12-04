function Aden_DC.ClientSideMenu:SelectionMenu(frame, arrayCharacter, id)
    Aden_DC.Buttons:removeView("Informations")
    Aden_DC.Buttons:addView(vector_zero, angle_zero, "Informations", false)

    if IsValid(self.playerRagdoll) then
        for i = 0, 31 do
            self.playerRagdoll:SetSubMaterial(i)
        end
        if arrayCharacter.infoClothes and arrayCharacter.infoClothes.model then
            self:SetClothes(arrayCharacter)
        else
            self.playerRagdoll:SetModel(arrayCharacter.cModel)
            for k,v in pairs(arrayCharacter.bodyGroups) do
                self.playerRagdoll:SetBodygroup(k, v)
            end
        end
        local idSeq = self.playerRagdoll:LookupSequence("walk_all")
        self.playerRagdoll:ResetSequence(idSeq)
        self.playerRagdoll:SetModelScale(arrayCharacter.mScale or 1, 0)
    end

    local age = Aden_DC.Config.CurrentYears - arrayCharacter.dBirth.y
    if Aden_DC.Config.DisableDateAge then
        age = "XX"
    end
    if not Aden_DC.Config.saveInformations["job"] then
        arrayCharacter.cJob = GAMEMODE.DefaultTeam
    end

    local layoutMenu = Aden_DC.Buttons:createButton()
    layoutMenu:SetSize(460, 430)
    layoutMenu:SetPos(20, 150)
    layoutMenu:SetIdView("Informations")
    layoutMenu.Paint = function(self, w, h, x, y)
        surface.SetDrawColor(255, 255, 255, 245)
        surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[7])
        surface.DrawTexturedRect(x, y, w, h)
        draw.DrawText(Aden_DC:GetPhrase("charselect"), "ADCFont::6", x+w/2, y+20, color_white, TEXT_ALIGN_CENTER)
        draw.DrawText(arrayCharacter.firstName .. " " .. arrayCharacter.lastName .. "\n" .. age .. " " .. Aden_DC:GetPhrase("age"), "ADCFont::1", x+w/2, y+80, color_white, TEXT_ALIGN_CENTER)
        if DarkRP then
            local marginH = 0
            if arrayCharacter.cJob and RPExtraTeams[arrayCharacter.cJob] then
                draw.DrawText(RPExtraTeams[arrayCharacter.cJob].name, "ADCFont::1", x+w/2, y+155, color_white, TEXT_ALIGN_CENTER)
                marginH = marginH + 1
            end
            if arrayCharacter.cMoney then
                draw.DrawText(DarkRP.formatMoney(Aden_DC.Config.saveInformations["money"] and arrayCharacter.cMoney or Aden_DC.LocalPlayer:getDarkRPVar("money")), "ADCFont::1", x+w/2, y+155 + marginH*h/11, color_white, TEXT_ALIGN_CENTER)
                marginH = marginH + 1
            end
        end
    end

    local Update = Aden_DC.Buttons:createButton()
    Update:SetSize(200, 60)
    Update:SetPos(150, 410)
    Update:SetIdView("Informations")
    Update.Paint = function(self, w, h, x, y)
        surface.SetDrawColor(255, 255, 255, 225)
        if self:IsHovered() then
            surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[17])
            frame:SetCursor("hand")
        else
            surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[16])
        end
        surface.DrawTexturedRect(x, y, w, h)
        draw.DrawText(Aden_DC:GetPhrase("update"), "ADCFont::1", x+w/2, y+h/5, color_white, TEXT_ALIGN_CENTER)
    end
    Update.DoClick = function()
        self:RequestMenu(frame, function(firstName, lastName)
            if DarkRP then
                if Aden_DC.Config.saveInformations["money"] and arrayCharacter.cMoney < Aden_DC.Config.PriceName then
                    self:sendPopup(Aden_DC:GetPhrase("cantbuy"))
                    return
                elseif !Aden_DC.Config.saveInformations["money"] and Aden_DC.LocalPlayer:getDarkRPVar("money") < Aden_DC.Config.PriceName then
                    self:sendPopup(Aden_DC:GetPhrase("cantbuy"))
                    return
                end
            end
            net.Start("ADC::UpdateName")
            net.WriteUInt(1, 8)
            net.WriteUInt(id, 8)
            net.WriteString(firstName)
            net.WriteString(lastName)
            net.SendToServer()
        end, "charupda", " " .. DarkRP.formatMoney(Aden_DC.Config.PriceName))
    end

    if Aden_DC.Config.changeModel then
        local modelUpdate = Aden_DC.Buttons:createButton()
        modelUpdate:SetSize(60, 60)
        modelUpdate:SetPos(400, 410)
        modelUpdate:SetIdView("Informations")
        modelUpdate.Paint = function(self, w, h, x, y)
            surface.SetDrawColor(255, 255, 255, 225)
            if self:IsHovered() then
                surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[17])
                frame:SetCursor("hand")
            else
                surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[16])
            end
            surface.DrawTexturedRect(x, y, w, h)
            draw.DrawText("+", "ADCFont::1", x+w/2, y+h/5, color_white, TEXT_ALIGN_CENTER)
        end
        modelUpdate.DoClick = function()
            self:OpenModel(frame, arrayCharacter, 15, Aden_DC.Config.Model, nil, nil, id)
        end
    end

    local Select = Aden_DC.Buttons:createButton()
    Select:SetSize(200, 60)
    Select:SetPos(40, 490)
    Select:SetIdView("Informations")
    Select.Paint = function(self, w, h, x, y)
        surface.SetDrawColor(255, 255, 255, 225)
        if self:IsHovered() then
            surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[17])
            frame:SetCursor("hand")
        else
            surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[16])
        end
        surface.DrawTexturedRect(x, y, w, h)
        draw.DrawText(Aden_DC:GetPhrase("select"), "ADCFont::1", x+w/2, y+h/5, color_white, TEXT_ALIGN_CENTER)
    end
    Select.DoClick = function()
        if self.selectedCharacter == id then
            self:sendPopup(Aden_DC:GetPhrase("charactual"))
            return
        end
        self:runExit(true, function()
            net.Start("ADC::CharacterNetwork")
            net.WriteUInt(2, 8)
            net.WriteUInt(id, 8)
            net.SendToServer()
        end)
    end

    local Remove = Aden_DC.Buttons:createButton()
    Remove:SetSize(200, 60)
    Remove:SetPos(260, 490)
    Remove:SetIdView("Informations")
    Remove.Paint = function(self, w, h, x, y)
        surface.SetDrawColor(255, 255, 255, 225)
        if self:IsHovered() then
            surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[17])
            frame:SetCursor("hand")
        else
            surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[16])
        end
        surface.DrawTexturedRect(x, y, w, h)
        if Aden_DC.Config.EnableDelete then
            draw.DrawText(Aden_DC:GetPhrase("delete"), "ADCFont::1", x+w/2, y+h/5, color_white, TEXT_ALIGN_CENTER)
        else
            draw.DrawText(Aden_DC:GetPhrase("delete"), "ADCFont::1", x+w/2, y+h/5, Aden_DC.ClientSideMenu.Colors["red"], TEXT_ALIGN_CENTER)
        end
    end
    Remove.DoClick = function()
        if Aden_DC.Config.EnableDelete then
            self:ConfirmeDelete(frame, arrayCharacter, id)
        end
    end
end

function Aden_DC.ClientSideMenu:ConfirmeDelete(frame, arrayCharacter, id)
    Aden_DC.Buttons:removeView("Informations")
    Aden_DC.Buttons:addView(vector_zero, angle_zero, "Informations", false)

    local layoutMenu = Aden_DC.Buttons:createButton()
    layoutMenu:SetSize(500, 235)
    layoutMenu:SetPos(0, 200)
    layoutMenu:SetIdView("Informations")
    layoutMenu.Paint = function(self, w, h, x, y)
        surface.SetDrawColor(255, 255, 255, 245)
        surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[7])
        surface.DrawTexturedRect(x, y, w, h)
        draw.DrawText(Aden_DC:GetPhrase("charconf"), "ADCFont::6", x+w/2, y+20, color_white, TEXT_ALIGN_CENTER)
        draw.DrawText(Aden_DC.Config.customMessageDelete and Aden_DC.Config.customMessageDelete or (arrayCharacter.firstName .. " " .. arrayCharacter.lastName), "ADCFont::1", x+w/2, y+85, color_white, TEXT_ALIGN_CENTER)
    end

    local Remove = Aden_DC.Buttons:createButton()
    Remove:SetSize(200, 60)
    Remove:SetPos(40, 350)
    Remove:SetIdView("Informations")
    Remove.Paint = function(self, w, h, x, y)
        surface.SetDrawColor(255, 255, 255, 225)
        if self:IsHovered() then
            surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[17])
            frame:SetCursor("hand")
        else
            surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[16])
        end
        surface.DrawTexturedRect(x, y, w, h)
        draw.DrawText(Aden_DC:GetPhrase("delete"), "ADCFont::1", x+w/2, y+h/5, color_white, TEXT_ALIGN_CENTER)
    end
    Remove.DoClick = function()
        self:runExit(false, function()
            net.Start("ADC::CharacterNetwork")
            net.WriteUInt(3, 8)
            net.WriteUInt(id, 8)
            net.SendToServer()
        end)
    end

    local Cancel = Aden_DC.Buttons:createButton()
    Cancel:SetSize(200, 60)
    Cancel:SetPos(270, 350)
    Cancel:SetIdView("Informations")
    Cancel.Paint = function(self, w, h, x, y)
        surface.SetDrawColor(255, 255, 255, 225)
        if self:IsHovered() then
            surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[17])
            frame:SetCursor("hand")
        else
            surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[16])
        end
        surface.DrawTexturedRect(x, y, w, h)
        draw.DrawText(Aden_DC:GetPhrase("cancel"), "ADCFont::1", x+w/2, y+h/5, color_white, TEXT_ALIGN_CENTER)
    end
    Cancel.DoClick = function()
        self:SelectionMenu(frame, arrayCharacter, id)
    end
end
