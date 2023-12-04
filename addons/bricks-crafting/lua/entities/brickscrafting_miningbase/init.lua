AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	if( BRICKSCRAFTING.CONFIG.Mining[self.MiningType] ) then
		self:SetModel( BRICKSCRAFTING.CONFIG.Mining[self.MiningType].model )
	else
		self:SetModel( BRICKSCRAFTING.LUACONFIG.Defaults.RockModel )
	end
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
	self:GetPhysicsObject():EnableMotion( false )
	
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end

	self:SetRHealth( BRICKSCRAFTING.LUACONFIG.RockHealth )
	self:SetStage( 0 )
end

local Stages = {}
Stages[1] = { 90, 0.95 }
Stages[2] = { 80, 0.9 }
Stages[3] = { 70, 0.85 }
Stages[4] = { 60, 0.8 }
Stages[5] = { 50, 0.75 }
Stages[6] = { 40, 0.7 }
Stages[7] = { 30, 0.65 }
Stages[8] = { 20, 0.625 }
Stages[9] = { 10, 0.6 }

function ENT:HitRock( Damage )
	if( not Damage or Damage <= 0 ) then return end

	self:SetRHealth( self:GetRHealth()-Damage )

	if( self:GetRHealth() <= 0 ) then
		if( BCS_ROCKS and BCS_ROCKS[self:GetRockKey() or 0] ) then
			local RockKey = self:GetRockKey()
			timer.Create( "BCS_TIMERS_ROCKS_" .. RockKey, BRICKSCRAFTING.LUACONFIG.RockRespawn, 1, function()
				if( BCS_ROCKS and BCS_ROCKS[RockKey or 0] ) then
					local RockTable = BCS_ROCKS[RockKey or 0]

					local NewEnt = ents.Create( RockTable[1] )
					NewEnt:SetPos( RockTable[2] )
					NewEnt:SetAngles( RockTable[3] )
					NewEnt:Spawn()
					NewEnt:SetRockKey( RockKey )
					if( math.random( 0, 1000 ) == 1 ) then
						NewEnt:SetEgg( true )
						NewEnt:EmitSound("ambient/alarms/warningbell1.wav", 511, 255, 1, CHAN_AUTO )
					end
				end
			end )
		end

		self:Remove()
		return 
	end

	if( BRICKSCRAFTING.LUACONFIG.ChangeRockSize and self:GetStage() != #Stages ) then
		for k, v in pairs( Stages ) do
			if( self:GetStage() < k ) then
				if( (self:GetRHealth()/BRICKSCRAFTING.LUACONFIG.RockHealth)*100 <= v[1] ) then
					self:SetStage( k )
					self:SetModelScale( v[2] )
					--self:Activate()
				else
					break
				end
			end
		end
	end
end