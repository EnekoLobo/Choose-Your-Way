Aden_DC.Support = Aden_DC.Support or {}
Aden_DC.Support.List = Aden_DC.Support.List or {}

local hookWOS = {
    ["PlayerSpawn"] = {"wOS.ALCS.Dueling.PassiveReset", "wOS.ALCS.ExecSys.RemoveState", "wOS.ALCS.ExecSys.SendExecutions", "wOS.ALCS.ResetBonePos", "wOS.Prestige.ActivatePlayerSpawns", "wOS.SkillTree.ActivatePlayerSpawns"},
}

Aden_DC.Support.List["WOS"] = {
    init = function()
        hook.Add("wOS.ALCS.GetCharacterID", "wOS.ALCS.ReturnCharacter", function(ply)
            if ply.adcInformation and ply.adcInformation.selectedCharacter then
                return ply.adcInformation.selectedCharacter
            end
        end)
    end,
    loadCharacter = function(ply, id)
        hook.Call("wOS.ALCS.PlayerLoadData", nil, ply)
        timer.Simple(1, function()
            local hookTable = hook.GetTable()
            for id, v in pairs(hookWOS) do
                for _, name in ipairs(v) do
                    if hookTable[id][name] then
                        hookTable[id][name](ply)
                    end
                end
            end
        end)
    end,
    saveCharacter = function(ply, id)
        hook.Call("wOS.ALCS.PlayerSaveData", nil, ply)
    end,
    deleteCharacter = function(ply, id)
        hook.Call("wOS.ALCS.PlayerDeleteData", nil, ply, id)
    end,
}

Aden_DC.Support.List["Modern Car Dealer"] = {
    check = function()
        return ModernCarDealer and Aden_DC.Config.Support["ModernCarDealer"]
    end,
    loadCharacter = function(ply, id)
        file.Write("moderncardealer/playerdata/"..tostring(ply:SteamID64())..".json", util.TableToJSON(ply.adcInformation.arrayCharacter[id].info.ModernCarDealer or {}))
    end,
    saveCharacter = function(ply, id)
        ply.adcInformation.arrayCharacter[id].info.ModernCarDealer = util.JSONToTable(file.Read("moderncardealer/playerdata/"..tostring(ply:SteamID64())..".json", "DATA"))
    end,
}

Aden_DC.Support.List["ATM Crap Head"] = {
    check = function()
        return CH_ATM and Aden_DC.Config.Support["CH_ATM"]
    end,
    loadCharacter = function(ply, id)
        if !ply.adcInformation.arrayCharacter[id].info.CH_ATM then
            ply.CH_ATM_BankAccount = CH_ATM.Config.AccountStartMoney
			ply.CH_ATM_BankAccountLevel = 1

            ply.adcInformation.arrayCharacter[id].info.CH_ATM = {ply.CH_ATM_BankAccount, ply.CH_ATM_BankAccountLevel}
        else
            ply.CH_ATM_BankAccount, ply.CH_ATM_BankAccountLevel = ply.adcInformation.arrayCharacter[id].info.CH_ATM[1], ply.adcInformation.arrayCharacter[id].info.CH_ATM[2]
            CH_ATM.SavePlayerBankAccount(ply)
        end
        CH_ATM.SetInterestRate(ply, CH_ATM.Config.AccountLevels[CH_ATM.GetAccountLevel(ply)].InterestRate)
        CH_ATM.NetworkBankAccountToPlayer(ply)
    end,
    saveCharacter = function(ply, id)
        ply.adcInformation.arrayCharacter[id].info.CH_ATM = {CH_ATM.GetMoneyBankAccount(ply), CH_ATM.GetAccountLevel(ply)}
    end,
}

local Notify = {"NotifyUnblacklisted", "NotifyBlacklisted", "NotifyUnwhitelisted", "NotifyWhitelisted"}

