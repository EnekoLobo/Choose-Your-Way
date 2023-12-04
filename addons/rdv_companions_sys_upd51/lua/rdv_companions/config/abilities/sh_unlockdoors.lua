local OBJ = RDV.COMPANIONS.AddAbility("Bloquear y Desbloquear")

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

OBJ:SetPrice(500)
OBJ:SetCooldown(60)

if SERVER then
    local LIST = {
        ["func_door"] = true,
        ["func_door_rotating"] = true,
        ["prop_door_rotating"] = true,
        ["func_movelinear"] = true,
        ["prop_dynamic"] = true
    }

    function OBJ:Initialize(ply, C_E)
        RDV.COMPANIONS.StartSelectingTarget(ply, function(ent)
            if LIST[ent:GetClass()] then
                RDV.LIBRARY.PlaySound(ply, "addoncontent/pets/droids/task_accepted.ogg")
    
                C_E:SetFollowTarget(ent)
    
                C_E.distancing = C_E.distancing / 3
                C_E.movementSpeed = C_E.movementSpeed * 2

                RDV.COMPANIONS.StopSelectingTarget(ply)
            end
        end)
    end

    function OBJ:AbilityEnded(ply, C_E)
        C_E.distancing = C_E.distancing * 3
        C_E.movementSpeed = C_E.movementSpeed / 2
    
        C_E:SetFollowTarget(ply)
    end

    local H_D = {}
    local H_P = {}

    function OBJ:Think(ply, C_E)
        local DOOR = C_E:GetFollowTarget()

        if DOOR == ply then
            return
        end

        if not C_E:GetFollowTarget():IsValid() then
            self:AbilityEnded(ply, C_E)
            return
        end

        
        if IsValid(DOOR) and LIST[DOOR:GetClass()] then
            if C_E:GetPos():DistToSqr(C_E:GetFollowTarget():GetPos()) > C_E.distancing then
                return
            end


            H_P[DOOR] = H_P[DOOR] or 0
            H_D[DOOR] = H_D[DOOR] or 0

            if H_D[DOOR] and CurTime() > H_D[DOOR] then
                H_P[DOOR] = H_P[DOOR] + 1

                if H_P[DOOR] >= 20 then
                    local DATA = DOOR:GetSaveTable()

					if DATA and DATA.m_bLocked then
						DOOR:Fire("unlock")
						DOOR:Fire("open")
					else
						DOOR:Fire("close")
						DOOR:Fire("lock")
					end

                    C_E:SetFollowTarget(ply)

                    self:AbilityEnded(ply, C_E)
                end

                H_D[DOOR] = CurTime() + 1

                C_E:EmitSound("ambient/energy/zap2.wav")
            end
        end
    end
end