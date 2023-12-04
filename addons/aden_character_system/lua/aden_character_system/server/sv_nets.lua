util.AddNetworkString("ADC::CharacterNetwork")
util.AddNetworkString("ADC::UpdateName")
util.AddNetworkString("ADC::Popup")

util.AddNetworkString("ADC::AdminNetworking")

resource.AddWorkshop("2771469791")

local function SendRequest(ply, id)
    net.Start("ADC::UpdateName")
    net.Send(ply)
    if id then
        ply.adcInformation.requestName = id
    end
    Aden_DC:sendNotif(ply, Aden_DC:GetPhrase("nameun"))
end

local function CreateCharacter(ply)
    local arrayCharacter = Aden_DC.Nets:ReadTable()
    if !ply.adcInformation.arrayCharacter then return end
    if ply.adcInformation.requestName then // He create a unfinish character (With a wrong name)
        Aden_DC:deleteCharacter(ply:SteamID64(), ply.adcInformation.arrayCharacter, ply.adcInformation.requestName) // So delete this character (i dont need to wait the SQLRequest because i table.remove in the function ouside the query)
        ply.adcInformation.requestName = false
    end

    // Check if the play can create a new character
    local id = ply.adcInformation.arrayLenght + 1
    if !Aden_DC.Config.maxCharacter[id] then return end
    if istable(Aden_DC.Config.maxCharacter[id]) and Aden_DC.Config.maxCharacter[id].usergroups then
        if !Aden_DC.Config.maxCharacter[id].usergroups[ply:GetUserGroup()] then
            Aden_DC:openMenu(ply)
            return
        end
    end

    // Parsing of the informations and setup variable
    arrayCharacter = Aden_DC:parsingCharacter(arrayCharacter, id == 1, ply)

    print(arrayCharacter.firstName, arrayCharacter.lastName)
    // Check available name
    Aden_DC:isAvailableName(arrayCharacter.firstName, arrayCharacter.lastName, function(available)
        if !available then // If the name isnt available save the character but he cant use it before he change the name
            Aden_DC:sendNotif(ply, Aden_DC:GetPhrase("nameun"))
            Aden_DC:openMenu(ply)
        else
        // Save Data
            Aden_DC:createCharacter(ply:SteamID64(), arrayCharacter, function(data)
                ply.adcInformation.arrayCharacter = data
                ply.adcInformation.arrayLenght = #ply.adcInformation.arrayCharacter
                Aden_DC.Support:createCharacter(ply, ply.adcInformation.arrayLenght)
                for k, _ in pairs(ply.adcInformation.arrayCharacter) do
                    ply.adcInformation.arrayCharacter[k].owner = ply
                end
                Aden_DC:openMenu(ply)
                hook.Run("Aden_DC_CharacterCreated", ply, arrayCharacter)
            end)
        end
    end)
end

net.Receive("ADC::CharacterNetwork", function(_, ply)
    local id = net.ReadUInt(8)

    // Anti spam for net exploit
    if ply.adcInformation.antiSpam and ply.adcInformation.antiSpam > CurTime() then
        Aden_DC:sendNotif(ply, Aden_DC:GetPhrase("thx") .. "(" .. math.floor(ply.adcInformation.antiSpam - CurTime()) .. "s)")
        return
    end
    ply.adcInformation.antiSpam = CurTime() + 3

    if id == 0 then
        Aden_DC:initializePlayer(ply)
    elseif id == 1 then  // Create
        CreateCharacter(ply)
    elseif id == 2 then // Select
        id = net.ReadUInt(8)

        if Aden_DC.Config.delayChracter and ply.adcInformation.antiSpam_Character and ply.adcInformation.antiSpam_Character > CurTime() then
            if Aden_DC.Config.textPopup then
                Aden_DC:sendNotif(ply, (Aden_DC.Config.textPopup == true and Aden_DC:GetPhrase("thx") or Aden_DC.Config.textPopup) .. "(" .. math.floor(ply.adcInformation.antiSpam_Character - CurTime()) .. "s)")
            end
            return
        end
        ply.adcInformation.antiSpam_Character = CurTime() + Aden_DC.Config.delayChracter
        if !ply.adcInformation.arrayCharacter or !ply.adcInformation.arrayCharacter[id] then return end
        if id == ply.adcInformation.selectedCharacter then return end // Dont reselect the same character
        if ply.adcInformation.selectedCharacter then
            Aden_DC.Support:saveCharacter(ply)
            Aden_DC:saveValueCharacter(ply)
            if Aden_DC.Config.deleteEntity then
                Aden_DC:removeEntity(ply)
            end
            Aden_DC.Support:preChangeCharacter(ply, id)
        end
        Aden_DC:selectCharacter(ply, id)
        Aden_DC.Support:loadCharacter(ply)
        hook.Run("Aden_DC_CharacterSelected", ply, id)
    elseif id == 3 then // Delete
        id = net.ReadUInt(8)

        if !ply.adcInformation.arrayCharacter or !ply.adcInformation.arrayCharacter[id] then return end
        Aden_DC.Support:deleteCharacter(ply, id)
        Aden_DC:deleteCharacter(ply:SteamID64(), ply.adcInformation.arrayCharacter, id, function()
            Aden_DC:selectNumCharacter(ply, nil) // Unselect the current character (because the player can select the delete character)
            Aden_DC:getCharacter(ply:SteamID64(), function(data)
                ply.adcInformation.arrayCharacter = data
                ply.adcInformation.arrayLenght = #ply.adcInformation.arrayCharacter
                Aden_DC:openMenu(ply)
            end)
            hook.Run("Aden_DC_DeleteCharacter", ply, id)
        end)
    elseif id == 4 then // Update Model
        id = net.ReadUInt(8)
        local cModel = net.ReadUInt(8)

        if !Aden_DC.Config.changeModel then return end
        Aden_DC:updateCharacter(ply.adcInformation.arrayCharacter[id],
            function()
                Aden_DC:openMenu(ply)
            end,
            "cModel", Aden_DC.Config.Model[cModel])
    end
end)

