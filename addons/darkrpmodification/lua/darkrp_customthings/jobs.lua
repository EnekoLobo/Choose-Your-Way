--[[---------------------------------------------------------------------------
DarkRP custom jobs
---------------------------------------------------------------------------
This file contains your custom jobs.
This file should also contain jobs from DarkRP that you edited.

Note: If you want to edit a default DarkRP job, first disable it in darkrp_config/disabled_defaults.lua
      Once you've done that, copy and paste the job to this file and edit it.

The default jobs can be found here:
https://github.com/FPtje/DarkRP/blob/master/gamemode/config/jobrelated.lua

For examples and explanation please visit this wiki page:
https://darkrp.miraheze.org/wiki/DarkRP:CustomJobFields

Add your custom jobs under the following line:
---------------------------------------------------------------------------]]

TEAM_PORINSTRUIR = DarkRP.createJob("Por Instruir", {
    color = Color(155,155,155),
    model = "models/custom/playerstart_playermodel.mdl",
    description = [[Un jugador pendiente de ser instruido o sin job seleccionado.]],
    weapons = {},
    command = "porinstruir",
    max = 0,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Por Instruir",
    canDemote = false,
    PlayerSpawn = function(ply)
        ply:SetHealth(50)
        ply:SetMaxHealth(50)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64))
        ply:SetViewOffsetDucked(Vector(0,0,28))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36))
    end,
})

TEAM_INICIADOJEDI = DarkRP.createJob("Iniciado Jedi", {
    color = Color(32, 110, 255),
    model = {
    "models/player/jedi/female_chiss_padawan.mdl", 
    "models/player/jedi/female_human_padawan.mdl",
    "models/player/jedi/female_kaleesh_padawan.mdl",
    "models/player/jedi/female_keldoran_padawan.mdl",
    "models/player/jedi/female_pantoran_padawan.mdl",
    "models/player/jedi/female_rodian_padawan.mdl",
    "models/player/jedi/female_tholothian_padawan.mdl",
    "models/player/jedi/female_zabrak_padawan.mdl",
    "models/player/jedi/twilek_female_padawan.mdl",
    "models/player/jedi/male_chiss_padawan.mdl",
    "models/player/jedi/male_human_padawan.mdl",
    "models/player/jedi/male_kaleesh_padawan.mdl",
    "models/player/jedi/male_keldoran_padawan.mdl",
    "models/player/jedi/male_tholothian_padawan.mdl",
    "models/player/jedi/male_zabrak_padawan.mdl",
    "models/player/jedi/pantoran_male_padawan.mdl",
    "models/player/jedi/rodian_male_padawan.mdl",
    "models/player/jedi/twilek_padawan_male.mdl"
    },
    description = [[Un joven Iniciado en la Orden Jedi, con mucho camino por delante.]],
    weapons = {
        "keys",
        "bkeycard"
    },
    command = "iniciado",
    max = 0,
    salary = 10,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Orden Jedi",
    canDemote = false,
    sortOrder= 1,
    modelScale = 0.8,
    PlayerSpawn = function(ply)
        ply:SetHealth(100)
        ply:SetMaxHealth(100)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64 * 0.8))
        ply:SetViewOffsetDucked(Vector(0,0,28 * 0.8))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72 * 0.8))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36 * 0.8))
    end,
})

TEAM_PADAWANJEDI = DarkRP.createJob("Padawan Jedi", {
    color = Color(32, 110, 255),
    model = {
        "models/player/jedi/female_chiss_knight.mdl",
        "models/player/jedi/female_human_knight.mdl",
        "models/player/jedi/female_kaleesh_padawan.mdl",
        "models/player/jedi/female_keldoran_knight.mdl",
        "models/player/jedi/female_pantoran_knight.mdl",
        "models/player/jedi/female_rodian_knight.mdl",
        "models/player/jedi/female_tholothian_knight.mdl",
        "models/player/jedi/female_zabrak_knight.mdl",
        "models/player/jedi/twilek_female_knight.mdl",
        "models/player/jedi/male_chiss_knight.mdl",
        "models/player/jedi/male_human_knight.mdl",
        "models/player/jedi/male_kaleesh_knight.mdl",
        "models/player/jedi/male_keldoran_knight.mdl",
        "models/player/jedi/male_tholothian_knight.mdl",
        "models/player/jedi/male_zabrak_knight.mdl",
        "models/player/jedi/pantoran_male_knight.mdl",
        "models/player/jedi/rodian_male_knight.mdl",
        "models/player/jedi/twilek_knight_male.mdl"
    },
    description = [[Un joven Padawan en la Orden Jedi, ya puedes tener un Maestro Jedi.]],
    weapons = {
        "keys",
        
    },
    command = "padawan",
    max = 0,
    salary = 15,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Orden Jedi",
    canDemote = false,
    sortOrder= 2,
    modelScale = 0.9,
    PlayerSpawn = function(ply)
        ply:SetHealth(150)
        ply:SetMaxHealth(150)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64 * 0.9))
        ply:SetViewOffsetDucked(Vector(0,0,28 * 0.9))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72 * 0.9))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36 * 0.9))
    end,
})

TEAM_CABALLEROJEDI = DarkRP.createJob("Caballero Jedi", {
    color = Color(32, 110, 255),
    model = {
        "models/player/jedi/female_chiss_guardian.mdl",
        "models/player/jedi/female_human_guardian.mdl",
        "models/player/jedi/female_kaleesh_guardian.mdl",
        "models/player/jedi/female_keldoran_guardian.mdl",
        "models/player/jedi/female_pantoran_guardian.mdl",
        "models/player/jedi/female_rodian_guardian.mdl",
        "models/player/jedi/female_tholothian_guardian.mdl",
        "models/player/jedi/female_zabrak_guardian.mdl",
        "models/player/jedi/twilek_female_guardian.mdl",
        "models/player/jedi/male_chiss_guardian.mdl",
        "models/player/jedi/male_human_guardian.mdl",
        "models/player/jedi/male_kaleesh_guardian.mdl",
        "models/player/jedi/male_keldoran_guardian.mdl",
        "models/player/jedi/male_tholothian_guardian.mdl",
        "models/player/jedi/male_zabrak_guardian.mdl",
        "models/player/jedi/pantoran_male_guardian.mdl",
        "models/player/jedi/rodian_male_guardian.mdl",
        "models/player/jedi/twilek_guardian_male.mdl"
    },
    description = [[Un Caballero de la Orden Jedi, ya puedes tener un Padawan Jedi al cual enseñarle y puedes empezar con la senda de la especialización que prefieras.]],
    weapons = {
        "keys",
        "bkeycard",
        "weapon_r_handcuffs"
    },
    command = "caballero",
    max = 0,
    salary = 20,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Orden Jedi",
    canDemote = false,
    sortOrder= 3,
    modelScale = 1,
    PlayerSpawn = function(ply)
        ply:SetHealth(250)
        ply:SetMaxHealth(250)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64))
        ply:SetViewOffsetDucked(Vector(0,0,28))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36))
    end,
})

