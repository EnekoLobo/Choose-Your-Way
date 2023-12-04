include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

function ENT:CustomInitialize()
    self.loco:SetJumpHeight(65)
    self.path = Path("Follow")

    self:SetUseType(SIMPLE_USE)
    self:SetCollisionGroup(COLLISION_GROUP_WORLD)
    self.nextAnimTime = 1

    local CFG = RDV.COMPANIONS.GetCompanion(self:GetPetType())
    self:SetHealth(CFG.Health or math.huge)
    self:SetMaxHealth(CFG.Health or math.huge)
    self:SetHealthEnabled(type(CFG.Health) == "number")
    self:SetFollowTarget(self:GetPetOwner())

    self.WalkAnimation = CFG.WalkAnimation
    self.RunAnimation = CFG.WalkAnimation
    self.IdleAnimation = CFG.IdleAnimation
    self.distancing = CFG.Distancing
    self.movementSpeed = CFG.MovementSpeed
    self.WalkSpeed = CFG.MovementSpeed
    self.RunSpeed = CFG.MovementSpeed

    hook.Run("RDV_COMPS_Initialize", self, self:GetPetType(), self:GetPetOwner())

    if CFG.CustomInitialize then
        CFG:CustomInitialize(self)
    end
end

function ENT:OnInjured(dmg)
    if (not self:GetHealthEnabled()) then
        self:SetHealth(self:GetMaxHealth())
    end
end

function ENT:OnRemove()
    if self.LOOPING_MOVEMENT_SOUND then
        self:StopLoopingSound(self.LOOPING_MOVEMENT_SOUND)
        self.LOOPING_MOVEMENT_SOUND = nil
    end

    if IsValid(self:GetPetOwner()) then
        RDV.COMPANIONS.StopSelectingTarget(self:GetPetOwner())
    end
end

function ENT:Use(activator)
    if !IsValid(self:GetPetOwner()) or activator ~= self:GetPetOwner() then 
        return 
    end

    net.Start("RDV_COMP_OpenPetMenu")
    net.Send(activator)
end

function ENT:AIBehaviour()
    local checkdistancedelay = CurTime() + 30
    local CFG = RDV.COMPANIONS.GetCompanion(self:GetPetType())

    while (true) do
        if not RDV.COMPANIONS.GetOption(self, "muteCommand") then
            self:PlayAmbientSound()
        end

        if RDV.COMPANIONS.GetOption(self, "stayCommand") then
            coroutine.wait(0.1)
            continue
        end

        if IsValid(self:GetFollowTarget()) and (self:GetPos():DistToSqr(self:GetFollowTarget():GetPos()) < self.distancing) then
            if self.LOOPING_MOVEMENT_SOUND then
                local SOUND = self.LOOPING_MOVEMENT_SOUND
                self:StopLoopingSound(SOUND)
                self.LOOPING_MOVEMENT_SOUND = nil
            end
        else
            if self:IsMoving() then
                if CFG.CustomMovement then
                    CFG:CustomMovement(self)
                end
            end

            if IsValid(self:GetFollowTarget()) then
                self:FollowPath(self:GetFollowTarget():GetPos())
            else
                self:FollowPath(self:GetPetOwner():GetPos())
            end

            self.path:Update(self)

            if CFG.MovementSound then
                if not self.LOOPING_MOVEMENT_SOUND then
                    self.LOOPING_MOVEMENT_SOUND = self:StartLoopingSound(CFG.MovementSound)
                end
            end
        end

        if checkdistancedelay < CurTime() then
            if IsValid(self:GetFollowTarget()) then
                if self:GetFollowTarget() ~= self:GetPetOwner() then
                    coroutine.wait(0.1)
                    continue
                end
            end

            if self:GetPos():DistToSqr(self:GetPetOwner():GetPos()) > 1000000 then
                self:SetPos(self:GetPetOwner():GetPos())
                checkdistancedelay = CurTime() + 30
            end
        end

        coroutine.wait(0.1)
    end
end

