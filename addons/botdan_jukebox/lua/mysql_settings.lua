--[[ MySQL SAVING INFORMATION ]]--
-- Requires mysqloo v9 from here:
-- https://gmod.facepunch.com/f/gmodaddon/jjdq/gmsv-mysqloo-v9-Rewritten-MySQL-Module-prepared-statements-transactions/1/
-- Follow the instructions at the bottom of the post for installation.
-- Download the correct 2 files for the server's OS and place where instructed.
-- Once MySQL is enabled, use the following console command in the server's console:
-- JukeBox_TransferSongs
-- to transfer all currently saves songs in the txt file to the MySQL table.

JukeBox.Settings.MySQL = {}

-- This dictates whether to use MySQL for the All Songs list.
-- If set to true, all the details below will need filling in.
JukeBox.Settings.MySQL.UseMySQL = false

-- Set this to true if you're using tmysql4 rather than mysqloo.
-- Note that this requires the use of this file:
-- https://github.com/FredyH/MySQLOO/blob/master/lua/tmysql4.lua
-- Follow the instructions at the top of the file.
-- THIS ISN'T FINISHED!!!
JukeBox.Settings.MySQL.tmysql4Override = false

-- The IP of the MySQL database
local Host = "localhost"

-- The username used to access the MySQL database
local Username = "user"

-- The password used with the username to access the MySQL database
local Password = "pass"

-- The port of the MySQL database
local Port = 3306

-- The name of the MySQL database
local Database = "sys"

--[[ END OF SETTINGS, DO NOT EDIT ]]--
--// BEGINNING OF MYSQL \\--
JukeBox.MySQL = {}
JukeBox.MySQL.Connection = nil
JukeBox.MySQL.Available = false
JukeBox.MySQL.Transferred = false

if not JukeBox.Settings.MySQL.UseMySQL then return end
JukeBox.MySQL.Available = true

if !JukeBox.Settings.MySQL.tmysql4Override then
	require( "mysqloo" )
	if ( mysqloo.VERSION ) then
		if ( mysqloo.VERSION != "9" ) then
			print( [[
	###################################
	- JUKEBOX
	- MYSQLOO ISSUE
	- I recommend updating to MySQLoo version 9. It can be found at:
	- https://gmod.facepunch.com/f/gmodaddon/jjdq/gmsv-mysqloo-v9-Rewritten-MySQL-Module-prepared-statements-transactions/1/
	- Different versions of mysqloo may not be compatible with the JukeBox.
	###################################
	]] )
		end
	else
			print( [[
	###################################
	- JUKEBOX
	- MYSQLOO ISSUE
	- I recommend updating to MySQLoo version 9. It can be found at:
	- https://gmod.facepunch.com/f/gmodaddon/jjdq/gmsv-mysqloo-v9-Rewritten-MySQL-Module-prepared-statements-transactions/1/
	- Different versions of mysqloo may not be compatible with the JukeBox.
	###################################
	]] )

	end
end

local db = mysqloo.connect( Host, Username, Password, Database, Port )
function db:onConnected()

    print( "[JukeBox] Connection Status....OK" )

	JukeBox.MySQL.Connection = self
	JukeBox.MySQL:CheckTable()

end
function db:onConnectionFailed( err )
    print( "[JukeBox] Connection Status....FAIL \n[JukeBox] Error: "..err )
end
print( "[JukeBox] Queueing MySQL Connection..." )

function JukeBox.MySQL:CheckTable()
	if not self.Connection then return end

	local q = self.Connection:query( "CREATE TABLE IF NOT EXISTS JukeBox_AllSongs( id varchar(11), name varchar(100), artist varchar(100), length int, starttime int, endtime int );CREATE TABLE IF NOT EXISTS JukeBox_IdleSongs( id varchar(11) );" )
	function q:onSuccess( data )
		print( "[JukeBox] Table Status.........OK" )
		JukeBox.MySQL:GetSongsData()
	end
	function q:onError( err, sql )
		print( "[JukeBox] Table Status.........FAIL \n[JukeBox] Error: "..err )
	end
	q:start()
end

db:connect()

