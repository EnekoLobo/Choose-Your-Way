AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()
	if( BRICKSCREDITSTORE.CONFIG.NPCs[self.NPCType] and BRICKSCREDITSTORE.CONFIG.NPCs[self.NPCType].model ) then
		self:SetModel( BRICKSCREDITSTORE.CONFIG.NPCs[self.NPCType].model )
	else
		self:SetModel( "models/breen.mdl" )
	end

	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_BBOX )
	self:SetCollisionGroup( COLLISION_GROUP_PLAYER )
end

util.AddNetworkString( "BRCS_Net_UseNPC" )
function ENT:Use( ply )
	if( IsValid( ply ) and ply:GetEyeTrace().Entity == self ) then
		if( self:GetUseCooldown() > CurTime() ) then return end

		self:SetUseCooldown( CurTime()+1 )
		
		net.Start( "BRCS_Net_UseNPC" )
			net.WriteString( self:Getnpc_type() or "" )
		net.Send( ply )
	end
end

function ENT:SetNPCType( npcType )
	self:Setnpc_type( npcType )

	if( BRICKSCREDITSTORE.CONFIG.NPCs[npcType] and BRICKSCREDITSTORE.CONFIG.NPCs[npcType].model ) then
		self:SetModel( BRICKSCREDITSTORE.CONFIG.NPCs[npcType].model )
	end
end