Aden_DC.Support.List["Billy Whitelist"] = {
    check = function()
        return GAS and GAS.JobWhitelist and Aden_DC.Config.Support["Billy Whitelist"]
    end,
    loadCharacter = function(ply, id)
        // Disable Notification
        local arrayNotify = {}
        for k, v in ipairs(Notify) do
            arrayNotify[v] = GAS.JobWhitelist.Config[v]
            GAS.JobWhitelist.Config[v] = false
        end

        if GAS.JobWhitelist.PlayerFactions then
            GAS.JobWhitelist.PlayerFactions[ply] = ply.adcInformation.arrayCharacter[id].info.BW_PlayerFactions
        end

        // Remove whitelist and blacklist of the player
        for k, v in pairs(RPExtraTeams) do
            if GAS.JobWhitelist:IsBlacklisted(ply, k) then
                GAS.JobWhitelist:RemoveFromBlacklist(k, GAS.JobWhitelist.LIST_TYPE_STEAMID, ply:AccountID())
            end
            if GAS.JobWhitelist:IsWhitelisted(ply, k) then
                GAS.JobWhitelist:RemoveFromWhitelist(k, GAS.JobWhitelist.LIST_TYPE_STEAMID, ply:AccountID())
            end
        end

        // Assign whitelist and blacklist save
        for k, v in pairs(ply.adcInformation.arrayCharacter[id].info.BW_Blacklists or {}) do
            GAS.JobWhitelist:AddToBlacklist(k, GAS.JobWhitelist.LIST_TYPE_STEAMID, ply:AccountID())
        end
        for k, v in pairs(ply.adcInformation.arrayCharacter[id].info.BW_Whitelists or {}) do
            GAS.JobWhitelist:AddToWhitelist(k, GAS.JobWhitelist.LIST_TYPE_STEAMID, ply:AccountID())
        end

        // Active Notification
        for k, v in pairs(arrayNotify) do
            GAS.JobWhitelist.Config[k] = v
        end
    end,
    saveCharacter = function(ply, id)
        local blacklist = {}
        local whitelist = {}

        for k, v in pairs(GAS.JobWhitelist.Blacklists[GAS.JobWhitelist.LIST_TYPE_STEAMID][ply:AccountID()] or {}) do
            blacklist[k] = v
        end
        for k, v in pairs(GAS.JobWhitelist.Whitelists[GAS.JobWhitelist.LIST_TYPE_STEAMID][ply:AccountID()] or {}) do
            whitelist[k] = v
        end

        if GAS.JobWhitelist.PlayerFactions then
            ply.adcInformation.arrayCharacter[id].info.BW_PlayerFactions = GAS.JobWhitelist.PlayerFactions[ply]
        end
        ply.adcInformation.arrayCharacter[id].info.BW_Blacklists = blacklist
        ply.adcInformation.arrayCharacter[id].info.BW_Whitelists = whitelist
    end,
}

Aden_DC.Support.List["ATM SlownLS"] = {
    check = function()
        return SlownLS and SlownLS.ATM and Aden_DC.Config.Support["ATM SlownLS"]
    end,
    loadCharacter = function(ply, id)
        ply.SlownLS_ATM_Account.balance = ply.adcInformation.arrayCharacter[id].info.SL_ATM or 0
        SlownLS.ATM:Save(ply)
    end,
    saveCharacter = function(ply, id)
        ply.adcInformation.arrayCharacter[id].info.SL_ATM = ply.SlownLS_ATM_Account.balance
    end,
}

Aden_DC.Support.List["WCD"] = {
    check = function()
        return WCD and Aden_DC.Config.Support["WCD"]
    end,
    loadCharacter = function(ply, id)
        ply.__WCDCoreOwned = ply.adcInformation.arrayCharacter[id].info.__WCDCoreOwned or {}
        WCD:SavePlayerData("owned", ply, ply.__WCDCoreOwned)
        ply.__WCDSpecifics = ply.adcInformation.arrayCharacter[id].info.__WCDSpecifics or {}
        WCD:SavePlayerData("specifics", ply, ply.__WCDSpecifics)
        timer.Simple(1, function()
            if !IsValid(ply) then return end
            WCD:InitializePlayer(ply)
        end)
    end,
    saveCharacter = function(ply, id)
        ply.adcInformation.arrayCharacter[id].info.__WCDCoreOwned = ply.__WCDCoreOwned or {}
        ply.adcInformation.arrayCharacter[id].info.__WCDSpecifics = ply.__WCDSpecifics or {}
    end,
}

