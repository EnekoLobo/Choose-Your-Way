local OBJ = RDV.COMPANIONS.AddAbility("Atacar")

OBJ:AddCompanion("Massiff")

OBJ:SetPrice(500)

OBJ:SetCooldown(30) -- 30 second cooldown on this ability.

if SERVER then
    function OBJ:Initialize(ply, C_E)
        RDV.COMPANIONS.StartSelectingTarget(ply, function(ent)
            if ent:IsPlayer() or ( ent:IsNPC() and ent:GetRelationship(ply) == D_HT ) then
                RDV.LIBRARY.PlaySound(ply, "addoncontent/pets/droids/task_accepted.ogg")
    
                C_E:SetFollowTarget(ent)
    
                C_E.distancing = C_E.distancing / 4
                C_E.movementSpeed = C_E.movementSpeed * 2

                RDV.COMPANIONS.StopSelectingTarget(ply)
            end
        end)
    end

    function OBJ:AbilityEnded(ply, C_E)
        C_E.distancing = C_E.distancing * 4
        C_E.movementSpeed = C_E.movementSpeed / 2

        C_E:SetFollowTarget(ply)
    end

    local A_D = {}

    function OBJ:Think(ply, C_E)
        if C_E:GetFollowTarget() == ply then
            return
        end

        if not C_E:GetFollowTarget():IsValid() or !C_E:GetFollowTarget():Alive() then
            self:AbilityEnded(ply, C_E)
            return
        end

        if C_E:GetPos():DistToSqr(C_E:GetFollowTarget():GetPos()) > C_E.distancing then
            return
        end

        if not A_D[C_E] or A_D[C_E] < CurTime() then
            local TARGET = C_E:GetFollowTarget()
            local RANDOM = math.random(25,50)

            if TARGET:Health() - RANDOM <= 0 then                
                self:AbilityEnded(ply, C_E)
            end

            TARGET:TakeDamage(math.random(25,50), C_E, C_E)

            C_E:EmitSound("weapons/massif/bite.wav")

            A_D[C_E] = CurTime() + 1
        end

        if not C_E:GetFollowTarget():IsValid() then
            self:AbilityEnded(ply, C_E)
        end
    end
end