local OBJ = RDV.COMPANIONS.AddAbility("Aturdir")

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

OBJ:SetPrice(250)

OBJ:SetCooldown(5)

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
    
        local effectdata = EffectData()
        effectdata:SetOrigin( C_E:GetPos() )
        util.Effect( "TeslaHitboxes", effectdata )
    
        local STUNNED = {}
    
        for k, v in ipairs(ents.FindInSphere(C_E:GetPos(), 500)) do
            if v:IsPlayer() and v ~= ply then
                v:Lock()
    
                STUNNED[v] = true
            end
        end
    
        timer.Simple(5, function()
            for k, v in pairs(STUNNED) do
                if not IsValid(k) then
                    continue
                end
    
                k:UnLock()
            end
        end)
    
        self:AbilityEnded(ply, C_E)
    end
end