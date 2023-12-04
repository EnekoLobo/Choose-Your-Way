TOOL.Category = "Bricks Credit Store"
TOOL.Name = "NPC Placer"
TOOL.Command = nil
TOOL.ConfigName = "" --Setting this means that you do not have to create external configuration files to define the layout of the tool config-hud 
 
if( SERVER ) then
	concommand.Add( "brcs_stoolcmd_npctype", function( ply, cmd, args )
		if( args[1] ) then
			ply:SetNWString( "brcs_stoolcmd_npctype", args[1] )
		end
	end )
end

function TOOL:LeftClick( trace )
	if( !trace.HitPos || IsValid( trace.Entity ) && trace.Entity:IsPlayer() ) then return false end
	if( CLIENT ) then return true end

	local ply = self:GetOwner()
	if( not BRICKSCREDITSTORE.HasAdminAccess( ply ) ) then
		ply:NotifyBRCS( "You don't have permission to use this tool!" )
		return
	end

	if( BRICKSCREDITSTORE.CONFIG.NPCs[ply:GetNWString( "brcs_stoolcmd_npctype" )] ) then
		local Ent = ents.Create( "brickscreditstore_npc" )
		if( !IsValid( Ent ) ) then
			ply:NotifyBRCS( "This is not a valid NPC!" )
			return
		end
		Ent:SetPos( trace.HitPos )
		local EntAngles = Ent:GetAngles()
		local PlayerAngle = ply:GetAngles()
		Ent:SetAngles( Angle( EntAngles.p, PlayerAngle.y+180, EntAngles.r ) )
		Ent:Spawn()

		Ent:SetNPCType( ply:GetNWString( "brcs_stoolcmd_npctype" ) )
		
		ply:NotifyBRCS( "NPC placed!" )
		ply:ConCommand( "brcs_savenpcpositions" )
	else
		ply:NotifyBRCS( "This is not a valid NPC!" )
	end
end
 
function TOOL:RightClick( trace )
	if( !trace.HitPos ) then return false end
	if( !IsValid( trace.Entity ) or trace.Entity:IsPlayer() ) then return false end
	if( CLIENT ) then return true end

	local ply = self:GetOwner()

	if( not BRICKSCREDITSTORE.HasAdminAccess( ply ) ) then
		ply:NotifyBRCS( "You don't have permission to use this tool!" )
		return
	end
	
	if( trace.Entity:GetClass() == "brickscreditstore_npc" ) then
		trace.Entity:Remove()
		ply:NotifyBRCS( "NPC removed!" )
		ply:ConCommand( "brcs_savenpcpositions" )
	else
		ply:NotifyBRCS( "You can only use this tool on credit store entities!" )
		return false
	end
end

function TOOL.BuildCPanel( panel )
	panel:AddControl("Header", { Text = "NPC Type", Description = "Left click to place the NPC, right click to remove the NPC!" })
 
	local combo = panel:AddControl( "ComboBox", { Label = "NPC Type", ConVar = "testcommand" } )
	for k, v in pairs( BRICKSCREDITSTORE.CONFIG.NPCs ) do
		combo:AddOption( k, { brcs_stoolcmd_npctype = k } )
	end
end