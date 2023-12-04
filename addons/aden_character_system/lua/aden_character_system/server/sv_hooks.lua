local function savePlayerInformations(ply)
    if ply.adcInformation and ply.adcInformation.selectedCharacter and ply.adcInformation.arrayCharacter[ply.adcInformation.selectedCharacter] then
        Aden_DC.Support:saveCharacter(ply)
        Aden_DC:saveValueCharacter(ply)
    end
end

hook.Add("PlayerSpawn", "ADC::PlayerSpawn::OpenMenu", function(ply)
    if !ply.adcInformation or !ply.adcInformation.initialSpawn then // Dont open the menu if its the first spawn (let the InitPostEntity clientside)
        ply.adcInformation = ply.adcInformation or {}
        ply.adcInformation.initialSpawn = true
        return
    end
    if ply.adcInformation.selectedCharacter and ply.adcInformation.arrayCharacter[ply.adcInformation.selectedCharacter] then // We reset position (because he die)
        ply.adcInformation.arrayCharacter[ply.adcInformation.selectedCharacter].cPos = nil
        ply.adcInformation.arrayCharacter[ply.adcInformation.selectedCharacter].cHealth = nil
        Aden_DC:updateCharacter(ply.adcInformation.arrayCharacter[ply.adcInformation.selectedCharacter], nil, "cWeapons", {}, "posX", 0, "posY", 0, "posZ", 0, "cArmor", 0, "cFood", 100)
    end
    if ply.MedicRevive then
        timer.Simple(0, function()
            if not IsValid(ply) then return end
            Aden_DC:selectModel(ply, ply.adcInformation.arrayCharacter[ply.adcInformation.selectedCharacter])
        end)
        return
    end
    if !ply.adcInformation.playerDead then return end
    ply.adcInformation.playerDead = false
    if Aden_DC.Config.Open.Respawn then // We need open the menu when the player respawn
        if Aden_DC.Config.deleteCharacterDie then
            local id = ply.adcInformation.selectedCharacter
            Aden_DC.Support:deleteCharacter(ply, id)
            Aden_DC:deleteCharacter(ply:SteamID64(), ply.adcInformation.arrayCharacter, id, function()
                Aden_DC:selectNumCharacter(ply, nil)
                Aden_DC:getCharacter(ply:SteamID64(), function(data)
                    ply.adcInformation.arrayCharacter = data
                    ply.adcInformation.arrayLenght = #ply.adcInformation.arrayCharacter
                    timer.Simple(0, function() // Sometime the player cam isnt ready for the 3d2d
                        Aden_DC:openMenu(ply)
                    end)
                end)
            end)
            return
        end
        timer.Simple(0, function() // Sometime the player cam isnt ready for the 3d2d
            if !IsValid(ply) then return end
            Aden_DC.Support:saveCharacter(ply)
            Aden_DC:saveValueCharacter(ply)
            Aden_DC:selectNumCharacter(ply, nil)
            Aden_DC:openMenu(ply)
        end)
    elseif ply.adcInformation.selectedCharacter and Aden_DC.Config.Open.AutoReselect then // If we dont need to open the menu just reselect the last character
        Aden_DC:selectCharacter(ply, ply.adcInformation.selectedCharacter, true)
    end
end)

hook.Add("PlayerButtonDown", "ADC::PlayerButtonDown::OpenMenu", function(ply, btn)
    if Aden_DC.Config.Open.Key and btn == Aden_DC.Config.Open.Key then
        Aden_DC:openMenu(ply)
    elseif Aden_DC.Config.Open.KeyAdmin and btn == Aden_DC.Config.Open.KeyAdmin and Aden_DC.Config.Open.Acces[ply:GetUserGroup()] then
        net.Start("ADC::AdminNetworking")
        net.WriteUInt(1, 8)
        net.Send(ply)
    end
end)

hook.Add("PlayerSay", "ADC::PlayerSay::OpenMenu", function(ply, txt, teamChat)
    if Aden_DC.Config.Open.Command == txt then
        if !ply.adcInformation then // If the ClientReady Failed
            Aden_DC:initializePlayer(ply)
        else
            Aden_DC:openMenu(ply)
        end
        return teamChat and txt or "" // Prevent the "[DarkRP] Invalid arguments!"
    elseif Aden_DC.Config.Open.CommandAdmin == txt and Aden_DC.Config.Open.Acces[ply:GetUserGroup()] then
        net.Start("ADC::AdminNetworking")
        net.WriteUInt(1, 8)
        net.Send(ply)
        return teamChat and txt or "" // Prevent the "[DarkRP] Invalid arguments!"
    end
end)

hook.Add("PlayerDisconnected", "ADC::PlayerDisconnected::saveCharacter", savePlayerInformations)

