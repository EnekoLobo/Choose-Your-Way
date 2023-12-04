AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	if( BRICKSCRAFTING.CONFIG.WoodCutting[self.TreeType] ) then
		self:SetModel( BRICKSCRAFTING.CONFIG.WoodCutting[self.TreeType].model )
	else
		self:SetModel( BRICKSCRAFTING.LUACONFIG.Defaults.TreeModel )
	end
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
	self:GetPhysicsObject():EnableMotion( false )
	
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end