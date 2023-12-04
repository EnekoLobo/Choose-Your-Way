--  _______               __          _______  __                   __          _______  ______  ______        
-- |   |   |.---.-..----.|  |.-----. |     __||__|.--------..-----.|  |.-----. |    |  ||   __ \|      |.-----.
-- |       ||  _  ||  __| |_||__ --| |__     ||  ||        ||  _  ||  ||  -__| |       ||    __/|   ---||__ --|
-- |__|_|__||___._||____|    |_____| |_______||__||__|__|__||   __||__||_____| |__|____||___|   |______||_____|
--                                                          |__|      
-- Template moved to the documentationw

MCS.Spawns["miniritojedi1"] = {
    name = "Instructor del Templo Jedi",
    model = "models/player/jedi/male_human_knight.mdl",
    namepos = 100,
    theme = "Backbone",
    scale = 1.05,
    questNPC = true,
    pos = {
        ["rp_jedi_cyw"] = { Vector(-10957.744140625,-6510.5307617188,-8651.96875 ), Angle(0,84.976028442383,0 )},
    },
    sequence = "pose_standing_04",
    uselimit = false,
    skin = 1,
    bgr = {[1] = 7,[2] = 0,},
    ClModels = {
    },
    dialogs = {
        [1] = {
            ["Line"] = [[Buenos dias Joven, necesita algo?]],
            ["Sound"] = "",
            ["Answers"] = {
                {"Si, me gustaría ver que puedo hacer por el templo", "MQS Open All quests",},
                {"Pero si es de noche", 2,},
            },
        },
        [2] = {
            ["Line"] = [[Uy, que rápido se pasa el tiempo]],
            ["Sound"] = "",
            ["Answers"] = {
            },
        },
    }
}

MCS.Spawns["miniritocazarecompensas1"] = {
    name = "Instructor del Gremio",
    model = "models/player/swtor/arsenic/mandoservers/forgemaster.mdl",
    namepos = 100,
    theme = "Backbone",
    scale = 1.05,
    questNPC = true,
    pos = {
        ["rp_jedi_cyw"] = { Vector(3430.2563476563,-279.4508972168,-752.96881103516 ), Angle(0,178.6641998291,0 )},
    },
    sequence = "pose_standing_02",
    uselimit = false,
    skin = 1,
    bgr = {},
    ClModels = {
    },
    dialogs = {
        [1] = {
            ["Line"] = [[Saludos señor, que necesita]],
            ["Sound"] = "",
            ["Answers"] = {
                {"Me gustaría informarme acerca de que puedo hacer", "MQS Open All quests",},
                {"No quiero nada", 2,},
            },
        },
        [2] = {
            ["Line"] = [[Entonces para que me habla, estos nuevos cazarecompensas...]],
            ["Sound"] = "",
            ["Answers"] = {
            },
        },
    }
}

MCS.Spawns["Tython"] = {
    name = "[Transportista] Piloto de Tython",
    model = "models/kurator/swtor/player/havoc_squad/havoc_assault_trooper.mdl",
    namepos = 80,
    theme = "Backbone",
    scale = 1,
    questNPC = true,
    pos = {
        ["rp_jedi_cyw"] = { Vector(-9589.1640625,-12445.090820313,-8051.64453125 ), Angle(0,-71.612663269043,0 )},
    },
    sequence = "pose_standing_01",
    uselimit = false,
    skin = 1,
    bgr = {},
    ClModels = {
    },
    dialogs = {
        [1] = {
            ["Line"] = [[Hey, qué tal? Transporte de la República, dónde le llevo?]],
            ["Sound"] = "",
            ["Answers"] = {
                {"*Le dices dónde ir*", "MQS Open All quests",},
            },
        },
    }
}

MCS.Spawns["Illum"] = {
    name = "[Transportista] Piloto de Illum",
    model = "models/kurator/swtor/player/havoc_squad/havoc_assault_trooper.mdl",
    namepos = 80,
    theme = "Backbone",
    scale = 1,
    questNPC = true,
    pos = {
        ["rp_jedi_cyw"] = { Vector(7986.7783203125,-12893.674804688,-455.96875 ), Angle(0,86.464256286621,0 )},
    },
    sequence = "pose_standing_02",
    uselimit = false,
    skin = 1,
    bgr = {},
    ClModels = {
    },
    dialogs = {
        [1] = {
            ["Line"] = [[Buenas, le sugiero abrigarse bien con el frío que hace... En fin, dónde le llevo?]],
            ["Sound"] = "",
            ["Answers"] = {
                {"*Le dices dónde ir*", "MQS Open All quests",},
            },
        },
    }
}

MCS.Spawns["Tatooine"] = {
    name = "[Transportista] Piloto de Tatooine",
    model = "models/bandit/pm_civ_bandit_human_male.mdl",
    namepos = 80,
    theme = "Backbone",
    scale = 1,
    questNPC = true,
    pos = {
        ["rp_jedi_cyw"] = { Vector(3697.8205566406,-18.47864151001,-144.96875 ), Angle(0,-178.43402099609,0 )},
    },
    sequence = "pose_standing_01",
    uselimit = false,
    skin = 1,
    bgr = {},
    ClModels = {
    },
    dialogs = {
        [1] = {
            ["Line"] = [[Tu también has oído del piloto de la nave más rápida de este sector, eh? Bien, donde te llevo.]],
            ["Sound"] = "",
            ["Answers"] = {
                {"*Le dices dónde ir*", "MQS Open All quests",},
            },
        },
    }
}

