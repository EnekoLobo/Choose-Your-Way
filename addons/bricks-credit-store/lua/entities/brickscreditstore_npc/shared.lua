ENT.Base = "base_ai" 
ENT.Type = "ai"
 
ENT.PrintName		= "Store Base"
ENT.Category		= "Bricks Credit Store"
ENT.Author			= "Brick Wall"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable		= false

function ENT:SetupDataTables()
    self:NetworkVar( "Int", 0, "UseCooldown" )
    self:NetworkVar( "String", 0, "npc_type" )
end