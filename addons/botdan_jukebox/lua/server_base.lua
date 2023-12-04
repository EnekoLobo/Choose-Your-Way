JukeBox.SongList = {}
JukeBox.QueueList = {}
JukeBox.RequestsList = {}
JukeBox.CooldownsList = {}
JukeBox.BansList = {}
JukeBox.IdleSongList = {}

JukeBox.CurPlaying = false
JukeBox.CurPlayingStart = false
JukeBox.CurPlayingEnd = false
JukeBox.CurPlayingIdleSong = false

JukeBox.TTTRoundPlaying = false

JukeBox.Volume = false

JukeBox.VoteSkips = 0
JukeBox.PlayersTunedIn = {}

JukeBox.PlayerCooldowns = {}

JukeBox.AddSongCooldowns = {}

JukeBox.VoteSkipPlayers = {}

JukeBox.PlaylistAdded = {0, 0}

util.AddNetworkString( "JukeBox_PlayNext" )
util.AddNetworkString( "JukeBox_PlayNextTime" )
util.AddNetworkString( "JukeBox_NoSong" )
util.AddNetworkString( "JukeBox_AllSongs" )
util.AddNetworkString( "JukeBox_Queue" )
util.AddNetworkString( "JukeBox_Requests" )
util.AddNetworkString( "JukeBox_QueueSong" )
util.AddNetworkString( "JukeBox_AddRequest" )
util.AddNetworkString( "JukeBox_AcceptRequest" )
util.AddNetworkString( "JukeBox_DenyRequest" )
util.AddNetworkString( "JukeBox_Popup" )
util.AddNetworkString( "JukeBox_Notification" )
util.AddNetworkString( "JukeBox_DeleteSong" )
util.AddNetworkString( "JukeBox_UpdateSong" )
util.AddNetworkString( "JukeBox_VoteSkip" )
util.AddNetworkString( "JukeBox_ForceSkip" )
util.AddNetworkString( "JukeBox_ChatMessage" )
util.AddNetworkString( "JukeBox_OpenMenu" )
util.AddNetworkString( "JukeBox_ReEnabled" )
util.AddNetworkString( "JukeBox_PlayersTunedIn" )
util.AddNetworkString( "JukeBox_DeleteQueuedSong" )
util.AddNetworkString( "JukeBox_VoteSkipChat" )
util.AddNetworkString( "JukeBox_Bans" )
util.AddNetworkString( "JukeBox_UpdateBan" )
util.AddNetworkString( "JukeBox_IdleSongUpdate" )
util.AddNetworkString( "JukeBox_AllSongs2" )
util.AddNetworkString( "JukeBox_StopMusic" )
util.AddNetworkString( "JukeBox_FasttrackRequest" )
util.AddNetworkString( "JukeBox_StartUp" )
util.AddNetworkString( "JukeBox_Volume" )
util.AddNetworkString( "JukeBox_AcceptPlaylistSong" )
util.AddNetworkString( "JukeBox_PlaylistSongState" )

--// Materials download \\--
if JukeBox.Settings.UseWorkshop then
	resource.AddWorkshop( "496484635" )
else
	resource.AddFile( "materials/jukebox/admin.png" )
	resource.AddFile( "materials/jukebox/arrow.png" )
	resource.AddFile( "materials/jukebox/close.png" )
	resource.AddFile( "materials/jukebox/cross.png" )
	resource.AddFile( "materials/jukebox/edit.png" )
	resource.AddFile( "materials/jukebox/error.png" )
	resource.AddFile( "materials/jukebox/favourite.png" )
	resource.AddFile( "materials/jukebox/home.png" )
	resource.AddFile( "materials/jukebox/list.png" )
	resource.AddFile( "materials/jukebox/loading.png" )
	resource.AddFile( "materials/jukebox/music.png" )
	resource.AddFile( "materials/jukebox/options.png" )
	resource.AddFile( "materials/jukebox/play.png" )
	resource.AddFile( "materials/jukebox/search.png" )
	resource.AddFile( "materials/jukebox/settings.png" )
	resource.AddFile( "materials/jukebox/tick.png" )
	resource.AddFile( "materials/jukebox/volume.png" )
	resource.AddFile( "materials/jukebox/warning.png" )
end

-- Add xAdmin permissions if needed
hook.Add( "Initialize", "JukeBox_xAdminSetup", function()
	if JukeBox.Settings.UsexAdminRestrictions and xAdmin then
		xAdmin.RegisterPermission("jukebox_queuesong", "Queue Songs", "JukeBox")
	end
end )

--[[ NEW TIMER FUNCTIONS ]]--
JukeBox.timer = {}
JukeBox.timer.Timers = {}
function JukeBox.timer.Create( id, len, rep, func )
	JukeBox.timer.Timers[id] = {
		start = os.time(),
		length = len,
		func = func,
	}
end

function JukeBox.timer.Destroy( id )
	JukeBox.timer.Timers[id] = nil
end

hook.Add( "Tick", "JukeBox_Timers", function()
	for k, v in pairs( JukeBox.timer.Timers ) do
		if (v.start + v.length) <= os.time() then
			JukeBox.timer.Timers[k] = nil
			v.func()
		end
	end
end )

local player_metadata = FindMetaTable( "Player" )
--[[ POINT PAYMENT FUNCTIONS ]]--
function JukeBox:CanAfford( ply, points )
	if JukeBox.Settings.UsePointshop and PS then -- Hopefully check for PointShop
		local points = points or JukeBox.Settings.PointsCost
		if JukeBox.Settings.UseULXRanks then
			for k, v in pairs( JukeBox.Settings.RankDiscount ) do
				if ply:IsUserGroup( k ) then
					points = math.Round( points * v )
					break
				end
			end
		end
		if ply:PS_HasPoints( points ) then
			return true
		else
			return false
		end
	elseif JukeBox.Settings.UsePointshop2 and ply.PS2_Wallet then
		local points = points or JukeBox.Settings.PointsCost
		if JukeBox.Settings.UseULXRanks then
			for k, v in pairs( JukeBox.Settings.RankDiscount ) do
				if ply:IsUserGroup( k ) then
					points = math.Round( points * v )
					break
				end
			end
		end
		if ply.PS2_Wallet.points >= points then
			return true
		else
			return false
		end
	elseif JukeBox.Settings.UseSHPointshop then
		local points = points or JukeBox.Settings.PointsCost
		if JukeBox.Settings.UseULXRanks then
			for k, v in pairs( JukeBox.Settings.RankDiscount ) do
				if ply:IsUserGroup( k ) then
					points = math.Round( points * v )
					break
				end
			end
		end
		if ply:SH_CanAffordStandard(points) then
			return true
		else
			return false
		end
	elseif JukeBox.Settings.UseDarkRPCash then
		local points = points or JukeBox.Settings.DarkRPCashCost
		local money = ply:getDarkRPVar( "money" )
		if JukeBox.Settings.UseULXRanks then
			for k, v in pairs( JukeBox.Settings.RankDiscount ) do
				if ply:IsUserGroup( k ) then
					points = math.Round( points * v )
					break
				end
			end
		end
		if money >= points then
			return true
		else
			return false
		end
	elseif JukeBox.Settings.UseSimpleMoney then
		local points = points or JukeBox.Settings.SimpleMoneyCost
		if JukeBox.Settings.UseULXRanks then
			for k, v in pairs( JukeBox.Settings.RankDiscount ) do
				if ply:IsUserGroup( k ) then
					points = math.Round( points * v )
					break
				end
			end
		end
		return ply:money_enough( points )

	else
		return true
	end