Aden_DC.Support.List["xInventory"] = {
    check = function()
        return WCD and Aden_DC.Config.Support["xInventory"]
    end,
    loadCharacter = function(ply, id)
        ply.xInventoryInventory = ply.adcInformation.arrayCharacter[id].info.xInventoryInventory or {}
    end,
    saveCharacter = function(ply, id)
        ply.adcInformation.arrayCharacter[id].info.xInventoryInventory = ply.xInventoryInventory or {}
    end,
}

Aden_DC.Support.List["Itemstore"] = {
    check = function()
        return itemstore and Aden_DC.Config.Support["Itemstore"]
    end,
    loadCharacter = function(ply, id)
        if ply.Bank then
            ply.Bank.Items = {}
            for k, v in pairs(ply.adcInformation.arrayCharacter[id].info.IS_BankItems or {}) do
                ply.Bank:SetItem(k, itemstore.Item(v.Class, v.Data))
            end
            ply.Bank:QueueSync()
        end
        if ply.Inventory then
            ply.Inventory.Items = {}
            for k, v in pairs(ply.adcInformation.arrayCharacter[id].info.IS_InventoryItems or {}) do
                ply.Inventory:SetItem(k, itemstore.Item(v.Class, v.Data))
            end
            ply.Inventory:QueueSync()
        end
    end,
    saveCharacter = function(ply, id)
        if ply.Bank then
            local inv = {}
            for k, v in pairs(ply.Bank:GetItems()) do
                inv[k] = {Class = v.Class, Data = v.Data}
            end
            ply.adcInformation.arrayCharacter[id].info.IS_BankItems = inv
        end
        if ply.Inventory then
            local inv = {}
            for k, v in pairs(ply.Inventory:GetItems()) do
                inv[k] = {Class = v.Class, Data = v.Data}
            end
            ply.adcInformation.arrayCharacter[id].info.IS_InventoryItems = inv
        end
    end,
}

Aden_DC.Support.List["Leveling System"] = {
    check = function()
        return LevelSystemConfiguration and Aden_DC.Config.Support["Leveling System"]
    end,
    loadCharacter = function(ply, id)
        ply:setDarkRPVar("level", ply.adcInformation.arrayCharacter[id].info.Leveling_LVL or 1)
        ply:setDarkRPVar("xp", ply.adcInformation.arrayCharacter[id].info.Leveling_XP or 0)
    end,
    saveCharacter = function(ply, id)
        ply.adcInformation.arrayCharacter[id].info.Leveling_LVL = ply:getDarkRPVar("level") or 1
        ply.adcInformation.arrayCharacter[id].info.Leveling_XP = ply:getDarkRPVar("xp") or 0
    end,
}

Aden_DC.Support.List["Guthlevelsystem"] = {
    check = function()
        return guthlevelsystem and Aden_DC.Config.Support["Guthlevelsystem"]
    end,
    loadCharacter = function(ply, id)
        ply:LSSetLVL(tonumber(ply.adcInformation.arrayCharacter[id].info.Guthlevelsystem_LVL or 1), true)
        ply:LSSetXP(tonumber(ply.adcInformation.arrayCharacter[id].info.Guthlevelsystem_XP or 0))
        ply:LSCalcNXP()
        ply:LSSendData()
    end,
    saveCharacter = function(ply, id)
        ply.adcInformation.arrayCharacter[id].info.Guthlevelsystem_LVL = ply:LSGetLVL() or 1
        ply.adcInformation.arrayCharacter[id].info.Guthlevelsystem_XP = ply:LSGetXP() or 0
    end,
}

Aden_DC.Support.List["bodyGroupr"] = {
    check = function()
        return true
    end,
    saveCharacter = function(ply, id)
        if !DarkRP or Aden_DC.Config.saveInformations["job"] or ply:Team() == GAMEMODE.DefaultTeam then
            local bodyGroups = {}
            for k, v in pairs(ply:GetBodyGroups()) do
                bodyGroups[v.id] = ply:GetBodygroup(v.id)
            end
            if ply.adcInformation.arrayCharacter[id] then
                Aden_DC:updateCharacter(ply.adcInformation.arrayCharacter[id], nil, "bodyGroups", bodyGroups, "cModel", ply:GetModel())
            end
        end
    end,
}

