if SERVER then return end
local scrx, scry = ScrW(), ScrH()
local chargeActive = false
include("shared.lua")
function drawcharge(isCharge)
	local globalwep = weapons.GetStored("weapon_defibrillator")
	local activewep = LocalPlayer():GetActiveWeapon()
	if isCharge then
		if CurTime() >= globalwep.CanUse and !chargeActive then
			frame = vgui.Create("DPanel")
			frame:SetSize(400, 60)
			frame:SetPos(scrx/2-200, 55)
			function frame:Paint(w, h) draw.RoundedBox(30, 0, 0, w, h, Color(80, 80, 80, 200)) end
			local bar = vgui.Create("DShape", frame)
			bar:SetType("Rect")
			bar:SetColor(Color(0, 200, 0, 245))
			bar:SetSize(350, 30)
			bar:SetPos(scrx/2-200, scry/2-30)
			bar:Center()
			local repeats = math.Round(globalwep.ChargeTime*30)
			local i = 1
			timer.Create("fadethething", 0.01, 0, function()
				local colstep = math.Min(200, i*(200/repeats))
				function bar:Paint(w,h) draw.RoundedBox(8, 0, 0, w, h, Color(-5+colstep, 205-colstep, 0, 245)) end
				local num = math.Min(350, i*(350/repeats))
				bar:SetSize(350 - num, 30)
				i = i + 1
				if num >= 350 then frame:Remove(); timer.Destroy("fadethething"); end
			end)
		end
	else
		if frame != nil then
			frame:Remove()
			if timer.Exists("fadethething") then timer.Destroy("fadethething") end
		end
	end
end
local hasswep = false
net.Receive("defibfx", function(len)
	local globalwep = weapons.GetStored("weapon_defibrillator")
	local ent = net.ReadEntity()
	local entpos = net.ReadVector()
	local fx = net.ReadString()
	local ply = net.ReadEntity()
	if fx == "spark" then
		local sparkData = EffectData()
		sparkData:SetStart(LocalPlayer():GetShootPos()+LocalPlayer():GetForward(50))
		sparkData:SetEntity(LocalPlayer())
		sparkData:SetOrigin(entpos)
		util.Effect("StunstickImpact", sparkData)
	elseif fx == "tracer" then
		local traceData = EffectData()
		traceData:SetStart(ply:GetShootPos())
		traceData:SetOrigin(ply:GetEyeTrace().HitPos)
		util.Effect("ToolTracer", traceData)
	elseif fx == "sound" then
		surface.PlaySound(globalwep.DeathSound)
	elseif fx == "charge" then
		drawcharge(true)
	elseif fx == "decharge" then
		drawcharge(false)
	elseif fx == "toolongdead" then
		if entpos == Vector(1, 1, 1) then notification.AddLegacy("He's dead. Really dead.", 1, 6)
		else notification.AddLegacy("You're dead. Really dead.", 1, 6) end
	elseif fx == "timedied" then
		ply.TimeDied = CurTime()
	end
end)
net.Receive("defibgetents", function(len)
	local globalwep = weapons.GetStored("weapon_defibrillator")
	local ply = LocalPlayer()
	local isRevive, otherPly, pos
	for k,v in pairs(ents.FindInSphere(ply:GetPos(), 164)) do
		if v:GetClass() == "prop_ragdoll" or v:GetClass() == "class C_HL2MPRagdoll" and ply:GetPos():Distance(v:GetPos()) <= globalwep.ReviveDistance and ply:GetEyeTrace().HitPos:Distance(v:GetPos()) < globalwep.ReviveDistance and IsValid(v:GetRagdollOwner()) then
			isRevive = true
			otherPly = v:GetRagdollOwner()
			pos = v:GetPos()
		end
	end
	if !isRevive then 
		local lookatent = ply:GetEyeTrace().Entity
		if lookatent:IsPlayer() and ply:GetPos():Distance(lookatent:GetPos()) <= globalwep.HitDistance then 
			isRevive = false
			otherPly = lookatent
			pos = lookatent:GetPos()
		end
	end
	if pos == nil then return end
	net.Start("defibgiveents")
	net.WriteBool(isRevive)
	net.WriteEntity(otherPly)
	net.WriteVector(pos)
	net.SendToServer()
end)
hook.Add("HUDPaint", "DrawDefibGUI", function()
	local globalwep = weapons.GetStored("weapon_defibrillator")
	local isDefib = LocalPlayer():GetActiveWeapon().PrintName == "Defibrillator"
	local medicsOnly = globalwep.ReviveHeartMedicsOnly
	if isDefib and medicsOnly or !medicsOnly then
		for k,v in pairs(ents.GetAll()) do
			local otherply = v:GetRagdollOwner()
			if v:GetClass() == "class C_HL2MPRagdoll" and otherply.TimeDied != nil and (otherply.TimeDied+globalwep.TimeToRevive)-CurTime() > 0 then
				local dist = LocalPlayer():GetPos():Distance(v:GetPos())
				if dist <= globalwep.ReviveHeartDistance then
					cam.Start2D()
					local bodyPos = v:GetPos()
					local heartPos = (bodyPos + Vector(0, 0, 30+dist/20)):ToScreen()
					heartPos.x = heartPos.x - (28-(dist/100))
					surface.SetDrawColor(255, 255, 255, 255)
					surface.SetMaterial(Material("vgui/revive.png"))
					local size = math.Round(math.max(80 - (dist/100)*4.2, 5))
					surface.DrawTexturedRect(heartPos.x, heartPos.y, size, size)
					cam.End2D()
				end
			end
		end
	end
	if globalwep.enableRespawnText and globalwep.disableRespawnTime != 0 and LocalPlayer():Health() <= 0 and LocalPlayer().TimeDied != nil then
		local timeLeft = (LocalPlayer().TimeDied+globalwep.disableRespawnTime) - CurTime()
		if timeLeft >= 0 then
			local text = string.format(globalwep.respawnWaitText, timeLeft)
			local textX = globalwep.textXPos
			local textY = globalwep.textYPos
			if textX == -1 or textY == -1 then
				textX = ScrW()/2
				textY = ScrH()/2
			end
			draw.SimpleTextOutlined(text, globalwep.respawnFont, textX, textY, globalwep.textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, 255))
		end
	end
end)
hook.Add("PostPlayerDraw", "DefibTwoHanded", function(ply)
	local model = ply.Defib
	local attach = ply:GetAttachment(ply:LookupAttachment("anim_attachment_LH"))
	if !ply or !ply:Alive() or ply:GetActiveWeapon() == NULL or ply:GetActiveWeapon():GetClass() != "weapon_defibrillator" or !attach then 
		if ply.Defib then ply.Defib:Remove(); ply.Defib = nil; end
		return
	end
	local color = Color(255, 255, 255)
	if model == nil then
		ply.Defib = ClientsideModel("models/weapons/custom/defib2.mdl")
		model = ply.Defib
	end
	local pos, ang = attach.Pos, attach.Ang
	ang:RotateAroundAxis(ang:Up(), 90)
	ang:RotateAroundAxis(ang:Right(), -60)
	ang:RotateAroundAxis(ang:Forward(), 45)
	pos = attach.Pos + ang:Forward()*0 + ang:Right()*1.5 + ang:Up()*2
	model:SetColor(color)
	model:SetRenderOrigin(pos)
	model:SetRenderAngles(ang)
	model:SetupBones()
	model:DrawModel()
	model:SetRenderOrigin()
	model:SetRenderAngles()
end)