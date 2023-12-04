function Aden_DC.ClientSideMenu:CreationMenu(frame)
    Aden_DC.Buttons:removeView("Informations")
    Aden_DC.Buttons:addView(vector_zero, angle_zero, "Informations", false)

    if IsValid(self.playerRagdoll) then
        for i = 0, 31 do
            self.playerRagdoll:SetSubMaterial(i)
        end
        self.playerRagdoll:SetModel(Aden_DC.Config.Model[1])
        self.playerRagdoll:SetModelScale(1)
        for k,v in ipairs(self.playerRagdoll:GetBodyGroups()) do
            self.playerRagdoll:SetBodygroup(k, 0)
        end
        local idSeq = self.playerRagdoll:LookupSequence("walk_all")
        self.playerRagdoll:ResetSequence(idSeq)
    end

    local layoutMenu = Aden_DC.Buttons:createButton()
    local sizeY = 835
    if Aden_DC.Config.DisableDateAge then
        sizeY = sizeY - 125
    end
    if Aden_DC.Config.DisableDescription then
        sizeY = sizeY - 305
    end
    if Aden_DC.Config.DisableLastName then
        sizeY = sizeY - 125
    end
    layoutMenu:SetSize(460, sizeY)
    layoutMenu:SetPos(20, 60)
    layoutMenu:SetIdView("Informations")
    layoutMenu.Paint = function(self, w, h, x, y)
        surface.SetDrawColor(255, 255, 255, 245)
        surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[7])
        surface.DrawTexturedRect(x, y, w, h)
        draw.DrawText(Aden_DC:GetPhrase("crea"), "ADCFont::6", x+w/2, y+20, color_white, TEXT_ALIGN_CENTER)
    end

    local firstName = Aden_DC.Buttons:createButton()
    firstName:SetSize(400, 100)
    firstName:SetPos(50, 150)
    firstName:SetIdView("Informations")
    firstName:SetTextEntry(Aden_DC:GetPhrase("firstname"), frame)
    firstName.entryLoad = function(mEntry)
        if Aden_DC.Config.UseNumberName then
            mEntry:SetNumeric(true)
            mEntry.maxChar = Aden_DC.Config.UseNumberName
            local str = ""
            for i = 1, Aden_DC.Config.UseNumberName do
                str = str .. math.random(0, 9)
            end
            mEntry:SetText(str)
            mEntry:SetCaretPos(Aden_DC.Config.UseNumberName)
        else
            mEntry.nameEntry = true
            mEntry.maxChar = Aden_DC.Config.MaxChar or 14
        end
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

    local lastName
    local moveYName = 0
    if not Aden_DC.Config.DisableLastName then
        lastName = Aden_DC.Buttons:createButton()
        lastName:SetSize(400, 100)
        lastName:SetPos(50, 275)
        lastName:SetIdView("Informations")
        lastName:SetTextEntry(Aden_DC:GetPhrase("lastname"), frame)
        lastName.entryLoad = function(mEntry)
            mEntry.maxChar = Aden_DC.Config.MaxChar or 14
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
    else
        moveYName = -125
    end

    local d, m, y, age, cDesc

    if !Aden_DC.Config.DisableDateAge then
        if Aden_DC.Config.YearsOld then
            age = Aden_DC.Buttons:createButton()
            age:SetSize(400, 85)
            age:SetPos(50, 400 + moveYName)
            age:SetIdView("Informations")
            age:SetTextEntry(Aden_DC:GetPhrase("age2"), frame, nil, Aden_DC.Config.DisableDateAge and "UNVAILABLE" or "18")
            age.entryLoad = function(mEntry)
                mEntry:SetNumeric(true)
                mEntry.maxChar = 2
                if Aden_DC.Config.DisableDateAge then
                    mEntry:SetEditable(false)
                end
            end
            age.customCheck = function(txt)
                txt = tonumber((txt == "" and "0" or txt)) or 0
                return txt < 1 or txt > 99
            end
            age.Paint = function(self, w, h, x, y)
                surface.SetDrawColor(255, 255, 255)
                surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[20])
                surface.DrawTexturedRect(x, y, w, h)

                surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[8])
                surface.DrawTexturedRect(x+w/15, y+h/4, h/2, h/2)
                if self:IsHovered() then
                    frame:SetCursor("beam")
                end
                self:DrawTextEntry(x + w/4, y + h/3.8)
            end
        else
            d = Aden_DC.Buttons:createButton()
            d:SetSize(110, 90)
            d:SetPos(50, 400 + moveYName)
            d:SetIdView("Informations")
            d:SetTextEntry(Aden_DC:GetPhrase("day"), frame, nil, "01")
            d.entryLoad = function(mEntry)
                mEntry:SetNumeric(true)
                mEntry.maxChar = 2
            end
            d.customCheck = function(txt)
                txt = tonumber((txt == "" and "0" or txt)) or 0
                return txt < 1 or txt > 31
            end
            d.Paint = function(self, w, h, x, y)
                surface.SetDrawColor(255, 255, 255)
                surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[21])
                surface.DrawTexturedRect(x, y, w, h)

                surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[8])
                surface.DrawTexturedRect(x + w/8, y + h/2.5, h/4, h/4)
                if self:IsHovered() then
                    frame:SetCursor("beam")
                end
                self:DrawTextEntry(x + w/2.3, y + h/3.5)
            end

            m = Aden_DC.Buttons:createButton()
            m:SetSize(110, 90)
            m:SetPos(180, 400 + moveYName)
            m:SetIdView("Informations")
            m:SetTextEntry(Aden_DC:GetPhrase("month"), frame, nil, "01")
            m.entryLoad = function(mEntry)
                mEntry:SetNumeric(true)
                mEntry.maxChar = 2
            end
            m.customCheck = function(txt)
                txt = tonumber((txt == "" and "0" or txt)) or 0
                return txt < 1 or txt > 12
            end
            m.Paint = function(self, w, h, x, y)
                surface.SetDrawColor(255, 255, 255)
                surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[21])
                surface.DrawTexturedRect(x, y, w, h)

                surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[8])
                surface.DrawTexturedRect(x + w/8, y + h/2.5, h/4, h/4)
                if self:IsHovered() then
                    frame:SetCursor("beam")
                end
                self:DrawTextEntry(x + w/2.3, y + h/3.5)
            end

            y = Aden_DC.Buttons:createButton()
            y:SetSize(140, 90)
            y:SetPos(310, 400 + moveYName)
            y:SetIdView("Informations")
            y:SetTextEntry(Aden_DC:GetPhrase("years"), frame, nil, Aden_DC.Config.MinimumYears)
            y.entryLoad = function(mEntry)
                mEntry:SetNumeric(true)
                if Aden_DC.Config.MinimumYears < 0 then
                    mEntry.maxChar = 5
                    mEntry.allowNegatif = true
                else
                    mEntry.maxChar = 4
                end
            end
            y.customCheck = function(txt)
                txt = tonumber((txt == "" and "0" or txt)) or 0
                return txt < Aden_DC.Config.MinimumYears or txt > Aden_DC.Config.CurrentYears
            end
            y.Paint = function(self, w, h, x, y)
                surface.SetDrawColor(255, 255, 255)
                surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[18])
                surface.DrawTexturedRect(x, y, w, h)

                surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[8])
                surface.DrawTexturedRect(x + w/8, y + h/2.5, h/4, h/4)
                if self:IsHovered() then
                    frame:SetCursor("beam")
                end
                self:DrawTextEntry(x + w/2.8, y + h/3.5)
            end
        end
    end

    if !Aden_DC.Config.DisableDescription then
        cDesc = Aden_DC.Buttons:createButton()
        cDesc:SetSize(405, 270)
        if Aden_DC.Config.DisableDateAge then
            cDesc:SetPos(50, 400 + moveYName)
        else
            cDesc:SetPos(50, 515 + moveYName)
        end
        cDesc:SetIdView("Informations")
        cDesc:SetTextEntry(Aden_DC:GetPhrase("desc"), frame, true)
        cDesc.entryLoad = function() end
        cDesc.Paint = function(self, w, h, x, y)
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[19])
            surface.DrawTexturedRect(x, y, w, h)

            if self:IsHovered() then
                frame:SetCursor("beam")
            end
            self:DrawTextEntry(x + w/15, y + h/15)
        end
    end

    local valideButton = Aden_DC.Buttons:createButton()
    valideButton:SetSize(200, 60)
    valideButton:SetPos(150, sizeY-20)
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
        if firstName:GetText() == "" or !firstName.isReady then
            return
        elseif lastName and (lastName:GetText() == "" or !lastName.isReady) then
            return
        end
        if !Aden_DC.Config.DisableDateAge then
            if Aden_DC.Config.YearsOld then
                if age:GetText() == "" or !age.isReady or age.customCheck(age:GetText()) then
                    return
                end
            else
                if d:GetText() == "" or !d.isReady or d.customCheck(d:GetText()) then
                    return
                elseif m:GetText() == "" or !m.isReady or m.customCheck(m:GetText()) then
                    return
                elseif y:GetText() == "" or !y.isReady or y.customCheck(y:GetText()) then
                    return
                end
            end
        end
        local arrayCharacter = {
            firstName = firstName:GetText(),
        }
        if Aden_DC.Config.DisableLastName then
            arrayCharacter.lastName = ""
        else
            arrayCharacter.lastName = lastName:GetText()
        end

        if Aden_DC.Config.DisableDescription then
            arrayCharacter.cDesc = ""
        else
            arrayCharacter.cDesc = cDesc:GetText() != "Description (Optional)" and cDesc:GetText() or ""
        end
        if Aden_DC.Config.DisableDateAge then
            arrayCharacter.dBirth = {
                d = 1,
                m = 1,
                y = Aden_DC.Config.CurrentYears
            }
        else
            if Aden_DC.Config.YearsOld then
                arrayCharacter.dBirth = {
                    d = 1,
                    m = 1,
                    y = Aden_DC.Config.CurrentYears - tonumber(age:GetText())
                }
            else
                arrayCharacter.dBirth = {
                    d = tonumber(d:GetText()),
                    m = tonumber(m:GetText()),
                    y = tonumber(y:GetText())
                }
            end
        end
        if CLOTHESMOD and Aden_DC.Config.Support["Clothes Venatuss"] then
            self:OpenModelClothes(frame, arrayCharacter)
        else
            if Aden_DC.Config.enableFaction then
                self:OpenFaction(frame, arrayCharacter)
            else
                self:OpenModel(frame, arrayCharacter, 15, Aden_DC.Config.Model)
            end
        end
    end
