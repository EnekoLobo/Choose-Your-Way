

local WAITING = {}

local function RetrieveModel(CLASS, CB)
    net.Start("RDV_VR_RetrieveModel")
        net.WriteString(CLASS)
    net.SendToServer()

    WAITING = CB
end

net.Receive("RDV_VR_RetrieveModel", function()
    local MODEL = net.ReadString()

    WAITING(MODEL)
end )

local function SendNotification(P, MSG)
    local PREFIX = RDV.VEHICLE_REQ.CFG.PRE_STRING
    local COL = RDV.VEHICLE_REQ.CFG.PRE_COLOR

    RDV.LIBRARY.AddText(P, Color(COL.r, COL.g, COL.b), "["..PREFIX.."] ", color_white, MSG)
end

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

local P_TABLE = {}

hook.Add("PlayerButtonDown", "RDV_REQUISITION_ButtonDown", function(P, BTN)
    if P ~= LocalPlayer() or !( BTN == KEY_E ) or !P_TABLE[P:SteamID64()] then return end

    P_TABLE[P:SteamID64()](P:GetPos(), P:GetAngles())
end )

--[[-----------------------------------------]]--
--  Add Spawns
--[[-----------------------------------------]]--

local function AddSpawn(UID, OFRAME, DUPLICATE)
    if IsValid(OFRAME) then
        OFRAME:SetVisible(false)
    end

    local DATA

    if UID and RDV.VEHICLE_REQ.SPAWNS[UID] then
        DATA = table.Copy(RDV.VEHICLE_REQ.SPAWNS[UID])
    else
        DATA = table.Copy(RDV.VEHICLE_REQ.DF_SPAWN)
    end
    
    for k, v in pairs(RDV.VEHICLE_REQ.DF_SPAWN) do
        if ( DATA[k] == nil ) then DATA[k] = v end
    end

    if DUPLICATE then
        DATA.NAME = DATA.NAME.."_COPY"
        DATA.UID = nil
    end

    local FRAME = vgui.Create("PIXEL.Frame")
    FRAME:SetSize(ScrW() * 0.2, ScrH() * 0.6)
    FRAME:Center()
    FRAME:MakePopup(true)
    FRAME:SetTitle(RDV.LIBRARY.GetLang(nil, "VR_addonTitle"))
    FRAME.OnClose = function(s)
        if IsValid(OFRAME) then
            OFRAME:SetVisible(true)
        end
    end

    local w, h = FRAME:GetSize()

    local SCROLL = vgui.Create("PIXEL.ScrollPanel", FRAME)
    SCROLL:Dock(FILL)
    SCROLL:DockMargin(w * 0.05, h * 0.015, w * 0.05, h * 0.015)
    
    local P = vgui.Create("PIXEL.Label", SCROLL)
    P:Dock(TOP)
    P:SetText(RDV.LIBRARY.GetLang(nil, "VR_nameLabel").."*")
    P:DockMargin(0, 0, w * 0.01, h * 0.01)

    local TEXT = SCROLL:Add("DTextEntry")
    TEXT:Dock(TOP)
    TEXT:DockMargin(0, 0, w * 0.01, h * 0.01)
    TEXT:SetPlaceholderText(RDV.LIBRARY.GetLang(nil, "VR_nameLabel"))
    TEXT.OnChange = function(s)
        DATA.NAME = s:GetValue()
    end

    if DATA.NAME then
        TEXT:SetText(DATA.NAME)
    end

    local P = vgui.Create("PIXEL.Label", SCROLL)
    P:Dock(TOP)
    P:DockMargin(0, 0, w * 0.01, h * 0.01)
    P:SetText(RDV.LIBRARY.GetLang(nil, "VR_CFG_PosAng").."*")

    local POS = SCROLL:Add("DButton")
    POS:Dock(TOP)
    POS:SetText("No Position")
    POS:DockMargin(0, 0, w * 0.01, h * 0.01)
    POS.DoClick = function()
        surface.PlaySound("reality_development/ui/ui_accept.ogg")

        SendNotification(LocalPlayer(), RDV.LIBRARY.GetLang(nil, "VR_CFG_confirmPos"))

        P_TABLE[LocalPlayer():SteamID64()] = function(VEC, ANG)
            if !IsValid(POS) then
                P_TABLE[LocalPlayer():SteamID64()] = nil
                return
            end

            DATA.POS = VEC
            DATA.ANG = ANG

            POS:SetText(tostring(VEC).." ("..tostring(ANG)..")")

            FRAME:SetVisible(true)
        end

        FRAME:SetVisible(false)
    end

    if DATA.POS and DATA.ANG then
        POS:SetText(tostring(DATA.POS).." ("..tostring(DATA.ANG)..")")
    end

    local P = vgui.Create("PIXEL.Label", SCROLL)
    P:Dock(TOP)
    P:SetText(RDV.LIBRARY.GetLang(nil, "VR_CFG_requestTeams"))
    P:DockMargin(0, 0, w * 0.01, h * 0.01)

    local R_TEAMS = SCROLL:Add("DListView")
    R_TEAMS:Dock(TOP)
    R_TEAMS:AddColumn( RDV.LIBRARY.GetLang(nil, "VR_nameLabel") )
    R_TEAMS:SetTall(FRAME:GetTall() * 0.2)
    R_TEAMS:DockMargin(0, 0, w * 0.01, h * 0.01)

    for k, v in ipairs(team.GetAllTeams()) do
        local LINE = R_TEAMS:AddLine( v.Name, k )

        LINE.OnRightClick = function(s)
            s:SetSelected(false)
        end

        if DATA.RTEAMS and DATA.RTEAMS[v.Name] then
            LINE:SetSelected(true)
        end

        LINE.UID = v.Name
    end

    -- Request Ranks
    local P = vgui.Create("PIXEL.Label", SCROLL)
    P:Dock(TOP)
    P:SetText(RDV.LIBRARY.GetLang(nil, "VR_CFG_requestRanks"))
    P:DockMargin(0, 0, w * 0.01, h * 0.01)

    local BRANCH
    local RANK
    local R_RANK

    local LABEL = SCROLL:Add("DLabel")
    LABEL:Dock(TOP)
    LABEL:SetTall(LABEL:GetTall() * 1.5)
    LABEL:SetText("")
    LABEL:SetMouseInputEnabled(true)
    LABEL:DockMargin(0, 0, w * 0.01, h * 0.01)

    local ADD = LABEL:Add("DButton", LABEL)
    ADD:SetImage("icon16/add.png")
    ADD:Dock(LEFT)
    ADD:SetText("")
    ADD:SetWide(ADD:GetWide() * 0.4)
    ADD.DoClick = function(s)
        local BR = BRANCH:GetValue()
        local RA = tonumber(RANK:GetValue())

        if ( !BR or BR == "" ) or ( !RA or RA == "" ) then return end

        local LINE = R_RANK:AddLine(BR, RA)
        LINE.BRANCH = BR
        LINE.RANK = RA
    end

    BRANCH = vgui.Create("DTextEntry", LABEL)
    BRANCH:Dock(LEFT)
    BRANCH:SetKeyboardInputEnabled(true)
    BRANCH:SetPlaceholderText(RDV.LIBRARY.GetLang(nil, "VR_CFG_branchLabel"))
    BRANCH:SetWide(BRANCH:GetWide() * 2)

    RANK = vgui.Create("DTextEntry", LABEL)
    RANK:Dock(LEFT)
    RANK:SetKeyboardInputEnabled(true)
    RANK:SetPlaceholderText(RDV.LIBRARY.GetLang(nil, "VR_CFG_rankLabel"))
    RANK:SetWide(RANK:GetWide() * 2)
    RANK:SetNumeric(true)

    local LABEL = vgui.Create("DLabel", SCROLL)
    LABEL:SetText("")
    LABEL:SetHeight(h * 0.3)
    LABEL:Dock(TOP)
    LABEL:SetMouseInputEnabled(true)
    LABEL:DockMargin(0, 0, w * 0.01, h * 0.01)

    R_RANK = vgui.Create("DListView", LABEL)
    R_RANK:Dock(FILL)
    R_RANK:AddColumn( RDV.LIBRARY.GetLang(nil, "VR_CFG_branchLabel"), 1 )
    R_RANK:AddColumn( RDV.LIBRARY.GetLang(nil, "VR_CFG_rankLabel"), 2 )

    R_RANK.OnRowRightClick = function(sm, ID, LINE)
        local BR = LINE.BRANCH

        if DATA.RANKS[BR] then
            DATA.RANKS[BR] = nil
        end

        R_RANK:RemoveLine(ID)
    end

    if DATA.RANKS then
        for k, v in pairs(DATA.RANKS) do
            local LINE = R_RANK:AddLine(k, v)
            LINE.BRANCH = k
            LINE.RANK = v
        end
    end

    -- Grant Teams

    local P = vgui.Create("PIXEL.Label", SCROLL)
    P:Dock(TOP)
    P:SetText(RDV.LIBRARY.GetLang(nil, "VR_CFG_grantTeams"))
    P:DockMargin(0, 0, w * 0.01, h * 0.01)

    local G_TEAMS = SCROLL:Add("DListView")
    G_TEAMS:Dock(TOP)
    G_TEAMS:AddColumn( RDV.LIBRARY.GetLang(nil, "VR_nameLabel") )
    G_TEAMS:DockMargin(0, 0, w * 0.01, h * 0.01)
    G_TEAMS:SetTall(FRAME:GetTall() * 0.2)

    for k, v in ipairs(team.GetAllTeams()) do
        local LINE = G_TEAMS:AddLine( v.Name, k )

        LINE.OnRightClick = function(s)
            s:SetSelected(false)
        end

        if DATA.GTEAMS and DATA.GTEAMS[v.Name] then
            LINE:SetSelected(true)
        end

        LINE.UID = v.Name
    end

    -- Grant Ranks
    local P = vgui.Create("PIXEL.Label", SCROLL)
    P:Dock(TOP)
    P:SetText(RDV.LIBRARY.GetLang(nil, "VR_CFG_grantRanks"))
    P:DockMargin(0, 0, w * 0.01, h * 0.01)

    local BRANCH
    local RANK
    local G_RANK

    local LABEL = SCROLL:Add("DLabel")
    LABEL:Dock(TOP)
    LABEL:SetTall(LABEL:GetTall() * 1.5)
    LABEL:SetText("")
    LABEL:SetMouseInputEnabled(true)
    LABEL:DockMargin(0, 0, w * 0.01, h * 0.01)

    local ADD = LABEL:Add("DButton", LABEL)
    ADD:SetImage("icon16/add.png")
    ADD:Dock(LEFT)
    ADD:SetText("")
    ADD:SetWide(ADD:GetWide() * 0.4)
    ADD.DoClick = function(s)
        local BR = BRANCH:GetValue()
        local RA = tonumber(RANK:GetValue())

        if ( !BR or BR == "" ) or ( !RA or RA == "" ) then return end

        local LINE = G_RANK:AddLine(BR, RA)
        LINE.BRANCH = BR
        LINE.RANK = RA
    end

    BRANCH = vgui.Create("DTextEntry", LABEL)
    BRANCH:Dock(LEFT)
    BRANCH:SetKeyboardInputEnabled(true)
    BRANCH:SetPlaceholderText(RDV.LIBRARY.GetLang(nil, "VR_CFG_branchLabel"))
    BRANCH:SetWide(BRANCH:GetWide() * 2)

    RANK = vgui.Create("DTextEntry", LABEL)
    RANK:Dock(LEFT)
    RANK:SetKeyboardInputEnabled(true)
    RANK:SetPlaceholderText(RDV.LIBRARY.GetLang(nil, "VR_CFG_rankLabel"))
    RANK:SetWide(RANK:GetWide() * 2)
    RANK:SetNumeric(true)

    local LABEL = vgui.Create("DLabel", SCROLL)
    LABEL:SetText("")
    LABEL:SetHeight(h * 0.3)
    LABEL:Dock(TOP)
    LABEL:SetMouseInputEnabled(true)
    LABEL:DockMargin(0, 0, w * 0.01, h * 0.01)

    G_RANK = vgui.Create("DListView", LABEL)
    G_RANK:Dock(FILL)
    G_RANK:AddColumn( RDV.LIBRARY.GetLang(nil, "VR_CFG_branchLabel"), 1 )
    G_RANK:AddColumn( RDV.LIBRARY.GetLang(nil, "VR_CFG_rankLabel"), 2 )

    G_RANK.OnRowRightClick = function(sm, ID, LINE)
        local BR = LINE.BRANCH

        if DATA.GRANKS[BR] then
            DATA.GRANKS[BR] = nil
        end

        G_RANK:RemoveLine(ID)
    end

    if DATA.GRANKS then
        for k, v in pairs(DATA.GRANKS) do
            local LINE = G_RANK:AddLine(k, v)
            LINE.BRANCH = k
            LINE.RANK = v
        end
    end

    -- Confirm

    local CONFIRM = FRAME:Add("PIXEL.TextButton")
    CONFIRM:Dock(BOTTOM)
    CONFIRM:SetText(RDV.LIBRARY.GetLang(nil, "VR_saveLabel"))
    CONFIRM:DockMargin(w * 0.05, h * 0.015, w * 0.05, h * 0.015)
    CONFIRM.DoClick = function()
        if !DATA.NAME or DATA.NAME == "" then return end
        if !DATA.POS or DATA.POS:IsZero() then return end
        if !DATA.ANG or DATA.ANG:IsZero() then return end

        DATA.RTEAMS = {}
        DATA.GTEAMS = {}
        DATA.GRANKS = {}
        DATA.RANKS = {}

        for k, v in ipairs(R_TEAMS:GetSelected()) do
            DATA.RTEAMS[v.UID] = true
        end

        for k, v in ipairs(G_TEAMS:GetSelected()) do
            DATA.GTEAMS[v.UID] = true
        end

        for k, v in ipairs(G_RANK:GetLines()) do
            DATA.GRANKS[v.BRANCH] = v.RANK
        end

        for k, v in ipairs(R_RANK:GetLines()) do
            DATA.RANKS[v.BRANCH] = v.RANK
        end

        local COMPRESS = util.Compress(util.TableToJSON(DATA))
        local BYTES = #COMPRESS

        net.Start("RDV_REQUISITION_AddSpawn")
            net.WriteUInt(BYTES, 32)
            net.WriteData(COMPRESS, BYTES)
        net.SendToServer()

        surface.PlaySound("reality_development/ui/ui_accept.ogg")
        SendNotification(LocalPlayer(), RDV.LIBRARY.GetLang(nil, "VR_CFG_savedSuccess"))

        if IsValid(OFRAME) then
            OFRAME:SetVisible(true)
        end

        FRAME:Remove()
    end
