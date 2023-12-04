local MODULE = MODULE
if SERVER then
    AddCSLuaFile()
end

SWEP.PrintName = 'Hands'
SWEP.Author = 'Kot'
SWEP.Purpose = 'Cool hands for cool players'
SWEP.Spawnable = true
SWEP.Category = 'MVP | Perfect Hands'
SWEP.ViewModel = 'models/weapons/c_medkit.mdl'
SWEP.WorldModel = ''
SWEP.AnimPrefix = 'rpg'
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = 'none'
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = 'none'
SWEP.DrawCrosshair = false

function SWEP:Initialize()
    self:SetHoldType('normal')
    self.range = 100

    self.ownerPos = Vector(0, 0, 0)
    self.ownerAim = Vector(0, 0, 0)
end

function SWEP:Think()
    self.ownerPos = self.Owner:GetShootPos()
    self.ownerAim = self.Owner:GetAimVector()

    if self.dragInfo then
        if not self.Owner:KeyDown(IN_ATTACK) then
            self.dragInfo = nil
        end
    end

end

function SWEP:CanDragEntity(ent)
    return  ( IsValid(ent) ) and
            (not ent:IsPlayer() ) and
            ( not IsValid(ent:GetParent()) ) and
            ( ent:GetMoveType() == MOVETYPE_VPHYSICS ) and
            ( not ent:IsVehicle() ) and 
            ( not MODULE.config.blacklist[ent:GetClass()] )
end

function SWEP:TraceEntity()
    local tr = util.TraceLine({
        start = self.ownerPos,
        endpos = self.ownerPos + self.ownerAim * self.range,
        filter = self.Owner
    })

    return tr
end

local maxVolume = math.pow(10, 5.85) -- calculate only one time
function SWEP:DragEntity()
    if not self.dragInfo then return end
    if not IsValid(self.dragInfo.ent) then return end

    local physObject = self.dragInfo.ent:GetPhysicsObject()

    if not IsValid(physObject) then return end
    
    if physObject:GetVolume() > maxVolume then return end

    local pos = self.ownerPos + self.ownerAim * self.range * self.dragInfo.fraction
    local offset = self.dragInfo.ent:LocalToWorld( self.dragInfo.offset )

    local applyPos = pos - offset

    local force = (applyPos:GetNormal() * math.min(1, applyPos:Length() / 100) * 500 - physObject:GetVelocity()) * (physObject:GetMass() / mvp.config.Get('ph.weightMultiplier'))

    physObject:ApplyForceOffset(force, offset)
    physObject:AddAngleVelocity( - physObject:GetAngleVelocity() * 0.25)
end

function SWEP:PrimaryAttack()
    if not self.dragInfo then
        local tr = self:TraceEntity()
    
        local ent = tr.Entity

        if not self:CanDragEntity(ent) then return end -- we cant drag this shit bruh

        self.dragInfo = {
            ent = ent,
            offset = ent:WorldToLocal(tr.HitPos),
            fraction = tr.Fraction
        }
    end

    if CLIENT then return end

    self:DragEntity()
end

function SWEP:SecondaryAttack()
    if not mvp.config.Get('ph.animationSystem') then return end
    if not IsFirstTimePredicted() then return end
    if SERVER then
        MODULE.animations.Toggle(self.Owner, false)
        return 
    end

    if MODULE.camera.isActive then
        return 
    end

    if #MODULE.config.animations == 0 then
        return 
    end

    local m = MODULE.Menu()

    local theme = mvp.config.Get('ph.iconsTheme')
    

    if not MODULE.config.themes[theme] or not MODULE.config.themes[theme].icons then
        chat.AddText(COLOR_RED, 'You have not installed the icon pack, which is selected in the config. Please make sure that you have added the necessary icons to the server collection!')
        chat.AddText(COLOR_RED, 'You will be prompted to visit collection page on Steam workshop with avaible icon packs, choose what you like!')
        
        timer.Simple(3, function()
            gui.OpenURL('https://steamcommunity.com/sharedfiles/filedetails/?id=2741704281')
        end)
        return 
    end

    local icons = MODULE.config.themes[theme].icons

    local plyTeam = self.Owner:Team()

    if MODULE.config.iconsPerJob and MODULE.config.iconsPerJob[plyTeam] then
        icons = MODULE.config.themes[MODULE.config.iconsPerJob[plyTeam]].icons
    end

    

    for k, v in pairs(MODULE.config.animations) do
        
        m:AddOption(mvp.language.Get(v.title), mvp.language.Get(v.description), icons[v.id], function()
            net.Start('mvpPH.startAnimation')
                net.WriteInt(k, 8)
            net.SendToServer()
        end)
    end

    m:Open()
