local COL_1 = Color(255, 255, 255)
local COL_3 = Color(41, 120, 185)
local COL_4 = Color(23, 23, 23, 255)

local OPTIONS = {}

local COMMANDS = {
    {
        UID = "stayCommand",
        Menu = function(S, C_E, LABEL)
            LABEL:SetText(RDV.LIBRARY.GetLang(nil, "COMP_stayCommand"))

            OPTIONS[C_E] = OPTIONS[C_E] or {}

            local O = ( OPTIONS[C_E][S.UID] or false )

            if O then
                LABEL:SetText(RDV.LIBRARY.GetLang(nil, "COMP_followCommand"))
            end
        end,
        Callback = function(S, C_E, LABEL, FRAME, CORE_MENU)
            OPTIONS[C_E] = OPTIONS[C_E] or {}

            local O = ( OPTIONS[C_E][S.UID] or false )

            OPTIONS[C_E][S.UID] = !O

            if CLIENT then
                if !O then
                    LABEL:SetText(RDV.LIBRARY.GetLang(nil, "COMP_followCommand"))
                else
                    LABEL:SetText(RDV.LIBRARY.GetLang(nil, "COMP_stayCommand"))
                end
            end
        end,
    },
    {
        UID = "muteCommand",
        Menu = function(S, C_E, LABEL)
            LABEL:SetText(RDV.LIBRARY.GetLang(nil, "COMP_muteCommand"))

            OPTIONS[C_E] = OPTIONS[C_E] or {}

            local O = ( OPTIONS[C_E][S.UID] or false )

            if O then
                LABEL:SetText(RDV.LIBRARY.GetLang(nil, "COMP_unmuteCommand"))
            end
        end,
        Callback = function(S, C_E, LABEL, FRAME, CORE_MENU)
            OPTIONS[C_E] = OPTIONS[C_E] or {}

            local O = ( OPTIONS[C_E][S.UID] or false )

            OPTIONS[C_E][S.UID] = !O

            if CLIENT then
                if !O then
                    LABEL:SetText(RDV.LIBRARY.GetLang(nil, "COMP_unmuteCommand"))
                else
                    LABEL:SetText(RDV.LIBRARY.GetLang(nil, "COMP_muteCommand"))
                end
            end
        end,
    },
    {
        UID = "dismissCommand",
        Menu = function(S, C_E, LABEL)
            LABEL:SetText(RDV.LIBRARY.GetLang(nil, "COMP_dismissCommand"))
        end,
        Callback = function(S, C_E, LABEL, FRAME, CORE_MENU)
            if IsValid(FRAME) then
                FRAME:Remove()
            end

            if IsValid(CORE_MENU) then
                CORE_MENU:Remove()
            end

            if !SERVER then return end

            if !IsValid(C_E) then return end

            local CLASS = C_E:GetPetType()
            local P = C_E:GetPetOwner()

            RDV.COMPANIONS.SetCompanionEquipped(P, CLASS, false, true)
        end,
    }
}

function RDV.COMPANIONS.GetOption(C_E, UID)
    if !IsValid(C_E) then return end
    OPTIONS[C_E] = OPTIONS[C_E] or {}

    return ( OPTIONS[C_E][UID] or false )
end

if SERVER then
    util.AddNetworkString("RDV_COMP_OPTIONS_SELECT")

    net.Receive("RDV_COMP_OPTIONS_SELECT", function(len, ply)
        local COMMAND = net.ReadUInt(8)

        if !COMMANDS[COMMAND] then return end

        COMMAND = COMMANDS[COMMAND]

        local C_E = RDV.COMPANIONS.GetPlayerCompanion(ply)

        if !IsValid(C_E) then return end

        COMMAND:Callback(C_E, nil)
    end )
else
    local function CommandsMenu(MENU)
        local C_E = RDV.COMPANIONS.GetPlayerCompanion(LocalPlayer())

        if !IsValid(C_E) then return end

        local NAME = RDV.LIBRARY.GetLang(nil, "COMP_commandsLabel")

        local FRAME = vgui.Create("PIXEL.Frame")
        FRAME:SetSize(ScrW() * 0.2, ScrH() * 0.3)
        FRAME:Center()
        FRAME:SetVisible(true)
        FRAME:MakePopup()
        FRAME:SetTitle(NAME)
        FRAME.OnRemove = function()
            if IsValid(MENU) then
                MENU:SetVisible(true)
            end
        end

        local w, h = FRAME:GetSize()

        local SCROLL = vgui.Create("PIXEL.ScrollPanel", FRAME)
        SCROLL:Dock(FILL)
        SCROLL:DockMargin(0, h * 0.05, 0, h * 0.05)

        for k, v in ipairs(COMMANDS) do
            local LABEL = SCROLL:Add("DLabel")
            LABEL:Dock(TOP)
            LABEL:SetFont("RD_FONTS_CORE_LABEL_LOWER")
            LABEL:SetText("")
            LABEL:SetContentAlignment(5)
            LABEL:SetMouseInputEnabled(true)
            LABEL:SetTextColor(COL_1)
            LABEL:SetSize(0, h * 0.2)
            LABEL:DockMargin(w * 0.025, 0, w * 0.025, h * 0.025)
            
            LABEL.DoClick = function()
                net.Start("RDV_COMP_OPTIONS_SELECT")
                    net.WriteUInt(k, 8)
                net.SendToServer()

                v:Callback(C_E, LABEL, FRAME, MENU)
            end 
            LABEL.OnCursorEntered = function(s)
                surface.PlaySound("reality_development/ui/ui_hover.ogg")

                s:SetTextColor(COL_3)
            end
            LABEL.OnCursorExited = function(s)
                s:SetTextColor(COL_1)
            end

            LABEL.Paint = function(self, w, h)
                local COL = PIXEL.CopyColor(PIXEL.Colors.Header)

                draw.RoundedBox(5, 0, 0, w, h, COL)
            end

            v:Menu(C_E, LABEL)
        end
    end

    RDV.COMPANIONS.AddCommandButton(function(C_MENU, PET_SCROLL)
        local w, h = C_MENU:GetSize()

        local LABEL = PET_SCROLL:Add("DLabel")
        LABEL:SetText("")
        LABEL:SetSize(0, h * 0.125)
        LABEL:Dock(TOP)
        LABEL:DockMargin(w * 0.025, 0, w * 0.025, h * 0.025)
        LABEL:SetMouseInputEnabled(true)
        LABEL:SetCursor("hand")

        local NAME = RDV.LIBRARY.GetLang(nil, "COMP_commandsLabel")
        LABEL:SetText(NAME)
        LABEL:SetFont("RD_FONTS_CORE_LABEL_LOWER")
        LABEL:SetContentAlignment(5)
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
            CommandsMenu(C_MENU)

            C_MENU:SetVisible(false)
        end
    end)
end