end

--[[-----------------------------------------]]--
--  Add Vehicle
--[[-----------------------------------------]]--

local function AddVehicle(UID, OFRAME, DUPLICATE)
    if IsValid(OFRAME) then
        OFRAME:SetVisible(false)
    end

    local DATA

    if UID and RDV.VEHICLE_REQ.VEHICLES[UID] then
        DATA = table.Copy(RDV.VEHICLE_REQ.VEHICLES[UID])
    else
        DATA = table.Copy(RDV.VEHICLE_REQ.DF_VEHICLE)
    end

    for k, v in pairs(RDV.VEHICLE_REQ.DF_VEHICLE) do
        if ( DATA[k] == nil ) then DATA[k] = v end
    end

    if DUPLICATE then
        DATA.NAME = DATA.NAME.."_COPY"
        DATA.UID = nil
    end

    local FRAME = vgui.Create("PIXEL.Frame")
    FRAME:SetSize(ScrW() * 0.3, ScrH() * 0.6)
    FRAME:Center()
    FRAME:MakePopup(true)
    FRAME:SetTitle(RDV.LIBRARY.GetLang(nil, "VR_addonTitle"))
    FRAME.OnClose = function(s)
        if IsValid(OFRAME) then
            OFRAME:SetVisible(true)
        end
    end

    local w, h = FRAME:GetSize()

    local TFRAME = vgui.Create("DLabel", FRAME)
    TFRAME:SetText("")
    TFRAME:Dock(TOP)
    TFRAME:SetTall(h * 0.3)
    TFRAME:DockMargin(0, w * 0.01, w * 0.01, w * 0.01)

    TFRAME.Paint = function() end
    TFRAME:SetMouseInputEnabled(true)
    TFRAME.Paint = function(s, w, h) 
        draw.RoundedBox(0, 0, 0, w, h, PIXEL.CopyColor(PIXEL.Colors.Header))
    end 

    local MODEL = vgui.Create("DModelPanel", TFRAME)
    MODEL:Dock(LEFT)
    MODEL:SetWide(w * 0.5)
    if DATA.MODEL then
        ChangeIcon(MODEL, DATA.MODEL)
    end

    local INFOTAB = vgui.Create("DLabel", TFRAME)
    INFOTAB:Dock(FILL)
    INFOTAB:SetText("")
    INFOTAB:SetMouseInputEnabled(true)
    INFOTAB:DockMargin(w * 0.05, h * 0.015, w * 0.05, h * 0.015)

    local P = vgui.Create("PIXEL.Label", INFOTAB)
    P:Dock(TOP)
    P:SetText(RDV.LIBRARY.GetLang(nil, "VR_CFG_defaultSkin"))
    P:DockMargin(0, 0, 0, h * 0.01)

    local DFSKIN = vgui.Create("DComboBox", INFOTAB)
    DFSKIN:Dock(TOP)
    DFSKIN:DockMargin(0, 0, 0, h * 0.01)

    DFSKIN.OnSelect = function( s, index, text, data )
        if !data then return end

        DATA.SKIN = data 

        MODEL:GetEntity():SetSkin(data)
    end

    local P = vgui.Create("PIXEL.Label", INFOTAB)
    P:Dock(TOP)
    P:SetText(RDV.LIBRARY.GetLang(nil, "VR_CFG_defaultLoadout"))
    P:DockMargin(0, 0, 0, h * 0.01)

    local DFLOADOUT = vgui.Create("DComboBox", INFOTAB)
    DFLOADOUT:Dock(TOP)

    local C = DFLOADOUT:AddChoice(RDV.LIBRARY.GetLang(nil, "VR_CFG_default"), false)
    DFLOADOUT:ChooseOptionID(C)

    DFLOADOUT.OnSelect = function( _, index, text, OTHER )
        if !OTHER then return end

        DATA.L_DEFAULT = OTHER 

        local E = MODEL:GetEntity()

        if !IsValid(E) then return end

        if !DATA.LOADOUTS[OTHER] then
            for k, v in ipairs(E:GetBodyGroups()) do
                E:SetBodygroup(k, 0)
            end

            return
        end

        for k, v in ipairs(E:GetBodyGroups()) do
            local CHOSEN = DATA.LOADOUTS[OTHER].OPTIONS[k]

            if CHOSEN then
                E:SetBodygroup(k, CHOSEN)
            else
                E:SetBodygroup(k, 0)
            end
        end
    end

    local function ResetSkinChoices()
        DFSKIN:Clear()
        DFLOADOUT:Clear()

        local C = DFSKIN:AddChoice(RDV.LIBRARY.GetLang(nil, "VR_CFG_default"), false)
        DFSKIN:ChooseOptionID(C)

        if !DATA.MODEL then return end

        for i = 1, NumModelSkins(DATA.MODEL) do
            local CHOICE = DFSKIN:AddChoice(RDV.LIBRARY.GetLang(nil, "VR_skinLabel").." "..i, i)

            if DATA.SKIN == i then
                DFSKIN:ChooseOptionID(CHOICE)
            end
        end

        for k, v in pairs(DATA.LOADOUTS) do
            local I = DFLOADOUT:AddChoice(v.NAME, k)

            if k == DATA.L_DEFAULT then
                DFLOADOUT:ChooseOptionID(I)
            end
        end
        
    end
    ResetSkinChoices()

    local BFRAME = vgui.Create("DLabel", FRAME)
    BFRAME:SetText("")
    BFRAME:Dock(FILL)
    BFRAME:SetMouseInputEnabled(true)
    BFRAME.Paint = function() end

    local SIDEBAR = vgui.Create("PIXEL.Sidebar", BFRAME)
    SIDEBAR:Dock(LEFT)
    SIDEBAR:SetWide(w * 0.3)
    SIDEBAR.BackgroundCol = PIXEL.CopyColor(PIXEL.Colors.Header)

    local PANEL = vgui.Create("DPanel", BFRAME)
    PANEL:Dock(FILL)
    PANEL:DockMargin(w * 0.01, 0, w * 0.01, 0)
    PANEL:SetMouseInputEnabled(true)
    PANEL:SetKeyboardInputEnabled(true)
    PANEL.Paint = function(s, w, h) 
        draw.RoundedBox(0, 0, 0, w, h, PIXEL.CopyColor(PIXEL.Colors.Header))
    end

    SIDEBAR:AddItem("main", "Main", "MQfnROH", function()
        PANEL:Clear()

        local SCROLL = vgui.Create("PIXEL.ScrollPanel", PANEL)
        SCROLL:Dock(FILL)
        SCROLL:DockMargin(w * 0.01, h * 0.01, w * 0.01, h * 0.01)

        --[[-----------------------------------------]]
        --  Name                                        
        --]]-----------------------------------------]]

        local P = vgui.Create("PIXEL.Label", SCROLL)
        P:Dock(TOP)
        P:SetText(RDV.LIBRARY.GetLang(nil, "VR_nameLabel").."*")
        P:DockMargin(0, 0, w * 0.01, h * 0.01)

        local TEXT = SCROLL:Add("DTextEntry")
        TEXT:Dock(TOP)
        TEXT:SetPlaceholderText(RDV.LIBRARY.GetLang(nil, "VR_nameLabel"))
        TEXT:DockMargin(0, 0, w * 0.01, h * 0.01)
        TEXT.OnChange = function(s)
            DATA.NAME = s:GetValue()
        end

        if DATA.NAME then
            TEXT:SetText(DATA.NAME)
        end

        --[[-----------------------------------------]]
        --  Category                                        
        --]]-----------------------------------------]]

        local P = vgui.Create("PIXEL.Label", SCROLL)
        P:Dock(TOP)
        P:SetText(RDV.LIBRARY.GetLang(nil, "VR_CFG_categoryLabel").."*")
        P:DockMargin(0, 0, w * 0.01, h * 0.01)

        local CATEGORY = SCROLL:Add("DTextEntry")
        CATEGORY:Dock(TOP)
        CATEGORY:SetPlaceholderText(RDV.LIBRARY.GetLang(nil, "VR_CFG_categoryLabel"))
        CATEGORY:DockMargin(0, 0, w * 0.01, h * 0.01)
        CATEGORY.OnChange = function(s)
            DATA.CATEGORY = s:GetValue()
        end

        if DATA.CATEGORY then
            CATEGORY:SetText(DATA.CATEGORY)
        end

        --[[-----------------------------------------]]
        --  Class                                        
        --]]-----------------------------------------]]

        local P = vgui.Create("PIXEL.Label", SCROLL)
        P:Dock(TOP)
        P:SetText(RDV.LIBRARY.GetLang(nil, "VR_CFG_classLabel").."*")
        P:DockMargin(0, 0, w * 0.01, h * 0.01)

        local CLASS = SCROLL:Add("DTextEntry")
        CLASS:Dock(TOP)
        CLASS:SetPlaceholderText(RDV.LIBRARY.GetLang(nil, "VR_CFG_classLabel"))
        CLASS:DockMargin(0, 0, w * 0.01, h * 0.01)
        CLASS.OnChange = function(s)
            RetrieveModel(s:GetValue(), function(SMODEL)
                DATA.MODEL = SMODEL

                DATA.S_CONFIG = {}
                DATA.LOADOUTS = {}

                ResetSkinChoices()
                    
                ChangeIcon(MODEL, SMODEL)
            end )

            DATA.CLASS = s:GetValue()
        end

        if DATA.CLASS then
            CLASS:SetText(DATA.CLASS)
        end

        --[[-----------------------------------------]]
        --  Class                                        
        --]]-----------------------------------------]]

        local P = vgui.Create("PIXEL.Label", SCROLL)
        P:Dock(TOP)
        P:SetText(RDV.LIBRARY.GetLang(nil, "VR_CFG_priceLabel"))
        P:DockMargin(0, 0, w * 0.01, h * 0.01)

        local PRICE = SCROLL:Add("DTextEntry")
        PRICE:Dock(TOP)
        PRICE:SetPlaceholderText(RDV.LIBRARY.GetLang(nil, "VR_CFG_priceLabel"))
        PRICE:SetNumeric(true)
        PRICE:DockMargin(0, 0, w * 0.01, h * 0.01)
        PRICE.OnChange = function(s)
            DATA.PRICE = s:GetValue()
        end

        if DATA.PRICE then
            PRICE:SetText(DATA.PRICE)
        end

        --[[-----------------------------------------]]
        --  Max                                        
        --]]-----------------------------------------]]

        local P = vgui.Create("PIXEL.Label", SCROLL)
        P:Dock(TOP)
        P:SetText(RDV.LIBRARY.GetLang(nil, "VR_CFG_maxAmount"))
        P:DockMargin(0, 0, w * 0.01, h * 0.01)

        local MAX = SCROLL:Add("DTextEntry")
        MAX:Dock(TOP)
        MAX:SetPlaceholderText(RDV.LIBRARY.GetLang(nil, "VR_CFG_maxAmount"))
        MAX:SetNumeric(true)
        MAX:DockMargin(0, 0, w * 0.01, h * 0.01)
        MAX.OnChange = function(s)
            DATA.MAX = tonumber(s:GetValue())
        end

        if DATA.MAX then
            MAX:SetText(DATA.MAX)
        end

        --[[-----------------------------------------]]
        --  Enable Requests                                        
        --]]-----------------------------------------]]

        local P = vgui.Create("PIXEL.Label", SCROLL)
        P:Dock(TOP)
        P:SetText(RDV.LIBRARY.GetLang(nil, "VR_CFG_enableRequests"))
        P:DockMargin(0, 0, w * 0.01, h * 0.01)

        local LABEL = vgui.Create("DLabel", SCROLL)
        LABEL:SetText("")
        LABEL:SetHeight(h * 0.05)
        LABEL:Dock(TOP)
        LABEL:SetMouseInputEnabled(true)
        LABEL:DockMargin(0, 0, w * 0.01, h * 0.01)

        local CHECK_L = vgui.Create("DLabel", LABEL)
        CHECK_L:SetMouseInputEnabled(true)
        CHECK_L:Dock(RIGHT)
        CHECK_L:SetText("")

        local CHECK = vgui.Create("PIXEL.Checkbox", CHECK_L)
        CHECK:SetPos( (CHECK_L:GetWide() * 0.4 ) - ( CHECK:GetWide() / 2 ) , ( CHECK_L:GetTall() * 0.5 ) + ( CHECK:GetTall() / 2 ) )
        CHECK.OnToggled = function(s, val)
            DATA.REQUEST = val
        end

        if DATA.REQUEST then
            CHECK:SetToggle(true)
        end
        

        --[[-----------------------------------------]]
        --  Request Teams
        --]]-----------------------------------------]]

        local P = vgui.Create("PIXEL.Label", SCROLL)
        P:Dock(TOP)
        P:SetText(RDV.LIBRARY.GetLang(nil, "VR_CFG_requestTeams"))
        P:DockMargin(0, 0, w * 0.01, h * 0.01)

        local R_TEAMS = SCROLL:Add("DListView")
        R_TEAMS:Dock(TOP)
        R_TEAMS:AddColumn( RDV.LIBRARY.GetLang(nil, "VR_nameLabel") )
        R_TEAMS:SetTall(FRAME:GetTall() * 0.2)
        R_TEAMS:DockMargin(0, 0, w * 0.01, h * 0.01)

        R_TEAMS.OnRowSelected = function(_, _, row)
            DATA.RTEAMS[row.UID] = true
        end

        for k, v in ipairs(team.GetAllTeams()) do
            local LINE = R_TEAMS:AddLine( v.Name, k )

            LINE.OnRightClick = function(s)
                s:SetSelected(false)

                DATA.RTEAMS[v.Name] = nil
            end

            if DATA.RTEAMS and DATA.RTEAMS[v.Name] then
                LINE:SetSelected(true)
            end

            LINE.UID = v.Name
        end

        --[[-----------------------------------------]]
        --  Request Ranks
        --]]-----------------------------------------]]

        local P = vgui.Create("PIXEL.Label", SCROLL)
        P:Dock(TOP)
        P:SetText(RDV.LIBRARY.GetLang(nil, "VR_CFG_requestRanks"))
        P:DockMargin(0, 0, w * 0.01, h * 0.01)

        local BRANCH
        local RANK
        local R_RANK

        local LABEL = SCROLL:Add("DLabel")
        LABEL:Dock(TOP)
        LABEL:SetTall(LABEL:GetTall() * 1.5)
        LABEL:SetText("")
        LABEL:SetMouseInputEnabled(true)
        LABEL:DockMargin(0, 0, w * 0.01, h * 0.01)

        local ADD = LABEL:Add("DButton", LABEL)
        ADD:SetImage("icon16/add.png")
        ADD:Dock(LEFT)
        ADD:SetText("")
        ADD:SetWide(ADD:GetWide() * 0.4)
        ADD.DoClick = function(s)
            local BR = BRANCH:GetValue()
            local RA = tonumber(RANK:GetValue())

            if ( !BR or BR == "" ) or ( !RA or RA == "" ) then return end

            local LINE = R_RANK:AddLine(BR, RA)
            LINE.BRANCH = BR
            LINE.RANK = RA

            DATA.RANKS[BR] = RA
        end

        BRANCH = vgui.Create("DTextEntry", LABEL)
        BRANCH:Dock(LEFT)
        BRANCH:SetKeyboardInputEnabled(true)
        BRANCH:SetPlaceholderText(RDV.LIBRARY.GetLang(nil, "VR_CFG_branchLabel"))
        BRANCH:SetWide(BRANCH:GetWide() * 2)

        RANK = vgui.Create("DTextEntry", LABEL)
        RANK:Dock(LEFT)
        RANK:SetKeyboardInputEnabled(true)
        RANK:SetPlaceholderText(RDV.LIBRARY.GetLang(nil, "VR_CFG_rankLabel"))
        RANK:SetWide(RANK:GetWide() * 2)
        RANK:SetNumeric(true)

        local LABEL = vgui.Create("DLabel", SCROLL)
        LABEL:SetText("")
        LABEL:SetHeight(h * 0.3)
        LABEL:Dock(TOP)
        LABEL:SetMouseInputEnabled(true)
        LABEL:DockMargin(0, 0, w * 0.01, h * 0.01)

        R_RANK = vgui.Create("DListView", LABEL)
        R_RANK:Dock(FILL)
        R_RANK:AddColumn( RDV.LIBRARY.GetLang(nil, "VR_CFG_branchLabel"), 1 )
        R_RANK:AddColumn( RDV.LIBRARY.GetLang(nil, "VR_CFG_rankLabel"), 2 )

        R_RANK.OnRowRightClick = function(sm, ID, LINE)
            local BR = LINE.BRANCH

            if DATA.RANKS[BR] then
                DATA.RANKS[BR] = nil
            end

            R_RANK:RemoveLine(ID)
        end

        if DATA.RANKS then
            for k, v in pairs(DATA.RANKS) do
                local LINE = R_RANK:AddLine(k, v)
                LINE.BRANCH = k
                LINE.RANK = v
            end
        end

        --[[-----------------------------------------]]
        --  Grant Teams
        --]]-----------------------------------------]]

        local P = vgui.Create("PIXEL.Label", SCROLL)
        P:Dock(TOP)
        P:SetText(RDV.LIBRARY.GetLang(nil, "VR_CFG_grantTeams"))
        P:DockMargin(0, 0, w * 0.01, h * 0.01)

        local G_TEAMS = SCROLL:Add("DListView")
        G_TEAMS:Dock(TOP)
        G_TEAMS:AddColumn( RDV.LIBRARY.GetLang(nil, "VR_nameLabel") )
        G_TEAMS:SetTall(FRAME:GetTall() * 0.2)
        G_TEAMS:DockMargin(0, 0, w * 0.01, h * 0.01)

        G_TEAMS.OnRowSelected = function(_, _, row)
            DATA.GTEAMS[row.UID] = true
        end

        for k, v in ipairs(team.GetAllTeams()) do
            local LINE = G_TEAMS:AddLine( v.Name, k )

            LINE.OnRightClick = function(s)
                s:SetSelected(false)

                DATA.GTEAMS[row.UID] = nil
            end

            if DATA.GTEAMS and DATA.GTEAMS[v.Name] then
                LINE:SetSelected(true)
            end

            LINE.UID = v.Name
        end

        --[[-----------------------------------------]]
        --  Grant Ranks
        --]]-----------------------------------------]]

        local P = vgui.Create("PIXEL.Label", SCROLL)
        P:Dock(TOP)
        P:SetText(RDV.LIBRARY.GetLang(nil, "VR_CFG_grantRanks"))
        P:DockMargin(0, 0, w * 0.01, h * 0.01)

        local BRANCH
        local RANK
        local G_RANK

        local LABEL = SCROLL:Add("DLabel")
        LABEL:Dock(TOP)
        LABEL:SetTall(LABEL:GetTall() * 1.5)
        LABEL:SetText("")
        LABEL:SetMouseInputEnabled(true)
        LABEL:DockMargin(0, 0, w * 0.01, h * 0.01)

        local ADD = LABEL:Add("DButton", LABEL)
        ADD:SetImage("icon16/add.png")
        ADD:Dock(LEFT)
        ADD:SetText("")
        ADD:SetWide(ADD:GetWide() * 0.4)
        ADD.DoClick = function(s)
            local BR = BRANCH:GetValue()
            local RA = tonumber(RANK:GetValue())

            if ( !BR or BR == "" ) or ( !RA or RA == "" ) then return end

            local LINE = G_RANK:AddLine(BR, RA)
            LINE.BRANCH = BR
            LINE.RANK = RA

            DATA.GRANKS[BR] = RA
        end

        BRANCH = vgui.Create("DTextEntry", LABEL)
        BRANCH:Dock(LEFT)
        BRANCH:SetKeyboardInputEnabled(true)
        BRANCH:SetPlaceholderText(RDV.LIBRARY.GetLang(nil, "VR_CFG_branchLabel"))
        BRANCH:SetWide(BRANCH:GetWide() * 2)

        RANK = vgui.Create("DTextEntry", LABEL)
        RANK:Dock(LEFT)
        RANK:SetKeyboardInputEnabled(true)
        RANK:SetPlaceholderText(RDV.LIBRARY.GetLang(nil, "VR_CFG_rankLabel"))
        RANK:SetWide(RANK:GetWide() * 2)
        RANK:SetNumeric(true)

        local LABEL = vgui.Create("DLabel", SCROLL)
        LABEL:SetText("")
        LABEL:SetHeight(h * 0.3)
        LABEL:Dock(TOP)
        LABEL:SetMouseInputEnabled(true)
        LABEL:DockMargin(0, 0, w * 0.01, h * 0.01)

        G_RANK = vgui.Create("DListView", LABEL)
        G_RANK:Dock(FILL)
        G_RANK:AddColumn( RDV.LIBRARY.GetLang(nil, "VR_CFG_branchLabel"), 1 )
        G_RANK:AddColumn( RDV.LIBRARY.GetLang(nil, "VR_CFG_rankLabel"), 2 )

        G_RANK.OnRowRightClick = function(sm, ID, LINE)
            local BR = LINE.BRANCH

            if DATA.GRANKS[BR] then
                DATA.GRANKS[BR] = nil
            end

            G_RANK:RemoveLine(ID)
        end

        if DATA.GRANKS then
            for k, v in pairs(DATA.GRANKS) do
                local LINE = G_RANK:AddLine(k, v)
                LINE.BRANCH = k
                LINE.RANK = v
            end
        end

        --[[-----------------------------------------]]
        --  Whitelist Hangars
        --]]-----------------------------------------]]

        local P = vgui.Create("PIXEL.Label", SCROLL)
        P:Dock(TOP)
        P:SetText(RDV.LIBRARY.GetLang(nil, "VR_CFG_whitelistedHangars"))
        P:DockMargin(0, 0, w * 0.01, h * 0.01)

        local HANGARS = SCROLL:Add("DListView")
        HANGARS:Dock(TOP)
        HANGARS:AddColumn( RDV.LIBRARY.GetLang(nil, "VR_nameLabel") )
        HANGARS:AddColumn( RDV.LIBRARY.GetLang(nil, "VR_CFG_UIDLabel") )
        HANGARS:SetTall(FRAME:GetTall() * 0.2)
        HANGARS:DockMargin(0, 0, w * 0.01, h * 0.01)
        HANGARS.OnRowSelected = function(s, ri, row)
            DATA.SPAWNS[row.spawnUID] = true
        end
        HANGARS.OnRowRightClick = function(sm, ID, row)
            if !DATA.SPAWNS[row.spawnUID] then return end

            LINE:SetSelected(false)
            DATA.SPAWNS[row.spawnUID] = nil
        end

        for k, v in pairs(RDV.VEHICLE_REQ.SPAWNS) do
            local LINE = HANGARS:AddLine( v.NAME, k )
            LINE.spawnUID = k

            if DATA.SPAWNS and DATA.SPAWNS[k] then
                LINE:SetSelected(true)
            end
        end
    end)

    SIDEBAR:AddItem("skins", RDV.LIBRARY.GetLang(nil, "VR_CFG_skins"), "21Xc7qO", function()
        if !DATA.MODEL or DATA.MODEL == "" then return end
        
        PANEL:Clear()

        local SCROLL = vgui.Create("PIXEL.ScrollPanel", PANEL)
        SCROLL:Dock(LEFT)
        SCROLL:DockMargin(w * 0.01, h * 0.01, w * 0.01, h * 0.01)
        SCROLL:SetWide(PANEL:GetWide() * 0.4)
        SCROLL:SetMouseInputEnabled(true)

        local COLLECT = vgui.Create("DPanel", PANEL)
        COLLECT:Dock(FILL)
        COLLECT:SetMouseInputEnabled(true)
        COLLECT.Paint = function() end
        COLLECT:DockMargin(w * 0.05, h * 0.015, w * 0.05, h * 0.015)

        for i = 1, NumModelSkins(DATA.MODEL) do
            local SKIN = vgui.Create("PIXEL.TextButton", SCROLL)
            SKIN:Dock(TOP)

            if DATA.S_CONFIG and DATA.S_CONFIG[i] and DATA.S_CONFIG[i].NAME then
                SKIN:SetText(DATA.S_CONFIG[i].NAME.." ("..i..")")
            else
                SKIN:SetText(RDV.LIBRARY.GetLang(nil, "VR_skinLabel").." "..i)
            end

            SKIN:DockMargin(w * 0.01, h * 0.01, w * 0.01, h * 0.01)

            SKIN.DoClick = function()
                if IsValid(COLLECT) then COLLECT:Clear() end

                local P = vgui.Create("PIXEL.Label", COLLECT)
                P:Dock(TOP)
                P:SetText(RDV.LIBRARY.GetLang(nil, "VR_CFG_skinEnabled"))
                P:DockMargin(0, 0, w * 0.01, h * 0.01)

                local LABEL = vgui.Create("DLabel", COLLECT)
                LABEL:SetText("")
                LABEL:SetHeight(h * 0.075)
                LABEL:Dock(TOP)
                LABEL:SetMouseInputEnabled(true)
        
                local CHECK_L = vgui.Create("DLabel", LABEL)
                CHECK_L:SetMouseInputEnabled(true)
                CHECK_L:Dock(RIGHT)
                CHECK_L:SetText("")
        
                local CHECK = vgui.Create("PIXEL.Checkbox", CHECK_L)
                CHECK:SetPos( (CHECK_L:GetWide() * 0.4 ) - ( CHECK:GetWide() / 2 ) , ( CHECK_L:GetTall() * 0.5 ) + ( CHECK:GetTall() / 2 ) )
                CHECK.OnToggled = function(s, val)
                    DATA.S_CONFIG[i] = DATA.S_CONFIG[i] or {}
                    DATA.S_CONFIG[i].ENABLED = val
                end
        
                if DATA.S_CONFIG[i] and DATA.S_CONFIG[i].ENABLED then
                    CHECK:SetToggle(true)
                end
                
                -- Name
                local P = vgui.Create("PIXEL.Label", COLLECT)
                P:Dock(TOP)
                P:SetText(RDV.LIBRARY.GetLang(nil, "VR_nameLabel"))
                P:DockMargin(0, 0, w * 0.01, h * 0.01)

                local NAME = vgui.Create("DTextEntry", COLLECT)
                NAME:Dock(TOP)
                NAME:SetMouseInputEnabled(true)
                NAME:SetKeyboardInputEnabled(true)

                if DATA.S_CONFIG and DATA.S_CONFIG[i] and DATA.S_CONFIG[i].NAME then
                    NAME:SetValue(DATA.S_CONFIG[i].NAME)
                end

                NAME.OnChange = function(s)
                    local VAL = s:GetValue()

                    if !VAL or VAL == "" then
                        VAL = false
                        SKIN:SetText(RDV.LIBRARY.GetLang(nil, "VR_skinLabel").." "..i)
                    else
                        SKIN:SetText(VAL.." ("..i..")")
                    end

                    DATA.S_CONFIG[i] = DATA.S_CONFIG[i] or {}
                    DATA.S_CONFIG[i].NAME = VAL
                end

                -- Skin Preview :)
                if !IsValid(MODEL:GetEntity()) then return end

                local E = MODEL:GetEntity()

                E:SetSkin(i)

                timer.Create("RDV_VR_ResetSkin", 5, 1, function()
                    if !IsValid(MODEL) or !IsValid(MODEL:GetEntity()) then return end

                    local E = MODEL:GetEntity()

                    E:SetSkin( (DATA.SKIN or 1) )
                end )
            end
        end
    end )

    SIDEBAR:AddItem("loadouts", RDV.LIBRARY.GetLang(nil, "VR_CFG_loadouts"), "83ttlX9", function()
        if !DATA.MODEL or DATA.MODEL == "" then return end

        local L_createLoadout = RDV.LIBRARY.GetLang(nil, "VR_CFG_createLoadout")

        DATA.LOADOUTS = DATA.LOADOUTS or {}

        PANEL:Clear()

        local LFT_PANEL = vgui.Create("DPanel", PANEL)
        LFT_PANEL:Dock(LEFT)
        LFT_PANEL:DockMargin(w * 0.01, h * 0.01, w * 0.01, h * 0.01)
        LFT_PANEL:SetWide(PANEL:GetWide() * 0.4)
        LFT_PANEL:SetMouseInputEnabled(true)
        LFT_PANEL.Paint = function(s, w, h) end
        
        local RHT_PANEL = vgui.Create("DPanel", PANEL)
        RHT_PANEL:Dock(FILL)
        RHT_PANEL.Paint = function() end
        RHT_PANEL:DockMargin(w * 0.01, h * 0.01, w * 0.01, h * 0.01)

        local LFT_SCROLL = vgui.Create("DScrollPanel", LFT_PANEL)
        LFT_SCROLL:Dock(FILL)
        LFT_SCROLL:SetMouseInputEnabled(true)

        --[[---------------------------------]]--
        --	Loadout Configuration (Selected)
        --[[---------------------------------]]--

        local COMBO = vgui.Create("DComboBox", LFT_PANEL)
        COMBO:SetValue(RDV.LIBRARY.GetLang(nil, "VR_CFG_selectLoadout"))
        COMBO:Dock(TOP)
        COMBO.OnSelect = function(s, I, T, OTHER)
            local P_ID = OTHER

            LFT_SCROLL:Clear()
            RHT_PANEL:Clear()

            if T == L_createLoadout then
                local P_ID = table.maxn(DATA.LOADOUTS) + 1
                local NAME = "New Loadout #"..P_ID

                local IND = COMBO:AddChoice(NAME, P_ID)
                COMBO:ChooseOptionID(IND)

                DATA.LOADOUTS[P_ID] = DATA.LOADOUTS[P_ID] or {
                    NAME = NAME,
                    OPTIONS = {},
                }

                ResetSkinChoices()

                return
            end

            DATA.LOADOUTS[P_ID] = DATA.LOADOUTS[P_ID] or {
                NAME = "New Loadout #"..P_ID,
                OPTIONS = {},
            }
            
            local P = vgui.Create("PIXEL.Label", RHT_PANEL)
            P:Dock(TOP)
            P:SetText(RDV.LIBRARY.GetLang(nil, "VR_nameLabel"))
            P:DockMargin(0, 0, w * 0.01, h * 0.01)

            local NAME = vgui.Create("DTextEntry", RHT_PANEL)
            NAME:SetPlaceholderText(RDV.LIBRARY.GetLang(nil, "VR_nameLabel"))
            NAME:Dock(TOP)

            if DATA.LOADOUTS[P_ID].NAME then
                NAME:SetText(DATA.LOADOUTS[P_ID].NAME)
            end

            NAME.OnChange = function(s)
                local TEXT = s:GetValue()

                if TEXT == "" then
                    TEXT = "New Loadout #"..P_ID
                end

                DATA.LOADOUTS[P_ID].NAME = TEXT

                COMBO:SetText(TEXT)

                COMBO.Choices[I] = TEXT

                ResetSkinChoices()
            end

            local E = MODEL:GetEntity()

            if !IsValid(E) then return end

            for k, v in ipairs(E:GetBodyGroups()) do
                local L = vgui.Create("DNumSlider", LFT_SCROLL)
                L:Dock(TOP)
                L:SetDecimals(0)
                L:SetValue(0)
                L:SetMouseInputEnabled(true)
                L:SetMax(v.num)
                L:SetText(v.name)
                L.OnValueChanged = function(s)
                    E:SetBodygroup(k, s:GetValue())

                    DATA.LOADOUTS[P_ID].OPTIONS[k] = s:GetValue()
                end

                if DATA.LOADOUTS[P_ID] and DATA.LOADOUTS[P_ID].OPTIONS[k] then
                    L:SetValue(DATA.LOADOUTS[P_ID].OPTIONS[k])
                end
            end

            if DATA.LOADOUTS[OTHER] and DATA.LOADOUTS[OTHER].OPTIONS then
                local E = MODEL:GetEntity()

                if !IsValid(E) then return end
                
                for k, v in ipairs(E:GetBodyGroups()) do
                    local CHOSEN = DATA.LOADOUTS[OTHER].OPTIONS[k]

                    if CHOSEN then
                        E:SetBodygroup(k, CHOSEN)
                    else
                        E:SetBodygroup(k, 0)
                    end
                end
            end
        end

        local function ResetCombo()
            COMBO:Clear()
            COMBO:AddChoice(L_createLoadout)

            local FIRST

            for k, v in pairs(DATA.LOADOUTS) do
                local I = COMBO:AddChoice( (v.NAME or ("New Preset #"..k) ), k )

                if !FIRST then FIRST = I end
            end

            if FIRST and !COMBO:GetSelected() then
                COMBO:ChooseOptionID(FIRST)
            end
        end

        --[[---------------------------------]]--
        --	Delete the selected Loadout.
        --[[---------------------------------]]--

        local DEL_BUTTON = vgui.Create("PIXEL.TextButton", LFT_PANEL)
        DEL_BUTTON:Dock(BOTTOM)
        DEL_BUTTON:SetText(RDV.LIBRARY.GetLang(nil, "VR_deleteLabel"))
        DEL_BUTTON.DoClick = function(s)
            local C_TEXT, C_DATA = COMBO:GetSelected()

            if C_DATA == DATA.L_DEFAULT then
                DATA.L_DEFAULT = false
            end

            DATA.LOADOUTS[C_DATA] = nil

            LFT_SCROLL:Clear()
            RHT_PANEL:Clear()

            ResetCombo()
            ResetSkinChoices()

            local E = MODEL:GetEntity()

            if !IsValid(E) then return end
            
            for k, v in ipairs(E:GetBodyGroups()) do
                E:SetBodygroup(k, 0)
            end
        end

        ResetCombo()
    end )

    local CONFIRM = FRAME:Add("PIXEL.TextButton")
    CONFIRM:Dock(BOTTOM)
    CONFIRM:SetText(RDV.LIBRARY.GetLang(nil, "VR_saveLabel"))
    CONFIRM:DockMargin(0, 0, w * 0.01, 0)
    CONFIRM.DoClick = function()
        if !DATA.NAME or DATA.NAME == "" then return end
        if !DATA.CLASS or DATA.CLASS == "" then return end
        if !DATA.CATEGORY or DATA.CATEGORY == "" then return end

        local COMPRESS = util.Compress(util.TableToJSON(DATA))
        local BYTES = #COMPRESS

        net.Start("RDV_REQUISITION_AddVehicle")
            net.WriteUInt(BYTES, 32)
            net.WriteData(COMPRESS, BYTES)
        net.SendToServer()

        surface.PlaySound("reality_development/ui/ui_accept.ogg")
        SendNotification(LocalPlayer(), RDV.LIBRARY.GetLang(nil, "VR_CFG_savedSuccess"))

        if IsValid(OFRAME) then
            OFRAME:SetVisible(true)
        end

        FRAME:Remove()
    end
