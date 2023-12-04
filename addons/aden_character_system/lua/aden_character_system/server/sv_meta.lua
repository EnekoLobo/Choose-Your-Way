function Aden_DC:openMenu(ply) // Open the menu (dont forget to initializePlayer before)
    ply.CanCreateCharacter = true
    net.Start("ADC::CharacterNetwork")
    net.WriteUInt(1, 8)
    net.WriteUInt(ply.adcInformation.arrayLenght, 4)
    for i = 1, ply.adcInformation.arrayLenght do
        self.Nets:WriteTable(ply.adcInformation.arrayCharacter[i])
    end
    net.Send(ply)

    self:networkIndexCharacter(ply)
end

function Aden_DC:createCharacter(steamid64, arrayCharacter, callback)
    local tbl = { // For lisibility
        [1] = steamid64,
        [2] = arrayCharacter.firstName,
        [3] = arrayCharacter.lastName,
        [4] = arrayCharacter.dBirth.d,
        [5] = arrayCharacter.dBirth.m,
        [6] = arrayCharacter.dBirth.y,
        [7] = arrayCharacter.cDesc or "",
        [8] = arrayCharacter.cFaction,
        [9] = arrayCharacter.cModel,
        [10] = util.TableToJSON(arrayCharacter.bodyGroups),
        [11] = arrayCharacter.mScale,
        [12] = arrayCharacter.nAvailable and 1 or 0,
        [13] = arrayCharacter.cMoney,
        [14] = arrayCharacter.cJob,
        [15] = util.TableToJSON(arrayCharacter.cWeapons),
        [16] = 0,
        [17] = 0,
        [18] = 0,
        [19] = "[]",
        [20] = "[]",
        [21] = arrayCharacter.cClass,
    } // I need to put the table in order
    self:SQLRequest(self:Format([[INSERT INTO `arrayCharacter` (`steamid64`, `firstName`, `lastName`, `day`, `month`, `years`, `cDesc`, `cFaction`, `cModel`, `bodyGroups`, `mScale`, `nAvailable`, `cMoney`, `cJob`, `cWeapons`, `posX`, `posY`, `posZ`, `withlist`, `info`, `cClass`) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)]], unpack(tbl)), function()
        self:getCharacter(steamid64, callback)
    end)
end

