--[[---------------------------------]]--    
--  Local Helpers & Vars
--[[---------------------------------]]--

local COL_1 = Color(255, 255, 255)
local COL_3 = Color(41, 120, 185)
local COL_4 = Color(23, 23, 23, 255)

local COL_GREEN = Color(133,187,101)
local COL_RED = Color(200,60,60)

local function ConfirmPurchase(OLDF, AB, PRICE, CB)
    local PANEL = vgui.Create("PIXEL.Frame")
    PANEL:SetSize(ScrW() * 0.2, ScrH() * 0.125)
    PANEL:Center()
    PANEL:MakePopup(true)
    PANEL:SetTitle(RDV.LIBRARY.GetLang(nil, "COMP_companionsLabel"))

    PANEL.OnRemove = function()
        if IsValid(OLDF) then
            OLDF:SetVisible(true)
        end
    end

    local w, h = PANEL:GetSize()

    local FORMAT = RDV.LIBRARY.FormatMoney(nil, PRICE)

    local LANG = RDV.LIBRARY.GetLang(nil, "COMP_purchaseConfirm", {
        AB,
        FORMAT,
    })

    local LABEL = vgui.Create("DLabel", PANEL)
    LABEL:SetText("")
    LABEL:Dock(TOP)
    LABEL:SetSize(w, h * 0.5)
    LABEL:SetWrap(true)
    LABEL:SetContentAlignment(5)
    LABEL.PaintOver = function(self, w, h)
        draw.DrawText( LANG, "RD_FONTS_CORE_LABEL_LOWER", w * 0.5, h * 0.1, COL_1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local BUTTON = vgui.Create("PIXEL.TextButton", PANEL)
    BUTTON:SetText( RDV.LIBRARY.GetLang(nil, "COMP_confirmLabel") )
    BUTTON:Dock(FILL)
    BUTTON.DoClick = function()
        net.Start("RDV_COMP_PurchaseAbility")
            net.WriteString(AB)
        net.SendToServer()

        surface.PlaySound("addoncontent/pets/droids/task_accepted.ogg")
            
        CB(true)

        PANEL:Remove()
    end
end

--[[---------------------------------]]--    
--  Shop Menu
--[[---------------------------------]]--

RDV.COMPANIONS.SideMenuButton(function(FRAME, SIDE, PANEL)
    local CLASS = RDV.COMPANIONS.GetPlayerCompanionClass(LocalPlayer())

    if !CLASS or CLASS == "" then
        return
    end

    local LABEL = RDV.LIBRARY.GetLang(nil, "COMP_abilitiesMenuIdentifier")

    SIDE:AddItem(LABEL, LABEL, RDV.LIBRARY.GetConfigOption("COMP_abilitiesIcon"), function()
        PANEL:Clear()
    
        PANEL.PaintOver = function(self, w, h)
        end

        local COUNT = {}
        COUNT.AVAILABLE = 0

        local LNOITEMS = RDV.LIBRARY.GetLang(nil, "COMP_noItemsAvailable")

        PANEL.PaintOver = function(self, w, h)
            if COUNT.AVAILABLE <= 0 then
                draw.SimpleText(LNOITEMS, "RD_FONTS_CORE_LABEL_LOWER", w * 0.5, h * 0.4, COL_1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end

        local PET = RDV.COMPANIONS.GetPlayerCompanionClass(LocalPlayer())

        local HAS = false

        local w, h = PANEL:GetSize()

        local SCROLL = vgui.Create("PIXEL.ScrollPanel", PANEL)
        SCROLL:Dock(FILL)
        SCROLL:DockMargin(w * 0.01, h * 0.01, w * 0.01, h * 0.01)

        for k, v in pairs(RDV.COMPANIONS.ABILITIES) do
            if v.PETS and !v.PETS[PET] then
                continue
            end

            if not RDV.COMPANIONS.IsAbilityUsable(k, PET) or RDV.COMPANIONS.HasPurchasedAbility(LocalPlayer(),k, PET) then
                continue
            end

            local FORMAT = RDV.LIBRARY.FormatMoney(nil, v.Price)

            COUNT.AVAILABLE = COUNT.AVAILABLE + 1

            HAS = true
                
            local LABEL = SCROLL:Add("DLabel")
            LABEL:SetText("")
            LABEL:SetHeight(h * 0.175)
            LABEL:Dock(TOP)
            LABEL:DockMargin(w * 0.025, h * 0, w * 0.025, h * 0.015)
            LABEL:SetMouseInputEnabled(true)
            LABEL:SetCursor("hand")
            LABEL:SetTooltip(v.Description)
            LABEL.Paint = function(self, w, h)
                local COL = PIXEL.CopyColor(PIXEL.Colors.Header)

                draw.RoundedBox(5, 0, 0, w, h, COL)
    
                draw.SimpleText(k, "RD_FONTS_CORE_LABEL_LOWER", w * 0.05, h * 0.35, COL_1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                if RDV.LIBRARY.CanAfford(LocalPlayer(), nil, v.Price) then
                    draw.SimpleText(FORMAT, "RD_FONTS_CORE_LABEL_LOWER", w * 0.05, h * 0.65, COL_GREEN, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                else
                    draw.SimpleText(FORMAT, "RD_FONTS_CORE_LABEL_LOWER", w * 0.05, h * 0.65, COL_RED, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end
            end

            local BUTTON = vgui.Create("PIXEL.TextButton", LABEL)
            BUTTON:Dock(RIGHT)
            BUTTON:SetText( RDV.LIBRARY.GetLang(nil, "COMP_buyLabel") )
            BUTTON:SetSize(w * 0.2, 0)

            BUTTON.DoClick = function()
                if !RDV.LIBRARY.CanAfford(LocalPlayer(), nil, v.Price) then
                    return
                end
                
                ConfirmPurchase(FRAME, k, v.Price, function()
                    LABEL:Remove()
                end )

                FRAME:SetVisible(false)
            end
        end
    end)
end)

--[[---------------------------------]]--    
--  Abilities Menu
--[[---------------------------------]]--

local function AbilitiesMenu(PET_MENU_PREV)
    local PET = RDV.COMPANIONS.GetPlayerCompanionClass(LocalPlayer())

    local TAB = RDV.COMPANIONS.PLAYERS[PET]

    if !TAB or !TAB.ABILITIES then
        return
    else
        TAB = ( RDV.COMPANIONS.PLAYERS[PET].ABILITIES or {} )
    end

    HAS = false

    local LCOMMANDS = RDV.LIBRARY.GetLang(nil, "COMP_abilitiesMenuIdentifier")

    local ABILITIES = vgui.Create("PIXEL.Frame")
    ABILITIES:SetSize(ScrW() * 0.2, ScrH() * 0.3)
    ABILITIES:Center()
    ABILITIES:SetVisible(true)
    ABILITIES:MakePopup()
    ABILITIES:SetTitle(LCOMMANDS)
    ABILITIES.OnRemove = function()
        if IsValid(PET_MENU_PREV) then
            PET_MENU_PREV:SetVisible(true)
        end
    end

    local LNOITEMS = RDV.LIBRARY.GetLang(nil, "COMP_noItemsAvailable")

    ABILITIES.PaintOver = function(self, w, h)
        if not HAS then
            draw.SimpleText(LNOITEMS, "RD_FONTS_CORE_LABEL_LOWER", w * 0.5, h * 0.3, COL_1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    local w, h = ABILITIES:GetSize()

    local SCROLL = vgui.Create("PIXEL.ScrollPanel", ABILITIES)
    SCROLL:Dock(FILL)
    SCROLL:DockMargin(0, h * 0.05, 0, h * 0.05)

    for k, v in pairs(TAB) do
        if not RDV.COMPANIONS.IsAbilityEnabled(k) or not RDV.COMPANIONS.HasPurchasedAbility(LocalPlayer(), k, PET) then
            continue
        end

        HAS = true

        local ABILITY_COLOR = COL_1
        local ABILITY_SOUND = true

        local LABEL = SCROLL:Add("DLabel")
        LABEL:SetText("")
        LABEL:SetSize(0, h * 0.125)
        LABEL:Dock(TOP)
        LABEL:DockMargin(w * 0.025, 0, w * 0.025, h * 0.025)
        LABEL:SetMouseInputEnabled(true)
        LABEL:SetText(k)
        LABEL:SetFont("RD_FONTS_CORE_LABEL_LOWER")
        LABEL:SetContentAlignment(5)
        LABEL:SetTextColor(COL_1)
        
        LABEL.Paint = function(self, w, h)
            local COL = PIXEL.CopyColor(PIXEL.Colors.Header)

            draw.RoundedBox(5, 0, 0, w, h, COL)
        end
        LABEL.OnCursorExited = function(self)
            self:SetTextColor(COL_1)
        end
        LABEL.OnCursorEntered = function(self)
            self:SetTextColor(COL_3)
            surface.PlaySound("reality_development/ui/ui_hover.ogg")
        end
        LABEL.DoClick = function()
            net.Start("RDV_COMP_SelectAbility")
                net.WriteString(k)
            net.SendToServer()

            surface.PlaySound("addoncontent/pets/droids/task_accepted.ogg")
            
            PET_MENU_PREV:Remove()
            ABILITIES:Remove()
        end
    end
end

--]]-------------------------------------------]]--
--  Pets Order Menu
--]]-------------------------------------------]]--