end

function JukeBox:TakeAmount( ply, points )
	if JukeBox.Settings.UsePointshop and PS then
		local points = points or JukeBox.Settings.PointsCost
		if JukeBox.Settings.UseULXRanks then
			for k, v in pairs( JukeBox.Settings.RankDiscount ) do
				if ply:IsUserGroup( k ) then
					points = math.Round( points * v )
					break
				end
			end
		end
		ply:PS_TakePoints( points )
	elseif JukeBox.Settings.UsePointshop2 and ply.PS2_Wallet then
		local points = points or JukeBox.Settings.PointsCost
		if JukeBox.Settings.UseULXRanks then
			for k, v in pairs( JukeBox.Settings.RankDiscount ) do
				if ply:IsUserGroup( k ) then
					points = math.Round( points * v )
					break
				end
			end
		end
		ply:PS2_AddStandardPoints( -points )
	elseif JukeBox.Settings.UseSHPointshop then
		local points = points or JukeBox.Settings.PointsCost
		if JukeBox.Settings.UseULXRanks then
			for k, v in pairs( JukeBox.Settings.RankDiscount ) do
				if ply:IsUserGroup( k ) then
					points = math.Round( points * v )
					break
				end
			end
		end
		ply:SH_AddStandardPoints(-points)
	elseif JukeBox.Settings.UseDarkRPCash then
		local points = points or JukeBox.Settings.DarkRPCashCost
		if JukeBox.Settings.UseULXRanks then
			for k, v in pairs( JukeBox.Settings.RankDiscount ) do
				if ply:IsUserGroup( k ) then
					points = math.Round( points * v )
					break
				end
			end
		end
		ply:addMoney( -points )
	elseif JukeBox.Settings.UseSimpleMoney then
		local points = points or JukeBox.Settings.SimpleMoneyCost
		if JukeBox.Settings.UseULXRanks then
			for k, v in pairs( JukeBox.Settings.RankDiscount ) do
				if ply:IsUserGroup( k ) then
					points = math.Round( points * v )
					break
				end
			end
		end
		ply:money_take( points )
	end
end

--[[ ADMIN FUNCTIONS ]]--
function JukeBox:IsManager( ply )
	local hasAdminRank = false
	if JukeBox.Settings.UseULXRanks then
		for k, v in pairs( JukeBox.Settings.ULXRanksList ) do
			if ply:IsUserGroup( v ) then
				hasAdminRank = true
			end
		end
	end
	if JukeBox.Settings.UseServerGuardRanks then
		if serverguard then
			if table.HasValue( JukeBox.Settings.ServerGuardRanksList, serverguard.player:GetRank( ply ) ) then
				hasAdminRank = true
			end
		end
	end
	if engine.ActiveGamemode() == "darkrp" then
		if table.HasValue( JukeBox.Settings.DarkRPJobRanks, ply:Team() ) then
			hasAdminRank = true
		end
	end
	return ply:IsSuperAdmin() or table.HasValue( JukeBox.Settings.SteamIDList, ply:SteamID() ) or hasAdminRank
end

--[[ GENERAL OPERATING FUNCTIONS ]]--
--// Finds values in tables \\--
function JukeBox:CheckInTable( thetable, thevalue )
	for k, v in pairs( thetable ) do
		if v.id then
			if v.id == thevalue then
				return true, k
			end
		end
	end
end

--// Added for an update to prevent compatibility issues \\--
function JukeBox:FixQueue()
	for k, v in pairs( JukeBox.QueueList ) do
		if JukeBox.SongList[v] then -- Old Format, need to convert
			song = {
				id = v,
				PlayerName = "",
				PlayerSID = "",
			}
			JukeBox.QueueList[k] = song
		end
	end
end

function JukeBox:PlayerTuneIn( ply, tunein )
	if tunein then
		table.insert( self.PlayersTunedIn, ply:SteamID() )
	else
		table.RemoveByValue( self.PlayersTunedIn, ply:SteamID() )
	end
	self:SendPlayersTunedIn( ply )
end
net.Receive( "JukeBox_PlayersTunedIn", function( len, ply ) JukeBox:PlayerTuneIn( ply, net.ReadBool() ) end )

--// JukeBox IdleSong functions \\--
function JukeBox:UpdateIdleSong( ply )
	if JukeBox:IsManager( ply ) then
		local id = net.ReadString()
		local bool = net.ReadBool()

		JukeBox.IdleSongList[id] = (bool and true or nil)
		if self:CheckForMySQL() then
			self.MySQL:UpdateIdleSong( id, (bool and true or false) )
		else
			JukeBox:SaveIdleList()
		end
		net.Start( "JukeBox_IdleSongUpdate" )
			net.WriteTable( JukeBox.IdleSongList )
		net.Broadcast()
	end
end
net.Receive( "JukeBox_IdleSongUpdate", function( len, ply ) JukeBox:UpdateIdleSong( ply ) end )

--// Idle song checking \\--
function JukeBox:IdleSong()
	if self.Settings.EnableIdlePlay then
		if JukeBox.Settings.IdlePlayDelay > 0 then
			JukeBox.timer.Create( "JukeBox_IdlePlayCountdown", JukeBox.CurPlayingIdleSong and JukeBox.Settings.IdlePlaySpacing or JukeBox.Settings.IdlePlayDelay, 1, function()
				--timer.Destroy( "JukeBox_IdlePlayCountdown" )
				JukeBox:StartIdleSong()
			end )
		else
			JukeBox:StartIdleSong()
		end
	end
end

--// Start the idle song \\--
function JukeBox:StartIdleSong()
	if self.Settings.TTTOnlyRoundEnd and self.TTTRoundPlaying then
		return
	end
	local available = {}
	if table.Count( self.IdleSongList ) < 1 then
		for k, v in pairs( self.SongList ) do
			if !self:CheckCooldown( k ) then
				available[k] = true
			end
		end
	else
		for k, v in pairs( self.IdleSongList ) do
			if v and !self:CheckCooldown( k ) and self.SongList[k] then
				available[k] = true
			end
		end
		if table.Count( available ) < 1 then
			for k, v in pairs( self.IdleSongList ) do
				if v and self.SongList[k] then
					available[k] = true
				end
			end
		end
	end
	if table.Count( available ) < 1 then
		return
	end
	local rand, id = table.Random( available )
	JukeBox.CurPlayingIdleSong = true
	net.Start( "JukeBox_PlayNext" )
		net.WriteString( id )
	net.Broadcast()
	self.CurPlaying = id
	self:TimeNext()
	self:ChatAddText( { "#CHAT_IdlePlaying", self.SongList[self.CurPlaying].artist, self.SongList[self.CurPlaying].name }, "JukeBox_ChatStartSong" )
end

