BRICKSCREDITSTORE.ITEMTYPES = {}
BRICKSCREDITSTORE.ITEMTYPES["Currency"] = {
    Name = "Currency",
    ReqInfo = {
        [1] = { "Combo", "Currency type", "Currencies" },
        [2] = { "Int", "Money amount" }
    },
    UseFunction = function( ply, typeInfo )
        if( BRICKSCREDITSTORE.CURRENCYTYPES[typeInfo[1]] and BRICKSCREDITSTORE.CURRENCYTYPES[typeInfo[1]].addFunc ) then
            BRICKSCREDITSTORE.CURRENCYTYPES[typeInfo[1]].addFunc( ply, typeInfo[2] or 0 )
        end
    end
}
BRICKSCREDITSTORE.ITEMTYPES["Health"] = {
    Name = "Health",
    ReqInfo = {
        [1] = { "Int", "Health amount" },
        [2] = { "Int", "Max health" },
    },
    UseFunction = function( ply, typeInfo )
        ply:SetHealth( math.Clamp( ply:Health()+typeInfo[1], 0, typeInfo[2] ) )
    end
}
BRICKSCREDITSTORE.ITEMTYPES["Armor"] = {
    Name = "Armor",
    ReqInfo = {
        [1] = { "Int", "Armor amount" },
        [2] = { "Int", "Max armor" },
    },
    UseFunction = function( ply, typeInfo )
        ply:SetArmor( math.Clamp( ply:Armor()+typeInfo[1], 0, typeInfo[2] ) )
    end
}
BRICKSCREDITSTORE.ITEMTYPES["SWEP"] = {
    Name = "SWEP",
    ReqInfo = {
        [1] = { "Combo", "Weapon class", "Weapon" },
    },
    UseFunction = function( ply, typeInfo )
        ply:Give( typeInfo[1] )
    end
}
BRICKSCREDITSTORE.ITEMTYPES["PERM_SWEP"] = {
    Name = "Permanent SWEP",
    BuyableOnce = true,
    LockerType = "SWEP",
    ReqInfo = {
        [1] = { "String", "Weapon class" },
    },
    UseFunction = function( ply, typeInfo, itemData )
        local itemInfo = { itemData.Name, (itemData.icon or itemData.model), (itemData.Description or "") }
        ply:AddBRCS_LockerItem( "SWEP", typeInfo, itemInfo )
    end
}
BRICKSCREDITSTORE.ITEMTYPES["PERM_MODEL"] = {
    Name = "Permanent Model",
    BuyableOnce = true,
    LockerType = "Model",
    ReqInfo = {
        [1] = { "String", "Model" },
    },
    UseFunction = function( ply, typeInfo, itemData )
        local itemInfo = { itemData.Name, (itemData.icon or itemData.model), (itemData.Description or "") }
        ply:AddBRCS_LockerItem( "Model", typeInfo, itemInfo )
    end
}
BRICKSCREDITSTORE.ITEMTYPES["TempRank"] = {
    Name = "Temporary Rank",
    LockerType = "TempRank",
    ReqInfo = {
        [1] = { "String", "User group" },
        [2] = { "Int", "Remove time" },
    },
    UseFunction = function( ply, typeInfo, itemData )
        local itemInfo = { itemData.Name, (itemData.icon or itemData.model), (itemData.Description or "") }
        ply:AddBRCS_LockerItem( "TempRank", typeInfo, itemInfo )
    end
}
BRICKSCREDITSTORE.ITEMTYPES["Rank"] = {
    Name = "Rank",
    ReqInfo = {
        [1] = { "String", "User group" },
    },
    UseFunction = function( ply, typeInfo, itemData )
        BRICKSCREDITSTORE.AddToGroup( ply, typeInfo[1] )
    end
}
BRICKSCREDITSTORE.ITEMTYPES["Booster"] = {
    Name = "Booster",
    BuyableOnce = true,
    LockerType = "Booster",
    ReqInfo = {
        [1] = { "Combo", "Booster type", "Boosters" },
        [2] = { "String", "Boost percent" },
    },
    UseFunction = function( ply, typeInfo, itemData )
        local itemInfo = { itemData.Name, (itemData.icon or itemData.model), (itemData.Description or "") }
        ply:AddBRCS_LockerItem( "Booster", typeInfo, itemInfo )
    end
}
BRICKSCREDITSTORE.ITEMTYPES["Trail"] = {
    Name = "Trail",
    BuyableOnce = true,
    LockerType = "Trail",
    ReqInfo = {
        [1] = { "Combo", "Trail type", "Trails" },
    },
    UseFunction = function( ply, typeInfo, itemData )
        local itemInfo = { itemData.Name, (itemData.icon or itemData.model), (itemData.Description or "") }
        ply:AddBRCS_LockerItem( "Trail", typeInfo, itemInfo )
    end
}
BRICKSCREDITSTORE.ITEMTYPES["Tool"] = {
    Name = "Tool",
    BuyableOnce = true,
    LockerType = "Tool",
    ReqInfo = {
        [1] = { "Combo", "Tool type", "Tools" },
    },
    UseFunction = function( ply, typeInfo, itemData )
        local itemInfo = { itemData.Name, (itemData.icon or itemData.model), (itemData.Description or "") }
        ply:AddBRCS_LockerItem( "Tool", typeInfo, itemInfo )
    end
}
if( BRICKSCREDITSTORE.LUACONFIG.DarkRP ) then
    BRICKSCREDITSTORE.ITEMTYPES["Job"] = {
        Name = "Job",
        BuyableOnce = true,
        LockerType = "Job",
        ReqInfo = {
            [1] = { "Combo", "Job", "Jobs" },
        },
        UseFunction = function( ply, typeInfo, itemData )
            local itemInfo = { itemData.Name, (itemData.icon or itemData.model), (itemData.Description or "") }
            ply:AddBRCS_LockerItem( "Job", typeInfo, itemInfo )
        end
    }
