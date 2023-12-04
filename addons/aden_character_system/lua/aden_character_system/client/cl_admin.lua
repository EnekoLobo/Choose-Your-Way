local AdminRequestInfo // The func who will receive the information of the player

surface.CreateFont("ADCFont::7", {
    font = "Tahoma",
    size = ScreenScale(5),
    weight = 0,
    extended = true
})

local scrW, scrH = ScrW(), ScrH()

hook.Add("OnScreenSizeChanged", "ADC::OnScreenSizeChanged::ChangeValue", function()
    scrW, scrH = ScrW(), ScrH()
end)

local function paintSubMenu(fake, self)
    local txt = self:GetText()
    self:SetText("")
    self.Paint = function(self, w, h)
        surface.SetDrawColor(255, 255, 255)
        if self:IsHovered() then
            surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[17])
        else
            surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[16])
        end
        surface.DrawTexturedRect(w/20, 0, w-w/20, h)
        draw.DrawText(txt, "ADCFont::7", w/2, h/8, color_white, TEXT_ALIGN_CENTER)
    end
    if fake then
        fake.Paint = function() end
    end
end

local function RequestReason(steamid64, selected)
    local time = SysTime()
    local layoutMenu = vgui.Create("DFrame")
    layoutMenu:SetSize(scrW/3, scrH/4)
    layoutMenu:Center()
    layoutMenu:SetTitle("")
    layoutMenu:MakePopup()
    layoutMenu:ShowCloseButton(false)
    layoutMenu.Paint = function(self, w, h)
        self:MoveToFront()
        Derma_DrawBackgroundBlur(self, time)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[24])
        surface.DrawTexturedRect(0, 0, w, h)

        draw.DrawText(Aden_DC:GetPhrase("charkill"), "ADCFont::2", w/2, h/8, color_white, TEXT_ALIGN_CENTER)
    end

    local btnClose = vgui.Create("DButton", layoutMenu)
    btnClose:SetSize(scrW/60, scrW/60)
    btnClose:SetPos(layoutMenu:GetWide() - btnClose:GetWide() - scrW/100, scrW/100)
    btnClose:SetText("")
    btnClose.Paint = function(self, w, h)
        surface.SetDrawColor(255, 255, 255)
        if self:IsHovered() then
            surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[13])
        else
            surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[14])
        end
        surface.DrawTexturedRect(0, 0, w, h)
        draw.DrawText("X", "ADCFont::2", w/2, h/30, color_white, TEXT_ALIGN_CENTER)
    end
    btnClose.DoClick = function()
        layoutMenu:Remove()
    end

    local base = vgui.Create("DPanel", layoutMenu)
    base:SetSize(layoutMenu:GetWide()/1.26, layoutMenu:GetTall()/4)
    base:Center()
    base.Paint = function(self, w, h)
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[22])
        surface.DrawTexturedRect(0, 0, w, h)
    end

    local Reason = vgui.Create("DTextEntry", base)
    Reason:SetSize(layoutMenu:GetWide()/1.5, layoutMenu:GetTall()/4)
    Reason:SetPos(base:GetTall()/2, 0)
    Reason:SetText(Aden_DC:GetPhrase("reason"))
    Reason:SetFont("ADCFont::2")
    Reason:SetDrawLanguageID(false)
    Reason.Paint = function(self, w, h)
        self:DrawTextEntryText(color_white, color_white, color_white)
    end

    local Validate = vgui.Create("DButton", layoutMenu)
    Validate:SetSize(layoutMenu:GetWide()/3, layoutMenu:GetTall()/5)
    Validate:SetPos(layoutMenu:GetWide()/8, layoutMenu:GetTall()/1.4)
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
        net.Start("ADC::AdminNetworking")
        net.WriteUInt(3, 8)
        net.WriteString(steamid64)
        net.WriteUInt(selected, 8)
        net.WriteString(Reason:GetText())
        net.SendToServer()
        layoutMenu:Remove()
    end

    local Cancel = vgui.Create("DButton", layoutMenu)
    Cancel:SetSize(layoutMenu:GetWide()/3, layoutMenu:GetTall()/5)
    Cancel:SetPos(layoutMenu:GetWide()/1.85, layoutMenu:GetTall()/1.4)
    Cancel:SetText("")
    Cancel.Paint = function(self, w, h)
        surface.SetDrawColor(255, 255, 255, 225)
        if self:IsHovered() then
            surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[17])
        else
            surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[16])
        end
        surface.DrawTexturedRect(0, 0, w, h)
        draw.DrawText(Aden_DC:GetPhrase("cancel"), "ADCFont::2", w/2, h/5, color_white, TEXT_ALIGN_CENTER)
    end
    Cancel.DoClick = function()
        layoutMenu:Remove()
    end
