include("shared.lua")

function ENT:Initialize()
	if self:GetEnablePhys() then return end
	self:InitRenderModel()
end

function ENT:InitRenderModel()
	self.RenderModel = ClientsideModel(self:GetCModel())
	self.RenderModel:SetPos(self:GetPos())
	self.RenderModel:SetParent(self)
	self.RenderModel:SetMaterial(self:GetMaterial())
	self.RenderModel:SetColor(self:GetColor())
	self:CallOnRemove("RenderModel", function()
		SafeRemoveEntity(self.RenderModel)
	end)
end

local questarrows = {}

function ENT:Draw()
	local Pos = self:GetPos()
	local Ang = self:GetAngles()
	local planeNormal = Ang:Up()
	if Pos:DistToSqr(LocalPlayer():GetPos()) > MQS.Config.QuestEntDrawDist ^ 2 then return end

	if self:GetEnablePhys() then
		self:DrawModel()
	else
		local sysTime = SysTime()
		local rotAng = Angle(Ang)
		self.rotationOffset = sysTime % 360 * 130
		rotAng:RotateAroundAxis(planeNormal, self.rotationOffset)

		if not IsValid(self.RenderModel) then
			self:InitRenderModel()
		end

		self.RenderModel:SetPos(Pos)
		self.RenderModel:SetAngles(rotAng)
	end

	if self:GetTPly() ~= LocalPlayer() then return end

	if not self:GetShowPointer() then return end

	if not questarrows[self] then questarrows[self] = true end
end

function ENT:OnRemove()
	questarrows[self] = nil
end

hook.Add( "PostDrawTranslucentRenderables", "DrawQuestIndicators", function( bDepth, bSkybox )
	for ent, _ in pairs(questarrows) do
		if not IsValid(ent) then return end

		local Pos = ent:GetPos()
		local eye = EyeAngles()

		if Pos:DistToSqr(LocalPlayer():GetPos()) > MQS.Config.QuestEntDrawDist ^ 2 then return end

		local q = MQS.HasQuest(LocalPlayer())

		if not q then return end

		if MQS.Quests[q.quest].objects[MQS.GetNWdata(LocalPlayer(), "quest_objective") or 0].type ~= "Collect quest ents" then
			continue
		end

		local max = ent:OBBMaxs()
		Pos.z = Pos.z + max.z + (20 + math.sin(CurTime() * 2) * 5)

		cam.Start3D2D(Pos, Angle(0,eye.y - 90,90), 0.2)
			MSD.DrawTexturedRect(-23, -23, 48, 64, MSD.Icons48.arrow_down_color, color_white)
		cam.End3D2D()
	end
end)