net.Receive("ADC::UpdateName", function(_, ply)
    local id = net.ReadUInt(8)

    if ply.adcInformation.adcAntispam and ply.adcInformation.adcAntispam > CurTime() then
        Aden_DC:sendNotif(ply, Aden_DC:GetPhrase("thx") .. "(" .. math.floor(ply.adcInformation.adcAntispam - CurTime()) .. "s)")
        return
    end
    ply.adcInformation.adcAntispam = CurTime() + 10
    if id == 1 then // Buy a new name
        id = net.ReadUInt(8)
        local firstName = string.Trim(net.ReadString())
        local lastName = string.Trim(net.ReadString())

        if DarkRP then
            if Aden_DC.Config.saveInformations["money"] and ply.adcInformation.arrayCharacter[id].cMoney < Aden_DC.Config.PriceName then
                Aden_DC:sendNotif(ply, Aden_DC:GetPhrase("cantbuy"))
                return
            elseif !Aden_DC.Config.saveInformations["money"] and ply:getDarkRPVar("money") < Aden_DC.Config.PriceName then
                Aden_DC:sendNotif(ply, Aden_DC:GetPhrase("cantbuy"))
                return
            end
        end
        if id and ply.adcInformation.arrayCharacter[id] then
            // If the name is available send the new name and paie with the money of the character (NOT THE ACTUAL MONEY ON THE PLAYER)
            Aden_DC:isAvailableName(firstName, lastName, function(available)
                if !available then
                    Aden_DC:sendNotif(ply, Aden_DC:GetPhrase("nameun"))
                else
                    Aden_DC:updateCharacter(ply.adcInformation.arrayCharacter[id],
                        function()
                            Aden_DC:openMenu(ply)
                        end,
                        "firstName", firstName,
                        "lastName", lastName,
                        "cMoney", math.max(ply.adcInformation.arrayCharacter[id].cMoney - Aden_DC.Config.PriceName, 0))
                    if id == ply.adcInformation.selectedCharacter then
                        if !Aden_DC.Config.saveInformations["money"] then
                            ply:addMoney(-Aden_DC.Config.PriceName)
                        else
                            ply:setDarkRPVar("money", ply.adcInformation.arrayCharacter[id].cMoney)
                        end
                        ply:setDarkRPVar("rpname", ply.adcInformation.arrayCharacter[id].firstName .. " " .. ply.adcInformation.arrayCharacter[id].lastName)
                    end
                end
            end)
        end
    elseif id == 2 then // The name was unvailable when the player create the character (so its free to change)
        id = ply.adcInformation.requestName // for the lisibility
        local firstName = string.Trim(net.ReadString())
        local lastName = string.Trim(net.ReadString())
        ply.adcInformation.adcAntispam = CurTime() + 1
        if id and ply.adcInformation.arrayCharacter[id] then
            Aden_DC:isAvailableName(firstName, lastName, function(available)
                if !available then
                    SendRequest(ply)
                else
                    Aden_DC:updateCharacter(ply.adcInformation.arrayCharacter[id],
                        function()
                            Aden_DC:openMenu(ply)
                        end,
                        "firstName", firstName,
                        "lastName", lastName,
                        "nAvailable", false)
                    ply.adcInformation.requestName = false
                end
            end)
        end
    end
end)

