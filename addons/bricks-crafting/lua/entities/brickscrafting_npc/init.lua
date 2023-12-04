AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/Eli.mdl")

	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid( SOLID_BBOX )
	self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
end

util.AddNetworkString( "BCS_Net_UseNPC" )
function ENT:Use( ply )
	if( IsValid( ply ) and ply:GetEyeTrace().Entity == self ) then
		if( self:GetUseCooldown() > CurTime() ) then return end

		self:SetUseCooldown( CurTime()+1 )
		
		net.Start( "BCS_Net_UseNPC" )
		net.Send( ply )
	end
end

function ENT:OnTakeDamage( dmgInfo )
	return 0
end

-- Training
util.AddNetworkString( "BCS_Net_LearnItem" )
net.Receive( "BCS_Net_LearnItem", function( len, ply )
	local BenchType = net.ReadString()
	local ItemKey = net.ReadInt( 32 )
	
	if( not BenchType or not ItemKey ) then return end
	
	if( BRICKSCRAFTING.CONFIG.Crafting[BenchType] and BRICKSCRAFTING.CONFIG.Crafting[BenchType].Items[ItemKey] ) then
		local Item = BRICKSCRAFTING.CONFIG.Crafting[BenchType].Items[ItemKey]
		if( Item.Skill ) then
			if( (Item.Skill or 0) > ply:GetBCS_SkillLevel( BenchType ) ) then
				ply:NotifyBCS( BRICKSCRAFTING.L("craftingNPCSkillLevelTooLow") )
				return
			end
		end

		if( BRICKSCRAFTING.LUACONFIG.DarkRP and Item.Cost ) then
			if( (Item.Cost or 0) > ply:getDarkRPVar( "money" ) ) then
				ply:NotifyBCS( BRICKSCRAFTING.L("craftingNPCNoMoney") )
				return
			end
		end

		local LearnItem = ply:AddBCS_CraftLearnt( BenchType, ItemKey )

		if( LearnItem != false ) then
			if( BRICKSCRAFTING.LUACONFIG.DarkRP and Item.Cost ) then
				ply:addMoney( -Item.Cost )
				ply:NotifyBCS_Chat( string.format( BRICKSCRAFTING.L("craftingNPCNewItemMoney"), Item.Name, DarkRP.formatMoney( Item.Cost ) ), "materials/brickscrafting/general_icons/training.png" )
			else
				ply:NotifyBCS_Chat( "+" .. Item.Name, "materials/brickscrafting/general_icons/training.png" )
			end
		end
	else
		ply:NotifyBCS( BRICKSCRAFTING.L("craftingNPCInvalid") )
	end
end )

-- Quests
util.AddNetworkString( "BCS_Net_AcceptQuest" )
util.AddNetworkString( "BCS_Net_ActiveQuest" )
net.Receive( "BCS_Net_AcceptQuest", function( len, ply )
	local QuestKey = net.ReadInt( 32 )
	
	if( not QuestKey ) then return end
	
	if( BRICKSCRAFTING.CONFIG.Quests[QuestKey] ) then
		local QuestTable = BRICKSCRAFTING.CONFIG.Quests[QuestKey]

		if( (ply:GetBCS_ActiveQuests() or 0) < BRICKSCRAFTING.LUACONFIG.MaxQuests ) then
			local AddQuest = ply:AddBCS_Quest( QuestKey )

			if( AddQuest != false ) then
				ply:NotifyBCS_Chat( BRICKSCRAFTING.L("craftingNPCAccepted") .. QuestTable.Name, "materials/brickscrafting/general_icons/quest.png" )

				net.Start( "BCS_Net_ActiveQuest" )
					net.WriteInt( QuestKey, 32 )
				net.Send( ply )
			else
				ply:NotifyBCS( BRICKSCRAFTING.L("craftingNPCAlready") )
			end
		else
			ply:NotifyBCS( string.format( BRICKSCRAFTING.L("craftingNPCLimit"), BRICKSCRAFTING.LUACONFIG.MaxQuests ) )
		end
	else
		ply:NotifyBCS( BRICKSCRAFTING.L("craftingNPCInvalidQuest") )
	end
end )

util.AddNetworkString( "BCS_Net_CancelQuest" )
net.Receive( "BCS_Net_CancelQuest", function( len, ply )
	local QuestKey = net.ReadInt( 32 )
	
	if( not QuestKey ) then return end
	
	if( BRICKSCRAFTING.CONFIG.Quests[QuestKey] ) then
		local QuestTable = BRICKSCRAFTING.CONFIG.Quests[QuestKey]

		local RemoveQuest = ply:RemoveBCS_Quest( QuestKey )

		if( RemoveQuest != false ) then
			ply:NotifyBCS_Chat( BRICKSCRAFTING.L("craftingNPCCancelled") .. QuestTable.Name, "materials/brickscrafting/general_icons/quest.png" )
		else
			ply:NotifyBCS( BRICKSCRAFTING.L("craftingNPCDontHave") )
		end
	else
		ply:NotifyBCS( BRICKSCRAFTING.L("craftingNPCInvalidQuest") )
	end
end )

