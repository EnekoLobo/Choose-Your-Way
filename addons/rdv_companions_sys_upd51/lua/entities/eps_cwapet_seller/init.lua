AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local COL_WHITE = Color(255,255,255)

local function SendNotification(ply, msg)
    local CFG = {
		Appension = RDV.LIBRARY.GetConfigOption("COMP_prefix"),
		Color = RDV.LIBRARY.GetConfigOption("COMP_prefixColor"),
	}

	RDV.LIBRARY.AddText(ply, CFG.Color, "["..CFG.Appension.."] ", COL_WHITE, msg)
end

function ENT:Initialize()
    self:SetModel("models/Humans/Group01/Female_01.mdl")
    self:SetSolid(SOLID_BBOX)
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
            if IsValid(self) then
                if RDV.LIBRARY.GetConfigOption("COMP_randomize") then
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
    local TAB = RDV.COMPANIONS.CFG.Restriction

    if TAB and !table.IsEmpty(TAB) then
        if TAB[activator:GetUserGroup()] then
            goto success
        end

        SendNotification(activator, RDV.LIBRARY.GetLang(nil, "COMP_noMarketAccess"))

        return
    end

    ::success::

    net.Start("RDV_COMP_VendorMenu")
    net.Send(activator)
end