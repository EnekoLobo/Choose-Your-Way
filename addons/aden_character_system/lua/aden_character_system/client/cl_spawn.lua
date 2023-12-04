local function readyClient()
    Aden_DC.LocalPlayer = LocalPlayer()
    net.Start("ADC::CharacterNetwork")
    net.WriteUInt(0, 8)
    net.SendToServer()
end

hook.Add("InitPostEntity", "InitPostEntity::ADC::readyClient", readyClient)

function Aden_DC:getCharacter(id)
    id = id or self.ClientSideMenu.selectedCharacter
    if not id then return end
    return self.ClientSideMenu.arrayCharacter[id]
end

function Aden_DC:getCharacters()
    return self.ClientSideMenu.arrayCharacter
end

Aden_DC.ClientSideMenu.playerCharacterID = Aden_DC.ClientSideMenu.playerCharacterID or {}
function Aden_DC:getCharacterID(ply)
    return self.ClientSideMenu.playerCharacterID[ply]
end

net.Receive("ADC::CharacterNetwork", function()
    local id = net.ReadUInt(8)
    if id == 1 then
        local arrayLenght = net.ReadUInt(4)
        local arrayCharacter = {}
        for i = 1, arrayLenght do
            arrayCharacter[i] = Aden_DC.Nets:ReadTable()
        end
        if Aden_DC.Config.Open.InitialSpawn then
            Aden_DC.ClientSideMenu:OpenMenu(arrayCharacter)
        end

        Aden_DC.ClientSideMenu.arrayCharacter = arrayCharacter

        for _, v in ipairs(Aden_DC.Config.Model) do
            if !Aden_DC.Model:IsValidModel(v) then
                Aden_DC.Model:GenerateSpawnIcon(v)
            end
        end

        for _, v in ipairs(istable(Aden_DC.Config.showRoom) and Aden_DC.Config.showRoom or {}) do
            util.PrecacheModel(v.model)
        end
    elseif id == 2 then
        Aden_DC.ClientSideMenu.selectedCharacter = net.ReadUInt(8)
    elseif id == 3 then
        local ply = net.ReadEntity()
        local id = net.ReadUInt(8)
        if not IsValid(ply) then return end
        Aden_DC.ClientSideMenu.playerCharacterID[ply] = id == 0 and nil or id
    elseif id == 4 then
        local arrayLenght = net.ReadUInt(8)
        for i = 1, arrayLenght do
            local ply = net.ReadEntity()
            local id = net.ReadUInt(8)
            if not IsValid(ply) then continue end
            Aden_DC.ClientSideMenu.playerCharacterID[ply] = id == 0 and nil or id
        end
    elseif id == 5 then
        local index = net.ReadUInt(4)
        local length = net.ReadUInt(4)
        if not Aden_DC.ClientSideMenu.arrayCharacter[index] then return end
        for i = 1, length do
            local key = net.ReadString()
            local value = net.ReadType()
            Aden_DC.ClientSideMenu.arrayCharacter[index][key] = value
        end
    end
end)