Aden_DC.Support.List["Clothes Venatuss"] = {
    check = function()
        return CLOTHESMOD and Aden_DC.Config.Support["Clothes Venatuss"]
    end,
    init = function()
        net.Receive("ClothesMod:PlayerHasLoaded", function() end)
    end,
    createCharacter = function(ply, id)
        Aden_DC.Support.List["Clothes Venatuss"].saveCharacter(ply, id)
    end,
    loadCharacter = function(ply, id)
        CLOTHESMOD.PlayerInfos[ply:SteamID64()] = ply.adcInformation.arrayCharacter[id].info.ClothesV_GetInfos or {
    			model = "models/kerry/player/citizen/male_01.mdl",
    			name = ply:SteamName() or "No name", -- DarkRP function
    			surname = "",
    			sex = 1,
    			playerColor = Vector(1,1,1),
    			bodygroups = {
    				top = "polo",
    				pant = "pant",
    			},
    			skin = 0,
    			eyestexture = {
    				basetexture = {
    					["r"] = "models/bloo_itcom_zel/citizens/facemaps/eyeball_r_blue",
    					["l"] = "models/bloo_itcom_zel/citizens/facemaps/eyeball_l_blue",
    				},
    			},
    			hasCostume = false, -- disable tee and pant and shoes texture
    			teetexture = {
    				basetexture = "models/bloo_itcom_zel/citizens/citizen_sheet2", -- name of the tee Choosen in the first part of the menu
    				hasCustomThings = false, -- if has custom things or not, if true then basetexture should be an id
    				id = 1,
    			},
    			panttexture = {
    				basetexture = "models/bloo_itcom_zel/citizens/citizen_sheet2",
    			},
    		}
        CLOTHESMOD.PlayerTops = CLOTHESMOD.PlayerTops or {}
        CLOTHESMOD.PlayerBottoms = CLOTHESMOD.PlayerBottoms or {}
        CLOTHESMOD.PlayerTops[ply:SteamID64()] = ply.adcInformation.arrayCharacter[id].info.ClothesV_GetTopList or {}
        CLOTHESMOD.PlayerBottoms[ply:SteamID64()] = ply.adcInformation.arrayCharacter[id].info.ClothesV_CM_GetBottomList or {}
        timer.Simple(0, function()
            ply:CM_NetworkTableInfos()
        end)
    end,
    saveCharacter = function(ply, id)
        ply.adcInformation.arrayCharacter[id].info.ClothesV_GetInfos = ply:CM_GetInfos() or {}
        ply.adcInformation.arrayCharacter[id].info.ClothesV_GetTopList = ply:CM_GetTopList() or {}
        ply.adcInformation.arrayCharacter[id].info.ClothesV_GetInfos.name = ply.adcInformation.arrayCharacter[id].firstName
        ply.adcInformation.arrayCharacter[id].info.ClothesV_GetInfos.surname = ply.adcInformation.arrayCharacter[id].lastName
        ply.adcInformation.arrayCharacter[id].info.ClothesV_CM_GetBottomList = ply:CM_GetBottomList() or {}
        ply.adcInformation.arrayCharacter[id].cModel = ply.adcInformation.arrayCharacter[id].info.ClothesV_GetInfos.model
        timer.Simple(1, function()
            if !IsValid(ply) then return end
            ply.CanCreateCharacter = true
        end)
        ply.CanCreateCharacter = true
        Aden_DC:updateCharacter(ply.adcInformation.arrayCharacter[id], nil, "info", ply.adcInformation.arrayCharacter[id].info)
        Aden_DC:selectNumCharacter(ply, nil)
    end,
    adminUpdateCharacter = function(ply, id)
        if CLOTHESMOD and Aden_DC.Config.Support["Clothes Venatuss"] and ply.adcInformation.arrayCharacter[id].info and ply.adcInformation.arrayCharacter[id].info.ClothesV_GetInfos then
            ply.adcInformation.arrayCharacter[id].info.ClothesV_GetInfos.name = ply.adcInformation.arrayCharacter[id].firstName
            ply.adcInformation.arrayCharacter[id].info.ClothesV_GetInfos.surname = ply.adcInformation.arrayCharacter[id].lastName
        end
    end,
}