end

function Aden_DC.ClientSideMenu:OpenFaction(frame, arrayCharacter)
    Aden_DC.Buttons:removeView("Informations")
    Aden_DC.Buttons:addView(vector_zero, angle_zero, "Informations", false)

    local cFaction
    local layoutMenu = Aden_DC.Buttons:createButton()
    layoutMenu:SetSize(460, 430)
    layoutMenu:SetPos(20, 150)
    layoutMenu:SetIdView("Informations")
    layoutMenu.Paint = function(self, w, h, x, y)
        surface.SetDrawColor(255, 255, 255, 245)
        surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[7])
        surface.DrawTexturedRect(x, y, w, h)
        draw.DrawText(Aden_DC:GetPhrase("chosefac"), "ADCFont::6", x+w/2, y+20, color_white, TEXT_ALIGN_CENTER)
        if cFaction then
            draw.DrawText(Aden_DC.Config.listFaction[cFaction].name, "ADCFont::6", x+w/2, y+65, color_white, TEXT_ALIGN_CENTER)
        else
            draw.DrawText("...", "ADCFont::6", x+w/2, y+65, color_white, TEXT_ALIGN_CENTER)
        end
    end

    local count = 0
    for k, v in ipairs(Aden_DC.Config.listFaction) do
        if v.hide then continue end
        count = count + 1
    end

    local w, h = 200, 200
    local offsetx, offsety, movey = 0, 0, 2
    if count == 3 then
        w, h = 130, 130
        offsetx, offsety, movey = -15, 30, 3
    elseif count > 3 then
        w, h = 90, 90
        offsetx, offsety, movey = -10, 10, 4
    end

    local id = 0
    for k, v in ipairs(Aden_DC.Config.listFaction) do
        if v.hide then continue end
        local first = Aden_DC.Buttons:createButton()
        first:SetSize(w, h)
        first:SetPos(40 + (id)%movey * (w + 30 + offsetx), 270 + (math.floor((id)/movey)) * (h + 30) + offsety)
        first:SetIdView("Informations")
        first.Paint = function(self, w, h, x, y)
            surface.SetDrawColor(255, 255, 255)
            if self:IsHovered() then
                surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[11])
                frame:SetCursor("hand")
                cFaction = k
            elseif arrayCharacter.cFaction == k then
                surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[11])
            else
                if v.color then
                    surface.SetDrawColor(v.color)
                    surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[11])
                else
                    surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[10])
                end
            end
            surface.DrawTexturedRect(x, y, w, h)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(v.mat)
            surface.DrawTexturedRectRotated(x+w/2, y+h/2, w/1.5, h/1.5, 0)
        end
        first.DoClick = function()
            Aden_DC.Config.showRoom = v.background and v.background or Aden_DC.Config.baseRoom
            self.npcOffset = v.npcOffset and v.npcOffset or Vector(0, 0, 0)
            arrayCharacter.cFaction = k
            cFaction = k
        end
        id = id + 1
    end

    local valideButton = Aden_DC.Buttons:createButton()
    valideButton:SetSize(200, 60)
    valideButton:SetPos(150, 495)
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
        draw.DrawText(Aden_DC:GetPhrase("valide"), "ADCFont::1", x+w/2, y+h/5, color_white, TEXT_ALIGN_CENTER)
    end
    valideButton.DoClick = function()
        if arrayCharacter.cFaction then
            if Aden_DC.Config.listFaction[arrayCharacter.cFaction].class then
                self:OpenClass(frame, arrayCharacter, Aden_DC.Config.listFaction[arrayCharacter.cFaction])
            else
                local factionMat
                if Aden_DC.Config.listFaction[arrayCharacter.cFaction].path_color then
                    factionMat = self:NewMaterial(Aden_DC.Config.listFaction[arrayCharacter.cFaction].path_color)
                end
                self:OpenJobs(frame, arrayCharacter, Aden_DC.Config.listFaction[arrayCharacter.cFaction].defaultJobs, factionMat)
            end
        end
    end