--// Adds a song to the queue \\--
function JukeBox:QueueSong( id, ply )
	local song = {
		id = id,
		PlayerName = ply:Nick(),
		PlayerSID = ply:SteamID(),
	}
	table.insert( self.QueueList, song )
	self:ChatAddText( { "#CHAT_SongQueued", self.SongList[id].artist, self.SongList[id].name }, "JukeBox_ChatQueueSong" )
	self:UpdateQueue()
	hook.Run("JukeBox_SongQueued", ply, self.SongList[id])
end

--// Player cooldowns checker \\--
function JukeBox:CheckPlayerCooldown( ply )
	local id = ply:SteamID()
	if JukeBox.Settings.UsePlayerCooldowns then
		if self.PlayerCooldowns[id] then
			if self.PlayerCooldowns[id].IsBlocked then
				if self.PlayerCooldowns[id].Expires < os.time() then
					self.PlayerCooldowns[id].Expires = os.time()+self:GetPlayerCooldownTime( ply )
					self.PlayerCooldowns[id].QueuedSongs = 0
					self.PlayerCooldowns[id].IsBlocked = false
					return false
				else
					return true
				end
			else
				return false
			end
		else
			return false
		end
	else
		return false
	end
end

--// Get player cooldown times \\--
function JukeBox:GetPlayerCooldownTime( ply )
	local time = JukeBox.Settings.PlayerCooldownsTime
	if JukeBox.Settings.UseULXRanks then
		for k, v in pairs( JukeBox.Settings.PlayerCooldownsTimeList ) do
			if ply:IsUserGroup( k ) then
				time = v
			end
		end
	elseif JukeBox.Settings.UseServerGuardRanks then
		if serverguard then
			for k, v in pairs( JukeBox.Settings.PlayerCooldownsTimeList ) do
				if serverguard.player:GetRank( ply ) == k then
					time = v
				end
			end
		end
	end
	return time
end

--// Get player cooldown limit \\--
function JukeBox:GetPlayerCooldownLimit( ply )
	local limit = JukeBox.Settings.PlayerCooldownsLimit
	if JukeBox.Settings.UseULXRanks then
		for k, v in pairs( JukeBox.Settings.PlayerCooldownsLimitList ) do
			if ply:IsUserGroup( k ) then
				limit = v
			end
		end
	elseif JukeBox.Settings.UseServerGuardRanks then
		if serverguard then
			for k, v in pairs( JukeBox.Settings.PlayerCooldownsLimitList ) do
				if serverguard.player:GetRank( ply ) == k then
					limit = v
				end
			end
		end
	end
	return limit
end

--// Set player cooldown info \\--
function JukeBox:AddPlayerCooldown( ply )
	if not JukeBox.Settings.UsePlayerCooldowns then return end
	local id = ply:SteamID()
	if not self.PlayerCooldowns[id] then
		self.PlayerCooldowns[id] = {
			IsBlocked = false,
			QueuedSongs = 0,
			Expires = os.time()+self:GetPlayerCooldownTime( ply ),
		}
	end
	self.PlayerCooldowns[id].QueuedSongs = self.PlayerCooldowns[id].QueuedSongs + 1
	if (self.PlayerCooldowns[id].QueuedSongs >= self:GetPlayerCooldownLimit( ply )) then
		self.PlayerCooldowns[id].IsBlocked = true
	end
end

--// Deal with incoming queue requests \\--
function JukeBox:ReceiveQueueSong( ply )
	local id = net.ReadString()
	if JukeBox.Settings.ManagerOnlyMode and not self:IsManager( ply ) then
		self:SendNotification( ply, "#ALLSONGS_ManagerOnly", JukeBox.Colours.Issue, "JukeBox/warning.png", "ALLSONGS", true )
		return
	end
	if JukeBox.BansList[ply:SteamID64()] and JukeBox.BansList[ply:SteamID64()].queueban then
		self:SendNotification( ply, "#ALLSONGS_Banned", JukeBox.Colours.Issue, "JukeBox/warning.png", "ALLSONGS", true )
		return
	end
	if JukeBox.Settings.UseGroupRestrictions then
		if JukeBox.Settings.GroupRestrctionWhiteList then
			if not table.HasValue( JukeBox.Settings.RestrictedGroups, ply:GetUserGroup() ) then
				self:SendNotification( ply, "#ALLSONGS_GroupBanned", JukeBox.Colours.Issue, "JukeBox/warning.png", "ALLSONGS", true )
				return
			end
		else
			if table.HasValue( JukeBox.Settings.RestrictedGroups, ply:GetUserGroup() ) then
				self:SendNotification( ply, "#ALLSONGS_GroupBanned", JukeBox.Colours.Issue, "JukeBox/warning.png", "ALLSONGS", true )
				return
			end
		end
	end
	if JukeBox.Settings.UseJobRestrictions then
		if JukeBox.Settings.JobRestrictionWhitelist then
			if not table.HasValue( JukeBox.Settings.RestrictedJobs, ply:Team() ) then
				self:SendNotification( ply, "#ALLSONGS_JobBanned", JukeBox.Colours.Issue, "JukeBox/warning.png", "ALLSONGS", true )
				return
			end
		else
			if table.HasValue( JukeBox.Settings.RestrictedJobs, ply:Team() ) then
				self:SendNotification( ply, "#ALLSONGS_JobBanned", JukeBox.Colours.Issue, "JukeBox/warning.png", "ALLSONGS", true )
				return
			end
		end
	end
	if JukeBox.Settings.UsexAdminRestrictions then
		if not ply:xAdminHasPermission("jukebox_queuesong") then
			self:SendNotification( ply, "#ALLSONGS_GroupBanned", JukeBox.Colours.Issue, "JukeBox/warning.png", "ALLSONGS", true )
			return
		end
	end
	if not self.SongList[id] then return end
	if self.CurPlaying == id then
		self:SendNotification( ply, "#ALLSONGS_CurPlaying", JukeBox.Colours.Issue, "JukeBox/warning.png", "ALLSONGS", true )
		return
	elseif self:CheckInTable( self.QueueList, id ) then
		self:SendNotification( ply, "#ALLSONGS_CurQueued", JukeBox.Colours.Issue, "JukeBox/warning.png", "ALLSONGS", true )
		return
	elseif self:CheckCooldown( id ) and not table.HasValue( JukeBox.Settings.CooldownBypassers, ply:GetUserGroup() ) then
		self:SendNotification( ply, "#ALLSONGS_RecentPlay", JukeBox.Colours.Issue, "JukeBox/warning.png", "ALLSONGS", true )
		return
	elseif self:CheckPlayerCooldown( ply ) then
		self:SendNotification( ply, { "#ALLSONGS_QueueCooldown", math.Round(self.PlayerCooldowns[ply:SteamID()].Expires-os.time()) }, JukeBox.Colours.Issue, "JukeBox/warning.png", "ALLSONGS", true )
		return
	end
	if JukeBox.Settings.UsePointshop then
		if not self:CanAfford( ply ) then
			self:SendNotification( ply, { "#ALLSONGS_CantAffordPS", JukeBox.Settings.PointsCost }, JukeBox.Colours.Warning, "JukeBox/warning.png", "ALLSONGS", true )
		else
			self:QueueSong( id, ply )
			self:TakeAmount( ply )
			self:AddPlayerCooldown( ply )
			self:SendNotification( ply, { "#ALLSONGS_SongQueued", self.SongList[id].artist, self.SongList[id].name }, JukeBox.Colours.Accept, "JukeBox/tick.png", "ALLSONGS", true )
			self:CheckStatus()
		end
	elseif JukeBox.Settings.UsePointshop2 then
		if not self:CanAfford( ply ) then
			self:SendNotification( ply, { "#ALLSONGS_CantAffordPS", JukeBox.Settings.PointsCost }, JukeBox.Colours.Warning, "JukeBox/warning.png", "ALLSONGS", true )
		else
			self:QueueSong( id, ply )
			self:TakeAmount( ply )
			self:AddPlayerCooldown( ply )
			self:SendNotification( ply, { "#ALLSONGS_SongQueued", self.SongList[id].artist, self.SongList[id].name }, JukeBox.Colours.Accept, "JukeBox/tick.png", "ALLSONGS", true )
			self:CheckStatus()
		end
	elseif JukeBox.Settings.UseSHPointshop then
		if not self:CanAfford( ply ) then
			self:SendNotification( ply, { "#ALLSONGS_CantAffordPS", JukeBox.Settings.PointsCost }, JukeBox.Colours.Warning, "JukeBox/warning.png", "ALLSONGS", true )
		else
			self:QueueSong( id, ply )
			self:TakeAmount( ply )
			self:AddPlayerCooldown( ply )
			self:SendNotification( ply, { "#ALLSONGS_SongQueued", self.SongList[id].artist, self.SongList[id].name }, JukeBox.Colours.Accept, "JukeBox/tick.png", "ALLSONGS", true )
			self:CheckStatus()
		end
	elseif JukeBox.Settings.UseDarkRPCash then
		if not self:CanAfford( ply ) then
			self:SendNotification( ply, { "#ALLSONGS_CantAffordDRP", JukeBox.Settings.DarkRPCashCost }, JukeBox.Colours.Warning, "JukeBox/warning.png", "ALLSONGS", true )
		else
			self:QueueSong( id, ply )
			self:TakeAmount( ply )
			self:AddPlayerCooldown( ply )
			self:SendNotification( ply, { "#ALLSONGS_SongQueued", self.SongList[id].artist, self.SongList[id].name }, JukeBox.Colours.Accept, "JukeBox/tick.png", "ALLSONGS", true )
			self:CheckStatus()
		end
	elseif JukeBox.Settings.UseSimpleMoney then
		if not self:CanAfford( ply ) then
			self:SendNotification( ply, { "ALLSONGS_CantAffordMSC", JukeBox.Settings.DarkRPCashCost }, JukeBox.Colours.Warning, "JukeBox/warning.png", "ALLSONGS", true )
		else
			self:QueueSong( id, ply )
			self:TakeAmount( ply )
			self:AddPlayerCooldown( ply )
			self:SendNotification( ply, { "#ALLSONGS_SongQueued", self.SongList[id].artist, self.SongList[id].name }, JukeBox.Colours.Accept, "JukeBox/tick.png", "ALLSONGS", true )
			self:CheckStatus()
		end
	else
		self:QueueSong( id, ply )
		self:TakeAmount( ply )
		self:AddPlayerCooldown( ply )
		self:SendNotification( ply, { "#ALLSONGS_SongQueued", self.SongList[id].artist, self.SongList[id].name }, JukeBox.Colours.Accept, "JukeBox/tick.png", "ALLSONGS", true )
		self:CheckStatus()
	end
