Aden_DC.Config.showRoom = {}
Aden_DC.Config.showRoom[1] = { // Show Room DarkRP
    [1] = {
        model = "models/adc/adc_showroom_1.mdl",
        pos = Vector(120, 0, 66),
        ang = Angle(0, 0, 0),
    },
    [2] = {
        model = "models/mark2580/gtav/mp_apa_06/wardrobe/apa_mpa6_wardrobe_details_high.mdl",
        pos = Vector(130, 0, 61),
        ang = Angle(0, 90, 0),
    },
    [3] = {
        model = "models/mark2580/gtav/mp_apa_06/bedroom/apa_mp_h_acc_artwalll_02_high.mdl",
        pos = Vector(219, 0, 65),
        ang = Angle(0, 180, 0),
    },
}
 
Aden_DC.Config.showRoom[2] = { // Show Room Star Wars
    [1] = {
        model = "models/props/adc/adc_showroom2.mdl",
        pos = Vector(100, 100, 60),
        ang = Angle(0, -160, 0),
    },
}
 
Aden_DC.Config.showRoom[3] = { // Show Room Military
    [1] = {
        model = "models/props/adc/adc_showroom3.mdl",
        pos = Vector(40, -130, 190),
        ang = Angle(0, -80, 0),
    },
    [2] = {
        model = "models/Items/ammocrate_ar2.mdl",
        pos = Vector(160, -150, 10),
        ang = Angle(0, 100, 0),
    },
    [3] = {
        model = "models/Items/ammocrate_ar2.mdl",
        pos = Vector(160, -150, 42),
        ang = Angle(0, 100, 0),
    },
    [4] = {
        model = "models/Items/item_item_crate.mdl",
        pos = Vector(160, -160, 57),
        ang = Angle(0, 100, 0),
    },
    [5] = {
        model = "models/maxofs2d/gm_painting.mdl",
        pos = Vector(188, -160, 160),
        ang = Angle(0, -170, 0),
    },
    [6] = {
        model = "models/Items/ammoCrate_Rockets.mdl",
        pos = Vector(160, 30, 10),
        ang = Angle(0, 10, 0),
    },
}
 
Aden_DC.Config.showRoomChoice = 2 // Choose your show room : 1 = DarkRP - 2 = Star Wars - 3 = Military
// if you want use a 2d Material for the background :
// Aden_DC.Config.showRoomChoice = "materials/yourmaterials.png"
 
Aden_DC.Config.lightMode = 0.5 // Brithness of the room [0 - 1]
Aden_DC.Config.spotLight = true // Enable spot light
 
