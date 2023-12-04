function BRCS_QueryRequest( subtitle, title, confirmText, func_confirm, cancelText, func_cancel )
	local DermaPanel = vgui.Create( "DFrame" )
	DermaPanel:SetPos( 0, 0 )
	DermaPanel:SetSize( ScrW(), ScrH() )
	DermaPanel:SetTitle( "" )
	DermaPanel:SetDraggable( false )
	DermaPanel:ShowCloseButton( false )
	DermaPanel:MakePopup()
	DermaPanel.Paint = function() end
	
	local BackPanel = vgui.Create( "DPanel", DermaPanel )
	BackPanel:SetSize( (1920)*0.25, (1080)*0.175 )
	BackPanel:Center()
	local col = Color( 245, 245, 245 )
	surface.SetFont( "BRCS_MP_22" )
	local TextX, TextY = surface.GetTextSize( subtitle )
	local Spacing = 15
	local CenterHeight = TextY+50+Spacing
	local StartY = (BackPanel:GetTall()/2)-(CenterHeight/2)
	BackPanel.Paint = function( self2, w, h )
		local x, y = self2:LocalToScreen( 0, 0 )
		
		BSHADOWS.BeginShadow()
		draw.RoundedBox( 5, x, y, w, h, BRICKSCREDITSTORE.LUACONFIG.Themes.Primary )	
		BSHADOWS.EndShadow(2, 2, 1, 255, 0, 0, false )

		draw.SimpleText( subtitle, "BRCS_MP_22", w/2, StartY, col, TEXT_ALIGN_CENTER, 0 )
	end

	local ButtonBar = vgui.Create( "DPanel", BackPanel )
	ButtonBar:SetSize( BackPanel:GetWide()*0.75, 50 )
	ButtonBar:SetPos( (BackPanel:GetWide()-ButtonBar:GetWide())/2, StartY+TextY+Spacing )
	ButtonBar.Paint = function( self2, w, h )
		surface.SetDrawColor( BRICKSCREDITSTORE.LUACONFIG.Themes.Primary )
		surface.DrawRect( 0, 0, w, h )		
	end
	
	local YesButton = vgui.Create( "brcs_vgui_button", ButtonBar )
	YesButton:Dock( LEFT )
	YesButton:DockMargin( 0, 0, 5, 0 )
	YesButton:SetWide( ButtonBar:GetWide()/2 )
	YesButton:SetInfo( confirmText or "OK" )
	YesButton.DoClick = function()
		DermaPanel:Remove()
		func_confirm()
	end	
	
	local NoButton = vgui.Create( "brcs_vgui_button", ButtonBar )
	NoButton:Dock( LEFT )
	NoButton:DockMargin( 5, 0, 0, 0 )
	NoButton:SetWide( ButtonBar:GetWide()/2 )
	NoButton:SetInfo( cancelText or "Cancel" )
	NoButton.DoClick = function()
		DermaPanel:Remove()
		func_cancel()
	end
end