TEAM_GUARDIANJEDI = DarkRP.createJob("Guardián Jedi", {
    color = Color(32, 110, 255),
    model = {
        "models/player/jedi/female_chiss_sentinel.mdl",
        "models/player/jedi/female_human_sentinel.mdl",
        "models/player/jedi/female_kaleesh_sentinel.mdl",
        "models/player/jedi/female_keldoran_sentinel.mdl",
        "models/player/jedi/female_pantoran_sentinel.mdl",
        "models/player/jedi/female_rodian_sentinel.mdl",
        "models/player/jedi/female_tholothian_sentinel.mdl",
        "models/player/jedi/female_zabrak_sentinel.mdl",
        "models/player/jedi/twilek_female_sentinel.mdl",
        "models/player/jedi/male_chiss_sentinel.mdl",
        "models/player/jedi/male_human_sentinel.mdl",
        "models/player/jedi/male_kaleesh_sentinel.mdl",
        "models/player/jedi/male_keldoran_sentinel.mdl",
        "models/player/jedi/male_tholothian_sentinel.mdl",
        "models/player/jedi/male_zabrak_sentinel.mdl",
        "models/player/jedi/pantoran_male_sentinel.mdl",
        "models/player/jedi/rodian_male_sentinel.mdl",
        "models/player/jedi/twilek_sentinel_male.mdl"
    },
    description = [[Un Guardián de la Orden Jedi, especializado en el combate con sable laser.]],
    weapons = {
        "keys",
        "bkeycard",
        "weapon_r_handcuffs",
    },
    command = "guardian",
    max = 0,
    salary = 25,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Orden Jedi",
    canDemote = false,
    sortOrder= 4,
    modelScale = 1,
    PlayerSpawn = function(ply)
        ply:SetHealth(400)
        ply:SetMaxHealth(400)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64))
        ply:SetViewOffsetDucked(Vector(0,0,28))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36))
    end,
})

TEAM_CONSULJEDI = DarkRP.createJob("Cónsul Jedi", {
    color = Color(32, 110, 255),
    model = {
        "models/player/jedi/female_chiss_consular.mdl",
        "models/player/jedi/female_human_consular.mdl",
        "models/player/jedi/female_kaleesh_consular.mdl",
        "models/player/jedi/female_keldoran_consular.mdl",
        "models/player/jedi/female_pantoran_consular.mdl",
        "models/player/jedi/female_rodian_consular.mdl",
        "models/player/jedi/female_tholothian_consular.mdl",
        "models/player/jedi/female_zabrak_consular.mdl",
        "models/player/jedi/twilek_female_consular.mdl",
        "models/player/jedi/male_chiss_consular.mdl",
        "models/player/jedi/male_human_consular.mdl",
        "models/player/jedi/male_kaleesh_consular.mdl",
        "models/player/jedi/male_keldoran_consular.mdl",
        "models/player/jedi/male_tholothian_consular.mdl",
        "models/player/jedi/male_zabrak_consular.mdl",
        "models/player/jedi/pantoran_male_consular.mdl",
        "models/player/jedi/rodian_male_consular.mdl",
        "models/player/jedi/twilek_consular_male.mdl"
    },
    description = [[Un Consul de la Orden Jedi, especializado en el manejo de La Fuerza.]],
    weapons = {
        "keys",
        "bkeycard",
        "weapon_r_handcuffs"
    },
    command = "consul",
    max = 0,
    salary = 25,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Orden Jedi",
    canDemote = false,
    sortOrder= 5,
    modelScale = 1,
    PlayerSpawn = function(ply)
        ply:SetHealth(300)
        ply:SetMaxHealth(300)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64))
        ply:SetViewOffsetDucked(Vector(0,0,28))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36))
    end,
})

TEAM_CENTINELAJEDI = DarkRP.createJob("Centinela Jedi", {
    color = Color(32, 110, 255),
    model = {
    "models/kaioken/swtor_templeguard/female_swtor_temple_guard.mdl",
    "models/kaioken/swtor_templeguard/male_swtor_temple_guard.mdl"
    },
    description = [[Un Centinela de la Orden Jedi, especializado en la protección y seguridad.]],
    weapons = {
        "keys",
        "weapon_r_handcuffs",
        "stunstick",
        "bkeycard"
    },
    command = "centinela",
    max = 0,
    salary = 25,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Orden Jedi",
    canDemote = false,
    sortOrder= 6,
    modelScale = 1,
    PlayerSpawn = function(ply)
        ply:SetHealth(350)
        ply:SetMaxHealth(350)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64))
        ply:SetViewOffsetDucked(Vector(0,0,28))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36))
    end,
})

TEAM_MAESTROJEDI = DarkRP.createJob("Maestro Jedi", {
    color = Color(32, 110, 255),
    model = {
        "models/player/jedi/female_chiss_guardian.mdl",
        "models/player/jedi/female_human_guardian.mdl",
        "models/player/jedi/female_kaleesh_guardian.mdl",
        "models/player/jedi/female_keldoran_guardian.mdl",
        "models/player/jedi/female_pantoran_guardian.mdl",
        "models/player/jedi/female_rodian_guardian.mdl",
        "models/player/jedi/female_tholothian_guardian.mdl",
        "models/player/jedi/female_zabrak_guardian.mdl",
        "models/player/jedi/twilek_female_guardian.mdl",
        "models/player/jedi/male_chiss_guardian.mdl",
        "models/player/jedi/male_human_guardian.mdl",
        "models/player/jedi/male_kaleesh_guardian.mdl",
        "models/player/jedi/male_keldoran_guardian.mdl",
        "models/player/jedi/male_tholothian_guardian.mdl",
        "models/player/jedi/male_zabrak_guardian.mdl",
        "models/player/jedi/pantoran_male_guardian.mdl",
        "models/player/jedi/rodian_male_guardian.mdl",
        "models/player/jedi/twilek_guardian_male.mdl"
    },
    description = [[Un Maestro de la Orden Jedi, el máximo rango que hay en la Orden Jedi.]],
    weapons = {
        "keys",
        "bkeycard",
        "weapon_r_handcuffs"
    },
    command = "maestro",
    max = 0,
    salary = 30,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Orden Jedi",
    canDemote = false,
    sortOrder= 8,
    modelScale = 1,
    PlayerSpawn = function(ply)
        ply:SetHealth(500)
        ply:SetMaxHealth(500)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64))
        ply:SetViewOffsetDucked(Vector(0,0,28))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36))
    end,
})

TEAM_GRANMAESTRONEVERLANDER = DarkRP.createJob("Gran Maestro Neverlander", {
    color = Color(0, 185, 255),
    model = {
        "models/player/swtor/arsenic/gadol/jedigado.mdl"
    },
    description = [[Eres el Gran Maestro Neverlander.  (VIP)]],
    weapons = {
        "keys",
        "bkeycard"
    },
    command = "neverlander",
    max = 1,
    salary = 30,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Especial",
    canDemote = false,
    sortOrder= 3,
    modelScale = 1,
    PlayerSpawn = function(ply)
        ply:SetHealth(550)
        ply:SetMaxHealth(550)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64))
        ply:SetViewOffsetDucked(Vector(0,0,28))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36))
    end,
})

TEAM_REUS = DarkRP.createJob("Umbra", {
    color = Color(0, 185, 255),
    model = {
        "models/banks/marauder/eg/egmarauder.mdl"
    },
    description = [[Eres el Gran Maestro Neverlander.  (VIP)]],
    weapons = {
        "keys",
    },
    command = "reus",
    max = 1,
    salary = 30,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Especial",
    canDemote = false,
    sortOrder= 3,
    modelScale = 1,
    PlayerSpawn = function(ply)
        ply:SetHealth(550)
        ply:SetMaxHealth(550)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64))
        ply:SetViewOffsetDucked(Vector(0,0,28))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36))
    end,
})


TEAM_IRIONDORPRIME = DarkRP.createJob("Irindor Prime", {
    color = Color(255, 66, 0),
    model = {
        "models/jajoff/sps/sw/kraken2.mdl"
    },
    description = [[Eres Irindor Prime.  (VIP)]],
    weapons = {
        "keys",
    },
    command = "irindorprime",
    max = 1,
    salary = 30,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Especial",
    canDemote = false,
    sortOrder= 4,
    modelScale = 1,
    PlayerSpawn = function(ply)
        ply:SetHealth(550)
        ply:SetMaxHealth(550)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64))
        ply:SetViewOffsetDucked(Vector(0,0,28))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36))
    end,
})