end
net.Receive( "JukeBox_QueueSong", function( len, ply ) JukeBox:ReceiveQueueSong( ply ) end )

--// Check if anything's playing \\--
function JukeBox:CheckStatus()
	if self.CurPlaying == false then
		if self.Settings.TTTOnlyRoundEnd then
			if not self.TTTRoundPlaying then
				self:CheckQueue()
			end
		else
			self:CheckQueue()
		end
	elseif self.CurPlayingIdleSong then
		if self.Settings.TTTOnlyRoundEnd then
			if not self.TTTRoundPlaying then
				if self.Settings.IdlePlayCutoff then
					self:ChatAddText( { "#CHAT_IdleSongStopped" }, "JukeBox_ChatStartSong" )
					self:CheckQueue()
				end
			end
		else
			if self.Settings.IdlePlayCutoff then
				self:ChatAddText( { "#CHAT_IdleSongStopped" }, "JukeBox_ChatStartSong" )
				self:CheckQueue()
			end
		end
	end
end

--// Checks the queue for the next song \\--
function JukeBox:CheckQueue()
	if self.CurPlaying then
		self:AddCooldown( self.CurPlaying )
	end
	self.CurPlaying = false
	self.CurPlayingStart = false
	self.CurPlayingEnd = false
	self.VoteSkips = 0
	self.VoteSkipPlayers = {}
	net.Start( "JukeBox_VoteSkip" )
		net.WriteString( tostring(self.VoteSkips) )
	net.Broadcast()
	JukeBox.timer.Destroy( "JukeBox_IdlePlayCountdown" )
	if self.QueueList[1] then
		if not self.SongList[self.QueueList[1].id] then
			self:RemoveTopQueue()
			self:CheckQueue()
		else
			self.CurPlayingIdleSong = false
			self:StartNextSong()
		end
	else
		self:NoSong()
	end
end

--// Sends the next song to clients \\--
function JukeBox:StartNextSong()
	net.Start( "JukeBox_PlayNext" )
		net.WriteString( self.QueueList[1].id )
	net.Broadcast()
	self.CurPlaying = self.QueueList[1].id
	self:TimeNext()
	self:RemoveTopQueue()
	self:ChatAddText( { "#CHAT_NowPlaying", self.SongList[self.CurPlaying].artist, self.SongList[self.CurPlaying].name }, "JukeBox_ChatStartSong" )
end

--// Deals with song cool-downs \\--
function JukeBox:AddCooldown( id )
	if JukeBox.Settings.UseCooldowns then
		self.CooldownsList[id] = os.time()
		self:SaveCooldowns()
	end
end

--// Checks if the song has a cooldown \\--
function JukeBox:CheckCooldown( id )
	if JukeBox.Settings.UseCooldowns then
		if self.CooldownsList[id] then
			if (self.CooldownsList[id]+JukeBox.Settings.CooldownAmount) > os.time() then
				return true
			else
				return false
			end
		else
			return false
		end
	else
		return false
	end
end

--// Counts down to the end of the song \\--
function JukeBox:TimeNext()
	self.CurPlayingStart = os.time()
	if self.SongList[self.CurPlaying].starttime and !self.SongList[self.CurPlaying].endtime then --| Only startTime
		self.CurPlayingEnd = os.time()+self.SongList[self.CurPlaying].length-self.SongList[self.CurPlaying].starttime
	elseif !self.SongList[self.CurPlaying].starttime and self.SongList[self.CurPlaying].endtime then --| Only endTime
		self.CurPlayingEnd = os.time()+self.SongList[self.CurPlaying].length-(self.SongList[self.CurPlaying].length-self.SongList[self.CurPlaying].endtime)
	elseif self.SongList[self.CurPlaying].starttime and self.SongList[self.CurPlaying].endtime then --| Both startTime and endTime
		self.CurPlayingEnd = os.time()+self.SongList[self.CurPlaying].length-self.SongList[self.CurPlaying].starttime-(self.SongList[self.CurPlaying].length-self.SongList[self.CurPlaying].endtime)
	else --| There isn't one
		self.CurPlayingEnd = os.time()+self.SongList[self.CurPlaying].length
	end
	JukeBox.timer.Create( "JukeBox_PlayingTimer", (self.CurPlayingEnd-self.CurPlayingStart)+self.Settings.LagCompensationTime, 1, function()
		self:CheckQueue()
	end)
