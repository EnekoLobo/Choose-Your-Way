local PANEL = {}

local NPCType = ""
function PANEL:Init()
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

	--[[ Sheets ]]--
	local ColSheetBack = vgui.Create( "DPanel", self.MenuBack )
	ColSheetBack:Dock( FILL )
	ColSheetBack.Paint = function( self2, w, h ) end

	function self:RefreshPages()
		ColSheetBack:Clear()

		self.ColSheet = vgui.Create( "brcs_vgui_dcolumnsheet", ColSheetBack )
		self.ColSheet:Dock( FILL )

		local Sheets = {}
		Sheets[1] = {
			Name = "Dashboard",
			Icon = "materials/brickscreditstore/dashboard.png",
			Element = "brcs_vgui_dashboard"
		}
		Sheets[2] = {
			Name = "Locker",
			Icon = "materials/brickscreditstore/locker.png",
			Element = "brcs_vgui_locker"
		}
		Sheets[3] = {
			Name = "Donate",
			Icon = "materials/brickscreditstore/donate.png",
			Element = "brcs_vgui_donate"
		}

		for k, v in pairs( Sheets ) do
			local SheetEntry = vgui.Create( v.Element, self.ColSheet )
			SheetEntry:Dock( FILL )

			if( SheetEntry.Setup ) then
				SheetEntry:Setup( self )
			end

			self.ColSheet:AddSheet( v.Name, SheetEntry, v.Icon )
		end
	end
	self:RefreshPages()

	--[[ Close Button ]]--
	local CloseButton = vgui.Create( "DButton", self.MenuBack )
	local size = 20
	CloseButton:SetSize( size, size )
	CloseButton:SetPos( BackW-83*BRCS_SHEIGHT_SCALE-size, 83*BRCS_SHEIGHT_SCALE )
	CloseButton:SetText( "" )
	local CloseMat = Material( "materials/brickscreditstore/close.png", "noclamp smooth" )
	CloseButton.Paint = function( self2, w, h )
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
	CloseButton.DoClick = function()
		self:SetKeyboardInputEnabled( false )
		self:SetMouseInputEnabled( false )
		self.MenuBack:AlphaTo( 0, 0.05, 0, function() 
			self:Remove()
		end )
	end
end

function PANEL:SetNPCType( type )
	NPCType = type
	self:RefreshPages()

	if( IsValid( self.ColSheet ) ) then
		self.ColSheet.StoreCurrency = ((BRICKSCREDITSTORE.CONFIG.NPCs[type] or {}).currency or "")
	end
end

function PANEL:Paint( w, h )
end

vgui.Register( "brcs_vgui_shop", PANEL, "DFrame" )

-- Dashboard --
local PANEL = {}

