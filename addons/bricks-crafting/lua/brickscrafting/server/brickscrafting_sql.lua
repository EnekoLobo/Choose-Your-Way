local Host = "178.32.51.125"
local Username = "salvajes_CYWADMI"
local Password = "%WUdS){.[JuP"
local DatabaseName = "salvajes_cywtienda"
local DatabasePort = 3306

--[[

	DONT TOUCH ANYTHING BELOW THIS LINE!
	
]]--


if( (BRICKSCRAFTING.LUACONFIG.UseMySQL or false) == true ) then
	local MYSQL_PLAYERS = true
	
	--[[ PLAYER DATA ]]--
	if( (MYSQL_PLAYERS or false) == true ) then
		local column_names = { 
			["inventory"] = "string",	
			["skills"] = "string",
			["misc"] = "string",
		}

		// MYSQL CODE
		local player_meta = FindMetaTable("Player")
		require( "mysqloo" )

		local function ConnectToDatabase()
			brickscrafting_db = mysqloo.connect( Host, Username, Password, DatabaseName, DatabasePort )
			brickscrafting_db.onConnected = function()	print( "[Brick's Crafting SQL] BricksCrafting database has connected!" )	end
			brickscrafting_db.onConnectionFailed = function( err )	print( "[Brick's Crafting SQL] Connection to BricksCrafting Database failed! Error: " ) PrintTable( err )	end
			brickscrafting_db:connect()
			
			local query = brickscrafting_db:query("CREATE TABLE IF NOT EXISTS BricksCrafting ( steamid64 varchar(20) NOT NULL UNIQUE, inventory TEXT, skills TEXT, misc TEXT );")
			function query:onSuccess(data)
				print( "[Brick's Crafting SQL] BricksCrafting table validated!" )
			end

			function query:onError(err)
				print("[Brick's Crafting SQL] An error occured while executing the query: " .. err)
			end

			query:start()
		end

		ConnectToDatabase()

		function player_meta:BCS_UpdateDBValue( key, value )
			local PlySteamID64 = self:SteamID64()
			if( not column_names[key] ) then return end
			
			if( column_names[key] == "string" ) then
				value = string.Replace( value, "'", "" )
			end
			
			local query = brickscrafting_db:query( string.format( "SELECT * FROM BricksCrafting WHERE steamid64 = '%s'", brickscrafting_db:escape( PlySteamID64 ) ) )
			function query:onSuccess(data)
				if( not data[1] ) then
					local queryinner = brickscrafting_db:query( string.format( "INSERT INTO BricksCrafting (`steamid64`, `%s`) VALUES( '%s', '%s')", key, brickscrafting_db:escape( PlySteamID64 ), brickscrafting_db:escape( value ) ) )
					function queryinner:onSuccess(data)
					
					end
					function queryinner:onError(err)
						local queryinner2 = brickscrafting_db:query( string.format( "UPDATE BricksCrafting SET %s = '%s' WHERE steamid64 = '%s';", key, brickscrafting_db:escape( value ), brickscrafting_db:escape( PlySteamID64 ) ) )
						function queryinner2:onSuccess(data)
						end
						function queryinner2:onError(err) print("[Brick's Crafting SQL] An error occured while executing the queryinner2: " .. err) end
						queryinner2:start()
						print("[Brick's Crafting SQL] An error occured while executing the queryinner: " .. err) 
					end
					queryinner:start()
				else
					local queryinner2 = brickscrafting_db:query( string.format( "UPDATE BricksCrafting SET %s = '%s' WHERE steamid64 = '%s';", key, brickscrafting_db:escape( value ), brickscrafting_db:escape( PlySteamID64 ) ) )
					function queryinner2:onSuccess(data)
					end
					function queryinner2:onError(err) print("[Brick's Crafting SQL] An error occured while executing the queryinner2: " .. err) end
					queryinner2:start()
				end
			end
			function query:onError(err)
				print("[Brick's Crafting SQL] An error occured while executing the query: " .. err)
			end
			query:start()
			
		end

		function player_meta:BCS_FetchDBValue( key, func )
			local PlySteamID64 = self:SteamID64()
			if( not column_names[key] ) then return end
			local query = brickscrafting_db:query( string.format( "SELECT %s FROM BricksCrafting WHERE steamid64 = '%s'", key, brickscrafting_db:escape( PlySteamID64 ) ) )
			function query:onSuccess(data)
				if( data[1] ) then
					if( data[1][key] ) then
						if( column_names[key] == "integer" ) then
							func( tonumber(data[1][key]) )
						else
							func( data[1][key] )
						end
					else
						func()
					end
				else
					func()
				end
			end
			function query:onError(err)
				print("[Brick's Crafting SQL] An error occured while executing the query: " .. err)
			end
			query:start()
		end
	end
end