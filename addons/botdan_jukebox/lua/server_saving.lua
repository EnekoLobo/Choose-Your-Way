--// Names of the text documents to save in \\--
			-- DON'T CHANGE THESE! --
local textAllSongs 	= "JukeBox_AllSongs.txt"
local textQueue 	= "JukeBox_CurrentQueue.txt"
local textRequests 	= "JukeBox_Requests.txt"
local textCooldowns = "JukeBox_CoolDowns.txt"
local textExtra		= "JukeBox_ExtraData.txt"
local textBans		= "JukeBox_Bans.txt"
local textIdleSongs	= "JukeBox_IdleSongs.txt"

--// Initial text document creation \\--
function JukeBox:CheckSaves()
	if not file.Exists( string.lower(textAllSongs), "DATA" ) then
		file.Write( string.lower(textAllSongs), "" )
	end
	if not file.Exists( string.lower(textQueue), "DATA" ) then
		file.Write( string.lower(textQueue), "" )
	end
	if not file.Exists( string.lower(textCooldowns), "DATA" ) then
		file.Write( string.lower(textCooldowns), "" )
	end
	if not file.Exists( string.lower(textRequests), "DATA" ) then
		file.Write( string.lower(textRequests), "" )
	end
	if not file.Exists( string.lower(textExtra), "DATA" ) then
		file.Write( string.lower(textExtra), "" )
	end
	if not file.Exists( string.lower(textBans), "DATA" ) then
		file.Write( string.lower(textBans), "" )
	end
	if not file.Exists( string.lower(textIdleSongs), "DATA" ) then
		file.Write( string.lower(textIdleSongs), "" )
	end
	if not file.Exists( "jukebox_logs", "DATA" ) then
		file.CreateDir( "jukebox_logs" )
	end
end

-- Attempts to read the content of the given filename. Also checks lowercase for linux
-- Added for backwards-compatibility with old save files. Ideally all saves should be lowercase.
local function readFile(name, path)
	local content = file.Read(name, path)
	if (not content or type(content) != "string" or content == "") then
		content = file.Read(string.lower(name), path)
	end
	return content
end

local function writeFile(name, content)
	local found = file.Exists(name, "DATA")
	if (found) then
		file.Write( name, content )
	else
		file.Write( string.lower(name), content )
	end
end

--// Gets all the saved data \\--
function JukeBox:GetSaveData()
	self:CheckSaves()

	if not JukeBox.Settings.MySQL.UseMySQL or not JukeBox.MySQL.Available then
		if readFile( textAllSongs, "DATA" ) != "" then
			local TableFromJSON = util.JSONToTable( readFile( textAllSongs, "DATA" ) )
			for k, v in pairs( TableFromJSON ) do
				JukeBox.SongList[v.id] = v
			end
		end
	end

	if readFile( textQueue, "DATA" ) != "" then
		local TableFromJSON = util.JSONToTable( readFile( textQueue, "DATA" ) )
		JukeBox.QueueList = TableFromJSON
		JukeBox:FixQueue()
		JukeBox:CheckQueue()
	end

	if readFile( textRequests, "DATA" ) != "" then
		local TableFromJSON = util.JSONToTable( readFile( textRequests, "DATA" ) )
		for k, v in pairs( TableFromJSON ) do
			table.insert( JukeBox.RequestsList, v )
		end
	end

	if readFile( textBans, "DATA" ) != "" then
		local TableFromJSON = util.JSONToTable( readFile( textBans, "DATA" ) )
		for k, v in pairs( TableFromJSON ) do
			JukeBox.BansList[v.steamid64] = v
		end
	end

	if not JukeBox.Settings.MySQL.UseMySQL or not JukeBox.MySQL.Available then
		if readFile( textIdleSongs, "DATA" ) != "" then
			local TableFromJSON = util.JSONToTable( readFile( textIdleSongs, "DATA" ) )
			JukeBox.IdleSongList = TableFromJSON
		end
	end

	if JukeBox.Settings.UseCooldowns then
		if readFile( textCooldowns, "DATA" ) != "" then
			local TableFromJSON = util.JSONToTable( readFile( textCooldowns, "DATA" ) )
			for k, v in pairs( TableFromJSON ) do
				if v+JukeBox.Settings.CooldownAmount > os.time() then
					JukeBox.CooldownsList[k] = v
				end
			end
		end
	end
end
hook.Add( "Initialize", "JukeBox_ServerStartUp", function()
	JukeBox:GetSaveData()
end )

--// Add log line \\--
function JukeBox:Log( data )
	local filename = "jukebox_logs/log_"..tostring(os.date("%Y-%m-%d")..".txt")
	local content = readFile(filename)
	data = "["..os.date("%H:%M:%S").."] "..data
	if content then
		writeFile( filename, content.."\n"..data )
	else
		writeFile( filename, data )
	end
end

--// Save all songs list \\--
function JukeBox:SaveAllSongs()
	local TableToJSON = util.TableToJSON( self.SongList )
	writeFile( textAllSongs, TableToJSON )
end

--// Save current queue \\--
function JukeBox:SaveQueue()
	local TableToJSON = util.TableToJSON( self.QueueList )
	writeFile( textQueue, TableToJSON )
end

--// Save requests \\--
function JukeBox:SaveRequests()
	local TableToJSON = util.TableToJSON( self.RequestsList )
	writeFile( textRequests, TableToJSON )
end

--// Save cooldowns \\--
function JukeBox:SaveCooldowns()
	local TableToJSON = util.TableToJSON( self.CooldownsList )
	writeFile( textCooldowns, TableToJSON )
end

--// Save idle list \\--
function JukeBox:SaveIdleList()
	local TableToJSON = util.TableToJSON( self.IdleSongList )
	writeFile( textIdleSongs, TableToJSON )
end

--// Save current song+time \\--
function JukeBox:SavePlaying()
	local info
	if self.CurPlaying then
		info = { id = self.CurPlaying, time = self.CurPlayingEnd-self.CurPlayingStart }
	else
		info = { id = false, time = false }
	end
	local TableToJSON = util.TableToJSON( info )
	writeFile( textExtra, TableToJSON )
end

--// Save player bans \\--
function JukeBox:SaveBans()
	local TableToJSON = util.TableToJSON( self.BansList )
	writeFile( textBans, TableToJSON )
end
