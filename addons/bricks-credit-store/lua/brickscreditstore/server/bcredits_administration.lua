function BRICKSCREDITSTORE.AddToGroup( ply, group )
	if( BRICKSCREDITSTORE.LUACONFIG.AdminSystem == "Serverguard" ) then
		RunConsoleCommand( "serverguard_setrank", ply:SteamID(), group )
	elseif( BRICKSCREDITSTORE.LUACONFIG.AdminSystem == "xAdmin" ) then
		RunConsoleCommand( "setgroup", ply:SteamID(), group )
	elseif( BRICKSCREDITSTORE.LUACONFIG.AdminSystem == "SAM" ) then
		RunConsoleCommand( "sam", "setrank", ply:SteamID(), group )
	elseif( BRICKSCREDITSTORE.LUACONFIG.AdminSystem == "ULX" ) then
		ulx.adduser( Entity( 0 ), ply, group )
	end
end

-- Entity saving --
concommand.Add( "brcs_savenpcpositions", function( ply, cmd, args )
	if( BRICKSCREDITSTORE.HasAdminAccess( ply ) ) then
		local Entities = {}
		for key, ent in pairs( ents.FindByClass( "brickscreditstore_npc" ) ) do
			if( not BRICKSCREDITSTORE.CONFIG.NPCs[ent:Getnpc_type() or ""] ) then continue end

			local EntVector = string.Explode(" ", tostring(ent:GetPos()))
			local EntAngles = string.Explode(" ", tostring(ent:GetAngles()))
			
			local EntTable = {
				Class = ent:Getnpc_type(),
				Position = ""..(EntVector[1])..";"..(EntVector[2])..";"..(EntVector[3])..";"..(EntAngles[1])..";"..(EntAngles[2])..";"..(EntAngles[3])..""
			}
			
			table.insert( Entities, EntTable )
		end
		
		file.Write("brickscreditstore/saved_ents/".. string.lower(game.GetMap()) ..".txt", util.TableToJSON( Entities ), "DATA")
		ply:NotifyBRCS( "Entity positions updated." )
	else
		ply:NotifyBRCS( "You don't have permission to use this command." )
	end
end )

concommand.Add( "brcs_clearnpcpositions", function( ply, cmd, args )
	if( BRICKSCREDITSTORE.HasAdminAccess( ply ) ) then
		for k, v in pairs( ents.FindByClass( "brickscreditstore_npc" ) ) do
			v:Remove()
		end

		if( file.Exists( "brickscreditstore/saved_ents/".. string.lower(game.GetMap()) ..".txt", "DATA" ) ) then
			file.Delete( "brickscreditstore/saved_ents/".. string.lower(game.GetMap()) ..".txt" )
		end
	else
		ply:NotifyBRCS( "You don't have permission to use this command." )
	end
end )

local function SpawnEntities()
	if not file.IsDir("brickscreditstore/saved_ents", "DATA") then
		file.CreateDir("brickscreditstore/saved_ents", "DATA")
	end
	
	local Entities = {}
	if( file.Exists( "brickscreditstore/saved_ents/".. string.lower(game.GetMap()) ..".txt", "DATA" ) ) then
		Entities = ( util.JSONToTable( file.Read( "brickscreditstore/saved_ents/".. string.lower(game.GetMap()) ..".txt", "DATA" ) ) )
	end
	
	if( table.Count( Entities ) > 0 ) then
		for k, v in pairs( Entities ) do
			if( BRICKSCREDITSTORE.CONFIG.NPCs[v.Class] ) then
				local ThePosition = string.Explode( ";", v.Position )
				
				local TheVector = Vector(ThePosition[1], ThePosition[2], ThePosition[3])
				local TheAngle = Angle(tonumber(ThePosition[4]), ThePosition[5], ThePosition[6])
				local NewEnt = ents.Create( "brickscreditstore_npc" )
				NewEnt:SetPos(TheVector)
				NewEnt:SetPos( TheVector )
				NewEnt:SetAngles(TheAngle)
				NewEnt:Spawn()
				NewEnt:SetNPCType( v.Class )
			else
				Entities[k] = nil
			end
		end

		file.Write("brickscreditstore/saved_ents/".. string.lower(game.GetMap()) ..".txt", util.TableToJSON( Entities ), "DATA")
		
		print( "[Brick's Credit Store] " .. table.Count( Entities ) .. " saved Entities were spawned." )
	else
		print( "[Brick's Credit Store] No saved Entities were spawned." )
	end