Aden_DC.Support.List["Venatuss Car Dealer"] = {
    check = function()
        return AdvCarDealer and Aden_DC.Config.Support["Venatuss Car Dealer"]
    end,
    loadCharacter = function(ply, id)
        AdvCarDealer:ClearPlayerCars(ply, function()
            timer.Simple(0, function()
                if !IsValid(ply) then return end
                for _, v in pairs(ply.adcInformation.arrayCharacter[id].info.VCD_lastPlayerCars) do
                    AdvCarDealer:AddPlayerCar(ply, v, true)
                end
            end)
        end)
    end,
    saveCharacter = function(ply, id)
        ply.adcInformation.arrayCharacter[id].info.VCD_lastPlayerCars = ply.lastPlayerCars or {}
    end,
}

Aden_DC.Support.List["MRS Support"] = {
    check = function()
        return MRS
    end,
    loadCharacter = function(ply, id)
        hook.Run("VoidChar.CharacterSelected", ply)
        MRS.SetupRankData(ply, ply.adcInformation.arrayCharacter[id].cJob)
    end,
    saveCharacter = function(ply, id)
        MRS.SavePlayerData(ply)
    end,
    deleteCharacter = function(ply, id)
        MRS.DB.Query("DELETE FROM mrs_player WHERE id=" .. ply:SteamID() .. id, function() end)
    end,
}

Aden_DC.Support.List["VoidCases"] = {
    check = function()
        return VoidCases and Aden_DC.Config.Support["VoidCases"]
    end,
    loadCharacter = function(ply, id)
        VoidCases.PlayerInventories[ply:SteamID64()] = ply.adcInformation.arrayCharacter[id].info.VoidCases_INV or {}
        VoidCases.NetworkInventory(ply)
        VoidCases.NetworkMarketplace(ply)
        VoidCases.NetworkEquippedItems(ply)
    end,
    saveCharacter = function(ply, id)
        ply.adcInformation.arrayCharacter[id].info.VoidCases_INV = VoidCases.PlayerInventories[ply:SteamID64()] or {}
    end,
}

Aden_DC.Support.List["PSS"] = {
    check = function()
        return PermSWEPsCFG
    end,
    loadCharacter = function(ply, id)
        timer.Simple(1, function()
            local arrayHook = hook.GetTable()
            if arrayHook["PlayerLoadout"] and arrayHook["PlayerLoadout"]["GivePermSweps"] then
                arrayHook["PlayerLoadout"]["GivePermSweps"](ply)
            end
        end)
    end,
}

Aden_DC.Support.List["Diablos Training"] = {
    check = function()
        return Diablos and Diablos.TS and Aden_DC.Config.Support["Diablos Training"]
    end,
    loadCharacter = function(ply, id)
        local tableConstruct = Diablos.TS:TransformSavedTableToSQLTable(ply.adcInformation.arrayCharacter[id].info.CharacterDiablosTraining)
        Diablos.TS:ConstructTrainingData(ply, tableConstruct, true)
    end,
    saveCharacter = function(ply, id)
        ply.adcInformation.arrayCharacter[id].info.CharacterDiablosTraining = ply:TSGetTrainingInfo()
    end,
}

