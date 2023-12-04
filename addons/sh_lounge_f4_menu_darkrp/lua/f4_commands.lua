-- Commands to display in the "Command" tab.
-- An empty table will hide the command tab.
-- You can add a "teams" filter to a category so the category will only display if a player's job name is in the teams tab.
-- See below for an example.
-- Other filters include "usergroups" table and "customCheck" function.
LOUNGE_F4.Commands = {
	{
		name = "General",
		commands = {
			{
				name = "Drop money",
				cmd = function()
					L_StringRequest("Drop money", "How much money would you like to drop?", function(text)
						RunConsoleCommand("say", "/dropmoney " .. text)
					end)
				end,
			},
			{
				name = "Change RP Name",
				cmd = function()
					L_StringRequest("Change RP Name", "Enter the RP Name you would like to have.", function(text)
						RunConsoleCommand("say", "/rpname " .. text)
					end)
				end,
			},
			{
				name = "Drop held weapon",
				cmd = function()
					RunConsoleCommand("say", "/drop")
				end,
			},
			{
				name = "Start demotion vote",
				cmd = function()
					local m = L_Menu()

					for _, v in ipairs (player.GetAll()) do
						if (v == LocalPlayer()) then
							continue end

						m:AddOption(v:Nick(), function()
							if (!IsValid(v)) then
								return end

							L_StringRequest("Demotion reason", "Enter a reason to demote " .. v:Nick() .. " from " .. team.GetName(v:Team()) .. ".", function(text)
								RunConsoleCommand("say", "/demote " .. v:Nick() .. " " .. text)
							end)
						end)
					end

					m:Open()
				end,
			},
			{
				name = "Sell all doors",
				cmd = function()
					RunConsoleCommand("say", "/unownalldoors")
				end,
			},
			{
				name = "Request gun license",
				cmd = function()
					RunConsoleCommand("say", "/requestlicense")
				end,
			},
		},
	},
	{
		name = "Mayor Commands",
		teams = {
			["Mayor"] = true,
		},
		commands = {
			{
				name = "Start a lottery",
				cmd = function()
					L_StringRequest("Lottery entry cost", "How much money should entering the lottery cost?", function(text)
						RunConsoleCommand("say", "/lottery " .. text)
					end)
				end,
			},
			{
				name = "Initiate lockdown",
				cmd = function()
					RunConsoleCommand("say", "/lockdown")
				end,
			},
			{
				name = "End lockdown",
				cmd = function()
					RunConsoleCommand("say", "/unlockdown")
				end,
			},
			{
				name = "Introduce new law",
				cmd = function()
					L_StringRequest("New law", "What law would you like to introduce?", function(text)
						RunConsoleCommand("say", "/addlaw " .. text)
					end)
				end,
			},
			{
				name = "Create law board",
				cmd = function()
					RunConsoleCommand("say", "/placelaws")
				end,
			},
			{
				name = "Make player wanted",
				cmd = function()
					local m = L_Menu()

					for _, v in ipairs (player.GetAll()) do
						local nick = v:Nick()
						m:AddOption(nick, function()
							L_StringRequest("Wanted reason", "Enter a reason to make " .. nick .. " wanted.", function(text)
								RunConsoleCommand("say", "/wanted " .. nick .. " " .. text)
							end)
						end)
					end

					m:Open()
				end,
			},
			{
				name = "Make player unwanted",
				cmd = function()
					local m = L_Menu()

					for _, v in ipairs (player.GetAll()) do
						local nick = v:Nick()
						m:AddOption(nick, function()
							RunConsoleCommand("say", "/unwanted " .. nick)
						end)
					end

					m:Open()
				end,
			},
			{
				name = "Authorize warrant on player",
				cmd = function()
					local m = L_Menu()

					for _, v in ipairs (player.GetAll()) do
						local nick = v:Nick()
						m:AddOption(nick, function()
							L_StringRequest("Warrant reason", "Enter a reason to authorize a search warrant on " .. nick .. ".", function(text)
								RunConsoleCommand("say", "/warrant " .. nick .. " " .. text)
							end)
						end)
					end

					m:Open()
				end,
			},
			{
				name = "Cancel warrant on player",
				cmd = function()
					local m = L_Menu()

					for _, v in ipairs (player.GetAll()) do
						local nick = v:Nick()
						m:AddOption(nick, function()
							RunConsoleCommand("say", "/unwarrant " .. nick)
						end)
					end

					m:Open()
				end,
			},
			{
				name = "Grant gun license to target player",
				cmd = function()
					RunConsoleCommand("say", "/givelicense")
				end,
			},
		},
	},
	{
		name = "Police Commands",
		teams = {
			["Mayor"] = true,
			["Civil Protection"] = true,
			["Civil Protection Chief"] = true,
		},
		commands = {
			{
				name = "Make player wanted",
				cmd = function()
					local m = L_Menu()

					for _, v in ipairs (player.GetAll()) do
						local nick = v:Nick()
						m:AddOption(nick, function()
							L_StringRequest("Wanted reason", "Enter a reason to make " .. nick .. " wanted.", function(text)
								RunConsoleCommand("say", "/wanted " .. nick .. " " .. text)
							end)
						end)
					end

					m:Open()
				end,
			},
			{
				name = "Make player unwanted",
				cmd = function()
					local m = L_Menu()

					for _, v in ipairs (player.GetAll()) do
						local nick = v:Nick()
						m:AddOption(nick, function()
							RunConsoleCommand("say", "/unwanted " .. nick)
						end)
					end

					m:Open()
				end,
			},
			{
				name = "Authorize warrant on player",
				cmd = function()
					local m = L_Menu()

					for _, v in ipairs (player.GetAll()) do
						local nick = v:Nick()
						m:AddOption(nick, function()
							L_StringRequest("Warrant reason", "Enter a reason to authorize a search warrant on " .. nick .. ".", function(text)
								RunConsoleCommand("say", "/warrant " .. nick .. " " .. text)
							end)
						end)
					end

					m:Open()
				end,
			},
			{
				name = "Cancel warrant on player",
				cmd = function()
					local m = L_Menu()

					for _, v in ipairs (player.GetAll()) do
						local nick = v:Nick()
						m:AddOption(nick, function()
							RunConsoleCommand("say", "/unwarrant " .. nick)
						end)
					end

					m:Open()
				end,
			},
			{
				name = "Set jail position",
				cmd = function()
					RunConsoleCommand("say", "/setjailpos")
				end,
			},
			{
				name = "Add jail position",
				cmd = function()
					RunConsoleCommand("say", "/addjailpos")
				end,
			},
		},
	},
}