end

local function makeParentMargin(sizeX, sizeY, posX, posY, layoutMenu, mat)
    local base = vgui.Create("DPanel", layoutMenu)
    base:SetSize(sizeX, sizeY)
    base:SetPos(posX, posY)
    base.Paint = function(self, w, h)
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[mat or 22])
        surface.DrawTexturedRect(0, 0, w, h)
    end
    return base
end

local paintEntry = function(self, w, h)
    if self.baseText == self:GetText() then
        self:DrawTextEntryText(Aden_DC.ClientSideMenu.Colors["grey"], color_white, color_white)
        if self:HasFocus() then
            self:SetText("")
        end
    else
        self:DrawTextEntryText(color_white, color_white, color_white)
    end
end

function Aden_DC:OpenMenuAdmin()
    if !self.Config.Open.Acces[Aden_DC.LocalPlayer:GetUserGroup()] then return end
    local selected
    local arrayCharacter = {}
    local arrayLenght = 0
    local SteamID

    local layoutMenu = vgui.Create("DFrame")
    layoutMenu:SetSize(scrW/4, scrH/1.95)
    layoutMenu:Center()
    layoutMenu:SetTitle("")
    layoutMenu:MakePopup()
    layoutMenu:ShowCloseButton(false)
    layoutMenu.Paint = function(_, w, h)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[27])
        surface.DrawTexturedRect(w/15, 0, w-w/6.7, h)

        draw.DrawText(string.upper(Aden_DC:GetPhrase("charupda")), "ADCFont::5", w/2, h/25, color_white, TEXT_ALIGN_CENTER)
    end

    local btnClose = vgui.Create("DButton", layoutMenu)
    btnClose:SetSize(scrW/60, scrW/60)
    btnClose:SetPos(layoutMenu:GetWide() - btnClose:GetWide() - scrW/100 - layoutMenu:GetWide()/13.4, scrW/100)
    btnClose:SetText("")
    btnClose.Paint = function(self, w, h)
        surface.SetDrawColor(255, 255, 255)
        if self:IsHovered() then
            surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[14])
            surface.DrawTexturedRect(0, 0, w, h)
        end

        draw.DrawText("X", "ADCFont::2", w/2, h/30, color_white, TEXT_ALIGN_CENTER)
    end
    btnClose.DoClick = function()
        layoutMenu:Remove()
    end

    local base = makeParentMargin(layoutMenu:GetWide()/2.56, scrH/20, layoutMenu:GetWide()/10.5, scrH/15.42 + scrH/18*3, layoutMenu, 28)
    local firstName = vgui.Create("DTextEntry", base)
    firstName:SetSize(layoutMenu:GetWide()/2.7 - base:GetTall()/2, scrH/20)
    firstName:SetPos(base:GetTall()/4, 0)
    firstName:SetText(Aden_DC:GetPhrase("firstname"))
    firstName.baseText = Aden_DC:GetPhrase("firstname")
    firstName:SetFont("ADCFont::2")
    firstName:SetDrawLanguageID(false)
    firstName.Paint = paintEntry

    local base = makeParentMargin(layoutMenu:GetWide()/2.56, scrH/20, layoutMenu:GetWide()/2.01, scrH/15.42 + scrH/18*3, layoutMenu, 28)
    local lastName = vgui.Create("DTextEntry", base)
    lastName:SetSize(layoutMenu:GetWide()/2.7 - base:GetTall()/2, scrH/20)
    lastName:SetPos(base:GetTall()/4, 0)
    lastName:SetText(Aden_DC:GetPhrase("lastname"))
    lastName.baseText = Aden_DC:GetPhrase("lastname")
    lastName:SetFont("ADCFont::2")
    lastName:SetDrawLanguageID(false)
    lastName.Paint = paintEntry
    if !Aden_DC:havePermission(Aden_DC.LocalPlayer, "name") then
        firstName:SetEditable(false)
        lastName:SetEditable(false)
    end

    local base = makeParentMargin(layoutMenu:GetWide()/1.26, scrH/20, layoutMenu:GetWide()/10.5, scrH/15.42 + scrH/18*4, layoutMenu, 29)
    local cMoney = vgui.Create("DTextEntry", base)
    cMoney:SetSize(layoutMenu:GetWide()/1.35, scrH/20)
    cMoney:SetPos(base:GetTall()/4, 0)
    cMoney:SetText(Aden_DC:GetPhrase("money"))
    cMoney.baseText = Aden_DC:GetPhrase("money")
    cMoney:SetFont("ADCFont::2")
    cMoney:SetDrawLanguageID(false)
    cMoney.Paint = paintEntry
    if !Aden_DC:havePermission(Aden_DC.LocalPlayer, "money") then
        cMoney:SetEditable(false)
    end

    local base = makeParentMargin(layoutMenu:GetWide()/1.26, scrH/20, layoutMenu:GetWide()/10.5, scrH/15.42 + scrH/18*5, layoutMenu, 29)
    local cModel = vgui.Create("DTextEntry", base)
    cModel:SetSize(layoutMenu:GetWide()/1.35, scrH/20)
    cModel:SetPos(base:GetTall()/4, 0)
    cModel:SetText(Aden_DC:GetPhrase("pm"))
    cModel.baseText = Aden_DC:GetPhrase("pm")
    cModel:SetFont("ADCFont::2")
    cModel:SetDrawLanguageID(false)
    cModel.Paint = paintEntry
    if !Aden_DC:havePermission(Aden_DC.LocalPlayer, "model") then
        cModel:SetEditable(false)
    end

    local base = makeParentMargin(layoutMenu:GetWide()/1.26, scrH/20, layoutMenu:GetWide()/10.5, scrH/15.42 + scrH/18*6, layoutMenu, 29)
    local cDate = vgui.Create("DTextEntry", base)
    cDate:SetSize(layoutMenu:GetWide()/1.35, scrH/20)
    cDate:SetPos(base:GetTall()/4, 0)
    cDate:SetText(Aden_DC:GetPhrase("age2"))
    cDate.baseText = Aden_DC:GetPhrase("age2")
    cDate:SetFont("ADCFont::2")
    cDate:SetDrawLanguageID(false)
    cDate.Paint = paintEntry
    if !Aden_DC:havePermission(Aden_DC.LocalPlayer, "model") then
        cDate:SetEditable(false)
    end

    local Validate = vgui.Create("DButton", layoutMenu)
    Validate:SetSize(layoutMenu:GetWide()/3, scrH/24)
    Validate:SetPos(layoutMenu:GetWide()/8, scrH/15.42 + scrH/18*7 + scrH/200)
    Validate:SetText("")
    Validate.Paint = function(self, w, h)
        surface.SetDrawColor(255, 255, 255, 225)
        if self:IsHovered() then
            surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[17])
        else
            surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[16])
        end
        surface.DrawTexturedRect(0, 0, w, h)
        draw.DrawText(Aden_DC:GetPhrase("valide"), "ADCFont::2", w/2, h/8, color_white, TEXT_ALIGN_CENTER)
    end
    Validate.DoClick = function()
        if !selected or !arrayCharacter[selected] then return end
        net.Start("ADC::AdminNetworking")
        net.WriteUInt(2, 8)
        net.WriteString(SteamID:GetText())
        net.WriteUInt(selected, 8)
        if Aden_DC:havePermission(Aden_DC.LocalPlayer, "name") then
            arrayCharacter[selected].firstName = firstName:GetText()
            arrayCharacter[selected].lastName = lastName:GetText()
        end
        if Aden_DC:havePermission(Aden_DC.LocalPlayer, "money") then
            arrayCharacter[selected].cMoney = cMoney:GetText()
        end
        if Aden_DC:havePermission(Aden_DC.LocalPlayer, "model") then
            arrayCharacter[selected].cModel = cModel:GetText()
        end
        arrayCharacter[selected].dBirth.y = Aden_DC.Config.CurrentYears - cDate:GetText()
        Aden_DC.Nets:WriteTable(arrayCharacter[selected])
        net.SendToServer()
        layoutMenu:Remove()
    end

    local Modify = vgui.Create("DButton", layoutMenu)
    Modify:SetSize(layoutMenu:GetWide()/3, scrH/24)
    Modify:SetPos(layoutMenu:GetWide()/1.9, scrH/15.42 + scrH/18*7 + scrH/200)
    Modify:SetText("")
    Modify.Paint = function(self, w, h)
        surface.SetDrawColor(255, 255, 255, 225)
        if self:IsHovered() then
            surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[17])
        else
            surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[16])
        end
        surface.DrawTexturedRect(0, 0, w, h)
        draw.DrawText(Aden_DC:GetPhrase("edit"), "ADCFont::2", w/2, h/8, color_white, TEXT_ALIGN_CENTER)
    end
    Modify.DoClick = function()
        if !selected or !arrayCharacter[selected] then return end
        local menu = DermaMenu()
        paintSubMenu(menu, menu)
        if Aden_DC.Config.enableFaction then
            if Aden_DC:havePermission(Aden_DC.LocalPlayer, "faction") then
                local fake, faction = menu:AddSubMenu("Faction")
                paintSubMenu(fake, faction)
                for k, v in ipairs(Aden_DC.Config.listFaction) do
                    if v.class then
                        local fake, withlist = fake:AddSubMenu((arrayCharacter[selected].cFaction == k and "✓ " or "") .. v.name)
                        paintSubMenu(fake, withlist)
                        for j, i in ipairs(v.class) do
                            paintSubMenu(nil, fake:AddOption((arrayCharacter[selected].cFaction == k and arrayCharacter[selected].cClass == j and "✓ " or "") .. i.name, function()
                                arrayCharacter[selected].cFaction = k
                                arrayCharacter[selected].cClass = j
                            end))
                        end
                    else
                        paintSubMenu(nil, fake:AddOption((arrayCharacter[selected].cFaction == k and "✓ " or "") .. v.name, function()
                            arrayCharacter[selected].cFaction = k
                        end))
                    end
                end
            end
            if Aden_DC:havePermission(Aden_DC.LocalPlayer, "job") then
                local fake, job = menu:AddSubMenu("Job")
                paintSubMenu(fake, job)
                fake:SetMinimumWidth(ScrW() / 9)
                for k, v in ipairs(RPExtraTeams) do
                    paintSubMenu(nil, fake:AddOption((arrayCharacter[selected].cJob == k and "✓ " or "") .. v.name, function()
                        arrayCharacter[selected].cJob = k
                    end))
                end
            end
            if Aden_DC.Config.listFaction[arrayCharacter[selected].cFaction] then
                if Aden_DC:havePermission(Aden_DC.LocalPlayer, "whitelist") then
                    local fake, withlist = menu:AddSubMenu("Whitelist")
                    paintSubMenu(fake, withlist)
                    local fake_add, add = fake:AddSubMenu("Add")
                    paintSubMenu(fake_add, add)
                    fake_add:SetMinimumWidth(ScrW() / 9)
                    local jobs
                    if Aden_DC.Config.listFaction[arrayCharacter[selected].cFaction].class then
                        jobs = Aden_DC.Config.listFaction[arrayCharacter[selected].cFaction].class[arrayCharacter[selected].cClass] and Aden_DC.Config.listFaction[arrayCharacter[selected].cFaction].class[arrayCharacter[selected].cClass].jobs or {}
                    else
                        jobs = Aden_DC.Config.listFaction[arrayCharacter[selected].cFaction].jobs or {}
                    end
                    for k, v in pairs(jobs) do
                        if arrayCharacter[selected].withlist[k] then continue end
                        if !RPExtraTeams[k] then continue end
                        local painted = fake_add:AddOption(RPExtraTeams[k].name, function()
                            arrayCharacter[selected].withlist[k] = true
                        end)
                        paintSubMenu(nil, painted)
                    end
                    local fake_del, del = fake:AddSubMenu("Remove")
                    paintSubMenu(fake_del, del)
                    fake_del:SetMinimumWidth(ScrW() / 9)
                    for k, v in pairs(arrayCharacter[selected].withlist) do
                        if !v then continue end
                        paintSubMenu(nil, fake_del:AddOption(RPExtraTeams[k].name, function()
                            arrayCharacter[selected].withlist[k] = false
                        end))
                    end
                end
            end
        end
        if Aden_DC:havePermission(Aden_DC.LocalPlayer, "delete") then
            paintSubMenu(nil, menu:AddOption(Aden_DC:GetPhrase("delete"), function()
                RequestReason(SteamID:GetText(), selected)
                layoutMenu:Remove()
            end))
        end
        menu:Open()
    end

    function AdminRequestInfo() // Local function (look the first line)
        arrayLenght = net.ReadUInt(8)
        arrayCharacter = {}
        for i = 1, arrayLenght do
            arrayCharacter[i] = Aden_DC.Nets:ReadTable()
        end
        selected = nil
        firstName:SetText(firstName.baseText)
        lastName:SetText(lastName.baseText)
        cMoney:SetText(cMoney.baseText)
        cModel:SetText(cModel.baseText)
        cDate:SetText(cDate.baseText)
        SteamID:SetText(net.ReadString())
    end

    local base = makeParentMargin(layoutMenu:GetWide()/1.26, scrH/20, layoutMenu:GetWide()/10.5, scrH/15.42 + scrH/18, layoutMenu, 29)
    SteamID = vgui.Create("DTextEntry", base)
    SteamID:SetSize(layoutMenu:GetWide()/1.35, scrH/20)
    SteamID:SetPos(base:GetTall()/4, 0)
    SteamID:SetText("SteamID 64 - 32")
    SteamID.baseText = "SteamID 64 - 32"
    SteamID:SetFont("ADCFont::2")
    SteamID:SetDrawLanguageID(false)
    SteamID.Paint = paintEntry
    SteamID.OnEnter = function(self)
        local txt = self:GetText()
        if string.StartWith(self:GetText(), "STEAM") then // steamid32 to 64
            txt = util.SteamIDTo64(txt)
        end
        net.Start("ADC::AdminNetworking")
        net.WriteUInt(1, 8)
        net.WriteBit(false)
        net.WriteString(txt)
        net.SendToServer()
    end

    local comboCharacter = vgui.Create("DButton", layoutMenu)
    comboCharacter:SetSize(layoutMenu:GetWide()/1.26, scrH/20)
    comboCharacter:SetPos(layoutMenu:GetWide()/10.5, scrH/15.42 + scrH/18*2)
    comboCharacter:SetText("")
    comboCharacter.Paint = function(self, w, h)
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[29])
        surface.DrawTexturedRect(0, 0, w, h)

        surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[26])
        surface.DrawTexturedRect(w/15, h/3.5, h/2, h/2)

        draw.DrawText("Character(s)", "ADCFont::2", w/5, h/5, color_white, TEXT_ALIGN_LEFT)
    end
    comboCharacter.DoClick = function(self)
        if arrayLenght <= 0 then return end
        if IsValid(self.baseCombo) then
            self.baseCombo:Remove()
            return
        end
        local x, y = self:LocalToScreen(0, 0)
        self.baseCombo = vgui.Create("DFrame")
        self.baseCombo:SetSize(self:GetWide(), self:GetTall() * 0.5 * arrayLenght)
        self.baseCombo:SetPos(x, y + self:GetTall() * 1.1)
        self.baseCombo:MakePopup()
        self.baseCombo:SetTitle("")
        self.baseCombo:ShowCloseButton(false)
        self.baseCombo.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h,color_white)
            if !IsValid(layoutMenu) then
                self:Remove()
            end
        end
        for k, v in ipairs(arrayCharacter) do
            local Choice = vgui.Create("DButton", self.baseCombo)
            Choice:SetSize(self.baseCombo:GetWide(), self.baseCombo:GetTall()/arrayLenght)
            Choice:SetPos(0, (k-1)*self.baseCombo:GetTall()/arrayLenght)
            Choice:SetText("")
            Choice.Paint = function(self, w, h)
                if self:IsHovered() then
                    draw.RoundedBox(0, 0, 0, w, h, Aden_DC.ClientSideMenu.Colors["grey"])
                end
                draw.DrawText(" - " .. v.firstName .. " " .. v.lastName, "ADCFont::3", w/10, h/15, color_black, TEXT_ALIGN_LEFT)
            end
            Choice.DoClick = function()
                firstName:SetText(v.firstName)
                lastName:SetText(v.lastName)
                cMoney:SetText(v.cMoney)
                cModel:SetText(v.cModel)
                cDate:SetText(Aden_DC.Config.CurrentYears - v.dBirth.y)
                selected = k
                self.baseCombo:Remove()
            end
        end
    end

    local arrayPlayers = player.GetAll()
    local playersCount = #arrayPlayers
    table.sort(arrayPlayers, function(a, b) return a:Nick() < b:Nick() end)

    local comboPlayer = vgui.Create("DButton", layoutMenu)
    comboPlayer:SetSize(layoutMenu:GetWide()/1.26, scrH/20)
    comboPlayer:SetPos(layoutMenu:GetWide()/10.5, 70)
    comboPlayer:SetText("")
    comboPlayer.textDraw = "Player(s)"
    comboPlayer.Paint = function(self, w, h)
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[29])
        surface.DrawTexturedRect(0, 0, w, h)

        surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[26])
        surface.DrawTexturedRect(w/15, h/3.5, h/2, h/2)

        draw.DrawText(comboPlayer.textDraw, "ADCFont::2", w/5, h/5, color_white, TEXT_ALIGN_LEFT)
    end
    comboPlayer.DoClick = function(self)
        if playersCount <= 0 then return end
        if IsValid(self.baseCombo) then
            self.baseCombo:Remove()
            return
        end
        local x, y = self:LocalToScreen(0, 0)
        self.baseCombo = vgui.Create("DFrame")
        if playersCount >= 20 then
            self.baseCombo:SetSize(self:GetWide()/1.5 * math.ceil(playersCount/20), self:GetTall() * 0.5 * 20)
            self.baseCombo:SetPos(x, y + self:GetTall() * 1.1)
        else
            self.baseCombo:SetSize(self:GetWide(), self:GetTall() * 0.5 * playersCount)
            self.baseCombo:SetPos(x, y + self:GetTall() * 1.1)
        end
        self.baseCombo:MakePopup()
        self.baseCombo:SetTitle("")
        self.baseCombo:ShowCloseButton(false)
        self.baseCombo.Paint = function(self, w, h)
            if !IsValid(layoutMenu) then
                self:Remove()
            end
        end
        for k, ply in ipairs(arrayPlayers) do
            local Choice = vgui.Create("DButton", self.baseCombo)
            if playersCount >= 20 then // We cant draw 20 buttons on the same column
                Choice:SetSize(self:GetWide()/1.6, self.baseCombo:GetTall()/20)
                Choice:SetPos(math.floor((k-1)/20) * self:GetWide()/1.5, ((k-1)%20)*self.baseCombo:GetTall()/20)
            else
                Choice:SetSize(self.baseCombo:GetWide(), self.baseCombo:GetTall()/playersCount)
                Choice:SetPos(0, (k-1)*self.baseCombo:GetTall()/playersCount)
            end
            Choice:SetText("")
            Choice.Paint = function(self, w, h)
                if self:IsHovered() then
                    draw.RoundedBox(0, 0, 0, w, h, Aden_DC.ClientSideMenu.Colors["grey"])
                else
                    draw.RoundedBox(0, 0, 0, w, h, color_white)
                end
                if playersCount >= 20 then
                    draw.DrawText(" - " .. ply:Nick(), "ADCFont::3", w/50, h/15, color_black, TEXT_ALIGN_LEFT)
                else
                    draw.DrawText(" - " .. ply:Nick(), "ADCFont::3", w/10, h/15, color_black, TEXT_ALIGN_LEFT)
                end
            end
            Choice.DoClick = function()
                if !IsValid(ply) then return end
                net.Start("ADC::AdminNetworking")
                net.WriteUInt(1, 8)
                net.WriteBit(true)
                net.WriteEntity(ply)
                net.SendToServer()
                self.baseCombo:Remove()
                self.textDraw = ply:Nick()
            end
        end
    end
end

net.Receive("ADC::AdminNetworking", function()
    local id = net.ReadUInt(8)

    if id == 1 then
        Aden_DC:OpenMenuAdmin()
    elseif id == 2 then
        AdminRequestInfo()
    end
end)
