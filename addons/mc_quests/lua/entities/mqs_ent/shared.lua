ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Quest Item"
ENT.Author = "Mactavish"

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "CModel")
	self:NetworkVar("Entity", 0, "TPly")
	self:NetworkVar("Entity", 1, "Reroot")
	self:NetworkVar("Bool", 0, "Distractible")
	self:NetworkVar("Bool", 1, "EnablePhys")
	self:NetworkVar("Bool", 2, "ShowPointer")
	self:NetworkVar("Int", 0, "UseHold")
	self:NetworkVar("Float", 0, "PickProgress")
end