function Aden_DC.ClientSideMenu:RequestMenu(frame, callback, text, price)
    Aden_DC.Buttons:removeView("Informations")
    Aden_DC.Buttons:addView(vector_zero, angle_zero, "Informations", false)

    local layoutMenu = Aden_DC.Buttons:createButton()
    layoutMenu:SetSize(460, 430)
    layoutMenu:SetPos(20, 150)
    layoutMenu:SetIdView("Informations")
    layoutMenu.Paint = function(self, w, h, x, y)
        surface.SetDrawColor(255, 255, 255, 245)
        surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[7])
        surface.DrawTexturedRect(x, y, w, h)
        draw.DrawText(string.Replace(Aden_DC:GetPhrase(text or "nameun"), "\n", ""), "ADCFont::6", x+w/2, y+20, color_white, TEXT_ALIGN_CENTER)
    end

    local firstName = Aden_DC.Buttons:createButton()
    firstName:SetSize(400, 100)
    firstName:SetPos(50, 240)
    firstName:SetIdView("Informations")
    firstName:SetTextEntry(Aden_DC:GetPhrase("firstname"), frame)
    firstName.entryLoad = function(mEntry)
        mEntry.maxChar = 14
        mEntry.nameEntry = true
    end
    firstName.Paint = function(self, w, h, x, y)
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[20])
        surface.DrawTexturedRect(x, y, w, h)

        surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[6])
        surface.DrawTexturedRect(x+w/15, y+h/4, h/2, h/2)
        if self:IsHovered() then
            frame:SetCursor("beam")
        end
        self:DrawTextEntry(x + w/4, y + h/3, true)
    end

    local lastName = Aden_DC.Buttons:createButton()
    lastName:SetSize(400, 100)
    lastName:SetPos(50, 365)
    lastName:SetIdView("Informations")
    lastName:SetTextEntry(Aden_DC:GetPhrase("lastname"), frame)
    lastName.entryLoad = function(mEntry)
        mEntry.maxChar = 14
        mEntry.nameEntry = true
    end
    lastName.Paint = function(self, w, h, x, y)
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[20])
        surface.DrawTexturedRect(x, y, w, h)

        surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[6])
        surface.DrawTexturedRect(x+w/15, y+h/4, h/2, h/2)
        if self:IsHovered() then
            frame:SetCursor("beam")
        end
        self:DrawTextEntry(x + w/4, y + h/3, true)
    end

    local valideButton = Aden_DC.Buttons:createButton()
    valideButton:SetSize(200, 60)
    valideButton:SetPos(150, 490)
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
        draw.DrawText(Aden_DC:GetPhrase("valide") .. (price or ""), "ADCFont::1", x+w/2, y+h/5,color_white, TEXT_ALIGN_CENTER)
    end
    valideButton.DoClick = function()
        if callback and firstName:GetText() != Aden_DC:GetPhrase("firstname") and lastName:GetText() != Aden_DC:GetPhrase("lastName") then
            callback(firstName:GetText(), lastName:GetText())
        end
    end
end

net.Receive("ADC::UpdateName", function()
    Aden_DC.ClientSideMenu.NeedRequest = true
end)