end

--[[-----------------------------------------]]--
--  Admin Menu
--[[-----------------------------------------]]--

net.Receive("RDV_REQUISITION_ADMIN", function()
    local FRAME = vgui.Create("PIXEL.Frame")
    FRAME:SetSize(ScrW() * 0.3, ScrH() * 0.6)
    FRAME:Center()
    FRAME:MakePopup(true)
    FRAME:SetTitle(RDV.LIBRARY.GetLang(nil, "VR_addonTitle"))

    local PANEL = vgui.Create("DPanel", FRAME)
    PANEL:Dock(FILL)
    PANEL.Paint = function(s)
        local SB = FRAME:CreateSidebar("vehiclesMenu", nil)

        SB:AddItem("generalConfig", RDV.LIBRARY.GetLang(nil, "VR_CFG_options"), "aYJTAUa", function()
            PANEL:Clear()

            local SCROLL = vgui.Create("PIXEL.ScrollPanel", PANEL)
            SCROLL:Dock(FILL)

            local DATA = table.Copy(RDV.VEHICLE_REQ.CFG)

            local w, h = PANEL:GetSize()

            --[[---------------------------------]]--
            --	NPC Model 
            --[[---------------------------------]]--

            local P = vgui.Create("PIXEL.Label", SCROLL)
            P:Dock(TOP)
            P:SetText(RDV.LIBRARY.GetLang(nil, "VR_CFG_npcModel"))
            P:DockMargin(0, 0, w * 0.01, h * 0.01)

            local OPTION_npcModel = SCROLL:Add("DTextEntry")
            OPTION_npcModel:Dock(TOP)
            OPTION_npcModel:SetHeight(OPTION_npcModel:GetTall() * 1.5)
            OPTION_npcModel:DockMargin(0, 0, w * 0.01, h * 0.01)
            OPTION_npcModel.OnChange = function(s, val)
                DATA.NPC_MODEL = s:GetValue()
            end

            if DATA.NPC_MODEL then
                OPTION_npcModel:SetText(DATA.NPC_MODEL)
            end

            --[[---------------------------------]]--
            --	Menu Model
            --[[---------------------------------]]--

            local P = vgui.Create("PIXEL.Label", SCROLL)
            P:Dock(TOP)
            P:SetText(RDV.LIBRARY.GetLang(nil, "VR_CFG_menuModel"))
            P:DockMargin(0, 0, w * 0.01, h * 0.01)

            local OPTION_menuModel = SCROLL:Add("DTextEntry")
            OPTION_menuModel:Dock(TOP)
            OPTION_menuModel:SetHeight(OPTION_menuModel:GetTall() * 1.5)
            OPTION_menuModel:DockMargin(0, 0, w * 0.01, h * 0.01)
            OPTION_menuModel.OnChange = function(s, val)
                DATA.MEN_MODEL = s:GetValue()
            end
    
            if DATA.MEN_MODEL and ( DATA.MEN_MODEL ~= "" ) then
                OPTION_menuModel:SetText(DATA.MEN_MODEL)
            end
            
            --[[---------------------------------]]--
            --	Overhead Accent
            --[[---------------------------------]]--

            local P = vgui.Create("PIXEL.Label", SCROLL)
            P:Dock(TOP)
            P:SetText(RDV.LIBRARY.GetLang(nil, "VR_CFG_overheadAccent"))
            P:DockMargin(0, 0, w * 0.01, h * 0.01)

            local OPTION_overheadColor = vgui.Create("DColorMixer", SCROLL)
            OPTION_overheadColor:SetTall(OPTION_overheadColor:GetTall() * 0.75)
            OPTION_overheadColor:Dock(TOP)
            OPTION_overheadColor:DockMargin(0, 0, w * 0.01, h * 0.01)

            if DATA.OVR_COLOR and ( DATA.OVR_COLOR ~= "" ) then
                local C = DATA.OVR_COLOR

                OPTION_overheadColor:SetColor(Color(C.r, C.g, C.b, C.a))
            end

            --[[---------------------------------]]--
            --	Prefix Text
            --[[---------------------------------]]--

            local P = vgui.Create("PIXEL.Label", SCROLL)
            P:Dock(TOP)
            P:SetText(RDV.LIBRARY.GetLang(nil, "VR_CFG_prefixText"))
            P:DockMargin(0, 0, w * 0.01, h * 0.01)

            local OPTION_prefixText = SCROLL:Add("DTextEntry")
            OPTION_prefixText:Dock(TOP)
            OPTION_prefixText:SetHeight(OPTION_prefixText:GetTall() * 1.5)
            OPTION_prefixText:DockMargin(0, 0, w * 0.01, h * 0.01)
            OPTION_prefixText.OnChange = function(s, val)
                DATA.PRE_STRING = s:GetValue()
            end
    
            if DATA.PRE_STRING and ( DATA.PRE_STRING ~= "" ) then
                OPTION_prefixText:SetText(DATA.PRE_STRING)
            end

            --[[---------------------------------]]--
            --	Prefix Color
            --[[---------------------------------]]--

            local P = vgui.Create("PIXEL.Label", SCROLL)
            P:Dock(TOP)
            P:SetText(RDV.LIBRARY.GetLang(nil, "VR_CFG_prefixColor"))
            P:DockMargin(0, 0, w * 0.01, h * 0.01)

            local OPTION_prefixColor = vgui.Create("DColorMixer", SCROLL)
            OPTION_prefixColor:SetTall(OPTION_prefixColor:GetTall() * 0.75)
            OPTION_prefixColor:Dock(TOP)
            OPTION_prefixColor:DockMargin(0, 0, w * 0.01, h * 0.01)

    
            if DATA.PRE_COLOR and ( DATA.PRE_COLOR ~= "" ) then
                local C = DATA.PRE_COLOR

                OPTION_prefixColor:SetColor(Color(C.r, C.g, C.b, C.a))
            end

            --[[---------------------------------]]--
            --	Auto Deny
            --[[---------------------------------]]--

            local P = vgui.Create("PIXEL.Label", SCROLL)
            P:Dock(TOP)
            P:SetText(RDV.LIBRARY.GetLang(nil, "VR_CFG_autoDenyTime"))
            P:DockMargin(0, 0, w * 0.01, h * 0.01)

            local OPTION_autoDeny = SCROLL:Add("DNumSlider")
            OPTION_autoDeny:Dock(TOP)
            OPTION_autoDeny:SetHeight(OPTION_autoDeny:GetTall() * 1.5)
            OPTION_autoDeny:DockMargin(0, 0, w * 0.01, h * 0.01)
            OPTION_autoDeny:SetMax(100000)
            OPTION_autoDeny:SetDecimals(0)
            OPTION_autoDeny.OnValueChanged  = function(s, val)
                if !val or val == 0 then
                    DATA.DEN_TIME = false
                else
                    DATA.DEN_TIME = tonumber(s:GetValue())
                end
            end

            if DATA.DEN_TIME then
                OPTION_autoDeny:SetValue(DATA.DEN_TIME)
            end

            --[[---------------------------------]]--
            --	Max Vehicles
            --[[---------------------------------]]--

            local P = vgui.Create("PIXEL.Label", SCROLL)
            P:Dock(TOP)
            P:SetText(RDV.LIBRARY.GetLang(nil, "VR_CFG_maxVehicles"))
            P:DockMargin(0, 0, w * 0.01, h * 0.01)

            local OPTION_maxVehicles = SCROLL:Add("DNumSlider")
            OPTION_maxVehicles:Dock(TOP)
            OPTION_maxVehicles:SetHeight(OPTION_maxVehicles:GetTall() * 1.5)
            OPTION_maxVehicles:DockMargin(0, 0, w * 0.01, h * 0.01)
            OPTION_maxVehicles:SetMax(100000)
            OPTION_maxVehicles:SetDecimals(0)

            OPTION_maxVehicles.OnValueChanged  = function(s, val)
                if !val or val == 0 then
                    DATA.MAX_VEH = false
                else
                    DATA.MAX_VEH = tonumber(s:GetValue())
                end
            end

            if DATA.MAX_VEH and isnumber(DATA.MAX_VEH) then
                OPTION_maxVehicles:SetValue(DATA.MAX_VEH)
            end

            --[[---------------------------------]]--
            --	Spawnpoint Radius
            --[[---------------------------------]]--

            local P = vgui.Create("PIXEL.Label", SCROLL)
            P:Dock(TOP)
            P:SetText(RDV.LIBRARY.GetLang(nil, "VR_CFG_spawnpointRadius"))
            P:DockMargin(0, 0, w * 0.01, h * 0.01)

            local OPTION_spawnRadius = SCROLL:Add("DNumSlider")
            OPTION_spawnRadius:Dock(TOP)
            OPTION_spawnRadius:SetHeight(OPTION_spawnRadius:GetTall() * 1.5)
            OPTION_spawnRadius:DockMargin(0, 0, w * 0.01, h * 0.01)
            OPTION_spawnRadius:SetMax(100000)
            OPTION_spawnRadius:SetDecimals(0)
            OPTION_spawnRadius.OnValueChanged  = function(s, val)
                DATA.HAN_SIZE = tonumber(s:GetValue())
            end

            if DATA.HAN_SIZE then
                OPTION_spawnRadius:SetValue(DATA.HAN_SIZE)
            end

            --[[---------------------------------]]--
            --	Spawnpoint Max Distance
            --[[---------------------------------]]--

            local P = vgui.Create("PIXEL.Label", SCROLL)
            P:Dock(TOP)
            P:SetText(RDV.LIBRARY.GetLang(nil, "VR_CFG_spawnpointMaxDistance"))
            P:DockMargin(0, 0, w * 0.01, h * 0.01)

            local OPTION_spawnDistance = SCROLL:Add("DNumSlider")
            OPTION_spawnDistance:Dock(TOP)
            OPTION_spawnDistance:SetHeight(OPTION_spawnDistance:GetTall() * 1.5)
            OPTION_spawnDistance:DockMargin(0, 0, w * 0.01, h * 0.01)
            OPTION_spawnDistance:SetMax(100000)
            OPTION_spawnDistance:SetDecimals(0)
            OPTION_spawnDistance.OnValueChanged  = function(s, val)
                if !val or val == 0 then
                    DATA.MAX_DIST = false
                else
                    DATA.MAX_DIST = tonumber(s:GetValue())
                end
            end

            if DATA.MAX_DIST then
                OPTION_spawnDistance:SetValue(DATA.MAX_DIST)
            end

            --[[---------------------------------]]--
            --	Randomize Vendor
            --[[---------------------------------]]--

            local P = vgui.Create("PIXEL.Label", SCROLL)
            P:Dock(TOP)
            P:SetText(RDV.LIBRARY.GetLang(nil, "VR_CFG_randomizeVendor"))
            P:DockMargin(0, 0, w * 0.01, h * 0.01)

            local LABEL = vgui.Create("DLabel", SCROLL)
            LABEL:SetText("")
            LABEL:SetHeight(h * 0.1)
            LABEL:Dock(TOP)
            LABEL:DockMargin(0, 0, w * 0.01, h * 0.01)
            LABEL:SetMouseInputEnabled(true)
                
            local CHECK_L = vgui.Create("DLabel", LABEL)
            CHECK_L:SetMouseInputEnabled(true)
            CHECK_L:Dock(RIGHT)
            CHECK_L:SetText("")
    
            local CHECK = vgui.Create("PIXEL.Checkbox", CHECK_L)
            CHECK:SetPos( (CHECK_L:GetWide() * 0.4 ) - ( CHECK:GetWide() / 2 ) , ( CHECK_L:GetTall() * 0.5 ) + ( CHECK:GetTall() / 2 ) )
            CHECK.OnToggled = function(s, val)
                DATA.VENDOR_RANDOMIZE = val

            end
    
            if DATA.VENDOR_RANDOMIZE then
                CHECK:SetToggle(true)
            end

            --[[---------------------------------]]--
            --	Self-Grant Allowed
            --[[---------------------------------]]--

            local P = vgui.Create("PIXEL.Label", SCROLL)
            P:Dock(TOP)
            P:SetText(RDV.LIBRARY.GetLang(nil, "VR_enableSelfGrant"))

            local LABEL = vgui.Create("DLabel", SCROLL)
            LABEL:SetText("")
            LABEL:SetHeight(h * 0.1)
            LABEL:Dock(TOP)
            LABEL:DockMargin(0, 0, w * 0.01, h * 0.01)
            LABEL:SetMouseInputEnabled(true)
                
            local CHECK_L = vgui.Create("DLabel", LABEL)
            CHECK_L:SetMouseInputEnabled(true)
            CHECK_L:Dock(RIGHT)
            CHECK_L:SetText("")
    
            local CHECK = vgui.Create("PIXEL.Checkbox", CHECK_L)
            CHECK:SetPos( (CHECK_L:GetWide() * 0.4 ) - ( CHECK:GetWide() / 2 ) , ( CHECK_L:GetTall() * 0.5 ) + ( CHECK:GetTall() / 2 ) )
            CHECK.OnToggled = function(s, val)
                DATA.SG_PERM = val
            end
    
            if DATA.SG_PERM then
                CHECK:SetToggle(true)
            end

            --[[---------------------------------]]--
            --	Display Spawn Locations
            --[[---------------------------------]]--

            local P = vgui.Create("PIXEL.Label", SCROLL)
            P:Dock(TOP)
            P:SetText(RDV.LIBRARY.GetLang(nil, "VR_displaySpawnLocations"))

            local LABEL = vgui.Create("DLabel", SCROLL)
            LABEL:SetText("")
            LABEL:SetHeight(h * 0.1)
            LABEL:Dock(TOP)
            LABEL:DockMargin(0, 0, w * 0.01, h * 0.01)
            LABEL:SetMouseInputEnabled(true)
                
            local CHECK_L = vgui.Create("DLabel", LABEL)
            CHECK_L:SetMouseInputEnabled(true)
            CHECK_L:Dock(RIGHT)
            CHECK_L:SetText("")

            local CHECK = vgui.Create("PIXEL.Checkbox", CHECK_L)
            CHECK:SetPos( (CHECK_L:GetWide() * 0.4 ) - ( CHECK:GetWide() / 2 ) , ( CHECK_L:GetTall() * 0.5 ) + ( CHECK:GetTall() / 2 ) )
            CHECK.OnToggled = function(s, val)
                DATA.DIS_HANGARS = val
            end

            if DATA.DIS_HANGARS then
                CHECK:SetToggle(true)
            end

            local SEND = vgui.Create("PIXEL.TextButton", PANEL)
            SEND:Dock(BOTTOM)
            SEND:SetText(RDV.LIBRARY.GetLang(nil, "VR_saveLabel"))
            SEND.DoClick = function(s)
                DATA.PRE_COLOR = OPTION_prefixColor:GetColor()
                DATA.OVR_COLOR = OPTION_overheadColor:GetColor()

                local S_COMPRESS = util.Compress(util.TableToJSON(DATA))
                local S_BYTES = #S_COMPRESS
            
                net.Start("RDV_REQUISITION_SaveSettings")
                    net.WriteUInt(S_BYTES, 32)
                    net.WriteData(S_COMPRESS, S_BYTES)
                net.SendToServer()

                surface.PlaySound("reality_development/ui/ui_accept.ogg")
                SendNotification(LocalPlayer(), RDV.LIBRARY.GetLang(nil, "VR_CFG_savedSuccess"))
            end
        end )

        SB:AddItem("vehiclesMenu", RDV.LIBRARY.GetLang(nil, "VR_vehiclesLabel"), "0w4PAfy", function()
            PANEL:Clear()

            local LIST

            local LABEL = PANEL:Add("DLabel")
            LABEL:Dock(TOP)
            LABEL:SetTall(LABEL:GetTall() * 1.5)
            LABEL:SetText("")
            LABEL:SetMouseInputEnabled(true)

            local ADD = LABEL:Add("DButton", LABEL)
            ADD:SetImage("icon16/add.png")
            ADD:Dock(LEFT)
            ADD:SetText("")
            ADD:SetWide(ADD:GetWide() * 0.4)

            local B_REFRESH = LABEL:Add("DButton", LABEL)
            B_REFRESH:SetImage("icon16/arrow_refresh.png")
            B_REFRESH:Dock(LEFT)
            B_REFRESH:SetText("")
            B_REFRESH:SetWide(B_REFRESH:GetWide() * 0.4)
            B_REFRESH.DoClick = function(s)
                LIST:Clear()

                for k, v in pairs(RDV.VEHICLE_REQ.VEHICLES) do
                    local LINE = LIST:AddLine( v.NAME, ( v.CREATOR or "Invalid" ), k )
                    LINE.UID = v.UID
                end
            end

            ADD.DoClick = function(s)
                AddVehicle(nil, FRAME)
            end

            --ADD:SetStretchToFit(false)

            LIST = PANEL:Add( "DListView" )
            LIST:Dock( TOP )
            LIST:SetTall(PANEL:GetTall() * 0.75)
            LIST:SetMultiSelect( false )
            LIST:AddColumn( RDV.LIBRARY.GetLang(nil, "VR_nameLabel") )
            LIST:AddColumn( RDV.LIBRARY.GetLang(nil, "VR_CFG_creatorLabel")  )
            LIST:AddColumn( RDV.LIBRARY.GetLang(nil, "VR_CFG_UIDLabel")  )

            LIST.OnRowRightClick = function(_, ID, LINE)
                local MenuButtonOptions = DermaMenu()

                MenuButtonOptions:AddOption(RDV.LIBRARY.GetLang(nil, "VR_editLabel"), function()
                    AddVehicle(LINE.UID, FRAME)
                end)

                MenuButtonOptions:AddOption(RDV.LIBRARY.GetLang(nil, "VR_dupeLabel"), function()
                    AddVehicle(LINE.UID, FRAME, true)
                end)

                MenuButtonOptions:AddOption(RDV.LIBRARY.GetLang(nil, "VR_deleteLabel"), function()
                    net.Start("RDV_RDV_REQUISITION_DelVehicle")
                        net.WriteString(LINE.UID)
                    net.SendToServer()
                end)

                MenuButtonOptions:Open()
            end

            for k, v in pairs(RDV.VEHICLE_REQ.VEHICLES) do
                local LINE = LIST:AddLine( v.NAME, ( v.CREATOR or "Invalid" ), k )
                LINE.UID = v.UID
            end
        end )

        SB:AddItem("spawnsMenu", RDV.LIBRARY.GetLang(nil, "VR_spawnsLabel"), "d9G08E4", function()
            PANEL:Clear()

            local LIST

            local LABEL = PANEL:Add("DLabel")
            LABEL:Dock(TOP)
            LABEL:SetTall(LABEL:GetTall() * 1.5)
            LABEL:SetText("")
            LABEL:SetMouseInputEnabled(true)

            local ADD = LABEL:Add("DButton", LABEL)
            ADD:SetImage("icon16/add.png")
            ADD:Dock(LEFT)
            ADD:SetText("")
            ADD:SetWide(ADD:GetWide() * 0.4)

            local B_REFRESH = LABEL:Add("DButton", LABEL)
            B_REFRESH:SetImage("icon16/arrow_refresh.png")
            B_REFRESH:Dock(LEFT)
            B_REFRESH:SetText("")
            B_REFRESH:SetWide(B_REFRESH:GetWide() * 0.4)
            B_REFRESH.DoClick = function(s)
                LIST:Clear()

                for k, v in pairs(RDV.VEHICLE_REQ.SPAWNS) do
                    local LINE = LIST:AddLine( v.NAME, v.CREATOR, k )
                    LINE.UID = v.UID
                end
            end

            ADD.DoClick = function(s)
                AddSpawn(nil, FRAME)
            end

            LIST = PANEL:Add( "DListView" )
            LIST:Dock( TOP )
            LIST:SetTall(PANEL:GetTall() * 0.75)
            LIST:SetMultiSelect( false )
            LIST:AddColumn( RDV.LIBRARY.GetLang(nil, "VR_nameLabel") )
            LIST:AddColumn( RDV.LIBRARY.GetLang(nil, "VR_CFG_creatorLabel")  )
            LIST:AddColumn( RDV.LIBRARY.GetLang(nil, "VR_CFG_UIDLabel")  )

            LIST.OnRowRightClick = function(_, ID, LINE)
                local MenuButtonOptions = DermaMenu()

                MenuButtonOptions:AddOption(RDV.LIBRARY.GetLang(nil, "VR_editLabel"), function()
                    AddSpawn(LINE.UID, FRAME)
                end)

                MenuButtonOptions:AddOption(RDV.LIBRARY.GetLang(nil, "VR_dupeLabel"), function()
                    AddSpawn(LINE.UID, FRAME, true)
                end)

                MenuButtonOptions:AddOption(RDV.LIBRARY.GetLang(nil, "VR_deleteLabel"), function()
                    net.Start("RDV_REQUISITION_DelSpawn")
                        net.WriteString(LINE.UID)
                    net.SendToServer()
                end)

                MenuButtonOptions:Open()
            end

            for k, v in pairs(RDV.VEHICLE_REQ.SPAWNS) do
                local LINE = LIST:AddLine( v.NAME, v.CREATOR, k )
                LINE.UID = v.UID
            end
        end )   

        PANEL.Paint = function() end
    end
end )

