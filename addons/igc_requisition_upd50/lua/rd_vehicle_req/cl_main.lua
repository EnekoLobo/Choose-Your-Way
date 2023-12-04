local R_FRAME

--[[----------------------------------------------------------------]]--
--  Send the request to all players who can grant it.
--[[----------------------------------------------------------------]]--
local INFO = {}

local function SelectHangar(O_FRAME, V_CLASS)
    if not V_CLASS then
        return
    end

    local V_TAB = RDV.VEHICLE_REQ.VEHICLES[V_CLASS]

    if not V_TAB then
        return
    end

    local COUNT = 0

    local FRAME = vgui.Create("PIXEL.Frame")
    FRAME:SetSize(ScrW() * 0.2, ScrH() * 0.4)
    FRAME:Center()
    FRAME:MakePopup(true)
    FRAME:SetMouseInputEnabled(true)
    FRAME:SetTitle(RDV.LIBRARY.GetLang(nil, "VR_addonTitle"))
    FRAME.OnRemove = function()
        if IsValid(O_FRAME) then
            O_FRAME:SetVisible(true)
        end
    end

    local w, h = FRAME:GetSize()

    local LUnavailableSpawns = RDV.LIBRARY.GetLang(nil, "VR_unavailableSpawns")

    local SCROLL = vgui.Create("PIXEL.ScrollPanel", FRAME)
    SCROLL:Dock(FILL)
    SCROLL:SetMouseInputEnabled(true)
    SCROLL.PaintOver = function(self, w, h)
        if COUNT <= 0 then
            draw.SimpleText(LUnavailableSpawns, "RDV_REQ_LabelFont", w * 0.5, h * 0.4, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    if IsValid(O_FRAME) then
        O_FRAME:SetVisible(false)
    end

    for k, v in pairs(RDV.VEHICLE_REQ.SPAWNS) do
        if V_TAB.SPAWNS and !table.IsEmpty(V_TAB.SPAWNS) then
            if !V_TAB.SPAWNS[k] then
                continue 
            end
        end

        if v.MAP and ( v.MAP ~= game.GetMap() ) then continue end
        
        if v.RTEAMS and !table.IsEmpty(v.RTEAMS) and !v.RTEAMS[team.GetName(LocalPlayer():Team())] then continue end
        
        if v.CanRequest and ( v:CanRequest(LocalPlayer()) == false ) then
            continue
        end
        
        local DISTANCE = (string.Explode(".", v.POS:Distance(LocalPlayer():GetPos()) / 52.49))[1]

        if RDV.VEHICLE_REQ.CFG.MAX_DIST then
            if tonumber(DISTANCE) >= (RDV.VEHICLE_REQ.CFG.MAX_DIST or 500) then
                continue
            end
        end

        COUNT = COUNT + 1

        local HANGAR_IN_USE = RDV.VEHICLE_REQ.IsHangarInUse(k)

        local claimedLabel = RDV.LIBRARY.GetLang(nil, "VR_claimedLabel")
        local unclaimedLabel = RDV.LIBRARY.GetLang(nil, "VR_unclaimedLabel")

        local label = SCROLL:Add("DLabel")
        label:SetSize(0, h * 0.1)
        label:DockMargin(w * 0.01, h * 0.01, w * 0.01, 0)
        label:Dock(TOP)
        label:SetText("")
        label:SetMouseInputEnabled(true)
        label.Paint = function(self, w, h)
            surface.SetDrawColor(PIXEL.CopyColor(PIXEL.Colors.Header))
            surface.DrawRect( 0, 0, w, h )
            
            local COL = color_white

            if self:IsHovered() then
                COL = Color(252,180,9,255)
            end

            draw.SimpleText(RDV.LIBRARY.TruncateString(v.NAME, w * 0.0325 ), "RDV_REQ_LabelFont", w * 0.05, h * 0.5, COL, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

            draw.SimpleText("("..(HANGAR_IN_USE and claimedLabel or unclaimedLabel)..")", "RDV_REQ_LabelFont", w * 0.5, h * 0.5, COL, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            draw.SimpleText(DISTANCE.."m", "RDV_REQ_LabelFont", w * 0.95, h * 0.5, COL, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end

        label.DoClick = function() 
            if IsValid(O_FRAME) then O_FRAME:Remove() end
            if IsValid(FRAME) then FRAME:Remove() end

            INFO[V_CLASS] = INFO[V_CLASS] or {}

            net.Start("RDV.VEHICLE_REQ.START")
                net.WriteString(V_TAB.UID) -- Vehicle
                net.WriteString(k) -- Spawn
                net.WriteTable(INFO[V_CLASS]) -- Info
            net.SendToServer()
        end
    end
end



local function AddLabel(SHIP, HANGAR, UID, TIME)
    if not RDV.VEHICLE_REQ.VEHICLES[SHIP] then
        return
    end
    
    local PLAYER = Entity(UID)

    if !IsValid(PLAYER) then
        return
    end

    local PCOLOR = team.GetColor(PLAYER:Team())
    local PNAME = PLAYER:Name()

    local SNAME = ( RDV.VEHICLE_REQ.VEHICLES[SHIP].NAME or "INVALID" )
    local HNAME = ( RDV.VEHICLE_REQ.SPAWNS[HANGAR].NAME or "INVALID" )

    local SCROLL

    if not IsValid(R_FRAME) then
        local LTitle = RDV.LIBRARY.GetLang(nil, "VR_addonTitle")

        R_FRAME = vgui.Create("PIXEL.Frame")
        R_FRAME:SetSize(ScrW() * 0.15, ScrH() * 0.35)
        R_FRAME:SetPos(ScrW() * 0.01, ScrH() * 0.35)
        R_FRAME:SetMouseInputEnabled(true)
        R_FRAME:SetTitle(LTitle)

        SCROLL = vgui.Create("PIXEL.ScrollPanel", R_FRAME)
        SCROLL:Dock(FILL)
    end

    local w, h = R_FRAME:GetSize()

    local label = SCROLL:Add("DButton")
    label:SetSize(0, h * 0.2)
    label:DockMargin(w * 0.03, h * 0.015, w * 0.03, 0)
    label:Dock(TOP)
    label:SetText("")
    label.Paint = function(self, w, h)
        local TIME = timer.TimeLeft("VR_"..PLAYER:SteamID64())

        surface.SetDrawColor(PIXEL.CopyColor(PIXEL.Colors.Header))
        surface.DrawRect( 0, 0, w, h )
        
        draw.SimpleText(SNAME, "RDV_REQ_LabelFont", w * 0.5, h * 0.2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        draw.SimpleText(HNAME, "RDV_REQ_LabelFont", w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)


        if not IsValid(PLAYER) then
            self:Remove()
            return
        end

        draw.SimpleText(PNAME.." ("..math.Round(TIME)..")", "RDV_REQ_LabelFont", w * 0.5, h * 0.8, PCOLOR, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end 
    label.DoClick = function()
        if not IsValid(PLAYER) then
            return
        end

        surface.PlaySound("rdv/new/activate.mp3")

        local LGrant = RDV.LIBRARY.GetLang(nil, "VR_grantLabel")
        local LDeny = RDV.LIBRARY.GetLang(nil, "VR_denyLabel")

        local MenuButtonOptions = DermaMenu()

        MenuButtonOptions:AddOption(LGrant, function()
            net.Start("RDV.VEHICLE_REQ.GRANT")
                net.WriteUInt(UID, 8)
            net.SendToServer()
        end)

        MenuButtonOptions:AddOption(LDeny, function()
            net.Start("RDV.VEHICLE_REQ.DENY")
                net.WriteUInt(UID, 8)
            net.SendToServer()
        end)

        MenuButtonOptions:Open()
    end

    if !TIME then
        TIME = ( RDV.VEHICLE_REQ.CFG.Waiting or 60 )

        timer.Create("VR_"..PLAYER:SteamID64(), TIME, 1, function()
            label:Remove()

            RDV.VEHICLE_REQ.ACTIVE[UID] = nil

            if RDV.VEHICLE_REQ.ACTIVE and table.Count(RDV.VEHICLE_REQ.ACTIVE) <= 0 then
                if IsValid(R_FRAME) then
                    R_FRAME:Remove()
                end
            end
        end )
    end

    RDV.VEHICLE_REQ.ACTIVE[UID] = {
        Ship = SHIP,
        Hangar = HANGAR,
        Label = label,
    }
end

--[[----------------------------------------------------------------]]--
--  Purge the player because they've been denied / accepted/
--[[----------------------------------------------------------------]]--

net.Receive("RDV_VR_CLEAR", function()
    local UID = net.ReadUInt(8)
    local R_PLAYER = Entity(UID)

    if !RDV.VEHICLE_REQ.ACTIVE or !RDV.VEHICLE_REQ.ACTIVE[UID] then
        return
    end

    local label = RDV.VEHICLE_REQ.ACTIVE[UID].Label

    if IsValid(label) then
        label:Remove()
    end

    RDV.VEHICLE_REQ.ACTIVE[UID] = nil

    if RDV.VEHICLE_REQ.ACTIVE and table.Count(RDV.VEHICLE_REQ.ACTIVE) <= 0 then
        if IsValid(R_FRAME) then
            R_FRAME:Remove()
        end
    end

    if IsValid(R_PLAYER) then
        timer.Remove("VR_"..R_PLAYER:SteamID64())
    end
end)


net.Receive("RDV_VR_INITIAL", function()
    local DATA = net.ReadTable()

    for k, v in pairs(DATA) do
        local SHIP = v.VEHICLE
        local SPAWN = v.SPAWN
        local UID = k
        local TIME = net.ReadUInt(8)

        AddLabel(SHIP, SPAWN, UID, v.TIME)
    end
end)

net.Receive("RDV_VR_ASK", function()
    local VEHICLE = net.ReadString()
    local SPAWN = net.ReadString()
    local UID = net.ReadUInt(8)

    AddLabel(VEHICLE, SPAWN, UID)

    surface.PlaySound("buttons/blip1.wav")
end)

--[[----------------------------------------------------------------]]--
--  Main Request Menu
--[[----------------------------------------------------------------]]--

local function ChangeIcon(ICON, model)
    if !model then return end

    if model and model ~= "" then
        ICON:SetModel(model)

        local mn, mx = ICON.Entity:GetRenderBounds()
    
        local size = 0
    
        size = Lerp(0.5, mx.z, mn.z)
    
        ICON:SetCamPos(Vector(size, size, size) + mx)
        ICON:SetLookAt(ICON:GetEntity():GetPos())
        ICON:SetAmbientLight( color_white )
    else
        return
    end
end

net.Receive("RDV.VEHICLE_REQ.MENU", function()
    local ICON
    local B_SKIN

    local SELECTED
    local V_CLASS
    
    local FRAMED = vgui.Create("PIXEL.Frame")
    FRAMED:SetSize(ScrW() * 0.4, ScrH() * 0.6)
    FRAMED:Center()
    FRAMED:MakePopup(true)
    FRAMED:SetMouseInputEnabled(true)
    FRAMED:SetTitle(RDV.LIBRARY.GetLang(nil, "VR_addonTitle"))

    local w,h = FRAMED:GetSize()


    local PANEL = vgui.Create("DPanel", FRAMED)
    PANEL:Dock(FILL)
    PANEL.Paint = function() end


    --[[--------------------------------------------------------]]--
    --  Left side of the panel (scrollbar)
    --[[--------------------------------------------------------]]--


        local PANEL_LEFT = vgui.Create("DPanel", PANEL)
        PANEL_LEFT:SetSize(w * 0.5, h)
        PANEL_LEFT:Dock(LEFT)
        PANEL_LEFT:SetMouseInputEnabled(true)
        PANEL_LEFT.Paint = function() end


        local COUNT = 0

        local LVehiclesUnavailable = RDV.LIBRARY.GetLang(nil, "VR_vehiclesUnavailable")

        local SCROLL = vgui.Create("PIXEL.ScrollPanel", PANEL_LEFT)
        SCROLL:DockMargin(0, 0, w * 0.01, 0)
        SCROLL:Dock(FILL)
        SCROLL:SetMouseInputEnabled(true)
        SCROLL.PaintOver = function(self, w, h)
            if COUNT <= 0 then
                draw.SimpleText(LVehiclesUnavailable, "RDV_REQ_LabelFont", w * 0.5, h * 0.4, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
        SCROLL.Paint = function(s, w, h) 
            draw.RoundedBox(0, 0, 0, w, h, Color(28, 28, 28))
        end

        local DELAY = 0.5 + SysTime()

        SCROLL.Think = function(self, w, h)
            if DELAY > SysTime() then
                return
            end

            DELAY = 0.5 + SysTime()

            if not self:IsChildHovered() then
                if !V_CLASS then
                    return
                end

                local VEH = RDV.VEHICLE_REQ.VEHICLES[V_CLASS]

                if !VEH then
                    return
                end

                if ICON:GetModel() ~= VEH.MODEL then
                    ChangeIcon(ICON, VEH.MODEL)
                end

                if INFO[V_CLASS] then
                    local C_SKIN = INFO[V_CLASS].SKIN

                    if VEH.S_CONFIG and VEH.S_CONFIG[C_SKIN] and VEH.S_CONFIG[C_SKIN].ENABLED then
                        ICON.Entity:SetSkin(C_SKIN)
                    else
                        ICON.Entity:SetSkin( (VEH.SKIN or 1) )
                    end
                end
            end
        end

        local CATEGORIES = {}
        local COMBO_S
        local COMBO_T

        local FIRST

        for k, v in pairs(RDV.VEHICLE_REQ.VEHICLES) do
            if !v.CATEGORY then v.CATEGORY = "Invalid" end
            
            if v.RTEAMS and !table.IsEmpty(v.RTEAMS) and !v.RTEAMS[team.GetName(LocalPlayer():Team())] then continue end

            if v.CanRequest and ( v:CanRequest(LocalPlayer()) == false ) then
                continue
            end

            if !FIRST then FIRST = v.MODEL end

            COUNT = COUNT + 1

            if not CATEGORIES[v.CATEGORY] then
                local D_CATEGORY = SCROLL:Add("DCollapsibleCategory")

                local CAT_LABEL = D_CATEGORY:GetChildren()[1]
        
                D_CATEGORY:Dock(TOP)
                D_CATEGORY:SetLabel( v.CATEGORY )
                D_CATEGORY:DockMargin(0, 0, 0, h * 0.035)
                D_CATEGORY:SetTall(D_CATEGORY:GetTall() * 1.25)
                D_CATEGORY:DockPadding(0, 0, 0, h * 0.025)
                CAT_LABEL:SetContentAlignment(5)
                CAT_LABEL:SetFont("RDV_REQ_LabelFont")
                CAT_LABEL:SetTall(CAT_LABEL:GetTall() * 1.5) 


                CATEGORIES[v.CATEGORY] = D_CATEGORY
            end

            local CATEGORY = CATEGORIES[v.CATEGORY]
            
            local FORMAT

            if v.PRICE and ( v.PRICE > 0 ) then
                FORMAT = RDV.LIBRARY.FormatMoney(nil, v.PRICE)
            end

            local label = CATEGORY:Add("PIXEL.TextButton")
            label:SetSize(0, h * 0.1)
            label:DockMargin(w * 0.01, h * 0.01, w * 0.01, h * 0.01)
            label:Dock(TOP)
            label:SetText("")

            local LAccept = RDV.LIBRARY.GetLang(nil, "VR_acceptLabel")

            local BUTTON = vgui.Create("PIXEL.TextButton", label)
            BUTTON:Dock(RIGHT)
            if FORMAT then
                BUTTON:SetText(LAccept.." ("..FORMAT..")")
            else
                BUTTON:SetText(LAccept)
            end
            BUTTON:SizeToContents()

            BUTTON.DoClick = function(s)                
                if (SELECTED ~= BUTTON ) then
                    if IsValid(SELECTED) then
                        if FORMAT then
                            SELECTED:SetText(LAccept.." ("..FORMAT..")")
                        else
                            SELECTED:SetText(LAccept)
                        end

                        SELECTED:SizeToContents()
                    end

                    if FORMAT then
                        BUTTON:SetText(RDV.LIBRARY.GetLang(nil, "VR_confirmLabel").." ("..FORMAT..")")
                    else
                        BUTTON:SetText(RDV.LIBRARY.GetLang(nil, "VR_confirmLabel"))
                    end

                    BUTTON:SizeToContents()

                    COMBO_S:Clear()
                    COMBO_T:Clear()

                    SELECTED = BUTTON
                    V_CLASS = k

                    INFO[V_CLASS] = INFO[v_CLASS] or {}

                    for k, v in pairs(v.S_CONFIG) do
                        if v.ENABLED then
                            local I = COMBO_S:AddChoice( (v.NAME or k), k )

                            if ( INFO[V_CLASS].SKIN == k ) then
                                COMBO_S:ChooseOptionID(I)
                            end
                        end
                    end

                    for L, L_D in pairs(v.LOADOUTS) do
                        local I = COMBO_T:AddChoice( (L_D.NAME or L), L )

                        if ( INFO[V_CLASS].LOADOUT == L ) or (v.L_DEFAULT == L) then
                            COMBO_T:ChooseOptionID(I)
                        end
                    end

                    surface.PlaySound("rdv/new/activate.mp3")

                    if v.MODEL then
                        local V_CFG = v

                        ChangeIcon(ICON, v.MODEL)
                        
                        local E = ICON:GetEntity()

                        if !IsValid(E) then return end

                        local DA = INFO[k].LOADOUT

                        if DA then
                            for k, v in ipairs(E:GetBodyGroups()) do
                                if V_CFG.LOADOUTS[DA].OPTIONS[v.id] then
                                    E:SetBodygroup(v.id, V_CFG.LOADOUTS[DA].OPTIONS[v.id])
                                else
                                    E:SetBodygroup(v.id, 0)
                                end
                            end
                        end
    
                        local C_SKIN = INFO[k].SKIN

                        if v.S_CONFIG and v.S_CONFIG[C_SKIN] and v.S_CONFIG[C_SKIN].ENABLED then
                            ICON.Entity:SetSkin(C_SKIN)
                        else
                            ICON.Entity:SetSkin( (v.SKIN or 1) )
                        end
                    end
                else
                    SelectHangar(FRAMED, k)
                end
            end

            local LChangeSkin = RDV.LIBRARY.GetLang(nil, "VR_changeSkin")

            label.Paint = function(self, w, h)            
                surface.SetDrawColor(PIXEL.CopyColor(PIXEL.Colors.Background))
                surface.DrawRect( 0, 0, w, h )

                draw.SimpleText(RDV.LIBRARY.TruncateString(v.NAME, w * 0.05), "RDV_REQ_LabelFont", w * 0.05, h * 0.5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            label.DoClick = function()
                if IsValid(B_SKIN) and v.CUSTOMIZABLE then
                    B_SKIN:SetText(LChangeSkin.." ("..ICON.Entity:GetSkin()..")")
                end
            end
        end

        local DOCKER = vgui.Create("DPanel", PANEL_LEFT)
        DOCKER:SetSize(0, h * 0.1)
        DOCKER:DockMargin(0, h * 0.01, w * 0.01, h * 0.01)

        DOCKER:Dock(BOTTOM)
        DOCKER:SetMouseInputEnabled(true)
        DOCKER.Paint = function() end

        local returnLabel = RDV.LIBRARY.GetLang(nil, "VR_returnLabel")

        local RETURN = vgui.Create("PIXEL.TextButton", DOCKER)
        RETURN:Dock(FILL)
        RETURN:SetText(returnLabel)

        RETURN.DoClick = function()
            net.Start("RDV.VEHICLE_REQ.RETURN")
            net.SendToServer()
        end

        --[[--------------------------------------------------------]]--
        --  Left side of the panel (ModelPanel)
        --[[--------------------------------------------------------]]--

        local PANEL_RIGHT = vgui.Create("DPanel", PANEL)
        PANEL_RIGHT:Dock(FILL)

        PANEL_RIGHT.Paint = function() end
        PANEL_RIGHT:SetMouseInputEnabled(true)

        local MD_PANEL = vgui.Create("DPanel", PANEL_RIGHT)
        MD_PANEL:Dock(TOP)
        MD_PANEL:SetTall(h * 0.5)
        MD_PANEL.Paint = function(s, w, h) 
            draw.RoundedBox(0, 0, 0, w, h, Color(28, 28, 28))
        end

        local P = vgui.Create("PIXEL.Label", PANEL_RIGHT)
        P:Dock(TOP)
        P:SetText(RDV.LIBRARY.GetLang(nil, "VR_skinLabel"))
        P:DockMargin(0, h * 0.01, 0, h * 0.01)

        COMBO_S = vgui.Create("DComboBox", PANEL_RIGHT)
        COMBO_S:Dock(TOP)
        COMBO_S:DockMargin(0, 0, 0, h * 0.01)

        COMBO_S.OnSelect = function(S, IND, VAL, DA)
            local E = ICON:GetEntity()

            if IsValid(E) then
                E:SetSkin(DA)
            end
            
            INFO[V_CLASS].SKIN = DA
        end

        local P = vgui.Create("PIXEL.Label", PANEL_RIGHT)
        P:Dock(TOP)
        P:SetText(RDV.LIBRARY.GetLang(nil, "VR_CFG_loadout"))
        P:DockMargin(0, 0, 0, h * 0.01)

        COMBO_T = vgui.Create("DComboBox", PANEL_RIGHT)
        COMBO_T:Dock(TOP)
        COMBO_T:DockMargin(0, 0, 0, h * 0.01)
        COMBO_T.OnSelect = function(S, IND, VAL, DA)
            local CFG = RDV.VEHICLE_REQ.VEHICLES[V_CLASS]

            if !CFG then return end

            local E = ICON:GetEntity()

            if !IsValid(E) then return end

            if CFG.LOADOUTS and CFG.LOADOUTS[DA] and CFG.LOADOUTS[DA].OPTIONS then
                for k, v in ipairs(E:GetBodyGroups()) do
                    if CFG.LOADOUTS[DA].OPTIONS[v.id] then
                        E:SetBodygroup(v.id, CFG.LOADOUTS[DA].OPTIONS[v.id])
                    else
                        E:SetBodygroup(v.id, 0)
                    end
                end

                INFO[V_CLASS].LOADOUT = DA
            end
        end

        ICON = vgui.Create("DModelPanel", MD_PANEL)
        ICON:Dock(FILL)
        ICON:SetSize(w * 0.25, h)
        
    ChangeIcon(ICON, ( FIRST or MODEL ) )
end)


hook.Add( "PostDrawTranslucentRenderables", "RDV", function( bDepth, bSkybox )
    if !RDV.VEHICLE_REQ.CFG.DIS_HANGARS then return end
    
    for k, v in pairs(RDV.VEHICLE_REQ.SPAWNS) do
        if v.MAP and v.MAP ~= game.GetMap() then continue end
        
        local POS = v.POS

        if ( POS:DistToSqr(LocalPlayer():GetPos()) > 1000000 ) then
            continue
        end

        local POS2 = Vector(POS.x, POS.y, POS.z + 1)

        cam.Start3D2D(POS2, Angle(0, CurTime(), 0), 1)
            surface.DrawCircle( 0, 0, RDV.VEHICLE_REQ.CFG.HAN_SIZE, color_white )
        cam.End3D2D()

        cam.Start3D2D(POS2, Angle(0, 0, 0), 0.75)
            draw.SimpleText(v.NAME, "RD_FONTS_CORE_OVERHEAD", 0, 0, color_white, TEXT_ALIGN_CENTER)
        cam.End3D2D()
    end
end)
