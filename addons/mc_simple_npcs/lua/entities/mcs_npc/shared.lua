AddCSLuaFile()
ENT.Type = "ai"
ENT.Base = "base_anim"
ENT.PrintName = "Simple NPC"
ENT.Author = "Mactavish"
ENT.Spawnable = false
ENT.AdminSpawnable = true

function ENT:Initialize()
	self.SimpleNPC = true
	self.UsingPlayer = false
	self.names = 0

	if SERVER then
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		self:CapabilitiesAdd(CAP_ANIMATEDFACE)
	end
	self.ClModels = MCS.Spawns[self:GetUID()] and MCS.Spawns[self:GetUID()].ClModels or {}

	if CLIENT and self.ClModels then
		self.mdls = {}
		self.msdW = 0
		for k, v in ipairs(self.ClModels) do
			self.mdls[k] = ents.CreateClientProp()
			self.mdls[k]:SetModel( v.model )
			self.mdls[k]:SetSkin( v.skin or 0 )
			self.mdls[k]:InvalidateBoneCache()
			self.mdls[k]:SetMoveType(MOVETYPE_NONE)
			self.mdls[k]:SetParent( self )

			if v.marge then
				self.mdls[k]:AddEffects(EF_BONEMERGE)
				self.mdls[k]:AddEffects(EF_BONEMERGE_FASTCULL)
				self.mdls[k]:AddEffects(EF_PARENT_ANIMATES)
				self.mdls[k].marge = true
			else
				self.mdls[k]:SetPos(self:LocalToWorld(v.pos))
				self.mdls[k]:SetAngles( self:GetAngles() + v.ang )
				self.mdls[k].pos = v.pos
				self.mdls[k].ang = v.ang
				self.mdls[k].bone = v.bone
				local mat = Matrix()
				local scale = (v.scale or 1) * self:GetModelScale()
				mat:Scale(Vector(scale,scale,scale))
				self.mdls[k]:EnableMatrix("RenderMultiply", mat)
			end
			self.mdls[k]:Spawn()
		end
	end
end

function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "Namer")
	self:NetworkVar("String", 1, "UID")
	self:NetworkVar("String", 2, "DefAnimation")
	self:NetworkVar("Bool", 0, "InputLimit")
end

function ENT:Think()
	local CT = CurTime()

	if SERVER and self:GetInputLimit() and self.UsingPlayer ~= false and not IsValid(self.UsingPlayer) then
		self.UsingPlayer = false
	end

	if SERVER and self.timer and self.timer < CT and not self.UsingPlayer then
		self:Remove()
		return true
	end

	if CLIENT then
		if not self.flexes then
			self.flexes = {
				self:GetFlexIDByName( "jaw_drop" ),
				self:GetFlexIDByName( "left_part" ),
				self:GetFlexIDByName( "right_part" ),
				self:GetFlexIDByName( "left_mouth_drop" ),
				self:GetFlexIDByName( "right_mouth_drop" )
			}
		end

		local weight = (MCS.Dialogue and MCS.Dialogue.Sound ) and math.Clamp(MCS.Dialogue.Sound:GetLevel() * 1.1, 0, 1 ) or 0

		for k, v in pairs( self.flexes ) do
			if not v then continue end
			self:SetFlexWeight( v, weight)
		end
	end


	self:NextThink(CT)

	return true
end