end

function JukeBox:PlayNextWithTimes( playID )
	if not self.SongList[playID] then return end
	if self.SongList[playID].starttime and !self.SongList[playID].endtime then --| Only startTime
		self:PlayVideoFromTime( playID, self.SongList[playID].starttime )
		self.CurPlaying = playID
		self.CurPlayingStart = os.time()
		self.CurPlayingEnd = os.time()+self.SongList[playID].length-self.SongList[playID].starttime
	elseif !self.SongList[playID].starttime and self.SongList[playID].endtime then --| Only endTime
		self:PlayVideoUntilTime( playID, self.SongList[playID].endtime )
		self.CurPlaying = playID
		self.CurPlayingStart = os.time()
		self.CurPlayingEnd = os.time()+self.SongList[playID].length-self.SongList[playID].endtime
	elseif self.SongList[playID].starttime and self.SongList[playID].endtime then --| Both startTime and endTime
		self:PlayVideoWithTimes( playID, self.SongList[playID].starttime, self.SongList[playID].endtime )
		self.CurPlaying = playID
		self.CurPlayingStart = os.time()
		self.CurPlayingEnd = os.time()+self.SongList[playID].length-self.SongList[playID].starttime-self.SongList[playID].endtime
	else --| Something went wrong
		--chat.AddText( "Fuck" )
	end
end

--// Used for saving song time for server changelevel \\--
function JukeBox:GetTimeStamp()
	if not self.CurPlaying then return 0 end
	return math.floor( os.time()-self.CurPlayingStart )
end

--// Removes top value of the queue \\--
function JukeBox:RemoveTopQueue()
	table.remove( self.QueueList, 1 )
	self:UpdateQueue()
end

--// Tells clients there's no song to play \\--
function JukeBox:NoSong()
	net.Start( "JukeBox_NoSong" )
	net.Broadcast()
	self:IdleSong()
end

--// Update the all songs list \\--
function JukeBox:UpdateAllSongs()
	if not self:CheckForMySQL() then
		self:SaveAllSongs()
	end
	--[[
	net.Start( "JukeBox_AllSongs" )
		net.WriteTable( JukeBox.SongList )
	net.Broadcast()
	]]--
	self:SendAllSongs()
end

--// Update the queue for all \\--
function JukeBox:UpdateQueue()
	self:SaveQueue()
	net.Start( "JukeBox_Queue" )
		net.WriteTable( self.QueueList )
	net.Broadcast()
end

--// Update the requests for all \\--
function JukeBox:UpdateRequests()
	self:SaveRequests()
	net.Start( "JukeBox_Requests" )
		net.WriteTable( self.RequestsList )
	net.Broadcast()
end

--// BETA function to get round net message size limit \\--
function JukeBox:SendAllSongs( ply )
	--[[
	totalbytes = 0
	for id, info in pairs( self.SongList ) do
		totalbytes = totalbytes + string.byte( tostring( id ) )
		for _, value in pairs( info ) do
			totalbytes = totalbytes + string.byte( tostring( value ) )
		end
	end
	local totalsends = math.ceil( (totalbytes/65536) )
	local persend = math.floor( table.Count( self.SongList )/totalsends )

	local overalltable = {}
	local lastvalue = nil
	local firstmsg = true
	for i=0, totalsends do
		net.Start( "JukeBox_AllSongs2" )
		net.WriteBool( firstmsg )
		firstmsg = false
		local sendtable = {}
		if i==totalsends then
			for j=1, table.Count( self.SongList )-(i*persend) do
				lastvalue = table.FindNext( self.SongList, lastvalue )
				sendtable[lastvalue.id] = lastvalue
			end
			net.WriteTable( sendtable )
			net.WriteBool( true )
		else
			for j=1, persend do
				lastvalue = table.FindNext( self.SongList, lastvalue )
				sendtable[lastvalue.id] = lastvalue
			end
			net.WriteTable( sendtable )
			net.WriteBool( false )
		end
		if ply then
			net.Send( ply )
		else
			net.Broadcast()
		end
	end
	]]--
	net.Start( "JukeBox_AllSongs" )
		net.WriteBool( false )
	if ply then net.Send( ply ) else net.Broadcast() end

	for k, v in pairs( self.SongList ) do
		net.Start( "JukeBox_AllSongs2" )
		/*
		local name = self:FormatToSend( v["name"] )
		local artist = self:FormatToSend( v["artist"] )
		net.WriteString( v.id..";"..name..";"..artist..";"..v.length..";"..(v.starttime or "nil")..";"..(v.endtime or "nil") )
		*/
		local song =  util.TableToJSON( { v.id, v.name, v.artist, v.length, (v.starttime or "nil"), (v.endtime or "nil") } )
		local compressed = util.Compress(song)
		net.WriteData(compressed)
		if ply then net.Send( ply ) else net.Broadcast() end
	end

	net.Start( "JukeBox_AllSongs" )
		net.WriteBool( true )
	if ply then net.Send( ply ) else net.Broadcast() end
end
net.Receive( "JukeBox_AllSongs", function(len,ply) JukeBox:SendAllSongs(ply) end )

function JukeBox:FormatToSend( str )
	local str = tostring( str )
	str = string.Replace( str, "/", "//" )
	str = string.Replace( str, ";", "/;" )
	return str
end

