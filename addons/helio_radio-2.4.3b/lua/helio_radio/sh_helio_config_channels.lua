
--------------
-- CHANNELS --
--------------

hradio.Channels = {}

-- talkers is a list of teams that can talk in a channel. listeners work the same.
-- gettalkers and geltisteners are functions that return whether a player should be able to talk or listen to a given channel. returning false makes the script ignore the function.
-- the script shall use the sum of the function and the team list to determine who should hear who.

-- Channels will be displayed in the same order they are in this file.

local todoslosjedis = { -- This name can be whatever you want (but it cannot start with a number or be a number)
  ["Orden Jedi"] = true,
  ["Tropas Jedi"] = true,
}

local senderoOscuro = { -- This name can be whatever you want (but it cannot start with a number or be a number)
  ["Sendero Oscuro"] = true,
}

local tropasjedis = { -- This name can be whatever you want (but it cannot start with a number or be a number)
  ["Tropas Jedi"] = true,
}

local solojedis = { -- This name can be whatever you want (but it cannot start with a number or be a number)
  ["Orden Jedi"] = true,
}

local civiles = { -- This name can be whatever you want (but it cannot start with a number or be a number)
  ["Civiles"] = true,
}

hradio.AddChannel({
	Name = "Radio Abierta",
	Talkers = {}, -- List of TEAM_ identifiers (from your jobs.lua), lets these people talk on this channel
	Listeners = {}, -- List of TEAM_ identifiers (from your jobs.lua), lets these people listen on this channel
	GetTalkers = function(ply) return true end, -- A lua function. Return true for a player to let them talk on this channel, return false to only let people in the Talkers table talk
	GetListeners = function(ply) return true end, -- A lua function. Return true for a player to let them listen on this channel, return false to only let people in the Listeners table listen
	Mutable = true, -- Should the player be able to mute this channel?
	Colour = Color(25,215,0) -- Channel header color
})

hradio.AddChannel({
	Name = "Templo Jedi",
	Talkers = {}, -- List of TEAM_ identifiers (from your jobs.lua), lets these people talk on this channel
	Listeners = {}, -- List of TEAM_ identifiers (from your jobs.lua), lets these people listen on this channel
    GetTalkers = function(ply) return solojedis[RPExtraTeams[ply:Team()].category] end, -- A lua function. Return true for a player to let them talk on this channel, return false to only let people in the Talkers table talk
    GetListeners = function(ply) return solojedis[RPExtraTeams[ply:Team()].category] end, -- A lua function. Return true for a player to let them listen on this channel, return false to only let people in the Listeners table listen
	Mutable = true, -- Should the player be able to mute this channel?
	Colour = Color(32, 110, 255) -- Channel header color
})

hradio.AddChannel({
	Name = "Jedis y Tropas Jedi",
	Talkers = {}, -- List of TEAM_ identifiers (from your jobs.lua), lets these people talk on this channel
	Listeners = {}, -- List of TEAM_ identifiers (from your jobs.lua), lets these people listen on this channel
    GetTalkers = function(ply) return todoslosjedis[RPExtraTeams[ply:Team()].category] end, -- A lua function. Return true for a player to let them talk on this channel, return false to only let people in the Talkers table talk
    GetListeners = function(ply) return todoslosjedis[RPExtraTeams[ply:Team()].category] end, -- A lua function. Return true for a player to let them listen on this channel, return false to only let people in the Listeners table listen
	Mutable = true, -- Should the player be able to mute this channel?
	Colour = Color(32, 110, 255) -- Channel header color
})

hradio.AddChannel({
	Name = "Imperio Sith",
	Talkers = {TEAM_ADEPTO, TEAM_SECUAZ, TEAM_APRENDIZ, TEAM_MAESTROSITH, TEAM_IRIONDORPRIME, TEAM_REUS}, -- List of TEAM_ identifiers (from your jobs.lua), lets these people talk on this channel
	Listeners = {TEAM_ADEPTO, TEAM_SECUAZ, TEAM_APRENDIZ, TEAM_MAESTROSITH, TEAM_IRIONDORPRIME, TEAM_REUS}, -- List of TEAM_ identifiers (from your jobs.lua), lets these people listen on this channel
	GetTalkers = function(ply) return false end, -- A lua function. Return true for a player to let them talk on this channel, return false to only let people in the Talkers table talk
	GetListeners = function(ply) return false end, -- A lua function. Return true for a player to let them listen on this channel, return false to only let people in the Listeners table listen
	Mutable = true, -- Should the player be able to mute this channel?
	Colour = Color(141, 0, 0) -- Channel header color
})

