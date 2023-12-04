AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	if( BRICKSCRAFTING.CONFIG.Resources[self.ResourceType] ) then
		self:SetModel( BRICKSCRAFTING.CONFIG.Resources[self.ResourceType].model )
	else
		self:SetModel( "models/props_wasteland/cafeteria_table001a.mdl" )
	end
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end

	self:SetAmount( 1 )
end

function ENT:Use( ply )
	if( IsValid( ply ) ) then
		if( BRICKSCRAFTING.CONFIG.Resources[self.ResourceType] ) then
			ply:AddBCS_InventoryResource( {[self.ResourceType] = (self:GetAmount() or 1)}, self.dropped )
			ply:NotifyBCS_Chat( "+" .. (self:GetAmount() or 1) .. " " .. (self.ResourceType or ""), BRICKSCRAFTING.CONFIG.Resources[self.ResourceType].icon )
			self:Remove()
		end
	end
end