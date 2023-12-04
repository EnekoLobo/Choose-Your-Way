local ply_meta = FindMetaTable( "Player" )

function ply_meta:GetBRCS_Credits()
	local Credits = 0

	if( CLIENT ) then
		if( self == LocalPlayer() ) then
			if( BRCS_CREDITS ) then
				Credits = BRCS_CREDITS
			end
		elseif( self.BRCS_CREDITS ) then
			Credits = self.BRCS_CREDITS
		end
	elseif( SERVER ) then
		if( self.BRCS_CREDITS ) then
			Credits = self.BRCS_CREDITS
		end
	end

	return Credits
end

if( SERVER ) then
	util.AddNetworkString( "BRCS_Net_UpdateClient" )
	function ply_meta:BRCS_UpdateClient()
		local Credits = self:GetBRCS_Credits() or 0
		
		net.Start( "BRCS_Net_UpdateClient" )
			net.WriteInt( Credits, 32 )
		net.Send( self )
	end	

	function ply_meta:SetBRCS_Credits( Credits, nosave )
		if( not Credits ) then return end
		self.BRCS_CREDITS = math.max( Credits, 0 )
		
		self:BRCS_UpdateClient()
		
		if( not nosave ) then
			self:SaveBRCS_Data()
		end
	end

	function ply_meta:AddBRCS_Credits( Credits )
		if( not Credits ) then return end

		local NewCredits = self:GetBRCS_Credits()+Credits
		self:SetBRCS_Credits( NewCredits )	
	end

	function ply_meta:RemoveBRCS_Credits( Credits )
		if( not Credits ) then return end

		local NewCredits = math.max( 0, self:GetBRCS_Credits()-Credits )
		self:SetBRCS_Credits( NewCredits )	
	end
	
	function ply_meta:SaveBRCS_Data()
		local Credits = self:GetBRCS_Credits()
		if( Credits != nil ) then
			if( not isnumber( Credits ) ) then
				Credits = 0
			end
		else
			Credits = 0
		end
		
		if( BRICKSCREDITSTORE.LUACONFIG.UseMySQL != true ) then
			if( not file.Exists( "brickscreditstore/credit_data", "DATA" ) ) then
				file.CreateDir( "brickscreditstore/credit_data" )
			end
			
			file.Write( "brickscreditstore/credit_data/" .. self:SteamID64() .. ".txt", Credits )
		else
			self:BRCS_UpdateDBValue( "credits", Credits )
		end
	end
	
	hook.Add( "PlayerInitialSpawn", "BRCSHooks_PlayerInitialSpawn_DataLoad", function( ply )
		local Credits = 0
	
		if( BRICKSCREDITSTORE.LUACONFIG.UseMySQL != true ) then
			if( file.Exists( "brickscreditstore/credit_data/" .. ply:SteamID64() .. ".txt", "DATA" ) ) then
				local CreditsString = file.Read( "brickscreditstore/credit_data/" .. ply:SteamID64() .. ".txt", "DATA" )
				CreditsString = tonumber( CreditsString )
				
				if( CreditsString != nil ) then
					if( isnumber( CreditsString ) ) then
						Credits = CreditsString
					end
				end
			end
			
			ply:SetBRCS_Credits( Credits, true )
		else
			ply:BRCS_FetchDBValue( "credits", function( value )
				if( value ) then
					local CreditsString = tonumber( value )

					if( CreditsString != nil ) then
						if( isnumber( CreditsString ) ) then
							Credits = CreditsString
						end
					end

					ply:SetBRCS_Credits( Credits, true )
				end
			end )
		end
    end )
elseif( CLIENT ) then
	net.Receive( "BRCS_Net_UpdateClient", function( len, ply )
		local Credits = net.ReadInt( 32 ) or 0

		BRCS_CREDITS = Credits
	end )
end
