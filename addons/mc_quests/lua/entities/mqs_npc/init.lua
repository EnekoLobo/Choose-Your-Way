AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
util.AddNetworkString("MQS.OpenNPCMenu")

function ENT:Initialize()
	self.MQSNPC = true
	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetNPCState(NPC_STATE_SCRIPT)
end

function ENT:AcceptInput(istr, ply)
	if IsValid(ply) and (not ply.UseTimer or ply.UseTimer < CurTime()) then
		ply.UseTimer = CurTime() + 2
		net.Start("MQS.OpenNPCMenu")
		net.WriteEntity(self)
		net.Send(ply)
	end
end

function ENT:Think()
	self:NextThink( CurTime() )
	return true
end