
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
 
ENT.PrintName		= BRICKSCRAFTING.L("garbagePile")
ENT.Category		= "Bricks Crafting"
ENT.Author			= "Brick Wall"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable		= true

function ENT:SetupDataTables()
    self:NetworkVar( "Entity", 0, "Collector" )
    self:NetworkVar( "Int", 0, "GarbageKey" )
end