end

if SERVER then
    return 
end

surface.CreateFont('perfecthands.hint', {
    font = 'Proxima Nova Rg',
    size = 21,
    weight = 500,
    extended = true 
})

local w, h = ScrW, ScrH
local clrWhite = Color(255, 255, 255)
local dragIcon = Material('mvp/perfecthands/drag.png', 'mips smooth')

function SWEP:DrawHUD()
    if IsValid(self.Owner:GetVehicle()) then return end

    local tr = self:TraceEntity()
    local showIndicator = (IsValid(tr.Entity) and self:CanDragEntity(tr.Entity)) or self.dragInfo
    local showIndicatorHint = (IsValid(tr.Entity) and self:CanDragEntity(tr.Entity)) and not self.dragInfo

    self.alphaMult = Lerp(FrameTime() * 10, self.alphaMult or 0, showIndicator and 1 or 0)
    self.alphaMultHint = Lerp(FrameTime() * 10, self.alphaMultHint or 0, showIndicatorHint and 1 or 0)

    surface.SetAlphaMultiplier(self.alphaMult)
    surface.SetDrawColor(clrWhite)
    surface.SetMaterial(dragIcon)
    surface.DrawTexturedRect(w() * .5 - 16, h() * .5 - 16, 32, 32)

    surface.SetAlphaMultiplier(self.alphaMultHint)

    draw.SimpleText(mvp.language.Get('ph#LMBDrag'), 'perfecthands.hint', w() * .5 + 32, h() * .5, clrWhite, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

    surface.SetAlphaMultiplier(1)

    local pulsateSpeed = (math.cos(CurTime() * mvp.config.Get('ph.pulsateSpeed', 0.5)) + 0.5)

    local hintsPos = h() - 150
    if MODULE.camera.isActive and mvp.config.Get('freelook') then
        local x, y = draw.SimpleText(mvp.language.Get('ph#RLook'), 'perfecthands.hint', w() * .5, hintsPos, Color(255,255,255, 255 * pulsateSpeed), TEXT_ALIGN_CENTER)
        hintsPos = hintsPos + y
    end


    if MODULE.camera.isActive then
        local x, y = draw.SimpleText(mvp.language.Get('ph#RMBEnd'), 'perfecthands.hint', w() * .5, hintsPos, Color(255,255,255, 255 * pulsateSpeed), TEXT_ALIGN_CENTER)
        hintsPos = hintsPos + y
    else
        draw.SimpleText(mvp.language.Get('ph#RMBOpen'), 'perfecthands.hint', w() * .5, hintsPos, Color(255,255,255, 255 * pulsateSpeed), TEXT_ALIGN_CENTER)
    end

    if not self.dragInfo then
        return 
    end

    if not IsValid(self.dragInfo.ent) then
        return 
    end

    local offset = self.dragInfo.ent:LocalToWorld( self.dragInfo.offset ):ToScreen()
    surface.SetDrawColor( clrWhite )
    surface.DrawLine( offset.x, offset.y, w() * .5, h() * .5, clrWhite )
end

function SWEP:PreDrawViewModel()
    return true
end