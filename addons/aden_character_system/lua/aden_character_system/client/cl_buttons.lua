Aden_DC.Buttons.List = Aden_DC.Buttons.List or {}
Aden_DC.ClientSideMenu.ModelId = Aden_DC.ClientSideMenu.ModelId or 0

function Aden_DC.Buttons:addView(posView, angView, idView, ndrawView, scaleView)
    if !self.List[idView] then
        self.List[idView] = {
            posView = posView,
            angView = angView,
            buttonsView = {},
            drawView = ndrawView,
            scaleView = scaleView or 0.07
        }
    else
        self.List[idView].posView = posView
        self.List[idView].angView = angView
        self.List[idView].ndrawView = ndrawView
        self.List[idView].scaleView = scaleView or 0.07
    end
end

function Aden_DC.Buttons:removeView(id)
    if !self.List[id] then return end
    for _, v in pairs(self.List[id].buttonsView or {}) do
        if v and v.Remove then
            v:Remove()
        end
    end
    self.List[id] = nil
    Aden_DC.ClientSideMenu.ModelId = 0 // Reset for DModelPanel
end

function Aden_DC.Buttons:insertElement(id, button)
    table.insert(self.List[id].buttonsView, button)
end

function Aden_DC.Buttons:getXCursor(scaleView)
    scaleView = scaleView or 0.07
    return self.cursorPos and (self.cursorPos.x/scaleView) or 0
end

function Aden_DC.Buttons:getYCursor(scaleView)
    scaleView = scaleView or 0.07
    return self.cursorPos and (self.cursorPos.y/-scaleView) or 0
end