util.AddNetworkString( "BCS_Net_HandInQuest" )
net.Receive( "BCS_Net_HandInQuest", function( len, ply )
	local QuestKey = net.ReadInt( 32 )
	
	if( not QuestKey ) then return end
	
	if( BRICKSCRAFTING.CONFIG.Quests[QuestKey] ) then
		local QuestTable = BRICKSCRAFTING.CONFIG.Quests[QuestKey]

		local CompletedQuest = ply:GetBCS_QuestCompleted( QuestKey )

		if( CompletedQuest != false ) then
			local CompleteQuest = ply:AddBCS_QuestCompleted( QuestKey )

			if( CompleteQuest != false ) then
				
			else
				ply:NotifyBCS( string.format( BRICKSCRAFTING.L("craftingNPCErrorQuest"), QuestTable.Name ) )
			end
		else
			ply:NotifyBCS( BRICKSCRAFTING.L("craftingNPCErrorCompletion") )
		end
	else
		ply:NotifyBCS( BRICKSCRAFTING.L("craftingNPCInvalidQuest") )
	end
end )

-- Update SWEP Colour
util.AddNetworkString( "BCS_Net_UpdateSWEP" )

-- Pickaxe Upgrades
util.AddNetworkString( "BCS_Net_UpgradePickaxe" )
net.Receive( "BCS_Net_UpgradePickaxe", function( len, ply )
	local MiscTable = ply:GetBCS_MiscTable()
	if( not BRICKSCRAFTING.CONFIG.Tools.Pickaxe[(MiscTable.PickaxeLevel or 0)+1] ) then return end

	local NextLevel = BRICKSCRAFTING.CONFIG.Tools.Pickaxe[(MiscTable.PickaxeLevel or 0)+1]

	if( not BRICKSCRAFTING.LUACONFIG.DarkRP or ply:getDarkRPVar( "money" ) >= (NextLevel.Cost or 0) ) then
		if( not NextLevel.Skill or ply:GetBCS_SkillLevel( "Mining" ) >= NextLevel.Skill ) then
			local UpgradePickaxe = ply:BCS_UpgradePickaxe()

			if( UpgradePickaxe != false ) then
				if( BRICKSCRAFTING.LUACONFIG.DarkRP and NextLevel.Cost and NextLevel.Cost > 0 ) then
					ply:addMoney( -(NextLevel.Cost or 0) )
					ply:NotifyBCS_Chat( string.format( BRICKSCRAFTING.L("craftingNPCUpgradeMoney"), (MiscTable.PickaxeLevel or 0), BRICKSCRAFTING.L("pickaxe"), DarkRP.formatMoney( NextLevel.Cost ) ), "materials/brickscrafting/general_icons/tools.png" )
				else
					ply:NotifyBCS_Chat( string.format( BRICKSCRAFTING.L("craftingNPCUpgrade"), (MiscTable.PickaxeLevel or 0), BRICKSCRAFTING.L("pickaxe") ), "materials/brickscrafting/general_icons/tools.png" )
				end

				if( IsValid( ply:GetActiveWeapon() ) and ply:GetActiveWeapon().UpdateSWEPColour ) then
					ply:GetActiveWeapon():UpdateSWEPColour()
				end

				net.Start( "BCS_Net_UpdateSWEP" )
				net.Send( ply )
			else
				ply:NotifyBCS( string.format( BRICKSCRAFTING.L("craftingNPCMaxLevel"), BRICKSCRAFTING.L("pickaxe") ) )
			end
		else
			ply:NotifyBCS( string.format( BRICKSCRAFTING.L("craftingNPCNotSkill"), NextLevel.Skill, BRICKSCRAFTING.L("mining"), BRICKSCRAFTING.L("pickaxe") ) )
		end
	else
		ply:NotifyBCS( string.format( BRICKSCRAFTING.L("craftingNPCNotMoney"), DarkRP.formatMoney( (NextLevel.Cost or 0) ), BRICKSCRAFTING.L("pickaxe") ) )
	end
end )