RDV.COMPANIONS.AddCommandButton(function(MENU, SCROLL)
    local PET = RDV.COMPANIONS.GetPlayerCompanionClass(LocalPlayer())
    
    local w, h = MENU:GetSize()
    
    local LABEL = SCROLL:Add("DLabel")
    LABEL:SetText("")
    LABEL:SetSize(0, h * 0.125)
    LABEL:Dock(TOP)
    LABEL:DockMargin(w * 0.025, 0, w * 0.025, h * 0.025)
    LABEL:SetMouseInputEnabled(true)
    LABEL:SetFont("RD_FONTS_CORE_LABEL_LOWER")
    LABEL:SetContentAlignment(5)

    local LABILITIES = RDV.LIBRARY.GetLang(nil, "COMP_abilitiesMenuIdentifier")
    LABEL:SetText(LABILITIES)
    LABEL:SetTextColor(COL_1)

    LABEL.Paint = function(self, w, h)
        local COL = PIXEL.CopyColor(PIXEL.Colors.Header)

        draw.RoundedBox(5, 0, 0, w, h, COL)
    end
    LABEL.OnCursorEntered = function(self)
        self:SetTextColor(COL_3)
        surface.PlaySound("reality_development/ui/ui_hover.ogg")
    end
    LABEL.OnCursorExited = function(self)
        self:SetTextColor(COL_1)
    end

    LABEL.DoClick = function()
        AbilitiesMenu(MENU)
    
        MENU:SetVisible(false)
    end
end)