end
BRICKSCREDITSTORE.ITEMTYPES["Suit"] = {
    Name = "Suit",
    BuyableOnce = true,
    LockerType = "Suit",
    ReqInfo = {
        [1] = { "Int", "Health boost percent" },
        [2] = { "Int", "Armor boost percent" },
        [3] = { "Int", "Speed boost percent" },
        [4] = { "Int", "Jumping boost percent" },
        [5] = { "String", "Playermodel" }
    },
    UseFunction = function( ply, typeInfo, itemData )
        local itemInfo = { itemData.Name, (itemData.icon or itemData.model), (itemData.Description or "") }
        ply:AddBRCS_LockerItem( "Suit", typeInfo, itemInfo )
    end
}
BRICKSCREDITSTORE.ITEMTYPES["Vehicle"] = {
    Name = "Vehicle",
    BuyableOnce = true,
    LockerType = "Vehicle",
    ReqInfo = {
        [1] = { "Combo", "Vehicle", "Vehicles" },
    },
    UseFunction = function( ply, typeInfo, itemData )
        local itemInfo = { itemData.Name, (itemData.icon or itemData.model), (itemData.Description or "") }
        ply:AddBRCS_LockerItem( "Vehicle", typeInfo, itemInfo )
    end
}
BRICKSCREDITSTORE.ITEMTYPES["Entity"] = {
    Name = "Entity",
    ReqInfo = {
        [1] = { "Combo", "Entity", "Entities" },
    },
    UseFunction = function( ply, typeInfo )
        local entity = ents.Create( typeInfo[1] )
        if ( !IsValid( entity ) ) then return end
        entity:SetPos( ply:GetPos()+ply:GetForward()*25 )
        entity:Spawn()
    end
}
BRICKSCREDITSTORE.ITEMTYPES["Experience"] = {
    Name = "Experience",
    ReqInfo = {
        [1] = { "Int", "Experience Amount" },
    },
    UseFunction = function( ply, typeInfo )
        BRICKSCREDITSTORE.AddExperience( ply, typeInfo[1], "Purchase" )
    end
}

if( BATTLEPASS ) then
    BRICKSCREDITSTORE.ITEMTYPES["Battlepass"] = {
        Name = "Battlepass",
		ReqInfo = {},
        UseFunction = function( ply, typeInfo )
            RunConsoleCommand( "battlepass_give_pass", ply:SteamID64() )
        end
    }
    BRICKSCREDITSTORE.ITEMTYPES["Battlepass Tier"] = {
        Name = "Battlepass Tiers",
        ReqInfo = {
            [1] = { "Int", "Tiers" },
        },
        UseFunction = function( ply, typeInfo )
            RunConsoleCommand( "battlepass_give_tier", ply:SteamID64(), typeInfo[1] )
        end
    }
end

BRICKSCREDITSTORE.ITEMTYPES["bWhitelist"] = {
	Name = "bWhitelist Job",
	ReqInfo = {
		[1] = { "Combo", "Job", "Teams" },
	},
    UseFunction = function( ply, typeInfo )
        RunConsoleCommand( "gas_jobwhitelist", "add " .. ply:SteamID64() .. " whitelist " .. typeInfo[1] )
	end
}

