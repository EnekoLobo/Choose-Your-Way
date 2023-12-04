
local PANEL = {}

local function skinScrollBar(vbar)
    function vbar:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, simplemount.config.colors.scrollbar.background)
    end
    function vbar.btnUp:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, simplemount.config.colors.scrollbar.up)
    end
    function vbar.btnDown:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, simplemount.config.colors.scrollbar.down)
    end
    function vbar.btnGrip:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, simplemount.config.colors.scrollbar.grip)
    end
end

local gradient_left = surface.GetTextureID("vgui/gradient-l")
local gradient_right = surface.GetTextureID("vgui/gradient-r")
local gradient_down = surface.GetTextureID("vgui/gradient_down")

function PANEL:Init()
    self:SetSize(ScrW() * 0.6, ScrH() * 0.61)
    self:Center()
    self:MakePopup()
    self:MoveToFront()

    local title = self:Add("EditablePanel")
    title:Dock(TOP)
    title:SetTall(35)
    title.Paint = function(s, w, h)
        draw.RoundedBoxEx(6, 0, 0, w, h, simplemount.config.colors.titleBar.color, true, true, false, false)

        draw.SimpleText(simplemount.config.text.title .. " - ".. simplemount.config.text.admin_cp, "SimpleMount.Title", 5, 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
    end

    local closeButton = title:Add('DButton')
    closeButton:Dock(RIGHT)
    closeButton:SetWide(35)
    closeButton:DockMargin(5, 5, 5, 5)
    closeButton.Paint = function(s, w, h)
        surface.SetDrawColor(simplemount.config.colors.close_button.primary)
        surface.DrawRect(0, 0, w, h)
    end
    closeButton:SetTextColor(simplemount.config.colors.close_button.text_color)
    closeButton:SetFont(simplemount.config.colors.close_button.font)
    closeButton:SetText("✕")
    closeButton.DoClick = function(s)
        self:Remove()
    end

    self.container = self:Add("DScrollPanel")
    self.container:Dock(FILL)
    self.container:DockMargin(5, 5, 5, 5)
    self.container:InvalidateParent(true)
    self.container:InvalidateLayout(true)
    skinScrollBar(self.container:GetVBar())

    -- self.top = self:Add("EditablePanel")
    -- self.top:Dock(TOP)
    -- self.top:SetTall(self:GetTall() * 0.05)

    -- local searchBox = self.top:Add("DTextEntry")
    -- searchBox:Dock(LEFT)
    -- searchBox:SetWide(self:GetWide() * 0.33)
    -- searchBox:DockMargin(1, 5, 5, 5)

    local players = player.GetAll()

    for k,v in ipairs(players) do
        local panel = self.container:Add("EditablePanel")
        panel:Dock(TOP)
        panel:SetTall(60)
        panel.Paint = function(s, w, h)
            draw.RoundedBox(8, 0, 0, w, h, simplemount.config.colors.admin.panel)
        end
        panel.OnCursorEntered = function(s)
            s:SetAlpha(175)
        end
        panel.OnCursorExited = function(s)
            s:SetAlpha(255)
        end
        

        local avatar = panel:Add("AvatarImage")
        avatar:Dock(LEFT)
        avatar:SetPlayer(v, 128)

        local name = panel:Add("DLabel")
        name:Dock(LEFT)
        name:DockMargin(5, 1, 5, 1)
        name:SetText(v:Nick() .. " (".. v:SteamID64()..")")
        name:SetTextColor(color_white)
        name:SetFont("SimpleMount.Title")
        name:SizeToContents()

        -- tools --
        local checkContent = panel:Add("SimpleMount.Button")
        checkContent:Dock(RIGHT)
        checkContent:DockMargin(5, 10, 5, 5)
        checkContent:SetText(simplemount.config.text.check_missing)
        checkContent:SizeToContents()
        checkContent:DarkMode()
        checkContent.DoClick = function(s)
            net.Start('SimpleMount.CheckContent')
                net.WriteEntity(v)
            net.SendToServer()
            self:Remove()
        end

        local forceDownload = panel:Add("SimpleMount.Button")
        forceDownload:Dock(RIGHT)
        forceDownload:DockMargin(5, 10, 5, 5)
        forceDownload:SetText(simplemount.config.text.force_download)
        forceDownload:SizeToContents()
        forceDownload:DarkMode()
        forceDownload.DoClick = function(s)
            net.Start("SimpleMount.ForceDownload")
                net.WriteEntity(v)
            net.SendToServer()
            self:Remove()
        end

    end

    if not simplemount.isAdmin(LocalPlayer()) then
        self:Remove()
    end
end

function PANEL:Paint(w, h)
    draw.RoundedBox(6, 0, 0, w, h, simplemount.config.colors.main_menu.bg)
end

vgui.Register("SimpleMount.Admin", PANEL, "EditablePanel")

