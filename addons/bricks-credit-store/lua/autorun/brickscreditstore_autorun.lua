if( SERVER ) then
	resource.AddWorkshop( 1928717805 )
	resource.AddFile( "resource/fonts/myriadprolight.otf")
	resource.AddFile( "resource/fonts/myriadproregular.otf")
end

BRICKSCREDITSTORE = {}

--[[ CONFIG LOADER ]]--
BRICKSCREDITSTORE.CONFIG = {}

AddCSLuaFile( "brickscreditstore_luaconfig.lua" )
include( "brickscreditstore_luaconfig.lua" )

AddCSLuaFile( "brickscreditstore_baseconfig.lua" )
include( "brickscreditstore_baseconfig.lua" )

function BRICKSCREDITSTORE.LoadConfig()
	local ConfigTable = BRICKSCREDITSTORE.BASECONFIG

	if( file.Exists( "brickscreditstore/config.txt", "DATA" ) ) then
		local FileTable = file.Read( "brickscreditstore/config.txt", "DATA" )
		FileTable = util.JSONToTable( FileTable )
		
		if( FileTable != nil ) then
			if( istable( FileTable ) ) then
				ConfigTable = FileTable
			end
		end
	end

	BRICKSCREDITSTORE.CONFIG = ConfigTable
end
BRICKSCREDITSTORE.LoadConfig()

--[[ LOADS FILES ]]--
local files, directories = file.Find( "brickscreditstore/*", "LUA" )
for k, v in pairs( files ) do
	AddCSLuaFile( "brickscreditstore/" .. v )
	include( "brickscreditstore/" .. v )
	
	print( "[BRICKSCREDITSTORE] SHARED " .. v .. " loaded" )
end

for k, v in pairs( directories ) do
	if( v == "server" ) then
		for key2, val2 in pairs( file.Find( "brickscreditstore/" .. v .. "/*.lua", "LUA" ) ) do
			if( SERVER ) then
				include( "brickscreditstore/" .. v .. "/" .. val2 )
			end
			
			print( "[BRICKSCREDITSTORE] SERVER " .. val2 .. " loaded" )
		end
	elseif( v == "client" ) then
		for key2, val2 in pairs( file.Find( "brickscreditstore/" .. v .. "/*.lua", "LUA" ) ) do
			if( CLIENT ) then
				include( "brickscreditstore/" .. v .. "/" .. val2 )
			elseif( SERVER ) then
				AddCSLuaFile( "brickscreditstore/" .. v .. "/" .. val2 )
			end
			
			print( "[BRICKSCREDITSTORE] CLIENT " .. val2 .. " loaded" )
		end
	end
end