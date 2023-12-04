RDV = RDV or {}
RDV.COMPANIONS = RDV.COMPANIONS or {}


function RDV.COMPANIONS.AddCompanion(pet)
    RDV.COMPANIONS.COMPANIONS = RDV.COMPANIONS.COMPANIONS or {}

    RDV.COMPANIONS.COMPANIONS[pet] = {
        Purchaseable = true,
        SetModel = function(self, model)
            self.Model = model
        end,
        SetPrice = function(self, price)
            self.Price = price
        end,
        SetAmbientSound = function(self, sounds)
            self.AmbientSounds = sounds
        end,
        SetMovementSound = function(self, sounds)
            self.MovementSound = sounds
        end,
        SetMovementSpeed = function(self, speed)
            self.MovementSpeed = speed
        end,
        SetAmbientDelay = function(self, delay)
            self.AmbientDelay = delay
        end,
        SetDistancing = function(self, distance)
            self.Distancing = distance
        end,
        AddSkins = function(self, skins)
            self.Skins = skins
        end,
        SetIdleAnimation = function(self, anim)
            self.IdleAnimation = anim
        end,
        SetWalkAnimation = function(self, walk)
            self.WalkAnimation = walk
        end,
        SetWalkSequence = function(self, sequence, lasting)
            self.WalkSequence = {
                Sequence = sequence,
                Duration = lasting,
            }
        end,
        SetPurchaseable = function(self, bool)
            self.Purchaseable = bool
        end,
        AddJobs = function(self, jobs)
            self.Teams = self.Teams or {}

            for k, v in ipairs(jobs) do
                self.Teams[v] = true
            end
        end,
        AddJob = function(self, job)
            self.Teams = self.Teams or {}

            self.Teams[job] = true
        end,
        SetColor = function(self, color)
            self.Color = color
        end,
        AddUserGroups = function(self, tab) 
            self.UserGroups = self.UserGroups or {}

            for k, v in ipairs(tab) do
                self.UserGroups[v] = true
            end
        end,
        SetHealth = function(self, newhealth)
            self.Health = self.Health or {}

            self.Health = newhealth
        end
    }
    
    RDV.COMPANIONS.Count = RDV.COMPANIONS.Count or 1

    RDV.COMPANIONS.Count = RDV.COMPANIONS.Count + 1

    return RDV.COMPANIONS.COMPANIONS[pet]
end

function RDV.COMPANIONS.GetCompanion(pet)
    if not RDV.COMPANIONS.COMPANIONS[pet] then
        return false
    end

    return RDV.COMPANIONS.COMPANIONS[pet]
end

function RDV.COMPANIONS.GetCompanionCount()
    return (RDV.COMPANIONS.Count or 0)
end