Aden_DC.Config.Model = { // All model the player can choose when he create the character ONLY IF YOU DONT USE THE FACTION SYSTEM
    [1] = "models/player/group03m/male_02.mdl",
    [2] = "models/player/group03/male_01.mdl",
    [3] = "models/player/group03m/male_01.mdl",
    [4] = "models/player/group01/male_06.mdl",
    [5] = "models/player/group03/male_08.mdl",
    [6] = "models/player/group03/male_09.mdl",
    [7] = "models/player/group01/female_03.mdl",
    [8] = "models/player/group03m/female_03.mdl",
    [9] = "models/player/group03m/male_04.mdl",
    [10] = "models/player/jedi/female_chiss_padawan.mdl",
    [11] = "models/player/jedi/female_human_padawan.mdl",
    [12] =  "models/player/jedi/female_kaleesh_padawan.mdl",
    [13] =  "models/player/jedi/female_keldoran_padawan.mdl",
    [14] =  "models/player/jedi/female_pantoran_padawan.mdl",
    [15] =  "models/player/jedi/female_rodian_padawan.mdl",
    [16] =  "models/player/jedi/female_tholothian_padawan.mdl",
    [17] =  "models/player/jedi/female_zabrak_padawan.mdl",
    [18] =  "models/player/jedi/twilek_female_padawan.mdl",
    [19] =  "models/player/jedi/male_chiss_padawan.mdl",
    [20] =  "models/player/jedi/male_human_padawan.mdl",
    [21] =  "models/player/jedi/male_kaleesh_padawan.mdl",
    [22] =  "models/player/jedi/male_keldoran_padawan.mdl",
    [23] =  "models/player/jedi/male_tholothian_padawan.mdl",
    [24] =  "models/player/jedi/male_zabrak_padawan.mdl",
    [25] =  "models/player/jedi/pantoran_male_padawan.mdl",
    [26] =  "models/player/jedi/rodian_male_padawan.mdl",
    [27] =  "models/player/jedi/twilek_padawan_male.mdl",
    [28] =  "models/player/swtor/arsenic/mandoservers/anzati.mdl",
    [29] = "models/player/swtor/arsenic/mandoservers/arsenic.mdl",
    [30] ="models/player/swtor/arsenic/mandoservers/arsenic2.mdl",
    [31] ="models/player/swtor/arsenic/mandoservers/commandervizla.mdl",
    [32] = "models/player/swtor/arsenic/mandoservers/hetakol.mdl",
    [33] = "models/player/swtor/arsenic/mandoservers/mandalorianclansmen.mdl",
    [34] = "models/player/swtor/arsenic/mandoservers/mandaloriantracker.mdl",
    [35] = "models/player/swtor/arsenic/mandoservers/medic.mdl",
    [36] = "models/player/swtor/arsenic/mandoservers/mercilessseeker.mdl",
    [37] = "models/player/swtor/arsenic/mandoservers/relicplunderer.mdl",
    [38] = "models/player/swtor/arsenic/mandoservers/shaevizla.mdl",
    [39] = "models/player/swtor/arsenic/mandoservers/vilehunter.mdl",
    [40] = "models/player/swtor/arsenic/mandoservers/wastelandraider.mdl",
    [41] = "models/clutch/pm_trandoshan_clutch.mdl",
    [42] = "models/dar/pm_trandoshan_dar.mdl",
    [43] = "models/garnac/pm_trandoshan_garnac.mdl",
    [44] ="models/hunter/pm_trandoshan_hunter.mdl",
    [45] = "models/lotaren/pm_trandoshan_lotaren.mdl",
    [46] = "models/sniper/pm_trandoshan_sniper.mdl",
    [47] = "models/sochek/pm_trandoshan_sochek.mdl",
    [48] = "models/sochek/pm_trandoshan_sochek.mdl",
    [49] = "models/trapper/pm_trandoshan_trapper.mdl",
    [50] = "models/tfa/comm/gg/pm_sw_chewbacca.mdl",
}
 
Aden_DC.Config.enableFaction = true // Enable Faction systeme
 
