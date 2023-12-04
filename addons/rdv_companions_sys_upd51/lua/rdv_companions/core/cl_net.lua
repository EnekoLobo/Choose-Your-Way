local MENU_COMMANDS = {}

function RDV.COMPANIONS.AddCommandButton(func)
    table.insert(MENU_COMMANDS, func)
end

local MENU_SIDES = {}

function RDV.COMPANIONS.SideMenuButton(func)
    table.insert(MENU_SIDES, func)
end


local COL_1 = Color(255, 255, 255)
local COL_3 = Color(41, 120, 185)
local COL_4 = Color(23, 23, 23, 255)
local COL_5 = Color(140, 140, 140)
local COL_GREEN = Color(133,187,101)
local COL_RED = Color(200,60,60)

local function ChangeIcon(ICON, model)
    if ICON:GetModel() ~= model then
        ICON:SetModel(model)

        local mn, mx = ICON.Entity:GetRenderBounds()
        local size = 0

        size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
        size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
        size = math.max(size, math.abs(mn.z) + math.abs(mx.z))

        ICON:SetCamPos(Vector(size, size, size))
        ICON:SetLookAt((mn + mx) * 0.55)
        ICON:SetAmbientLight( color_white )
    end
end

local function SendNotification(msg)
    local CFG = {
		Appension = RDV.LIBRARY.GetConfigOption("COMP_prefix"),
		Color = RDV.LIBRARY.GetConfigOption("COMP_prefixColor"),
	}

    RDV.LIBRARY.AddText(LocalPlayer(), CFG.Color, "["..CFG.Appension.."] ", COL_1, msg)
end

