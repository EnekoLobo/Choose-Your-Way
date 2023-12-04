MQS.DB.Driver = {}
MQS.DB.Driver.Name = "SQLite"

local map = string.lower(game.GetMap())

function MQS.DB.GetMapData(map_name)

	map_name = MQS.DB.Escape(string.lower(map_name))

	if not map_name then return false end

	local data_found = {}

	MQS.DB.Query("SELECT * FROM mqs_quests WHERE map=" .. map_name, function(result)
		if result ~= nil and #result > 0 then
			for k,v in ipairs(result) do
				data_found[v.id] = util.JSONToTable(v.value)
			end
		end
	end)

	return data_found
end

function MQS.DB.Init()
	MsgC(Color(0, 255, 0), "[MQS] SQLite: Initializing...\n")

	MQS.DB.Query("CREATE TABLE IF NOT EXISTS mqs_player(id TEXT, value TEXT)")
	MQS.DB.Query("CREATE TABLE IF NOT EXISTS mqs_quests(id TEXT, map TEXT, value TEXT)")

	MQS.Quests = MQS.DB.GetMapData(map)
end

function MQS.DB.Query(query, callback, errorcb)

	local result = sql.Query(query)

	if result == false then
		if errorcb ~= nil then
			errorcb(sql.LastError)
		else
			local sqlerror = sql.LastError()
			MsgC(Color(255, 0, 0), "[MQS] SQL Error: " .. sqlerror .. "\n")
		end
	else
		if callback ~= nil then
			callback(result)
		end
	end
end

function MQS.DB.Escape(str, nqts)
	return sql.SQLStr(str, nqts)
end

hook.Add("Initialize", "MQS.DB.Init", function()
	MQS.DB.Init()
end)

function MQS.SaveQuestData(id, data)
	id = MQS.DB.Escape(id)

	local json = MQS.DB.Escape(util.TableToJSON(data), true)

	MQS.DB.Query("DELETE FROM mqs_quests WHERE id=" .. id .. " AND map='" .. map .. "'", function()
		MQS.DB.Query("INSERT INTO mqs_quests VALUES(" .. id .. ", '" .. map .. "', '" .. json .. "')")
		MsgC(Color(0, 255, 0), "[MQS] SQLite: Quest " .. id .. " updated\n")
	end)
end

function MQS.RemoveQuestData(id)
	id = MQS.DB.Escape(id)

	MQS.DB.Query("DELETE FROM mqs_quests WHERE id=" .. id .. " AND map='" .. map .. "'", function()
		MsgC(Color(0, 255, 0), "[MQS] SQLite: Quest " .. id .. " removed\n")
	end)
end

function MQS.DB.GetPlayerData(sid)
	if not sid then return end
	sid = MQS.DB.Escape(sid)
	local data
	MQS.DB.Query("SELECT * FROM mqs_player WHERE id=" .. sid, function(result)
		if result ~= nil and #result > 0 then
			local tbl = util.JSONToTable(result[1].value)
			if tbl and istable(tbl) then
				data = tbl
			end
		end
	end)
	return data
end