-- Lumber Axe Upgrades
util.AddNetworkString( "BCS_Net_UpgradeLumberAxe" )
net.Receive( "BCS_Net_UpgradeLumberAxe", function( len, ply )
	local MiscTable = ply:GetBCS_MiscTable()
	if( not BRICKSCRAFTING.CONFIG.Tools.LumberAxe[(MiscTable.LumberAxeLevel or 0)+1] ) then return end

	local NextLevel = BRICKSCRAFTING.CONFIG.Tools.LumberAxe[(MiscTable.LumberAxeLevel or 0)+1]

	if( not BRICKSCRAFTING.LUACONFIG.DarkRP or ply:getDarkRPVar( "money" ) >= (NextLevel.Cost or 0) ) then
		if( not NextLevel.Skill or ply:GetBCS_SkillLevel( "Wood Cutting" ) >= NextLevel.Skill ) then
			local UpgradeLumberAxe = ply:BCS_UpgradeLumberAxe()

			if( UpgradeLumberAxe != false ) then
				if( BRICKSCRAFTING.LUACONFIG.DarkRP and NextLevel.Cost and NextLevel.Cost > 0 ) then
					ply:addMoney( -(NextLevel.Cost or 0) )
					ply:NotifyBCS_Chat( string.format( BRICKSCRAFTING.L("craftingNPCUpgradeMoney"), (MiscTable.LumberAxeLevel or 0), BRICKSCRAFTING.L("lumberAxe"), DarkRP.formatMoney( NextLevel.Cost ) ), "materials/brickscrafting/general_icons/tools.png" )
				else
					ply:NotifyBCS_Chat( string.format( BRICKSCRAFTING.L("craftingNPCUpgrade"), (MiscTable.LumberAxeLevel or 0), BRICKSCRAFTING.L("lumberAxe") ), "materials/brickscrafting/general_icons/tools.png" )
				end

				if( IsValid( ply:GetActiveWeapon() ) and ply:GetActiveWeapon().UpdateSWEPColour ) then
					ply:GetActiveWeapon():UpdateSWEPColour()
				end

				net.Start( "BCS_Net_UpdateSWEP" )
				net.Send( ply )
			else
				ply:NotifyBCS( string.format( BRICKSCRAFTING.L("craftingNPCMaxLevel"), BRICKSCRAFTING.L("lumberAxe") ) )
			end
		else
			ply:NotifyBCS( string.format( BRICKSCRAFTING.L("craftingNPCNotSkill"), NextLevel.Skill, BRICKSCRAFTING.L("woodCutting"), BRICKSCRAFTING.L("lumberAxe") ) )
		end
	else
		ply:NotifyBCS( string.format( BRICKSCRAFTING.L("craftingNPCNotMoney"), DarkRP.formatMoney( (NextLevel.Cost or 0) ), BRICKSCRAFTING.L("lumberAxe") ) )
	end
end )

-- Sell resources
util.AddNetworkString( "BCS_Net_SellResources" )
util.AddNetworkString( "BCS_Net_SellResources_Return" )
net.Receive( "BCS_Net_SellResources", function( len, ply )
	local ResourceType = net.ReadString()
	local Amount = net.ReadInt( 32 )

	if( not ResourceType or not Amount ) then return end
	if( not BRICKSCRAFTING.CONFIG.Resources[ResourceType] ) then return end
	if( not BRICKSCRAFTING.CONFIG.Resources[ResourceType].Price ) then return end

	if( (ply.BCS_SellCooldown or 0) > CurTime() ) then return end
	ply.BCS_SellCooldown = CurTime()+BRICKSCRAFTING.LUACONFIG.SellCooldown
	
	local nearNPC = false
	for k, v in pairs( ents.FindInSphere( ply:GetPos(), BRICKSCRAFTING.LUACONFIG.NPCSellDistance ) or {} ) do
		if( v:GetClass() == "brickscrafting_npc" ) then
			nearNPC = true
			break
		end
	end

	if( not nearNPC ) then return end

	local PlyInventory = ply:GetBCS_Inventory()
	if( PlyInventory and PlyInventory.Resources and PlyInventory.Resources[ResourceType] ) then
		if( PlyInventory.Resources[ResourceType] >= Amount and Amount > 0 ) then
			PlyInventory.Resources[ResourceType] = PlyInventory.Resources[ResourceType] - Amount
			ply:SetBCS_Inventory( PlyInventory )
			ply:NotifyBCS_Chat( "-" .. Amount .. " " .. ResourceType, BRICKSCRAFTING.CONFIG.Resources[ResourceType].icon )

			local Money = BRICKSCRAFTING.CONFIG.Resources[ResourceType].Price*Amount
			ply:addMoney( Money )

			ply:NotifyBCS( string.format( BRICKSCRAFTING.L("vguiNPCShopExchange"), string.Comma( Amount ), ResourceType, DarkRP.formatMoney( Money ) ) )

			net.Start( "BCS_Net_SellResources_Return" )
			net.Send( ply )
		end
	end
end )