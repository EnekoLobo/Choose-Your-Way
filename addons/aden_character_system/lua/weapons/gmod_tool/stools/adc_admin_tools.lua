TOOL.Category = "Configuration"
TOOL.Name = "ADC Admin"

if CLIENT then
    language.Add("tool.adc_admin_tools.name", "Aden Character")
    language.Add("tool.adc_admin_tools.desc", "Use this tools to manage players and the NPCs")
    language.Add("tool.adc_admin_tools.0", "Left click : Update a player data")

    function TOOL:LeftClick(tr)
        if Aden_DC:isAdmin(self:GetOwner()) then
            if IsValid(Aden_DC.adminRagdoll) then
                net.Start("ADC::AdminNetworking")
                net.WriteUInt(4, 8)
                net.WriteUInt(1, 2)
                net.SendToServer()
                Aden_DC.adminRagdoll:Remove()
            elseif IsValid(tr.Entity) and tr.Entity:IsPlayer() then
                Aden_DC:OpenMenuAdmin()
                net.Start("ADC::AdminNetworking")
                net.WriteUInt(1, 8)
                net.WriteBit(true)
                net.WriteEntity(tr.Entity)
                net.SendToServer()
            end
            return true
        end
    end

    function TOOL:Holster()
        if IsValid(Aden_DC.adminRagdoll) then
            Aden_DC.adminRagdoll:Remove()
        end
    end

    function TOOL:Reload()
        if IsValid(Aden_DC.adminRagdoll) then
            Aden_DC.adminRagdoll:Remove()
        end
        return true
    end

    hook.Add("PostDrawOpaqueRenderables","ADC:PostDrawOpaqueRenderables:DrawRagdoll",function()
        if IsValid(Aden_DC.adminRagdoll) then
            local npcAng = LocalPlayer():GetAngles()
            npcAng:RotateAroundAxis(npcAng:Up(), 180)
            npcAng.x = 0
            Aden_DC.adminRagdoll:SetPos(LocalPlayer():GetEyeTrace().HitPos)
            Aden_DC.adminRagdoll:SetAngles(npcAng)
            Aden_DC.adminRagdoll:DrawModel()
        end
    end)

    function TOOL.BuildCPanel(panel)

        local base = vgui.Create("DPanel")
        base:SetSize(0, ScrH()/3)
        base.Paint = function(self, w, h)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[24])
            surface.DrawTexturedRect(0, 0, w, h/1.8)
        end
        panel:AddPanel(base)

        timer.Simple(1, function()
            if !IsValid(base) then return end
            local adminMenu = vgui.Create("DButton", base)
            adminMenu:SetSize(base:GetWide()/1.2, base:GetTall()/10)
            adminMenu:SetPos(base:GetWide()/2 - adminMenu:GetWide()/2, base:GetTall()/20)
            adminMenu:SetText("")
            adminMenu.Paint = function(self, w, h)
                surface.SetDrawColor(255, 255, 255, 225)
                if self:IsHovered() then
                    surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[31])
                else
                    surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[30])
                end
                surface.DrawTexturedRect(0, 0, w, h)
                draw.DrawText(Aden_DC:GetPhrase("adminmenu"), "ADCFont::3", w/2, h/10, color_white, TEXT_ALIGN_CENTER)
            end
            adminMenu.DoClick = function()
                if !Aden_DC:isAdmin(LocalPlayer()) then return end
                Aden_DC:OpenMenuAdmin()
            end

            local npcSpawn = vgui.Create("DButton", base)
            npcSpawn:SetSize(base:GetWide()/1.2, base:GetTall()/10)
            npcSpawn:SetPos(base:GetWide()/2 - npcSpawn:GetWide()/2, base:GetTall()/20 + base:GetTall()/9)
            npcSpawn:SetText("")
            npcSpawn.Paint = function(self, w, h)
                surface.SetDrawColor(255, 255, 255, 225)
                if self:IsHovered() then
                    surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[31])
                else
                    surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[30])
                end
                surface.DrawTexturedRect(0, 0, w, h)
                draw.DrawText(Aden_DC:GetPhrase("spawnnpc"), "ADCFont::3", w/2, h/10, color_white, TEXT_ALIGN_CENTER)
            end
            npcSpawn.DoClick = function()
                if !Aden_DC:isAdmin(LocalPlayer()) then return end
                local tool = LocalPlayer():GetWeapon("gmod_tool")
                if !IsValid(tool) then return end
                input.SelectWeapon(tool)
                Aden_DC.adminRagdoll = ClientsideModel("models/breen.mdl")
                Aden_DC.adminRagdoll:SetPos(LocalPlayer():GetEyeTrace().HitPos)
                Aden_DC.adminRagdoll:SetNoDraw(true)
                Aden_DC.adminRagdoll:SetMaterial("models/wireframe")
            end

            local npcSave = vgui.Create("DButton", base)
            npcSave:SetSize(base:GetWide()/1.2, base:GetTall()/10)
            npcSave:SetPos(base:GetWide()/2 - npcSave:GetWide()/2, base:GetTall()/20 + base:GetTall()/9 * 2)
            npcSave:SetText("")
            npcSave.Paint = function(self, w, h)
                surface.SetDrawColor(255, 255, 255, 225)
                if self:IsHovered() then
                    surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[31])
                else
                    surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[30])
                end
                surface.DrawTexturedRect(0, 0, w, h)
                draw.DrawText(Aden_DC:GetPhrase("savenpc"), "ADCFont::3", w/2, h/10, color_white, TEXT_ALIGN_CENTER)
            end
            npcSave.DoClick = function()
                if !Aden_DC:isAdmin(LocalPlayer()) then return end
                net.Start("ADC::AdminNetworking")
                net.WriteUInt(4, 8)
                net.WriteUInt(2, 2)
                net.SendToServer()
            end

            local npcDelete = vgui.Create("DButton", base)
            npcDelete:SetSize(base:GetWide()/1.2, base:GetTall()/10)
            npcDelete:SetPos(base:GetWide()/2 - npcDelete:GetWide()/2, base:GetTall()/20 + base:GetTall()/9 * 3)
            npcDelete:SetText("")
            npcDelete.Paint = function(self, w, h)
                surface.SetDrawColor(255, 255, 255, 225)
                if self:IsHovered() then
                    surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[31])
                else
                    surface.SetMaterial(Aden_DC.ClientSideMenu.Mat[30])
                end
                surface.DrawTexturedRect(0, 0, w, h)
                draw.DrawText(Aden_DC:GetPhrase("deletenpc"), "ADCFont::3", w/2, h/10, color_white, TEXT_ALIGN_CENTER)
            end
            npcDelete.DoClick = function()
                if !Aden_DC:isAdmin(LocalPlayer()) then return end
                net.Start("ADC::AdminNetworking")
                net.WriteUInt(4, 8)
                net.WriteUInt(3, 2)
                net.SendToServer()
            end
        end)
    end
end
