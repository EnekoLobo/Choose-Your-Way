AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName = "Lado Oscuro +50"
ENT.Category = "forceAlign"
ENT.Spawnable = true
ENT.AdminSpawnable = true

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end

function ENT:Use()

	self:Remove()
	
end

function ENT:Initialize()
	if CLIENT then return end

	self:SetModel("models/lordtrilobite/starwars/props/holocron_sith01.mdl");
	self:PhysicsInit(SOLID_VPHYSICS);
	self:SetMoveType(MOVETYPE_VPHYSICS);
	self:SetSolid(SOLID_VPHYSICS);
	self:SetUseType(SIMPLE_USE);
end