end

function Aden_DC.ClientSideMenu:OpenClass(frame, arrayCharacter, cFaction)
    Aden_DC.Buttons:removeView("Informations")
    Aden_DC.Buttons:addView(vector_zero, angle_zero, "Informations", false)

    local factionMat
    if cFaction.path_color then
        factionMat = self:NewMaterial(cFaction.path_color)
    end

    local cClass
    local layoutMenu = Aden_DC.Buttons:createButton()
    layoutMenu:SetSize(460, 430)
    layoutMenu:SetPos(20, 150)
    layoutMenu:SetIdView("Informations")
    layoutMenu.Paint = function(self, w, h, x, y)
        surface.SetDrawColor(255, 255, 255, 245)
        surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[7])
        surface.DrawTexturedRect(x, y, w, h)
        draw.DrawText(Aden_DC:GetPhrase("choseclass"), "ADCFont::6", x+w/2, y+20, color_white, TEXT_ALIGN_CENTER)
        if cClass then
            draw.DrawText(cFaction.class[cClass].name, "ADCFont::6", x+w/2, y+65, color_white, TEXT_ALIGN_CENTER)
        else
            draw.DrawText("...", "ADCFont::6", x+w/2, y+65, color_white, TEXT_ALIGN_CENTER)
        end
    end

    local w, h = 200, 200
    local offsetx, offsety, movey = 0, 0, 2
    if #cFaction.class == 3 then
        w, h = 130, 130
        offsetx, offsety, movey = -15, 30, 3
    elseif #cFaction.class > 3 then
        w, h = 90, 90
        offsetx, offsety, movey = -10, 10, 4
    end

    for k, v in ipairs(cFaction.class) do
        if v.hide then continue end
        local first = Aden_DC.Buttons:createButton()
        first:SetSize(w, h)
        first:SetPos(40 + (k-1)%movey * (w + 30 + offsetx), 270 + (math.floor((k-1)/movey)) * (h + 30) + offsety)
        first:SetIdView("Informations")
        first.Paint = function(self, w, h, x, y)
            surface.SetDrawColor(255, 255, 255)
            if self:IsHovered() then
                surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[11])
                frame:SetCursor("hand")
                cClass = k
            elseif arrayCharacter.cClass == k then
                surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[11])
            else
                if v.color or cFaction.color then
                    surface.SetDrawColor(v.color or cFaction.color)
                    surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[11])
                else
                    surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[10])
                end
            end
            surface.DrawTexturedRect(x, y, w, h)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(v.mat)
            surface.DrawTexturedRectRotated(x+w/2, y+h/2, w/1.5, h/1.5, 0)
        end
        first.DoClick = function()
            Aden_DC.Config.showRoom = v.background and v.background or cFaction.background or Aden_DC.Config.baseRoom
            self.npcOffset = v.npcOffset and v.npcOffset or cFaction.npcOffset or Vector(0, 0, 0)
            arrayCharacter.cClass = k
            cClass = k
        end
    end

    local valideButton = Aden_DC.Buttons:createButton()
    valideButton:SetSize(200, 60)
    valideButton:SetPos(150, 495)
    valideButton:SetIdView("Informations")
    valideButton.Paint = function(self, w, h, x, y)
        surface.SetDrawColor(255, 255, 255, 225)
        if self:IsHovered() then
            surface.SetMaterial(factionMat and factionMat[4] or Aden_DC.ClientSideMenu.Mat[17])
            frame:SetCursor("hand")
        else
            surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[16])
        end
        surface.DrawTexturedRect(x, y, w, h)
        draw.DrawText(Aden_DC:GetPhrase("valide"), "ADCFont::1", x+w/2, y+h/5, color_white, TEXT_ALIGN_CENTER)
    end
    valideButton.DoClick = function()
        if arrayCharacter.cClass then
            self:OpenJobs(frame, arrayCharacter, cFaction.class[arrayCharacter.cClass].defaultJobs, factionMat)
        end
    end
