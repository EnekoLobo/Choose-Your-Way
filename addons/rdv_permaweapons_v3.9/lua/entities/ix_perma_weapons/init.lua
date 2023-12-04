AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    if RDV and RDV.PERMAWEAPONS then
        self:SetModel(table.Random(RDV.PERMAWEAPONS.CFG.Models))
    end

    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_BBOX)
    self:SetHullType(HULL_HUMAN)
    self:SetHullSizeNormal()
    self:SetNPCState(NPC_STATE_SCRIPT)
    self:CapabilitiesAdd(CAP_ANIMATEDFACE)
    self:CapabilitiesAdd(CAP_TURN_HEAD)
    self:SetUseType(SIMPLE_USE)
    self:DropToFloor()

    local TRIES = 0

    local function Randomize()
        if TRIES >= 50 then return end
        TRIES = TRIES + 1

        timer.Simple(0, function()
            if RDV and RDV.PERMAWEAPONS and IsValid(self) then
                self:ResetSequence(table.Random(RDV.PERMAWEAPONS.CFG.Stances))

                if RDV.PERMAWEAPONS.CFG.Randomize then
                    local COUNT = self:SkinCount()
                    local SKIN = math.random(1, COUNT)

                    self:SetSkin(SKIN)

                    for k, v in ipairs(self:GetBodyGroups()) do
                        local STACK = v.submodels
                        local _, key = table.Random(STACK)

                        self:SetBodygroup(k, key)
                    end
                end
            else
                Randomize()
            end
        end)
    end

    Randomize()


    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
        phys:EnableMotion(false)
    end
end

function ENT:Use(activator)
    activator.ixPermaWeapons = activator.ixPermaWeapons or {}
    
    local COUNT = 0

    for k, v in pairs(activator.ixPermaWeapons) do
        COUNT = COUNT + 1    
    end

    net.Start("ix.PermaWeapons.Menu")
        net.WriteUInt(table.Count(activator.ixPermaWeapons), 8)

        for k, v in pairs(activator.ixPermaWeapons) do
            net.WriteString(k)
            net.WriteBool(v.Equipped)
        end
    net.Send(activator)
end