hook.Add("DarkRPVarChanged", "ADC::DarkRPVarChanged::saveCharacter", function(ply, name, old, new) // Save the money of the players
    if ply.adcInformation and ply.adcInformation.selectedCharacter and ply.adcInformation.arrayCharacter[ply.adcInformation.selectedCharacter] then
        timer.Simple(0, function() // Sometime we need to wait the next tick'
            if name == "money" then
                if !IsValid(ply) then return end
                Aden_DC:updateCharacter(ply.adcInformation.arrayCharacter[ply.adcInformation.selectedCharacter], nil, "cMoney", ply:getDarkRPVar("money"))
            elseif name == "rpname" then
                local explode = string.Explode(" ", new)
                local firstName, lastName = explode[1], explode[2]
                Aden_DC:updateCharacter(ply.adcInformation.arrayCharacter[ply.adcInformation.selectedCharacter], nil, "firstName", firstName or "", "lastName", lastName or "")
            end
        end)
    end
end)

hook.Add("playerDroppedMoney", "ADC::playerDroppedMoney::SaveOwner", function(ply, _, money)
    if !ply.adcInformation or !ply.adcInformation.selectedCharacter or !ply.adcInformation.arrayCharacter[ply.adcInformation.selectedCharacter] then
        money:Remove()
        return 
    end
    if IsValid(ply) and IsValid(money) then
        money.ADC_Owner = ply
    end
end)


hook.Add("playerCanChangeTeam", "ADC::playerCanChangeTeam::factionWhitlist", function(ply, team, force)
    if Aden_DC.Config.enableFaction and !force and Aden_DC.Config.enableFaction and ply.adcInformation and ply.adcInformation.selectedCharacter then
        local cFaction = ply.adcInformation.arrayCharacter[ply.adcInformation.selectedCharacter].cFaction
        local cClass = ply.adcInformation.arrayCharacter[ply.adcInformation.selectedCharacter].cClass

        // If not a valid faction or the jobs is a default jobs we dont need to check something
        if !cFaction or !Aden_DC.Config.listFaction[cFaction] or Aden_DC.Config.defaultJobs[team] then
            return
        end
        // the faction use the class system
        if Aden_DC.Config.listFaction[cFaction].class then

            // If not a valid class or the jobs is a default jobs of the class or not a whitelist jobs
            if !Aden_DC.Config.listFaction[cFaction].class[cClass] or Aden_DC.Config.listFaction[cFaction].class[cClass].defaultJobs[team] or (Aden_DC.Config.listFaction[cFaction].class[cClass].jobsNWhitelist and Aden_DC.Config.listFaction[cFaction].class[cClass].jobsNWhitelist[team]) then
                return
            end

            // He want join a job whitelist
            if Aden_DC.Config.listFaction[cFaction].class[cClass].jobs[team] then

                // He is whitlist ?
                if ply.adcInformation.arrayCharacter[ply.adcInformation.selectedCharacter].withlist[team] then
                    return true
                else
                    return false, "You are not whitelist !"
                end
            end
            return false, "You can't join a job of an other class !" // He want join a team who are not a default job and not a job of her class
        else
            // Not in fac or he want join a default job or a default job of the faction its Ok
            if Aden_DC.Config.listFaction[cFaction].defaultJobs[team] or (Aden_DC.Config.listFaction[cFaction].jobsNWhitelist and Aden_DC.Config.listFaction[cFaction].jobsNWhitelist[team]) then
                return
            end

            // He want join a job whitelist
            if Aden_DC.Config.listFaction[cFaction].jobs[team] then

                // He is whitlist ?
                if ply.adcInformation.arrayCharacter[ply.adcInformation.selectedCharacter].withlist[team] then
                    return true
                else
                    return false, "You are not whitelist !"
                end
            end
            return false, "You can't join a job of an other faction !" // He want join a team who are not a default job and not a job of her faction
        end
    end
end)

hook.Add("ShutDown", "ADC::ShutDown::saveCharacter", function() // Save when the server ShutDown
    for _, ply in ipairs(player.GetAll()) do
        savePlayerInformations(ply)
    end
end)