local function loadFactionSystem()
    Aden_DC.Config.defaultJobs = { // The Jobs not in a faction
        [TEAM_PORINSTRUIR] = true,
    }
    Aden_DC.Config.listFaction = {
        [1] = {
            name = "Orden Jedi", // The name of the faction
            mat = Material("materials/adc_materials/jedi.png"), // The material of the facton example : Material("materials/adc_materials/jedi.png")
            background = false, // You can set a new Background when a player choose a faction (false = disable)
            // Example : Material("materials/background1.jpg")
 
            //path_color = "materials/adc_materials/", // You can use a custom package for the faction
            //color = Color(0, 132, 255), // And a custom color (pls put the same color as your custom materials)
            npcOffset = Vector(0, 0, 0), // You can modify the position of the NPC (ONLY IF YOU SET A BACKGROUND !)
            defaultJobs = { // Jobs the player can select when he create her character and join the faction
                [TEAM_INICIADOJEDI] = true,

            },
            jobs = { // Whitelist jobs of the faction

            },
            jobsNWhitelist = {

                [TEAM_INICIADOJEDI] = true,
                [TEAM_PADAWANJEDI] = true,
                [TEAM_CABALLEROJEDI] = true,
                [TEAM_MAESTROJEDI] = true,
                [TEAM_CONSULJEDI] = true,
                [TEAM_GUARDIANJEDI] = true,
                [TEAM_CENTINELAJEDI] = true,
                [TEAM_GRANMAESTRONEVERLANDER] = true,
                [TEAM_MAESTROXIVSIXER] = true,
                [TEAM_MAESTROXIVSIXER2] = true,
            }, // Jobs no whitelist in the faction
            hide = false, // If you want hide the faction in the creation menu
            saveModel = false, // Save the models when you switch to an other job of this faction
        },
        [2] = {
            name = "Havoc",
            mat = Material("materials/adc_materials/sith.png"), // example : Material("materials/adc_materials/sith.png")
            background = false,
            npcOffset = Vector(0, 0, 0),
            defaultJobs = { // Jobs available when you create your character
                [TEAM_JEDITROOPER5] = true,

            },
            jobs = { // Whitelist Jobs

            },
            jobsNWhitelist = {

                [TEAM_JEDITROOPER1] = true,
                [TEAM_JEDITROOPER2] = true,
                [TEAM_JEDITROOPER3] = true,
                [TEAM_JEDITROOPER4] = true,
                [TEAM_JEDITROOPER5] = true,
                [TEAM_JEDITROOPER6] = true,
                [TEAM_JEDITROOPER7] = true,
                [TEAM_JEDITROOPER8] = true,

            }, // Jobs no whitelist in the faction
            hide = false, // If you want hide the faction in the creation menu
        },
        [3] = {
            name = "Mandaloriano",
            mat = Material("materials/materials/mandaloriano.png"), // example : Material("materials/adc_materials/sith.png")
            background = false,
            npcOffset = Vector(0, 0, 0),
            defaultJobs = { // Jobs available when you create your character
                [TEAM_MANDALORIANO] = true,
            },
            jobs = { // Whitelist Jobs

            },
            jobsNWhitelist = {

                [TEAM_MANDALORIANO] = false,

            }, // Jobs no whitelist in the faction
            hide = false, // If you want hide the faction in the creation menu
        },
        [4] = {
            name = "Cazarrecompensas",
            mat = Material("materials/materials/cazare.png"), // example : Material("materials/adc_materials/sith.png")
            background = false,
            npcOffset = Vector(0, 0, 0),
            defaultJobs = { // Jobs available when you create your character
                [TEAM_CAZARRECOMPENSAS] = true,
            },
            jobs = { // Whitelist Jobs

            },
            jobsNWhitelist = {

                [TEAM_CAZARRECOMPENSAS] = false,

            }, // Jobs no whitelist in the faction
            hide = false, // If you want hide the faction in the creation menu
        },
        [5] = {
            name = "Civiles",
            mat = Material("materials/materials/civil.png"), // example : Material("materials/adc_materials/sith.png")
            background = false,
            npcOffset = Vector(0, 0, 0),
            defaultJobs = { // Jobs available when you create your character
                [TEAM_CIVIL] = false,
                [TEAM_DROIDE1] = false,
                [TEAM_DROIDE2] = false,
                [TEAM_DROIDE3] = false,
            },
            jobs = { // Whitelist Jobs


            },
            jobsNWhitelist = {

                [TEAM_CIVIL] = true,
                [TEAM_DROIDE1] = true,
                [TEAM_DROIDE2] = true,
                [TEAM_DROIDE3] = true,

            }, // Jobs no whitelist in the faction
            hide = false, // If you want hide the faction in the creation menu
        },
        [6] = {
            name = "Wookies",
            mat = Material("materials/materials/wookie.png"), // example : Material("materials/adc_materials/sith.png")
            background = false,
            npcOffset = Vector(0, 0, 0),
            defaultJobs = { // Jobs available when you create your character
                [TEAM_WOOKIE] = true,
            },
            jobs = { // Whitelist Jobs

            },
            jobsNWhitelist = {

                [TEAM_WOOKIE] = false,

            }, // Jobs no whitelist in the faction
            hide = false, // If you want hide the faction in the creation menu
        },
        [7] = {
            name = "Jawa",
            mat = Material("materials/materials/jawa.png"), // example : Material("materials/adc_materials/sith.png")
            background = false,
            npcOffset = Vector(0, 0, 0),
            defaultJobs = { // Jobs available when you create your character
                [TEAM_JAWA] = true,
            },
            jobs = { // Whitelist Jobs

            },
            jobsNWhitelist = {

                [TEAM_JAWA] = false,

            }, // Jobs no whitelist in the faction
            hide = false, // If you want hide the faction in the creation menu
        },
        [8] = {
            name = "Renegado",
            mat = Material("materials/materials/civil.png"), // example : Material("materials/adc_materials/sith.png")
            background = false,
            npcOffset = Vector(0, 0, 0),
            defaultJobs = { // Jobs available when you create your character
                [TEAM_RENEGADO] = true,
                [TEAM_RENEGADO2] = true,
            },
            jobs = { // Whitelist Jobs

            },
            jobsNWhitelist = {

                [TEAM_RENEGADO] = true,
                [TEAM_RENEGADO2] = true,

            }, // Jobs no whitelist in the faction
            hide = false, // If you want hide the faction in the creation menu
        },
        [9] = {
            name = "Imperio Sith",
            mat = Material("materials/materials/sith2.png"), // example : Material("materials/adc_materials/sith.png")
            background = false,
            npcOffset = Vector(0, 0, 0),
            defaultJobs = { // Jobs available when you create your character
                [TEAM_SECUAZ] = true,

            },
            jobs = { // Whitelist Jobs

            },
            jobsNWhitelist = {

                [TEAM_SECUAZ] = true,
                [TEAM_ADEPTO] = true,
                [TEAM_APRENDIZ] = true,
                [TEAM_MAESTROSITH] = true,
                [TEAM_IRIONDORPRIME] = true,
                [TEAM_REUS] = true,

            }, // Jobs no whitelist in the faction
            hide = true, // If you want hide the faction in the creation menu
        },

        [10] = {
            name = "Imperio Zygerriano",
            mat = Material("materials/materials/sith2.png"), // example : Material("materials/adc_materials/sith.png")
            background = false,
            npcOffset = Vector(0, 0, 0),
            defaultJobs = { // Jobs available when you create your character
                [TEAM_SLDZYGERRIANO] = true,

            },
            jobs = { // Whitelist Jobs

            },
            jobsNWhitelist = {

                [TEAM_SLDZYGERRIANO] = true,
                [TEAM_CPTZYGERRIANO] = true,
                [TEAM_SENIORZYGERRIANO] = true,
                [TEAM_JDCZYGERRIANA] = true,
                [TEAM_ESCLAVA] = true,
                [TEAM_ESCLAVO] = true,

            }, // Jobs no whitelist in the faction
            hide = false, // If you want hide the faction in the creation menu
        },

    }
 
    // If you want create a class you can use this base :
    --[[
        Aden_DC.Config.listFaction = {
            [1] = {
                name = "Police",
                mat = Material("materials/img1.png"),
                background = false,
                npcOffset = Vector(0, 0, 0),
                class = {
                    [1] = {
                        name = "LSPD",
                        background = false,
                        npcOffset = Vector(0, 0, 0),
                        mat = Material("materials/img1.png"),
                        defaultJobs = {
                            [TEAM_LSPD_RECRUIT] = true,
                        },
                        jobs = {
                            [TEAM_LSPD] = true,
                        },
                        jobsNWhitelist = {},
                        saveModel = true,
                        hide = false,
                    },
                    [2] = {
                        name = "CIA",
                        mat = Material("materials/img1.png"),
                        defaultJobs = {
                            [TEAM_CIA] = true,
                        },
                        jobs = {
                            [TEAM_CHIEF_CIA] = true,
                        },
                        jobsNWhitelist = {},
                        saveModel = true,
                    },
                }
            },
        }
    ]]
