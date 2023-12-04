AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName = "Lado Luminoso +1000"
ENT.Category = "forceAlign"
ENT.Spawnable = true
ENT.AdminSpawnable = true

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end

function ENT:Initialize()
	if CLIENT then return end

	self:SetModel("models/kingpommes/starwars/misc/jedi/jedi_holocron_closed.mdl");
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:SetSolid(SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE);
end

function ENT:Use()

	self:Remove()
	
end