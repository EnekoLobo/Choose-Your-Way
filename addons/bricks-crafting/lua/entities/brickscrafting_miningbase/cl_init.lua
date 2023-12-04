include('shared.lua')

function ENT:Draw()
	self:DrawModel()

	if( self:GetEgg() ) then
		self:SetColor( Color( math.random( 0, 255 ), math.random( 0, 255 ), math.random( 0, 255 ) ) )
		return
	end

	if( BRICKSCRAFTING.CONFIG.Mining[self.MiningType or ""] ) then
		if( BRICKSCRAFTING.CONFIG.Mining[self.MiningType or ""].material ) then
			self:SetMaterial( BRICKSCRAFTING.CONFIG.Mining[self.MiningType or ""].material )
		end		
		if( BRICKSCRAFTING.CONFIG.Mining[self.MiningType or ""].color ) then
			self:SetColor( BRICKSCRAFTING.CONFIG.Mining[self.MiningType or ""].color )
		end
	end
end