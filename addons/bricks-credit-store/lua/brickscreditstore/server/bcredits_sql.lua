local Host = ""
local Username = ""
local Password = ""
local DatabaseName = ""
local DatabasePort = 3306

--[[

	DONT TOUCH ANYTHING BELOW THIS LINE!
	
]]--


if( (BRICKSCREDITSTORE.LUACONFIG.UseMySQL or false) == true ) then
	local MYSQL_PLAYERS = true
	
	--[[ PLAYER DATA ]]--
	if( (MYSQL_PLAYERS or false) == true ) then
		local column_names = { 
			["credits"] = "integer",	
			["locker"] = "string"	
		}

		// MYSQL CODE
		local player_meta = FindMetaTable("Player")
		require( "mysqloo" )

		local function ConnectToDatabase()
			brickscreditstore_db = mysqloo.connect( Host, Username, Password, DatabaseName, DatabasePort )
			brickscreditstore_db.onConnected = function()	print( "[Brick's Credit Store SQL] BricksCreditStore database has connected!" )	end
			brickscreditstore_db.onConnectionFailed = function( err )	print( "[Brick's Credit Store SQL] Connection to BricksCreditStore Database failed! Error: " ) PrintTable( err )	end
			brickscreditstore_db:connect()
			
			local query = brickscreditstore_db:query("CREATE TABLE IF NOT EXISTS BricksCreditStore ( steamid64 varchar(20) NOT NULL UNIQUE, credits int, locker TEXT );")
			function query:onSuccess(data)
				print( "[Brick's Credit Store SQL] BricksCreditStore table validated!" )
			end

			function query:onError(err)
				print("[Brick's Credit Store SQL] An error occured while executing the query: " .. err)
			end

			query:start()
		end

		ConnectToDatabase()

		function player_meta:BRCS_UpdateDBValue( key, value )
			local PlySteamID64 = self:SteamID64()
			if( not column_names[key] ) then return end
			
			if( column_names[key] == "string" ) then
				value = string.Replace( value, "'", "" )
			end
			
			local query = brickscreditstore_db:query("SELECT * FROM BricksCreditStore WHERE steamid64 = '" .. PlySteamID64 .. "'")
			function query:onSuccess(data)
				if( not data[1] ) then
					local queryinner = brickscreditstore_db:query("INSERT INTO BricksCreditStore (`steamid64`, `" .. key .. "`) VALUES( '" .. PlySteamID64 .. "', '" .. value .. "')")
					function queryinner:onSuccess(data)
					
					end
					function queryinner:onError(err)
						local queryinner2 = brickscreditstore_db:query("UPDATE BricksCreditStore SET " .. key .. " = '" .. value .. "' WHERE steamid64 = '" .. PlySteamID64 .. "';")
						function queryinner2:onSuccess(data)
						end
						function queryinner2:onError(err) print("[Brick's Credit Store SQL] An error occured while executing the queryinner2: " .. err) end
						queryinner2:start()
						print("[Brick's Credit Store SQL] An error occured while executing the queryinner: " .. err) 
					end
					queryinner:start()
				else
					local queryinner2 = brickscreditstore_db:query("UPDATE BricksCreditStore SET " .. key .. " = '" .. value .. "' WHERE steamid64 = '" .. PlySteamID64 .. "';")
					function queryinner2:onSuccess(data)
					end
					function queryinner2:onError(err) print("[Brick's Credit Store SQL] An error occured while executing the queryinner2: " .. err) end
					queryinner2:start()
				end
			end
			function query:onError(err)
				print("[Brick's Credit Store SQL] An error occured while executing the query: " .. err)
			end
			query:start()
			
		end

		function player_meta:BRCS_FetchDBValue( key, func )
			local PlySteamID64 = self:SteamID64()
			if( not column_names[key] ) then return end
			local query = brickscreditstore_db:query("SELECT " .. key .. " FROM BricksCreditStore WHERE steamid64 = '" .. PlySteamID64 .. "'")
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
				print("[Brick's Credit Store SQL] An error occured while executing the query: " .. err)
			end
			query:start()
		end
	end
end