end
hook.Add( "InitPostEntity", "BRCSHooks_InitPostEntity_LoadEntities", SpawnEntities )
hook.Add( "PostCleanupMap", "BRCSHooks_PostCleanupMap_LoadEntities", SpawnEntities )

util.AddNetworkString( "BRCS_Net_OpenAdmin" )
hook.Add( "PlayerSay", "BRCSHooks_PlayerSay_Administration", function( ply, text, bteam )
	local text = string.lower( text )
	
	if( string.StartWith( text, "/brickscreditstore" ) or string.StartWith( text, "!brickscreditstore" ) ) then
		if( BRICKSCREDITSTORE.HasAdminAccess( ply ) ) then
			net.Start( "BRCS_Net_OpenAdmin" )
			net.Send( ply )
		else
			ply:NotifyBRCS( "You must be an admin to use this command!" )
			return ""
		end
	end
end )

--[[ CONFIG ]]--
function BRICKSCREDITSTORE.SaveConfig()
	local Config = BRICKSCREDITSTORE.CONFIG
	if( Config != nil ) then
		if( not istable( Config ) ) then
			BRICKSCREDITSTORE.LoadConfig()
			return
		end
	else
		BRICKSCREDITSTORE.LoadConfig()
		return
	end
	
	local ConfigJSON = util.TableToJSON( Config )

	if( not file.Exists( "brickscreditstore", "DATA" ) ) then
		file.CreateDir( "brickscreditstore" )
	end
	
	file.Write( "brickscreditstore/config.txt", ConfigJSON )
end

util.AddNetworkString( "BRCS_Net_SendConfig" )
function BRICKSCREDITSTORE.SendConfig( ply )
	local compressedConfig = util.Compress( util.TableToJSON( BRICKSCREDITSTORE.CONFIG ) )
	net.Start( "BRCS_Net_SendConfig" )
		net.WriteData( compressedConfig, string.len( compressedConfig ) )
	net.Send( ply )
end

hook.Add( "PlayerInitialSpawn", "BRCSHooks_PlayerInitialSpawn_ConfigSend", function( ply )
	if( IsValid( ply ) ) then
		BRICKSCREDITSTORE.SendConfig( ply )
	end
end )

util.AddNetworkString( "BRCS_Net_UpdateConfig" )
net.Receive( "BRCS_Net_UpdateConfig", function( len, ply )
	if( not BRICKSCREDITSTORE.HasAdminAccess( ply ) ) then return end

	local compressedConfig = net.ReadData( len )

	if( not compressedConfig ) then return end

	local unCompressedConfig = util.Decompress( compressedConfig )

	if( not unCompressedConfig ) then return end

	local newConfigTable = util.JSONToTable( unCompressedConfig )

	if( not newConfigTable ) then return end

	if( istable( newConfigTable ) ) then 
		BRICKSCREDITSTORE.CONFIG = newConfigTable

		local compressedConfig = util.Compress( util.TableToJSON( BRICKSCREDITSTORE.CONFIG ) )
		net.Start( "BRCS_Net_SendConfig" )
			net.WriteData( compressedConfig, string.len( compressedConfig ) )
		net.Broadcast()

		BRICKSCREDITSTORE.SaveConfig()

		ply:NotifyBRCS( "Config saved!" )
	end
end )

util.AddNetworkString( "BRCS_Net_CloseAdminMenu" )
net.Receive( "BRCS_Net_CloseAdminMenu", function( len, ply )
	if( not BRICKSCREDITSTORE.HasAdminAccess( ply ) ) then return end

	BRICKSCREDITSTORE.SendConfig( ply )
end )