TEAM_MAESTROXIVSIXER = DarkRP.createJob("Maestro Luky Sylvasta", {
    color = Color(162, 215, 244),
    model = {
        "models/player/swtor/arsenic/zeus/zeus.mdl"
    },
    description = [[Eres el Maestro Luky Sylvasta.  (VIP)  ]],
    weapons = {
        "keys",
        "bkeycard"
    },
    command = "xixi",
    max = 1,
    salary = 30,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Especial",
    canDemote = false,
    sortOrder= 2,
    modelScale = 1,
    PlayerSpawn = function(ply)
        ply:SetHealth(300)
        ply:SetMaxHealth(500)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64))
        ply:SetViewOffsetDucked(Vector(0,0,28))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36))
    end,
})

TEAM_MAESTROXIVSIXER2 = DarkRP.createJob("Maestra Hextar", {
    color = Color(234, 168, 255),
    model = {
        "models/rinyata/meredith/meredithwage.mdl"
    },
    description = [[Eres el Maestro Cónsul Xiv Si'xer.]],
    weapons = {
        "keys",
        "bkeycard"
    },
    command = "hextar",
    max = 1,
    salary = 30,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Especial",
    canDemote = false,
    sortOrder= 1,
    modelScale = 0.92,
    PlayerSpawn = function(ply)
        ply:SetHealth(500)
        ply:SetMaxHealth(500)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64))
        ply:SetViewOffsetDucked(Vector(0,0,28))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36))
    end,
})

TEAM_JEDITROOPER1 = DarkRP.createJob("Soldado de la República: Jet", {
    color = Color(255, 255, 255),
    model = {"models/kurator/swtor/player/havoc_squad/havoc_jet_trooper.mdl", "models/jajoff/sps/republic/tc13j/rsb03.mdl",
     "models/jajoff/sps/republic/tc13j/rsb03_female.mdl"},
    description = [[
        Eres un miembro de la República, con rango "Soldado" de la compañia "Aerea".
    ]],
    weapons = {"comlink_swep", "weapon_r_handcuffs", "jet_mk5", "rw_sw_stun_dc17", "rw_sw_dc15s", "stunstick", "salute_swep", "bkeycard"},
    command = "81sttropa",
    max = 0,
    salary = 15,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Tropas Jedi",    
    canDemote = false,
    sortOrder= 1,
    PlayerSpawn = function(ply)
        ply:SetHealth(150)
        ply:SetMaxHealth(150)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64))
        ply:SetViewOffsetDucked(Vector(0,0,28))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36))
    end,
})

TEAM_JEDITROOPER7 = DarkRP.createJob("Soldado de la República: Recon", {
    color = Color(255, 255, 255),
    model = {"models/kurator/swtor/player/havoc_squad/havoc_specialist_trooper.mdl", "models/jajoff/sps/republic/tc13j/rsb03.mdl",
    "models/jajoff/sps/republic/tc13j/rsb03_female.mdl"},
    description = [[
        Eres un miembro de la República, con rango "Soldado" de la compañia de "Reconocimiento".
    ]],
    weapons = {"comlink_swep", "weapon_r_handcuffs", "rw_sw_stun_dc17", "rw_sw_dc15x", "realistic_hook", "stunstick", "salute_swep", "bkeycard"},
    command = "reconocimientorep",
    max = 0,
    salary = 15,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Tropas Jedi",    
    canDemote = false,
    sortOrder= 7,
    PlayerSpawn = function(ply)
        ply:SetHealth(150)
        ply:SetMaxHealth(150)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64))
        ply:SetViewOffsetDucked(Vector(0,0,28))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36))
    end,
})

TEAM_JEDITROOPER8 = DarkRP.createJob("Soldado de la República: Espia", {
    color = Color(255, 255, 255),
    model = {"models/kurator/swtor/player/havoc_squad/havoc_spy_trooper.mdl", "models/jajoff/sps/republic/tc13j/rsb03.mdl",
    "models/jajoff/sps/republic/tc13j/rsb03_female.mdl"},
    description = [[
        Eres un miembro de la República, con rango "Soldado" de la compañia de "Espionaje".
    ]],
    weapons = {"comlink_swep", "weapon_r_handcuffs", "rw_sw_stun_dc17", "rw_sw_dc19", "stunstick", "salute_swep", "bkeycard"},
    command = "espiarep",
    max = 0,
    salary = 15,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Tropas Jedi",    
    canDemote = false,
    sortOrder= 8,
    PlayerSpawn = function(ply)
        ply:SetHealth(150)
        ply:SetMaxHealth(150)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64))
        ply:SetViewOffsetDucked(Vector(0,0,28))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36))
    end,
})

TEAM_JEDITROOPER2 = DarkRP.createJob("Soldado de la República: Pesado", {
    color = Color(255, 255, 255),
    model = {"models/kurator/swtor/player/havoc_squad/havoc_heavy_trooper.mdl", "models/jajoff/sps/republic/tc13j/rsb03.mdl",
    "models/jajoff/sps/republic/tc13j/rsb03_female.mdl"},
    description = [[
        Eres un miembro de la República, con rango "Soldado" de la compañia de "Pesados".
    ]],
    weapons = {"comlink_swep", "weapon_r_handcuffs", "rw_sw_z6", "rw_sw_stun_dc17", "stunstick", "salute_swep", "bkeycard"},
    command = "81stoficial",
    max = 0,
    salary = 30,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Tropas Jedi",    
    canDemote = false,
    sortOrder= 2,
    PlayerSpawn = function(ply)
        ply:SetHealth(150)
        ply:SetMaxHealth(150)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64))
        ply:SetViewOffsetDucked(Vector(0,0,28))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36))
    end,
})

TEAM_JEDITROOPER3 = DarkRP.createJob("Soldado de la República: Piloto", {
    color = Color(255, 255, 255),
    model = {"models/kurator/swtor/player/havoc_squad/havoc_gunner_trooper.mdl", "models/jajoff/sps/republic/tc13j/rsb03.mdl",
    "models/jajoff/sps/republic/tc13j/rsb03_female.mdl"},
    description = [[
        Eres un miembro de la República, con rango "Soldado" de la compañia de "Pilotaje".
    ]],
    weapons = {"comlink_swep", "weapon_r_handcuffs", "alydus_fusioncutter", "rw_sw_dc15s", "rw_sw_stun_dc17", "stunstick", "salute_swep", "bkeycard"},
    command = "havoctropa",
    max = 0,
    salary = 15,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Tropas Jedi",    
    canDemote = false,
    sortOrder= 3,
    PlayerSpawn = function(ply)
        ply:SetHealth(150)
        ply:SetMaxHealth(150)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64))
        ply:SetViewOffsetDucked(Vector(0,0,28))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36))
    end,
})

TEAM_JEDITROOPER4 = DarkRP.createJob("Soldado de la República: Medica", {
    color = Color(255, 255, 255),
    model = {"models/kurator/swtor/player/havoc_squad/havoc_assault_trooper.mdl", "models/jajoff/sps/republic/tc13j/rsb03.mdl",
    "models/jajoff/sps/republic/tc13j/rsb03_female.mdl"},
    description = [[
        Eres un miembro de la República, con rango "Soldado" de la compañia "Medica".
    ]],
    weapons = {"comlink_swep", "weapon_r_handcuffs", "rw_sw_nade_bacta", "weapon_defibrillator", "rw_sw_stun_dc17", "rw_sw_dc15a", "stunstick", "salute_swep", "weapon_bactainjector", "weapon_bactanade", "bkeycard"},
    command = "havocoficial",
    max = 0,
    salary = 30,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Tropas Jedi",    
    canDemote = false,
    sortOrder= 4,
    PlayerSpawn = function(ply)
        ply:SetHealth(150)
        ply:SetMaxHealth(150)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64))
        ply:SetViewOffsetDucked(Vector(0,0,28))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36))
    end,
})

