AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel( "models/props_junk/garbage128_composite001d.mdl" )
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end

	phys:EnableMotion( false )

	self:SetCollector( nil )
end

function ENT:Use(activator, caller)
	if( IsValid( self:GetCollector() ) ) then return end
	if( caller:GetPos():DistToSqr( self:GetPos() ) > 8000 ) then return end
	if( caller:GetNWInt("BCS_GarbageTime", 0) > CurTime() ) then return end

	self:SetCollector( caller )

	caller:SetNWInt( "BCS_GarbageTime", CurTime()+BRICKSCRAFTING.CONFIG.Garbage.CollectTime )
end

function ENT:Think()
	if( IsValid( self:GetCollector() ) ) then
		local ply = self:GetCollector()

		if( not ply:Alive() or ply:GetPos():DistToSqr( self:GetPos() ) > 8000 ) then
			ply:SetNWInt( "BCS_GarbageTime", 0 )
			self:SetCollector( nil )
		else
			if( CurTime() >= ply:GetNWInt("BCS_GarbageTime", 0) ) then
				self:RewardPly( ply )
			end
		end
	end
end

function ENT:RewardPly( ply )
	for i = 1, 4 do
		local ChosenResource = ""
		local ResourcePercent = math.Rand(0, 100)
		local CurPercent = 0
		for k, v in pairs( BRICKSCRAFTING.CONFIG.Garbage.Resources ) do
			if( ResourcePercent > CurPercent and ResourcePercent < CurPercent+v ) then
				ChosenResource = k
				break
			end
			CurPercent = CurPercent+v
		end

		if( BRICKSCRAFTING.CONFIG.Resources[ChosenResource] ) then
			local StartPos = self:GetPos()-(self:GetRight()*60)

			local resourceEnt = ents.Create( "brickscrafting_resource" .. string.Replace( string.lower( ChosenResource ), " ", "" ) )
			if( IsValid( resourceEnt ) ) then
				resourceEnt:SetPos( StartPos+(self:GetRight()*((i-1)*40))+(self:GetUp()*20) )
				resourceEnt:Spawn()
			end
		end
	end

	ply:SetNWInt( "BCS_GarbageTime", 0 )

	if( BCS_GARBAGE and BCS_GARBAGE[self:GetGarbageKey() or 0] ) then
		local GarbageKey = self:GetGarbageKey()
		timer.Create( "BCS_TIMERS_GARBAGE_" .. GarbageKey, BRICKSCRAFTING.LUACONFIG.GarbageRespawn, 1, function()
			if( BCS_GARBAGE and BCS_GARBAGE[GarbageKey or 0] ) then
				local GarbageTable = BCS_GARBAGE[GarbageKey or 0]

				local NewEnt = ents.Create( "brickscrafting_garbage" )
				NewEnt:SetPos( GarbageTable[1] )
				NewEnt:SetAngles( GarbageTable[2] )
				NewEnt:Spawn()
				NewEnt:SetGarbageKey( GarbageKey )
			end
		end )
	end

	BRICKSCRAFTING.AddExperience( ply, BRICKSCRAFTING.LUACONFIG.ExpForGarbage, "Garbage" )

	self:Remove()
end