function Aden_DC:updateCharacter(arrayCharacter, callback, ...) // (arrayCharacter, ..., callback) dont work
    local str = ""
    local array = {...}
    for i = 1, #array / 2 do
        str = str .. "`" .. array[(i * 2) - 1] .. "` = %s, " // We need to put `` quote for the mysql syntax
        arrayCharacter[array[(i * 2) - 1]] = array[i * 2] // Assign arrayCharacter["cMoney"] = value
        array[i] = array[i * 2] // We remove the index of the value
    end
    array[#array / 2 + 1] = arrayCharacter.index // Add the index for the last %s
    str = str:sub(1, -3) // Remove the last ", "
    self:SQLRequest(self:Format([[UPDATE `arrayCharacter` SET ]] .. str .. [[ WHERE `index` = %s]], unpack(array)), callback)

    local arraySend = {...}
    if IsValid(arrayCharacter.owner) then
        local lenght = #arraySend / 2
        net.Start("ADC::CharacterNetwork")
        net.WriteUInt(5, 8)
        net.WriteUInt(arrayCharacter.localIndex, 4)
        net.WriteUInt(lenght, 4)
        for i = 1, lenght do
            net.WriteString(arraySend[(i * 2) - 1])
            net.WriteType(arraySend[i * 2])
        end
        net.Send(arrayCharacter.owner)
    end
end

function Aden_DC:deleteCharacter(steamid64, arrayCharacter, id, callback) // Delete a character with the index
    self:SQLRequest(self:Format([[DELETE FROM `arrayCharacter` WHERE `index` = %s]], arrayCharacter[id].index), function()
        table.remove(arrayCharacter, id)
        if callback then
            callback()
        end
    end)
end

function Aden_DC:getCharacter(steamid64, callback) // Get all character of the SteamID64
    self:SQLRequest(self:Format([[SELECT * FROM `arrayCharacter` WHERE `steamid64` = %s]], steamid64), function(data)
        local arrayCharacter = {}
        if data and data[1] then
            arrayCharacter = data
            for k, v in ipairs(arrayCharacter) do
                arrayCharacter[k].dBirth = {
                    d = v.day,
                    m = v.month,
                    y = v.years,
                }
                arrayCharacter[k].bodyGroups = util.JSONToTable(v.bodyGroups or '[]')
                arrayCharacter[k].cWeapons = util.JSONToTable(v.cWeapons or '[]')
                arrayCharacter[k].withlist = util.JSONToTable(v.withlist or '[]')
                arrayCharacter[k].info = util.JSONToTable(v.info or '[]')
                arrayCharacter[k].cHealth = tonumber(arrayCharacter[k].cHealth or 100)
                arrayCharacter[k].cArmor = tonumber(arrayCharacter[k].cArmor or 0)
                arrayCharacter[k].cFood = tonumber(arrayCharacter[k].cFood or 100)
                arrayCharacter[k].cMoney = tonumber(arrayCharacter[k].cMoney or 0)
                arrayCharacter[k].cJob = tonumber(arrayCharacter[k].cJob or 0)
                arrayCharacter[k].cFaction = tonumber(arrayCharacter[k].cFaction or 0)
                arrayCharacter[k].cClass = tonumber(arrayCharacter[k].cClass or 0)
                arrayCharacter[k].cScale = tonumber(arrayCharacter[k].cScale or 1)
                arrayCharacter[k].nAvailable = arrayCharacter[k].nAvailable == "1"
                if tonumber(v.posX) != 0 or tonumber(v.posY) != 0 or tonumber(v.posZ) != 0 then
                    arrayCharacter[k].cPos = Vector(v.posX, v.posY, v.posZ)
                end
                arrayCharacter[k].localIndex = k
            end
        end
        if callback then
            callback(arrayCharacter)
        end
    end)
end

function Aden_DC:initializePlayer(ply) // Initialize the player and open the menu
    ply.adcInformation = ply.adcInformation or {}
    self:getCharacter(ply:SteamID64(), function(data)
        ply.adcInformation.arrayCharacter = data
        for k, _ in pairs(ply.adcInformation.arrayCharacter) do
            ply.adcInformation.arrayCharacter[k].owner = ply
        end
        ply.adcInformation.arrayLenght = #ply.adcInformation.arrayCharacter
        if ply.adcInformation.arrayCharacter[ply.adcInformation.arrayLenght] and ply.adcInformation.arrayCharacter[ply.adcInformation.arrayLenght].nAvailable then // Dont forget the unfinish caracter
            ply.adcInformation.requestName = ply.adcInformation.arrayLenght
        end
        if self.Config.Open.InitialSpawn then
            self:openMenu(ply)
        end
        if ply:IsSuperAdmin() and !self.OnDate then // If the player is superadmin and the addon isnt to date send message
            ply:ChatPrint("[ADC] Your addon is not on date !")
        end
    end)
    self:executeNotif(ply) // Send notif the player was receive when he was disconnected
end

function Aden_DC:isAvailableName(firstName, lastName, callback)  // Check if the name is avaible in the data base and if the name isnt blacklist
    print(self.Func:IsBlackList(firstName, lastName))
    if self.Func:IsBlackList(firstName, lastName) then
        callback(false)
        return
    end
    self:SQLRequest(self:Format([[SELECT * FROM `arrayCharacter` WHERE firstName = %s and lastName = %s]], firstName, lastName), function(data)
        callback(!(data and data[1]))
    end)
end

function Aden_DC:parsingCharacter(arrayCharacter, firstCharacter, ply) // Check value (exploit)
    arrayCharacter.firstName = string.Trim(arrayCharacter.firstName)
    if self.Config.UseNumberName then
        arrayCharacter.firstName = self.Config.PrefixNumberName .. arrayCharacter.firstName
    end
    arrayCharacter.lastName = string.Trim(arrayCharacter.lastName)
    arrayCharacter.dBirth = arrayCharacter.dBirth or {d = 1, m = 1, y = self.Config.MinimumYears}
    arrayCharacter.dBirth.d = math.Clamp(arrayCharacter.dBirth.d, 1, 31)
    arrayCharacter.dBirth.m = math.Clamp(arrayCharacter.dBirth.m, 1, 12)
    arrayCharacter.dBirth.y = math.Clamp(arrayCharacter.dBirth.y, self.Config.MinimumYears, self.Config.CurrentYears) // Minimum 18 years old
    arrayCharacter.cFaction = arrayCharacter.cFaction or 1
    if !isnumber(arrayCharacter.cModel) then // Anti Exploit (He cant write a string model at the creation)
        arrayCharacter.cModel = 1
    end
    if Aden_DC.Config.enableFaction then
        if !Aden_DC.Config.listFaction[arrayCharacter.cFaction] or Aden_DC.Config.listFaction[arrayCharacter.cFaction].hide then
            arrayCharacter.cFaction = 1
        end
        if Aden_DC.Config.listFaction[arrayCharacter.cFaction].class then
            if !Aden_DC.Config.listFaction[arrayCharacter.cFaction].class[arrayCharacter.cClass] then
                arrayCharacter.cClass = 1
            end
            if !Aden_DC.Config.listFaction[arrayCharacter.cFaction].class[arrayCharacter.cClass].defaultJobs[arrayCharacter.cJob] then
                arrayCharacter.cJob = table.GetFirstKey(Aden_DC.Config.listFaction[arrayCharacter.cFaction].class[arrayCharacter.cClass].defaultJobs)
            end
        else
            if !Aden_DC.Config.listFaction[arrayCharacter.cFaction].defaultJobs[arrayCharacter.cJob] then
                arrayCharacter.cJob = table.GetFirstKey(Aden_DC.Config.listFaction[arrayCharacter.cFaction].defaultJobs)
            end
        end
        if !RPExtraTeams[arrayCharacter.cJob].model[arrayCharacter.cModel] then
            arrayCharacter.cModel = 1
        end
        arrayCharacter.cModel = RPExtraTeams[arrayCharacter.cJob].model[arrayCharacter.cModel]
    else
        if !self.Config.Model[arrayCharacter.cModel] then
            arrayCharacter.cModel = 1
        end
        arrayCharacter.cJob = 0
        if DarkRP then
            arrayCharacter.cJob = GAMEMODE.DefaultTeam
        end
        arrayCharacter.cModel = self.Config.Model[arrayCharacter.cModel]
    end
    if self.Config.transferMoney and firstCharacter then
        arrayCharacter.cMoney = ply:getDarkRPVar("money", 0)
    elseif self.Config.moneyForAll then
        arrayCharacter.cMoney = self.Config.moneyStartCharacter or 0
    elseif firstCharacter then
        arrayCharacter.cMoney = self.Config.moneyStartCharacter or 0
    else
        arrayCharacter.cMoney = 0
    end
    arrayCharacter.cWeapons = {}
    arrayCharacter.nAvailable = false
    arrayCharacter.withlist = {}
    // In the Aden_DC.Nets:WriteTable the client cant send the cHealth or cArmor .... so i dont need to check the value
    // The SQL Table initialize 76561198087853030 values like cArmor
    return arrayCharacter
end

function Aden_DC:saveValueCharacter(ply)
    local id = ply.adcInformation.selectedCharacter
    local arg = {} // i dont want send 4 request just for save some values
    if id and ply.adcInformation.arrayCharacter[id] then
        if self.Config.saveInformations["health"] then
            arg[#arg + 1] = "cHealth"
            arg[#arg + 1] = ply:Health()
        end
        if self.Config.saveInformations["armor"] then
            arg[#arg + 1] = "cArmor"
            arg[#arg + 1] = ply:Armor()
        end
        if self.Config.saveInformations["position"] then
            local pos = ply:GetPos()
            arg[#arg + 1] = "posX"
            arg[#arg + 1] = pos.x
            arg[#arg + 1] = "posY"
            arg[#arg + 1] = pos.y
            arg[#arg + 1] = "posZ"
            arg[#arg + 1] = pos.z
        end
        if DarkRP then
            if self.Config.saveInformations["money"] then
                arg[#arg + 1] = "cMoney"
                arg[#arg + 1] = ply:getDarkRPVar("money")
            end
            if !DarkRP.disabledDefaults["modules"]["hungermod"] and self.Config.saveInformations["food"] then
                arg[#arg + 1] = "cFood"
                arg[#arg + 1] = ply:getDarkRPVar("Energy")
            end
        end
        arg[#arg + 1] = "info"
        arg[#arg + 1] = ply.adcInformation.arrayCharacter[id].info
        self:updateCharacter(ply.adcInformation.arrayCharacter[id], nil, unpack(arg))
    end
end

function Aden_DC:selectNumCharacter(ply, id)
    ply.adcInformation.selectedCharacter = id
    net.Start("ADC::CharacterNetwork")
    net.WriteUInt(2, 8)
    net.WriteUInt(id or 0, 8)
    net.Send(ply)

    net.Start("ADC::CharacterNetwork")
    net.WriteUInt(3, 8)
    net.WriteEntity(ply)
    if not ply.adcInformation.arrayCharacter[id] then
        net.WriteUInt(0, 8)
    else
        net.WriteUInt(ply.adcInformation.arrayCharacter[id].index, 8)
    end
    net.Broadcast()
end

function Aden_DC:networkIndexCharacter(ply)
    local arrayPlayers = {}
    for _, ply in ipairs(arrayPlayers) do
        if not ply.adcInformation then continue end
        if not ply.adcInformation.selectedCharacter then continue end
        arrayPlayers[#arrayPlayers + 1] = {ply, ply.adcInformation.arrayCharacter[ply.adcInformation.selectedCharacter].index}
    end

    if #arrayPlayers <= 0 then return end

    net.Start("ADC::CharacterNetwork")
    net.WriteUInt(4, 8)
    net.WriteUInt(#arrayPlayers, 8)
    for _, v in ipairs(arrayPlayers) do
        net.WriteEntity(v[1])
        net.WriteUInt(v[2], 8)
    end
    net.Send(ply)
end

function Aden_DC:selectModel(ply, arrayCharacter)
    ply:SetModel(arrayCharacter.cModel)
    if self.Config.ModelScale then
        ply:SetModelScale(arrayCharacter.cScale or 1)
    end
    for k, v in pairs(arrayCharacter.bodyGroups or {}) do
        ply:SetBodygroup(k, v)
    end
end

function Aden_DC:removeEntity(ply)
    for _, v in ipairs(ents.GetAll()) do
        if v.ADC_Owner and v.ADC_Owner == ply then
            v:Remove()
        elseif v.CPPIGetOwner and v:CPPIGetOwner() == ply then
            v:Remove()
        elseif v.GetCreator and v:GetCreator() == ply then
            v:Remove()
        end
    end
end

function Aden_DC:selectCharacter(ply, id, die) // Selection of the character
    local arrayCharacter = ply.adcInformation.arrayCharacter[id]
    ply.adcInformation.switchJob = true
    if ply.adcInformation.selectedCharacter and ply.adcInformation.arrayCharacter[ply.adcInformation.selectedCharacter] then // If we have a selected character, strip the weapon of this character
        for _, v in ipairs(ply.adcInformation.arrayCharacter[ply.adcInformation.selectedCharacter].cWeapons) do
            if self.Config.blackListWeapons[v] then continue end
            ply:StripWeapon(v)
        end
    end
    self:selectNumCharacter(ply, id)
    self:setupBaseVar(ply, arrayCharacter)
    if DarkRP then
        self:setupDarkRPVar(ply, arrayCharacter, die)
    else
        self:selectModel(ply, arrayCharacter)
    end
    ply.adcInformation.switchJob = false
end

function Aden_DC:setupDarkRPVar(ply, arrayCharacter, die) // Value of DarkRP
    ply:setDarkRPVar("rpname", arrayCharacter.firstName .. " " .. arrayCharacter.lastName)
    if self.Config.saveInformations["money"] then
        ply:setDarkRPVar("money", arrayCharacter.cMoney or 0)
    end
    if !DarkRP.disabledDefaults["modules"]["hungermod"] and self.Config.saveInformations["food"] then
        ply:setDarkRPVar("Energy", arrayCharacter.cFood or 100)
    end
    if !arrayCharacter.cJob or !self.Config.saveInformations["job"] then arrayCharacter.cJob = GAMEMODE.DefaultTeam end
    if self.Config.saveInformations["job"] and ply:Team() != arrayCharacter.cJob then
        ply:changeTeam(arrayCharacter.cJob, MRS and true or false)
    end
    if self.Config.UseModelsForJobs then
        if self.Config.ModelsJobs[die and ply:Team() or arrayCharacter.cJob] then
            timer.Simple(1, function()
                self:selectModel(ply, arrayCharacter)
            end)
        end
        return
    end
    if self.Config.enableFaction then // Set the good skin
        timer.Simple(1, function()
            self:selectModel(ply, arrayCharacter)
        end)
        return
    end
    if arrayCharacter.cJob == GAMEMODE.DefaultTeam or arrayCharacter.cJob == ply:Team() then // Dont want citizen model in CP Job
        if ply:Team() != arrayCharacter.cJob then
            ply:changeTeam(arrayCharacter.cJob)
        end
        self:selectModel(ply, arrayCharacter)
    end
end

function Aden_DC:setupBaseVar(ply, arrayCharacter) // Value of all gamemode
    if self.Config.saveInformations["weapon"] then
        for _, v in ipairs(arrayCharacter.cWeapons or {}) do
            ply:Give(v)
        end
    end
    if self.Config.saveInformations["health"] then
        if (!arrayCharacter.cHealth or arrayCharacter.cHealth <= 0) then
            arrayCharacter.cHealth = 100
        end
        ply:SetHealth(arrayCharacter.cHealth)
    end
    if self.Config.saveInformations["armor"] then
        ply:SetArmor(arrayCharacter.cArmor or 0)
    end
    if self.Config.saveInformations["position"] and arrayCharacter.cPos then
        ply:SetPos(arrayCharacter.cPos)
    end
end

function Aden_DC:saveNotif(steamid64, reason, type, callback) // Add a notif in the data base (when the player is disconnected)
    self:SQLRequest(self:Format([[INSERT INTO `arrayNotif` (`reason`, `steamid64`, `type`) VALUES (%s, %s, %s)]], reason, steamid64, type or ""), callback)
end

function Aden_DC:sendNotif(ply, reason, type) // Send Popup
    net.Start("ADC::Popup")
    net.WriteString(reason or "")
    net.WriteString(type or "")
    net.Send(ply)
end

function Aden_DC:executeNotif(ply, callback) // Send all notif when the player reconnect
    self:SQLRequest(self:Format([[SELECT * FROM `arrayNotif` WHERE `steamid64` = %s]], ply:SteamID64()), function(data)
        if data and data[1] then
            for _, v in ipairs(data) do
                Aden_DC:sendNotif(ply, v.reason, v.type)
            end
            self:SQLRequest(self:Format([[DELETE FROM `arrayNotif` WHERE `steamid64` = %s]], ply:SteamID64()), callback)
        end
    end)
end

function Aden_DC:respawnNPC(callback)
    Aden_DC.NPC = {}
    self:SQLRequest(self:Format([[SELECT * FROM `arrayNPC` WHERE `map` = %s]], game.GetMap()), function(data)
        if data and data[1] then
            for _, v in ipairs(data) do
                local npc = ents.Create("npc_adc_menu")
                npc:SetPos(Vector(v.posX, v.posY, v.posZ))
                npc:SetAngles(Angle(v.angX, v.angY, v.angZ))
                npc:Spawn()
                npc.isSaved = true
                Aden_DC.NPC[#Aden_DC.NPC + 1] = npc
            end
        end
        if callback then
            callback()
        end
    end)
end

function Aden_DC:saveNPC(callback)
    for k, v in ipairs(Aden_DC.NPC) do
        if !IsValid(v) or v.isSaved then continue end
        local pos, ang = v:GetPos(), v:GetAngles()
        self:SQLRequest(self:Format([[INSERT INTO `arrayNPC` (`map`, `posX`, `posY`, `posZ`, `angX`, `angY`, `angZ`) VALUES (%s, %s, %s, %s, %s, %s, %s)]], game.GetMap(), pos.x, pos.y, pos.z, ang.x, ang.y, ang.z))
        v.isSaved = true
    end
    callback()
end

function Aden_DC:deleteNPC(callback)
    self:SQLRequest(self:Format([[DELETE FROM `arrayNPC` WHERE map = %s]], game.GetMap()), function()
        for k, v in ipairs(Aden_DC.NPC) do
            if !IsValid(v) then continue end
            v:Remove()
        end
        Aden_DC.NPC = {}
        callback()
    end)
end