end


function Aden_DC.ClientSideMenu:OpenJobs(frame, arrayCharacter, jobs, factionMat)
    Aden_DC.Buttons:removeView("Informations")
    Aden_DC.Buttons:addView(vector_zero, angle_zero, "Informations", false)

    local cJob
    local jobsCount = math.min(table.Count(jobs), 6)
    local layoutMenu = Aden_DC.Buttons:createButton()
    layoutMenu:SetSize(460, 200 + 100 * jobsCount)
    layoutMenu:SetPos(20, 150)
    layoutMenu:SetIdView("Informations")
    layoutMenu:CreateLayout(frame, 105, 100, 20, 10, 25)
    layoutMenu.Paint = function(self, w, h, x, y)
        surface.SetDrawColor(255, 255, 255, 245)
        surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[7])
        surface.DrawTexturedRect(x, y, w, h)
        draw.DrawText(Aden_DC:GetPhrase("chosejob"), "ADCFont::6", x+w/2, y+20, color_white, TEXT_ALIGN_CENTER)
    end
    local i = 0
    local offset = 0
    for k, v in pairs(jobs) do
        local base = Aden_DC.Buttons:createButton()
        base:SetSize(400, 80)
        base:SetPos(50, 0)
        //base:SetIdView("Informations")
        base.Paint = function(self, w, h, x, y)
            surface.SetDrawColor(255, 255, 255)
            if self:IsHovered() then
                frame:SetCursor("hand")
            end
            if self:IsHovered() or arrayCharacter.cJob == k then
                surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[1])
            else
                surface.SetMaterial(factionMat and factionMat[1] or Aden_DC.ClientSideMenu.Mat[2])
            end
            surface.DrawTexturedRect(x, y, w, h)
            draw.DrawText(RPExtraTeams[k].name, "ADCFont::1", x+w/2, y+h/4,color_white, TEXT_ALIGN_CENTER)
        end
        base.DoClick = function()
            arrayCharacter.cJob = k
            if isstring(RPExtraTeams[k].model) then
                self.playerRagdoll:SetModel(RPExtraTeams[k].model)
            local idSeq = self.playerRagdoll:LookupSequence("walk_all")
                self.playerRagdoll:ResetSequence(idSeq)
            elseif RPExtraTeams[k].model[1] then
                self.playerRagdoll:SetModel(RPExtraTeams[k].model[1])
            local idSeq = self.playerRagdoll:LookupSequence("walk_all")
                self.playerRagdoll:ResetSequence(idSeq)
            end
        end
        i = i + 1
        layoutMenu:AddToLayout(base)
    end
    local valideButton = Aden_DC.Buttons:createButton()
    valideButton:SetSize(200, 60)
    valideButton:SetPos(150, 260 + 100 * jobsCount)
    valideButton:SetIdView("Informations")
    valideButton.Paint = function(self, w, h, x, y)
        surface.SetDrawColor(255, 255, 255, 225)
        if self:IsHovered() then
            surface.SetMaterial(factionMat and factionMat[4] or Aden_DC.ClientSideMenu.Mat[17])
            frame:SetCursor("hand")
        else
            surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[16])
        end
        surface.DrawTexturedRect(x, y, w, h)
        draw.DrawText(Aden_DC:GetPhrase("valide"), "ADCFont::1", x+w/2, y+h/5,color_white, TEXT_ALIGN_CENTER)
    end
    valideButton.DoClick = function()
        if arrayCharacter.cJob then
            self:OpenModel(frame, arrayCharacter, 15, isstring(RPExtraTeams[arrayCharacter.cJob].model) and {RPExtraTeams[arrayCharacter.cJob].model} or RPExtraTeams[arrayCharacter.cJob].model, Aden_DC.Config.listFaction[arrayCharacter.cFaction].color, factionMat)
        end
    end
