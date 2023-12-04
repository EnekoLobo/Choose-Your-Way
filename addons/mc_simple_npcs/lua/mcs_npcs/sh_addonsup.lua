--  _______               __          _______  __                   __          _______  ______  ______        
-- |   |   |.---.-..----.|  |.-----. |     __||__|.--------..-----.|  |.-----. |    |  ||   __ \|      |.-----.
-- |       ||  _  ||  __| |_||__ --| |__     ||  ||        ||  _  ||  ||  -__| |       ||    __/|   ---||__ --|
-- |__|_|__||___._||____|    |_____| |_______||__||__|__|__||   __||__||_____| |__|____||___|   |______||_____|
--   
----------------------------------------------------------------------------------------------------------------
------------------------- Warning! Edit this only if you know what are you doing -------------------------------
----------------------------------------------------------------------------------------------------------------
MCS.AddonList = {}
MCS.ActiveAddons = 0

function MCS.CheckID(id)
	return string.match( id, "^[a-zA-Z0-9_]*$" )
end

function MCS.TableCompress(data)
	local json_data = util.TableToJSON(data, false)
	local compressed_data = util.Compress(json_data)
	local bytes_number = string.len(compressed_data)

	return compressed_data, bytes_number
end

function MCS.TableDecompress(compressed_data)
	local json_data = util.Decompress(compressed_data)
	local data = util.JSONToTable(json_data)

	return data
end

MCS.AddonList["CH FireSystem"] = {
	["check"] = function() return CH_FireSystem and true or false end,
	["function"] = nil,
	["function_sv"] = function(ply)
		if IsValid(ply) and table.HasValue(CH_FireSystem.Config.AllowedTeams, team.GetName(ply:Team())) then
			net.Start("FIRE_FiretruckMenu")
			net.Send(ply)
		else
			DarkRP.notify(ply, 2, 5, "Only firefighters can access this NPC!")
		end
	end,
	["enabled"] = false,
}

MCS.AddonList["CH TowTruck"] = {
	["check"] = function() return TEAM_TOWER and true or false end,
	["function"] = nil,
	["function_sv"] = function(ply)
		if IsValid(ply) and ply:Team() == TEAM_TOWER then
			net.Start("TOW_TowTruck_Menu", ply)
			net.Send(ply)
		else
			DarkRP.notify(ply, 1, 5, "Only tow truck drivers can access this NPC!")
		end
	end,
	["enabled"] = false,
}

MCS.AddonList["CH ShopNPC"] = {
	["check"] = function() return NPCShop_Items and true or false end,
	["function"] = function()
		NPC_ShopMenu()
	end,
	["function_sv"] = nil,
	["enabled"] = false,
}

MCS.AddonList["CH GovStation"] = {
	["check"] = function() return GovStation_Vehicles and true or false end,
	["function"] = function()
		GovStation_Menu()
	end,
	["function_sv"] = nil,
	["enabled"] = false,
}

MCS.AddonList["SH Accessories"] = {
	["check"] = function() return SH_ACC and true or false end,
	["function"] = nil,
	["function_sv"] = function(ply)
		SH_ACC:Show(ply)
	end,
	["enabled"] = false,
}

MCS.AddonList["MQS Continue quest"] = {
	["check"] = function() return MQS and true or false end,
	["function"] = nil,
	["function_sv"] = function(ply, npc, data)
		local q = MQS.HasQuest(ply)

		if not q then return end

		if (data and not data.quest_id) and MQS.Quests[q.quest].objects[MQS.GetNWdata(ply, "quest_objective") or 0].type ~= "Talk to NPC" then
			return
		end

		if data and data.quest_id and data.quest_id ~= q.quest then
			return
		end

		MQS.UpdateObjective(ply)
	end,
	["enabled"] = false,
}

MCS.AddonList["MQS Skip to"] = {
	["check"] = function() return MQS and true or false end,
	["function"] = nil,
	["function_sv"] = function(ply, npc, data)
		local q = MQS.HasQuest(ply)

		if not q then return end

		if (data and not data.quest_id) and MQS.Quests[q.quest].objects[MQS.GetNWdata(ply, "quest_objective") or 0].type ~= "Talk to NPC" then
			return
		end

		if data and data.quest_id and data.quest_id ~= q.quest then
			return
		end

		MQS.UpdateObjective(ply, data.id)
	end,
	["add_data"] = {
		id = 1
	},
	["enabled"] = false,
}

MCS.AddonList["MQS Fail quest"] = {
	["check"] = function() return MQS and true or false end,
	["function"] = nil,
	["function_sv"] = function(ply)
		local q = MQS.HasQuest(ply)

		if not q then return end

		if MQS.Quests[q.quest].objects[MQS.GetNWdata(ply, "quest_objective") or 0].type ~= "Talk to NPC" then
			return
		end

		MQS.FailTask(ply, MSD.GetPhrase("m_blew"))
	end,
	["enabled"] = false,
}

MCS.AddonList["MQS Start quest"] = {
	["check"] = function() return MQS and true or false end,
	["function"] = function(npc, data)
		net.Start("MQS.StartTask")
		net.WriteString(data.quest_id)
		net.WriteBool(true)
		net.WriteString(npc:GetUID())
		net.SendToServer()
	end,
	["function_sv"] = nil,
	["enabled"] = false,
	["add_data"] = {
		quest_id = "none"
	},
	["hide"] = true,
}

MCS.AddonList["MQS Open All quests"] = {
	["check"] = function() return MQS and true or false end,
	["function"] = nil,
	["function_sv"] = function(ply, npc)
		net.Start("MQS.OpenNPCMenu")
		net.WriteEntity(npc)
		net.Send(ply)
	end,
	["enabled"] = false,
}

MCS.AddonList["Modern Car Dealler"] = {
	["function"] = function(npc, data)
		ModernCarDealer:OpenDealerUI({}, "CarDealler")
	end,
	["function_sv"] = nil,
	["enabled"] = true,
}


MCS.AddonList["MQS Finish and force start"] = {
	["check"] = function() return MQS and true or false end,
	["function"] = nil,
	["function_sv"] = function(ply, npc, data)
		local q = MQS.HasQuest(ply)

		if not q then return end

		if MQS.Quests[q.quest].objects[MQS.GetNWdata(ply, "quest_objective") or 0].type ~= "Talk to NPC" then
			return
		end

		MQS.UpdateObjective(ply)

		timer.Simple(0, function()
			MQS.StartTask(data.quest_id, ply, npc, true)
		end)
	end,
	["add_data"] = {
		quest_id = "new_quest"
	},
	["enabled"] = false,
}

local function AddonListCheck()
	for id, addon in pairs(MCS.AddonList) do
		if not addon["enabled"] and addon["check"] and addon["check"]() then
			addon["enabled"] = true
			MCS.ActiveAddons = MCS.ActiveAddons + 1
			print("[MCS] " .. id .. " support enabled!")
		end
	end

	if SH_ACC then
		local meta = FindMetaTable("Player")
		local npc_list = {
			["npc_accessory_vendor"] = true,
			["mcs_npc"] = true
		}
		function meta:SH_NearAccessoryVendor()
			if (SH_ACC.FreeAccess) then
				return true
			end

			local pos = self:GetPos()
			for _, v in ipairs(ents.GetAll()) do
				if npc_list[v:GetClass()] and v:GetPos():DistToSqr(pos) <= 70000 then
					return true
				end
			end

			return false
		end
	end
end

AddonListCheck()
timer.Create("MCS.AddonCheck", 20, 5, AddonListCheck)