function PANEL:Init()
	if( not BRICKSCREDITSTORE.CONFIG.NPCs[NPCType] or not BRICKSCREDITSTORE.CONFIG.NPCs[NPCType].Items ) then return end
	
	local TopColsheet = vgui.Create( "brcs_vgui_dcolumnsheet_top", self )
	TopColsheet:Dock( FILL )

	local Pages = {}
	for k, v in pairs( BRICKSCREDITSTORE.CONFIG.NPCs[NPCType].Items ) do
		local catName = v.Category
		if( not catName or not BRICKSCREDITSTORE.CONFIG.Categories[catName] ) then
			catName = "Other"
		end

		local LayoutWidth = BRCS_SWIDTH-(BRCS_SWIDTH*0.2)-(BRCS_SWIDTH_SCALE*103)
		local Spacing = 15
		if( not IsValid( Pages[catName] ) ) then
			local ScrollPanel = vgui.Create( "DScrollPanel", TopColsheet )
			ScrollPanel:Dock( FILL )
			ScrollPanel:DockMargin( 0, 10, BRCS_SWIDTH_SCALE*103, BRCS_SWIDTH_SCALE*103 )
			ScrollPanel:GetVBar():SetWide( 0 )
			
			Pages[catName] = vgui.Create( "DIconLayout", ScrollPanel )
			Pages[catName]:Dock( FILL )
			Pages[catName]:SetSpaceX( Spacing )
			Pages[catName]:SetSpaceY( Spacing )

			local icon = false
			if( BRICKSCREDITSTORE.CONFIG.Categories[catName] ) then
				icon = BRICKSCREDITSTORE.GetImage( BRICKSCREDITSTORE.CONFIG.Categories[catName] )
			end

			if( not icon ) then
				icon = Material( "materials/brickscreditstore/other.png" )
			end

			TopColsheet:AddSheet( catName, ScrollPanel, icon )
		end

		local ItemSize = (LayoutWidth-(3*Spacing))/4

		local ItemEntry = Pages[catName]:Add( "DPanel" )
		ItemEntry:SetSize( ItemSize, ItemSize )
		local Tall = 50
		local SecondaryC = BRICKSCREDITSTORE.LUACONFIG.Themes.Secondary
		ItemEntry.Paint = function( self2, w, h )
			draw.RoundedBox( 15, 0, 0, w, h, SecondaryC )
			draw.RoundedBoxEx( 15, 0, h-Tall, w, Tall, Color( SecondaryC.r*1.25, SecondaryC.g*1.25, SecondaryC.b*1.25, 255 ), false, false, true, true )

			draw.SimpleText( v.Name, "BRCS_MP_26", 20, h-(Tall/2), Color( 255, 255, 255 ), 0, TEXT_ALIGN_CENTER )

			local PosHeight = h-(Tall/2)
			if( ScrW() < 1920 ) then
				PosHeight = (Tall/2)
			end

			if( not v.GroupType or not BRICKSCREDITSTORE.CONFIG.Groups[v.GroupType] or BRICKSCREDITSTORE.CONFIG.Groups[v.GroupType][BRICKSCREDITSTORE.GetAdminGroup( LocalPlayer() )] ) then
				draw.SimpleText( BRICKSCREDITSTORE.FormatCurrency( (v.Price or 0), BRICKSCREDITSTORE.CONFIG.NPCs[NPCType].currency, true ), "BRCS_MP_16", w-20, PosHeight, Color( 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
			else
				draw.SimpleText( v.GroupType .. " ONLY", "BRCS_MP_16", w-20, PosHeight, Color( 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
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
				self2.PopUp:AddOption( "Purchase", function() 
					if( not v.GroupType or not BRICKSCREDITSTORE.CONFIG.Groups[v.GroupType] or BRICKSCREDITSTORE.CONFIG.Groups[v.GroupType][BRICKSCREDITSTORE.GetAdminGroup( LocalPlayer() )] ) then
						if( not (BRICKSCREDITSTORE.ITEMTYPES[v.Type or ""] or {}).BuyableOnce or not LocalPlayer():GetBRCS_AlreadyOwn( NPCType, k ) ) then
							net.Start( "BRCS_Net_Purchase" )
								net.WriteString( NPCType )
								net.WriteInt( k, 32 )
							net.SendToServer()
						else
							notification.AddLegacy( "You already own this item!", 1, 3 )
						end
					else
						notification.AddLegacy( string.format( "This item is %s only!", v.GroupType ), 1, 3 )
					end
				end )
				self2.PopUp:AddOption( "Info", function()
					if( IsValid( self2.PopUp ) ) then
						self2.PopUp:SetDescription( v.Description )
					end
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
	
	for k, v in pairs( Pages ) do
		if( IsValid( v ) ) then
			v:SizeToContents()
		end
	end
end

function PANEL:Paint( w, h )
end

vgui.Register( "brcs_vgui_dashboard", PANEL, "DPanel" )

-- Locker --
local PANEL = {}

function PANEL:Init()

end

function PANEL:Setup( ParentVGUI )
	local ToggleBar = vgui.Create( "DPanel", self )
	ToggleBar:Dock( TOP )
	ToggleBar:DockMargin( 0, 83*BRCS_SHEIGHT_SCALE, 0, 0 )
	ToggleBar:SetTall( 40 )
	ToggleBar.Paint = function() end

	local LayoutWidth = BRCS_SWIDTH-(BRCS_SWIDTH*0.2)-(BRCS_SWIDTH_SCALE*103)
	local Spacing = 15
	
	local ScrollPanel = vgui.Create( "DScrollPanel", self )
	ScrollPanel:Dock( FILL )
	ScrollPanel:DockMargin( 0, 10, BRCS_SWIDTH_SCALE*103, BRCS_SWIDTH_SCALE*103 )
	ScrollPanel:GetVBar():SetWide( 0 )
	
	local IconLayout = vgui.Create( "DIconLayout", ScrollPanel )
	IconLayout:Dock( FILL )
	IconLayout:SetSpaceX( Spacing )
	IconLayout:SetSpaceY( Spacing )

	local Toggled = {}
	local CreatedToggles = {}
	function ParentVGUI:RefreshLocker()
		IconLayout:Clear()

		for k, v in pairs( LocalPlayer():GetBRCS_Locker() ) do
			if( not CreatedToggles[v[1]] ) then
				Toggled[v[1]] = true
		
				CreatedToggles[v[1]] = vgui.Create( "DButton", ToggleBar )
				CreatedToggles[v[1]]:Dock( LEFT )
				CreatedToggles[v[1]]:SetText( "" )
				CreatedToggles[v[1]]:DockMargin( 0, 0, 10, 0 )
				local IconSize = ToggleBar:GetTall()*0.5
				surface.SetFont( "BRCS_MP_22" )
				local label = BRICKSCREDITSTORE.LOCKERTYPES[v[1] or ""].Name or v[1]
				local TextX, TextY = surface.GetTextSize( label )
				CreatedToggles[v[1]]:SetWide( IconSize+TextX+30 )
				CreatedToggles[v[1]].Paint = function( self2, w, h )
					draw.RoundedBox( 3, 0, 0, w, h, BRICKSCREDITSTORE.LUACONFIG.Themes.Secondary )
			
					if( self2:IsHovered() and !self2:IsDown() and not Toggled[v[1]] ) then
						surface.SetDrawColor( 52*1.35, 55*1.35, 76*1.35 )
						draw.SimpleText( label, "BRCS_MP_22", 10, h/2, Color( 101*1.35, 107*1.35, 145*1.35 ), 0, 1 )
					elseif( self2:IsDown() || Toggled[v[1]] ) then
						surface.SetDrawColor( BRICKSCREDITSTORE.LUACONFIG.Themes.Accent )
						draw.SimpleText( label, "BRCS_MP_22", 10, h/2, BRICKSCREDITSTORE.LUACONFIG.Themes.White, 0, 1 )
					else
						surface.SetDrawColor( 52, 55, 76 )
						draw.SimpleText( label, "BRCS_MP_22", 10, h/2, Color( 101, 107, 145 ), 0, 1 )
					end
					draw.NoTexture()
					BRICKSCREDITSTORE.DrawCircle( w-10-(IconSize/2), h/2, IconSize/2, 45 )
				end
				CreatedToggles[v[1]].DoClick = function()
					if( Toggled[v[1]] ) then
						Toggled[v[1]] = false
					else
						Toggled[v[1]] = true
					end
		
					ParentVGUI:RefreshLocker()
				end
			end

			if( not Toggled[v[1] or ""] or not v[1] or not BRICKSCREDITSTORE.LOCKERTYPES[v[1] or ""] ) then continue end

			local LockerType = BRICKSCREDITSTORE.LOCKERTYPES[v[1] or ""]
			
			local ItemSize = (LayoutWidth-(3*Spacing))/4

			local ItemEntry = IconLayout:Add( "DPanel" )
			ItemEntry:SetSize( ItemSize, ItemSize )
			local Tall = 50
			local SecondaryC = BRICKSCREDITSTORE.LUACONFIG.Themes.Secondary
			local Name = (v[3] or {})[1] or "INVALID"
			local IconSize = ToggleBar:GetTall()*0.5
			ItemEntry.Paint = function( self2, w, h )
				draw.RoundedBox( 15, 0, 0, w, h, SecondaryC )
				draw.RoundedBoxEx( 15, 0, h-Tall, w, Tall, Color( SecondaryC.r*1.25, SecondaryC.g*1.25, SecondaryC.b*1.25, 255 ), false, false, true, true )

				draw.SimpleText( Name, "BRCS_MP_26", 20, h-(Tall/2), Color( 255, 255, 255 ), 0, TEXT_ALIGN_CENTER )

				if( v.Active and LockerType.TimerKey and (v[2] or {})[LockerType.TimerKey] ) then
					local TimeLeft = math.max( 0, (v[2] or {})[LockerType.TimerKey]-os.time() )
					if( TimeLeft < 86400 ) then
						draw.SimpleText( os.date( "%H:%M:%S" , TimeLeft ), "BRCS_MP_16", w-20, h-(Tall/2), Color( 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
					else
						draw.SimpleText( math.Round(TimeLeft/86400, 1) .. " days", "BRCS_MP_16", w-20, h-(Tall/2), Color( 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
					end
				end
			end

			if( (v[3] or {})[2] and string.EndsWith( (v[3] or {})[2], ".mdl" ) ) then
				local ItemEntryIcon = vgui.Create( "DModelPanel", ItemEntry )
				ItemEntryIcon:Dock( FILL )
				ItemEntryIcon:DockMargin( 0, 0, 0, Tall )
				ItemEntryIcon:SetModel( (v[3] or {})[2]  )		
				if( IsValid( ItemEntryIcon.Entity ) ) then
					local mn, mx = ItemEntryIcon.Entity:GetRenderBounds()
					local size = 0
					size = math.max( size, math.abs( mn.x ) + math.abs( mx.x ) )
					size = math.max( size, math.abs( mn.y ) + math.abs( mx.y ) )
					size = math.max( size, math.abs( mn.z ) + math.abs( mx.z ) )

					ItemEntryIcon:SetFOV( 55 )
					ItemEntryIcon:SetCamPos( Vector( size, size, size ) )
					ItemEntryIcon:SetLookAt( ( mn + mx ) * 0.5 )
					function ItemEntryIcon:LayoutEntity( Entity ) return end
				end
			else
				local ItemEntryIcon = vgui.Create( "DPanel", ItemEntry )
				ItemEntryIcon:Dock( FILL )
				ItemEntryIcon:DockMargin( 0, 0, 0, Tall )
				local IconMat = BRICKSCREDITSTORE.GetImage( (v[3] or {})[2] )
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
				if( not ItemEntryCover.XPos or not ItemEntryCover.YPos ) then
					local X, Y = self2:LocalToScreen( 0, 0 )
					ItemEntryCover.XPos = X
					ItemEntryCover.YPos = Y
				end
	
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
					self2.PopUp:AddOption( "Info", function()
						if( IsValid( self2.PopUp ) ) then
							self2.PopUp:SetDescription( (v[3] or {})[3] or "INVALID" )
						end
					end )
					if( BRICKSCREDITSTORE.LUACONFIG.CanTransferItems ) then
						self2.PopUp:AddOption( "Transfer", function() 
							local Options = {}
							for k, v in pairs( player.GetHumans() ) do
								if( v == LocalPlayer() ) then continue end
								Options[v:SteamID64()] = v:Nick()
							end

							if( table.Count( Options ) <= 0 ) then
								notification.AddLegacy( "There are no players online!", 1, 3 )
								return
							end
							
							BRCS_ComboRequest( "Who would you like to transfer it to?", "Locker", Options, "Transfer", function( chosenK, chosenV ) 
								net.Start( "BRCS_Net_Transfer" )
									net.WriteInt( k, 32 )
									net.WriteString( chosenK )
								net.SendToServer()
							end, "Cancel", function() end )
						end )
					end
					self2.PopUp:AddOption( "Remove", function() 
						BRCS_QueryRequest( "Are you sure you want to remove this?", "Locker", "Yes", function() 
							net.Start( "BRCS_Net_Remove" )
								net.WriteInt( k, 32 )
							net.SendToServer()
						end, "No", function() end )
					end )
					local YPos = self2.YPos+(ItemSize/2)
					self2.PopUp:SetPos( self2.XPos+ItemSize-5, YPos-(self2.PopUp:GetTall()/2) )
				end )
			end
			ItemEntryCover.OnCursorExited = function( self2 )
				if( timer.Exists( tostring( self2 ) .. "_BRCS_TIMER" ) ) then 
					timer.Remove( tostring( self2 ) .. "_BRCS_TIMER" )
				end
			end

			local IconSize = ToggleBar:GetTall()*0.5

			local ItemToggle = vgui.Create( "DButton", ItemEntryCover )
			ItemToggle:SetSize( IconSize, IconSize )
			ItemToggle:SetPos( ItemEntry:GetWide()-10-IconSize, 10 )
			ItemToggle:SetText( "" )
			ItemToggle.Paint = function( self2, w, h )
				if( self2:IsHovered() and !self2:IsDown() and not v.Active ) then
					surface.SetDrawColor( 52*1.35, 55*1.35, 76*1.35 )
				elseif( v.Active ) then
					surface.SetDrawColor( BRICKSCREDITSTORE.LUACONFIG.Themes.Accent )
				else
					surface.SetDrawColor( 52, 55, 76 )
				end
				draw.NoTexture()
				BRICKSCREDITSTORE.DrawCircle( w/2, h/2, IconSize/2, 45 )
			end
			ItemToggle.DoClick = function()
				if( not v.Active ) then
					local canToggle, message = LocalPlayer():GetBRCS_CanToggle( k )

					if( not canToggle ) then
						notification.AddLegacy( message or "ERROR Toggling", 1, 3 )
						return
					end
				end

				net.Start( "BRCS_Net_ToggleLocker" )
					net.WriteInt( k, 32 )
				net.SendToServer()
			end
		end
		
		IconLayout:SizeToContents()
	end

	ParentVGUI:RefreshLocker()
end

function PANEL:Paint( w, h )
end

vgui.Register( "brcs_vgui_locker", PANEL, "DPanel" )

-- Donate --
local PANEL = {}

function PANEL:Init()
	local ToggleBar = vgui.Create( "DPanel", self )
	ToggleBar:Dock( TOP )
	ToggleBar:DockMargin( 0, 83*BRCS_SHEIGHT_SCALE, 0, 0 )
	ToggleBar:SetTall( 40 )
	ToggleBar.Paint = function() end

	local Buttons = {}
	Buttons[1] = {
		Name = "Visit",
		Icon = "materials/brickscreditstore/site.png",
		doClick = function()
			gui.OpenURL( BRICKSCREDITSTORE.LUACONFIG.DonationURL )
		end
	}
	/*Buttons[2] = {
		Name = "Enter code",
		Icon = "materials/brickscreditstore/donate.png",
		doClick = function()
			
		end
	}*/

	for k, v in pairs( Buttons ) do
		local ButtonEntry = vgui.Create( "DButton", ToggleBar )
		ButtonEntry:Dock( LEFT )
		ButtonEntry:SetText( "" )
		ButtonEntry:DockMargin( 0, 0, 10, 0 )
		local IconSize = ToggleBar:GetTall()*0.5
		surface.SetFont( "BRCS_MP_22" )
		local TextX, TextY = surface.GetTextSize( v.Name )
		ButtonEntry:SetWide( IconSize+TextX+30 )
		local IconMat = Material( v.Icon, "noclamp smooth" )
		ButtonEntry.Paint = function( self2, w, h )
			draw.RoundedBox( 3, 0, 0, w, h, BRICKSCREDITSTORE.LUACONFIG.Themes.Secondary )

			if( self2:IsHovered() and !self2:IsDown() ) then
				surface.SetDrawColor( 52*1.35, 55*1.35, 76*1.35 )
				draw.SimpleText( v.Name, "BRCS_MP_22", w-10, h/2, Color( 101*1.35, 107*1.35, 145*1.35 ), TEXT_ALIGN_RIGHT, 1 )
			elseif( self2:IsDown() ) then
				surface.SetDrawColor( BRICKSCREDITSTORE.LUACONFIG.Themes.Accent )
				draw.SimpleText( v.Name, "BRCS_MP_22", w-10, h/2, BRICKSCREDITSTORE.LUACONFIG.Themes.White, TEXT_ALIGN_RIGHT, 1 )
			else
				surface.SetDrawColor( 52, 55, 76 )
				draw.SimpleText( v.Name, "BRCS_MP_22", w-10, h/2, Color( 101, 107, 145 ), TEXT_ALIGN_RIGHT, 1 )
			end

			surface.SetMaterial( IconMat )
			surface.DrawTexturedRect( 10, (h/2)-(IconSize/2), IconSize, IconSize )
		end
		ButtonEntry.DoClick = v.doClick
	end

	local websiteBack = vgui.Create( "DPanel", self )
	websiteBack:Dock( FILL )
	websiteBack.Paint = function() end

	function self:OnLoad()
		websiteBack:Clear()
		
		local WebsiteControls = vgui.Create( "DHTMLControls", websiteBack )
		WebsiteControls:Dock( TOP )
		WebsiteControls:DockMargin( 0, 10, BRCS_SWIDTH_SCALE*103, 0 )
		WebsiteControls:SetTall( 40 )
		WebsiteControls.AddressBar:SetText( BRICKSCREDITSTORE.LUACONFIG.DonationURL )

		local WebsiteView = vgui.Create( "DHTML", websiteBack )
		WebsiteView:Dock( FILL )
		WebsiteView:DockMargin( 0, 0, BRCS_SWIDTH_SCALE*103, BRCS_SWIDTH_SCALE*103 )
		WebsiteView:OpenURL( BRICKSCREDITSTORE.LUACONFIG.DonationURL )
		local LoadingMat = Material( "materials/brickscreditstore/loading.png", "noclamp smooth" )
		local MatSize = 32
		WebsiteView.Paint = function( self2, w, h )
			surface.SetDrawColor( BRICKSCREDITSTORE.LUACONFIG.Themes.Secondary )
			surface.DrawRect( 0, 0, w, h )

			draw.SimpleText( "Loading Page", "BRCS_MP_22", w/2, h/2, BRICKSCREDITSTORE.LUACONFIG.Themes.White, 1, 1 )
		end

		WebsiteControls:SetHTML( WebsiteView )
	end
end

function PANEL:Paint( w, h )
end

vgui.Register( "brcs_vgui_donate", PANEL, "DPanel" )