--// Prevent spamming of playersTunedIn net message
local lastSendPlayesTunedIn = 0
function JukeBox:SendPlayersTunedIn( ply )
	if (lastSendPlayesTunedIn > CurTime()) then
		-- Timer already created, do nothing
		return
	end
	timer.Simple(math.max((lastSendPlayesTunedIn + 1) - CurTime(), 0), function()
		net.Start( "JukeBox_PlayersTunedIn" )
			net.WriteString( tostring( #self.PlayersTunedIn ) )
		if ( ply ) then
			net.Send( ply )
		else
			net.Broadcast()
		end
	end)
	lastSendPlayesTunedIn = CurTime() + 1
end

--// Sends all data to newly-connected players \\--
function JukeBox:SendAll( ply )
	if not ply or not IsValid( ply ) then return end
	--[[
	net.Start( "JukeBox_AllSongs" )
		net.WriteTable( JukeBox.SongList )
	net.Send( ply )
	]]--
	self:SendAllSongs( ply )
	net.Start( "JukeBox_Queue" )
		net.WriteTable( JukeBox.QueueList )
	net.Send( ply )
	net.Start( "JukeBox_Requests" )
		net.WriteTable( JukeBox.RequestsList )
	net.Send( ply )
	self:SendPlayersTunedIn( ply )
	if self.CurPlaying != false then
		local timestamp = self:GetTimeStamp()
		net.Start( "JukeBox_PlayNextTime" )
			net.WriteString( self.CurPlaying )
			net.WriteString( timestamp )
		net.Send( ply )
	else
		net.Start( "JukeBox_NoSong" )
		net.Send( ply )
	end
	net.Start( "JukeBox_Bans" )
		net.WriteBool( JukeBox.BansList[ply:SteamID64()] and JukeBox.BansList[ply:SteamID64()].requestban or false )
		net.WriteBool( JukeBox.BansList[ply:SteamID64()] and JukeBox.BansList[ply:SteamID64()].queueban or false )
		net.WriteTable( JukeBox.BansList )
	net.Send( ply )
	net.Start( "JukeBox_IdleSongUpdate" )
		net.WriteTable( JukeBox.IdleSongList )
	net.Send( ply )
	net.Start( "JukeBox_Volume" )
		net.WriteTable( { JukeBox.Volume } )
	net.Send( ply )
	net.Start( "JukeBox_StartUp" )
	net.Send( ply )
end

--// If the user re-enables the JukeBox \\--
function JukeBox:PlayReEnabled( ply )
	if self.CurPlaying != false then
		local timestamp = self:GetTimeStamp()
		net.Start( "JukeBox_PlayNextTime" )
			net.WriteString( self.CurPlaying )
			net.WriteString( timestamp )
		net.Send( ply )
	else
		net.Start( "JukeBox_NoSong" )
		net.Send( ply )
	end
end
net.Receive( "JukeBox_ReEnabled", function( len, ply ) JukeBox:PlayReEnabled( ply ) end )

--// Handles the vote skips \\--
function JukeBox:VoteSkip( ply )
	if table.HasValue( self.VoteSkipPlayers, ply:SteamID() ) then
		return
	end
	table.insert( self.VoteSkipPlayers, ply:SteamID() )
	self.VoteSkips = JukeBox.VoteSkips+1
	self:ChatAddText( { "#CHAT_VotesToSkip", self.VoteSkips, math.ceil(#self.PlayersTunedIn*JukeBox.Settings.VoteSkipPercent) }, "JukeBox_ChatVoteSkip" )
	if self.VoteSkips >= math.ceil(#self.PlayersTunedIn*JukeBox.Settings.VoteSkipPercent) then
		self.VoteSkips = 0
		self.VoteSkipPlayers = {}
		self:ChatAddText( { "#CHAT_SongSkipped" }, "JukeBox_ChatSkipSong" )
		self:CheckQueue()
	else
		net.Start( "JukeBox_VoteSkip" )
		net.WriteString( tostring(self.VoteSkips) )
		net.Broadcast()
	end
end
net.Receive( "JukeBox_VoteSkip", function( len, ply ) JukeBox:VoteSkip( ply ) end )

--// Handles the force skips \\--
function JukeBox:ForceSkip( ply )
	if not self:IsManager( ply ) then return end
	self:ChatAddText( { "#CHAT_ForceSkipped" }, "JukeBox_ChatSkipSong" )
	self.VoteSkips = 0
	self.VoteSkipPlayers = {}
	self:CheckQueue()
end
net.Receive( "JukeBox_ForceSkip", function( len, ply ) JukeBox:ForceSkip( ply ) end )

--[[ VGUI TO PLAYER FUNCTIONS ]]--
--// Create a popup on the player \\--
function JukeBox:SendPopup( ply, header, body )
	net.Start( "JukeBox_Popup" )
		net.WriteString( header )
		net.WriteString( body )
	net.Send( ply )
end

--// Creates a notification on the player \\--
function JukeBox:SendNotification( ply, text, colour, mat, id, killID )
	net.Start( "JukeBox_Notification" )
		net.WriteTable( {
			text = text,
			colour = colour,
			mat = mat,
			id = id,
			killID = killID,
			} )
	net.Send( ply )
end

--[[ QUICK MYSQL CHECKER FUNCTIONS ]]--
--// Check for MySQL stuff \\--
function JukeBox:CheckForMySQL()
	if self.Settings.MySQL then
		if self.Settings.MySQL.UseMySQL then
			if self.MySQL then
				if self.MySQL.Available then
					return true
				end
			end
		end
	end
	return false
end

--[[ REQUEST FUNCTIONS ]]--
--// Adds a song to all songs list \\--
function JukeBox:AddSongToAll( data )
	self.SongList[data.id] = data
	if self:CheckForMySQL() then
		self.MySQL:AddSong( data )
	else
		self:SaveAllSongs()
	end
	self:UpdateAllSongs()
end

--// For fasttracked requests \\--
function JukeBox:FasttrackRequest( ply )
	local request = net.ReadTable()
	if JukeBox.BansList[ply:SteamID64()] and JukeBox.BansList[ply:SteamID64()].requestban then
		self:SendNotification( ply, "#NOTIFY_BannedRequest", JukeBox.Colours.Issue, "JukeBox/warning.png", "REQUEST", true )
		return
	end
	if self:CheckInTable( self.SongList, request.id ) then
		self:SendPopup( ply, "#POPUP_Error", "#POPUP_URLInAllSongs" )
		return
	end
	if JukeBox:CanAfford( ply, JukeBox.Settings.RequestFasttrackCost ) then
		self:TakeAmount( ply, JukeBox.Settings.RequestFasttrackCost )
		self:SendNotification( ply, "#NOTIFY_AddedToAllSongs", JukeBox.Colours.Accept, "JukeBox/tick.png", "REQUEST", true )
		if self:CheckInTable( self.RequestsList, request.id ) then
			JukeBox:RemoveRequest( request.id )
		end
		self.SongList[request.id] = request
		if self:CheckForMySQL() then
			self.MySQL:AddSong( request )
		else
			self:SaveAllSongs()
		end
		self:UpdateAllSongs()
		hook.Run("JukeBox_SongRequested", ply, request, true)
	else
		self:SendNotification( ply, "#NOTIFY_CantAfford", JukeBox.Colours.Issue, "JukeBox/warning.png", "REQUEST", true )
	end
end
net.Receive( "JukeBox_FasttrackRequest", function( len, ply ) JukeBox:FasttrackRequest( ply ) end )


--// Add song cooldowns checker \\--
function JukeBox:CheckAddSongCooldown( ply )
	local id = ply:SteamID()
	if JukeBox.Settings.UseAddSongCooldowns then
		if self.AddSongCooldowns[id] then
			if self.AddSongCooldowns[id].IsBlocked then
				if self.AddSongCooldowns[id].Expires < os.time() then
					self.AddSongCooldowns[id].Expires = os.time()+self:GetAddSongCooldownTime( ply )
					self.AddSongCooldowns[id].AddedSongs = 0
					self.AddSongCooldowns[id].IsBlocked = false
					return false
				else
					return true
				end
			else
				return false
			end
		else
			return false
		end
	else
		return false
	end
end

--// Get player cooldown times \\--
function JukeBox:GetAddSongCooldownTime( ply )
	local time = JukeBox.Settings.AddSongCooldownsTime
	if JukeBox.Settings.UseULXRanks then
		for k, v in pairs( JukeBox.Settings.AddSongCooldownsTimeList ) do
			if ply:IsUserGroup( k ) then
				time = v
			end
		end
	elseif JukeBox.Settings.UseServerGuardRanks then
		if serverguard then
			for k, v in pairs( JukeBox.Settings.AddSongCooldownsTimeList ) do
				if serverguard.player:GetRank( ply ) == k then
					time = v
				end
			end
		end
	end
	return time
end

--// Get player cooldown limit \\--
function JukeBox:GetAddSongCooldownLimit( ply )
	local limit = JukeBox.Settings.AddSongCooldownsLimit
	if JukeBox.Settings.UseULXRanks then
		for k, v in pairs( JukeBox.Settings.AddSongCooldownsLimitList ) do
			if ply:IsUserGroup( k ) then
				limit = v
			end
		end
	elseif JukeBox.Settings.UseServerGuardRanks then
		if serverguard then
			for k, v in pairs( JukeBox.Settings.AddSongCooldownsLimitList ) do
				if serverguard.player:GetRank( ply ) == k then
					limit = v
				end
			end
		end
	end
	return limit
end

--// Set player cooldown info \\--
function JukeBox:AddAddSongCooldown( ply )
	if not JukeBox.Settings.UseAddSongCooldowns then return end
	local id = ply:SteamID()
	if not self.AddSongCooldowns[id] then
		self.AddSongCooldowns[id] = {
			IsBlocked = false,
			AddedSongs = 0,
			Expires = os.time()+self:GetAddSongCooldownTime( ply ),
		}
	end
	self.AddSongCooldowns[id].AddedSongs = self.AddSongCooldowns[id].AddedSongs + 1
	if (self.AddSongCooldowns[id].AddedSongs >= self:GetAddSongCooldownLimit( ply )) then
		self.AddSongCooldowns[id].IsBlocked = true
	end
end

--// Adds a request to the list \\--
function JukeBox:AddRequest( ply )
	local request = net.ReadTable()
	if JukeBox.BansList[ply:SteamID64()] and JukeBox.BansList[ply:SteamID64()].requestban then
		self:SendNotification( ply, "#NOTIFY_BannedRequest", JukeBox.Colours.Issue, "JukeBox/warning.png", "REQUEST", true )
		return
	end
	if self:CheckInTable( self.RequestsList, request.id ) then
		self:SendPopup( ply, "#POPUP_Error", "#POPUP_URLInRequests" )
		return
	end
	if self:CheckInTable( self.SongList, request.id ) then
		self:SendPopup( ply, "#POPUP_Error", "#POPUP_URLInAllSongs" )
		return
	end
	if self:CheckAddSongCooldown( ply ) then
		self:SendPopup( ply, "#POPUP_Error", "#POPUP_AddSongCooldown" )
		return
	end
	if JukeBox.Settings.UseAddSongGroupRestrictions then
		if JukeBox.Settings.AddSongGroupRestrctionWhiteList then
			if not table.HasValue( JukeBox.Settings.AddSongRestrictedGroups, ply:GetUserGroup() ) then
				self:SendPopup( ply, "#POPUP_Error", "#POPUP_AddSongGroupBan" )
				return
			end
		else
			if table.HasValue( JukeBox.Settings.AddSongRestrictedGroups, ply:GetUserGroup() ) then
				self:SendPopup( ply, "#POPUP_Error", "#POPUP_AddSongGroupBan" )
				return
			end
		end
	end
	if JukeBox.Settings.AutoAcceptRequests then
		self:AddSongToAll( request )
		self:SendNotification( ply, "#NOTIFY_AddedToAllSongs", JukeBox.Colours.Accept, "JukeBox/tick.png", "REQUEST", true )
		self:AddAddSongCooldown( ply )
		hook.Run("JukeBox_SongRequested", ply, request, true)
	else
		request.PlayerName = ply:Nick()
		request.PlayerSID = ply:SteamID()
		table.insert( self.RequestsList, request )
		self:ChatAddText( { "#CHAT_NewRequest" }, "JukeBox_ChatAdminRequest" )
		self:UpdateRequests()
		self:SaveRequests()
		self:AddAddSongCooldown( ply )
		hook.Run("JukeBox_SongRequested", ply, request, false)
	end
end
net.Receive( "JukeBox_AddRequest", function( len, ply ) JukeBox:AddRequest( ply ) end )

--// Updates song info \\--
function JukeBox:UpdateSong( ply )
	local song = net.ReadTable()
	if not self:IsManager( ply ) then return end
	JukeBox.SongList[song.id] = song
	if self:CheckForMySQL() then
		self.MySQL:AddSong( song )
	else
		self:SaveAllSongs()
	end
	self:UpdateAllSongs()
end
net.Receive( "JukeBox_UpdateSong", function( len, ply ) JukeBox:UpdateSong( ply ) end )

--// Deletes a song \\--
function JukeBox:DeleteSong( ply )
	local song = net.ReadString()
	if not self:IsManager( ply ) then return end

	if self:CheckInTable( self.QueueList, song ) then
		table.RemoveByValue( self.QueueList, song )
		self:UpdateAllSongs()
		self:UpdateQueue()
	end
	if self.CurPlaying == song then
		if self.Settings.TTTOnlyRoundEnd then
			if not self.TTTRoundPlaying then
				self:ChatAddText( { "#CHAT_SkipDeleted" }, "JukeBox_ChatSkipSong" )
				self:CheckQueue()
			end
		else
			self:ChatAddText( { "#CHAT_SkipDeleted" }, "JukeBox_ChatSkipSong" )
			self:CheckQueue()
		end
	end
	JukeBox.SongList[song] = nil
	if self:CheckForMySQL() then
		self.MySQL:DeleteSong( song )
	else
		self:SaveAllSongs()
	end
	self:UpdateAllSongs()
end
net.Receive( "JukeBox_DeleteSong", function( len, ply ) JukeBox:DeleteSong( ply ) end )

--// Deletes a queued song \\--
function JukeBox:DeleteQueuedSong( ply )
	local song = net.ReadString()
	if not self:IsManager( ply ) then return end
	local _, pos = self:CheckInTable( self.QueueList, song )
	table.remove( self.QueueList, pos )
	self:SendNotification( ply, "#NOTIFY_SongRemoved", JukeBox.Colours.Accept, "JukeBox/tick.png", "QUEUEREMOVE", true )
	self:UpdateQueue()
	self:SaveQueue()
end
net.Receive( "JukeBox_DeleteQueuedSong", function( len, ply ) JukeBox:DeleteQueuedSong( ply ) end )

--// Adds a request to the all songs list \\--
function JukeBox:AcceptRequest( ply )
	local request = net.ReadTable()
	if not self:IsManager( ply ) then return end
	if self:CheckInTable( self.SongList, request.id ) then
		self:SendPopup( ply, "#POPUP_Error", "#POPUP_URLInAllSongsRem" )
		return
	end
	self:SendNotification( ply, "#NOTIFY_AddedToAllSongs", JukeBox.Colours.Accept, "JukeBox/tick.png", "ADMINREQUEST", true )
	self:AddSongToAll( request )
	self:RemoveRequest( request.id )
	self:Log( "[REQUEST] "..ply:Nick().." ("..ply:SteamID()..") accepted "..request.artist.." - "..request.name.." (id: "..request.id..").\n" )
end
net.Receive( "JukeBox_AcceptRequest", function( len, ply ) JukeBox:AcceptRequest( ply ) end )

--// Redies everything for playlist spam \\--
function JukeBox:PlaylistAddState( ply )
	local start = net.ReadBool()
	if not self:IsManager( ply ) then return end
	if start then
		JukeBox.PlaylistAdded = {0, 0}
	else
		self:SendNotification( ply, { "#PLAYLIST_SongsAdded", JukeBox.PlaylistAdded[1], JukeBox.PlaylistAdded[2] }, JukeBox.Colours.Accept, "JukeBox/tick.png", "ADMINPLAYLIST", true )
		self:SendAllSongs()
	end
end
net.Receive( "JukeBox_PlaylistSongState", function( len, ply ) JukeBox:PlaylistAddState( ply ) end )

--// Adds a request to the all songs list \\--
function JukeBox:AcceptPlaylistSong( ply )
	local request = net.ReadTable()
	if not self:IsManager( ply ) then return end
	if self:CheckInTable( self.SongList, request.id ) then
		JukeBox.PlaylistAdded[2] = JukeBox.PlaylistAdded[2] + 1
		return
	end
	-- Add the song without triggering a send state
	self.SongList[request.id] = request
	if self:CheckForMySQL() then
		self.MySQL:AddSong( request )
	else
		self:SaveAllSongs()
	end
	JukeBox.PlaylistAdded[1] = JukeBox.PlaylistAdded[1] + 1
end
net.Receive( "JukeBox_AcceptPlaylistSong", function( len, ply ) JukeBox:AcceptPlaylistSong( ply ) end )

--// Removes request from list \\--
function JukeBox:RemoveRequest( id )
	for k, v in pairs( JukeBox.RequestsList ) do
		if v.id then
			if v.id == id then
				table.remove( JukeBox.RequestsList, k )
				self:SaveRequests()
				self:UpdateRequests()
			end
		end
	end
end
net.Receive( "JukeBox_DenyRequest", function( len, ply )
	local id = net.ReadString()
	if not JukeBox:IsManager( ply ) then return end
	JukeBox:RemoveRequest( id )
end )

--// Chat add text client function \\--
function JukeBox:ChatAddText( text, code )
	net.Start( "JukeBox_ChatMessage" )
		net.WriteTable( text )
		net.WriteString( code )
	net.Broadcast()
end

--[[ BAN FUNCTIONS ]]--
--// Updates bans \\--
function JukeBox:UpdateBan( ply )
	if not self:IsManager( ply ) then return end
	local data = net.ReadTable()
	if not data.requestban and not data.queueban then -- Player is fully unbanned
		JukeBox.BansList[data.steamid64] = nil
	else
		data.bannername = ply:Nick()
		data.bannersid = ply:SteamID64()
		JukeBox.BansList[data.steamid64] = data
	end
	JukeBox:SaveBans()
	JukeBox:SendBans()
end
net.Receive( "JukeBox_UpdateBan", function( len, ply ) JukeBox:UpdateBan( ply ) end )

--// Sends Bans \\--
function JukeBox:SendBans()
	for k, v in pairs( player.GetAll() ) do
		net.Start( "JukeBox_Bans" )
			net.WriteBool( JukeBox.BansList[v:SteamID64()] and JukeBox.BansList[v:SteamID64()].requestban or false )
			net.WriteBool( JukeBox.BansList[v:SteamID64()] and JukeBox.BansList[v:SteamID64()].queueban or false )
			net.WriteTable( JukeBox.BansList )
		net.Send( v )
	end
end

--// Sets Client Volume \\--
function JukeBox:SetClientVolume( amount )
	JukeBox.Volume = amount
	net.Start( "JukeBox_Volume" )
		net.WriteTable( { amount } )
	net.Broadcast()
end

--[[ PRINT FUNCTION FOR DEBUG ]]--
function JukeBox:Print( text, override )
	if override then
		MsgC( Color(211, 84, 0), "\nJukeBox ", Color( 160, 230, 230 ), "[SERVER]", Color(243, 156, 18), " - "..text )
	elseif self.DevMode then
		MsgC( Color(211, 84, 0), "\nJukeBox ", Color( 160, 230, 230 ), "[SERVER]", Color(41, 128, 185), "[DEV]", Color(243, 156, 18), " - "..text )
	end
end

--// Chat command \\--
hook.Add( "PlayerSay", "JukeBox.VGUI.ChatHook", function( ply, message )
	if table.HasValue( JukeBox.Settings.ChatCommands, message ) then
		net.Start( "JukeBox_OpenMenu" )
		net.Send( ply )
		return false
	elseif table.HasValue( JukeBox.Settings.SkipCommands, message ) then
		net.Start( "JukeBox_VoteSkipChat" )
		net.Send( ply )
		return false
	elseif table.HasValue( JukeBox.Settings.StopCommand, message ) then
		net.Start( "JukeBox_StopMusic" )
		net.Send( ply )
	end
end )

hook.Add( "PlayerInitialSpawn", "JukeBox_ReceiveWant", function( ply )
	timer.Simple( 1, function()
		JukeBox:SendAll( ply )
	end)
end )

hook.Add( "PlayerDisconnected", "JukeBox_TunedInUpdate", function( ply )
	if table.HasValue( JukeBox.PlayersTunedIn, ply:SteamID() ) then
		table.RemoveByValue( JukeBox.PlayersTunedIn, ply:SteamID() )
		JukeBox:SendPlayersTunedIn()
	end
end)

--// TTT Play while end-round \\--
function JukeBox:TTTStopSong()
	timer.Remove( "JukeBox_PlayingTimer" ) -- This should sort of hibernate the JukeBox
	JukeBox:NoSong()
	JukeBox.CurPlayingIdleSong = false
end
hook.Add( "TTTEndRound", "JukeBox_TTTEndRound", function()
	if JukeBox.Settings.TTTOnlyRoundEnd then
		-- Start the next song in the queue.
		JukeBox.TTTRoundPlaying = false
		JukeBox:CheckQueue()
	elseif JukeBox.Settings.TTTNotRoundEnd then
		-- Stop the current song.
		JukeBox:SetClientVolume( 0 )
	end
end )
hook.Add( "TTTPrepareRound", "JukeBox_TTTPrepareRound", function()
	if JukeBox.Settings.TTTOnlyRoundEnd then
		-- Stop the current song.
		JukeBox.TTTRoundPlaying = true
		JukeBox:TTTStopSong()
	elseif JukeBox.Settings.TTTNotRoundEnd then
		-- Start the next song in the queue.
		JukeBox:SetClientVolume( false )
	end
end )


hook.Add("JukeBox_SongQueued", "testing", function(ply, song)
	print(ply:Nick() .. " queued " .. song.artist .. " - " .. song.name)
end)

hook.Add("JukeBox_SongRequested", "testing", function(ply, song, accepted)
	print(ply:Nick() .. " requested " .. song.artist .. " - " .. song.name .. " (accepted: " .. tostring(accepted) ..")")
end)