TEAM_JEDITROOPER5 = DarkRP.createJob("Soldado de la República", {
    color = Color(255, 255, 255),
    model = {"models/kurator/swtor/player/havoc_squad/havoc_assault_trooper.mdl", "models/jajoff/sps/republic/tc13j/rsb03.mdl",
    "models/jajoff/sps/republic/tc13j/rsb03_female.mdl"},
    description = [[
        Eres un miembro de la República, con rango "Soldado"
    ]],
    weapons = {"comlink_swep", "weapon_r_handcuffs", "rw_sw_stun_dc17", "rw_sw_dc15a", "stunstick", "salute_swep", "bkeycard"},
    command = "republicasoldado",
    max = 0,
    salary = 15,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Tropas Jedi",    
    canDemote = false,
    sortOrder= 5,
    PlayerSpawn = function(ply)
        ply:SetHealth(150)
        ply:SetMaxHealth(150)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64))
        ply:SetViewOffsetDucked(Vector(0,0,28))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36))
    end,
})


TEAM_JEDITROOPER6 = DarkRP.createJob("Oficial de la República", {
    color = Color(255, 255, 255),
    model = {"models/kurator/swtor/player/havoc_squad/havoc_officer_trooper.mdl", "models/jajoff/sps/republic/tc13j/navy_03.mdl"},
    description = [[
        Eres un miembro de la República, con rango "Oficial"
    ]],
    weapons = {"comlink_swep", "weapon_r_handcuffs", "rw_sw_stun_dc17", "rw_sw_dc15a", "stunstick", "salute_swep", "bkeycard"},
    command = "republicaoficial",
    max = 0,
    salary = 30,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Tropas Jedi",    
    canDemote = false,
    sortOrder= 6,
    PlayerSpawn = function(ply)
        ply:SetHealth(150)
        ply:SetMaxHealth(150)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64))
        ply:SetViewOffsetDucked(Vector(0,0,28))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36))
    end,
})

TEAM_CIVIL = DarkRP.createJob("Civil", {
    color = Color(255, 255, 255),
    model = {
        "models/assassin/pm_civ_assassin_human_female.mdl",
        "models/assassin/pm_civ_assassin_human_male.mdl",
        "models/bandit/pm_civ_bandit_human_female.mdl",
        "models/bandit/pm_civ_bandit_human_male.mdl",
        "models/dweller/pm_civ_dweller_human_female.mdl",
        "models/dweller/pm_civ_dweller_human_male.mdl",
        "models/formal/pm_civ_formal_human_female.mdl",
        "models/formal/pm_civ_formal_human_male.mdl",
        "models/merc/pm_civ_merc_human_male.mdl",
        "models/merc/pm_civ_merc_human_female.mdl",
        "models/noble/pm_civ_noble_human_female.mdl",
        "models/noble/pm_civ_noble_human_male.mdl",
        "models/renegade/pm_civ_renegade_human_male.mdl",
        "models/renegade/pm_civ_renegade_human_female.mdl",
    },
    description = [[
        Eres un civil.
    ]],
    weapons = {"weapon_fists"},
    command = "civil",
    max = 0,
    salary = 10,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Civiles",    
    canDemote = false,
    sortOrder= 1,
    modelScale = 1,
    PlayerSpawn = function(ply)
        ply:SetHealth(150)
        ply:SetMaxHealth(150)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64))
        ply:SetViewOffsetDucked(Vector(0,0,28))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36))
    end,
})

TEAM_DROIDE1 = DarkRP.createJob("Astromecanico", {
    color = Color(255, 255, 255),
    model = {
        "models/t3_droids/3cfd/3cfd.mdl",
        "models/t3_droids/g3sp/g3sp.mdl",
        "models/t3_droids/t3c4/t3c4.mdl",
        "models/t3_droids/t3d6/t3d6.mdl",
        "models/t3_droids/t3d3/t3d3.mdl",
        "models/t3_droids/t3f2/t3f2.mdl",
        "models/t3_droids/t3h3/t3h3.mdl",
        "models/t3_droids/t3h8/t3h8.mdl",
        "models/t3_droids/t3kt/t3kt.mdl",
        "models/t3_droids/t3lp/t3lp.mdl",
        "models/t3_droids/t3m3/t3m3.mdl",
        "models/t3_droids/t3m4/t3m4.mdl",
        "models/t3_droids/t3m5/t3m5.mdl",
        "models/t3_droids/t3qt/t3qt.mdl",
        "models/t3_droids/t3rd/t3rd.mdl"
    },
    description = [[
        Eres un Astromecanico.
    ]],
    weapons = {"weapon_fists", "pack_swswep_r2d2", "pack_swswep_bb8", "t3m4", "shockarm_3cfd"},
    command = "astromech",
    max = 0,
    salary = 10,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Civiles",    
    canDemote = false,
    sortOrder= 1,
    modelScale = 1,
    PlayerSpawn = function(ply)
        ply:SetHealth(150)
        ply:SetMaxHealth(150)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64))
        ply:SetViewOffsetDucked(Vector(0,0,28))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36))
    end,
})

TEAM_DROIDE2 = DarkRP.createJob("Droides", {
    color = Color(255, 255, 255),
    model = {
        "models/player/swtor/droids/worker_droid.mdl",
        "models/player/swtor/droids/welder_droid.mdl",
        "models/player/swtor/droids/bodyguard_droid.mdl"
    },
    description = [[
        Eres un Droide.
    ]],
    weapons = {"weapon_fists"},
    command = "astromech2",
    max = 0,
    salary = 10,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Civiles",    
    canDemote = false,
    sortOrder= 1,
    modelScale = 1,
    PlayerSpawn = function(ply)
        ply:SetHealth(150)
        ply:SetMaxHealth(150)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64))
        ply:SetViewOffsetDucked(Vector(0,0,28))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36))
    end,
})

TEAM_DROIDE3 = DarkRP.createJob("Droide de Entrenamiento Jedi", {
    color = Color(255, 255, 255),
    model = {
        "models/player/cheddar/droids/lightsaber_training_droid.mdl"
    },
    description = [[
        Eres un Droide.
    ]],
    weapons = {"weapon_fists", "weapon_training_saber"},
    command = "astromech3",
    max = 0,
    salary = 10,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Orden Jedi",    
    canDemote = false,
    sortOrder= 1,
    modelScale = 1,
    PlayerSpawn = function(ply)
        ply:SetHealth(150)
        ply:SetMaxHealth(150)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64))
        ply:SetViewOffsetDucked(Vector(0,0,28))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36))
    end,
})

TEAM_DROIDE3 = DarkRP.createJob("Droide de Sonda", {
    color = Color(255, 255, 255),
    model = {
        "models/niksacokica/items/excavation_seeker_droid_03.mdl",
        "models/niksacokica/items/excavation_seeker_droid_02.mdl",
        "models/niksacokica/items/excavation_seeker_droid_01_top.mdl"
    },
    description = [[
        Eres un Droide.
    ]],
    weapons = {"weapon_fists", "jet_mk4"},
    command = "astromech4",
    max = 0,
    salary = 10,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Civiles",    
    canDemote = false,
    sortOrder= 1,
    modelScale = 1,
    PlayerSpawn = function(ply)
        ply:SetHealth(150)
        ply:SetMaxHealth(150)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64))
        ply:SetViewOffsetDucked(Vector(0,0,28))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36))
    end,
})