end
 
Aden_DC.Config.maxCharacter = {
    [1] = "Nuevo personaje!", // If you set only a text, everyone can create a character
    [2] = "Nuevo personaje!",
    [3] = {
        name = "Vip",
        color = Color(241, 253, 91),
        msg = "No eres vip.",
        usergroups = { // Only this usergroups can create a character
            ["Vip Tercera Vida"] = true,
            ["superadmin"] = true
        }
    },
    [4] = {
        name = "Admin",
        color = Color(237, 28, 36),
        usergroups = {
            ["superadmin"] = true,
        }
    },
}
 
Aden_DC.Config.DefaultLang = "es" // Language  (check shared/sh_lang.lua)
Aden_DC.Config.DebugMode = false // Enable the close button in the menu TOP RIGHT
Aden_DC.Config.MinimumYears = 1970 // Minimum years of birth
Aden_DC.Config.CurrentYears = 2021 // Years (config for example WW2 1945)
Aden_DC.Config.YearsOld = false // Replace the date by the age
Aden_DC.Config.DisableDateAge = true // Disable the date of birth and the age system
Aden_DC.Config.DisableDescription =  true // Disable the description
Aden_DC.Config.DisableLastName = true // Disable the last name
Aden_DC.Config.UseNumberName = false // Change the first name to X Numbers (the player can choose)
Aden_DC.Config.PrefixNumberName = "D-" // Set a prefix before the numbers (When Aden_DC.Config.UseNumberName its activated)
Aden_DC.Config.MaxChar = 14 // Max character for the first name and the last name
// (e.g) Aden_DC.Config.UseNumberName = 5
Aden_DC.Config.PriceName = 0 // The cost of change name
Aden_DC.Config.NPCModel = "models/custom/playerstart_playermodel.mdl" // NPC Model
Aden_DC.Config.Music = false // Start a music when the player open the menu ex : "sound/music/hl2_song12_long.mp3" or a URL "https://cdn.discordapp.com/attachments/900837847412637767/957577143364227082/ambiance_aps.wav"
// for example if you want a music
// (e.g) Aden_DC.Config.Music = "https://cdn.discordapp.com/attachments/900837847412637767/957577143364227082/ambiance_aps.wav"
Aden_DC.Config.Volume = 1 // The volume of the music
 