local function AdminInfo(ply)
    local steamid64

    if net.ReadBit() == 1 then
        steamid64 = net.ReadEntity()
        if !IsValid(steamid64) then return end
        steamid64 = steamid64:SteamID64()
    else
        steamid64 = net.ReadString()
    end
    if !Aden_DC:isAdmin(ply) then return end

    Aden_DC:getCharacter(steamid64, function(data)
        net.Start("ADC::AdminNetworking")
        net.WriteUInt(2, 8)
        net.WriteUInt(#data, 8)
        for i = 1, #data do
            Aden_DC.Nets:WriteTable(data[i])
        end
        net.WriteString(steamid64)
        net.Send(ply)
    end)
end

local function AdminUpdate(ply)
    local steamid64 = net.ReadString()
    local id = net.ReadUInt(8)
    local arrayCharacter = Aden_DC.Nets:ReadTable()
    if !Aden_DC:isAdmin(ply) then return end
    Aden_DC:getCharacter(steamid64, function(data) // Need to get the index
        if !data or !data[id] then return end
        if data[id].cJob != arrayCharacter.cJob then
            arrayCharacter.cModel = RPExtraTeams[arrayCharacter.cJob].model[1]
        end
        data[id].dBirth.y = arrayCharacter.dBirth.y // I can't set the years value in the table in the function "updateCharacter"
        Aden_DC:updateCharacter(data[id], function() // Update with the index
            local user = player.GetBySteamID64(steamid64) // If the player is connected update the values
            if IsValid(user) then
                user.adcInformation.arrayCharacter[id] = data[id]
                if DarkRP and user.adcInformation.selectedCharacter == id then // Update money
                    Aden_DC:setupDarkRPVar(user, data[id])
                end
                Aden_DC.Support:adminUpdateCharacter(user, id)
            end
            Aden_DC:sendNotif(ply, Aden_DC:GetPhrase("charupdamsg"), "charupda")
        end, "firstName", arrayCharacter.firstName, "lastName", arrayCharacter.lastName, "cMoney", arrayCharacter.cMoney, "cModel", arrayCharacter.cModel, "cFaction", arrayCharacter.cFaction, "cJob", arrayCharacter.cJob, "withlist", arrayCharacter.withlist, "years", arrayCharacter.dBirth.y, "cClass", arrayCharacter.cClass)
    end)
end

local function AdminDelete(ply)
    local steamid64 = net.ReadString()
    local id = net.ReadUInt(8)
    local reason = net.ReadString()
    if !Aden_DC:isAdmin(ply) then return end
    if !Aden_DC:isAdmin(ply, "delete") then return end
    Aden_DC:getCharacter(steamid64, function(data) // Like AdminUpdate
        if !data or !data[id] then return end
        Aden_DC:deleteCharacter(steamid64, data, id, function()
            local user = player.GetBySteamID64(steamid64)
            if IsValid(user) then // if the user is connected refetch and reopen the menu
                Aden_DC:getCharacter(steamid64, function(data) // fetch the data
                    user.adcInformation.arrayCharacter = data
                    user.adcInformation.arrayLenght = #user.adcInformation.arrayCharacter
                    Aden_DC:selectNumCharacter(user, nil)
                    Aden_DC:openMenu(user)
                    Aden_DC:sendNotif(user, reason, "chardelete")
                end)
            else
                Aden_DC:saveNotif(steamid64, reason, "chardelete")
            end
        end)
    end)
end

local function AdminNPC(ply)
    if !Aden_DC:isAdmin(ply) then return end
    local mode = net.ReadUInt(2)
    if mode == 1 then
        local npc = ents.Create("npc_adc_menu")
        npc:SetPos(ply:GetEyeTrace().HitPos)
        local npcAng = ply:GetAngles()
        npcAng:RotateAroundAxis(npcAng:Up(), 180)
        npcAng.x = 0
        npc:SetAngles(npcAng)
        npc:Spawn()
        Aden_DC.NPC[#Aden_DC.NPC + 1] = npc
        undo.Create("ADC NPC")
             undo.AddEntity(npc)
             undo.SetPlayer(ply)
        undo.Finish()
    elseif mode == 2 then
        Aden_DC:saveNPC(function()
            Aden_DC:sendNotif(ply, Aden_DC:GetPhrase("succes"))
        end)
    elseif mode == 3 then
        Aden_DC:deleteNPC(function()
            Aden_DC:sendNotif(ply, Aden_DC:GetPhrase("succes"))
        end)
    end
end

net.Receive("ADC::AdminNetworking", function(_,ply)
    local id = net.ReadUInt(8)
    if !Aden_DC:isAdmin(ply) then return end
    if id == 1 then // ADC::AdminInfo
        AdminInfo(ply)
    elseif id == 2 then // ADC::AdminUpdate
        AdminUpdate(ply)
    elseif id == 3 then // ADC::AdminDelete
        AdminDelete(ply)
    elseif id == 4 then // ADC::AdminNPC
        AdminNPC(ply)
    end
end)