TEAM_REPREPUBLICA = DarkRP.createJob("Representante de la República", {
    color = Color(255, 255, 255),
    model = {
        "models/player/bombur/1unbekannte_person_egm_03.mdl",
        "models/player/bombur/10unbekannte_person_egm_03.mdl",
        "models/player/bombur/11unbekannte_person_egm_03.mdl",
        "models/player/bombur/12unbekannte_person_egm_03.mdl",
        "models/player/bombur/14unbekannte_person_egm_03.mdl",
        "models/player/bombur/2unbekannte_person_egm_03.mdl",
        "models/player/bombur/4unbekannte_person_egm_03.mdl",
        "models/player/bombur/5unbekannte_person_egm_03.mdl",
        "models/player/bombur/6unbekannte_person_egm_03.mdl",
        "models/player/bombur/7unbekannte_person_egm_03.mdl",
        "models/player/bombur/8unbekannte_person_egm_03.mdl",
        "models/player/bombur/9unbekannte_person_egm_03.mdl",
        "models/player/bombur/1Togruta-carthonasi.mdl",
        "models/player/bombur/Togruta-TheronShan.mdl"
    },
    description = [[
        Eres un civil que representa a la República.
    ]],
    weapons = {"weapon_fists", "bkeycard"},
    command = "representanterepublica",
    max = 0,
    salary = 15,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Civiles",    
    canDemote = false,
    sortOrder= 2,
    modelScale = 1,
    PlayerSpawn = function(ply)
        ply:SetHealth(150)
        ply:SetMaxHealth(150)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64))
        ply:SetViewOffsetDucked(Vector(0,0,28))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36))
    end,
})

TEAM_REPIMPERIO = DarkRP.createJob("Representante del Imperio", {
    color = Color(255, 255, 255),
    model = {
        "models/player/bombur/1unbekannte_person_egm_03.mdl",
        "models/player/bombur/10unbekannte_person_egm_03.mdl",
        "models/player/bombur/11unbekannte_person_egm_03.mdl",
        "models/player/bombur/12unbekannte_person_egm_03.mdl",
        "models/player/bombur/14unbekannte_person_egm_03.mdl",
        "models/player/bombur/2unbekannte_person_egm_03.mdl",
        "models/player/bombur/4unbekannte_person_egm_03.mdl",
        "models/player/bombur/5unbekannte_person_egm_03.mdl",
        "models/player/bombur/6unbekannte_person_egm_03.mdl",
        "models/player/bombur/7unbekannte_person_egm_03.mdl",
        "models/player/bombur/8unbekannte_person_egm_03.mdl",
        "models/player/bombur/9unbekannte_person_egm_03.mdl",
        "models/player/bombur/1Togruta-carthonasi.mdl",
        "models/player/bombur/Togruta-TheronShan.mdl"
    },
    description = [[
        Eres un civil que representa al Imperio.
    ]],
    weapons = {"weapon_fists", "bkeycard"},
    command = "representanteimperio",
    max = 0,
    salary = 15,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Civiles",    
    canDemote = false,
    sortOrder= 3,
    modelScale = 1,
    PlayerSpawn = function(ply)
        ply:SetHealth(150)
        ply:SetMaxHealth(150)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64))
        ply:SetViewOffsetDucked(Vector(0,0,28))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36))
    end,
})

TEAM_POLICIALOCAL = DarkRP.createJob("Policía Local", {
    color = Color(255, 255, 255),
    model = {
        "models/player/bombur/wintercombatarmormalepm.mdl",
        "models/player/bombur/1wintercombatarmormalepm.mdl",
        "models/player/bombur/2wintercombatarmormalepm.mdl",
        "models/player/bombur/3wintercombatarmormalepm.mdl",
        "models/player/bombur/4wintercombatarmormalepm.mdl",
        "models/player/bombur/7wintercombatarmormalepm.mdl",
        "models/player/bombur/wintercombatarmorfemalepm.mdl",
        "models/player/bombur/1wintercombatarmorfemalepm.mdl",
        "models/player/bombur/2wintercombatarmorfemalepm.mdl",
        "models/player/bombur/3wintercombatarmorfemalepm.mdl",
    },
    description = [[
        Eres un policía local. Te encargas de la seguridad y el bienestar.
    ]],
    weapons = {"tfa_spas_swtor_smugglerpistol", "weapon_r_handcuffs", "salute_swep", "stunstick", "weapon_bactainjector", "bkeycard"},
    command = "policialocal",
    max = 0,
    salary = 25,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Civiles",    
    canDemote = false,
    sortOrder= 4,
    modelScale = 1,
    PlayerSpawn = function(ply)
        ply:SetHealth(250)
        ply:SetMaxHealth(250)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64))
        ply:SetViewOffsetDucked(Vector(0,0,28))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36))
    end,
})

TEAM_ALCALDE = DarkRP.createJob("Alcalde", {
    color = Color(255, 255, 255),
    model = {
        "models/player/bombur/1unbekannte_person_egm_03.mdl",
        "models/player/bombur/10unbekannte_person_egm_03.mdl",
        "models/player/bombur/11unbekannte_person_egm_03.mdl",
        "models/player/bombur/12unbekannte_person_egm_03.mdl",
        "models/player/bombur/14unbekannte_person_egm_03.mdl",
        "models/player/bombur/2unbekannte_person_egm_03.mdl",
        "models/player/bombur/4unbekannte_person_egm_03.mdl",
        "models/player/bombur/5unbekannte_person_egm_03.mdl",
        "models/player/bombur/6unbekannte_person_egm_03.mdl",
        "models/player/bombur/7unbekannte_person_egm_03.mdl",
        "models/player/bombur/8unbekannte_person_egm_03.mdl",
        "models/player/bombur/9unbekannte_person_egm_03.mdl",
        "models/player/bombur/1Togruta-carthonasi.mdl",
        "models/player/bombur/Togruta-TheronShan.mdl"
    },
    description = [[
        Eres el alcalde.
    ]],
    weapons = {"weapon_fists", "bkeycard"},
    command = "alcalde",
    max = 1,
    salary = 35,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Civiles",    
    canDemote = false,
    sortOrder= 5,
    modelScale = 1,
    PlayerSpawn = function(ply)
        ply:SetHealth(200)
        ply:SetMaxHealth(200)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64))
        ply:SetViewOffsetDucked(Vector(0,0,28))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36))
    end,
})

TEAM_FUNCIONARIO = DarkRP.createJob("Funcionario", {
    color = Color(255, 255, 255),
    model = {
        "models/player/bombur/1unbekannte_person_egm_03.mdl",
        "models/player/bombur/10unbekannte_person_egm_03.mdl",
        "models/player/bombur/11unbekannte_person_egm_03.mdl",
        "models/player/bombur/12unbekannte_person_egm_03.mdl",
        "models/player/bombur/14unbekannte_person_egm_03.mdl",
        "models/player/bombur/2unbekannte_person_egm_03.mdl",
        "models/player/bombur/4unbekannte_person_egm_03.mdl",
        "models/player/bombur/5unbekannte_person_egm_03.mdl",
        "models/player/bombur/6unbekannte_person_egm_03.mdl",
        "models/player/bombur/7unbekannte_person_egm_03.mdl",
        "models/player/bombur/8unbekannte_person_egm_03.mdl",
        "models/player/bombur/9unbekannte_person_egm_03.mdl",
        "models/player/bombur/1Togruta-carthonasi.mdl",
        "models/player/bombur/Togruta-TheronShan.mdl"
    },
    description = [[
        Eres un funcionario.
    ]],
    weapons = {"weapon_fists", "bkeycard"},
    command = "funcionario",
    max = 0,
    salary = 30,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Civiles",    
    canDemote = false,
    sortOrder= 6,
    modelScale = 1,
    PlayerSpawn = function(ply)
        ply:SetHealth(175)
        ply:SetMaxHealth(175)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64))
        ply:SetViewOffsetDucked(Vector(0,0,28))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36))
    end,
})

