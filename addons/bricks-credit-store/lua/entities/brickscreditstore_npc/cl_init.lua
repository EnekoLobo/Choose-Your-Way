include( "shared.lua" )

local Padding = 10
function ENT:Draw()
	self:DrawModel()

	local ang = self:GetAngles()

	local ShopName = self:Getnpc_type() or self.PrintName

    local Pos = self:GetPos()
    local Ang = self:GetAngles()

    Ang:RotateAroundAxis(Ang:Up(), 90)
	Ang:RotateAroundAxis(Ang:Forward(), 90)

	local YPos = -(self:OBBMaxs().z*10)-5

	local Distance = LocalPlayer():GetPos():DistToSqr( self:GetPos() )

	local AlphaMulti = 1-(Distance/BRICKSCREDITSTORE.LUACONFIG.DisplayDist3D2D)
	if( Distance < BRICKSCREDITSTORE.LUACONFIG.DisplayDist3D2D ) then
		surface.SetAlphaMultiplier( AlphaMulti )

		cam.Start3D2D(Pos + Ang:Up() * 0.5, Ang, 0.1)
		
			surface.SetFont("BRCS_MP_30")
		
			local width, height = surface.GetTextSize( ShopName )

			draw.RoundedBox( 5, -(width/2)-Padding, YPos-(height+(2*Padding)), width+(2*Padding), height+(2*Padding), BRICKSCREDITSTORE.LUACONFIG.Themes.Primary )	

			draw.SimpleText( ShopName, "BRCS_MP_30", 0, YPos-((height+(2*Padding))/2), BRICKSCREDITSTORE.LUACONFIG.Themes.White, 1, 1 )
			
		cam.End3D2D()

		surface.SetAlphaMultiplier( 1 )
	end
end


net.Receive( "BRCS_Net_UseNPC", function( len, ply )
	local NPCType = net.ReadString()
	
	BRICKSCREDITSTORE.OpenStore( NPCType )
end )