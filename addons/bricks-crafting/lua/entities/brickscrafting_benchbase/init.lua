AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	if( BRICKSCRAFTING.CONFIG.Crafting[self.BenchType] ) then
		self:SetModel( BRICKSCRAFTING.CONFIG.Crafting[self.BenchType].model )
	else
		self:SetModel( "models/props_wasteland/cafeteria_table001a.mdl" )
	end
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end

	self:SetUseCooldown( 0 )
	self.BenchHealth = BRICKSCRAFTING.LUACONFIG.BenchHealth or 100
end

util.AddNetworkString( "BCS_Net_UseBench" )
function ENT:Use( ply )
	if( IsValid( ply ) and ply:GetEyeTrace().Entity == self ) then
		if( self:GetUseCooldown() > CurTime() ) then return end

		self:SetUseCooldown( CurTime()+1 )

		if( BRICKSCRAFTING.CONFIG.Crafting[self.BenchType] ) then
			net.Start( "BCS_Net_UseBench" )
				net.WriteString( self.BenchType )
			net.Send( ply )
		end
	end
end

function ENT:Think()
	self:NextThink( CurTime() )
	return true
end

function ENT:OnTakeDamage( dmgInfo )
	if( BRICKSCRAFTING.LUACONFIG.BenchHealth <= 0 ) then return end

	self:SetHealth( math.Clamp( self:Health()-dmgInfo:GetDamage(), 0, self.BenchHealth ) )
	if( self:Health() <= 0 ) then
		self:Remove()
	end
end

function ENT:SpawnFunction( ply, tr, ClassName )

	if ( !tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 20
	local SpawnAng = ply:EyeAngles()
	SpawnAng.p = 0
	SpawnAng.y = SpawnAng.y + 180

	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:SetAngles( SpawnAng )
	ent:Spawn()
	ent:Activate()

	return ent

end

function ENT:DoMyAnimationThing( SequenceName, PlaybackRate )
	--print( SequenceName .. "  	" .. tostring(self:GetCooling()) )
	PlaybackRate = PlaybackRate or 1
	local sequenceID, sequenceDuration = self:LookupSequence( SequenceName )
	if (sequenceID != -1) then
		
		self:ResetSequence(sequenceID)
		self:SetPlaybackRate(PlaybackRate)
		self:ResetSequenceInfo()
		self:SetCycle(0)
		return CurTime() + sequenceDuration * (1 / PlaybackRate) 
	else
		MsgN("ERROR: Didn't find a sequence by the name of ", SequenceName)
		return CurTime()
	end
end

function ENT:OnRemove()
	if( self.sound ) then
		self.sound:Stop()
	end
end

util.AddNetworkString( "BCS_Net_CraftItem" )
net.Receive( "BCS_Net_CraftItem", function( len, ply )
	local BenchType = net.ReadString()
	local ItemKey = net.ReadInt( 32 )
	
	if( not BenchType or not ItemKey ) then return end
	
	ply:CraftBCS_Inventory( BenchType, ItemKey )
end )