TEAM_CAZARRECOMPENSAS = DarkRP.createJob("Cazarrecompensas", {
    color = Color(255, 255, 255),
    model = {
        "models/player/swtor/arsenic/mandoservers/anzati.mdl",
        "models/player/swtor/arsenic/mandoservers/arsenic.mdl",
        "models/player/swtor/arsenic/mandoservers/arsenic2.mdl",
        "models/player/swtor/arsenic/mandoservers/commandervizla.mdl",
        "models/player/swtor/arsenic/mandoservers/hetakol.mdl",
        "models/player/swtor/arsenic/mandoservers/mandalorianclansmen.mdl",
        "models/player/swtor/arsenic/mandoservers/mandaloriantracker.mdl",
        "models/player/swtor/arsenic/mandoservers/medic.mdl",
        "models/player/swtor/arsenic/mandoservers/mercilessseeker.mdl",
        "models/player/swtor/arsenic/mandoservers/relicplunderer.mdl",
        "models/player/swtor/arsenic/mandoservers/shaevizla.mdl",
        "models/player/swtor/arsenic/mandoservers/vilehunter.mdl",
        "models/player/swtor/arsenic/mandoservers/wastelandraider.mdl",
        "models/clutch/pm_trandoshan_clutch.mdl",
        "models/dar/pm_trandoshan_dar.mdl",
        "models/garnac/pm_trandoshan_garnac.mdl",
        "models/hunter/pm_trandoshan_hunter.mdl",
        "models/lotaren/pm_trandoshan_lotaren.mdl",
        "models/sniper/pm_trandoshan_sniper.mdl",
        "models/sochek/pm_trandoshan_sochek.mdl",
        "models/sochek/pm_trandoshan_sochek.mdl",
        "models/trapper/pm_trandoshan_trapper.mdl",
    },
    description = [[
        Eres un cazarrecompensas.
    ]],
    weapons = {"rw_sw_umb1", "weapon_r_handcuffs", "realistic_hook", "bkeycard"},
    command = "cazarrecompensas",
    max = 15,
    salary = 10,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Civiles",    
    canDemote = false,
    sortOrder= 7,
    modelScale = 1,
    PlayerSpawn = function(ply)
        ply:SetHealth(275)
        ply:SetMaxHealth(275)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64))
        ply:SetViewOffsetDucked(Vector(0,0,28))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36))
    end,
})

TEAM_MANDALORIANO = DarkRP.createJob("Mandaloriano", {
    color = Color(255, 255, 255),
    model = {
        "models/player/swtor/arsenic/mandoservers/cassusfett.mdl",
        "models/player/swtor/arsenic/mandoservers/charismaticmandalorian.mdl",
        "models/player/swtor/arsenic/mandoservers/forgemaster.mdl",
        "models/player/swtor/arsenic/mandoservers/infamousbountyhunter.mdl",
        "models/player/swtor/arsenic/mandoservers/mandalorethepreserver.mdl",
        "models/player/swtor/arsenic/mandoservers/mandalorianhunter.mdl",
        "models/player/swtor/arsenic/mandoservers/mandalorianseeker.mdl",
        "models/player/swtor/arsenic/mandoservers/mandalorianstormbringer.mdl",
        "models/player/swtor/arsenic/mandoservers/rassordo.mdl",
        "models/player/swtor/arsenic/mandoservers/rohlandyre.mdl",
    },
    description = [[
        Eres un mandaloriano.
    ]],
    weapons = {"rw_sw_westar11", "tfa_spas_swtor_mandopistol", "weapon_r_handcuffs", "realistic_hook", "bkeycard"},
    command = "mandaloriano",
    max = 15,
    salary = 10,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Civiles",    
    canDemote = false,
    sortOrder= 8,
    modelScale = 1,
    PlayerSpawn = function(ply)
        ply:SetHealth(300)
        ply:SetMaxHealth(300)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64))
        ply:SetViewOffsetDucked(Vector(0,0,28))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36))
    end,
})

TEAM_WOOKIE = DarkRP.createJob("Wookie", {
    color = Color(255, 255, 255),
    model = "models/tfa/comm/gg/pm_sw_chewbacca.mdl",
    description = [[
        Eres un Wookie.
    ]],
    weapons = {"weapon_fists", "pack_swswep_chewie"},
    command = "wookie",
    max = 15,
    salary = 15,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Civiles",    
    canDemote = false,
    sortOrder= 9,
    modelScale = 1.1,
    PlayerSpawn = function(ply)
        ply:SetHealth(300)
        ply:SetMaxHealth(300)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64 * 1.1))
        ply:SetViewOffsetDucked(Vector(0,0,28 * 1.1))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72 * 1.1))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36 * 1.1))
    end,
})

TEAM_JAWA = DarkRP.createJob("Jawa", {
    color = Color(255, 255, 255),
    model = "models/jajoff/sw/jawacustom.mdl",
    description = [[
        Eres un Jawa, chatarrero de la cuna a la tumba.
    ]],
    weapons = {"alydus_fusioncutter", "weapon_fists", "pack_swswep_jawa", "bkeycard"},
    command = "jawa",
    max = 15,
    salary = 5,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Civiles",    
    canDemote = false,
    sortOrder= 10,
    modelScale = 0.7,
    PlayerSpawn = function(ply)
        ply:SetHealth(150)
        ply:SetMaxHealth(150)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,44.8))
        ply:SetViewOffsetDucked(Vector(0,0,19.6))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72 * 0.7))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36 * 0.7))
    end,
})

TEAM_ESCLAVO = DarkRP.createJob("Esclavo Twi'lek", {
    color = Color(152,0,254),
    model = {
        "models/player/slave/twilek_slave_male.mdl",
    },
    description = [[Un esclavo Twi'lek, bajo el yugo del Imperio Zygerriano.]],
    weapons = {"pickaxe", "bkeycard"},
    command = "esclavotwilek",
    max = 0,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Imperio Esclavista Zygerriano",
    canDemote = false,
    sortOrder= 1,
    modelScale = 1,
    PlayerSpawn = function(ply)
        ply:SetHealth(125)
        ply:SetMaxHealth(125)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64))
        ply:SetViewOffsetDucked(Vector(0,0,28))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36))
    end,
})

TEAM_ESCLAVA = DarkRP.createJob("Esclava Twi'lek", {
    color = Color(152,0,254),
    model = {
        "models/player/slave/twilek_slave_female_dancer.mdl",
    },
    description = [[Una esclava Twi'lek, bajo el yugo del Imperio Zygerriano.]],
    weapons = {"bkeycard"},
    command = "esclavatwilek",
    max = 0,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Imperio Esclavista Zygerriano",
    canDemote = false,
    sortOrder= 2,
    modelScale = 1,
    PlayerSpawn = function(ply)
        ply:SetHealth(125)
        ply:SetMaxHealth(125)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64 * 0.9))
        ply:SetViewOffsetDucked(Vector(0,0,28 * 0.9))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72 * 0.9))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36 * 0.9))
    end,
})

TEAM_SLDZYGERRIANO = DarkRP.createJob("Soldado Zygerriano", {
    color = Color(102,0,204),
    model = {
        "models/player/zygerrian/zygerrian_soldier.mdl"
    },
    description = [[Un soldado esclavista Zygerriano.]],
    weapons = {"weapon_r_handcuffs", "stunstick", "tfa_spas_swtor_impcarbine", "bkeycard"},
    command = "soldadozygerriano",
    max = 0,
    salary = 15,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Imperio Esclavista Zygerriano",
    canDemote = false,
    sortOrder= 3,
    modelScale = 1,
    PlayerSpawn = function(ply)
        ply:SetHealth(150)
        ply:SetMaxHealth(150)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64))
        ply:SetViewOffsetDucked(Vector(0,0,28))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36))
    end,
})

TEAM_CPTZYGERRIANO = DarkRP.createJob("Capitán Zygerriano", {
    color = Color(102,0,204),
    model = {
        "models/player/zygerrian/zygerrian_cpt.mdl"
    },
    description = [[Un capitán esclavista Zygerriano.]],
    weapons = {"weapon_r_handcuffs", "stunstick", "tfa_spas_swtor_impcarbine", "bkeycard"},
    command = "capitanzygerriano",
    max = 0,
    salary = 25,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Imperio Esclavista Zygerriano",
    canDemote = false,
    sortOrder= 4,
    modelScale = 1,
    PlayerSpawn = function(ply)
        ply:SetHealth(175)
        ply:SetMaxHealth(175)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64))
        ply:SetViewOffsetDucked(Vector(0,0,28))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36))
    end,
})

