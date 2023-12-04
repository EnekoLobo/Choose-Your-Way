local PANEL = {}

local NPCType = ""
function PANEL:Init()
	BRCS_ADMIN_CFG = table.Copy( BRICKSCREDITSTORE.CONFIG )

	self:SetSize( ScrW(), ScrH() )
	self:SetPos( 0, 0 )
	self:MakePopup()
	self:SetTitle( "" )
	self:ShowCloseButton( false )
	self:SetDraggable( false )

	--[[ INVENTORY ]]--
	self.MenuBack = vgui.Create( "DPanel", self )
	self.MenuBack:SetSize( BRCS_SWIDTH, BRCS_SWIDTH*0.6 )
	self.MenuBack:Center()
	self.MenuBack:SetAlpha( 0 )
	self.MenuBack:AlphaTo( 255, 0.05, 0 )
	self.MenuBack.Paint = function( self2, w, h )
		surface.SetDrawColor( BRICKSCREDITSTORE.LUACONFIG.Themes.Primary )
		surface.DrawRect( 0, 0, w, h )
	end

	local BackW, BackH = self.MenuBack:GetSize()

	function self:CreateCloseButton( parent )
		if( IsValid( self.CloseButton ) ) then
			self.CloseButton:Remove()
		end

		self.CloseButton = vgui.Create( "DButton", parent )
		local size = 20
		self.CloseButton:SetSize( size, size )
		self.CloseButton:SetPos( BackW-83*BRCS_SHEIGHT_SCALE-size, 83*BRCS_SHEIGHT_SCALE )
		self.CloseButton:SetText( "" )
		local CloseMat = Material( "materials/brickscreditstore/close.png", "noclamp smooth" )
		self.CloseButton.Paint = function( self2, w, h )
			if( self2:IsHovered() and !self2:IsDown() ) then
				surface.SetDrawColor( 52*1.35, 55*1.35, 76*1.35 )
			elseif( self2:IsDown() || self2.m_bSelected ) then
				surface.SetDrawColor( BRICKSCREDITSTORE.LUACONFIG.Themes.Accent )
			else
				surface.SetDrawColor( 52, 55, 76 )
			end

			surface.SetMaterial( CloseMat )
			surface.DrawTexturedRect( 0, 0, w, h )
		end
		self.CloseButton.DoClick = function()
			if( BRCS_ADMIN_CFG and BRCS_ADMIN_CFG_CHANGED ) then
				BRCS_ADMIN_CFG_CHANGED = false

				local configData = util.Compress( util.TableToJSON( BRCS_ADMIN_CFG ) )

				net.Start( "BRCS_Net_UpdateConfig" )
					net.WriteData( configData, string.len( configData ) )
				net.SendToServer()
			else
				net.Start( "BRCS_Net_CloseAdminMenu" )
				net.SendToServer()
			end

			self:SetKeyboardInputEnabled( false )
			self:SetMouseInputEnabled( false )
			self.MenuBack:AlphaTo( 0, 0.05, 0, function() 
				self:Remove()
			end )
		end
	end

	function self:CreateHomeButton( parent )
		if( IsValid( self.HomeButton ) ) then
			self.HomeButton:Remove()
		end

		self.HomeButton = vgui.Create( "brcs_vgui_button", parent )
		self.HomeButton:SetPos( 83*BRCS_SHEIGHT_SCALE, 83*BRCS_SHEIGHT_SCALE )
		self.HomeButton:SetSize( 40, 40 )
		local CloseMat = Material( "materials/brickscreditstore/home.png", "noclamp smooth" )
		self.HomeButton:SetInfo( "", CloseMat )
		self.HomeButton.DoClick = function()
			self:ShowChoices()
		end
	end

	local DisplayArea = vgui.Create( "DPanel", self.MenuBack )
	DisplayArea:Dock( FILL )
	DisplayArea.Paint = function( self2, w, h ) end

	function self:ShowChoices()
		DisplayArea:Clear()

		local SettingsButton = vgui.Create( "brcs_vgui_button", DisplayArea )
		SettingsButton:SetPos( 83*BRCS_SHEIGHT_SCALE, 83*BRCS_SHEIGHT_SCALE )
		SettingsButton:SetSize( 40, 40 )
		local SettingsMat = Material( "materials/brickscreditstore/settings.png", "noclamp smooth" )
		SettingsButton:SetInfo( "", SettingsMat )
		SettingsButton.DoClick = function()
			if( IsValid( BCREDITSTORE_ADMIN_OTHERSETTINGS ) ) then
				BCREDITSTORE_ADMIN_OTHERSETTINGS:Remove()
			end
	
			BCREDITSTORE_ADMIN_OTHERSETTINGS = vgui.Create( "brcs_vgui_admin_othersettings" )
		end

		local ChoiceColumn = vgui.Create( "DPanel", DisplayArea )
		ChoiceColumn:SetSize( 300, BackH )
		ChoiceColumn:SetPos( (BackW/2)-(ChoiceColumn:GetWide()/2), 0 )
		local ChoiceBackY = 0
		ChoiceColumn.Paint = function( self2, w, h ) 
			draw.SimpleText( "Which store would you like to edit?", "BRCS_MP_22", w/2, ChoiceBackY-20, BRICKSCREDITSTORE.LUACONFIG.Themes.White, 1, TEXT_ALIGN_BOTTOM )
		end

		local ChoiceBack = vgui.Create( "DPanel", ChoiceColumn )
		ChoiceBack:SetSize( 300, 0 )
		ChoiceBack:SetPos( 0, 0 )
		ChoiceBack.Paint = function( self2, w, h ) end

		local ChoiceTall = 50
		for k, v in pairs( BRCS_ADMIN_CFG.NPCs ) do
			ChoiceBack:SetTall( ChoiceBack:GetTall()+ChoiceTall+10 )
			local ChoiceEntry = vgui.Create( "DButton", ChoiceBack )
			ChoiceEntry:Dock( TOP )
			ChoiceEntry:SetTall( ChoiceTall )
			ChoiceEntry:SetText( "" )
			ChoiceEntry:DockMargin( 0, 0, 0, 10 )
			local IconSize = ChoiceEntry:GetTall()*0.5
			local IconMat = BRICKSCREDITSTORE.GetImage( v.icon or "" )
			ChoiceEntry.Paint = function( self2, w, h )
				draw.RoundedBox( 3, 0, 0, w, h, BRICKSCREDITSTORE.LUACONFIG.Themes.Secondary )
		
				if( self2:IsHovered() and !self2:IsDown() ) then
					surface.SetDrawColor( 52*1.35, 55*1.35, 76*1.35 )
					draw.SimpleText( k, "BRCS_MP_22", w/2, h/2, Color( 101*1.35, 107*1.35, 145*1.35 ), 1, 1 )
				elseif( self2:IsDown() ) then
					surface.SetDrawColor( BRICKSCREDITSTORE.LUACONFIG.Themes.Accent )
					draw.SimpleText( k, "BRCS_MP_22", w/2, h/2, BRICKSCREDITSTORE.LUACONFIG.Themes.White, 1, 1 )
				else
					surface.SetDrawColor( 52, 55, 76 )
					draw.SimpleText( k, "BRCS_MP_22", w/2, h/2, Color( 101, 107, 145 ), 1, 1 )
				end
		
				surface.SetMaterial( IconMat )
				surface.DrawTexturedRect( 10, (h/2)-(IconSize/2), IconSize, IconSize )
			end
			ChoiceEntry.DoClick = function()
				self:ShowStore( k )
			end
		end

		ChoiceBack:SetTall( ChoiceBack:GetTall()+ChoiceTall+10 )
		local NewStore = vgui.Create( "DButton", ChoiceBack )
		NewStore:Dock( TOP )
		NewStore:SetTall( ChoiceTall )
		NewStore:SetText( "" )
		NewStore:DockMargin( 0, 0, 0, 10 )
		NewStore.Paint = function( self2, w, h )
			draw.RoundedBox( 3, 0, 0, w, h, BRICKSCREDITSTORE.LUACONFIG.Themes.Secondary )
	
			if( self2:IsHovered() and !self2:IsDown() ) then
				surface.SetDrawColor( 52*1.35, 55*1.35, 76*1.35 )
				draw.SimpleText( "Create a new store", "BRCS_MP_22", w/2, h/2, Color( 101*1.35, 107*1.35, 145*1.35 ), 1, 1 )
			elseif( self2:IsDown() ) then
				surface.SetDrawColor( BRICKSCREDITSTORE.LUACONFIG.Themes.Accent )
				draw.SimpleText( "Create a new store", "BRCS_MP_22", w/2, h/2, BRICKSCREDITSTORE.LUACONFIG.Themes.White, 1, 1 )
			else
				surface.SetDrawColor( 52, 55, 76 )
				draw.SimpleText( "Create a new store", "BRCS_MP_22", w/2, h/2, Color( 101, 107, 145 ), 1, 1 )
			end
		end
		NewStore.DoClick = function()
			local NewStore = { Items = {} }
			local StoreName = ""
			BRCS_StringRequest( "What should the name be?", "", "Example Store", "Next", function( text ) 
				if( BRCS_ADMIN_CFG.NPCs[text] ) then
					notification.AddLegacy( "A store with this name already exists!", 1, 5 )
					return
				end
				StoreName = text

				BRCS_StringRequest( "What should the icon URL be?", "", "https://i.imgur.com/eUKo7d4.png", "Next", function( text ) 
					NewStore.icon = text

					BRCS_StringRequest( "What should the NPC model be?", "", "models/breen.mdl", "Next", function( text ) 
						NewStore.model = text

						local Currencies = {}
						for k, v in pairs( BRICKSCREDITSTORE.CURRENCYTYPES ) do
							table.insert( Currencies, k )
						end
						BRCS_ComboRequest( "What should the store's currency be?", "", Currencies, "Next", function( key, value ) 
							NewStore.currency = value

							BRCS_StringRequest( "What should the new command be? (blank for none)", "", "/examplestore", "Next", function( text ) 
								if( string.Replace( text, " ", "" ) != "" ) then
									NewStore.CMD = text
								else
									NewStore.CMD = nil
								end

								BRCS_ComboRequest( "What keybind should open the store?", "", BRICKSCREDITSTORE.KeyBinds, "Finish", function( key, value ) 
									if( value != "None" ) then
										NewStore.Bind = key
									else
										NewStore.Bind = nil
									end

									BRCS_ADMIN_CFG.NPCs[StoreName] = NewStore
									BRCS_ADMIN_CFG_CHANGED = true

									self:ShowChoices()
								end, "Cancel", function() end, "None" )
							end, "Cancel", function() end )
						end, "Cancel", function() end )
					end, "Cancel", function() end )
				end, "Cancel", function() end )
			end, "Cancel", function() end )
		end

		ChoiceBack:SetTall( ChoiceBack:GetTall()-10 )
		ChoiceBack:SetPos( 0, (ChoiceColumn:GetTall()/2)-(ChoiceBack:GetTall()/2) )

		ChoiceBackY = (ChoiceColumn:GetTall()/2)-(ChoiceBack:GetTall()/2)

		self:CreateCloseButton( DisplayArea )
	end
	self:ShowChoices()

	function self:ShowStore( NPCType )
		DisplayArea:Clear()

		self:SetNPCType( NPCType )

		local StoreArea = vgui.Create( "brcs_vgui_admin_npc", DisplayArea )
		StoreArea:Dock( FILL )
		StoreArea.MenuPanel = self
		StoreArea.Paint = function( self2, w, h ) end

		self:CreateCloseButton( StoreArea )
		self:CreateHomeButton( StoreArea )
	end
