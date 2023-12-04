function BRICKSCREDITSTORE.FormatCredits( amount, short )
    if( not short ) then
        return string.Comma( amount ) .. " Credits"
    else
        return string.Comma( amount ) .. "C"
    end
end

function BRICKSCREDITSTORE.FormatCurrency( amount, type, short )
    if( BRICKSCREDITSTORE.CURRENCYTYPES[type] and BRICKSCREDITSTORE.CURRENCYTYPES[type].formatFunc ) then
        return BRICKSCREDITSTORE.CURRENCYTYPES[type].formatFunc( amount, short )
    else
        return "CURRENCY ERROR"
    end
end

function BRICKSCREDITSTORE.GetAdminGroup( ply )
	if( BRICKSCREDITSTORE.LUACONFIG.AdminSystem == "Serverguard" ) then
		return serverguard.player:GetRank(ply)
	elseif( BRICKSCREDITSTORE.LUACONFIG.AdminSystem == "xAdmin" ) then
		return ply:xAdminGetTag()
    elseif( BRICKSCREDITSTORE.LUACONFIG.AdminSystem == "SAM" ) then
		return ply:GetUserGroup()
	else
		return ply:GetNWString("usergroup")
	end
end

function BRICKSCREDITSTORE.HasAdminAccess( ply )
	return BRICKSCREDITSTORE.LUACONFIG.AdminRanks[BRICKSCREDITSTORE.GetAdminGroup( ply )]
end

function BRICKSCREDITSTORE.GetTable( key )
    if( key == "Weapon" ) then
        local WeaponList = {}
        for k, v in pairs( list.Get( "Weapon" ) ) do
            table.insert( WeaponList, k )
        end

        return WeaponList
    elseif( key == "Entities" ) then
        local EntityList = {}
        for k, v in pairs( list.Get( "SpawnableEntities" ) ) do
            table.insert( EntityList, k )
        end

        return EntityList
    elseif( key == "Vehicles" ) then
        local VehicleList = {}
        for k, v in pairs( list.Get( "Vehicles" ) ) do
            table.insert( VehicleList, k )
        end

        return VehicleList
    elseif( key == "Trails" ) then
        local TrailsList = {}
        for k, v in pairs( list.Get( "trail_materials" ) ) do
            table.insert( TrailsList, v )
        end

        return TrailsList
    elseif( key == "Tools" ) then
        local ToolsList = {}
        for key, val in pairs( file.Find( "weapons/gmod_tool/stools/*.lua", "LUA" ) ) do
            local char1, char2, toolmode = string.find( val, "([%w_]*).lua" )
            table.insert( ToolsList, toolmode )
        end

        return ToolsList
    elseif( key == "Jobs" ) then
        local JobsList = {}
        for key, val in pairs( RPExtraTeams ) do
            JobsList[val.name] = val.command
        end

        return JobsList, true
    elseif( key == "Teams" ) then
        local JobsList = {}
        for key, val in pairs( RPExtraTeams ) do
            JobsList[val.name] = tostring( key )
        end

        return JobsList, true
    elseif( key == "Boosters" ) then
        local Boosters = { "Health", "Armor", "Speed", "Jumping", "Damage" }

        return Boosters
    elseif( key == "Groups" ) then
        local Groups = {}

        Groups[1] = "None"
        for k, v in pairs( BRCS_ADMIN_CFG.Groups or BRICKSCREDITSTORE.CONFIG.Groups ) do
            table.insert( Groups, k )
        end

        return Groups
    elseif( key == "Currencies" ) then
        local Currencies = {}
        for k, v in pairs( BRICKSCREDITSTORE.CURRENCYTYPES ) do
            table.insert( Currencies, k )
        end

        return Currencies
    end
    return {}
end