TEAM_JDCZYGERRIANA = DarkRP.createJob("Jefa de Campo Zygerriana", {
    color = Color(102,0,204),
    model = {
        "models/player/zygerrian/zygerrian_pitboss.mdl"
    },
    description = [[Una Jefa de Campo esclavista Zygerriana.]],
    weapons = {"weapon_r_handcuffs", "stunstick", "tfa_spas_swtor_impcarbine", "bkeycard"},
    command = "jefazygerriana",
    max = 0,
    salary = 30,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Imperio Esclavista Zygerriano",
    canDemote = false,
    sortOrder= 5,
    modelScale = 1,
    PlayerSpawn = function(ply)
        ply:SetHealth(200)
        ply:SetMaxHealth(200)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64 * 0.9))
        ply:SetViewOffsetDucked(Vector(0,0,28 * 0.9))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72 * 0.9))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36 * 0.9))
    end,
})

TEAM_SENIORZYGERRIANO = DarkRP.createJob("Señor Zygerriano", {
    color = Color(102,0,204),
    model = {
        "models/player/zygerrian/zygerrian_slave_lord.mdl"
    },
    description = [[El Señor Zygerriano, líder total y absoluto del Imperio Esclavista Zygerriano.]],
    weapons = {"weapon_r_handcuffs", "stunstick", "tfa_spas_swtor_impcarbine", "bkeycard"},
    command = "seniorzygerriano",
    max = 0,
    salary = 35,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Imperio Esclavista Zygerriano",
    canDemote = false,
    sortOrder= 6,
    modelScale = 1,
    PlayerSpawn = function(ply)
        ply:SetHealth(250)
        ply:SetMaxHealth(250)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64))
        ply:SetViewOffsetDucked(Vector(0,0,28))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36))
    end,
})

TEAM_ADMINONDUTY = DarkRP.createJob("Admin On Duty", {
    color = Color(175,0,0),
    model = "models/player/combine_super_soldier.mdl",
    description = [[Administrador haciendo cosas de administrador.]],
    weapons = {},
    command = "adminonduty",
    max = 0,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Administración",
    canDemote = false,
    PlayerSpawn = function(ply)
        ply:SetHealth(100000)
        ply:SetMaxHealth(100000)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64))
        ply:SetViewOffsetDucked(Vector(0,0,28))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36))
    end,
})

TEAM_SECUAZ = DarkRP.createJob("Secuaz Sith", {
    color = Color(255, 0, 0),
    model = {
    "models/player/jedi/female_chiss_padawan.mdl", 
    "models/player/jedi/female_human_padawan.mdl",
    "models/player/jedi/female_kaleesh_padawan.mdl",
    "models/player/jedi/female_keldoran_padawan.mdl",
    "models/player/jedi/female_pantoran_padawan.mdl",
    "models/player/jedi/female_rodian_padawan.mdl",
    "models/player/jedi/female_tholothian_padawan.mdl",
    "models/player/jedi/female_zabrak_padawan.mdl",
    "models/player/jedi/twilek_female_padawan.mdl",
    "models/player/swtor/arsenic/tombstone/sithacolyte.mdl",
    "models/player/sith/zabrak.mdl",
    "models/player/sith/umbaran.mdl",
    "models/player/sith/twilek.mdl",
    "models/player/sith/twilek2.mdl",
    "models/player/sith/trandoshan.mdl",
    "models/player/sith/togruta.mdl",
    "models/player/sith/rodian.mdl",
    "models/player/sith/pantoran.mdl",
    "models/player/sith/nautolan.mdl",
    "models/player/sith/human.mdl",
    "models/player/sith/gungan.mdl",
    "models/player/sith/gotal.mdl",
    "models/player/sith/bith.mdl"
    },
    description = [[  Unete al Sendero Oscuro.  ]],
    weapons = {
        "keys",
    },
    command = "secuaz",
    max = 0,
    salary = 10,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Sendero Oscuro",
    canDemote = false,
    sortOrder= 1,
    modelScale = 0.8,
    PlayerSpawn = function(ply)
        ply:SetHealth(100)
        ply:SetMaxHealth(100)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64 * 0.8))
        ply:SetViewOffsetDucked(Vector(0,0,28 * 0.8))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72 * 0.8))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36 * 0.8))
    end,
})

TEAM_APRENDIZ = DarkRP.createJob("Aprendiz Sith", {
    color = Color(255, 0, 0),
    model = {
    "models/player/jedi/female_chiss_padawan.mdl", 
    "models/player/jedi/female_human_padawan.mdl",
    "models/player/jedi/female_kaleesh_padawan.mdl",
    "models/player/jedi/female_keldoran_padawan.mdl",
    "models/player/jedi/female_pantoran_padawan.mdl",
    "models/player/jedi/female_rodian_padawan.mdl",
    "models/player/jedi/female_tholothian_padawan.mdl",
    "models/player/jedi/female_zabrak_padawan.mdl",
    "models/player/jedi/twilek_female_padawan.mdl",
    "models/player/swtor/arsenic/tombstone/sithacolyte.mdl",
    "models/player/sith/zabrak.mdl",
    "models/player/sith/umbaran.mdl",
    "models/player/sith/twilek.mdl",
    "models/player/sith/twilek2.mdl",
    "models/player/sith/trandoshan.mdl",
    "models/player/sith/togruta.mdl",
    "models/player/sith/rodian.mdl",
    "models/player/sith/pantoran.mdl",
    "models/player/sith/nautolan.mdl",
    "models/player/sith/human.mdl",
    "models/player/sith/gungan.mdl",
    "models/player/sith/gotal.mdl",
    "models/player/sith/bith.mdl"
    },
    description = [[  Unete al Sendero Oscuro.  ]],
    weapons = {
        "keys",
    },
    command = "aprendiz",
    max = 0,
    salary = 10,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Sendero Oscuro",
    canDemote = false,
    sortOrder= 2,
    modelScale = 0.9,
    PlayerSpawn = function(ply)
        ply:SetHealth(150)
        ply:SetMaxHealth(150)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64 * 0.8))
        ply:SetViewOffsetDucked(Vector(0,0,28 * 0.8))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72 * 0.8))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36 * 0.8))
    end,
})

TEAM_ADEPTO = DarkRP.createJob("Adepto Sith", {
    color = Color(255, 0, 0),
    model = {
    "models/player/jedi/female_chiss_padawan.mdl", 
    "models/player/jedi/female_human_padawan.mdl",
    "models/player/jedi/female_kaleesh_padawan.mdl",
    "models/player/jedi/female_keldoran_padawan.mdl",
    "models/player/jedi/female_pantoran_padawan.mdl",
    "models/player/jedi/female_rodian_padawan.mdl",
    "models/player/jedi/female_tholothian_padawan.mdl",
    "models/player/jedi/female_zabrak_padawan.mdl",
    "models/player/jedi/twilek_female_padawan.mdl",
    "models/player/swtor/arsenic/tombstone/sithacolyte.mdl",
    "models/player/sith/zabrak.mdl",
    "models/player/sith/umbaran.mdl",
    "models/player/sith/twilek.mdl",
    "models/player/sith/twilek2.mdl",
    "models/player/sith/trandoshan.mdl",
    "models/player/sith/togruta.mdl",
    "models/player/sith/rodian.mdl",
    "models/player/sith/pantoran.mdl",
    "models/player/sith/nautolan.mdl",
    "models/player/sith/human.mdl",
    "models/player/sith/gungan.mdl",
    "models/player/sith/gotal.mdl",
    "models/player/sith/bith.mdl"
    },
    description = [[  Unete al Sendero Oscuro.  ]],
    weapons = {
        "keys",
        "weapon_r_handcuffs"
    },
    command = "adepto",
    max = 0,
    salary = 10,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Sendero Oscuro",
    canDemote = false,
    sortOrder= 3,
    modelScale = 0.9,
    PlayerSpawn = function(ply)
        ply:SetHealth(250)
        ply:SetMaxHealth(250)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64 * 0.8))
        ply:SetViewOffsetDucked(Vector(0,0,28 * 0.8))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72 * 0.8))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36 * 0.8))
    end,
})

