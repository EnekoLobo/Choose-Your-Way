local ply_meta = FindMetaTable( "Player" )

function ply_meta:GetBRCS_Locker()
	local Locker = {}

	if( CLIENT ) then
		if( self == LocalPlayer() ) then
			if( BRCS_LOCKER ) then
				Locker = BRCS_LOCKER
			end
		elseif( self.BRCS_LOCKER ) then
			Locker = self.BRCS_LOCKER
		end
	elseif( SERVER ) then
		if( self.BRCS_LOCKER ) then
			Locker = self.BRCS_LOCKER
		end
	end

	return Locker
end

function ply_meta:GetBRCS_Active()
	local Active = {}

	if( CLIENT ) then
		if( self == LocalPlayer() ) then
			if( BRCS_LOCKER_ACTIVE ) then
				Active = BRCS_LOCKER_ACTIVE
			end
		elseif( self.BRCS_LOCKER_ACTIVE ) then
			Active = self.BRCS_LOCKER_ACTIVE
		end
	elseif( SERVER ) then
		if( self.BRCS_LOCKER_ACTIVE ) then
			Active = self.BRCS_LOCKER_ACTIVE
		end
	end

	return Active
end

local function CompareTable( table1, table2 )
	if( #table1 != #table2 ) then return false end

	for k, v in pairs( table1 ) do
		if( not table2[k] or table2[k] != v ) then
			return false
		end
	end

	return true
end

function ply_meta:GetBRCS_AlreadyOwn( NPCType, itemKey )
	local plyLocker = self:GetBRCS_Locker()

	if( #plyLocker <= 0 ) then return false end
	if( not BRICKSCREDITSTORE.CONFIG.NPCs[NPCType] or not BRICKSCREDITSTORE.CONFIG.NPCs[NPCType].Items[itemKey] ) then return false end

	local itemTable = BRICKSCREDITSTORE.CONFIG.NPCs[NPCType].Items[itemKey]
	for k, v in pairs( plyLocker ) do
		if( (BRICKSCREDITSTORE.ITEMTYPES[itemTable.Type].LockerType or "") == v[1] and CompareTable( (itemTable.TypeInfo or {}), v[2] ) ) then
			return true, k
		end
	end

	return false
end

function ply_meta:GetBRCS_CanToggle( itemKey, active )
	local plyLocker = self:GetBRCS_Locker()

	if( not plyLocker[itemKey] ) then return false end

	local lockerItem = plyLocker[itemKey]
	local typeTable = BRICKSCREDITSTORE.LOCKERTYPES[lockerItem[1] or ""] or {}

	if( active and typeTable.CantDisable ) then
		return false, "You cannot disable this item! You must remove it instead."
	end

	if( not active and typeTable.OneAtATime ) then
		for k, v in pairs( self:GetBRCS_Active() ) do
			if( plyLocker[k] and (plyLocker[k][1] or "a") == (lockerItem[1] or "b") ) then
				return false, "You can only have one of these active at a time!"
			end
		end
	end

	if( not active and typeTable.OnlyActiveKey ) then
		local AKey = typeTable.OnlyActiveKey
		for k, v in pairs( self:GetBRCS_Active() ) do
			if( plyLocker[k] and plyLocker[k][2] and lockerItem[2] and (plyLocker[k][1] or "a") == (lockerItem[1] or "b") and (plyLocker[k][2][AKey] or "a") == (lockerItem[2][AKey] or "b") ) then
				return false, "You can only have one of these active at a time!"
			end
		end
	end

	if( not active and typeTable.Conflicts ) then
		local Conflicts = typeTable.Conflicts
		for k, v in pairs( self:GetBRCS_Active() ) do
			if( plyLocker[k] and plyLocker[k][1] and Conflicts[plyLocker[k][1]] ) then
				return false, "This item conflicts with another item (e.g. having a playermodel equipped)."
			end
		end
	end

	return true
end

if( SERVER ) then
	util.AddNetworkString( "BRCS_Net_UpdateClientToggled" )
	function ply_meta:BRCS_UpdateClientActive()
		local Active = self:GetBRCS_Active() or {}
		
		net.Start( "BRCS_Net_UpdateClientToggled" )
			net.WriteTable( Active )
		net.Send( self )
	end	

	function ply_meta:BRCS_Remove( ItemKey )
		local Locker = self:GetBRCS_Locker()

		if( not Locker[ItemKey] ) then return end
		
		local Active = self:GetBRCS_Active()
		if( Locker[ItemKey].Active ) then
			Locker[ItemKey].Active = nil
			Active[ItemKey] = nil

			local LockerType = BRICKSCREDITSTORE.LOCKERTYPES[Locker[ItemKey][1] or ""] or {}
			if( LockerType.OnDisable ) then
				LockerType.OnDisable( self, ((Locker[ItemKey][2] or "") or {}) )
			end
		end
	
		Locker[ItemKey] = nil
	
		self:SetBRCS_Locker( Locker )
		self.BRCS_LOCKER_ACTIVE = Active
		self:BRCS_UpdateClientActive()
	end	

	function ply_meta:BRCS_Toggle( ItemKey, manual )
		local Locker = self:GetBRCS_Locker()
		local Active = self:GetBRCS_Active()
		if( Locker[ItemKey] ) then
			local canToggle, message = self:GetBRCS_CanToggle( ItemKey, Active[ItemKey] )

			if( not canToggle ) then
				if( manual ) then
					self:NotifyBRCS( message or "ERROR Toggling" )
				end
				return
			end

			local LockerType = BRICKSCREDITSTORE.LOCKERTYPES[Locker[ItemKey][1] or ""] or {}
	
			if( Active[ItemKey] ) then
				Locker[ItemKey].Active = nil
				Active[ItemKey] = nil
			else
				Locker[ItemKey].Active = true
				Active[ItemKey] = true
			end

			if( LockerType.TimerRunOut and LockerType.TimerKey and LockerType.TimeKey ) then
				if( Active[ItemKey] ) then
					Locker[ItemKey][2][LockerType.TimerKey] = os.time()+(Locker[ItemKey][2][LockerType.TimeKey] or 60)
				else
					Locker[ItemKey][2][LockerType.TimerKey] = nil
				end
			end
			
			if( LockerType.GroupKey ) then
				if( Active[ItemKey] ) then
					Locker[ItemKey][2][LockerType.GroupKey] = BRICKSCREDITSTORE.GetAdminGroup( self )
				else
					Locker[ItemKey][2][LockerType.GroupKey] = nil
				end
			end

			if( Active[ItemKey] and LockerType.OnUse ) then
				if( CurTime() >= (self.BRCS_UseCooldown or 0) ) then
					self.BRCS_UseCooldown = CurTime()+(LockerType.UseCooldown or 30)
					LockerType.OnUse( self, ((Locker[ItemKey][2] or "") or {}), true )
					Locker[ItemKey].Active = nil
					Active[ItemKey] = nil
				else
					self:NotifyBRCS( string.format( "You cannot use this for another %d seconds!", ((LockerType.UseCooldown or 30)-CurTime()) ) )
					return
				end
			end
	
			self:SetBRCS_Locker( Locker )
			self.BRCS_LOCKER_ACTIVE = Active
			self:BRCS_UpdateClientActive()
	
			if( not Active[ItemKey] and LockerType.OnDisable ) then
				LockerType.OnDisable( self, ((Locker[ItemKey][2] or "") or {}) )
			end
			
			if( Active[ItemKey] and LockerType.OnEnable ) then
				LockerType.OnEnable( self, ((Locker[ItemKey][2] or "") or {}) )
			end

			if( Active[ItemKey] and LockerType.OnSpawn ) then
				LockerType.OnSpawn( self, ((Locker[ItemKey][2] or "") or {}), true )
			end

			if( Active[ItemKey] and LockerType.OnInitialSpawn ) then
				LockerType.OnInitialSpawn( self, ((Locker[ItemKey][2] or "") or {}), true )
			end

			local typeInfo = Locker[ItemKey][2]
			if( LockerType.TimerRunOut and LockerType.TimerKey and typeInfo[LockerType.TimerKey] and LockerType.TimeKey and typeInfo[LockerType.TimeKey] ) then
				if( Active[ItemKey] ) then
					BRCS_TIMER_PLYS = BRCS_TIMER_PLYS or {}
					BRCS_TIMER_PLYS[self:SteamID64()] = BRCS_TIMER_PLYS[self:SteamID64()] or {}
					BRCS_TIMER_PLYS[self:SteamID64()][ItemKey] = { typeInfo, LockerType }
				elseif( BRCS_TIMER_PLYS and BRCS_TIMER_PLYS[self:SteamID64()] and BRCS_TIMER_PLYS[self:SteamID64()][ItemKey] ) then
					BRCS_TIMER_PLYS[self:SteamID64()][ItemKey] = nil
					if( #BRCS_TIMER_PLYS[self:SteamID64()] <= 0 ) then
						BRCS_TIMER_PLYS[self:SteamID64()] = nil
					end
				end
			end
		elseif( manual ) then
			self:NotifyBRCS( "This item is not in your locker!" )
		end
	end	

	BRCS_TIMER_PLYS = BRCS_TIMER_PLYS or {}
	hook.Add( "Think", "BRCSHooks_Think_TimerRunOut", function()
		if( BRCS_TIMER_PLYS and table.Count( BRCS_TIMER_PLYS ) > 0 ) then
			for k, v in pairs( BRCS_TIMER_PLYS ) do
				local ply = player.GetBySteamID64( k )
				if( IsValid( ply ) ) then
					for key, val in pairs( v ) do
						local typeInfo = val[1] or {}
						local LockerType = val[2] or {}
						if( typeInfo[LockerType.TimerKey] ) then
							if( os.time() >= typeInfo[LockerType.TimerKey] ) then
								local PlyLocker = ply:GetBRCS_Locker()
								if( PlyLocker[key] ) then
									LockerType.TimerRunOut( ply, PlyLocker[key][2], key )
									BRCS_TIMER_PLYS[k][key] = nil
									if( #BRCS_TIMER_PLYS[k] <= 0 ) then
										BRCS_TIMER_PLYS[k] = nil
									end
								else
									BRCS_TIMER_PLYS[k][key] = nil
									if( #BRCS_TIMER_PLYS[k] <= 0 ) then
										BRCS_TIMER_PLYS[k] = nil
									end
								end
							end
						else
							BRCS_TIMER_PLYS[k][key] = nil
							if( #BRCS_TIMER_PLYS[k] <= 0 ) then
								BRCS_TIMER_PLYS[k] = nil
							end
						end
					end
				else
					BRCS_TIMER_PLYS[k] = nil
				end
			end
		end
	end )

	function ply_meta:BRCS_UpdateActive()
		local Locker = self:GetBRCS_Locker() or {}
		self.BRCS_LOCKER_ACTIVE = {}

		for k, v in pairs( Locker ) do
			if( v.Active ) then
				self.BRCS_LOCKER_ACTIVE[k] = true

				local typeInfo = v[2]
				local LockerType = BRICKSCREDITSTORE.LOCKERTYPES[v[1] or ""] or {}
				if( LockerType.TimerRunOut and LockerType.TimerKey and typeInfo[LockerType.TimerKey] and LockerType.TimeKey and typeInfo[LockerType.TimeKey] ) then
					if( v.Active ) then
						BRCS_TIMER_PLYS = BRCS_TIMER_PLYS or {}
						BRCS_TIMER_PLYS[self:SteamID64()] = BRCS_TIMER_PLYS[self:SteamID64()] or {}
						BRCS_TIMER_PLYS[self:SteamID64()][k] = { typeInfo, LockerType }
					elseif( BRCS_TIMER_PLYS and BRCS_TIMER_PLYS[self:SteamID64()] and BRCS_TIMER_PLYS[self:SteamID64()][k] ) then
						BRCS_TIMER_PLYS[self:SteamID64()][k] = nil
						if( #BRCS_TIMER_PLYS[self:SteamID64()] <= 0 ) then
							BRCS_TIMER_PLYS[self:SteamID64()] = nil
						end
					end
				end
			end
		end

		self:BRCS_UpdateClientActive()
	end	

	util.AddNetworkString( "BRCS_Net_UpdateClientLocker" )
	function ply_meta:BRCS_UpdateClientLocker()
		local Locker = self:GetBRCS_Locker() or {}
		
		net.Start( "BRCS_Net_UpdateClientLocker" )
			net.WriteTable( Locker )
		net.Send( self )
	end	

	function ply_meta:SetBRCS_Locker( Locker, nosave )
		if( not Locker or not istable( Locker ) ) then return end
		self.BRCS_LOCKER = Locker
		
		self:BRCS_UpdateClientLocker()
		
		if( not nosave ) then
			self:SaveBRCS_LockerData()
		end
	end

	function ply_meta:AddBRCS_LockerItem( type, typeInfo, itemInfo )
		if( not type or not BRICKSCREDITSTORE.LOCKERTYPES[type] or not typeInfo or not itemInfo ) then 
			return false
		end

		local NewLocker = self:GetBRCS_Locker()
		local NewKey = #NewLocker+1
		NewLocker[NewKey] = { type, typeInfo, itemInfo }

		self:SetBRCS_Locker( NewLocker )
	end

	function ply_meta:RemoveBRCS_LockerItem( itemKey, message )
		local NewLocker = self:GetBRCS_Locker()

		if( not NewLocker[itemKey] ) then return false end

		NewLocker[itemKey] = nil

		self:SetBRCS_Locker( NewLocker )

		if( message ) then
			self:NotifyBRCS( message )
		end

		self:BRCS_UpdateActive()
	end
	
	function ply_meta:SaveBRCS_LockerData()
		local Locker = self:GetBRCS_Locker()
		if( Locker != nil ) then
			if( not istable( Locker ) ) then
				Locker = {}
			end
		else
			Locker = {}
		end
		
		local LockerJSON = util.TableToJSON( Locker )
		if( BRICKSCREDITSTORE.LUACONFIG.UseMySQL != true ) then
			if( not file.Exists( "brickscreditstore/locker_data", "DATA" ) ) then
				file.CreateDir( "brickscreditstore/locker_data" )
			end
			
			file.Write( "brickscreditstore/locker_data/" .. self:SteamID64() .. ".txt", LockerJSON )
		else
			self:BRCS_UpdateDBValue( "locker", LockerJSON )
		end
	end
	
	hook.Add( "PlayerInitialSpawn", "BRCSHooks_PlayerInitialSpawn_LockerDataLoad", function( ply )
		local Locker = {}
	
		if( BRICKSCREDITSTORE.LUACONFIG.UseMySQL != true ) then
			if( file.Exists( "brickscreditstore/locker_data/" .. ply:SteamID64() .. ".txt", "DATA" ) ) then
				local LockerJSON = file.Read( "brickscreditstore/locker_data/" .. ply:SteamID64() .. ".txt", "DATA" )
				LockerJSON = util.JSONToTable( LockerJSON )
				
				if( LockerJSON != nil ) then
					if( istable( LockerJSON ) ) then
						Locker = LockerJSON
					end
				end
			end
			
			ply:SetBRCS_Locker( Locker, true )
			ply:BRCS_UpdateActive()
		else
			ply:BRCS_FetchDBValue( "locker", function( value )
				if( value ) then
					local LockerJSON = util.JSONToTable( value )

					if( LockerJSON != nil ) then
						if( istable( LockerJSON ) ) then
							Locker = LockerJSON
						end
					end

					ply:SetBRCS_Locker( Locker, true )
					ply:BRCS_UpdateActive()
				end
			end )
		end
	end )
elseif( CLIENT ) then
	net.Receive( "BRCS_Net_UpdateClientLocker", function( len, ply )
		local Locker = net.ReadTable() or {}

		BRCS_LOCKER = Locker

		BRICKSCREDITSTORE.RefreshLocker()
	end )

	net.Receive( "BRCS_Net_UpdateClientToggled", function( len, ply )
		local Toggled = net.ReadTable() or {}

		BRCS_LOCKER_ACTIVE = Toggled
	end )
end