BRICKSCREDITSTORE.ITEMTYPES["Command"] = {
	Name = "Console Command",
	ReqInfo = {
		[1] = { "String", "Command" },
	},
    UseFunction = function( ply, typeInfo )
        local arguments = string.Explode( " ", string.Replace( typeInfo[1], "{steamid64}", ply:SteamID64() ) )
        RunConsoleCommand( unpack( arguments ) )
	end
}

if( BRICKSCRAFTING ) then
    BRICKSCREDITSTORE.ITEMTYPES["Crafting Resource"] = {
        Name = "Crafting Resources",
        ReqInfo = {
            [1] = { "String", "Resource Name" },
            [2] = { "Int", "Amount" },
        },
        UseFunction = function( ply, typeInfo )
            ply:AddBCS_InventoryResource( { [typeInfo[1]] = typeInfo[2] } )
        end
    }
end

BRICKSCREDITSTORE.LOCKERTYPES = {}
BRICKSCREDITSTORE.LOCKERTYPES["Suit"] = {
    Name = "Suits",
    OneAtATime = true,
    Conflicts = { ["Model"] = true, ["Booster"] = true },
    ReqInfo = {
        [1] = { "Int", "Health" },
        [2] = { "Int", "Armor" },
        [3] = { "Int", "Speed" },
        [4] = { "Int", "Jumping" },
        [5] = { "String", "Playermodel" }
    },
    OnSpawn = function( ply, typeInfo )
        timer.Simple( 1, function() 
            if( IsValid( ply ) ) then
                if( typeInfo[1] ) then
                    ply:SetHealth( math.Clamp( ply:Health()*(1+(typeInfo[1]/100)), 5, ply:GetMaxHealth()*(1+(typeInfo[1]/100)) ) )
                end
        
                if( typeInfo[2] ) then
                    local Armor = (ply:Armor() > 0 and ply:Armor()*(1+(typeInfo[2]/100))) or 255*(typeInfo[2]/100)
                    ply:SetArmor( math.Clamp( Armor, 5, 255*(typeInfo[2]/100) ) )
                end
        
                if( typeInfo[3] ) then
                    ply.BRCS_OLDW_SPEED = ply:GetWalkSpeed()
                    ply.BRCS_OLDR_SPEED = ply:GetRunSpeed()
                    ply:SetWalkSpeed( ply:GetWalkSpeed()*(1+(typeInfo[3]/100)) )
                    ply:SetRunSpeed( ply:GetRunSpeed()*(1+(typeInfo[3]/100)) )
                end
        
                if( typeInfo[4] ) then
                    ply.BRCS_OLDJ_HEIGHT = ply:GetJumpPower()
                    ply:SetJumpPower( ply:GetJumpPower()*(1+(typeInfo[4]/100)) )
                end
        
                if( typeInfo[5] ) then
                    ply:SetModel( typeInfo[5] )
                end
            end 
        end )
    end,
    OnDisable = function( ply, typeInfo )
        if( typeInfo[3] ) then
            ply:SetWalkSpeed( ply.BRCS_OLDW_SPEED or 10 )
            ply:SetRunSpeed( ply.BRCS_OLDR_SPEED or 10 )
        end

        if( typeInfo[4] ) then
            ply:SetJumpPower( ply.BRCS_OLDJ_HEIGHT or 10 )
        end

        if( not typeInfo[5] or not RPExtraTeams or not RPExtraTeams[ply:Team()] or not RPExtraTeams[ply:Team()].model ) then return end

        local model = RPExtraTeams[ply:Team()].model
        if( istable( model ) ) then
            model = model[1]
        end

        ply:SetModel( model )
    end
}
BRICKSCREDITSTORE.LOCKERTYPES["SWEP"] = {
    Name = "SWEPs",
    ReqInfo = {
        [1] = { "String", "Weapon class" },
    },
    OnSpawn = function( ply, typeInfo )
        ply:Give( typeInfo[1] )
    end,
    OnDisable = function( ply, typeInfo )
        if( ply:HasWeapon( typeInfo[1] ) ) then
            ply:StripWeapon( typeInfo[1] )
        end
    end
}
BRICKSCREDITSTORE.LOCKERTYPES["Model"] = {
    Name = "Models",
    OneAtATime = true,
    Conflicts = { ["Suit"] = true },
    ReqInfo = {
        [1] = { "String", "Model" },
    },
    OnSpawn = function( ply, typeInfo )
        timer.Simple( 0.25, function() if( IsValid( ply ) ) then ply:SetModel( typeInfo[1] ) end end )
    end,
    OnDisable = function( ply, typeInfo )
        if( not RPExtraTeams or not RPExtraTeams[ply:Team()] or not RPExtraTeams[ply:Team()].model ) then return end

        local model = RPExtraTeams[ply:Team()].model
        if( istable( model ) ) then
            model = model[1]
        end

        ply:SetModel( model )
    end
}
BRICKSCREDITSTORE.LOCKERTYPES["Trail"] = {
    Name = "Trails",
    OneAtATime = true,
    ReqInfo = {
        [1] = { "String", "TrailTexture" },
    },
    OnInitialSpawn = function( ply, typeInfo )
        ply.BRCS_TRAIL = util.SpriteTrail( ply, 0, Color( 255, 255, 255 ), false, 15, 1, 4, 1 / ( 15 + 1 ) * 0.5, typeInfo[1] )
    end,
    OnDisable = function( ply, typeInfo )
        if( IsValid( ply.BRCS_TRAIL ) ) then
            ply.BRCS_TRAIL:Remove()
        end
    end
}
BRICKSCREDITSTORE.LOCKERTYPES["TempRank"] = {
    Name = "Ranks",
    OneAtATime = true,
    CantDisable = true,
    TimerKey = 4,
    TimeKey = 2,
    GroupKey = 3,
    ReqInfo = {
        [1] = { "String", "Usergroup" },
        [2] = { "Int", "Removetime" }
    },
    OnEnable = function( ply, typeInfo )
        BRICKSCREDITSTORE.AddToGroup( ply, typeInfo[1] )
    end,
    TimerRunOut = function( ply, typeInfo, itemKey )
        BRICKSCREDITSTORE.AddToGroup( ply, (typeInfo[3] or "user") )
        ply:RemoveBRCS_LockerItem( itemKey, string.format( "Your temporary rank of '%s' has ran out!", typeInfo[1] ) )
    end,
    OnDisable = function( ply, typeInfo, itemKey )
        BRICKSCREDITSTORE.AddToGroup( ply, (typeInfo[3] or "user") )
        ply:RemoveBRCS_LockerItem( itemKey, string.format( "Your temporary rank of '%s' has been disabled!", typeInfo[1] ) )
    end
}
local Boosters = {
    ["Health"] = function( ply, boost )
        ply:SetHealth( math.Clamp( ply:Health()*(1+boost), 5, ply:GetMaxHealth()*(1+boost) ) )
    end,
    ["Armor"] = function( ply, boost )
        local Armor = (ply:Armor() > 0 and ply:Armor()*(1+boost)) or 255*boost
        ply:SetArmor( math.Clamp( Armor, 5, 255 ) )
    end,
    ["Speed"] = function( ply, boost )
        ply.BRCS_OLDW_SPEED = ply:GetWalkSpeed()
        ply.BRCS_OLDR_SPEED = ply:GetRunSpeed()
        ply:SetWalkSpeed( ply:GetWalkSpeed()*(1+boost) )
        ply:SetRunSpeed( ply:GetRunSpeed()*(1+boost) )
    end,
    ["Jumping"] = function( ply, boost )
        ply.BRCS_OLDJ_HEIGHT = ply:GetJumpPower()
        ply:SetJumpPower( ply:GetJumpPower()*(1+boost) )
    end
}
local BoostersEnable = {
    ["Damage"] = function( ply, boost )
        ply.BRCS_DMG_BOOST = 1+boost
    end
}
local BoostersDisable = {
    ["Damage"] = function( ply, boost )
        ply.BRCS_DMG_BOOST = 1
    end,
    ["Speed"] = function( ply, boost )
        ply:SetWalkSpeed( ply.BRCS_OLDW_SPEED or 10 )
        ply:SetRunSpeed( ply.BRCS_OLDR_SPEED or 10 )
    end,
    ["Jumping"] = function( ply, boost )
        ply:SetJumpPower( ply.BRCS_OLDJ_HEIGHT or 10 )
    end
}
BRICKSCREDITSTORE.LOCKERTYPES["Booster"] = {
    Name = "Boosters",
    OnlyActiveKey = 1,
    Conflicts = { ["Suit"] = true },
    ReqInfo = {
        [1] = { "String", "BoosterType" }, -- Types: Health, Armor, Damage, Speed, Jumping
        [2] = { "String", "BoostPercent" },
    },
    OnSpawn = function( ply, typeInfo, toggle )
        if( toggle ) then return end

        if( Boosters[typeInfo[1]] ) then
            timer.Simple( 0.25, function() if( IsValid( ply ) ) then Boosters[typeInfo[1]]( ply, typeInfo[2]/100, toggle ) end end )
        end
    end,
    OnEnable = function( ply, typeInfo )
        if( BoostersEnable[typeInfo[1]] ) then
            BoostersEnable[typeInfo[1]]( ply, typeInfo[2]/100 )
        end
    end,
    OnDisable = function( ply, typeInfo )
        if( BoostersDisable[typeInfo[1]] ) then
            BoostersDisable[typeInfo[1]]( ply, typeInfo[2]/100 )
        end
    end
}
BRICKSCREDITSTORE.LOCKERTYPES["Tool"] = {
    Name = "Tools",
    ReqInfo = {
        [1] = { "String", "ToolType" },
    }
}
if( BRICKSCREDITSTORE.LUACONFIG.DarkRP ) then
    BRICKSCREDITSTORE.LOCKERTYPES["Job"] = {
        Name = "Jobs",
        ReqInfo = {
            [1] = { "String", "Job" },
        }
    }