end

function PANEL:SetNPCType( type )
	NPCType = type
end

function PANEL:Paint( w, h )
end

vgui.Register( "brcs_vgui_admin", PANEL, "DFrame" )

-- Store --
local PANEL = {}

function PANEL:RefreshStore()
	if( not IsValid( self.MenuPanel ) ) then return end

	self.MenuPanel:ShowStore( NPCType )
end

function PANEL:Init()
	if( not BRCS_ADMIN_CFG.NPCs[NPCType] ) then return end

	if( not BRCS_ADMIN_CFG.NPCs[NPCType].Items ) then
		BRCS_ADMIN_CFG.NPCs[NPCType].Items = {}
	end
	
	local TopColsheet = vgui.Create( "brcs_vgui_dcolumnsheet_top", self )
	TopColsheet:Dock( FILL )
	TopColsheet:DockMargin( 83*BRCS_SHEIGHT_SCALE, 50, 83*BRCS_SHEIGHT_SCALE, 83*BRCS_SHEIGHT_SCALE )
	TopColsheet:AddButton( "Settings", function() 
		if( IsValid( BCREDITSTORE_ADMIN_SETTINGS ) ) then
			BCREDITSTORE_ADMIN_SETTINGS:Remove()
		end
	
		BCREDITSTORE_ADMIN_SETTINGS = vgui.Create( "brcs_vgui_admin_settings" )
		BCREDITSTORE_ADMIN_SETTINGS:SetNPCType( NPCType )
		BCREDITSTORE_ADMIN_SETTINGS.StorePanel = self
	end )
	TopColsheet:AddButton( "New item", function() 
		if( IsValid( BCREDITSTORE_ADMIN_ITEM ) ) then
			BCREDITSTORE_ADMIN_ITEM:Remove()
		end
		
		local NewKey = #BRCS_ADMIN_CFG.NPCs[NPCType].Items+1

		BCREDITSTORE_ADMIN_ITEM = vgui.Create( "brcs_vgui_admin_item" )
		BCREDITSTORE_ADMIN_ITEM:SetItemData( NPCType, NewKey, true )
		BCREDITSTORE_ADMIN_ITEM.StorePanel = self
	end )

	local Pages = {}
	local LayoutWidth = BRCS_SWIDTH-((83*BRCS_SHEIGHT_SCALE)*2)
	local Spacing = 15
	local function CreatePage( catName )
		local ScrollPanel = vgui.Create( "DScrollPanel", TopColsheet )
		ScrollPanel:Dock( FILL )
		ScrollPanel:DockMargin( 0, 10, 0, 0 )

		Pages[catName] = vgui.Create( "DIconLayout", ScrollPanel )
		Pages[catName]:Dock( FILL )
		Pages[catName]:SetSpaceX( Spacing )
		Pages[catName]:SetSpaceY( Spacing )

		local icon = false
		if( BRCS_ADMIN_CFG.Categories[catName] ) then
			icon = BRICKSCREDITSTORE.GetImage( BRCS_ADMIN_CFG.Categories[catName] )
		end

		if( not icon ) then
			icon = Material( "materials/brickscreditstore/other.png" )
		end

		TopColsheet:AddSheet( catName, ScrollPanel, icon )
	end

	for k, v in pairs( BRCS_ADMIN_CFG.NPCs[NPCType].Items ) do
		local catName = v.Category
		if( not catName or not BRCS_ADMIN_CFG.Categories[catName] ) then
			catName = "Other"
		end

		if( not IsValid( Pages[catName] ) ) then
			CreatePage( catName )
		end

		local ItemCount = 5
		local ItemSize = (LayoutWidth-((ItemCount-1)*Spacing))/ItemCount

		local ItemEntry = Pages[catName]:Add( "DPanel" )
		ItemEntry:SetSize( ItemSize, ItemSize )
		local Tall = 50
		local SecondaryC = BRICKSCREDITSTORE.LUACONFIG.Themes.Secondary
		ItemEntry.Paint = function( self2, w, h )
			draw.RoundedBox( 15, 0, 0, w, h, SecondaryC )
			draw.RoundedBoxEx( 15, 0, h-Tall, w, Tall, Color( SecondaryC.r*1.25, SecondaryC.g*1.25, SecondaryC.b*1.25, 255 ), false, false, true, true )

			draw.SimpleText( v.Name, "BRCS_MP_26", 20, h-(Tall/2), Color( 255, 255, 255 ), 0, TEXT_ALIGN_CENTER )
			if( not v.GroupType or not BRCS_ADMIN_CFG.Groups[v.GroupType] or BRCS_ADMIN_CFG.Groups[v.GroupType][BRICKSCREDITSTORE.GetAdminGroup( LocalPlayer() )] ) then
				draw.SimpleText( BRICKSCREDITSTORE.FormatCurrency( (v.Price or 0), BRCS_ADMIN_CFG.NPCs[NPCType].currency, true ), "BRCS_MP_16", w-20, h-(Tall/2), Color( 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
			else
				draw.SimpleText( v.GroupType .. " ONLY", "BRCS_MP_16", w-20, h-(Tall/2), Color( 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
			end
		end

		if( v.model ) then
			local ItemEntryIcon = vgui.Create( "DModelPanel", ItemEntry )
            ItemEntryIcon:Dock( FILL )
            ItemEntryIcon:DockMargin( 0, 0, 0, Tall )
            ItemEntryIcon:SetModel( v.model )		
            if( IsValid( ItemEntryIcon.Entity ) ) then
                local mn, mx = ItemEntryIcon.Entity:GetRenderBounds()
                local size = 0
                size = math.max( size, math.abs( mn.x ) + math.abs( mx.x ) )
                size = math.max( size, math.abs( mn.y ) + math.abs( mx.y ) )
                size = math.max( size, math.abs( mn.z ) + math.abs( mx.z ) )

                ItemEntryIcon:SetFOV( 45 )
                ItemEntryIcon:SetCamPos( Vector( size, size, size ) )
                ItemEntryIcon:SetLookAt( ( mn + mx ) * 0.5 )
                function ItemEntryIcon:LayoutEntity( Entity ) return end
			end
		elseif( v.icon ) then
			local ItemEntryIcon = vgui.Create( "DPanel", ItemEntry )
            ItemEntryIcon:Dock( FILL )
			ItemEntryIcon:DockMargin( 0, 0, 0, Tall )
			local IconMat = BRICKSCREDITSTORE.GetImage( v.icon )
			ItemEntryIcon.Paint = function( self2, w, h )
				surface.SetDrawColor( 255, 255, 255 )
				surface.SetMaterial( IconMat )
				local Size = h*0.65
				surface.DrawTexturedRect( (w/2)-(Size/2), (h/2)-(Size/2), Size, Size )
			end
		end

		local ItemEntryCover = vgui.Create( "DPanel", ItemEntry )
		ItemEntryCover:Dock( FILL )
		ItemEntryCover.Paint = function( self2, w, h ) 
			--if( not ItemEntryCover.XPos or not ItemEntryCover.YPos ) then
				local X, Y = self2:LocalToScreen( 0, 0 )
				ItemEntryCover.XPos = X
				ItemEntryCover.YPos = Y
			--end

			if( not ItemEntryCover.Width or not ItemEntryCover.Height ) then
				ItemEntryCover.Width = w
				ItemEntryCover.Height = h
			end
		end
		ItemEntryCover.OnCursorEntered = function( self2 )
			if( IsValid( self2.PopUp ) ) then return end

			if( timer.Exists( tostring( self2 ) .. "_BRCS_TIMER" ) ) then return end

			timer.Create( tostring( self2 ) .. "_BRCS_TIMER", 0.02, 1, function()
				if( IsValid( self2.PopUp ) or not IsValid( self2 ) or not self2:IsHovered() ) then return end

				self2.PopUp = vgui.Create( "brcs_vgui_popupmenu" )
				self2.PopUp:SetPopupParent( self2, self2.XPos, self2.YPos, self2.Width, self2.Height )
				self2.PopUp:AddOption( "Edit", function() 
					if( IsValid( BCREDITSTORE_ADMIN_ITEM ) ) then
						BCREDITSTORE_ADMIN_ITEM:Remove()
					end
				
					BCREDITSTORE_ADMIN_ITEM = vgui.Create( "brcs_vgui_admin_item" )
					BCREDITSTORE_ADMIN_ITEM:SetItemData( NPCType, k )
					BCREDITSTORE_ADMIN_ITEM.StorePanel = self
				end )
				self2.PopUp:SetPos( self2.XPos+ItemSize-5, (self2.YPos+(ItemSize/2))-(self2.PopUp:GetTall()/2) )
			end )
		end
		ItemEntryCover.OnCursorExited = function( self2 )
			if( timer.Exists( tostring( self2 ) .. "_BRCS_TIMER" ) ) then 
				timer.Remove( tostring( self2 ) .. "_BRCS_TIMER" )
			end
		end
	end

	if( not IsValid( Pages["Other"] ) ) then
		CreatePage( "Other" )
	end
	
	for k, v in pairs( Pages ) do
		if( IsValid( v ) ) then
			v:SizeToContents()
		end
	end
end

function PANEL:Paint( w, h )
end

vgui.Register( "brcs_vgui_admin_npc", PANEL, "DPanel" )

-- Store settings --
local PANEL = {}

function PANEL:Init()
	self:SetSize( ScrW(), ScrH() )
	self:SetPos( 0, 0 )
	self:MakePopup()
	self:SetTitle( "" )
	self:ShowCloseButton( false )
	self:SetDraggable( false )

	self.MenuBack = vgui.Create( "DPanel", self )
	self.MenuBack:SetSize( 400, ((83*BRCS_SHEIGHT_SCALE)*2)+20 )
	self.MenuBack:Center()
	self.MenuBack:SetAlpha( 0 )
	self.MenuBack:AlphaTo( 255, 0.05, 0 )
	self.MenuBack.Paint = function( self2, w, h )
		local x, y = self2:LocalToScreen( 0, 0 )
		
		BSHADOWS.BeginShadow()
		draw.RoundedBox( 5, x, y, w, h, BRICKSCREDITSTORE.LUACONFIG.Themes.Primary )	
		BSHADOWS.EndShadow(2, 2, 1, 255, 0, 0, false )

		draw.SimpleText( self.npcType or "ERROR STORE", "BRCS_MP_22", w/2, (83*BRCS_SHEIGHT_SCALE)+10, BRICKSCREDITSTORE.LUACONFIG.Themes.White, 1, 1 )
	end

	self.CloseButton = vgui.Create( "DButton", self.MenuBack )
	local size = 20
	self.CloseButton:SetSize( size, size )
	self.CloseButton:SetPos( self.MenuBack:GetWide()-83*BRCS_SHEIGHT_SCALE-size, 83*BRCS_SHEIGHT_SCALE )
	self.CloseButton:SetText( "" )
	local CloseMat = Material( "materials/brickscreditstore/close.png", "noclamp smooth" )
	self.CloseButton.Paint = function( self2, w, h )
		if( self2:IsHovered() and !self2:IsDown() ) then
			surface.SetDrawColor( 52*1.35, 55*1.35, 76*1.35 )
		elseif( self2:IsDown() || self2.m_bSelected ) then
			surface.SetDrawColor( BRICKSCREDITSTORE.LUACONFIG.Themes.Accent )
		else
			surface.SetDrawColor( 52, 55, 76 )
		end

		surface.SetMaterial( CloseMat )
		surface.DrawTexturedRect( 0, 0, w, h )
	end
	self.CloseButton.DoClick = function()
		if( IsValid( self.StorePanel ) ) then
			self.StorePanel:RefreshStore()
		end

		self:Remove()
	end
end

function PANEL:SetNPCType( npcType )
	if( not BRCS_ADMIN_CFG.NPCs[npcType] ) then return end

	local NPC = BRCS_ADMIN_CFG.NPCs[npcType]

	self.npcType = npcType

	local ChoiceBack = vgui.Create( "DScrollPanel", self.MenuBack )
	ChoiceBack:Dock( FILL )
	ChoiceBack:DockMargin( 10, ((83*BRCS_SHEIGHT_SCALE)*2)+20, 10, 10 )
	ChoiceBack.Paint = function( self2, w, h ) end

	local function CreateButton( label, IconMat, doClick, sColor )
		self.MenuBack:SetTall( self.MenuBack:GetTall()+40+10 )
		self.MenuBack:Center()

		local ChoiceEntry = vgui.Create( "DButton", ChoiceBack )
		ChoiceEntry:Dock( TOP )
		ChoiceEntry:SetTall( 40 )
		ChoiceEntry:SetText( "" )
		ChoiceEntry:DockMargin( 0, 0, 0, 10 )
		local IconSize = ChoiceEntry:GetTall()*0.5
		local Hover = Color( 0, 0, 0, 25 )
		local Down = Color( 0, 0, 0, 50 )
		local LabelHover = Color( 101*1.35, 107*1.35, 145*1.35 )
		local TextNorm = Color( 101, 107, 145 )
		ChoiceEntry.Paint = function( self2, w, h )
			draw.RoundedBox( 3, 0, 0, w, h, sColor or BRICKSCREDITSTORE.LUACONFIG.Themes.Secondary )
			
			if( not sColor ) then
				if( self2:IsHovered() and !self2:IsDown() ) then
					surface.SetDrawColor( 52*1.35, 55*1.35, 76*1.35 )
					draw.SimpleText( label, "BRCS_MP_22", w/2, h/2, LabelHover, 1, 1 )
				elseif( self2:IsDown() ) then
					surface.SetDrawColor( BRICKSCREDITSTORE.LUACONFIG.Themes.Accent )
					draw.SimpleText( label, "BRCS_MP_22", w/2, h/2, BRICKSCREDITSTORE.LUACONFIG.Themes.White, 1, 1 )
				else
					surface.SetDrawColor( 52, 55, 76 )
					draw.SimpleText( label, "BRCS_MP_22", w/2, h/2, TextNorm, 1, 1 )
				end
			else
				if( self2:IsHovered() and !self2:IsDown() ) then
					draw.RoundedBox( 3, 0, 0, w, h, Hover )
				elseif( self2:IsDown() ) then
					draw.RoundedBox( 3, 0, 0, w, h, Down )
				end

				surface.SetDrawColor( BRICKSCREDITSTORE.LUACONFIG.Themes.White )
				draw.SimpleText( label, "BRCS_MP_22", w/2, h/2, BRICKSCREDITSTORE.LUACONFIG.Themes.White, 1, 1 )
			end
			
			if( not IconMat ) then return end

			surface.SetMaterial( IconMat )
			surface.DrawTexturedRect( 10, (h/2)-(IconSize/2), IconSize, IconSize )
		end
		ChoiceEntry.DoClick = doClick
	end

	CreateButton( "Change Name", Material( "materials/brickscreditstore/name.png", "noclamp smooth" ), function() 
		BRCS_StringRequest( "What should the new name be?", "", npcType, "Confirm", function( text )
			BRCS_ADMIN_CFG.NPCs[text] = NPC
			NPCType = text
			self.npcType = text
			BRCS_ADMIN_CFG.NPCs[npcType] = nil
			BRCS_ADMIN_CFG_CHANGED = true
		end, "Cancel", function() end )
	end )
	CreateButton( "Change Icon", Material( "materials/brickscreditstore/icon.png", "noclamp smooth" ), function() 
		BRCS_StringRequest( "What should the new icon URL be?", "", NPC.icon or "", "Confirm", function( text ) 
			BRCS_ADMIN_CFG.NPCs[npcType].icon = text
			BRCS_ADMIN_CFG_CHANGED = true
		end, "Cancel", function() end )
	end )
	CreateButton( "Change NPC Model", Material( "materials/brickscreditstore/model.png", "noclamp smooth" ), function() 
		BRCS_StringRequest( "What should the new NPC model be?", "", NPC.model or "", "Confirm", function( text ) 
			BRCS_ADMIN_CFG.NPCs[npcType].model = text
			BRCS_ADMIN_CFG_CHANGED = true
		end, "Cancel", function() end )
	end )
	local Currencies = {}
	for k, v in pairs( BRICKSCREDITSTORE.CURRENCYTYPES ) do
		table.insert( Currencies, k )
	end
	CreateButton( "Change Currency", Material( "materials/brickscreditstore/donate.png", "noclamp smooth" ), function() 
		BRCS_ComboRequest( "What should the store's currency be?", "", Currencies, "Confirm", function( key, value ) 
			BRCS_ADMIN_CFG.NPCs[npcType].currency = value
			BRCS_ADMIN_CFG_CHANGED = true
		end, "Cancel", function() end, BRCS_ADMIN_CFG.NPCs[npcType].currency )
	end )
	CreateButton( "Change Command", Material( "materials/brickscreditstore/command.png", "noclamp smooth" ), function() 
		BRCS_StringRequest( "What should the new command be? (blank for none)", "", NPC.CMD or "/examplestore", "Confirm", function( text ) 
			if( string.Replace( text, " ", "" ) != "" ) then
				BRCS_ADMIN_CFG.NPCs[npcType].CMD = text
			else
				BRCS_ADMIN_CFG.NPCs[npcType].CMD = nil
			end
			BRCS_ADMIN_CFG_CHANGED = true
		end, "Cancel", function() end )
	end )
	CreateButton( "Change Keybind", Material( "materials/brickscreditstore/keybind.png", "noclamp smooth" ), function() 
		BRCS_ComboRequest( "What keybind should open the store?", "", BRICKSCREDITSTORE.KeyBinds, "Confirm", function( key, value ) 
			if( value != "None" ) then
				BRCS_ADMIN_CFG.NPCs[npcType].Bind = key
			else
				BRCS_ADMIN_CFG.NPCs[npcType].Bind = nil
			end
			BRCS_ADMIN_CFG_CHANGED = true
		end, "Cancel", function() end, BRCS_ADMIN_CFG.NPCs[npcType].Bind or "None" )
	end )
	CreateButton( "Delete", false, function() 
		BRCS_QueryRequest( "Are you sure you want to delete this store?", "", "Yes", function()
			BRCS_ADMIN_CFG.NPCs[npcType] = nil
			BRCS_ADMIN_CFG_CHANGED = true

			if( IsValid( self.StorePanel ) and IsValid( self.StorePanel.MenuPanel ) ) then
				self.StorePanel.MenuPanel:ShowChoices()
			end

			self:Remove()
		end, "No", function() end )
	end, BRICKSCREDITSTORE.LUACONFIG.Themes.Red )
end

function PANEL:Paint( w, h )
end

vgui.Register( "brcs_vgui_admin_settings", PANEL, "DFrame" )

-- Item settings --
local PANEL = {}

function PANEL:Init()
	self:SetSize( ScrW(), ScrH() )
	self:SetPos( 0, 0 )
	self:MakePopup()
	self:SetTitle( "" )
	self:ShowCloseButton( false )
	self:SetDraggable( false )

	self.MenuBack = vgui.Create( "DPanel", self )
	self.MenuBack:SetSize( 400, ((83*BRCS_SHEIGHT_SCALE)*2)+20 )
	self.MenuBack:Center()
	self.MenuBack:SetAlpha( 0 )
	self.MenuBack:AlphaTo( 255, 0.05, 0 )
	self.MenuBack.Paint = function( self2, w, h )
		local x, y = self2:LocalToScreen( 0, 0 )
		
		BSHADOWS.BeginShadow()
		draw.RoundedBox( 5, x, y, w, h, BRICKSCREDITSTORE.LUACONFIG.Themes.Primary )	
		BSHADOWS.EndShadow(2, 2, 1, 255, 0, 0, false )

		if( not self.npcType or not self.itemKey or not BRCS_ADMIN_CFG.NPCs[self.npcType] or not BRCS_ADMIN_CFG.NPCs[self.npcType].Items or not BRCS_ADMIN_CFG.NPCs[self.npcType].Items[self.itemKey] ) then
			draw.SimpleText( "ERROR ITEM", "BRCS_MP_22", w/2, (83*BRCS_SHEIGHT_SCALE)+10, BRICKSCREDITSTORE.LUACONFIG.Themes.White, 1, 1 )
		else
			draw.SimpleText( BRCS_ADMIN_CFG.NPCs[self.npcType].Items[self.itemKey].Name or "New Item", "BRCS_MP_22", w/2, (83*BRCS_SHEIGHT_SCALE)+10, BRICKSCREDITSTORE.LUACONFIG.Themes.White, 1, 1 )
		end
	end

	self.CloseButton = vgui.Create( "DButton", self.MenuBack )
	local size = 20
	self.CloseButton:SetSize( size, size )
	self.CloseButton:SetPos( self.MenuBack:GetWide()-83*BRCS_SHEIGHT_SCALE-size, 83*BRCS_SHEIGHT_SCALE )
	self.CloseButton:SetText( "" )
	local CloseMat = Material( "materials/brickscreditstore/close.png", "noclamp smooth" )
	self.CloseButton.Paint = function( self2, w, h )
		if( self2:IsHovered() and !self2:IsDown() ) then
			surface.SetDrawColor( 52*1.35, 55*1.35, 76*1.35 )
		elseif( self2:IsDown() || self2.m_bSelected ) then
			surface.SetDrawColor( BRICKSCREDITSTORE.LUACONFIG.Themes.Accent )
		else
			surface.SetDrawColor( 52, 55, 76 )
		end

		surface.SetMaterial( CloseMat )
		surface.DrawTexturedRect( 0, 0, w, h )
	end
	self.CloseButton.DoClick = function()
		if( self.newItem and BRCS_ADMIN_CFG.NPCs[self.npcType or ""] and BRCS_ADMIN_CFG.NPCs[self.npcType or ""].Items and BRCS_ADMIN_CFG.NPCs[self.npcType or ""].Items[self.itemKey or ""] ) then
			BRCS_ADMIN_CFG.NPCs[self.npcType].Items[self.itemKey] = nil
		end

		if( IsValid( self.StorePanel ) ) then
			self.StorePanel:RefreshStore()
		end

		self:Remove()
	end
end

function PANEL:SetItemData( npcType, itemKey, newItem )
	if( not newItem and (not BRCS_ADMIN_CFG.NPCs[npcType] or not BRCS_ADMIN_CFG.NPCs[npcType].Items or not BRCS_ADMIN_CFG.NPCs[npcType].Items[itemKey]) ) then return end

	local Item = BRCS_ADMIN_CFG.NPCs[npcType].Items[itemKey]
	if( newItem ) then
		Item = {}
		BRCS_ADMIN_CFG.NPCs[npcType].Items[itemKey] = {}
	end

	self.npcType = npcType
	self.itemKey = itemKey
	self.newItem = newItem

	local ChoiceBack = vgui.Create( "DScrollPanel", self.MenuBack )
	ChoiceBack:Dock( FILL )
	ChoiceBack:DockMargin( 10, ((83*BRCS_SHEIGHT_SCALE)*2)+20, 10, 10 )
	ChoiceBack.Paint = function( self2, w, h ) end

	local function CreateButton( label, IconMat, doClick, sColor, completed )
		self.MenuBack:SetTall( self.MenuBack:GetTall()+40+10 )
		self.MenuBack:Center()

		local ChoiceEntry = vgui.Create( "DButton", ChoiceBack )
		ChoiceEntry:SetText( "" )
		ChoiceEntry:Dock( TOP )
		ChoiceEntry:DockMargin( 0, 0, 0, 10 )
		ChoiceEntry:SetTall( 40 )
		local IconSize = ChoiceEntry:GetTall()*0.5
		local Hover = Color( 0, 0, 0, 25 )
		local Down = Color( 0, 0, 0, 50 )
		local LabelHover = Color( 101*1.35, 107*1.35, 145*1.35 )
		local TextNorm = Color( 101, 107, 145 )
		ChoiceEntry.Paint = function( self2, w, h )
			draw.RoundedBox( 3, 0, 0, w, h, sColor or BRICKSCREDITSTORE.LUACONFIG.Themes.Secondary )
			
			if( not sColor ) then
				if( self2:IsHovered() and !self2:IsDown() and not (newItem and completed) ) then
					surface.SetDrawColor( 52*1.35, 55*1.35, 76*1.35 )
					draw.SimpleText( label, "BRCS_MP_22", w/2, h/2, LabelHover, 1, 1 )
				elseif( self2:IsDown() or (newItem and completed) ) then
					surface.SetDrawColor( BRICKSCREDITSTORE.LUACONFIG.Themes.Accent )
					draw.SimpleText( label, "BRCS_MP_22", w/2, h/2, BRICKSCREDITSTORE.LUACONFIG.Themes.White, 1, 1 )
				else
					surface.SetDrawColor( 52, 55, 76 )
					draw.SimpleText( label, "BRCS_MP_22", w/2, h/2, TextNorm, 1, 1 )
				end
			else
				if( self2:IsHovered() and !self2:IsDown() ) then
					draw.RoundedBox( 3, 0, 0, w, h, Hover )
				elseif( self2:IsDown() ) then
					draw.RoundedBox( 3, 0, 0, w, h, Down )
				end

				surface.SetDrawColor( BRICKSCREDITSTORE.LUACONFIG.Themes.White )
				draw.SimpleText( label, "BRCS_MP_22", w/2, h/2, BRICKSCREDITSTORE.LUACONFIG.Themes.White, 1, 1 )
			end
			
			if( not IconMat ) then return end

			surface.SetMaterial( IconMat )
			surface.DrawTexturedRect( 10, (h/2)-(IconSize/2), IconSize, IconSize )
		end
		ChoiceEntry.DoClick = doClick
	end

	function self:LoadTypePage()
		ChoiceBack:Clear()
		self.MenuBack:SetTall( ((83*BRCS_SHEIGHT_SCALE)*2)+20+100 )
		self.MenuBack:Center()

		function self:RefreshTypePage()
			ChoiceBack:Clear()
			self.MenuBack:SetTall( ((83*BRCS_SHEIGHT_SCALE)*2)+20+25+10 )
			self.MenuBack:Center()

			local DComboBox = vgui.Create( "DComboBox", ChoiceBack )
			DComboBox:Dock( TOP )
			DComboBox:DockMargin( 0, 0, 0, 10 )
			DComboBox:SetTall( 25 )
			DComboBox:SetValue( "Select option" )
			for k, v in pairs( BRICKSCREDITSTORE.ITEMTYPES ) do
				local index = DComboBox:AddChoice( (v.Name or k), k )
		
				if( Item.Type == k ) then
					DComboBox:ChooseOption( (v.Name or k), index )
				end
			end
			DComboBox.OnSelect = function( self2, index, val, data )
				Item.Type = data
				BRCS_ADMIN_CFG.NPCs[npcType].Items[itemKey].Type = data
				BRCS_ADMIN_CFG.NPCs[npcType].Items[itemKey].TypeInfo = {}

				BRCS_ADMIN_CFG_CHANGED = true
				self:RefreshTypePage()
			end
			DComboBox.Width = self.MenuBack:GetWide()-20
			DComboBox.Height = DComboBox:GetTall()
			local MBX, MBY = self.MenuBack:GetPos()
			DComboBox.XPos = MBX+10
			DComboBox.YPos = MBY+((83*BRCS_SHEIGHT_SCALE)*2)+20
			DComboBox.OnCursorEntered = function( self2 )
				if( IsValid( self2.PopUp ) ) then return end
				if( self2:IsMenuOpen() ) then return end

				if( timer.Exists( tostring( self2 ) .. "_BRCS_TIMER" ) ) then return end

				timer.Create( tostring( self2 ) .. "_BRCS_TIMER", 0.02, 1, function()
					if( IsValid( self2.PopUp ) or not IsValid( self2 ) or not self2:IsHovered() ) then return end

					self2.PopUp = vgui.Create( "brcs_vgui_popupmenu" )
					self2.PopUp:SetPopupParent( self2, self2.XPos, self2.YPos, self2.Width, self2.Height, true )
					self2.PopUp:SetDescription( "Item Type" )
					local YPos = self2.YPos+(self2.Height/2)
					self2.PopUp:SetPos( self2.XPos+self2.Width-5, YPos-(self2.PopUp:GetTall()/2) )
				end )
			end
			DComboBox.OnCursorExited = function( self2 )
				if( timer.Exists( tostring( self2 ) .. "_BRCS_TIMER" ) ) then 
					timer.Remove( tostring( self2 ) .. "_BRCS_TIMER" )
				end
			end

			local Count = 0
			local EntryPanels = {}
			if( BRICKSCREDITSTORE.ITEMTYPES[Item.Type] and BRICKSCREDITSTORE.ITEMTYPES[Item.Type].ReqInfo ) then
				for k, v in ipairs( BRICKSCREDITSTORE.ITEMTYPES[Item.Type].ReqInfo ) do
					Count = Count+1
					local EntryPanel
					if( v[1] == "String" ) then
						EntryPanel = vgui.Create( "DTextEntry", ChoiceBack )
						EntryPanel:SetText( (Item.TypeInfo or {})[k] or "" )
					elseif( v[1] == "Int" ) then
						EntryPanel = vgui.Create( "DNumberWang", ChoiceBack )
						EntryPanel:SetMax( 9999999999999 )
						EntryPanel:SetValue( (Item.TypeInfo or {})[k] or 0 )
					elseif( v[1] == "Combo" ) then
						EntryPanel = vgui.Create( "DComboBox", ChoiceBack )
						EntryPanel:SetValue( "Select option" )
						local optionTable, displayKey = BRICKSCREDITSTORE.GetTable( v[3] or {} )
						for key, val in pairs( optionTable ) do
							local index
							if( displayKey ) then
								EntryPanel:AddChoice( key, val )
							else
								EntryPanel:AddChoice( val, val )
							end

							if( (Item.TypeInfo or {})[k] == key or (Item.TypeInfo or {})[k] == val ) then
								if( displayKey ) then
									EntryPanel:ChooseOption( key, index )
								else
									EntryPanel:ChooseOption( val, index )
								end
							end
						end
					end
					
					if( not IsValid( EntryPanel ) ) then continue end

					EntryPanel:Dock( TOP )
					EntryPanel:DockMargin( 0, 0, 0, 10 )
					EntryPanel:SetTall( 25 )
					EntryPanel.Width = self.MenuBack:GetWide()-20
					EntryPanel.Height = EntryPanel:GetTall()
					local MBX, MBY = self.MenuBack:GetPos()
					EntryPanel.XPos = MBX+10
					EntryPanel.YPos = MBY+((83*BRCS_SHEIGHT_SCALE)*2)+20+25+10+((k-1)*35)
					EntryPanel.OnCursorEntered = function( self2 )
						if( IsValid( self2.PopUp ) ) then return end
						if( v[1] == "Combo" and self2:IsMenuOpen() ) then return end
		
						if( timer.Exists( tostring( self2 ) .. "_BRCS_TIMER" ) ) then return end
		
						timer.Create( tostring( self2 ) .. "_BRCS_TIMER", 0.02, 1, function()
							if( IsValid( self2.PopUp ) or not IsValid( self2 ) or not self2:IsHovered() ) then return end
		
							self2.PopUp = vgui.Create( "brcs_vgui_popupmenu" )
							self2.PopUp:SetPopupParent( self2, self2.XPos, self2.YPos, self2.Width, self2.Height, true )
							self2.PopUp:SetDescription( v[2] or "INVALID" )
							local YPos = self2.YPos+(self2.Height/2)
							self2.PopUp:SetPos( self2.XPos+self2.Width-5, YPos-(self2.PopUp:GetTall()/2) )
						end )
					end
					EntryPanel.OnCursorExited = function( self2 )
						if( timer.Exists( tostring( self2 ) .. "_BRCS_TIMER" ) ) then 
							timer.Remove( tostring( self2 ) .. "_BRCS_TIMER" )
						end
					end

					EntryPanels[k] = EntryPanel
				end
			end

			self.MenuBack:SetTall( self.MenuBack:GetTall()+(Count*35) )

			CreateButton( "Save", false, function() 
				if( not DComboBox:GetOptionData( DComboBox:GetSelectedID() ) ) then 
					notification.AddLegacy( "Select a item type!", 1, 5 )
					return 
				end

				BRCS_ADMIN_CFG.NPCs[npcType].Items[itemKey].TypeInfo = {}
				for k, v in ipairs( BRICKSCREDITSTORE.ITEMTYPES[Item.Type].ReqInfo ) do
					local ValuePanel = EntryPanels[k]
					if( not EntryPanels[k] ) then
						notification.AddLegacy( "Missing value!", 1, 5 )
						return
					end

					if( v[1] == "String" ) then
						if( string.Replace( ValuePanel:GetText(), " ", "" ) == "" ) then
							notification.AddLegacy( "Missing value!", 1, 5 )
							return
						end

						BRCS_ADMIN_CFG.NPCs[npcType].Items[itemKey].TypeInfo[k] = ValuePanel:GetText()
					elseif( v[1] == "Int" ) then
						local Value = tonumber( ValuePanel:GetValue() )
						if( not isnumber( Value ) ) then
							notification.AddLegacy( "Missing value!", 1, 5 )
							return
						end

						BRCS_ADMIN_CFG.NPCs[npcType].Items[itemKey].TypeInfo[k] = Value
					elseif( v[1] == "Combo" ) then
						if( not ValuePanel:GetOptionData( ValuePanel:GetSelectedID() ) ) then 
							notification.AddLegacy( "Select an option!", 1, 5 )
							return 
						end

						BRCS_ADMIN_CFG.NPCs[npcType].Items[itemKey].TypeInfo[k] = ValuePanel:GetOptionData( ValuePanel:GetSelectedID() )
					end
				end

				self:RefreshChoices()
			end, BRICKSCREDITSTORE.LUACONFIG.Themes.Red )

			local MBX, MBY = self.MenuBack:GetPos()
			DComboBox.XPos = MBX+10
			DComboBox.YPos = MBY+((83*BRCS_SHEIGHT_SCALE)*2)+20

			for k, v in pairs( EntryPanels ) do
				if( IsValid( v ) ) then
					v.XPos = MBX+10
					v.YPos = MBY+((83*BRCS_SHEIGHT_SCALE)*2)+20+25+10+((k-1)*35)
				end
			end
		end
		self:RefreshTypePage()
	end

	function self:RefreshChoices()
		ChoiceBack:Clear()
		self.MenuBack:SetTall( ((83*BRCS_SHEIGHT_SCALE)*2)+20 )
		self.MenuBack:Center()
		
		local StartParam = "Change"
		if( newItem ) then
			StartParam = "Enter"
		end

		CreateButton( StartParam .. " Name", Material( "materials/brickscreditstore/name.png", "noclamp smooth" ), function() 
			BRCS_StringRequest( "What should the new name be?", "", Item.Name, "Confirm", function( text ) 
				if( not BRCS_ADMIN_CFG.NPCs[npcType] or not BRCS_ADMIN_CFG.NPCs[npcType].Items or not BRCS_ADMIN_CFG.NPCs[npcType].Items[itemKey] ) then return end

				BRCS_ADMIN_CFG.NPCs[npcType].Items[itemKey].Name = text

				BRCS_ADMIN_CFG_CHANGED = true
				self:RefreshChoices()
			end, "Cancel", function() end )
		end, false, (BRCS_ADMIN_CFG.NPCs[npcType].Items[itemKey].Name and true) )

		CreateButton( StartParam .. " Price", Material( "materials/brickscreditstore/donate.png", "noclamp smooth" ), function() 
			BRCS_StringRequest( "What should the new price be?", "", Item.Price, "Confirm", function( text ) 
				if( not BRCS_ADMIN_CFG.NPCs[npcType] or not BRCS_ADMIN_CFG.NPCs[npcType].Items or not BRCS_ADMIN_CFG.NPCs[npcType].Items[itemKey] ) then return end

				text = tonumber( text )

				if( not isnumber( text ) or text <= 0 ) then
					notification.AddLegacy( "The price must be a number & greater than 0!", 1, 5 )
					return
				end
				
				BRCS_ADMIN_CFG.NPCs[npcType].Items[itemKey].Price = text

				BRCS_ADMIN_CFG_CHANGED = true
				self:RefreshChoices()
			end, "Cancel", function() end )
		end, false, (BRCS_ADMIN_CFG.NPCs[npcType].Items[itemKey].Price and true) )

		CreateButton( StartParam .. " Description", Material( "materials/brickscreditstore/description.png", "noclamp smooth" ), function() 
			BRCS_StringRequest( "What should the new description be?", "", Item.Description, "Confirm", function( text ) 
				if( not BRCS_ADMIN_CFG.NPCs[npcType] or not BRCS_ADMIN_CFG.NPCs[npcType].Items or not BRCS_ADMIN_CFG.NPCs[npcType].Items[itemKey] ) then return end

				BRCS_ADMIN_CFG.NPCs[npcType].Items[itemKey].Description = text

				BRCS_ADMIN_CFG_CHANGED = true
				self:RefreshChoices()
			end, "Cancel", function() end )
		end, false, (BRCS_ADMIN_CFG.NPCs[npcType].Items[itemKey].Description and true) )

		CreateButton( StartParam .. " Icon/Model", Material( "materials/brickscreditstore/icon.png", "noclamp smooth" ), function() 
			BRCS_StringRequest( "What should the new icon URL/model be?", "", Item.model or Item.icon or "", "Confirm", function( text ) 
				if( not BRCS_ADMIN_CFG.NPCs[npcType] or not BRCS_ADMIN_CFG.NPCs[npcType].Items or not BRCS_ADMIN_CFG.NPCs[npcType].Items[itemKey] ) then return end

				if( string.StartWith( text, "models/" ) ) then
					BRCS_ADMIN_CFG.NPCs[npcType].Items[itemKey].model = text
					BRCS_ADMIN_CFG.NPCs[npcType].Items[itemKey].icon = nil
				else
					BRCS_ADMIN_CFG.NPCs[npcType].Items[itemKey].icon = text
					BRCS_ADMIN_CFG.NPCs[npcType].Items[itemKey].model = nil
				end
				BRCS_ADMIN_CFG_CHANGED = true
				self:RefreshChoices()
			end, "Cancel", function() end )
		end, false, (BRCS_ADMIN_CFG.NPCs[npcType].Items[itemKey].model or BRCS_ADMIN_CFG.NPCs[npcType].Items[itemKey].icon) )

		local Categories = {}
		Categories[1] = "Other"
		for k, v in pairs( BRCS_ADMIN_CFG.Categories ) do
			table.insert( Categories, k )
		end
		CreateButton( StartParam .. " Category", Material( "materials/brickscreditstore/other.png", "noclamp smooth" ), function() 
			BRCS_ComboRequest( "What should the new category be?", "", Categories, "Confirm", function( key, value ) 
				if( not BRCS_ADMIN_CFG.NPCs[npcType] or not BRCS_ADMIN_CFG.NPCs[npcType].Items or not BRCS_ADMIN_CFG.NPCs[npcType].Items[itemKey] ) then return end

				BRCS_ADMIN_CFG.NPCs[npcType].Items[itemKey].Category = value
				BRCS_ADMIN_CFG_CHANGED = true
				self:RefreshChoices()
			end, "Cancel", function() end, Item.Category or "" )
		end, false, (BRCS_ADMIN_CFG.NPCs[npcType].Items[itemKey].Category and true) )
		
		CreateButton( StartParam .. " Type Info", Material( "materials/brickscreditstore/model.png", "noclamp smooth" ), function() 
			self:LoadTypePage()
		end, false, (BRCS_ADMIN_CFG.NPCs[npcType].Items[itemKey].Type and BRCS_ADMIN_CFG.NPCs[npcType].Items[itemKey].TypeInfo) )

		CreateButton( StartParam .. " Groups", Material( "materials/brickscreditstore/groups.png", "noclamp smooth" ), function() 
			BRCS_ComboRequest( "What group of users can buy this?", "", BRICKSCREDITSTORE.GetTable( "Groups" ), "Confirm", function( key, value ) 
				if( not BRCS_ADMIN_CFG.NPCs[npcType] or not BRCS_ADMIN_CFG.NPCs[npcType].Items or not BRCS_ADMIN_CFG.NPCs[npcType].Items[itemKey] ) then return end

				BRCS_ADMIN_CFG.NPCs[npcType].Items[itemKey].GroupType = value
				BRCS_ADMIN_CFG_CHANGED = true
				self:RefreshChoices()
			end, "Cancel", function() end, Item.Category or "" )
		end, false, (BRCS_ADMIN_CFG.NPCs[npcType].Items[itemKey].GroupType and true) )

		if( not newItem ) then
			CreateButton( "Delete", false, function() 
				BRCS_QueryRequest( "Are you sure you want to delete this item?", "", "Yes", function()
					if( not BRCS_ADMIN_CFG.NPCs[npcType] or not BRCS_ADMIN_CFG.NPCs[npcType].Items or not BRCS_ADMIN_CFG.NPCs[npcType].Items[itemKey] ) then return end

					BRCS_ADMIN_CFG.NPCs[npcType].Items[itemKey] = nil
					BRCS_ADMIN_CFG_CHANGED = true

					if( IsValid( self.StorePanel ) ) then
						self.StorePanel:RefreshStore()
					end

					self:Remove()
				end, "No", function() end )
			end, BRICKSCREDITSTORE.LUACONFIG.Themes.Red )
		else
			CreateButton( "Finish", false, function() 
				if( not BRCS_ADMIN_CFG.NPCs[npcType] or not BRCS_ADMIN_CFG.NPCs[npcType].Items or not BRCS_ADMIN_CFG.NPCs[npcType].Items[itemKey] ) then return end

				local FinalItem = BRCS_ADMIN_CFG.NPCs[npcType].Items[itemKey]
				if( not FinalItem.Name or not FinalItem.Description or not FinalItem.Price or (not FinalItem.icon and not FinalItem.model) or not FinalItem.Type or not FinalItem.TypeInfo ) then
					notification.AddLegacy( "Missing information!", 1, 5 )
					return
				end

				if( IsValid( self.StorePanel ) ) then
					self.StorePanel:RefreshStore()
				end

				self:Remove()
			end, BRICKSCREDITSTORE.LUACONFIG.Themes.Green )
		end
	end
	self:RefreshChoices()
end

function PANEL:Paint( w, h )
end

vgui.Register( "brcs_vgui_admin_item", PANEL, "DFrame" )

-- Settings --
local PANEL = {}

function PANEL:Init()
	self:SetSize( ScrW(), ScrH() )
	self:SetPos( 0, 0 )
	self:MakePopup()
	self:SetTitle( "" )
	self:ShowCloseButton( false )
	self:SetDraggable( false )

	self.MenuBack = vgui.Create( "DPanel", self )
	self.MenuBack:SetSize( 400, ((83*BRCS_SHEIGHT_SCALE)*2)+20 )
	self.MenuBack:Center()
	self.MenuBack:SetAlpha( 0 )
	self.MenuBack:AlphaTo( 255, 0.05, 0 )
	self.MenuBack.Paint = function( self2, w, h )
		local x, y = self2:LocalToScreen( 0, 0 )
		
		BSHADOWS.BeginShadow()
		draw.RoundedBox( 5, x, y, w, h, BRICKSCREDITSTORE.LUACONFIG.Themes.Primary )	
		BSHADOWS.EndShadow(2, 2, 1, 255, 0, 0, false )

		draw.SimpleText( "SETTINGS", "BRCS_MP_22", w/2, (83*BRCS_SHEIGHT_SCALE)+10, BRICKSCREDITSTORE.LUACONFIG.Themes.White, 1, 1 )
	end

	self.CloseButton = vgui.Create( "DButton", self.MenuBack )
	local size = 20
	self.CloseButton:SetSize( size, size )
	self.CloseButton:SetPos( self.MenuBack:GetWide()-83*BRCS_SHEIGHT_SCALE-size, 83*BRCS_SHEIGHT_SCALE )
	self.CloseButton:SetText( "" )
	local CloseMat = Material( "materials/brickscreditstore/close.png", "noclamp smooth" )
	self.CloseButton.Paint = function( self2, w, h )
		if( self2:IsHovered() and !self2:IsDown() ) then
			surface.SetDrawColor( 52*1.35, 55*1.35, 76*1.35 )
		elseif( self2:IsDown() || self2.m_bSelected ) then
			surface.SetDrawColor( BRICKSCREDITSTORE.LUACONFIG.Themes.Accent )
		else
			surface.SetDrawColor( 52, 55, 76 )
		end

		surface.SetMaterial( CloseMat )
		surface.DrawTexturedRect( 0, 0, w, h )
	end
	self.CloseButton.DoClick = function()
		self:Remove()
	end

	local ChoiceBack = vgui.Create( "DScrollPanel", self.MenuBack )
	ChoiceBack:Dock( FILL )
	ChoiceBack:DockMargin( 10, ((83*BRCS_SHEIGHT_SCALE)*2)+20, 10, 10 )
	ChoiceBack.Paint = function( self2, w, h ) end

	local function CreateButton( label, IconMat, doClick, sColor, completed )
		self.MenuBack:SetTall( self.MenuBack:GetTall()+40+10 )
		self.MenuBack:Center()

		local ChoiceEntry = vgui.Create( "DButton", ChoiceBack )
		ChoiceEntry:SetText( "" )
		ChoiceEntry:Dock( TOP )
		ChoiceEntry:DockMargin( 0, 0, 0, 10 )
		ChoiceEntry:SetTall( 40 )
		local IconSize = ChoiceEntry:GetTall()*0.5
		local Hover = Color( 0, 0, 0, 25 )
		local Down = Color( 0, 0, 0, 50 )
		local LabelHover = Color( 101*1.35, 107*1.35, 145*1.35 )
		local TextNorm = Color( 101, 107, 145 )
		ChoiceEntry.Paint = function( self2, w, h )
			draw.RoundedBox( 3, 0, 0, w, h, sColor or BRICKSCREDITSTORE.LUACONFIG.Themes.Secondary )
			
			if( not sColor ) then
				if( self2:IsHovered() and !self2:IsDown() and not (newItem and completed) ) then
					surface.SetDrawColor( 52*1.35, 55*1.35, 76*1.35 )
					draw.SimpleText( label, "BRCS_MP_22", w/2, h/2, LabelHover, 1, 1 )
				elseif( self2:IsDown() or (newItem and completed) ) then
					surface.SetDrawColor( BRICKSCREDITSTORE.LUACONFIG.Themes.Accent )
					draw.SimpleText( label, "BRCS_MP_22", w/2, h/2, BRICKSCREDITSTORE.LUACONFIG.Themes.White, 1, 1 )
				else
					surface.SetDrawColor( 52, 55, 76 )
					draw.SimpleText( label, "BRCS_MP_22", w/2, h/2, TextNorm, 1, 1 )
				end
			else
				if( self2:IsHovered() and !self2:IsDown() ) then
					draw.RoundedBox( 3, 0, 0, w, h, Hover )
				elseif( self2:IsDown() ) then
					draw.RoundedBox( 3, 0, 0, w, h, Down )
				end

				surface.SetDrawColor( BRICKSCREDITSTORE.LUACONFIG.Themes.White )
				draw.SimpleText( label, "BRCS_MP_22", w/2, h/2, BRICKSCREDITSTORE.LUACONFIG.Themes.White, 1, 1 )
			end
			
			if( not IconMat ) then return end

			surface.SetMaterial( IconMat )
			surface.DrawTexturedRect( 10, (h/2)-(IconSize/2), IconSize, IconSize )
		end
		ChoiceEntry.DoClick = doClick
	end

	function self:ShowHomePage()
		ChoiceBack:Clear()
		self.MenuBack:SetTall( ((83*BRCS_SHEIGHT_SCALE)*2)+20 )
		self.MenuBack:Center()

		CreateButton( "Buy Groups", Material( "materials/brickscreditstore/groups.png", "noclamp smooth" ), function() 
			self:ShowGroupsPage()
		end )

		CreateButton( "Categories", Material( "materials/brickscreditstore/other.png", "noclamp smooth" ), function() 
			self:ShowCategoriesPage()
		end )
	end
	self:ShowHomePage()

	function self:ShowGroupsPage()
		ChoiceBack:Clear()
		self.MenuBack:SetTall( ((83*BRCS_SHEIGHT_SCALE)*2)+20 )
		self.MenuBack:Center()

		for k, v in pairs( BRCS_ADMIN_CFG.Groups ) do
			CreateButton( k, false, function() 
				self:ShowSinglePage( k )
			end )
		end

		CreateButton( "Add Group", Material( "materials/brickscreditstore/new.png", "noclamp smooth" ), function() 
			BRCS_StringRequest( "What is the name of the group you want to add?", "", "VIP", "Confirm", function( text ) 
				if( BRCS_ADMIN_CFG.Groups[text] ) then
					notification.AddLegacy( "This group already exists!", 1, 5 )
					return
				end

				BRCS_ADMIN_CFG.Groups[text] = {}
				self:ShowGroupsPage()
			end, "Cancel", function() end )
		end )

		CreateButton( "Back", false, function() 
			self:ShowHomePage()
		end, BRICKSCREDITSTORE.LUACONFIG.Themes.Green )
	end

	function self:ShowSinglePage( groupKey )
		if( not BRCS_ADMIN_CFG.Groups[groupKey] ) then return end

		ChoiceBack:Clear()
		self.MenuBack:SetTall( ((83*BRCS_SHEIGHT_SCALE)*2)+20 )
		self.MenuBack:Center()

		local GroupString = "Ranks: "
		for k, v in pairs( BRCS_ADMIN_CFG.Groups[groupKey] ) do
			if( GroupString != "Ranks: " ) then
				GroupString = GroupString .. ", " .. k
			else
				GroupString = GroupString .. k
			end
		end

		CreateButton( GroupString, Material( "materials/brickscreditstore/groups.png", "noclamp smooth" ), function() 

		end )

		CreateButton( "Add Rank", Material( "materials/brickscreditstore/new.png", "noclamp smooth" ), function() 
			BRCS_StringRequest( "What is the name of the rank you want to add?", "", "vip", "Confirm", function( text ) 
				if( BRCS_ADMIN_CFG.Groups[groupKey][text] ) then
					notification.AddLegacy( "This rank is already in the group!", 1, 5 )
					return
				end

				BRCS_ADMIN_CFG.Groups[groupKey][text] = true
				BRCS_ADMIN_CFG_CHANGED = true
				self:ShowSinglePage( groupKey )
			end, "Cancel", function() end )
		end )

		CreateButton( "Remove Rank", Material( "materials/brickscreditstore/remove.png", "noclamp smooth" ), function() 
			local Ranks = {}
			for k, v in pairs( BRCS_ADMIN_CFG.Groups[groupKey] ) do
				Ranks[k] = k
			end

			BRCS_ComboRequest( "What rank do you want to remove?", "", Ranks, "Confirm", function( key ) 
				BRCS_ADMIN_CFG.Groups[groupKey][key] = nil
				BRCS_ADMIN_CFG_CHANGED = true
				self:ShowSinglePage( groupKey )
			end, "Cancel", function() end )
		end )

		CreateButton( "Remove Group", false, function() 
			BRCS_QueryRequest( "Are you sure you want to remove this group?", "", "Yes", function() 
				BRCS_ADMIN_CFG.Groups[groupKey] = nil
				BRCS_ADMIN_CFG_CHANGED = true
				self:ShowGroupsPage()
			end, "No", function() end )
		end, BRICKSCREDITSTORE.LUACONFIG.Themes.Red )

		CreateButton( "Back", false, function() 
			self:ShowGroupsPage()
		end, BRICKSCREDITSTORE.LUACONFIG.Themes.Green )
	end

	function self:ShowCategoriesPage()
		ChoiceBack:Clear()
		self.MenuBack:SetTall( ((83*BRCS_SHEIGHT_SCALE)*2)+20 )
		self.MenuBack:Center()

		for k, v in pairs( BRCS_ADMIN_CFG.Categories ) do
			local icon = BRICKSCREDITSTORE.GetImage( v )
			if( not icon or type( icon ) != "IMaterial" ) then
				icon = Material( "materials/brickscreditstore/other.png" )
			end

			CreateButton( k, icon, function() 
				BRCS_QueryRequest( "Are you sure you want to remove this category?", "", "Yes", function() 
					BRCS_ADMIN_CFG.Categories[k] = nil
					BRCS_ADMIN_CFG_CHANGED = true
					self:ShowCategoriesPage()
				end, "No", function() end )
			end )
		end

		CreateButton( "Add Category", Material( "materials/brickscreditstore/new.png", "noclamp smooth" ), function() 
			BRCS_StringRequest( "What is the name of the category you want to add?", "", "Other", "Confirm", function( text ) 
				if( BRCS_ADMIN_CFG.Categories[text] ) then
					notification.AddLegacy( "This category already exists!", 1, 5 )
					return
				end

				BRCS_StringRequest( "What is the image link for this category?", "", "https://i.imgur.com/SrDj1Id.png", "Confirm", function( link ) 
					BRCS_ADMIN_CFG.Categories[text] = link
					BRCS_ADMIN_CFG_CHANGED = true
					self:ShowCategoriesPage()
				end, "Cancel", function() end )
			end, "Cancel", function() end )
		end )

		CreateButton( "Back", false, function() 
			self:ShowHomePage()
		end, BRICKSCREDITSTORE.LUACONFIG.Themes.Green )
	end
end

function PANEL:Paint( w, h )	
	surface.SetDrawColor( BRICKSCREDITSTORE.LUACONFIG.Themes.Primary )
	surface.DrawRect( (w/2)-((BRCS_SWIDTH*0.5)/2), (h/2)-((BRCS_SWIDTH*0.6)/2), BRCS_SWIDTH*0.5, BRCS_SWIDTH*0.6 )
end

vgui.Register( "brcs_vgui_admin_othersettings", PANEL, "DFrame" )