local COL_1 = Color(255, 255, 255)
local COL_2 = Color(27, 27, 27, 255)
local COL_3 = Color(41, 120, 185)
local COL_4 = Color(24, 24, 24, 225)
local COL_5 = Color(23, 23, 23, 255)

local function SendNotification(msg)
    local CFG = {
		Appension = RDV.LIBRARY.GetConfigOption("COMP_prefix"),
		Color = RDV.LIBRARY.GetConfigOption("COMP_prefixColor"),
	}
    
    RDV.LIBRARY.AddText(LocalPlayer(), CFG.Color, "[" .. CFG.Appension .. "] ", COL_1, msg)
end

local function ShowHealth(FRAME_OLD)
    if IsValid(FRAME_OLD) then
        FRAME_OLD:SetVisible(false)
    end

    local C = RDV.COMPANIONS.GetPlayerCompanion(LocalPlayer())

    local FRAME = vgui.Create("PIXEL.Frame")
    FRAME:SetSize(ScrW() * 0.2, ScrH() * 0.125)
    FRAME:Center()
    FRAME:SetVisible(true)
    FRAME:MakePopup()
    FRAME:SetTitle(C:GetPetType())

    FRAME.OnRemove = function()
        if IsValid(FRAME_OLD) then
            FRAME_OLD:SetVisible(true)
        end
    end

    local w, h = FRAME:GetSize()
    local TITLE = vgui.Create("DLabel", FRAME)
    TITLE:Dock(TOP)
    TITLE:SetText(RDV.LIBRARY.GetLang(nil, "COMP_health_text", {C:Health()}))
    TITLE:DockMargin(w * 0.05, h * 0.05, w * 0.05, 0)
    TITLE.Think = function(self)
        self:SetText(RDV.LIBRARY.GetLang(nil, "COMP_health_text", {C:Health()}))
    end

    local BAR = vgui.Create("DPanel", FRAME)
    BAR:Dock(FILL)
    BAR:SetText("")
    BAR:DockMargin(w * 0.05, h * 0.05, w * 0.05, h * 0.05)
    BAR:SetWide(w)

    BAR.Paint = function(self, w, h)
        surface.SetDrawColor(255, 255, 255)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(0, 255, 13)
        surface.DrawRect(0, 0, (C:Health() / C:GetMaxHealth()) * w, h)
    end

    local BUTTON = vgui.Create("PIXEL.TextButton", FRAME)

    if (RDV.COMPANIONS.HasPurchasedAbility(LocalPlayer(),"Repair", nil) or RDV.COMPANIONS.HasPurchasedAbility(LocalPlayer(),"Heal", nil)) then
        BUTTON:SetEnabled(true)
        BUTTON:SetText(RDV.LIBRARY.GetLang(nil, "COMP_healconfirm"))
    else
        BUTTON:SetEnabled(false)
        BUTTON:SetText(RDV.LIBRARY.GetLang(nil, "COMP_healunavail"))
    end

    BUTTON:SetSize(w, h * 0.3)
    BUTTON:Dock(BOTTOM)

    BUTTON.DoClick = function(self)
        if (RDV.COMPANIONS.HasPurchasedAbility(LocalPlayer(),"Heal", nil)) then
            net.Start("RDV_COMP_SelectAbility")
            net.WriteString("Heal")
            net.SendToServer()
            return
        elseif (RDV.COMPANIONS.HasPurchasedAbility(LocalPlayer(),"Repair", nil)) then
            net.Start("RDV_COMP_SelectAbility")
            net.WriteString("Repair")
            net.SendToServer()
            SendNotification(RDV.LIBRARY.GetLang(nil, "COMP_healsuccess"))
            return
        end

        SendNotification(RDV.LIBRARY.GetLang(nil, "COMP_healerror"))
    end
end

RDV.COMPANIONS.AddCommandButton(function(MENU, SCROLL)
    local w, h = MENU:GetSize()

    local LABEL = SCROLL:Add("DLabel")
    LABEL:SetSize(0, h * 0.125)
    LABEL:Dock(TOP)
    LABEL:DockMargin(w * 0.025, 0, w * 0.025, h * 0.025)
    LABEL:SetMouseInputEnabled(true)
    LABEL:SetCursor("hand")

    local NAME = RDV.LIBRARY.GetLang(nil, "COMP_health")
    LABEL:SetText(NAME)
    LABEL:SetFont("RD_FONTS_CORE_LABEL_LOWER")
    LABEL:SetContentAlignment(5)
    LABEL:SetTextColor(COL_1)

    LABEL.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 0, w, h, COL_2)
    end

    LABEL.OnCursorEntered = function(self)
        self:SetTextColor(COL_3)
        surface.PlaySound("reality_development/ui/ui_hover.ogg")
    end

    LABEL.OnCursorExited = function(self)
        self:SetTextColor(COL_1)
    end

    LABEL.DoClick = function()
        ShowHealth(MENU)
    end
end)