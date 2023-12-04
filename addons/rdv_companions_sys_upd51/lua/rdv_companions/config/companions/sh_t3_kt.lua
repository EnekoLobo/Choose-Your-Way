local OBJ = RDV.COMPANIONS.AddCompanion("T3-KT")

--[[---------------------------------]]--
--  Model of the Companion.
--[[---------------------------------]]--

OBJ:SetModel("models/t3_droids/t3kt/t3kt.mdl")

--[[---------------------------------]]--
--  Color or the Companion in the Shop.
--[[---------------------------------]]--

OBJ:SetColor(Color(255,217,0))

--[[---------------------------------]]--
--  Price of the Companion
--[[---------------------------------]]--

OBJ:SetPrice(3500)

--[[---------------------------------]]--
--  Set the Health of the Pet
--[[---------------------------------]]--

OBJ:SetHealth(200)

--[[---------------------------------]]--
--  Ambient Sounds
--[[---------------------------------]]--

OBJ:SetAmbientSound({
    "kaioken/t3/idle_01.ogg", 
    "kaioken/t3/idle_02.ogg", 
    "kaioken/t3/idle_03.ogg"
})



--[[---------------------------------]]--
--  Movement Sound
--[[---------------------------------]]--

OBJ:SetMovementSound("rdv/companions/misc/movement.wav")

--[[---------------------------------]]--
--  Movement Speed
--[[---------------------------------]]--

OBJ:SetMovementSpeed(100)

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
--  Walk animation we should use.
--[[---------------------------------]]--

OBJ:SetWalkAnimation("walk_all")