TEAM_MAESTROSITH = DarkRP.createJob("Maestro Sith", {
    color = Color(255, 0, 0),
    model = {
        "models/player/jedi/female_chiss_knight.mdl",
        "models/player/jedi/female_human_knight.mdl",
        "models/player/jedi/female_kaleesh_padawan.mdl",
        "models/player/jedi/female_keldoran_knight.mdl",
        "models/player/jedi/female_pantoran_knight.mdl",
        "models/player/jedi/female_rodian_knight.mdl",
        "models/player/jedi/female_tholothian_knight.mdl",
        "models/player/jedi/female_zabrak_knight.mdl",
        "models/player/jedi/twilek_female_knight.mdl",
        "models/player/jedi/male_chiss_knight.mdl",
        "models/player/jedi/male_human_knight.mdl",
        "models/player/jedi/male_kaleesh_knight.mdl",
        "models/player/jedi/male_keldoran_knight.mdl",
        "models/player/jedi/male_tholothian_knight.mdl",
        "models/player/jedi/male_zabrak_knight.mdl",
        "models/player/jedi/pantoran_male_knight.mdl",
        "models/player/jedi/rodian_male_knight.mdl",
        "models/player/jedi/twilek_knight_male.mdl",
        "models/player/sith/zabrak.mdl",
        "models/player/sith/umbaran.mdl",
        "models/player/sith/twilek.mdl",
        "models/player/sith/twilek2.mdl",
        "models/player/sith/trandoshan.mdl",
        "models/player/sith/togruta.mdl",
        "models/player/sith/rodian.mdl",
        "models/player/sith/pantoran.mdl",
        "models/player/sith/nautolan.mdl",
        "models/player/sith/human.mdl",
        "models/player/sith/gungan.mdl",
        "models/player/sith/gotal.mdl",
        "models/player/sith/bith.mdl",
        "models/player/swtor/arsenic/sithlords/darthbane.mdl",
        "models/player/swtor/arsenic/sithlords/tulakhord.mdl",
        "models/player/swtor/arsenic/tombstone/sithrecluse.mdl"
    },
    description = [[  Unete al Sendero Oscuro.  ]],
    weapons = {
        "keys",
        "weapon_r_handcuffs"
    },
    command = "maestrosith",
    max = 0,
    salary = 10,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Sendero Oscuro",
    canDemote = false,
    sortOrder= 5,
    modelScale = 1,
    PlayerSpawn = function(ply)
        ply:SetHealth(500)
        ply:SetMaxHealth(500)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64 * 0.8))
        ply:SetViewOffsetDucked(Vector(0,0,28 * 0.8))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72 * 0.8))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36 * 0.8))
    end,
})



TEAM_RENEGADO = DarkRP.createJob("Renegado Joven", {
    color = Color(64, 173, 208),
    model = {
    "models/player/jedi/female_chiss_padawan.mdl", 
    "models/player/jedi/female_human_padawan.mdl",
    "models/player/jedi/female_kaleesh_padawan.mdl",
    "models/player/jedi/female_keldoran_padawan.mdl",
    "models/player/jedi/female_pantoran_padawan.mdl",
    "models/player/jedi/female_rodian_padawan.mdl",
    "models/player/jedi/female_tholothian_padawan.mdl",
    "models/player/jedi/female_zabrak_padawan.mdl",
    "models/player/jedi/twilek_female_padawan.mdl",
    "models/player/jedi/male_chiss_padawan.mdl",
    "models/player/jedi/male_human_padawan.mdl",
    "models/player/jedi/male_kaleesh_padawan.mdl",
    "models/player/jedi/male_keldoran_padawan.mdl",
    "models/player/jedi/male_tholothian_padawan.mdl",
    "models/player/jedi/male_zabrak_padawan.mdl",
    "models/player/jedi/pantoran_male_padawan.mdl",
    "models/player/jedi/rodian_male_padawan.mdl",
    "models/player/jedi/twilek_padawan_male.mdl"
    },
    description = [[  Sigue tu camino  ]],
    weapons = {
        "keys",
    },
    command = "renegadoj",
    max = 0,
    salary = 10,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Renegado",
    canDemote = false,
    sortOrder= 1,
    modelScale = 0.9,
    PlayerSpawn = function(ply)
        ply:SetHealth(150)
        ply:SetMaxHealth(150)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64 * 0.8))
        ply:SetViewOffsetDucked(Vector(0,0,28 * 0.8))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72 * 0.8))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36 * 0.8))
    end,
})

TEAM_RENEGADO2 = DarkRP.createJob("Renegado", {
    color = Color(64, 173, 208),
    model = {
    "models/player/jedi/female_chiss_padawan.mdl", 
    "models/player/jedi/female_human_padawan.mdl",
    "models/player/jedi/female_kaleesh_padawan.mdl",
    "models/player/jedi/female_keldoran_padawan.mdl",
    "models/player/jedi/female_pantoran_padawan.mdl",
    "models/player/jedi/female_rodian_padawan.mdl",
    "models/player/jedi/female_tholothian_padawan.mdl",
    "models/player/jedi/female_zabrak_padawan.mdl",
    "models/player/jedi/twilek_female_padawan.mdl",
    "models/player/jedi/male_chiss_padawan.mdl",
    "models/player/jedi/male_human_padawan.mdl",
    "models/player/jedi/male_kaleesh_padawan.mdl",
    "models/player/jedi/male_keldoran_padawan.mdl",
    "models/player/jedi/male_tholothian_padawan.mdl",
    "models/player/jedi/male_zabrak_padawan.mdl",
    "models/player/jedi/pantoran_male_padawan.mdl",
    "models/player/jedi/rodian_male_padawan.mdl",
    "models/player/jedi/twilek_padawan_male.mdl"
    },
    description = [[  Sigue tu camino  ]],
    weapons = {
        "keys",
    },
    command = "renegado",
    max = 0,
    salary = 10,
    admin = 0,
    vote = false,
    hasLicense = false,
    category = "Renegado",
    canDemote = false,
    sortOrder= 2,
    modelScale = 1,
    PlayerSpawn = function(ply)
        ply:SetHealth(250)
        ply:SetMaxHealth(250)
        ply:SetArmor(100)
        ply:SetMaxArmor(100)
        ply:SetViewOffset(Vector(0,0,64 * 0.8))
        ply:SetViewOffsetDucked(Vector(0,0,28 * 0.8))
        ply:SetHull( Vector(-16,-16,0),Vector(16,16,72 * 0.8))
        ply:SetHullDuck( Vector(-16,-16,0),Vector(16,16,36 * 0.8))
    end,
})


--[[---------------------------------------------------------------------------
Define which team joining players spawn into and what team you change to if demoted
---------------------------------------------------------------------------]]
GAMEMODE.DefaultTeam = TEAM_PORINSTRUIR
--[[---------------------------------------------------------------------------
Define which teams belong to civil protection
Civil protection can set warrants, make people wanted and do some other police related things
---------------------------------------------------------------------------]]
GAMEMODE.CivilProtection = {
    [TEAM_POLICE] = true,
    [TEAM_CHIEF] = true,
    [TEAM_MAYOR] = true,
}
--[[---------------------------------------------------------------------------
Jobs that are hitmen (enables the hitman menu)
---------------------------------------------------------------------------]]
DarkRP.addHitmanTeam(TEAM_CAZARRECOMPENSAS)
DarkRP.addHitmanTeam(TEAM_MANDALORIANO)