local function ConfirmPurchase(OLDF, COMPANION, CB)
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

    local TAB = RDV.COMPANIONS.COMPANIONS[COMPANION]
    local FORMAT = RDV.LIBRARY.FormatMoney(nil, TAB.Price)

    local LANG = RDV.LIBRARY.GetLang(nil, "COMP_purchaseConfirm", {
        COMPANION,
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
        net.Start("RDV_COMP_PurchaseComp")
            net.WriteString(COMPANION)
        net.SendToServer()

        RDV.COMPANIONS.PLAYERS[COMPANION] = {
            SKIN = 0,
        }

        surface.PlaySound("addoncontent/pets/droids/task_accepted.ogg")

        CB(true)

        PANEL:Remove()

        if IsValid(OLDF) then
            OLDF:SetVisible(true)
        end
    end
end

local function GetCurrentSkin(PET)
    if !RDV.COMPANIONS.PLAYERS[PET] then
        return 0
    else
        return tonumber(RDV.COMPANIONS.PLAYERS[PET].SKIN) or 0
    end
end

local function GetSkinName(PET, ID)
    local CFG = RDV.COMPANIONS.COMPANIONS[PET]

    if !CFG then
        return "N/A"
    elseif CFG.Skins and CFG.Skins[ID] then
        return CFG.Skins[ID].Name
    end

    return "N/A"
end

local function CustomizePet(pet, SKIN, panel_master)
    if not pet or not RDV.COMPANIONS.COMPANIONS[pet] then return end

    local pet_config = RDV.COMPANIONS.COMPANIONS[pet]

    if not pet_config.Skins then SendNotification( RDV.LIBRARY.GetLang(nil, "COMP_noCustomization") ) return end    
    
    if IsValid(panel_master) then
        panel_master:SetVisible(false)
    end

    local LCUSTOMIZE = RDV.LIBRARY.GetLang(nil, "COMP_customizeLabel")

    local FRAME = vgui.Create("PIXEL.Frame")
    FRAME:SetSize(ScrW() * 0.4, ScrH() * 0.5)
    FRAME:Center()
    FRAME:SetVisible(true)
    FRAME:MakePopup()
    FRAME:SetTitle(LCUSTOMIZE)

    FRAME.OnRemove = function()
        if IsValid(panel_master) then
            panel_master:SetVisible(true)
        end
    end

    local w, h = FRAME:GetSize()

    local ICON = vgui.Create( "DModelPanel", FRAME )
    ICON:SetSize( w * 0.4, 0 )
    ICON:Dock(LEFT)

    ChangeIcon(ICON, pet_config.Model)

    if SKIN then
        ICON.Entity:SetSkin(SKIN)
    end

    local SCROLL = vgui.Create("PIXEL.ScrollPanel", FRAME)
    SCROLL:Dock(FILL)
    SCROLL:DockMargin(w * 0.01, h * 0.01, w * 0.01, h * 0.01)

    for k, v in pairs(pet_config.Skins) do
        local FORMAT = RDV.LIBRARY.FormatMoney(nil, v.Price)

        local NAME = v.Name

        local CAN = true

        local LABEL = SCROLL:Add("DLabel")
        LABEL:SetText("")
        LABEL:SetHeight(h * 0.075)
        LABEL:Dock(TOP)
        LABEL:DockMargin(w * 0.025, 0, w * 0.025, h * 0.015)
        LABEL:SetMouseInputEnabled(true)
        LABEL:SetCursor("hand")

        LABEL.Paint = function(self, w, h)
            local COL = PIXEL.CopyColor(PIXEL.Colors.Header)

            draw.RoundedBox(5, 0, 0, w, h, COL)

            draw.SimpleText(NAME, "RD_FONTS_CORE_LABEL_LOWER", w * 0.1, h * 0.5, COL_1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

            if RDV.LIBRARY.CanAfford(LocalPlayer(), nil, v.Price) then
                draw.SimpleText(FORMAT, "RD_FONTS_CORE_LABEL_LOWER", w * 0.5, h * 0.5, COL_GREEN, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            else
                draw.SimpleText(FORMAT, "RD_FONTS_CORE_LABEL_LOWER", w * 0.5, h * 0.5, COL_RED, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
        LABEL.OnCursorEntered = function(self)
            ICON.Entity:SetSkin(k)
        end

        local BUTTON = vgui.Create("PIXEL.TextButton", LABEL)
        BUTTON:Dock(RIGHT)
        BUTTON:SetSize(w * 0.15, 0)

        if GetCurrentSkin(pet) == tonumber(k) then
            local LEQUIPPED = RDV.LIBRARY.GetLang(nil, "COMP_currentLabel")

            BUTTON:SetText(LEQUIPPED)
        else
            local LSET = RDV.LIBRARY.GetLang(nil, "COMP_setLabel") 

            BUTTON:SetText(LSET)
        end


        BUTTON.OnCursorEntered = function(self)
            ICON.Entity:SetSkin(k)
        end

        BUTTON.DoClick = function()
            RDV.COMPANIONS.PLAYERS[pet] = RDV.COMPANIONS.PLAYERS[pet] or {}

            local CUR_SKIN = (RDV.COMPANIONS.PLAYERS[pet].SKIN or 0)

            if tonumber(CUR_SKIN) == tonumber(k) then 
                return 
            end

            if RDV.LIBRARY.CanAfford(LocalPlayer(), nil, v.Price) then
                net.Start("RDV_COMP_ChangeSkin")
                    net.WriteString(pet)
                    net.WriteInt(k, 8)
                net.SendToServer()

                RDV.COMPANIONS.PLAYERS[pet].SKIN = k

                FRAME:Remove()
            else
                local LCantAfford = RDV.LIBRARY.GetLang(nil, "COMP_cannotAffordSkin")

                SendNotification(LCantAfford)
            end
        end
    end
end

net.Receive("RDV_COMP_VendorMenu", function()
    local LPETS = RDV.LIBRARY.GetLang(nil, "COMP_companionsLabel")

    local FRAME = vgui.Create("PIXEL.Frame")
    FRAME:SetSize(ScrW() * 0.4, ScrH() * 0.5)
    FRAME:Center()
    FRAME:SetVisible(true)
    FRAME:MakePopup()
    FRAME:SetTitle(LPETS)

    local w, h = FRAME:GetSize()

    local SIDE = vgui.Create("PIXEL.Sidebar", FRAME)
    SIDE:Dock(LEFT)
    SIDE:SetWide(w * 0.3)

    local PANEL = vgui.Create("DPanel", FRAME)
    PANEL:Dock(FILL)
    PANEL.Paint = function() end

    PANEL.Think = function(self) SIDE:SelectItem(LPETS) self.Think = function() end end

    SIDE:AddItem(LPETS, LPETS, RDV.LIBRARY.GetConfigOption("COMP_shopIcon"), function()
        PANEL:Clear()

        local COUNT = 0

        local LNOITEMS = RDV.LIBRARY.GetLang(nil, "COMP_noItemsAvailable")
    
        PANEL.PaintOver = function(self, w, h)
            if COUNT <= 0 then
                draw.SimpleText(LNOITEMS, "RD_FONTS_CORE_LABEL_LOWER", w * 0.5, h * 0.4, COL_1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end

        local w, h = PANEL:GetSize()

        local SCROLL = vgui.Create("PIXEL.ScrollPanel", PANEL)
        SCROLL:Dock(FILL)
        SCROLL:DockMargin(w * 0.01, h * 0.01, w * 0.01, h * 0.01)

        local LANG = RDV.LIBRARY.GetLang(nil, "COMP_purchasedLabel")

        for k, v in pairs(RDV.COMPANIONS.COMPANIONS) do
            if v.Teams then
                if not v.Teams[team.GetName(LocalPlayer():Team())] then continue end
            end

            if !RDV.COMPANIONS.PLAYERS[k] and !v.Purchaseable then continue end

            local COLOR = v.Color

            COUNT = COUNT + 1

            local PRICE = RDV.LIBRARY.FormatMoney(nil, v.Price)

            local LABEL = SCROLL:Add("DLabel")
            LABEL:SetText("")
            LABEL:SetHeight(h * 0.175)
            LABEL:Dock(TOP)
            LABEL:DockMargin(w * 0.025, h * 0, w * 0.025, h * 0.015)
            LABEL:SetMouseInputEnabled(true)
            LABEL:SetCursor("hand")

            LABEL.Paint = function(self, w, h)
                local COL = PIXEL.CopyColor(PIXEL.Colors.Header)

                draw.RoundedBox(5, 0, 0, w, h, COL)

                draw.SimpleText(k, "RD_FONTS_CORE_LABEL_LOWER", w * 0.25, h * 0.35, COLOR, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                if !RDV.COMPANIONS.PLAYERS[k] then
                    if RDV.LIBRARY.CanAfford(LocalPlayer(), nil, v.Price) then
                        draw.SimpleText(PRICE, "RD_FONTS_CORE_LABEL_LOWER", w * 0.25, h * 0.65, COL_GREEN, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    else
                        draw.SimpleText(PRICE, "RD_FONTS_CORE_LABEL_LOWER", w * 0.25, h * 0.65, COL_RED, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    end
                else
                    draw.SimpleText(LANG, "RD_FONTS_CORE_LABEL_LOWER", w * 0.25, h * 0.65, COL_1, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end
            end

            local LBUY = RDV.LIBRARY.GetLang(nil, "COMP_buyLabel")

            local BUY = vgui.Create("PIXEL.TextButton", LABEL)
            BUY:Dock(RIGHT)
            BUY:SetSize(w * 0.2, 0)

            if not RDV.COMPANIONS.PLAYERS[k] then
                BUY:SetText(LBUY)
            else
                if RDV.COMPANIONS.GetPlayerCompanionClass(LocalPlayer()) == k then
                    local LEQUIPPED = RDV.LIBRARY.GetLang(nil, "COMP_customizeLabel")
                    BUY:SetText(LEQUIPPED)
                else
                    local LEQUIP = RDV.LIBRARY.GetLang(nil, "COMP_equipLabel")
                    BUY:SetText(LEQUIP)
                end
            end

            BUY.DoClick = function()
                RDV.COMPANIONS.PLAYERS = RDV.COMPANIONS.PLAYERS or {}

                local CLASS = RDV.COMPANIONS.GetPlayerCompanionClass(LocalPlayer())
                local LIST = RDV.COMPANIONS.PLAYERS[k]

                if CLASS and (CLASS == k) then
                    local SKIN = (LIST.SKIN or 0)
                    CustomizePet(k, SKIN, FRAME)
                elseif not LIST then
                    if !RDV.LIBRARY.CanAfford(LocalPlayer(), nil, v.Price) then
                        return
                    end

                    FRAME:SetVisible(false)

                    ConfirmPurchase(FRAME, k, function()
                        local LEQUIP = RDV.LIBRARY.GetLang(nil, "COMP_equipLabel")
                        BUY:SetText(LEQUIP)
                    end )
                else
                    net.Start("RDV_COMP_TogglePet")
                        net.WriteString(k)
                    net.SendToServer()

                    FRAME:Remove()
                end
            end

            local label = vgui.Create("DLabel", LABEL)
            label:SetSize(ScrW() * 0.05, 0)
            label:Dock(LEFT)
            label:SetText("")

            label.Paint = function(self, w, h)
                local COL = PIXEL.CopyColor(PIXEL.Colors.Header)

                draw.RoundedBox(5, 0, 0, w, h, COL)
            end

            local icon = vgui.Create("DModelPanel", label)
            icon:Dock(FILL)

            ChangeIcon(icon, v.Model)
            
            if GetCurrentSkin(k) then
                icon.Entity:SetSkin(GetCurrentSkin(k))
            end
        end
    end)

    for k, v in ipairs(MENU_SIDES) do
        v(FRAME, SIDE, PANEL)
    end
end)

net.Receive("RDV_COMP_NetworkComps", function()
    local MULT = net.ReadBool()

    if MULT then
        RDV.COMPANIONS.PLAYERS = {}

        local COUNT = net.ReadUInt(16)

        for i = 1, COUNT do
            local PET = net.ReadString()
            local SKIN = net.ReadUInt(8)

            RDV.COMPANIONS.PLAYERS[PET] = {
                SKIN = SKIN,
            }
        end
    else
        local PET = net.ReadString()
        local SKIN = net.ReadUInt(8)

        RDV.COMPANIONS.PLAYERS[PET] = {
            SKIN = SKIN,
        }
    end
end)

net.Receive("RDV_COMP_OpenPetMenu", function()
    local PET = RDV.COMPANIONS.GetPlayerCompanionClass(LocalPlayer())
    
    local MENU = vgui.Create("PIXEL.Frame")
    MENU:SetSize(ScrW() * 0.3, ScrH() * 0.4)
    MENU:Center()
    MENU:SetVisible(true)
    MENU:MakePopup()
    MENU:SetTitle(PET)

    local w, h = MENU:GetSize()

    local SCROLL = vgui.Create("PIXEL.ScrollPanel", MENU)
    SCROLL:Dock(FILL)
    SCROLL:DockMargin(0, h * 0.05, 0, h * 0.05)
    
    for k, v in ipairs(MENU_COMMANDS) do
        v(MENU, SCROLL)
    end
end)