end

function Aden_DC.ClientSideMenu:OpenModel(frame, arrayCharacter, numModel, cModel, cColor, factionMat, update)
    Aden_DC.Buttons:removeView("Informations")
    Aden_DC.Buttons:addView(vector_zero, angle_zero, "Informations", false)

    if cModel[1] then
        self.playerRagdoll:SetModel(cModel[1])
        local idSeq = self.playerRagdoll:LookupSequence("walk_all")
        self.playerRagdoll:ResetSequence(idSeq)
    end

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
            if cColor then
                surface.SetDrawColor(cColor)
            else
                surface.SetDrawColor(255, 255, 255, 225)
            end
            surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[12])
            surface.DrawTexturedRect(50, y+7, 400, 40)
            draw.RoundedBox(16, x, y, w, h, cColor or Aden_DC.ClientSideMenu.Colors["blue"])
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
    /*for k, v in ipairs(Aden_DC.Config.Model) do
        if Aden_DC.Config.enableFaction and arrayCharacter.cFaction then
            if !Aden_DC.Config.listFaction[arrayCharacter.cFaction].skin[k] then
                continue
            end
        end*/
    for k, v in ipairs(cModel) do
        idArrow = idArrow + 1
        if !Aden_DC.Model:IsValidModel(v) then
            Aden_DC.Model:GenerateSpawnIcon(v)
        end
        local background = Aden_DC.Buttons:createButton()
        background:SetSize(115, 115)
        //background:SetPos(70 + ((posY-1)%3) * 125, 230 + math.floor((posY-1)/3) * 125)
        background:SetPos(70 + ((posY-1)%3) * 125, 0)
        background.line = idArrow%3 != 0
        background.DoClick = function()
            arrayCharacter.cModel = k
            self.playerRagdoll:SetModel(v)
            local idSeq = self.playerRagdoll:LookupSequence("walk_all")
            self.playerRagdoll:ResetSequence(idSeq)
        end

        local model = Aden_DC.Model:GetSpawnIcon(v)
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
                if cColor then
                    surface.SetDrawColor(cColor)
                    surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[11])
                else
                    surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[10])
                end
            end
            surface.DrawTexturedRect(x, y, w, h)
            model:PaintManual()
        end
        layoutMenu:AddToLayout(background)
        posY = posY + 1
    end

    local valideButton = Aden_DC.Buttons:createButton()
    valideButton:SetSize(200, 60)
    valideButton:SetPos(150, 800)
    valideButton:SetIdView("Informations")
    valideButton.Paint = function(self, w, h, x, y)
        surface.SetDrawColor(255, 255, 255, 225)
        if self:IsHovered() then
            surface.SetMaterial(factionMat and factionMat[4] or Aden_DC.ClientSideMenu.Mat[17])
            frame:SetCursor("hand")
        else
            surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[16])
        end
        surface.DrawTexturedRect(x, y, w, h)
        draw.DrawText(Aden_DC:GetPhrase("valide"), "ADCFont::1", x+w/2, y+h/5,color_white, TEXT_ALIGN_CENTER)
    end
    valideButton.DoClick = function()
        if update then
            if !arrayCharacter.cModel or isstring(arrayCharacter.cModel) then
                arrayCharacter.cModel = 1
            end
            net.Start("ADC::CharacterNetwork")
            net.WriteUInt(4, 8)
            net.WriteUInt(update, 8)
            net.WriteUInt(arrayCharacter.cModel, 8)
            net.SendToServer()
        else
            self:OpenBodyGroup(frame, arrayCharacter)
        end
    end