if SERVER then
	function ENT:GotScared(ply, data)
		local npct = MCS.Spawns[self:GetUID()]
		if not npct then return end

		self:ResetSequence(npct.scare_anim[1])
		self:SetCycle(0)
		self.LastAnim = CurTime()
		self.scared = true

		if npct.scare_sound then
			self:EmitSound(npct.scare_sound)
		end

		if npct.do_scare then
			npct.do_scare(self, ply, data)
		end

		timer.Simple(npct.scare_timer, function()
			if not IsValid(self) then return end
			self:ResetSequence(npct.scare_anim[2])
			self:SetCycle(0)
			self.LastAnim = CurTime()
			self.scared = nil

			if npct.do_unscare then
				npct.do_unscare(self, ply, data)
			end
		end)
	end

	function ENT:AcceptInput(istr, ply)
		if self.scared then return end

		if not IsValid(ply) or (ply.UseTimer and ply.UseTimer > CurTime()) then return end

		ply.UseTimer = CurTime() + MCS.Config.UseDelay

		if self:GetInputLimit() then
			if self.UsingPlayer then
				return
			else
				self.UsingPlayer = ply
			end

			if self.timer then
				self.timer = self.timer + 120
			end
		end

		net.Start("MCS.OpenMenu")
		net.WriteEntity(self)
		net.Send(ply)
	end

	function ENT:OnTakeDamage(data)
		if self.scared then return end

		local attc = data:GetAttacker()

		if self.canscare and IsValid(attc) and attc:IsPlayer() then
			self:GotScared(attc, data)
		end
	end
else
	function ENT:Draw()
		self:DrawModel()

		local p_dist = self:GetPos():DistToSqr(LocalPlayer():GetPos())

		if p_dist > 100000 then return end

		local npct = MCS.Spawns[self:GetUID()]

		if not npct then return end

		local Pos = self:GetPos()
		local Ang = self:GetAngles()
		local eyepos = EyePos()
		local planeNormal = Ang:Up()

		Ang:RotateAroundAxis(Ang:Forward(), 90)

		if npct.namepos then
			local bone = self:LookupBone(npct.nametobone or "")
			if npct.nametobone and bone then
				Pos = MCS.GetBoneOrientation(self, bone, Pos, Ang)
			end

			Pos.z = Pos.z + (npct.namepos * self:GetModelScale())
		else
			Pos.z = Pos.z + (77 * self:GetModelScale())
		end

		local relativeEye = eyepos - Pos
		local relativeEyeOnPlane = relativeEye - planeNormal * relativeEye:Dot(planeNormal)
		local textAng = relativeEyeOnPlane:AngleEx(planeNormal)

		textAng:RotateAroundAxis(textAng:Up(), 90)
		textAng:RotateAroundAxis(textAng:Forward(), 90)
		local hover = Vector(0,0,-2)
		if MCS.Config.NPCNameHover then
			hover = Ang:Right() * math.sin(CurTime()) * 0.9
		end

		if not npct.noinfo then
			cam.Start3D2D(Pos - hover, textAng, 0.1)
				draw.RoundedBox(0, -self.names / 2 - 10, 0, self.names + 20, 35, MSD.Theme.m)
				MCS.Frame( -self.names / 2 - 10, 0, self.names + 20, 35, 10, MSD.Theme.d, color_white)
				self.names = draw.SimpleText(self:GetNamer(), "MSDFont.32", 0, 0, color_white, TEXT_ALIGN_CENTER, 0)
			cam.End3D2D()
		end

		if not self.mdls then return end
		for k,v in ipairs(self.mdls) do
			if not IsValid(v) then continue end
			if v.bone then
				local pos, ang = MCS.GetBoneOrientation(self, v.bone, v.pos, v.ang, self:GetModelScale())
				ang:RotateAroundAxis(ang:Up(), v.ang.y)
				ang:RotateAroundAxis(ang:Right(), v.ang.p)
				ang:RotateAroundAxis(ang:Forward(), v.ang.r)
				v:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z)
				v:SetAngles(ang)
				if v:GetParent() == NULL then
					v:SetParent(self)
				end
			end

			if v.marge and v:GetParent() == NULL then
				v:SetParent(self)
				v:AddEffects(EF_BONEMERGE)
				v:AddEffects(EF_BONEMERGE_FASTCULL)
				v:AddEffects(EF_PARENT_ANIMATES)
			end
		end
	end

	function ENT:OnRemove()
		if not self.mdls then return end
		for k,v in ipairs(self.mdls) do
			if IsValid(v) then
				v:Remove()
			end
		end
	end
end