local meta = {
    SetPos = function(self, x, y)
        self.x = x
        self.y = y
    end,
    SetSize = function(self, w, h)
        self.w = w
        self.h = h
    end,
    GetPos = function(self)
        return self.x, self.y
    end,
    GetWide = function(self)
        return self.w
    end,
    GetTall = function(self)
        return self.h
    end,
    GetSize = function(self)
        return self.w, self.h
    end,
    SetIdView = function(self, id)
        self.RenderViewID = id
        Aden_DC.Buttons:insertElement(id, self)
    end,
    Remove = function(self)
        if self.OnRemove then
            self:OnRemove()
        end
        if self.ParentLayout then
            self:RemoveToLayout()
        end
        if self.Children then
            for k, v in ipairs(self.Children) do
                if !v then continue end
                v:Remove()
            end
        end
        table.RemoveByValue(Aden_DC.Buttons.List[self.RenderViewID].buttonsView, self)
    end,
    IsCliked = function(self)
        if !self.PaintManual and self:IsHovered() then
            if input.IsMouseDown(MOUSE_LEFT) and !self.antiClick and !Aden_DC.Buttons.IsDragging then
                if isfunction(self.DoClick) then
                    Aden_DC.Buttons.IsDragging = self.DoClick(self) != true // If return true we don't block the next button
                    self.antiClick = true
                end
                return true
            elseif !input.IsMouseDown(MOUSE_LEFT) then
                self.antiClick = false
            end
        else
            return false
        end
    end,
    IsHovered = function(self)
        if Aden_DC.Buttons.List[self.RenderViewID] and Aden_DC.Buttons:getXCursor(Aden_DC.Buttons.List[self.RenderViewID].scaleView) > self.x and Aden_DC.Buttons:getXCursor(Aden_DC.Buttons.List[self.RenderViewID].scaleView) < self.x + self.w and Aden_DC.Buttons:getYCursor(Aden_DC.Buttons.List[self.RenderViewID].scaleView) > self.y and Aden_DC.Buttons:getYCursor(Aden_DC.Buttons.List[self.RenderViewID].scaleView) < self.y + self.h then
            return true
        else
            return false
        end
    end,
    RenderModel = function(self)
        if self.Model and IsValid(self.Model) then
            local dModelPanelRT = GetRenderTarget("dModelPanelRT" .. self.customMaterial:GetName(), self.w, self.h)
            render.PushRenderTarget(dModelPanelRT)
                render.OverrideAlphaWriteEnable(true, true)
                render.ClearDepth()
                render.Clear(0, 0, 0, 0)

                local mn, mx = self.Model:GetRenderBounds()
                local size = 0
                size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
                size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
                size = math.max(size, math.abs(mn.z) + math.abs(mx.z))

                local lookat = (mn + mx) * 0.5
                local campos = Vector(size, size, size)
                local move = (lookat-campos):Angle()

                cam.Start3D(campos + move:Forward() * -200, (lookat-campos):Angle(), self:GetFOV(), 0, 0, Aden_DC.ScrW, Aden_DC.ScrH, 5, 4096)
                    render.SuppressEngineLighting(true)
                    render.SetLightingOrigin(self.Model:GetPos())
                    render.ResetModelLighting(1, 1, 1)
                    self.ColorModel = color_white
                    if self.ColorModel then
                        render.SetColorModulation(self.ColorModel.r/255, self.ColorModel.g/255, self.ColorModel.b/255)
                    end
                    render.SetBlend(1)
                    for i = 0, 6 do
                        if (col) then
                            render.SetModelLighting(i, 1, 1, 1)
                        end
                    end
                    if !self.NoRotation then
                        //self.Model:SetAngles(Angle(0, CurTime()*30, 0))
                    end
                    self.Model:DrawModel()
                    render.SuppressEngineLighting(false)
                cam.End3D()
                render.OverrideAlphaWriteEnable(false)
            render.PopRenderTarget()
            self.customMaterial:SetTexture("$basetexture", dModelPanelRT:GetName())
        end
    end,
    RenderChildren = function(self, draws)
        local base = ((self.y + self.marginTop) - (self.scrollValue * (self.canvasLenght - (self.h - self.marginTop - self.marginBot))))
        local first = (self.y + self.marginTop)
        local lastOffset = 0
        local childLenght = #self.childrenLayout
        for k, v in ipairs(self.childrenLayout) do
            if !v.startDragging then
                v.y = base
            end
            local x, y = self.x, math.max(v.y, self.y + self.marginTop)
            local w, h = self.w, math.max(0, math.min(v.h - (y - v.y), (self.h - self.marginBot) - (y - self.y)))
            if !Aden_DC.Buttons:IsHovered(x, y, w, h, v.RenderViewID) and !v.alwaysClick then
                v.antiClick = true
            end
            if draws and !v.startDragging then
                Aden_DC.Buttons:DrawStencil(function()
                    if v.y < self.y + self.h - self.marginBot and ((v.y + v.h) - (self.y + self.marginTop)) >= 0 then
                        surface.SetDrawColor(255, 255, 255, 255)
                        surface.DrawRect(x, y, w, h)
                    end
                end,
                function()
                    v:Render3D()
                end)
            end
            if !v.line or k == childLenght then
                base = base + v.h + self.spaceY + v.offsetLayoutY
                first = first + v.h + self.spaceY + v.offsetLayoutY
                lastOffset = v.offsetLayoutY
            end
        end
        first = (first - (self.y + self.marginTop) - self.spaceY - lastOffset)
        self.scrollBar.h = (((self.h - self.marginTop - self.marginBot) / (first)) * (self.h - self.marginTop - self.marginBot))
        if self.scrollBar.h > (self.h - self.marginTop - self.marginBot) || self.scrollBar.h < 0 then
            self.scrollBar.h = 0.0001
            self.scrollValue = 0
        elseif self.startDown then
            self.scrollValue = 1
            self.scrollBar.y = self.y + self.marginTop + self.h - self.marginBot - self.scrollBar.h
        end
        self.scrollBar.y = math.Clamp(self.scrollBar.y, self.scrollBar.baseY, self.scrollBar.baseY + ((self.h - self.marginTop - self.marginBot) - self.scrollBar.h))
        self.scrollValue = (self.scrollBar.y - self.scrollBar.baseY) / ((self.h - self.marginTop - self.marginBot) - self.scrollBar.h)
        self.canvasLenght = first
    end,
    Render3D = function(self)
        if isfunction(self.Paint) then self.Paint(self, self.w, self.h, self.x, self.y) end
        if isfunction(self.Think) then self.Think(self) end
        if self.startAnimation then self:AnimThink() end
        if self.childrenLayout then
            self:RenderChildren(true)
            for k, v in ipairs(self.childrenLayout) do
                if v.startDragging then
                    v:Render3D()
                end
            end
        elseif self.Model and self.customMaterial then
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(self.customMaterial)
            surface.DrawTexturedRect(self.x, self.y, self.w, self.h)
        elseif self.openSizeX then
            if self.OpenBySize then
                self.h = Lerp(10/(1/FrameTime()), self.h, self.openSizeX)
            else
                self.h = Lerp(10/(1/FrameTime()), self.h, self.baseOpenX)
            end
        end
    end,
    CreateLayout = function(self, frame, marginTop, marginBot, spaceY, sizeBtnX, marginBtnX, startDown, barColor)
        self.childrenLayout = {}
        self.scrollValue = 0
        self.canvasLenght = 0
        self.marginTop = marginTop
        self.marginBot = marginBot
        self.spaceY = spaceY
        self.mouseFrame = frame
        self.startDown = startDown
        local scrollBar = Aden_DC.Buttons:createButton()
        scrollBar:SetSize(sizeBtnX, 0)
        scrollBar:SetPos(self.x + self.w - marginBtnX, self.y + self.marginTop)
        scrollBar.baseY = self.y + self.marginTop
        scrollBar.parentLayout = self
        scrollBar:SetIdView(self.RenderViewID)
        scrollBar:AddRemoveParent(self)
        scrollBar.Paint = function(self, w, h, x, y)
            if self.Disable then return end
            draw.RoundedBox(30, x, y, w, h, barColor or color_white)
            if self.IsDragging then
                if !isnumber(self.IsDragging) then
                    self.IsDragging = Aden_DC.Buttons:getYCursor(Aden_DC.Buttons.List[self.RenderViewID].scaleView) - y
                end
                local y = Aden_DC.Buttons:getYCursor(Aden_DC.Buttons.List[self.RenderViewID].scaleView) - self.IsDragging
                y = math.Clamp(y, self.baseY, self.baseY + ((self.parentLayout.h - marginTop - marginBot) - self.h))
                self.parentLayout.scrollValue = (y - self.baseY) / ((self.parentLayout.h - marginTop - marginBot) - self.h)
                self:SetPos(self.x, y)
                if !input.IsMouseDown(MOUSE_LEFT) then
                    self.IsDragging = false
                    Aden_DC.Buttons.IsDragging = false
                end
            elseif self.IsWheeled and self.parentLayout:IsHovered() then
                self.y = math.Clamp(self.y - self.IsWheeled, self.baseY, self.baseY + ((self.parentLayout.h - marginTop - marginBot) - self.h))
                self.parentLayout.scrollValue = (y - self.baseY) / ((self.parentLayout.h - marginTop - marginBot) - self.h)
            end
            self.IsWheeled = false
        end
        scrollBar.DoClick = function(self)
            self.IsDragging = true
            Aden_DC.Buttons.IsDragging = true
        end
        self.OnRemove = function(self)
            if IsValid(Aden_DC.tempFrame) then
                Aden_DC.tempFrame:Remove()
            end
        end
        if !IsValid(frame) and !IsValid(Aden_DC.tempFrame) then
            frame = vgui.Create("DFrame")
            frame:SetSize(Aden_DC.ScrW,Aden_DC.ScrH)
            frame:ShowCloseButton(false)
            frame:SetTitle("")
            frame.Temp = true
            frame.Paint = function(self)
                frame:MoveToBack()
            end
            Aden_DC.tempFrame = frame
        elseif IsValid(Aden_DC.tempFrame) then
            frame = Aden_DC.tempFrame
        end
        if IsValid(frame) then
            local save = frame.OnMouseWheeled or function() end
            frame.OnMouseWheeled = function(_, delta)
                self.scrollBar.IsWheeled = self.scrollBar.IsWheeled and self.scrollBar.IsWheeled + (delta / math.abs(delta))*self.scrollBar.h / 10 or (delta / math.abs(delta))*self.scrollBar.h / 10
                save(_, delta)
            end
        end
        self.scrollBar = scrollBar
    end,
    AddToLayout = function(self, children, pos)
        if pos then
            table.insert(self.childrenLayout, pos, children)
        else
            self.childrenLayout[#self.childrenLayout + 1] = children
        end
        children.RenderViewID = self.RenderViewID
        children.ParentLayout = self
        self.scrollBar.h = 0
        self.scrollBar.y = self.scrollBar.baseY
        self.scrollValue = 0
    end,
    RemoveToLayout = function(self)
        self.ParentLayout.scrollBar.h = 0
        self.ParentLayout.scrollValue = 0
        self.ParentLayout.scrollBar.y = self.ParentLayout.scrollBar.baseY
        table.RemoveByValue(self.ParentLayout.childrenLayout, self)
    end,
    AnimThink = function(self)
        local vector = LerpVector(self.animTime, Vector(self.x, self.y, 0), Vector(self.endPosX, self.endPosY, 0))
        self:SetPos(vector.x, vector.y)
    end,
    MoveTo = function(self, x, y, second)
        self.endPosX = x
        self.endPosY = y

        self.animTime = second ^ -3

        self.startAnimation = true
        return self
    end,
    SetTextEntry = function(self, text, frame, multi, base)
        self.textDraw = text
        self.baseText = text
        self.DoClick = function(self)
            if self.textDraw == text then
                self.textDraw = base and tostring(base) or ""
                self.isReady = true
            end
            local removeFrame = false
            if !IsValid(frame) then
                frame = vgui.Create("DFrame")
                frame:SetSize(Aden_DC.ScrW, Aden_DC.ScrH)
                frame:MakePopup()
                frame:SetTitle("")
                frame:ShowCloseButton(false)
                frame.Paint = function() end
                removeFrame = true
            end
            self.mEntry = vgui.Create("DTextEntry", frame)
            self.mEntry:SetSize(300, Aden_DC.ScrW/20)
            self.mEntry:SetText(self.textDraw)
            self.mEntry:SetCaretPos(#self.textDraw)
            self.mEntry:SetMultiline(multi or false)
            self.mEntry.Paint = function(selfs)
                self.textDraw = selfs:GetText()
                if !selfs:HasFocus() then
                    if self.textDraw == "" then
                        self.textDraw = self.baseText
                    end
                    selfs:Remove()
                    if removeFrame and IsValid(frame) then
                        frame:Remove()
                    end
                    Aden_DC.Buttons.IsDragging = true
                end
            end
            self.mEntry.OnEnter = function()
                if self.OnEnter then
                    self:OnEnter()
                end
            end
            if self.entryLoad then
                self.entryLoad(self.mEntry)
                if multi then
                    self.mEntry.AllowInput = function(selfs, stringValue)
                        surface.SetFont(selfs.drawFont or "ADCFont::1")
                        local w, h = surface.GetTextSize(selfs:GetText() .. stringValue)
                        if h > self.h-10 then
                            return true
                        end
                        if (w >= self.w-40) then
                            w, h = surface.GetTextSize(selfs:GetText() .. "\n test")
                            if h > self.h-10 then
                                return true
                            end
                            selfs:SetText(selfs:GetText() .. "\n")
                            self.textDraw = selfs:GetText()
                            selfs:SetCaretPos(#self.textDraw)
                        end
                    end
                else
                    self.mEntry.AllowInput = function(self, stringValue)
                        if (self:CheckNumeric(stringValue)) then return true end
                        if self:GetNumeric() and stringValue == "-" then return true end
                        if self.maxChar then
                            if #self:GetText() >= self.maxChar then return true end
                        end
                        if self.nameEntry then
                            return Aden_DC.Func:AvailableChar(stringValue)
                        end
                    end
                end
            end
            self.mEntry:RequestFocus()
        end
    end,
    DrawTextEntry = function(self, x, y, bl, textAdd)
        if IsValid(self.mEntry) then
            if math.floor(CurTime()*2)%2 == 0 or input.IsKeyDown(KEY_RIGHT) or input.IsKeyDown(KEY_LEFT) then
                local firstText, lastText = Aden_DC:StringSeparate(self.textDraw, self.mEntry:GetCaretPos())
                surface.SetFont(self.drawFont or "ADCFont::1")
                local explodeText = string.Explode("\n", firstText)
                firstText = explodeText[#explodeText]
                local sizeX, sizeY = surface.GetTextSize(firstText)
                surface.SetDrawColor(255, 255, 255, 255)
                surface.DrawRect(x + sizeX, y + sizeY*(#explodeText-1), 1, sizeY)
            end
        end
        if self.textDraw == self.baseText then
            draw.DrawText(self.textDraw .. (textAdd or ""), self.drawFont or "ADCFont::1", x, y, Aden_DC.ClientSideMenu.Colors["grey"], TEXT_ALIGN_LEFT)
            return
        end
        if (self.isReady and self.customCheck and self.customCheck(self.textDraw)) then
            draw.DrawText(self.textDraw .. (textAdd or ""), self.drawFont or "ADCFont::1", x, y, Aden_DC.ClientSideMenu.Colors["red"], TEXT_ALIGN_LEFT)
        else
            draw.DrawText(self.textDraw .. (textAdd or ""), self.drawFont or "ADCFont::1", x, y, color_white, TEXT_ALIGN_LEFT)
        end
    end,
    GetText = function(self)
        return self.textDraw
    end,
    SetText = function(self, txt)
        self.textDraw = txt
    end,
    AddRemoveParent = function(self, parent)
        parent.Children = parent.Children or {}
        parent.Children[#parent.Children + 1] = self
    end,
    CreateDModelPanel = function(self, model)
        if IsValid(self.Model) then
            self.Model:Remove()
        end
        self.Model = ClientsideModel(model, RENDERGROUP_OPAQUE)
        self.Model:SetNoDraw(true)
        self.Model:SetIK(false)
        self.CreateModelId = Aden_DC.ClientSideMenu.ModelId
        Aden_DC.ClientSideMenu.ModelId = Aden_DC.ClientSideMenu.ModelId + 1
        self.OnRemove = function(self)
            if IsValid(self.Model) then
                self.Model:Remove()
            end
            //Aden_DC.ClientSideMenu.ModelId = Aden_DC.ClientSideMenu.ModelId - 1
        end
        self.customMaterial = CreateMaterial("dModelPanelRT" .. self.CreateModelId, "UnlitGeneric", {
            ["$translucent"] = 1,
            ["$vertexcolor"] = 1
        })
    end,
    SetColorModel = function(self, color)
        self.ColorModel = color
    end,
    SetOpenSize = function(self, x)
        if !self.baseOpenX then
            self.baseOpenX = self.h
        end
        self.openSizeX = x
    end,
    GetOpenSize = function(self)
        return self.openSizeX
    end,
    SetOpen = function(self, bool)
        self.OpenBySize = bool
    end,
    GetOpen = function(self)
        return self.OpenBySize
    end,
}
AccessorFunc(meta, "FOVValue", "FOV", FORCE_NUMBER)
AccessorFunc(meta, "CamPosValue", "CamPos", FORCE_VECTOR)
AccessorFunc(meta, "LookAtValue", "LookAt", FORCE_VECTOR)

function Aden_DC.Buttons:createButton()
    local button = {}
    button.x = 0
    button.y = 0
    button.w = 0
    button.h = 0
    button.RenderViewID = nil
    button.offsetLayoutY = 0

    meta.__index = meta
    setmetatable(button, meta)
    return button
end

function Aden_DC.Buttons:drawView(posView, angView, fovView, ...)
    local x, y = input.GetCursorPos()
    local arrayButton = {}
    if #{...} >= 1 then // Draw only the vargs
        for k, v in ipairs({...}) do
            arrayButton[v] = self.List[v]
        end
    else
        arrayButton = self.List
    end
    for _, v in pairs(arrayButton) do
        if v.ndrawView then continue end

        local aimDirec = util.AimVector(angView or Aden_DC.LocalPlayer:EyeAngles(), fovView or 85, x, y, Aden_DC.ScrW, Aden_DC.ScrH)
        local collidePos = util.IntersectRayWithPlane(posView or Aden_DC.LocalPlayer:EyePos(), aimDirec, v.posView, v.angView:Up())

        if collidePos then
            self.cursorPos = WorldToLocal(collidePos, Angle(0, 0, 0), v.posView, v.angView)
        end

        if self.IsDragging and !input.IsMouseDown(MOUSE_LEFT) then
            self.IsDragging = false
        end

        for _, j in ipairs(v.buttonsView) do
            if j.Model then
                j:RenderModel()
            end
        end

        cam.Start3D2D(v.posView, v.angView, v.scaleView or 0.07)
        for _, j in ipairs(v.buttonsView) do
            if IsValid(j) and ispanel(j) then // For spawnicon
                j:PaintManual()
            elseif !j.PaintManual then
                j:Render3D()
            end
        end
        cam.End3D2D()
        for _, j in SortedPairs(v.buttonsView, true) do
            if !ispanel(j) then
                if j.childrenLayout then
                    for _, child in SortedPairs(j.childrenLayout, true) do
                        if child:IsCliked() then
                            break
                        end
                    end
                elseif j:IsCliked() then
                    break
                end
            end
        end
    end
end

function Aden_DC.Buttons:IsHovered(x, y, w, h, RenderViewID)
    if Aden_DC.Buttons.List[RenderViewID] and Aden_DC.Buttons:getXCursor(Aden_DC.Buttons.List[RenderViewID].scaleView) > x and Aden_DC.Buttons:getXCursor(Aden_DC.Buttons.List[RenderViewID].scaleView) < x + w and Aden_DC.Buttons:getYCursor(Aden_DC.Buttons.List[RenderViewID].scaleView) > y and Aden_DC.Buttons:getYCursor(Aden_DC.Buttons.List[RenderViewID].scaleView) < y + h then
        return true
    else
        return false
    end
end

function Aden_DC.Buttons:DrawStencil(calcFunc, drawFunc, id)
    render.SetStencilWriteMask(0xFF)
    render.SetStencilTestMask(0xFF)
    render.SetStencilReferenceValue(id or 0)
    render.SetStencilPassOperation(STENCIL_KEEP)
    render.SetStencilZFailOperation(STENCIL_KEEP)
    render.ClearStencil()

    render.SetStencilEnable(true)
    render.SetStencilReferenceValue(id and (id + 1) or 1)
    render.SetStencilCompareFunction(STENCIL_NEVER)
    render.SetStencilFailOperation(STENCIL_REPLACE)
    calcFunc()
    render.SetStencilCompareFunction(STENCIL_EQUAL)
    render.SetStencilFailOperation(STENCIL_KEEP)
    drawFunc()
    render.SetStencilEnable(false)
end

function Aden_DC:StringSeparate(text, pos) // 3D2D TextEntry cursor position
    return utf8.sub(text, 1, pos), utf8.sub(text, pos+1)
end
