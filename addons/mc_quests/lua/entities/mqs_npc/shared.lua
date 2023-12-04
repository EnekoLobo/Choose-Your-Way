ENT.Type = "ai"
ENT.Base = "base_anim"
ENT.PrintName = "MQS Quest NPC"
ENT.Author = "Mactavish"
ENT.Spawnable = false
ENT.AdminSpawnable = true

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "Namer")
	self:NetworkVar("Int", 1, "UID")
end