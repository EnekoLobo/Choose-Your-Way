local AWAITING = {}

net.Receive("ix.PermaWeapons.Receive", function()
    local PLAYER = net.ReadPlayer()

    if !IsValid(PLAYER) then return end

    local TAB = net.ReadTable()

    if AWAITING[PLAYER] then
        AWAITING[PLAYER](TAB)
    end
end)

local COL_GREEN = Color(133,187,101)
local COL_WHITE = Color(255,255,255)

local function SendNotification(ply, msg)
    local CFG = RDV.PERMAWEAPONS.CFG.Prefix

    RDV.LIBRARY.AddText(ply, CFG.Color, "["..CFG.Appension.."] ", Color(255,255,255), msg)
end

local function GenerateTab(PANEL, AVAILABLE, WEPS)
    local CATS2 = RDV.PERMAWEAPONS.CATS

    local TOTAL = 0
    local w, h = PANEL:GetSize()

    local SCROLL = vgui.Create("PIXEL.ScrollPanel", PANEL)
    SCROLL:Dock(FILL)
    SCROLL:DockMargin(w * 0.025, h * 0.025, w * 0.025, h * 0.025)
    SCROLL.PaintOver = function()
        if TOTAL <= 0 then
            draw.SimpleText(RDV.LIBRARY.GetLang(nil, "PMW_NoItems"), "RD_FONTS_CORE_LABEL_LOWER", w * 0.5, h * 0.4, COL_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    local CATS = {}

    for k, v in pairs(RDV.PERMAWEAPONS.CFG.Weapons) do
        if AVAILABLE and ( WEPS[k] or !v.BUYABLE ) then
            continue
        elseif !AVAILABLE and !WEPS[k] then
            continue
        end
        
        if !RDV.PERMAWEAPONS.CanUse(LocalPlayer(), k) then continue end

        TOTAL = TOTAL + 1

        if !CATS[v.Category] then
            local CATEGORY_F = SCROLL:Add("PIXEL.Category")
            CATEGORY_F:Dock(TOP)
            CATEGORY_F:SetTitle( v.Category )
            CATEGORY_F:DockMargin(w * 0.015, h * 0.015, w * 0.015, h * 0.015)

            CATS[v.Category] = CATEGORY_F
        end

        local CATEGORY = CATS[v.Category]
        
        local label = CATEGORY:Add("DButton")
        label:SetSize(0, h * 0.13)
        label:DockMargin(w * 0.01, h * 0.01, w * 0.01, 0)
        label:Dock(TOP)
        label:SetText("")

        local PRICE = v.Price
        local CURRENCY = RDV.PERMAWEAPONS.CFG.Currency

        local FORMAT = RDV.LIBRARY.FormatMoney(CURRENCY, PRICE)

        label.Paint = function(self, w, h)
            local COL = PIXEL.OffsetColor(PIXEL.CopyColor(PIXEL.Colors.Header), 5)

            draw.RoundedBox(5, 0, 0, w, h, COL)

            draw.SimpleText(v.Name, "RD_FONTS_CORE_LABEL_LOWER", w * 0.2, h * 0.35, COL_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(FORMAT, "RD_FONTS_CORE_PROPERTY_TABS", w * 0.2, h * 0.65, COL_GREEN, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        local WEP = vgui.Create("SpawnIcon", label)
        WEP:Dock(LEFT)
        WEP:SetModel(v.Model)
        WEP:SetMouseInputEnabled(false)

        local BUY = vgui.Create("PIXEL.TextButton", label)
        BUY:Dock(RIGHT)

        local TAB = WEPS[k]

        if !TAB then
            BUY:SetText(RDV.LIBRARY.GetLang(nil, "PMW_Purchase"))
        elseif TAB then
            if TAB.Equipped then
                RDV.PERMAWEAPONS.CATS[v.Category] = k
                
                BUY:SetText(RDV.LIBRARY.GetLang(nil, "PMW_Unequip"))
            else
                BUY:SetText(RDV.LIBRARY.GetLang(nil, "PMW_Equip"))
            end
        end

        BUY.DoClick = function(self)
            if !TAB then
                local CURRENCY = RDV.PERMAWEAPONS.CFG.Currency

                if !RDV.LIBRARY.CanAfford(LocalPlayer(), CURRENCY, v.Price) then                    
                    notification.AddLegacy( RDV.LIBRARY.GetLang(nil, "PMW_CannotAfford", {k}), NOTIFY_GENERIC, 3 )
                    return
                end

                net.Start("ix.PermaWeapons.Purchase")
                    net.WriteString(k)
                net.SendToServer()

                TOTAL = TOTAL - 1

                WEPS[k] = {
                    Equipped = false,
                }

                label:Remove()
            elseif TAB then
                TAB.Equipped = !TAB.Equipped

                if TAB.Equipped then
                    if RDV.PERMAWEAPONS.CFG.OneCat then
                        if CATS2[v.Category] then
                            SendNotification(LocalPlayer(), RDV.LIBRARY.GetLang(nil, "PMW_oneCat"))

                            return
                        end
                    
                        CATS2[v.Category] = k
                    end

                    BUY:SetText(RDV.LIBRARY.GetLang(nil, "PMW_Unequip"))
                else
                    if RDV.PERMAWEAPONS.CFG.OneCat then
                        if ( CATS2[v.Category] and CATS2[v.Category] == k ) then CATS2[v.Category] = nil end
                    end
                    
                    BUY:SetText(RDV.LIBRARY.GetLang(nil, "PMW_Equip"))
                end

                net.Start("ix.PermaWeapons.Equip")
                    net.WriteString(k)
                net.SendToServer()
            end
        end
    end
end

net.Receive("ix.PermaWeapons.Menu", function(len, ply)
    local TAB = {}

    local COUNT = net.ReadUInt(8)

    for i = 1, COUNT do
        TAB[net.ReadString()] = {
            Equipped = net.ReadBool(),
        }
    end

    LocalPlayer().ixPermaWeapons = TAB

    local FRAMEM = vgui.Create("PIXEL.Frame")
    FRAMEM:SetSize(ScrW() * 0.35, ScrH() * 0.5)
    FRAMEM:Center()
    FRAMEM:SetVisible(true)
    FRAMEM:MakePopup()
    FRAMEM:SetTitle(RDV.LIBRARY.GetLang(nil, "PMW_Overhead"))

    local w,h = FRAMEM:GetSize()

    local SIDE = vgui.Create("PIXEL.Sidebar", FRAMEM)
    SIDE:Dock(LEFT)
    SIDE:SetWide(w * 0.3)

    local PANEL = vgui.Create("DPanel", FRAMEM)
    PANEL:Dock(FILL)
    PANEL.Paint = function() end
    PANEL.Think = function(self) SIDE:SelectItem("weps") self.Think = function() end end

    SIDE:AddItem("weps", RDV.LIBRARY.GetLang(nil, "PMW_Available"), "g4w7PtA", function()
        PANEL:Clear()
        
        GenerateTab(PANEL, true, TAB)
    end)

    SIDE:AddItem("purch", RDV.LIBRARY.GetLang(nil, "PMW_Purchased"), "2pR91kY", function()
        PANEL:Clear()

        GenerateTab(PANEL, false, TAB)
    end)

    if RDV.PERMAWEAPONS.CFG.Admins[LocalPlayer():GetUserGroup()] then
        local BUY = vgui.Create("PIXEL.TextButton", FRAMEM)
        BUY:Dock(BOTTOM)
        BUY:SetText(RDV.LIBRARY.GetLang(nil, "PMW_Admin"))
        BUY.DoClick = function(self)
            FRAMEM:SetVisible(false)

            local TOTAL = 0

            local FRAME = vgui.Create("PIXEL.Frame")
            FRAME:SetSize(ScrW() * 0.25, ScrH() * 0.5)
            FRAME:Center()
            FRAME:SetVisible(true)
            FRAME:MakePopup()
            FRAME:SetTitle(RDV.LIBRARY.GetLang(nil, "PMW_Overhead"))
            FRAME.OnRemove = function(s)
                FRAMEM:SetVisible(true)
            end

            local SCROLL = vgui.Create("DScrollPanel", FRAME)
            SCROLL:Dock(FILL)
            SCROLL:GetVBar():SetWide(0)
            SCROLL:DockMargin(w * 0.025, h * 0.025, w * 0.025, h * 0.025)
            SCROLL.PaintOver = function()
                if TOTAL <= 0 then
                    draw.SimpleText(RDV.LIBRARY.GetLang(nil, "PMW_NoItems"), "RD_FONTS_CORE_LABEL_LOWER", w * 0.5, h * 0.4, COL_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end
            SCROLL.Think = function(self)
                local w, h = SCROLL:GetSize()

                for k, v in ipairs(player.GetAll()) do
                    local COL_TEAM = team.GetColor(v:Team())

                    TOTAL = TOTAL + 1

                    local label = SCROLL:Add("DLabel")
                    label:SetSize(0, h * 0.125)
                    label:DockMargin(0, h * 0.01, 0, 0)
                    label:Dock(TOP)
                    label:SetText("")
                    label:SetMouseInputEnabled(true)
                    label.Paint = function(self, w, h)
                        if !IsValid(v) then self:Remove() return end

                        draw.RoundedBox(5, 0, 0, w, h, PIXEL.CopyColor(PIXEL.Colors.Header))

                        draw.SimpleText(v:Name(), "RD_FONTS_CORE_LABEL_LOWER", w * 0.2, h * 0.35, COL_TEAM, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                        draw.SimpleText(v:GetUserGroup(), "RD_FONTS_CORE_PROPERTY_TABS", w * 0.2, h * 0.65, COL_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    end

                    local avatar = vgui.Create("AvatarImage", label)
                    avatar:SetPlayer(v, 64)
                    avatar:Dock(LEFT)

                    local BUTTON = vgui.Create("PIXEL.TextButton", label)
                    BUTTON:SetText(RDV.LIBRARY.GetLang(nil, "PMW_Select"))
                    BUTTON:Dock(RIGHT)
                    BUTTON.DoClick = function(len, ply)
                        TOTAL = 0
                        SCROLL:Clear()

                        AWAITING[v] = function(TAB)
                            if !IsValid(SCROLL) or !IsValid(v) then return end
                                    
                            local w, h = SCROLL:GetSize()

                            for key, tab in pairs(RDV.PERMAWEAPONS.CFG.Weapons) do
                                TOTAL = TOTAL + 1
                                        
                                local PRICE = tab.Price
                                local CURRENCY = RDV.PERMAWEAPONS.CFG.Currency
                                
                                local FORMAT = RDV.LIBRARY.FormatMoney(CURRENCY, PRICE)

                                local label = SCROLL:Add("DLabel")
                                label:SetSize(0, h * 0.125)
                                label:DockMargin(0, h * 0.01, 0, 0)
                                label:Dock(TOP)
                                label:SetText("")
                                label:SetMouseInputEnabled(true)
                                label.Paint = function(self, w, h)
                                        
                                    draw.RoundedBox(5, 0, 0, w, h, PIXEL.CopyColor(PIXEL.Colors.Header))

                                    draw.SimpleText(tab.Name, "RD_FONTS_CORE_LABEL_LOWER", w * 0.2, h * 0.35, COL_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                                    draw.SimpleText(FORMAT, "RD_FONTS_CORE_PROPERTY_TABS", w * 0.2, h * 0.65, COL_GREEN, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                                end

                                local WEP = vgui.Create("SpawnIcon", label)
                                WEP:Dock(LEFT)
                                WEP:SetModel(tab.Model)
                                WEP:SetMouseInputEnabled(false)

                                local BUTTON = vgui.Create("PIXEL.TextButton", label)

                                if TAB[key] then 
                                    BUTTON:SetText(RDV.LIBRARY.GetLang(nil, "PMW_Take"))
                                else
                                    BUTTON:SetText(RDV.LIBRARY.GetLang(nil, "PMW_Give"))
                                end

                                BUTTON:Dock(RIGHT)
                                BUTTON.DoClick = function(len, ply)
                                    net.Start("ix.PermaWeapons.Admin")
                                        net.WritePlayer(v)
                                        net.WriteString(key)
                                    net.SendToServer()

                                    if TAB[key] then
                                        TAB[key] = nil
                                        BUTTON:SetText(RDV.LIBRARY.GetLang(nil, "PMW_Give"))
                                    else
                                        TAB[key] = true

                                        BUTTON:SetText(RDV.LIBRARY.GetLang(nil, "PMW_Take"))
                                    end
                                end
                            end
                        end

                        net.Start("ix.PermaWeapons.Receive")
                            net.WritePlayer(v)
                        net.SendToServer()
                    end 
                end

                self.Think = function() end
            end
        end
    end
end)