function BRCS_StringRequest( subtitle, title, default, confirmText, func_confirm, cancelText, func_cancel )
	local DermaPanel = vgui.Create( "DFrame" )
	DermaPanel:SetPos( 0, 0 )
	DermaPanel:SetSize( ScrW(), ScrH() )
	DermaPanel:SetTitle( "" )
	DermaPanel:SetDraggable( false )
	DermaPanel:ShowCloseButton( false )
	DermaPanel:MakePopup()
	DermaPanel.Paint = function() end
	
	local BackPanel = vgui.Create( "DPanel", DermaPanel )
	BackPanel:SetSize( (1920)*0.25, (1080)*0.2 )
	BackPanel:Center()
	local col = Color( 245, 245, 245 )
	surface.SetFont( "BRCS_MP_22" )
	local TextX, TextY = surface.GetTextSize( subtitle )
	local Spacing = 15
	local CenterHeight = TextY+25+50+(2*Spacing)
	local StartY = (BackPanel:GetTall()/2)-(CenterHeight/2)
	BackPanel.Paint = function( self2, w, h )
		local x, y = self2:LocalToScreen( 0, 0 )
		
		BSHADOWS.BeginShadow()
		draw.RoundedBox( 5, x, y, w, h, BRICKSCREDITSTORE.LUACONFIG.Themes.Primary )	
		BSHADOWS.EndShadow(2, 2, 1, 255, 0, 0, false )

		draw.SimpleText( subtitle, "BRCS_MP_22", w/2, StartY, col, TEXT_ALIGN_CENTER, 0 )
	end

	local DTextEntry = vgui.Create( "DTextEntry", BackPanel )
	DTextEntry:SetSize( BackPanel:GetWide()*0.75, 25 )
	DTextEntry:SetPos( (BackPanel:GetWide()-DTextEntry:GetWide())/2, StartY+TextY+Spacing )
	DTextEntry:SetText( default or "" )

	local ButtonBar = vgui.Create( "DPanel", BackPanel )
	ButtonBar:SetSize( BackPanel:GetWide()*0.75, 50 )
	ButtonBar:SetPos( (BackPanel:GetWide()-ButtonBar:GetWide())/2, StartY+TextY+Spacing+DTextEntry:GetTall()+Spacing )
	ButtonBar.Paint = function( self2, w, h )
		surface.SetDrawColor( BRICKSCREDITSTORE.LUACONFIG.Themes.Primary )
		surface.DrawRect( 0, 0, w, h )		
	end
	
	local YesButton = vgui.Create( "brcs_vgui_button", ButtonBar )
	YesButton:Dock( LEFT )
	YesButton:SetWide( ButtonBar:GetWide()/2 )
	YesButton:SetInfo( confirmText or "OK" )
	YesButton.DoClick = function()
		DermaPanel:Remove()
		func_confirm( DTextEntry:GetText() )
	end	
	
	local NoButton = vgui.Create( "brcs_vgui_button", ButtonBar )
	NoButton:Dock( LEFT )
	NoButton:SetWide( ButtonBar:GetWide()/2 )
	NoButton:SetInfo( cancelText or "Cancel" )
	NoButton.DoClick = function()
		DermaPanel:Remove()
		func_cancel()
	end
end

function BRCS_ComboRequest( subtitle, title, options, confirmText, func_confirm, cancelText, func_cancel, default )
	local DermaPanel = vgui.Create( "DFrame" )
	DermaPanel:SetPos( 0, 0 )
	DermaPanel:SetSize( ScrW(), ScrH() )
	DermaPanel:SetTitle( "" )
	DermaPanel:SetDraggable( false )
	DermaPanel:ShowCloseButton( false )
	DermaPanel:MakePopup()
	DermaPanel.Paint = function() end
	
	local BackPanel = vgui.Create( "DPanel", DermaPanel )
	BackPanel:SetSize( (1920)*0.25, (1080)*0.2 )
	BackPanel:Center()
	local col = Color( 245, 245, 245 )
	surface.SetFont( "BRCS_MP_22" )
	local TextX, TextY = surface.GetTextSize( subtitle )
	local Spacing = 15
	local CenterHeight = TextY+25+50+(2*Spacing)
	local StartY = (BackPanel:GetTall()/2)-(CenterHeight/2)
	BackPanel.Paint = function( self2, w, h )
		local x, y = self2:LocalToScreen( 0, 0 )
		
		BSHADOWS.BeginShadow()
		draw.RoundedBox( 5, x, y, w, h, BRICKSCREDITSTORE.LUACONFIG.Themes.Primary )	
		BSHADOWS.EndShadow(2, 2, 1, 255, 0, 0, false )

		draw.SimpleText( subtitle, "BRCS_MP_22", w/2, StartY, col, TEXT_ALIGN_CENTER, 0 )
	end

	local DComboBox = vgui.Create( "DComboBox", BackPanel )
	DComboBox:SetSize( BackPanel:GetWide()*0.75, 25 )
	DComboBox:SetPos( (BackPanel:GetWide()-DComboBox:GetWide())/2, StartY+TextY+Spacing )
	DComboBox:SetValue( "Select option" )
	for k, v in pairs( options ) do
		local index = DComboBox:AddChoice( v, k )

		if( default == k or default == v ) then
			DComboBox:ChooseOption( v, index )
		end
	end

	local ButtonBar = vgui.Create( "DPanel", BackPanel )
	ButtonBar:SetSize( BackPanel:GetWide()*0.75, 50 )
	ButtonBar:SetPos( (BackPanel:GetWide()-ButtonBar:GetWide())/2, StartY+TextY+Spacing+DComboBox:GetTall()+Spacing )
	ButtonBar.Paint = function( self2, w, h ) end
	
	local YesButton = vgui.Create( "brcs_vgui_button", ButtonBar )
	YesButton:Dock( LEFT )
	YesButton:DockMargin( 0, 0, 5, 0)
	YesButton:SetWide( ButtonBar:GetWide()/2 )
	YesButton:SetInfo( confirmText or "OK" )
	YesButton.DoClick = function()
		if( not DComboBox:GetOptionData( DComboBox:GetSelectedID() ) ) then 
			notification.AddLegacy( "Select an option!", 1, 3 )
			return 
		end

		DermaPanel:Remove()
		func_confirm( DComboBox:GetOptionData( DComboBox:GetSelectedID() ), DComboBox:GetValue() )
	end	
	
	local NoButton = vgui.Create( "brcs_vgui_button", ButtonBar )
	NoButton:Dock( LEFT )
	NoButton:DockMargin( 5, 0, 0, 0)
	NoButton:SetWide( ButtonBar:GetWide()/2 )
	NoButton:SetInfo( cancelText or "Cancel" )
	NoButton.DoClick = function()
		DermaPanel:Remove()
		func_cancel()
	end
