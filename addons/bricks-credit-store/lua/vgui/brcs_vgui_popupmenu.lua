local PANEL = {}

function PANEL:Init()
	self:SetSize( 150, 45 )
	self:MakePopup()

	self:SetAlpha( 0 )
	self:AlphaTo( 255, 0.05, 0 )

	self.OptionCount = 0
end

local function PopupRemove( parentSelf, noStay )
	if( not IsValid( parentSelf ) or not IsValid( parentSelf.parent ) ) then return false end

	if( noStay ) then return true end

	if( parentSelf:IsHovered() ) then
		return false
	end

	if( parentSelf.bounds ) then
		local bounds = parentSelf.bounds
		local cPosX, cPosY = input.GetCursorPos()
		if( cPosX > bounds[1] and cPosY > bounds[2] and cPosX < bounds[1]+bounds[3] and cPosY < bounds[2]+bounds[4] ) then
			return false
		end
	end

	for k, v in pairs( parentSelf:GetChildren() ) do
		if( v:IsHovered() ) then
			return false
		end
	end

	return true
end

local TriangleSizeW, TriangleSizeH = 10, 15
local OptionH = 45
function PANEL:AddOption( label, onClick, material )
	self.OptionCount = self.OptionCount+1

	self:SetTall( self.OptionCount*OptionH )
	
	local OptionButton = vgui.Create( "DButton", self )
	OptionButton:Dock( TOP )
	OptionButton:DockMargin( TriangleSizeW, 0, 0, 0 )
	OptionButton:SetTall( OptionH )
	OptionButton:SetText( "" )
	OptionButton.OptionPos = self.OptionCount
	local BackgroundColor = Color( 0, 0, 0, 0 )
	local TextColor = Color( 101, 107, 145 )
	local IconMat = material and Material( material, "noclamp smooth" ) or false
	OptionButton.Paint = function( self2, w, h )
		if( self2:IsHovered() and !self2:IsDown() ) then
			BackgroundColor = Color( 0, 0, 0, 25 )
			TextColor = Color( 101*1.35, 107*1.35, 145*1.35 )
		elseif( self2:IsDown() ) then
			BackgroundColor = Color( 0, 0, 0, 50 )
			TextColor = BRICKSCREDITSTORE.LUACONFIG.Themes.White
		else
			BackgroundColor = Color( 0, 0, 0, 0 )
			TextColor = Color( 101, 107, 145 )
		end

		if( (self2.OptionPos or 0) == 1 and self.OptionCount > 1 ) then
			draw.RoundedBoxEx( 5, 0, 0, w, h, BackgroundColor, true, true, false, false)
		elseif( (self2.OptionPos or 0) == self.OptionCount and self.OptionCount > 1 ) then
			draw.RoundedBoxEx( 5, 0, 0, w, h, BackgroundColor, false, false, true, true)
		else
			surface.SetDrawColor( BackgroundColor )
			surface.DrawRect( 0, 0, w, h )
		end

		draw.SimpleText( label, "BRCS_MP_20", w/2, h/2, TextColor, 1, 1 )

		if( material ) then
			local IconSize = h*0.45
			surface.SetDrawColor( TextColor )
			surface.SetMaterial( IconMat )
			surface.DrawTexturedRect( 10, (h/2)-(IconSize/2), IconSize, IconSize )
		end
	end
	OptionButton.DoClick = onClick
	OptionButton.OnCursorExited = function( self2 )
		if( PopupRemove( self ) ) then 
			self:AlphaTo( 0, 0.05, 0, function()
				if( IsValid( self ) ) then
					self:Remove()
				end
			end )
		end
	end
end

function PANEL:SetPopupParent( parent, x, y, w, h, noStay )
	self.parent = parent
	self.bounds = { x, y, w, h }
	parent.OnCursorExited = function( self2 )
		if( PopupRemove( self, noStay ) ) then 
			self:AlphaTo( 0, 0.05, 0, function()
				if( IsValid( self ) ) then
					self:Remove()
				end
			end )
		end
	end
	self.OnCursorExited = function( self2 )
		if( PopupRemove( self ) ) then 
			self:AlphaTo( 0, 0.05, 0, function()
				if( IsValid( self ) ) then
					self:Remove()
				end
			end )
		end
	end
end

function PANEL:Think()
	if( not IsValid( self.parent ) ) then
		self:Remove()
	end
end

function PANEL:SetDescription( text )
	self:Clear()

	local Description = vgui.Create( "DLabel", self )
	local MarginSide = 10
	Description:SetPos( TriangleSizeW+MarginSide, MarginSide )
	Description:SetFont( "BRCS_MP_20" )
	Description:SetTextColor( BRICKSCREDITSTORE.LUACONFIG.Themes.White )
	Description:SetText( text )
	Description:SizeToContentsX( TriangleSizeW+(2*MarginSide) )
	Description:SizeToContentsY()

	local DWide, DTall = Description:GetSize()
	self:SetSize( DWide, DTall+(2*MarginSide) )
end

function PANEL:Paint( w, h )
	local x, y = self:LocalToScreen( 0, 0 )

	local triangle = {
		{ x = x, y = y+(h/2) },
		{ x = x+TriangleSizeW, y = y+(h/2)-(TriangleSizeH/2) },
		{ x = x+TriangleSizeW, y = y+(h/2)+(TriangleSizeH/2) }
	}

	BSHADOWS.BeginShadow()
	draw.RoundedBox( 5, x+TriangleSizeW, y, w-TriangleSizeW, h, BRICKSCREDITSTORE.LUACONFIG.Themes.Secondary )	
	surface.SetDrawColor( BRICKSCREDITSTORE.LUACONFIG.Themes.Secondary )
	draw.NoTexture()
	surface.DrawPoly( triangle )
	BSHADOWS.EndShadow(2, 2, 1, 255, 0, 0, false )
end

vgui.Register( "brcs_vgui_popupmenu", PANEL, "DPanel" )