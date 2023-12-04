local OBJ = RDV.COMPANIONS.AddAbility("Inmolarse")
--[[]
OBJ:AddCompanion("3C-FD")
OBJ:AddCompanion("G3-SP")
OBJ:AddCompanion("M3-LN")
OBJ:AddCompanion("T3-C4")
OBJ:AddCompanion("T3-D3")
OBJ:AddCompanion("T3-H6")
OBJ:AddCompanion("T3-H8")
OBJ:AddCompanion("T3-K7")
OBJ:AddCompanion("T3-KT")
OBJ:AddCompanion("T3-LP")
OBJ:AddCompanion("T3-M3")
OBJ:AddCompanion("T3-M4")
OBJ:AddCompanion("T3-M5")
OBJ:AddCompanion("T3-QT")
OBJ:AddCompanion("T3-R2")
OBJ:AddCompanion("T3-RD")
]]--
OBJ:SetPrice(350)
OBJ:SetCooldown(30)

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

    function OBJ:Think(ply, C_E)
        if C_E:GetFollowTarget() == ply then
            return
        end

        if not C_E:GetFollowTarget():IsValid() then
            self:AbilityEnded(ply, C_E)
            return
        end
        
        if C_E:GetPos():DistToSqr(C_E:GetFollowTarget():GetPos()) > C_E.distancing then
            return
        end

        C_E:Ignite(55, 50)

        timer.Simple(3, function()
            if IsValid(C_E) then
                local effectdata = EffectData()
                effectdata:SetOrigin( C_E:GetPos() )
                util.Effect( "HelicopterMegaBomb", effectdata )

                for k, v in ipairs(ents.FindInSphere(C_E:GetPos(), 300)) do
                    if v:IsPlayer() then
                        v:TakeDamage(500, C_E, C_E)
                    end    
                end

                C_E:EmitSound("ambient/explosions/explode_1.wav")

                C_E:Ignite(0, 0)

                local CLASS = C_E:GetPetType()

                RDV.COMPANIONS.SetCompanionEquipped(ply, CLASS, false, true)

                if IsValid(C_E) then
                    C_E:Remove()
                end
            end
        end)
    end
end