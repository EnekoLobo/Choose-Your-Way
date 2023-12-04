
local PANEL = {}

AccessorFunc( PANEL, "ActiveButton", "ActiveButton" )

function PANEL:Init()

	self.Navigation = vgui.Create( "DPanel", self )
	self.Navigation:Dock( TOP )
	self.Navigation:DockMargin( 0, 83*BRCS_SHEIGHT_SCALE, 0, 0 )
	self.Navigation:SetTall( 40 )
	self.Navigation.Paint = function() end

	self.Content = vgui.Create( "Panel", self )
	self.Content:Dock( FILL )

	self.Items = {}

end

function PANEL:UseButtonOnlyStyle()
	self.ButtonOnly = true
end

function PANEL:AddSheet( label, panel, IconMat )

	if ( !IsValid( panel ) ) then return end

	local Sheet = {}
	Sheet.Button = vgui.Create( "DButton", self.Navigation )
	Sheet.Button.Target = panel
	Sheet.Button:Dock( LEFT )
	Sheet.Button:SetText( "" )
	Sheet.Button:DockMargin( 0, 0, 10, 0 )
	local IconSize = self.Navigation:GetTall()*0.5
	surface.SetFont( "BRCS_MP_22" )
	local TextX, TextY = surface.GetTextSize( label )
	Sheet.Button:SetWide( IconSize+TextX+30 )
	Sheet.Button.Paint = function( self2, w, h )
		draw.RoundedBox( 3, 0, 0, w, h, BRICKSCREDITSTORE.LUACONFIG.Themes.Secondary )

		if( self2:IsHovered() and !self2:IsDown() and !self2.m_bSelected ) then
			surface.SetDrawColor( 52*1.35, 55*1.35, 76*1.35 )
			draw.SimpleText( label, "BRCS_MP_22", w-10, h/2, Color( 101*1.35, 107*1.35, 145*1.35 ), TEXT_ALIGN_RIGHT, 1 )
		elseif( self2:IsDown() || self2.m_bSelected ) then
			surface.SetDrawColor( BRICKSCREDITSTORE.LUACONFIG.Themes.Accent )
			draw.SimpleText( label, "BRCS_MP_22", w-10, h/2, BRICKSCREDITSTORE.LUACONFIG.Themes.White, TEXT_ALIGN_RIGHT, 1 )
		else
			surface.SetDrawColor( 52, 55, 76 )
			draw.SimpleText( label, "BRCS_MP_22", w-10, h/2, Color( 101, 107, 145 ), TEXT_ALIGN_RIGHT, 1 )
		end

		surface.SetMaterial( IconMat )
		surface.DrawTexturedRect( 10, (h/2)-(IconSize/2), IconSize, IconSize )
	end
	Sheet.Button.DoClick = function()
		self:SetActiveButton( Sheet.Button )
	end

	Sheet.Panel = panel
	Sheet.Panel:SetParent( self.Content )
	Sheet.Panel:SetVisible( false )

	if ( self.ButtonOnly ) then
		Sheet.Button:SizeToContents()
	end

	table.insert( self.Items, Sheet )

	if ( !IsValid( self.ActiveButton ) ) then
		self:SetActiveButton( Sheet.Button )
	end
	
	return Sheet
end

function PANEL:AddButton( label, onClick, IconMat )
	local Sheet = {}
	Sheet.Button = vgui.Create( "DButton", self.Navigation )
	Sheet.Button.Target = panel
	Sheet.Button:Dock( RIGHT )
	Sheet.Button:SetText( "" )
	Sheet.Button:DockMargin( 10, 0, 0, 0 )
	local IconSize = self.Navigation:GetTall()*0.5
	surface.SetFont( "BRCS_MP_22" )
	local TextX, TextY = surface.GetTextSize( label )
	if( IconMat ) then
		Sheet.Button:SetWide( IconSize+TextX+30 )
		Sheet.Button.Paint = function( self2, w, h )
			draw.RoundedBox( 3, 0, 0, w, h, BRICKSCREDITSTORE.LUACONFIG.Themes.Secondary )

			if( self2:IsHovered() and !self2:IsDown() and !self2.m_bSelected ) then
				surface.SetDrawColor( 52*1.35, 55*1.35, 76*1.35 )
				draw.SimpleText( label, "BRCS_MP_22", w-10, h/2, Color( 101*1.35, 107*1.35, 145*1.35 ), TEXT_ALIGN_RIGHT, 1 )
			elseif( self2:IsDown() || self2.m_bSelected ) then
				surface.SetDrawColor( BRICKSCREDITSTORE.LUACONFIG.Themes.Accent )
				draw.SimpleText( label, "BRCS_MP_22", w-10, h/2, BRICKSCREDITSTORE.LUACONFIG.Themes.White, TEXT_ALIGN_RIGHT, 1 )
			else
				surface.SetDrawColor( 52, 55, 76 )
				draw.SimpleText( label, "BRCS_MP_22", w-10, h/2, Color( 101, 107, 145 ), TEXT_ALIGN_RIGHT, 1 )
			end

			surface.SetMaterial( IconMat )
			surface.DrawTexturedRect( 10, (h/2)-(IconSize/2), IconSize, IconSize )
		end
	else
		Sheet.Button:SetWide( TextX+30 )
		Sheet.Button.Paint = function( self2, w, h )
			draw.RoundedBox( 3, 0, 0, w, h, BRICKSCREDITSTORE.LUACONFIG.Themes.Secondary )

			if( self2:IsHovered() and !self2:IsDown() and !self2.m_bSelected ) then
				draw.SimpleText( label, "BRCS_MP_22", w/2, h/2, Color( 101*1.35, 107*1.35, 145*1.35 ), 1, 1 )
			elseif( self2:IsDown() || self2.m_bSelected ) then
				draw.SimpleText( label, "BRCS_MP_22", w/2, h/2, BRICKSCREDITSTORE.LUACONFIG.Themes.White, 1, 1 )
			else
				draw.SimpleText( label, "BRCS_MP_22", w/2, h/2, Color( 101, 107, 145 ), 1, 1 )
			end
		end
	end
	Sheet.Button.DoClick = onClick

	if ( self.ButtonOnly ) then
		Sheet.Button:SizeToContents()
	end
end

function PANEL:SetActiveButton( active )

	if ( self.ActiveButton == active ) then return end

	if ( self.ActiveButton && self.ActiveButton.Target ) then
		self.ActiveButton.Target:SetVisible( false )
		self.ActiveButton:SetSelected( false )
		self.ActiveButton:SetToggle( false )
	end

	self.ActiveButton = active
	active.Target:SetVisible( true )
	active:SetSelected( true )
	active:SetToggle( true )

	self.Content:InvalidateLayout()

end

derma.DefineControl( "brcs_vgui_dcolumnsheet_top", "", PANEL, "Panel" )
