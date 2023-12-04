local ply_meta = FindMetaTable( "Player" )

util.AddNetworkString( "BRCS_Net_Notify" )
function ply_meta:NotifyBRCS( Message )
    net.Start( "BRCS_Net_Notify" )
        net.WriteString( Message )
    net.Send( self )
end

concommand.Add( "setcredits", function( ply, cmd, args )
    if( IsValid( ply ) and not BRICKSCREDITSTORE.HasAdminAccess( ply ) ) then 
        ply:NotifyBRCS( "You must be an admin to use this command!" )
        return 
    end
    if( not args[1] or not args[2] ) then return end

    local receiver = player.GetBySteamID64( args[1] )
    if( not receiver or not IsValid( receiver ) ) then return end

    local credits = tonumber( args[2] )
    if( not credits or not isnumber( credits ) ) then return end

    receiver:SetBRCS_Credits( credits )

    if( not IsValid( ply ) ) then return end
    ply:NotifyBRCS( string.format( "Set %s's credits to %s!", receiver:Nick(), string.Comma( credits ) ) )
end )

concommand.Add( "addcredits", function( ply, cmd, args )
    if( IsValid( ply ) and not BRICKSCREDITSTORE.HasAdminAccess( ply ) ) then 
        ply:NotifyBRCS( "You must be an admin to use this command!" )
        return 
    end
    if( not args[1] or not args[2] ) then return end

    local receiver = player.GetBySteamID64( args[1] )
    if( not receiver or not IsValid( receiver ) ) then return end

    local credits = tonumber( args[2] )
    if( not credits or not isnumber( credits ) ) then return end

    receiver:AddBRCS_Credits( credits )

    if( not IsValid( ply ) ) then return end
    ply:NotifyBRCS( string.format( "Gave %s %s credits!", receiver:Nick(), string.Comma( credits ) ) )
end )

concommand.Add( "removecredits", function( ply, cmd, args )
    if( IsValid( ply ) and not BRICKSCREDITSTORE.HasAdminAccess( ply ) ) then 
        ply:NotifyBRCS( "You must be an admin to use this command!" )
        return 
    end
    if( not args[1] or not args[2] ) then return end

    local receiver = player.GetBySteamID64( args[1] )
    if( not receiver or not IsValid( receiver ) ) then return end

    local credits = tonumber( args[2] )
    if( not credits or not isnumber( credits ) ) then return end

    receiver:RemoveBRCS_Credits( credits )

    if( not IsValid( ply ) ) then return end
    ply:NotifyBRCS( string.format( "Taken %s credits from %s!", string.Comma( credits ), receiver:Nick() ) )
end )

local function Ply(name) -- Finds a player from a string
	name = string.lower(name);
	for _,v in ipairs(player.GetHumans()) do
		if(string.find(string.lower(v:Name()),name,1,true) != nil)
			then return v;
		end
	end
end