end

-- Button --
local PANEL = {}

function PANEL:Init()
	self:SetText( "" )
end

local Hover = Color( 0, 0, 0, 25 )
local Down = Color( 0, 0, 0, 50 )
local LabelHover = Color( 101*1.35, 107*1.35, 145*1.35 )
local TextNorm = Color( 101, 107, 145 )
function PANEL:Paint( w, h )
	local IconSize = h*0.5
	draw.RoundedBox( 3, 0, 0, w, h, self.sColor or BRICKSCREDITSTORE.LUACONFIG.Themes.Secondary )
	
	if( not self.sColor ) then
		if( self:IsHovered() and !self:IsDown() ) then
			surface.SetDrawColor( 52*1.35, 55*1.35, 76*1.35 )
			draw.SimpleText( self.label, "BRCS_MP_22", w/2, h/2, LabelHover, 1, 1 )
		elseif( self:IsDown() ) then
			surface.SetDrawColor( BRICKSCREDITSTORE.LUACONFIG.Themes.Accent )
			draw.SimpleText( self.label, "BRCS_MP_22", w/2, h/2, BRICKSCREDITSTORE.LUACONFIG.Themes.White, 1, 1 )
		else
			surface.SetDrawColor( 52, 55, 76 )
			draw.SimpleText( self.label, "BRCS_MP_22", w/2, h/2, TextNorm, 1, 1 )
		end
	else
		if( self:IsHovered() and !self:IsDown() ) then
			draw.RoundedBox( 3, 0, 0, w, h, Hover )
		elseif( self:IsDown() ) then
			draw.RoundedBox( 3, 0, 0, w, h, Down )
		end

		surface.SetDrawColor( BRICKSCREDITSTORE.LUACONFIG.Themes.White )
		draw.SimpleText( self.label, "BRCS_MP_22", w/2, h/2, BRICKSCREDITSTORE.LUACONFIG.Themes.White, 1, 1 )
	end
	
	if( not self.IconMat ) then return end

	surface.SetMaterial( self.IconMat )
	surface.DrawTexturedRect( 10, (h/2)-(IconSize/2), IconSize, IconSize )
end

function PANEL:SetInfo( label, IconMat, sColor )
	self.label = label or ""
	self.IconMat = IconMat or false
	self.sColor = sColor or false
end

vgui.Register( "brcs_vgui_button", PANEL, "DButton" )