end

function Aden_DC.ClientSideMenu:OpenBodyGroup(frame, arrayCharacter)
    Aden_DC.Buttons:removeView("Informations")
    Aden_DC.Buttons:addView(vector_zero, angle_zero, "Informations", false)

    local size = 0
    for k, v in ipairs(self.playerRagdoll:GetBodyGroups()) do
        if self.playerRagdoll:GetBodygroupCount(v.id) <= 1 then continue end
        size = size + 1
    end

    local layoutMenu = Aden_DC.Buttons:createButton()
    layoutMenu:SetSize(460, 835)
    layoutMenu:SetPos(20, 60)
    layoutMenu:SetIdView("Informations")
    layoutMenu:CreateLayout(frame, 90, 110, 15, 10, 20)
    layoutMenu.Paint = function(self, w, h, x, y)
        surface.SetDrawColor(255, 255, 255, 245)
        surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[7])
        surface.DrawTexturedRect(x, y, w, h)
        draw.DrawText(Aden_DC:GetPhrase("body"), "ADCFont::6", x+w/2, y+20, color_white, TEXT_ALIGN_CENTER)
    end

    arrayCharacter.bodyGroups = {}
    local i = 0

    for k, v in ipairs(self.playerRagdoll:GetBodyGroups()) do
        if self.playerRagdoll:GetBodygroupCount(v.id) <= 1 then continue end
        local id = 0
        local base = Aden_DC.Buttons:createButton()
        base:SetSize(400, 80)
        base:SetPos(50, 0)
        base.line = false
        base.offsetLayoutY = -75

        local Left = Aden_DC.Buttons:createButton()
        Left:SetSize(40, 40)
        Left:SetPos(80, 0)
        Left.line = true
        Left.Paint = function(self, w, h, x, y)
            surface.SetDrawColor(255, 255, 255)
            if self:IsHovered() then
                surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[14])
                frame:SetCursor("hand")
            else
                surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[13])
            end
            surface.DrawTexturedRect(x, y, w, h)
            draw.DrawText("<", "ADCFont::1", x+w/2, y+h/20,color_white, TEXT_ALIGN_CENTER)
        end
        Left.DoClick = function()
            id = (v.submodels[id-1] and id-1) or #v.submodels
            self.playerRagdoll:SetBodygroup(v.id, id)
            arrayCharacter.bodyGroups[v.id] = id
        end

        local Right = Aden_DC.Buttons:createButton()
        Right:SetSize(40, 40)
        Right:SetPos(380, 0)
        Right.line = false
        Right.offsetLayoutY = 25
        Right.Paint = function(self, w, h, x, y)
            surface.SetDrawColor(255, 255, 255)
            if self:IsHovered() then
                surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[14])
                frame:SetCursor("hand")
            else
                surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[13])
            end
            surface.DrawTexturedRect(x, y, w, h)
            draw.DrawText(">", "ADCFont::1", x+w/2, y+h/20,color_white, TEXT_ALIGN_CENTER)
        end
        Right.DoClick = function()
            id = (v.submodels[id+1] and id+1) or 0
            self.playerRagdoll:SetBodygroup(v.id, id)
            arrayCharacter.bodyGroups[v.id] = id
        end

        base.Paint = function(self, w, h, x, y)
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[20])
            surface.DrawTexturedRect(x, y, w, h)
            draw.DrawText(v.name, "ADCFont::1", x+w/2, y+h/4,color_white, TEXT_ALIGN_CENTER)
        end

        layoutMenu:AddToLayout(base)
        layoutMenu:AddToLayout(Left)
        layoutMenu:AddToLayout(Right)

        i = i + 1
    end

    local valideButton = Aden_DC.Buttons:createButton()
    valideButton:SetSize(200, 60)
    valideButton:SetPos(150, 810)
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
        self:runExit(false, function()
            net.Start("ADC::CharacterNetwork")
            net.WriteUInt(1, 8);
            Aden_DC.Nets:WriteTable(arrayCharacter)
            net.SendToServer()
        end)
    end
    if size == 0 or Aden_DC.Config.DisableBodyGroups then
        valideButton:DoClick()
    end
end