MCS.Spawns["zygeriano1"] = {
	name = "[Transportista] Piloto Esclavista ",
	model = "models/player/zygerrian/zygerrian_soldier.mdl",
	namepos = 80,
	theme = "Backbone",
	scale = 1,
	questNPC = true,
	pos = {
		["rp_jedi_cyw"] = { Vector(-8816.1708984375,6950.255859375,5576.03125 ), Angle(0,63.053600311279,0 )},
	},
	sequence = "idle_all_02",
	uselimit = false,
	skin = 1,
	bgr = {},
	ClModels = {
	},
	dialogs = {
		[1] = {
			["Line"] = [[*Silencio incomodo*]],
			["Sound"] = "",
			["Answers"] = {
				{"**Entrar en la nave de transporte.**", "MQS Open All quests",},
				{"**Irse**", "close",},
			},
		},
	}
}

MCS.Spawns["transporteeneko1"] = {
	name = "[Transportista] Piloto de Yavin IV",
	model = "models/bandit/pm_civ_bandit_human_male.mdl",
	namepos = 80,
	theme = "Backbone",
	scale = 1,
	questNPC = true,
	pos = {
		["rp_jedi_cyw"] = { Vector(8104.9794921875,6897.6298828125,-8318.96875 ), Angle(0,25.103782653809,0 )},
	},
	sequence = "idle_all_02w",
	uselimit = false,
	skin = 1,
	bgr = {},
	ClModels = {
	},
	dialogs = {
		[1] = {
			["Line"] = [[*Silencio altamente agradable*]],
			["Sound"] = "",
			["Answers"] = {
				{"**Entrar en la nave de transporte.**", "MQS Open All quests",},
				{"**Irse**", "close",},
			},
		},
	}
}

MCS.Spawns["Guardián"] = {
    name = "Guardián de las Profundidades",
    model = "models/epangelmatikes/templeguard/temple_guard.mdl",
    namepos = 80,
    theme = "Backbone",
    scale = 1,
    questNPC = true,
    pos = {
        ["rp_jedi_cyw"] = { Vector(-6816.6166992188,-12151.994140625,-8667.96484375 ), Angle(0,142.56251525879,0 )},
    },
    sequence = "pose_standing_02",
    uselimit = false,
    skin = 1,
    bgr = {},
    ClModels = {
    },
    dialogs = {
        [1] = {
            ["Line"] = [[Cuidado al moverte por aquí, más aun ahí dentro, los Centinelas no podremos protegerte si entras... Los 'Come Pieles', como se les llama desde hace mucho son peligrosos, y muy territoriales... Ten cuidado y que la Fuerza te acompañe...]],
            ["Sound"] = "",
            ["Answers"] = {
                {"Gracias por el aviso, que la Fuerza vaya contigo.", "close",},
                {"Qué son esos 'Come Pieles'?", 2,},
            },
        },
        [2] = {
            ["Line"] = [[Son los habitantes originales de Tython, los Jedi iniciamos la Órden aquí, y, aunque se dice que es 'El Planeta de Nacimiento de los Jedi', solo es donde nació la Órden... Para ellos este es su planeta, y no estan dispuestos a compartirlo... Por suerte, son primitivos, aunque lo suficientemente listos como para usar un Blaster... No te acerques a ellos sin ir armado... ]],
            ["Sound"] = "",
            ["Answers"] = {
                {"Entendido... Gracias.", "close",},
            },
        },
    }
}

MCS.Spawns["Guardián2"] = {
    name = "Guardián de las Profundidades",
    model = "models/epangelmatikes/templeguard/temple_guard.mdl",
    namepos = 80,
    theme = "Backbone",
    scale = 1,
    questNPC = true,
    pos = {
        ["rp_jedi_cyw"] = { Vector(-13601.840820313,-7519.01953125,-8704.96875 ), Angle(0,-34.137687683105,0 )},
    },
    sequence = "pose_standing_02",
    uselimit = false,
    skin = 1,
    bgr = {},
    ClModels = {
    },
    dialogs = {
        [1] = {
            ["Line"] = [[Estas puertas estan selladas desde hace mucho, y es mejor que sigan así, da la vuelta...]],
            ["Sound"] = "",
            ["Answers"] = {
                {"Entendido, disculpe las molestias.", "close",},
            },
        },
        [2] = {
            ["Line"] = [[Son los habitantes originales de Tython, los Jedi iniciamos la Órden aquí, y, aunque se dice que es 'El Planeta de Nacimiento de los Jedi', solo es donde nació la Órden... Para ellos este es su planeta, y no estan dispuestos a compartirlo... Por suerte, son primitivos, aunque lo suficientemente listos como para usar un Blaster... No te acerques a ellos sin ir armado... ]],
            ["Sound"] = "",
            ["Answers"] = {
                {"Entendido... Gracias.", "close",},
            },
        },
    }
}
MCS.Spawns["sith1"] = {
	name = "[Transportista] Inqusidor Sith ",
	model = "models/player/swtor/arsenic/tombstone/heavysith.mdl",
	namepos = 80,
	theme = "Backbone",
	scale = 1,
	questNPC = true,
	pos = {
		["rp_jedi_cyw"] = { Vector(11786.5234375,6673.1723632813,9356.35546875 ), Angle(0,-1.9560189247131,0 )},
	},
	sequence = "pose_standing_02",
	uselimit = false,
	skin = 1,
	bgr = {},
	ClModels = {
	},
	dialogs = {
		[1] = {
			["Line"] = [[*Silencio incomodo*]],
			["Sound"] = "",
			["Answers"] = {
				{"**Entrar en la nave de transporte.**", "MQS Open All quests",},
				{"**Irse**", "close",},
			},
		},
	}
}