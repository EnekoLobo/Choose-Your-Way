function RDV.COMPANIONS.AddAbility(ABILITY)
    RDV.COMPANIONS.ABILITIES[ABILITY] = {
        AddCompanion = function(self, PET)
            local TAB = RDV.COMPANIONS.ABILITIES
            TAB[ABILITY] = TAB[ABILITY] or {}
            TAB[ABILITY].PETS = TAB[ABILITY].PETS or {}
            
            TAB[ABILITY].PETS[PET] = true
        end,
        AddPet = function(self, C_E)
            self:AddCompanion(C_E)
        end,
        AddHook = function(self, id, callback)
            hook.Add(id, "ABILITY_HOOK_"..ABILITY, function(...)
                callback(self, ...)
            end)
        end,
        SetCooldown = function(self, seconds)
            self.AbilityCooldown = (seconds or 0)
        end,
        SetPrice = function(self, price)
            self.Price = price
        end,
        SetGroups = function(self, ...)
            self.Groups = ...
        end,
        
        Price = 0,
    }

    return RDV.COMPANIONS.ABILITIES[ABILITY]
end

function RDV.COMPANIONS.IsAbilityUsable(ABILITY, PET)
    if not ABILITY or not PET then
        return
    end

    local TAB = RDV.COMPANIONS.ABILITIES

    if not TAB then
        return false
    end

    if not TAB[ABILITY] then
        return false
    end

    if not TAB[ABILITY].PETS then
        return false
    end

    if not TAB[ABILITY].PETS[PET] then
        return false
    end


    return true
end