Aden_DC.Config.changeModel = false // Player can change skin in the update menu
 
Aden_DC.Config.EnableDelete = true // Enable player to delete her character
Aden_DC.Config.customMessageDelete = false // Message will be display when the player will delete her character (false = default message)
// Aden_DC.Config.customMessageDelete = "You will loose your statistics"
 
Aden_DC.Config.customColorPackage = false
// You can put a custom color package who will change actual Material
// Aden_DC.Config.customColorPackage = "materials/custom_adc/"
 
Aden_DC.Config.delayChracter = 1 // You can configure the change time between 2 characters
Aden_DC.Config.textPopup = true // You can configure the text, when the player can't switch between 2 characters (set to false = popup disabled, true = default message)
 
Aden_DC.Config.deleteEntity = false // Delete entities when you switch from one character to another
 
Aden_DC.Config.deleteCharacterDie = false // Delete the current character when a player die
Aden_DC.Config.moneyStartCharacter = 500 // The money give only for the first character
Aden_DC.Config.moneyForAll = false // The "moneyStartCharacter" is for all character
Aden_DC.Config.transferMoney = false // Transfer the actuall money to the first Character
 
Aden_DC.Config.ModelScale = true // Enable the scale model
Aden_DC.Config.ModelMin = 0.7 // Model Scale Min
Aden_DC.Config.ModelMax = 1.3 // Model Scale Max
 
Aden_DC.Config.DisableBodyGroups = false // Disable bodygroups menu 
 
Aden_DC.Config.Open = {}
 
Aden_DC.Config.Open.InitialSpawn = true // Open the menu when the player spawn for the first time (Recommended)
Aden_DC.Config.Open.Respawn = false // Open the menu when the player respawn (If you set at false the player respawn with the last selected character)
Aden_DC.Config.Open.AutoReselect = true // Select the current character when you respawn (ONLY IF Aden_DC.Config.Open.Respawn = false)
Aden_DC.Config.Open.Command = "!pj" // To disable set to false
Aden_DC.Config.Open.CommandAdmin = "!adc_admin" // Admin command
Aden_DC.Config.Open.CommandConsole = false // Enable or disable adc_menu command
Aden_DC.Config.Open.Key = false // Open the menu with a KEY (example KEY_F2) | To disable set to false
//Aden_DC.Config.Open.Key = KEY_F2 (e.g)
Aden_DC.Config.Open.KeyAdmin = false // Open the admin menu with a KEY (example KEY_F2) | To disable set to false
//Aden_DC.Config.Open.KeyAdmin = KEY_F6 (e.g)
 
Aden_DC.Config.Open.Acces = {
    ["superadmin"] = {
        ["all"] = true,
    },
    ["admin"] = {
        ["name"] = true,
        ["money"] = true,
        ["job"] = true,
        ["faction"] = true,
        ["whitelist"] = true,
        ["delete"] = true,
        ["model"] = true
    },
    ["7656119822030XXXX"] = { // Enable a steamid
        ["whitelist"] = true,
    },
}
 
Aden_DC.Config.blackListName = { // Name blacklist
    ["Putain"] = true,
    ["Shit"] = true,
    ["Merde"] = true,
    ["Elver"] = true,
}
 
Aden_DC.Config.blackListWeapons = { // Weapons not save
    ["door_ram"] = true,
    ["arrest_stick"] = true,
    ["unarrest_stick"] = true,
    ["stunstick"] = true,
    ["weaponchecker"] = true,
    ["gmod_camera"] = true,
    ["gmod_tool"] = true,
    ["pocket"] = true,
    ["keys"] = true,
    ["weapon_keypadchecker"] = true,
    ["weapon_physgun"] = true,
    ["weapon_physcannon"] = true,
}
 
Aden_DC.Config.saveInformations = { // Set the value you dont want on false
    ["weapon"] = true,
    ["job"] = true,
    ["position"] = true,
    ["health"] =  true,
    ["armor"] = true,
    ["money"] = true,
    ["food"] = true,
}
 
