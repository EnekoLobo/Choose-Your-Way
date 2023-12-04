Aden_DC.Nets = {}

function Aden_DC.Nets:WriteTable(arrayCharacter)
    net.WriteString(arrayCharacter.firstName or "")
    net.WriteString(arrayCharacter.lastName or "")
    net.WriteUInt(arrayCharacter.dBirth.d or 1, 5) // 2^5 - 1 == 31 (31 day max in a month)
    net.WriteUInt(arrayCharacter.dBirth.m or 1, 4) // 2^4 - 1 == 15 (12 month max in a years)
    net.WriteUInt(arrayCharacter.dBirth.y or Aden_DC.Config.MinimumYears, 20)
    net.WriteString(arrayCharacter.cDesc or "")
    net.WriteUInt(arrayCharacter.cFaction or 0, 8)
    if isnumber(arrayCharacter.cModel) then
        net.WriteBit(true)
        net.WriteUInt(arrayCharacter.cModel or 1, 8)
    else
        net.WriteBit(false)
        net.WriteString(arrayCharacter.cModel or "")
    end
    net.WriteUInt(table.Count(arrayCharacter.bodyGroups or {}), 5)
    for k, v in pairs(arrayCharacter.bodyGroups or {}) do
        net.WriteUInt(k, 5)
        net.WriteUInt(v, 5)
    end
    net.WriteFloat(arrayCharacter.mScale or 1)
    net.WriteBit(arrayCharacter.nAvailable or false) // For the request Name (send nil value = error)
    net.WriteFloat(tonumber(arrayCharacter.cMoney) or 0) // I need to use float because UInt limited to 32 bits
    if DarkRP then
        net.WriteUInt(arrayCharacter.cJob or GAMEMODE.DefaultTeam, 8)
    end
    net.WriteUInt(table.Count(arrayCharacter.withlist or {}), 8)
    for k, v in pairs(arrayCharacter.withlist or {}) do
        net.WriteUInt(k, 8)
        net.WriteBool(v)
    end
    net.WriteUInt(arrayCharacter.cClass or 0, 8)
    if SERVER and CLOTHESMOD and Aden_DC.Config.Support["Clothes Venatuss"] then
        net.WriteTable(arrayCharacter.info and arrayCharacter.info.ClothesV_GetInfos or {})
    end
end

function Aden_DC.Nets:ReadTable()
    local arrayCharacter = {}
    arrayCharacter.firstName = net.ReadString()
    arrayCharacter.lastName = net.ReadString()
    arrayCharacter.dBirth = {}
    arrayCharacter.dBirth.d = net.ReadUInt(5)
    arrayCharacter.dBirth.m = net.ReadUInt(4)
    arrayCharacter.dBirth.y = net.ReadUInt(20)
    arrayCharacter.cDesc = net.ReadString()
    arrayCharacter.cFaction = net.ReadUInt(8)
    local isNum = net.ReadBit() == 1
    if isNum then
        arrayCharacter.cModel = net.ReadUInt(8)
    else
        arrayCharacter.cModel = net.ReadString()
    end
    arrayCharacter.bodyGroups = {}
    for i = 1, net.ReadUInt(5) do
        arrayCharacter.bodyGroups[net.ReadUInt(5)] = net.ReadUInt(5)
    end
    arrayCharacter.mScale = net.ReadFloat()
    arrayCharacter.nAvailable = net.ReadBit() == 1
    arrayCharacter.cMoney = net.ReadFloat()
    if DarkRP then
        arrayCharacter.cJob = net.ReadUInt(8)
    end
    arrayCharacter.withlist = {}
    for i = 1, net.ReadUInt(8) do
        arrayCharacter.withlist[net.ReadUInt(8)] = net.ReadBool()
    end
    arrayCharacter.cClass = net.ReadUInt(8)
    if CLIENT and CLOTHESMOD and Aden_DC.Config.Support["Clothes Venatuss"] then
        arrayCharacter.infoClothes = net.ReadTable()
    end
    return arrayCharacter
end
