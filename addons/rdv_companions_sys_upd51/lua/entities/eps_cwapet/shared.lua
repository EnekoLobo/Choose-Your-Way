if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)

ENT.RenderGroup = RENDERGROUP_BOTH
ENT.PrintName = "Companion Base"
ENT.Category = "Other"
ENT.BehaviourType = AI_BEHAV_CUSTOM
ENT.Spawnable = false

function ENT:SetupDataTables()
	self:NetworkVar( "Entity", 0, "PetOwner" )
	self:NetworkVar( "String", 0, "PetType" )
	self:NetworkVar( "Entity", 1, "FollowTarget" )
	self:NetworkVar( "String", 1, "CurrentAbility" )
	self:NetworkVar( "Bool", 1, "HealthEnabled" )
end