Aden_DC.Support.List["KB RCD"] = {
    check = function()
        return RCD and Aden_DC.Config.Support["KB RCD"]
    end,
    loadCharacter = function(ply, id)
        ply.RCD.vehicleBought = ply.adcInformation.arrayCharacter[id].info.RCDVehicleBought or {}

        local boughVehiclesCompressed = util.Compress(util.TableToJSON(ply.RCD.vehicleBought))

        net.Start("RCD:Main:Client")
            net.WriteUInt(10, 4)
            net.WriteUInt(#boughVehiclesCompressed, 32)
            net.WriteData(boughVehiclesCompressed, #boughVehiclesCompressed)
        net.Send(ply)
    end,
    saveCharacter = function(ply, id)
        ply.adcInformation.arrayCharacter[id].info.RCDVehicleBought = ply.RCD.vehicleBought
    end
}

Aden_DC.Support.List["Gmod Leveling System"] = {
    check = function()
        return Aden_DC.Config.Support["Gmod Leveling System"]
    end,
    loadCharacter = function(ply, id)
        ply:setLevel(ply.adcInformation.arrayCharacter[id].info.NordaLevel or 1)
        ply:setXP(ply.adcInformation.arrayCharacter[id].info.NordaXP or 0)
    end,
    saveCharacter = function(ply, id)
        ply.adcInformation.arrayCharacter[id].info.NordaLevel = ply:getLevel()
        ply.adcInformation.arrayCharacter[id].info.NordaXP = ply:getXP()
    end
}

Aden_DC.Support.List["Gmod Advanced Inventory System"] = {
    check = function()
        return Aden_DC.Config.Support["Gmod Advanced Inventory System"]
    end,
    loadCharacter = function(ply, id)
        ply.Norda_Inventory = ply.adcInformation.arrayCharacter[id].info.Norda_Inventory or {}
        net.Start("Download_Inventory")
            net.WriteTable(ply.Norda_Inventory)
        net.Send(ply)
    end,
    saveCharacter = function(ply, id)
        ply.adcInformation.arrayCharacter[id].info.Norda_Inventory = ply.Norda_Inventory or {}
    end
}

// Custom
Aden_DC.Support.List["NPS"] = {
    check = function()
        return NPS
    end,
    loadCharacter = function(ply, id)
        if !ply.adcInformation.arrayCharacter[id].info.NPS_randomID then
            ply.adcInformation.arrayCharacter[id].info.NPS_randomID = math.random(1000, 9999)
        end
        ply:SetNWString("NPS.Prefix", ply.adcInformation.arrayCharacter[id].info.NPS_randomID)
    end,
}

Aden_DC.Support.List["WOS Medal"] = {
    check = function()
        return wOS and wOS.Medals
    end,
    loadCharacter = function(ply, id)
        ply.SelectedMedals = ply.adcInformation.arrayCharacter[id].info.SelectedMedals or {}
        ply.AccoladeList = ply.adcInformation.arrayCharacter[id].info.AccoladeList or {}
        net.Start("wOS.Medals.Badges.RequestBadgePos")
    		net.WriteEntity(ply)
    		net.WriteTable(ply.SelectedMedals)
    	net.Broadcast()
        wOS.Medals:SendPlayerMedals(ply)
    end,
    saveCharacter = function(ply, id)
        ply.adcInformation.arrayCharacter[id].info.SelectedMedals = ply.SelectedMedals
        ply.adcInformation.arrayCharacter[id].info.AccoladeList = ply.AccoladeList
    end,
}

timer.Simple(1, function()
    for k, v in pairs(Aden_DC.Support.List) do
        if !v.init then continue end
        v.init()
    end
end)

function Aden_DC.Support:saveCharacter(ply)
    local id = ply.adcInformation.selectedCharacter
    for k, v in pairs(Aden_DC.Support.List) do
        if (v.check and !v.check()) or !v.saveCharacter then continue end
        v.saveCharacter(ply, id)
    end
end

function Aden_DC.Support:loadCharacter(ply)
    for k, v in pairs(Aden_DC.Support.List) do
        if (v.check and !v.check()) or !v.loadCharacter then continue end
        v.loadCharacter(ply, ply.adcInformation.selectedCharacter)
    end
end

function Aden_DC.Support:preChangeCharacter(ply, new)
    for k, v in pairs(Aden_DC.Support.List) do
        if (v.check and !v.check()) or !v.preChangeCharacter then continue end
        v.preChangeCharacter(ply, ply.adcInformation.selectedCharacter, new)
    end
end

function Aden_DC.Support:createCharacter(ply, id)
    for k, v in pairs(Aden_DC.Support.List) do
        if (v.check and !v.check()) or !v.createCharacter then continue end
        v.createCharacter(ply, id)
    end
end

function Aden_DC.Support:deleteCharacter(ply, id)
    for k, v in pairs(Aden_DC.Support.List) do
        if (v.check and !v.check()) or !v.deleteCharacter then continue end
        v.deleteCharacter(ply, id)
    end
end

function Aden_DC.Support:adminUpdateCharacter(ply, id)
    for k, v in pairs(Aden_DC.Support.List) do
        if (v.check and !v.check()) or !v.adminUpdateCharacter then continue end
        v.adminUpdateCharacter(ply, id)
    end
end
