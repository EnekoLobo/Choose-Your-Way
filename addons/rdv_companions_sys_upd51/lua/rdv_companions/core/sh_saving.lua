if SERVER then
    local VENDORS = {}

    concommand.Add("rdv_comps_addvendor", function(ply, cmd, args)
        if !ply:IsAdmin() then return end
        
        net.Start("RDV_COMP_AddVendor")
        net.Send(ply)
    end )

    --[[---------------------------------]]--
    --	Initializing Vendors
    --[[---------------------------------]]--

    local function ResetVendors()
        for k, v in ipairs(VENDORS) do
            local E = ents.Create("eps_cwapet_seller")
            E:SetPos(v.P)
            E:SetAngles(v.A)
            E:Spawn()
            E:SetModel(v.M)

            VENDORS[k].NPC = E

            timer.Simple(0, function()
                E:ResetSequence(v.S)
            end )
        end
    end
    hook.Add("PostCleanupMap", "RDV_COMPS_ResetVendors", ResetVendors)

    --[[---------------------------------]]--
    --	Reading Vendors File on Startup
    --[[---------------------------------]]--

    local function Read()
        local PATH = "rdv/comps/vendors/"..game.GetMap()..".json"

        if file.Exists(PATH, "DATA") then
            local TAB = util.JSONToTable(file.Read(PATH, "DATA"))

            if !istable(TAB) then
                return
            end

            VENDORS = TAB

            ResetVendors()
        end
    end
    Read()

    --[[---------------------------------]]--
    --	Saving
    --[[---------------------------------]]--

    local function Save()
        local SAVE = {}

        for k, v in ipairs(VENDORS) do
            if !IsValid(v.NPC) then
                continue
            end

            table.insert(SAVE, {
                P = v.P,
                M = v.M,
                A = v.A,
                S = v.S,
            })
        end

        local JSON = util.TableToJSON(SAVE)

        file.CreateDir("rdv/comps/vendors")
            
        file.Write("rdv/comps/vendors/"..game.GetMap()..".json", JSON)
    end

    util.AddNetworkString("RDV_COMP_AddVendor")

    concommand.Add("rdv_comps_removevendor", function(ply, cmd, args)
        if !ply:IsAdmin() then return end

        local TRACE = ply:GetEyeTrace().Entity

        if !IsValid(TRACE) then return end
        
        for k, v in ipairs(VENDORS) do
            if ( v.NPC == TRACE ) then
                table.remove(VENDORS, k)    
                
                TRACE:Remove()
                
                break
            end
        end

        Save()
    end )

    --[[---------------------------------]]--
    --	Adding Initial Vendor
    --[[---------------------------------]]--



    net.Receive("RDV_COMP_AddVendor", function(len, ply)
        if !ply:IsAdmin() then return end

        local MODEL = net.ReadString()
        local STANCE = net.ReadString()

        local E = ents.Create("eps_cwapet_seller")
        E:SetPos(ply:GetPos())
        E:SetAngles(ply:GetAngles())
        E:Spawn()
        E:SetModel(MODEL)

        table.insert(VENDORS, {
            M = MODEL,
            S = STANCE,
            P = ply:GetPos(),
            A = ply:GetAngles(),
            NPC = E,
        })

        timer.Simple(0, function()
            E:ResetSequence(STANCE)
        end )

        Save()
    end )
else
    net.Receive("RDV_COMP_AddVendor", function()
        local ICON
        local STANCES
        local AN
        local DELAY = 0

        local FRAME = vgui.Create("PIXEL.Frame")
        FRAME:SetSize(ScrW() * 0.3, ScrH() * 0.6)
        FRAME:Center()
        FRAME:SetVisible(true)
        FRAME:MakePopup()
        FRAME:SetTitle(RDV.LIBRARY.GetLang(nil, "COMP_companionsLabel"))

        local w, h = FRAME:GetSize()

        local TEXT = vgui.Create("PIXEL.TextEntry", FRAME)
        TEXT:Dock(TOP)
        TEXT:DockMargin(w * 0.05, h * 0.015, w * 0.05, h * 0.015)
        TEXT:SetPlaceholderText(RDV.LIBRARY.GetLang(nil, "COMP_modelLabel"))
        TEXT.OnValueChange = function(s)
            STANCES:Clear()
            
            ICON:SetModel(s:GetValue())

            if IsValid(ICON.Entity) then
                local mn, mx = ICON.Entity:GetRenderBounds()
                mn = mn * 0.7
                mx = mx * 0.7
            
                local size = 0
            
                size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
                size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
                size = math.max(size, math.abs(mn.z) + math.abs(mx.z))

                ICON:SetCamPos(Vector(size, size, size))
                ICON:SetLookAt((mn + mx) * 0.55)
                ICON:SetAmbientLight( color_white )
                ICON:SetAnimated(true)

                local LIST = ICON.Entity:GetSequenceList()

                for k, v in ipairs(LIST) do
                    STANCES:AddLine( v, k )
                end
            end
        end

        local SEND = vgui.Create("PIXEL.TextButton", FRAME)
        SEND:Dock(BOTTOM)
        SEND:SetText(RDV.LIBRARY.GetLang(nil, "COMP_confirmLabel"))
        SEND:SetMouseInputEnabled(true)
        SEND.DoClick = function(self)
            local MODEL = TEXT:GetValue()
            local STANCES = STANCES:GetSelected()

            if !STANCES[1] then return end

            local STANCE = STANCES[1]:GetValue(1)

            if ( !MODEL or MODEL == "" ) or ( !STANCE or STANCE == "" ) then
                return
            end

            net.Start("RDV_COMP_AddVendor")
                net.WriteString(TEXT:GetValue())
                net.WriteString(STANCES[1]:GetValue(1))
            net.SendToServer()
        end

        STANCES = vgui.Create( "DListView", FRAME )
        STANCES:Dock( FILL )
        STANCES:SetMultiSelect( false )
        STANCES:AddColumn( RDV.LIBRARY.GetLang(nil, "COMP_stanceLabel") )
        STANCES:DockMargin(w * 0.05, h * 0.015, w * 0.05, h * 0.015)
        STANCES.OnRowSelected = function( _, _, row )
            AN = row:GetValue( 1 )
            DELAY = 0
        end

        ICON = vgui.Create( "DModelPanel", FRAME )
        ICON:SetSize( w * 0.4, 0 )
        ICON:Dock(RIGHT)

        function ICON:LayoutEntity( Entity )
            if !IsValid(ICON.Entity) then return end
            if !AN then return end

            if DELAY and DELAY < CurTime() then
                ICON.Entity:SetSequence("idle_all_01")
                
                ICON:RunAnimation()

                local DUR = ICON.Entity:SequenceDuration(AN)
                ICON.Entity:SetSequence(AN)

                DELAY = CurTime() + DUR
            end

            ICON:RunAnimation()
        end

        TEXT:SetValue("models/Humans/Group01/Female_01.mdl")
    end )
end