function JukeBox.MySQL:GetSongsData()
	if not self.Connection then return end

	local q = self.Connection:query( "SELECT * FROM JukeBox_AllSongs;" )
	function q:onSuccess( data )
		print( "[JukeBox] Data Status..........OK" )
		print( "[JukeBox] Received "..#data.." results from All Songs table." )
		for k, v in pairs( data ) do
			if v.starttime == 0 then
				v.starttime = nil
			end
			if v.endtime == v.length then
				v.endtime = nil
			end
			JukeBox.SongList[v.id] = v
		end
		JukeBox:SendAllSongs()
	end
	function q:onError( err, sql )
		print( "[JukeBox] Data Status..........FAIL \n[JukeBox] Error: "..err )
	end
	q:start()

	local q = self.Connection:query( "SELECT * FROM JukeBox_IdleSongs;" )
	function q:onSuccess( data )
		print( "[JukeBox] Received "..#data.." results from Idle Songs table." )
		for k, v in pairs( data ) do
			JukeBox.IdleSongList[v.id] = true
		end
	end
	function q:onError( err, sql )
		print( "[JukeBox] Data Status..........FAIL \n[JukeBox] Error: "..err )
	end
	q:start()
end

function JukeBox.MySQL:AddSong( data )
	if not self.Connection then return end

	self:DeleteSong( data.id )

	/*
	data.id = data.id
	print( data.name )
	data.name = string.Replace( self.Connection:escape( data.name ), "\\\\", "\\" )
	print( data.name )
	data.artist = self.Connection:escape( data.artist )
	if not data.starttime then data.starttime = 0 end
	if not data.endtime then data.endtime = data.length end

	local q = self.Connection:query( "INSERT INTO JukeBox_AllSongs VALUES( '"..data.id.."', '"..data.name.."', '"..data.artist.."', "..data.length..", "..data.starttime..", "..data.endtime.." );" )
	function q:onSuccess( data )

	end
	function q:onError( err, sql )

	end
	*/
	if not data.starttime then data.starttime = 0 end
	if not data.endtime then data.endtime = data.length end

	local q = db:prepare( "INSERT INTO JukeBox_AllSongs (`id`, `name`, `artist`, `length`, `starttime`, `endtime`) VALUES (?,?,?,?,?,?);" )
	q:setString( 1, data.id )
	q:setString( 2, data.name )
	q:setString( 3, data.artist )
	q:setNumber( 4, data.length )
	q:setNumber( 5, data.starttime )
	q:setNumber( 6, data.endtime )
	function q:onSuccess( data ) end
	function q:onError( err, sql ) end
	q:start()

end

function JukeBox.MySQL:DeleteSong( id )
	if not self.Connection then return end

	id = self.Connection:escape( id )

	local q = self.Connection:query( "DELETE FROM JukeBox_AllSongs WHERE id=\""..id.."\";" )
	function q:onSuccess( data )

	end
	function q:onError( err, sql )

	end
	q:start()
end

function JukeBox.MySQL:UpdateIdleSong( id, isIdleSong )
	if not self.Connection then return end

	local q = nil
	if (isIdleSong) then
		q = db:prepare( "INSERT INTO JukeBox_IdleSongs (`id`) VALUES (?);" )
		q:setString( 1, id )
	else
		id = self.Connection:escape( id )
		q = self.Connection:query( "DELETE FROM JukeBox_IdleSongs WHERE id=\""..id.."\";" )
	end

	function q:onSuccess( data ) end
	function q:onError( err, sql ) end
	q:start()
end

function JukeBox.MySQL:TransferSongs()
	if not self.Connection then
		print( "[JukeBox] Can't transfer songs as MySQL conection isn't established." )
		return
	end

	print( "[JukeBox] Beginning song transfer." )
	if file.Read( "JukeBox_AllSongs.txt", "DATA" ) != "" then
		local TableFromJSON = util.JSONToTable( file.Read( "JukeBox_AllSongs.txt", "DATA" ) )
		for k, v in pairs( TableFromJSON ) do
			self:AddSong( v )
		end
		print( "[JukeBox] Transferred "..table.Count(TableFromJSON).." songs from text file.\n[JukeBox] Songs will be loaded next level change/restart." )
	else
		print( "[JukeBox] File is empty, transferred 0 songs." )
	end
end
concommand.Add( "JukeBox_TransferSongs", function( ply )
	if IsValid(ply) then return end
	if JukeBox.MySQL.Transferred then
		print( "[JukeBox] You have already transferred the songs list, please change level and try again." )
		return
	end
	JukeBox.MySQL:TransferSongs()
	JukeBox.MySQL.Transferred = true
end )

function JukeBox.MySQL:AddTestSong()
	if not self.Connection then return end

	local q = self.Connection:query( "INSERT INTO JukeBox_AllSongs VALUES( \"12345678911\", \"Song Name\", \"Song Artist\", 123, 0, 123 );" )
	function q:onSuccess( data )
		print( "[JukeBox] Added a Test Song..." )
	end
	function q:onError( err, sql )
		print( "[JukeBox] Error: "..err )
	end
	q:start()
end