function ENT:PlayAnimation(sequence, force, rate, wait)
    self.currentAnimation = false
    rate = rate or 3
    force = force or false
    wait = wait or false

    if (not force) then
        if (sequence == self.currentAnimation) then return true end
        if (CurTime() < self.nextAnimTime) then return false end
    end

    local sequenceID, sequenceDuration = self:LookupSequence(sequence)
    if (sequenceID == -1) then return false end

    if (wait) then
        self.nextAnimTime = CurTime() + sequenceDuration
    end

    self:ResetSequenceInfo()
    self:SetCycle(0)
    self:SetPlaybackRate(rate)
    self:ResetSequence(sequenceID)
    self.currentAnimation = sequence

    return true
end

function ENT:CustomThink()
    if IsValid(self) and IsValid(self:GetPetOwner()) then
        --hook.Run("RDV_COMPS_Think", self, self:GetPetType(), self:GetPetOwner())
        local OBJ = RDV.COMPANIONS.GetCompanion(self:GetPetType())

        if OBJ.CustomThink then
            OBJ:CustomThink(self)
        end
    end
end

--[[---------------------------------]]--
--	Handle Ambient Sound
--[[---------------------------------]]--

local LAST_AMB = {}

function ENT:PlayAmbientSound()
    local CFG = RDV.COMPANIONS.GetCompanion(self:GetPetType())
    LAST_AMB[self] = LAST_AMB[self] or 0

    if LAST_AMB[self] < CurTime() then
        local STRING_PET = self:GetPetType()
        local AMBIENT_DELAY = (CFG.AmbientDelay or 0)
        local TABLE_AMBIENT = CFG.AmbientSounds
        local AMBIENT = table.Random(TABLE_AMBIENT)

        if AMBIENT and AMBIENT ~= "" then
            hook.Run("RDV_COMPS_Ambient", self, self:GetPetType(), self:GetPetOwner(), AMBIENT)
            self:EmitSound(AMBIENT)
        end

        LAST_AMB[self] = CurTime() + AMBIENT_DELAY
    end
end

--[[---------------------------------]]--
--	Health Support
--[[---------------------------------]]--

function ENT:OnTakeDamage(dmg)
    if (self:GetHealthEnabled()) then
        self:SetHealth(self:Health() - dmg:GetDamage())
    else
        self:SetHealth(self:GetMaxHealth())
        return 0
    end
end

function ENT:OnKilled(dmginfo)
    local PET = self:GetPetType()
    local ply = self:GetPetOwner()

    RDV.COMPANIONS.SetCompanionEquipped(ply, PET, false, true)
    
    local effectdata = EffectData()
    effectdata:SetOrigin(self:GetPos())
    util.Effect("Explosion", effectdata)
end

--[[---------------------------------]]--
--	Handle Custom Vars
--[[---------------------------------]]--

function ENT:RDV_COMPS_SetVar(key, val)
    local OWNER = self:GetPetOwner()
    local TYPE = self:GetPetType()
    
    if not IsValid(OWNER) or TYPE == "" then 
        return 
    end

	local PCHAR =  ( RDV.LIBRARY.GetCharacterEnabled() and RDV.LIBRARY.GetCharacterID(OWNER, nil) or 1 )

    local SID = OWNER:SteamID64()

    RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR] = RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR] or {}

    local TAB = RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR]
    TAB.COMPANIONS = TAB.COMPANIONS or {}
    TAB.COMPANIONS[TYPE] = TAB.COMPANIONS[TYPE] or {}
    TAB.COMPANIONS[TYPE].VARS = TAB.COMPANIONS[TYPE].VARS or {}
    TAB.COMPANIONS[TYPE].VARS[key] = val
end

function ENT:RDV_COMPS_GetVar(key, default)
    local OWNER = self:GetPetOwner()
    local TYPE = self:GetPetType()

    if not IsValid(OWNER) or TYPE == "" then 
        return 
    end

	local PCHAR =  ( RDV.LIBRARY.GetCharacterEnabled() and RDV.LIBRARY.GetCharacterID(OWNER, nil) or 1 )

    local SID = OWNER:SteamID64()

    RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR] = RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR] or {}

    local TAB = RDV.COMPANIONS.PLAYERS[SID].LIST[PCHAR]
    TAB.COMPANIONS = TAB.COMPANIONS or {}
    TAB.COMPANIONS[TYPE] = TAB.COMPANIONS[TYPE] or {}
    TAB.COMPANIONS[TYPE].VARS = TAB.COMPANIONS[TYPE].VARS or {}

    return TAB.COMPANIONS[TYPE].VARS[key] or (default or false)
end