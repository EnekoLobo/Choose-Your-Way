
local PANEL = {}

AccessorFunc( PANEL, "ActiveButton", "ActiveButton" )

local SidePadding = BRCS_SWIDTH_SCALE*103
function PANEL:Init()

	self.Navigation = vgui.Create( "DScrollPanel", self )
	self.Navigation:Dock( LEFT )
	self.Navigation:SetWidth( BRCS_SWIDTH*0.2 )

	local Logo = vgui.Create( "DPanel", self.Navigation )
	Logo:Dock( TOP )
	Logo:DockMargin( SidePadding, 83*BRCS_SHEIGHT_SCALE, SidePadding, 0 )
	Logo:SetTall( ((self.Navigation:GetWide())-(2*SidePadding))*0.30375939849 )
	local LogoMat = Material( "materials/brickscreditstore/logo.png", "noclamp smooth" )
	Logo.Paint = function( self2, w, h )
		surface.SetDrawColor( 255, 255, 255 )
		surface.SetMaterial( LogoMat )
		surface.DrawTexturedRect( 0, 0, w, h )
	end

	local PlyInfo = vgui.Create( "DPanel", self.Navigation )
	PlyInfo:Dock( TOP )
	PlyInfo:DockMargin( SidePadding, 110*BRCS_SHEIGHT_SCALE, SidePadding, 120*BRCS_SHEIGHT_SCALE )
	PlyInfo:SetTall( 50 )
	PlyInfo.Paint = function( self2, w, h )
		draw.RoundedBox( 6, 0, 0, w, h, BRICKSCREDITSTORE.LUACONFIG.Themes.Accent )

		draw.SimpleText( LocalPlayer():Nick(), "BRCS_MP_22", h+5, 6, BRICKSCREDITSTORE.LUACONFIG.Themes.White, 0, 0 )
		if( BRICKSCREDITSTORE.CURRENCYTYPES[self.StoreCurrency] ) then
			local CurrencyTable = BRICKSCREDITSTORE.CURRENCYTYPES[self.StoreCurrency]
			draw.SimpleText( CurrencyTable.formatFunc( CurrencyTable.getFunc( LocalPlayer() ) ), "BRCS_MP_16", h+5, 26, BRICKSCREDITSTORE.LUACONFIG.Themes.White, 0, 0 )
		else
			draw.SimpleText( BRICKSCREDITSTORE.FormatCredits( LocalPlayer():GetBRCS_Credits() ), "BRCS_MP_16", h+5, 26, BRICKSCREDITSTORE.LUACONFIG.Themes.White, 0, 0 )
		end
	end

	local PlyAvatar = vgui.Create( "AvatarImage", PlyInfo )
	local Spacing = 4
	PlyAvatar:Dock( LEFT )
	PlyAvatar:DockMargin( Spacing, Spacing, 0, Spacing )
	PlyAvatar:SetWide( PlyInfo:GetTall()-(2*Spacing) )
	PlyAvatar:SetPlayer( LocalPlayer(), 64 )

	self.Content = vgui.Create( "Panel", self )
	self.Content:Dock( FILL )

	self.Items = {}

end

function PANEL:UseButtonOnlyStyle()
	self.ButtonOnly = true
end

function PANEL:AddSheet( label, panel, material )

	if ( !IsValid( panel ) ) then return end

	local Sheet = {}
	Sheet.Button = vgui.Create( "DButton", self.Navigation )
	Sheet.Button.Target = panel
	Sheet.Button:Dock( TOP )
	Sheet.Button:SetText( "" )
	Sheet.Button:SetTall( 18 )
	Sheet.Button:DockMargin( SidePadding, 0, SidePadding, 15 )
	local IconMat = Material( material, "noclamp smooth" )
	Sheet.Button.Paint = function( self2, w, h )
		if( self2:IsHovered() and !self2:IsDown() and !self2.m_bSelected ) then
			surface.SetDrawColor( 52*1.35, 55*1.35, 76*1.35 )
			draw.SimpleText( label, "BRCS_MP_24", h+25, h/2, Color( 101*1.35, 107*1.35, 145*1.35 ), 0, 1 )
		elseif( self2:IsDown() || self2.m_bSelected ) then
			surface.SetDrawColor( BRICKSCREDITSTORE.LUACONFIG.Themes.Accent )
			draw.SimpleText( label, "BRCS_MP_24", h+25, h/2, BRICKSCREDITSTORE.LUACONFIG.Themes.White, 0, 1 )
		else
			surface.SetDrawColor( 52, 55, 76 )
			draw.SimpleText( label, "BRCS_MP_24", h+25, h/2, Color( 101, 107, 145 ), 0, 1 )
		end

		surface.SetMaterial( IconMat )
		surface.DrawTexturedRect( 0, 0, h, h )
	end
	Sheet.Button.DoClick = function()
		self:SetActiveButton( Sheet.Button )

		if( panel and panel.OnLoad ) then
			panel:OnLoad()
		end
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

derma.DefineControl( "brcs_vgui_dcolumnsheet", "", PANEL, "Panel" )