end
BRICKSCREDITSTORE.LOCKERTYPES["Vehicle"] = {
    Name = "Vehicles",
    UseCooldown = BRICKSCREDITSTORE.LUACONFIG.VehicleUseCooldown,
    ReqInfo = {
        [1] = { "String", "VehicleID" },
    },
    OnUse = function( ply, typeInfo )
        if( not list.Get( "Vehicles" )[typeInfo[1]] ) then return end

        local CarTable = list.Get( "Vehicles" )[typeInfo[1]]

        local carEnt = ents.Create( CarTable.Class )
        carEnt:SetModel( CarTable.Model )
        for k, v in pairs( CarTable.KeyValues or {} ) do
            carEnt:SetKeyValue( k, v )
        end
        carEnt:SetPos( ply:GetPos()-Vector( 0, 100, 0 ) )
        carEnt:Spawn()
    end
}

BRICKSCREDITSTORE.CURRENCYTYPES = {}
BRICKSCREDITSTORE.CURRENCYTYPES["Credits"] = {
    formatFunc = function( amount, short )
        return BRICKSCREDITSTORE.FormatCredits( amount or 0, short )
    end,
    getFunc = function( ply )
        return ply:GetBRCS_Credits()
    end,
    addFunc = function( ply, amount )
        ply:AddBRCS_Credits( amount )
    end
}
if( BRICKSCREDITSTORE.LUACONFIG.DarkRP ) then
    BRICKSCREDITSTORE.CURRENCYTYPES["DarkRP Money"] = {
        formatFunc = function( amount, short )
            return DarkRP.formatMoney( amount or 0 )
        end,
        getFunc = function( ply )
            return ply:getDarkRPVar( "money" )
        end,
        addFunc = function( ply, amount )
            ply:addMoney( amount )
        end
    }
