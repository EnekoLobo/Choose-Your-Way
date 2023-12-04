AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel(Aden_DC.Config.NPCModel)
    self:SetSolid(SOLID_BBOX)
    self:SetHullType(HULL_HUMAN)
    self:SetUseType(SIMPLE_USE)
end

function ENT:Use(ply)
    if IsValid(ply) then
        Aden_DC:openMenu(ply)
    end
end