timer.Simple(1, function()
    if DarkRP then
        Aden_DC.Config.UseModelsForJobs = false // Use the model of your character for the jobs in ModelsJobs
        Aden_DC.Config.ModelsJobs = {
            [TEAM_CITIZEN] = true,
            [TEAM_POLICE] = false,
        }
    end
end)
 
Aden_DC.Config.Support = {
    ["CH_ATM"] = false, // Crap Head ATM  https://www.gmodstore.com/market/view/atm
    ["ModernCarDealer"] = false, // Moder car dealer https://www.gmodstore.com/market/view/modern-car-dealer-showcases-mechanic-underglow-easily-configurable
    ["Billy Whitelist"] = false, // Billy Whitelist https://www.gmodstore.com/market/view/billys-whitelist
    ["ATM SlownLS"] = false, // ATM SlownLS https://www.gmodstore.com/market/view/6954
    ["Itemstore"] = false, // Itemstore https://www.gmodstore.com/market/view/itemstore-inventory-bank-and-trading-for-darkrp
    ["Leveling System"] = false, // Leveling-System https://github.com/uen/Leveling-System/blob/master
    ["Guthlevelsystem"] = false, // Guthlevelsystem https://github.com/Guthen/guthlevelsystem
    ["Clothes Venatuss"] = false, // Ventanuss clothes https://www.gmodstore.com/market/view/character-clothes-t-shirt-customizable-realistic-clothes-system
    ["WCD"] = false, // William car dealer
    ["xInventory"] = false, // xInventory https://www.gmodstore.com/market/view/742459101545463811
    ["Venatuss Car Dealer"] = false, // Advanced Car Dealer https://www.gmodstore.com/market/view/advanced-car-dealer-make-a-car-dealer-job
    ["VoidCases"] = false,  // VoidCases https://www.gmodstore.com/market/view/voidcases-unboxing-system
    ["Diablos Training"] = false, // The Perfect Training System // https://www.gmodstore.com/market/view/training
    ["KB RCD"] = false, // Realistic Car Dealer // https://www.gmodstore.com/market/view/realistic-car-dealer-the-best-car-dealer-system
    ["Gmod Leveling System"] = false,
    ["Gmod Advanced Inventory System"] = false,
}
 
//////////////////////Bellow this line don't touch//////////////////////
 
for k, v in pairs(Aden_DC.Config.blackListName) do
    Aden_DC.Config.blackListName[string.lower(k)] = v
end
 
if isnumber(Aden_DC.Config.showRoomChoice) then
    Aden_DC.Config.showRoom = Aden_DC.Config.showRoom[Aden_DC.Config.showRoomChoice]
else
    Aden_DC.Config.showRoom = Material(Aden_DC.Config.showRoomChoice)
end
Aden_DC.Config.baseRoom = Aden_DC.Config.showRoom
 
if Aden_DC.Config.Music and string.StartWith(Aden_DC.Config.Music, "http") then
    Aden_DC.Config.SoundFunc = sound.PlayURL
else
    Aden_DC.Config.SoundFunc = sound.PlayFile
end
 
Aden_DC.Config.listFaction = Aden_DC.Config.listFaction or {}
Aden_DC.Config.defaultJobs = Aden_DC.Config.defaultJobs or {}
 
if Aden_DC.Config.YearsOld then
    Aden_DC.Config.CurrentYears = 2000
    Aden_DC.Config.MinimumYears = 1800
end
 
timer.Simple(1, function() // DarkRPFinishedLoading  Don't work
    if CLOTHESMOD and Aden_DC.Config.Support["Clothes Venatuss"] then
        Aden_DC.Config.enableFaction = false
        Aden_DC.Config.Model = {} // Replace models
        for k, v in pairs(CLOTHESMOD.Male.ListDefaultPM) do
            Aden_DC.Config.Model[#Aden_DC.Config.Model + 1] = k
        end
        for k, v in pairs(CLOTHESMOD.Female.ListDefaultPM) do
            Aden_DC.Config.Model[#Aden_DC.Config.Model + 1] = k
        end
    end
    if DarkRP then
        loadFactionSystem()
       DarkRP.removeChatCommand("rpname")
       DarkRP.removeChatCommand("name")
       DarkRP.removeChatCommand("nick")
    end
end)