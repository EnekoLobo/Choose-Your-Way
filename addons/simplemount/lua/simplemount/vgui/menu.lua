
local PANEL = {}

local function skinScrollBar(vbar)
    vbar:SetWide(5)
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

        draw.SimpleText(simplemount.config.text.title, "SimpleMount.Title", 5, 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
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

    if simplemount.isAdmin(LocalPlayer()) then
        local adminCp = title:Add('SimpleMount.Button')
        adminCp:Dock(RIGHT)
        adminCp:SetWide(60)
        adminCp:DockMargin(10, 0, 20, 0)
        adminCp:SetText(simplemount.config.text.admin_cp)
        adminCp.Paint = function(s, w, h)
            surface.SetDrawColor(simplemount.config.colors.main_menu.gradient)
            surface.DrawRect(0, 0, w, h)
        end
        adminCp.DoClick = function()
            self:Remove()
            vgui.Create("SimpleMount.Admin")
        end
    end

    self.container = self:Add("DScrollPanel")
    self.container:Dock(FILL)
    self.container:DockMargin(5, 1, 5, 5)
    skinScrollBar(self.container:GetVBar())

    self.layout = self.container:Add("DIconLayout")
    self.layout:Dock(FILL)
    self.layout:DockMargin(1, 1, 1, 1)
    self.layout:SetSpaceX(10)
    self.layout:SetSpaceY(10)

    self.bottom = self:Add("EditablePanel")
    self.bottom:Dock(TOP)
    self.bottom:SetTall(self:GetTall() * 0.10)

    self.label = self.bottom:Add("DLabel")
    self.label:DockMargin(5, 1, 1, 1)
    self.label:Dock(LEFT)
    self.label:SetTextColor(color_white)
    self.label:SetFont("SimpleMount.Notice")
    self.label:SetText(simplemount.config.text.missing)
    self.label:SizeToContents()

    -- ignore
    local ignore = self.bottom:Add("SimpleMount.Button")
    ignore:Dock(RIGHT)
    ignore:DockMargin(5, 5, 5, 5)
    ignore:SetText(simplemount.config.text.ignore)
    ignore.DoClick = function(s)
        self:Remove()
    end
    ignore:SizeToContents()
    ignore:Gutter()
    ignore.DoClick = function(s)
        if simplemount.config.buttonClickSound then
            surface.PlaySound("ui/buttonclickrelease.wav")
        end
        self:Remove()
    end

    -- view collection
    local view = self.bottom:Add("SimpleMount.Button")
    view:Dock(RIGHT)
    view:DockMargin(5, 5, 5, 5)
    view:SetText(simplemount.config.text.open_collection)
    view:SizeToContents()
    view:Gutter()
    view.DoClick = function(s)
        gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id="..simplemount.config.workshopCollectionId)
        if simplemount.config.buttonClickSound  then
            surface.PlaySound("ui/buttonclickrelease.wav")
        end
    end

    -- mount addons
    local mount = self.bottom:Add("SimpleMount.Button")
    mount:Dock(RIGHT)
    mount:DockMargin(5, 5, 5, 5)
    mount:SetText(simplemount.config.text.mount_all)
    mount:SizeToContents()
    mount:Gutter()
    mount.DoClick = function(s)
        simplemount.startDownload()
        simplemount.notify(simplemount.config.text.downloading_collection)
        self:Remove()
    end

end

function PANEL:Paint(w, h)
    draw.RoundedBox(6, 0, 0, w, h, simplemount.config.colors.main_menu.bg)

    if self.notMissingContent then
        draw.SimpleText(simplemount.config.text.up_to_date, "SimpleMount.Notice", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)

    end
end

local fallbackColor = Color(25, 25, 25)
function PANEL:Build(data)
    data = data or simplemount.badCache
    local boxSize = (self:GetWide() - 10) / 6 - 10
    local didSomething = false


    local noContent = true
    for k,v in pairs(data) do
        if not v.id then continue end
        if not v.name then v.name = "NA" end
        if v.id and simplemount.mountedCache[v.id] then continue end
        didSomething = true
        local panel = self.layout:Add("DPanel")
        panel:SetSize(boxSize, boxSize)
        panel.Paint = function(s, w, h)
            local mat = simplemount.fetchOrGetImage(v.previewId)

            if mat then
                if isstring(mat) then
                    surface.SetDrawColor(fallbackColor)
                    surface.DrawRect(0, 0, w, h)

                    draw.SimpleText(mat, "SimpleMount.ViewBtn", 0, 0, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
                else
                    surface.SetDrawColor(color_white)
                    surface.SetMaterial(mat)
                    surface.DrawTexturedRect(0, 0, w, h)
                end

                if s.drawCard then
                    surface.SetDrawColor(color_black)
                    surface.SetTexture(gradient_down)
                    surface.DrawTexturedRect(0, 0, w, h)

                    draw.RoundedBox(4, w * 0.25, h/2, w * 0.50, 20, simplemount.config.colors.main_menu.gradient)
                    draw.SimpleText("VIEW", "SimpleMount.ViewBtn", w * 0.50, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
                end
            end
        end
        panel.OnCursorEntered = function(s)
            s.drawCard = true
        end
        panel.OnCursorExited = function(s)
            s.drawCard = false
        end
        panel.OnMouseReleased = function(s)
            if v.id then
                gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=".. v.id)
            end
        end

        local label = panel:Add('DLabel')
        label:Dock(TOP)
        label:SetAutoStretchVertical(true)
        label:SetTextColor(color_white)
        label:SetText(v.name or "")
        label:SetFont("SimpleMount.Label")
        label:SetWrap(true)
        label:DockMargin(1, 1, 1, 1)
    end

    if not didSomething then
        self.label:Remove()
        self.notMissingContent = true
    end
end
vgui.Register("SimpleMount.MainMenu", PANEL, "EditablePanel")


local PANEL = {}

function PANEL:Init()
    self:SetFont("SimpleMount.Button")
    self:SetTextColor(color_white)
end

function PANEL:Gutter()
    self:SetWide(self:GetWide() + 10)
end

function PANEL:DarkMode()
    self.darkMode = true 
end

function PANEL:Paint(w, h)
    if self.darkMode then
        draw.RoundedBox(8, 0, 0, w, h, simplemount.config.colors.button.paint_dark)
    else
        draw.RoundedBox(8, 0, 0, w, h, simplemount.config.colors.button.paint)
    end
end

function PANEL:OnCursorEntered()
    self:SetAlpha(200)
    if simplemount.config.rollOverSounds then
        surface.PlaySound("ui/buttonrollover.wav")
    end
end

function PANEL:OnCursorExited()
    self:SetAlpha(255)
end

vgui.Register("SimpleMount.Button", PANEL, "DButton")