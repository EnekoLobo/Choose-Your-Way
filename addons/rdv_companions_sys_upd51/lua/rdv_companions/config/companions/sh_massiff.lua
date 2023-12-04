local OBJ = RDV.COMPANIONS.AddCompanion("Massiff")

--[[---------------------------------]]--
--  Model of the Companion.
--[[---------------------------------]]--

OBJ:SetModel("models/mrpounder1/player/massif.mdl")

--[[---------------------------------]]--
--  Color or the Companion in the Shop.
--[[---------------------------------]]--

OBJ:SetColor(Color(150,150,124))

--[[---------------------------------]]--
--  Price of the Companion
--[[---------------------------------]]--

OBJ:SetPrice(7500)

--[[---------------------------------]]--
--  Set the Health of the Pet
--[[---------------------------------]]--

OBJ:SetHealth(350)

--[[---------------------------------]]--
--  Ambient Sounds
--[[---------------------------------]]--

OBJ:SetAmbientSound({
    "rdv/companions/massif/bark.wav", 
    "rdv/companions/massif/growl.wav", 
})

--[[---------------------------------]]--
--  Movement Speed
--[[---------------------------------]]--

OBJ:SetMovementSpeed(150)

--[[---------------------------------]]--
--  How often should we play an ambient sound?
--[[---------------------------------]]--

OBJ:SetAmbientDelay(12)

--[[---------------------------------]]--
--  How far the companion should stay away.
--[[---------------------------------]]--

OBJ:SetDistancing(40000)

--[[---------------------------------]]--
--  Idle animation we should use.
--[[---------------------------------]]--

OBJ:SetIdleAnimation("idle")

--[[---------------------------------]]--
--  Walk-Sequence we should use.
--[[---------------------------------]]--

OBJ:SetWalkSequence(ACT_HL2MP_RUN_MELEE, 3)

--[[---------------------------------]]--
--  User-group restriction.
--[[---------------------------------]]--


OBJ:AddUserGroups({
    "superadmin",
    "admin",
    "Event Master",
    "VIP",
})


--[[---------------------------------]]--
--  Job Restriction.
--[[---------------------------------]]--

--OBJ:AddJobs({
--    "Gun Dealer",
--})

--[[---------------------------------]]--
--  Custom functions.
--[[---------------------------------]]--

if SERVER then
    local M_D =  {}
    
    function OBJ:CustomMovement(self)
        local CFG = RDV.COMPANIONS.GetCompanion(self:GetPetType())

        if M_D[self] and M_D[self] > CurTime() then
            return
        end

        local WALK = CFG.WalkSequence

        self:StartActivity(WALK.Sequence)

        M_D[self] = CurTime() + WALK.Duration
    end
end