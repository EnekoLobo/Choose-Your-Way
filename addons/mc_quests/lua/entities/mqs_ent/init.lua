AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	if not self.model then
		self.model = "models/props_junk/garbage_newspaper001a.mdl"
	end

	self:SetModel(self.model)
	self:SetCModel(self.model)
	self:SetTPly(self.task_ply)
	self:SetShowPointer(self.pointer)
	self:SetEnablePhys(self.enablephys)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetSolid(SOLID_VPHYSICS)
	self:Activate()
end

function ENT:PickUP(ply)
	if self.pickedup then return end
	self.pickedup = true

	if self.updateobj then
		MQS.UpdateObjective(ply, self.updateobj)
	else
		MQS.SetSelfNWdata(ply, "quest_colected", MQS.GetSelfNWdata(ply, "quest_colected") + 1)

		if MQS.GetSelfNWdata(ply, "quest_colected") >= MQS.GetSelfNWdata(ply, "quest_ent") then
			MQS.UpdateObjective(ply)
		end
	end

	self.save_remove = true
	SafeRemoveEntity(self)
end

function ENT:Use(ply)
	if not IsValid(ply) then return end
	local q = MQS.HasQuest(ply)

	if not q then return end
	if ply ~= self.task_ply then
		for _, ent in pairs(self.allies) do
			if IsValid(ent) and ply == ent.task_ply then
				ent:Use(ply)
				net.Start("MQS.FixPickUP")
					net.WriteEntity(ent)
				net.Send(ply)
				break
			end
		end
		return
	end

	if MQS.Quests[q.quest].objects[MQS.GetNWdata(ply, "quest_objective") or 0].type ~= "Collect quest ents" then
		return
	end

	if self:GetUseHold() then
		if not self.StartPicking then
			self.StartPicking = CurTime()
			self.pickply = ply
		end
		return
	end
	self:PickUP(ply)
end

function ENT:Think()
	self:NextThink(CurTime())

	if self.StartPicking and self:GetUseHold() and IsValid(self.pickply) and self.pickply:KeyDown(IN_USE) and self.pickply:GetPos():DistToSqr(self:GetPos()) < 40000 then
		local progress = (self.StartPicking + self:GetUseHold() - CurTime()) / self:GetUseHold()
		progress = 1 - progress
		if progress >= 1 then
			self:PickUP(self.pickply)
			self.StartPicking = nil
			self:SetPickProgress(0)
			self.pickply = nil
			return true
		end
		self:SetPickProgress(progress)
	else
		self.StartPicking = nil
		self:SetPickProgress(0)
		self.pickply = nil
	end
	return true
end

function ENT:OnRemove()
	if MQS.ActiveTask[self.task_id] then
		table.RemoveByValue(MQS.ActiveTask[self.task_id].ents, self:EntIndex())
	end

	if not self.save_remove and IsValid(self.task_ply) then
		if self.pickedup then return end
		self.pickedup = true
		MQS.SetSelfNWdata(self.task_ply, "quest_ent", MQS.GetSelfNWdata(self.task_ply, "quest_ent") - 1)

		if MQS.GetSelfNWdata(self.task_ply, "quest_colected") >= MQS.GetSelfNWdata(self.task_ply, "quest_ent") then
			MQS.UpdateObjective(self.task_ply)
		end
	end

	if self.task_ply then
		MQS.ActiveDataShare(self.task_ply)
	end
end