local CMDs = { "setcredits", "addcredits", "removecredits" }
hook.Add( "PlayerSay", "BRCSHooks_PlayerSay_Commands", function( ply, text, bteam )
	local text = string.lower( text )
	
	for k, v in pairs( CMDs ) do
        if( string.StartWith( text, "/" .. v ) or string.StartWith( text, "!" .. v ) ) then
            if( BRICKSCREDITSTORE.HasAdminAccess( ply ) ) then
                local stringTable = string.Split( text, " " )
                local numValue = tonumber( table.GetLastValue( stringTable ) )

                if( isnumber( numValue ) and #stringTable == 3 ) then
                    local victimPly = Ply( stringTable[2] )
                    
                    if( IsValid( victimPly ) and victimPly:IsPlayer() ) then
                        ply:ConCommand( v .. " " .. victimPly:SteamID64() .. " " .. numValue )
                        return ""
                    else
                        ply:NotifyBRCS( "A player could not be found with this name!" )
                        return ""
                    end
                else
                    ply:NotifyBRCS( "You did not provide enough arguments (cmd, plyName, amount)." )
                    return ""
                end
            else
                ply:NotifyBRCS( "You must be an admin to use this command!" )
                return ""
            end
        end
    end
end)

util.AddNetworkString( "BRCS_Net_Purchase" )
net.Receive( "BRCS_Net_Purchase", function( len, ply )
    local NPCType = net.ReadString()
    local ItemKey = net.ReadInt( 32 )

    if( not NPCType or not ItemKey ) then return end
    if( BRICKSCREDITSTORE.CONFIG.NPCs[NPCType] and BRICKSCREDITSTORE.CONFIG.NPCs[NPCType].Items and BRICKSCREDITSTORE.CONFIG.NPCs[NPCType].Items[ItemKey] ) then
        local ItemTable = BRICKSCREDITSTORE.CONFIG.NPCs[NPCType].Items[ItemKey]
        local Currency = BRICKSCREDITSTORE.CONFIG.NPCs[NPCType].currency

        if( not ItemTable.GroupType or not BRICKSCREDITSTORE.CONFIG.Groups[ItemTable.GroupType] or BRICKSCREDITSTORE.CONFIG.Groups[ItemTable.GroupType][BRICKSCREDITSTORE.GetAdminGroup( ply )] ) then
            if( not (BRICKSCREDITSTORE.ITEMTYPES[ItemTable.Type or ""] or {}).BuyableOnce or not ply:GetBRCS_AlreadyOwn( NPCType, ItemKey ) ) then
                if( BRICKSCREDITSTORE.CURRENCYTYPES[Currency] and BRICKSCREDITSTORE.CURRENCYTYPES[Currency].getFunc ) then
                    if( BRICKSCREDITSTORE.CURRENCYTYPES[Currency].getFunc( ply ) >= (ItemTable.Price or 1) ) then
                        if( BRICKSCREDITSTORE.ITEMTYPES[ItemTable.Type] and BRICKSCREDITSTORE.ITEMTYPES[ItemTable.Type].UseFunction and ItemTable.TypeInfo ) then
                            BRICKSCREDITSTORE.ITEMTYPES[ItemTable.Type].UseFunction( ply, ItemTable.TypeInfo, ItemTable )
                        end

                        BRICKSCREDITSTORE.CURRENCYTYPES[Currency].addFunc( ply, -(ItemTable.Price or 1) )

                        ply:NotifyBRCS( string.format( "You have successfully purchased this item for %s!", (BRICKSCREDITSTORE.CURRENCYTYPES[Currency].formatFunc( (ItemTable.Price or 1) ) or "ERROR") ) )
                    else
                        ply:NotifyBRCS( "You cannot afford this item!" )
                    end
                else
                    ply:NotifyBRCS( "This shop's currency is invalid!" )
                end
            else
                ply:NotifyBRCS( "You already own this item!" )
            end
        else
            ply:NotifyBRCS( string.format( "This item is %s only!", ItemTable.GroupType ) )
        end
    else
        ply:NotifyBRCS( "This item is invalid!" )
    end
end )

util.AddNetworkString( "BRCS_Net_Remove" )
net.Receive( "BRCS_Net_Remove", function( len, ply )
    local ItemKey = net.ReadInt( 32 )

    if( not ItemKey ) then return end

    ply:BRCS_Remove( ItemKey )
end )

if( BRICKSCREDITSTORE.LUACONFIG.CanTransferItems ) then
    util.AddNetworkString( "BRCS_Net_Transfer" )
    net.Receive( "BRCS_Net_Transfer", function( len, ply )
        local ItemKey = net.ReadInt( 32 )
        local victimID = net.ReadString()

        if( not ItemKey or not victimID ) then return end

        local victimPly = player.GetBySteamID64( victimID )

        if( not IsValid( victimPly ) or victimPly == ply ) then
            ply:NotifyBRCS( "This player is no longer valid!" )
            return
        end

        local PlyLocker = ply:GetBRCS_Locker()

        if( not PlyLocker[ItemKey] ) then return end

        local ItemTable = PlyLocker[ItemKey]
        ply:BRCS_Remove( ItemKey )

        local victimLocker = victimPly:GetBRCS_Locker()
        table.insert( victimLocker, ItemTable )

        victimPly:SetBRCS_Locker( victimLocker )
    end )
end

util.AddNetworkString( "BRCS_Net_ToggleLocker" )
net.Receive( "BRCS_Net_ToggleLocker", function( len, ply )
    local ItemKey = net.ReadInt( 32 )

    if( not ItemKey ) then return end
    if( CurTime() < (ply.BRCS_TOGGLE_CD or 0) ) then 
        ply:NotifyBRCS( "Please wait before toggling another item!" )
        return 
    end

    ply.BRCS_TOGGLE_CD = CurTime()+0.5

    ply:BRCS_Toggle( ItemKey, true )
end )

hook.Add( "PlayerSpawn", "BRCSHooks_PlayerSpawn_Locker", function( ply )
    if( ply:GetBRCS_Active() and table.Count( ply:GetBRCS_Active() ) > 0 ) then
        local PlyLocker = ply:GetBRCS_Locker()
        for k, v in pairs( ply:GetBRCS_Active() ) do
            if( PlyLocker[k] and PlyLocker[k][1] and PlyLocker[k][2] and BRICKSCREDITSTORE.LOCKERTYPES[PlyLocker[k][1]] and BRICKSCREDITSTORE.LOCKERTYPES[PlyLocker[k][1]].OnSpawn ) then
                BRICKSCREDITSTORE.LOCKERTYPES[PlyLocker[k][1]].OnSpawn( ply, PlyLocker[k][2] )
            end
        end
    end
end )

hook.Add( "PlayerInitialSpawn", "BRCSHooks_PlayerInitialSpawn_Locker", function( ply )
    if( ply:GetBRCS_Active() and table.Count( ply:GetBRCS_Active() ) > 0 ) then
        local PlyLocker = ply:GetBRCS_Locker()
        for k, v in pairs( ply:GetBRCS_Active() ) do
            if( PlyLocker[k] and PlyLocker[k][1] and PlyLocker[k][2] and BRICKSCREDITSTORE.LOCKERTYPES[PlyLocker[k][1]] and BRICKSCREDITSTORE.LOCKERTYPES[PlyLocker[k][1]].OnInitialSpawn ) then
                BRICKSCREDITSTORE.LOCKERTYPES[PlyLocker[k][1]].OnInitialSpawn( ply, PlyLocker[k][2] )
            end
        end
    end
end )

if( BRICKSCREDITSTORE.LUACONFIG.DarkRP ) then
    hook.Add( "PlayerChangedTeam", "BRCSHooks_PlayerChangedTeam_Locker", function( ply )
        if( ply:GetBRCS_Active() and table.Count( ply:GetBRCS_Active() ) > 0 ) then
            timer.Simple( 0, function()
                local PlyLocker = ply:GetBRCS_Locker()
                for k, v in pairs( ply:GetBRCS_Active() ) do
                    if( PlyLocker[k] and PlyLocker[k][1] and PlyLocker[k][2] and BRICKSCREDITSTORE.LOCKERTYPES[PlyLocker[k][1]] and BRICKSCREDITSTORE.LOCKERTYPES[PlyLocker[k][1]].OnSpawn ) then
                        BRICKSCREDITSTORE.LOCKERTYPES[PlyLocker[k][1]].OnSpawn( ply, PlyLocker[k][2] )
                    end
                end
            end )
        end
    end )
end

hook.Add( "EntityTakeDamage", "BRCSHooks_EntityTakeDamage_DamageBoost", function( target, dmginfo )
	if( IsValid( dmginfo:GetAttacker() ) and dmginfo:GetAttacker():IsPlayer() and dmginfo:GetAttacker().BRCS_DMG_BOOST  ) then
		dmginfo:ScaleDamage( dmginfo:GetAttacker().BRCS_DMG_BOOST )
	end
end )

hook.Add( "CanTool", "BRCSHooks_CanTool_ToolType", function( ply, tr, tool )
    local IsBuyable
    for k, v in pairs( BRICKSCREDITSTORE.CONFIG.NPCs ) do
        if( v.Items ) then
            for key, val in pairs( v.Items ) do
                if( val.Type == "Tool" and val.TypeInfo and (val.TypeInfo[1] or "") == tool ) then
                    IsBuyable = { k, key }
                    break
                end
            end
        end
    end

    if( IsValid( ply ) and IsBuyable ) then
        local hasItem, itemKey = ply:GetBRCS_AlreadyOwn( IsBuyable[1], IsBuyable[2] )
        if( not hasItem or not ply:GetBRCS_Active()[itemKey] ) then
            ply:NotifyBRCS( "You must buy access to this toolgun in the store!" )
            return false
        end
	end
end )

hook.Add( "playerCanChangeTeam", "BRCSHooks_playerCanChangeTeam_JobType", function( ply, team_n, force )
    local IsBuyable
    for k, v in pairs( BRICKSCREDITSTORE.CONFIG.NPCs ) do
        if( v.Items ) then
            for key, val in pairs( v.Items ) do
                if( val.Type == "Job" and val.TypeInfo and (val.TypeInfo[1] or "") == ((RPExtraTeams[team_n] or {}).command or "NIL COMMAND") ) then
                    IsBuyable = { k, key }
                    break
                end
            end
        end
    end

    if( IsValid( ply ) and IsBuyable ) then
        local hasItem, itemKey = ply:GetBRCS_AlreadyOwn( IsBuyable[1], IsBuyable[2] )
        if( not hasItem or not ply:GetBRCS_Active()[itemKey] ) then
            return false, "You must buy access to this job in the store!"
        end
	end
end )

function BRICKSCREDITSTORE.AddExperience( ply, amount, reason )
	if( DARKRP_ESSENTIALS or DarkRPFoundation or UUI ) then
		ply:AddExperience( amount, (reason or "") )
	elseif( Sublime ) then
		ply:SL_AddExperience(amount, (reason or ""), true )
	else
		ply:addXP( amount, true )
	end
end

hook.Add( "canDropWeapon", "BRCSHooks_canDropWeapon_preventWeaponDrops", function( ply, wep )
    if( IsValid( wep ) ) then
        local NPCType, itemKey
        for k, v in pairs( BRICKSCREDITSTORE.CONFIG.NPCs ) do
            for key, val in pairs( BRICKSCREDITSTORE.CONFIG.NPCs[k].Items ) do
                if( val.Type == "PERM_SWEP" and val.TypeInfo[1] == wep:GetClass() ) then
                    NPCType = k
                    itemKey = key
                    break
                end
            end
        end

        if( NPCType and itemKey ) then
            local Own, key = ply:GetBRCS_AlreadyOwn( NPCType, itemKey )
            if( Own ) then
                if( ply:GetBRCS_Locker()[key] and ply:GetBRCS_Locker()[key].Active ) then
                    return false
                end
            end
        end
    end
end )