hook.Add("PlayerChangedTeam", "ADC::PlayerChangedTeam::saveCharacter", function(ply, _, new)
    if !ply.adcInformation or ply.adcInformation.switchJob or !DarkRP then return end // If we are selecting a character dont save weapons
    if ply.adcInformation.selectedCharacter and ply.adcInformation.arrayCharacter[ply.adcInformation.selectedCharacter] then
        if Aden_DC.Config.saveInformations["job"] then
            Aden_DC:updateCharacter(ply.adcInformation.arrayCharacter[ply.adcInformation.selectedCharacter], nil, "cJob", new, "cWeapons", {})
            /*timer.Simple(2, function()
                if !IsValid(ply) then return end
                Aden_DC:updateCharacter(ply.adcInformation.arrayCharacter[ply.adcInformation.selectedCharacter], nil, "cModel", ply:GetModel())
            end)*/
        else
            Aden_DC:updateCharacter(ply.adcInformation.arrayCharacter[ply.adcInformation.selectedCharacter], nil, "cWeapons", {})
        end
        if Aden_DC.Config.enableFaction then // Save playermodel of the job when the faction systeme is ON
            local cFaction = ply.adcInformation.arrayCharacter[ply.adcInformation.selectedCharacter].cFaction
            local cClass = ply.adcInformation.arrayCharacter[ply.adcInformation.selectedCharacter].cClass
            if Aden_DC.Config.listFaction[cFaction] and (Aden_DC.Config.listFaction[cFaction].saveModel or (Aden_DC.Config.listFaction[cFaction].class and Aden_DC.Config.listFaction[cFaction].class[cClass] and Aden_DC.Config.listFaction[cFaction].class[cClass].saveModel)) then // We don't need to save a new model just because we WANT USE the actual model
                timer.Simple(1, function() // I need to wait the last "playerLoad" hook
                    if !IsValid(ply) then return end
                    Aden_DC:selectModel(ply, ply.adcInformation.arrayCharacter[ply.adcInformation.selectedCharacter])
                end)
                return
            end
            if !Aden_DC.Config.ModelsJobs[new] then return end
            timer.Simple(1, function() // I need to wait the last "playerLoad" hook
                if !IsValid(ply) then return end
                Aden_DC:updateCharacter(ply.adcInformation.arrayCharacter[ply.adcInformation.selectedCharacter], nil, "cModel", ply:GetModel())
            end)
        elseif Aden_DC.Config.UseModelsForJobs then
            if Aden_DC.Config.ModelsJobs[new] then
                timer.Simple(1, function()
                    Aden_DC:selectModel(ply, ply.adcInformation.arrayCharacter[ply.adcInformation.selectedCharacter])
                end)
            end
        elseif new == ply.adcInformation.arrayCharacter[ply.adcInformation.selectedCharacter].cJob then // He come back at the saved jobs
            timer.Simple(1, function() // I need to wait the last "playerLoad" hook
                if !IsValid(ply) then return end
                Aden_DC:selectModel(ply, ply.adcInformation.arrayCharacter[ply.adcInformation.selectedCharacter])
            end)
        end
    end
end)

hook.Add("WeaponEquip", "ADC::WeaponEquip::saveCharacter", function(weap, ply) // Save weapon player
    if !ply.adcInformation or ply.adcInformation.switchJob or !DarkRP then return end // If we are selecting a character dont save weapons
    if table.HasValue(RPExtraTeams[ply:Team()].weapons or {}, weap:GetClass()) or Aden_DC.Config.blackListWeapons[weap:GetClass()] then return end // table.HasValue :(
    if DarkRP and ply.adcInformation.selectedCharacter and ply.adcInformation.arrayCharacter[ply.adcInformation.selectedCharacter] then
        weap.adc_arrayIndex = table.insert(ply.adcInformation.arrayCharacter[ply.adcInformation.selectedCharacter].cWeapons, weap:GetClass())
        Aden_DC:updateCharacter(ply.adcInformation.arrayCharacter[ply.adcInformation.selectedCharacter], nil, "cWeapons", ply.adcInformation.arrayCharacter[ply.adcInformation.selectedCharacter].cWeapons)
    end
end)

hook.Add("onDarkRPWeaponDropped", "ADC::onDarkRPWeaponDropped::saveCharacter", function(ply, _, weap) // Save weapon player
    if !ply.adcInformation or !weap.adc_arrayIndex or !DarkRP then return end // adc_arrayIndex the Index of the cWeapons
    if table.HasValue(RPExtraTeams[ply:Team()].weapons or {}, weap:GetClass()) or Aden_DC.Config.blackListWeapons[weap:GetClass()] then return end
    if DarkRP and ply.adcInformation.selectedCharacter and ply.adcInformation.arrayCharacter[ply.adcInformation.selectedCharacter] then
        table.remove(ply.adcInformation.arrayCharacter[ply.adcInformation.selectedCharacter].cWeapons, weap.adc_arrayIndex)
        Aden_DC:updateCharacter(ply.adcInformation.arrayCharacter[ply.adcInformation.selectedCharacter], nil, "cWeapons", ply.adcInformation.arrayCharacter[ply.adcInformation.selectedCharacter].cWeapons)
    end
end)

hook.Add("InitPostEntity", "ADC::InitPostEntity::respawnNPC", function()
    timer.Simple(1, function() // Sometime SQLRequest == nil in the InitPostEntity
        Aden_DC:respawnNPC()
    end)
end)

hook.Add("PostCleanupMap", "ADC::PostCleanupMap::respawnNPC", function()
    Aden_DC:respawnNPC()
end)

hook.Add("PlayerDeath", "ADC::PlayerDeath::respawnValue", function(ply) // To fix the issue with addon who "ply:Spawn()"
    if ply.adcInformation then
        ply.adcInformation.playerDead = true
    end
end)

concommand.Add("adc_menu", function(ply)
    if not Aden_DC.Config.Open.CommandConsole then return end
    Aden_DC:openMenu(ply)
end)