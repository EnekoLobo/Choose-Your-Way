local COL_1 = Color(255,255,255)
local COL_2 = Color(27, 27, 27, 255)
local COL_3 = Color(41, 120, 185)
local COL_4 = Color(24,24,24, 225)
local COL_5 = Color(23, 23, 23, 255)

local function SendNotification(msg)
    local CFG = {
		Appension = RDV.LIBRARY.GetConfigOption("COMP_prefix"),
		Color = RDV.LIBRARY.GetConfigOption("COMP_prefixColor"),
	}

	RDV.LIBRARY.AddText(LocalPlayer(), CFG.Color, "["..CFG.Appension.."] ", COL_1, msg)
end

local function ChangeName(FRAME_OLD)
    if IsValid(FRAME_OLD) then
        FRAME_OLD:SetVisible(false)
    end

    local C = RDV.COMPANIONS.GetPlayerCompanion(LocalPlayer())

    local NAME = C:GetNW2String("RDV.COMPANIONS.NAME", "N/A")

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

    local TITLE = vgui.Create("PIXEL.TextEntry", FRAME)
    TITLE:Dock(FILL)
    TITLE:SetMultiline(false)
    TITLE:SetText(NAME)
    TITLE:DockMargin(w * 0.05, h * 0.05, w * 0.05, h * 0.05)

    local BUTTON = vgui.Create("PIXEL.TextButton", FRAME)
    BUTTON:SetText( RDV.LIBRARY.GetLang(nil, "COMP_confirm") )
    BUTTON:SetSize(w, h * 0.3)
    BUTTON:Dock(BOTTOM)
    BUTTON.DoClick = function(self)
        local TEXT = TITLE:GetValue()
        local LEN = utf8.len(TEXT)
        local MAX = RDV.COMPANIONS.NAME.Characters

        if LEN > MAX then
            local CFG = RDV.LIBRARY.GetLang(nil, "COMP_shortenName", {
                MAX,
            })

            SendNotification(CFG)
            return
        end

        net.Start("RDV.COMPANIONS.SetName")
            net.WriteString(TITLE:GetValue())
        net.SendToServer()
    end
end

RDV.COMPANIONS.AddCommandButton(function(PET_MENU, PET_SCROLL)
    local w, h = PET_MENU:GetSize()

    local LABEL = PET_SCROLL:Add("DLabel")
    LABEL:SetSize(0, h * 0.125)
    LABEL:Dock(TOP)
    LABEL:DockMargin(w * 0.025, 0, w * 0.025, h * 0.025)
    LABEL:SetMouseInputEnabled(true)
    LABEL:SetCursor("hand")

    local NAME = RDV.LIBRARY.GetLang(nil, "COMP_changeName")

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
        ChangeName(PET_MENU)
    end
end)