hradio.AddChannel({
	Name = "Seguridad Jedi",
	Talkers = {}, -- List of TEAM_ identifiers (from your jobs.lua), lets these people talk on this channel
	Listeners = {}, -- List of TEAM_ identifiers (from your jobs.lua), lets these people listen on this channel
	GetTalkers = function(ply) return tropasjedis[RPExtraTeams[ply:Team()].category] end, -- A lua function. Return true for a player to let them talk on this channel, return false to only let people in the Talkers table talk
	GetListeners = function(ply) return tropasjedis[RPExtraTeams[ply:Team()].category] end, -- A lua function. Return true for a player to let them listen on this channel, return false to only let people in the Listeners table listen
	Mutable = true, -- Should the player be able to mute this channel?
	Colour = Color(32, 85, 255) -- Channel header color
})

hradio.AddChannel({
	Name = "Civiles",
	Talkers = {}, -- List of TEAM_ identifiers (from your jobs.lua), lets these people talk on this channel
	Listeners = {}, -- List of TEAM_ identifiers (from your jobs.lua), lets these people listen on this channel
    GetTalkers = function(ply) return civiles[RPExtraTeams[ply:Team()].category] end, -- A lua function. Return true for a player to let them talk on this channel, return false to only let people in the Talkers table talk
    GetListeners = function(ply) return civiles[RPExtraTeams[ply:Team()].category] end, -- A lua function. Return true for a player to let them listen on this channel, return false to only let people in the Listeners table listen
	Mutable = true, -- Should the player be able to mute this channel?
	Colour = Color(255, 255, 255) -- Channel header color
})

hradio.AddChannel({
	Name = "Cazarrecompensas",
	Talkers = {TEAM_CAZARRECOMPENSAS}, -- List of TEAM_ identifiers (from your jobs.lua), lets these people talk on this channel
	Listeners = {TEAM_CAZARRECOMPENSAS}, -- List of TEAM_ identifiers (from your jobs.lua), lets these people listen on this channel
	GetTalkers = function(ply) return false end, -- A lua function. Return true for a player to let them talk on this channel, return false to only let people in the Talkers table talk
	GetListeners = function(ply) return false end, -- A lua function. Return true for a player to let them listen on this channel, return false to only let people in the Listeners table listen
	Mutable = true, -- Should the player be able to mute this channel?
	Colour = Color(255, 255, 255) -- Channel header color
})

hradio.AddChannel({
	Name = "Mandalorianos",
	Talkers = {TEAM_MANDALORIANO}, -- List of TEAM_ identifiers (from your jobs.lua), lets these people talk on this channel
	Listeners = {TEAM_MANDALORIANO}, -- List of TEAM_ identifiers (from your jobs.lua), lets these people listen on this channel
	GetTalkers = function(ply) return false end, -- A lua function. Return true for a player to let them talk on this channel, return false to only let people in the Talkers table talk
	GetListeners = function(ply) return false end, -- A lua function. Return true for a player to let them listen on this channel, return false to only let people in the Listeners table listen
	Mutable = true, -- Should the player be able to mute this channel?
	Colour = Color(255, 255, 255) -- Channel header color
})

hradio.AddChannel({
	Name = "Imperio Zygerriano",
	Talkers = {TEAM_SLDZYGERRIANO, TEAM_CPTZYGERRIANO, TEAM_JDCZYGERRIANA, TEAM_SENIORZYGERRIANO}, -- List of TEAM_ identifiers (from your jobs.lua), lets these people talk on this channel
	Listeners = {TEAM_SLDZYGERRIANO, TEAM_CPTZYGERRIANO, TEAM_JDCZYGERRIANA, TEAM_SENIORZYGERRIANO}, -- List of TEAM_ identifiers (from your jobs.lua), lets these people listen on this channel
	GetTalkers = function(ply) return false end, -- A lua function. Return true for a player to let them talk on this channel, return false to only let people in the Talkers table talk
	GetListeners = function(ply) return false end, -- A lua function. Return true for a player to let them listen on this channel, return false to only let people in the Listeners table listen
	Mutable = true, -- Should the player be able to mute this channel?
	Colour = Color(102, 0, 204) -- Channel header color
})

hradio.AddChannel({
	Name = "Admin",
	Talkers = {TEAM_ADMINONDUTY}, -- List of TEAM_ identifiers (from your jobs.lua), lets these people talk on this channel
	Listeners = {TEAM_ADMINONDUTY}, -- List of TEAM_ identifiers (from your jobs.lua), lets these people listen on this channel
	GetTalkers = function(ply) return false end, -- A lua function. Return true for a player to let them talk on this channel, return false to only let people in the Talkers table talk
	GetListeners = function(ply) return false end, -- A lua function. Return true for a player to let them listen on this channel, return false to only let people in the Listeners table listen
	Mutable = true, -- Should the player be able to mute this channel?
	Colour = Color(120, 0, 255) -- Channel header color
})