net.Receive("RDV_REQUISITION_AddSpawn", function()
    local LEN = net.ReadUInt(32)
    local DATA = net.ReadData(LEN)

    local DECOMP = util.JSONToTable(util.Decompress(DATA))
    local UID = DECOMP.UID

    RDV.VEHICLE_REQ.SPAWNS[UID] = DECOMP
end )

net.Receive("RDV_REQUISITION_DelSpawn", function()
    local UID = net.ReadString()

    if RDV.VEHICLE_REQ.SPAWNS[UID] then
        RDV.VEHICLE_REQ.SPAWNS[UID] = nil
    end
end )

--[[
--  Vehicles
--]]

net.Receive("RDV_REQUISITION_AddVehicle", function()
    local LEN = net.ReadUInt(32)
    local DATA = net.ReadData(LEN)

    local DECOMP = util.JSONToTable(util.Decompress(DATA))
    local UID = DECOMP.UID

    RDV.VEHICLE_REQ.VEHICLES[UID] = DECOMP
end )

net.Receive("RDV_RDV_REQUISITION_DelVehicle", function()
    local UID = net.ReadString()

    if RDV.VEHICLE_REQ.VEHICLES[UID] then
        RDV.VEHICLE_REQ.VEHICLES[UID] = nil
    end
end )

net.Receive("RDV_REQUISITION_BatchSend", function()
    local V_LEN = net.ReadUInt(32)
    local V_DATA = net.ReadData(V_LEN)
    local H_LEN = net.ReadUInt(32)
    local H_DATA = net.ReadData(H_LEN)

    local V_DECOMP = util.JSONToTable(util.Decompress(V_DATA))
    RDV.VEHICLE_REQ.VEHICLES = V_DECOMP

    local H_DECOMP = util.JSONToTable(util.Decompress(H_DATA))
    RDV.VEHICLE_REQ.SPAWNS = H_DECOMP
end )

net.Receive("RDV_REQUISITION_SaveSettings", function()
    local LEN = net.ReadUInt(32)
    local DATA = net.ReadData(LEN)

    local DECOMP = util.JSONToTable(util.Decompress(DATA))

    for k, v in pairs(DECOMP) do
        if istable(v) and v.r and v.g and v.b then v = Color(v.r, v.g, v.b) end

        if ( RDV.VEHICLE_REQ.CFG[k] ~= nil ) then
            RDV.VEHICLE_REQ.CFG[k] = v
        end
    end
end )