end

if( mTokens ) then
    BRICKSCREDITSTORE.CURRENCYTYPES["MTokens"] = {
        getFunc = function( ply )
            return ((SERVER and mTokens.GetPlayerTokens(ply)) or (CLIENT and mTokens.PlayerTokens)) or 0
        end,
        addFunc = function( ply, amount )
            if( amount > 0 ) then
                mTokens.AddPlayerTokens(ply, amount)
            else
                mTokens.TakePlayerTokens(ply, math.abs(amount))
            end
        end,
        formatFunc = function( amount )
            return string.Comma( amount ) .. " Tokens"
        end
    }
end

BRICKSCREDITSTORE.CURRENCYTYPES["PS2 Points"] = {
    getFunc = function( ply )
        return (ply.PS2_Wallet or {}).points or 0
    end,
    addFunc = function( ply, amount )
        ply:PS2_AddStandardPoints( amount )
    end,
    formatFunc = function( amount )
        return string.Comma( amount ) .. " Points"
    end
}

BRICKSCREDITSTORE.CURRENCYTYPES["PS2 Premium Points"] = {
    getFunc = function( ply )
        return (ply.PS2_Wallet or {}).premiumPoints or 0
    end,
    addFunc = function( ply, amount )
        ply:PS2_AddPremiumPoints( amount )
    end,
    formatFunc = function( amount )
        return string.Comma( amount ) .. " Premium Points"
    end
}

BRICKSCREDITSTORE.CURRENCYTYPES["PS1 Points"] = {
    getFunc = function( ply )
        return ply:PS_GetPoints() or 0
    end,
    addFunc = function( ply, amount )
        ply:PS_GivePoints( amount )
    end,
    formatFunc = function( amount )
        return string.Comma( amount ) .. " Points"
    end
}