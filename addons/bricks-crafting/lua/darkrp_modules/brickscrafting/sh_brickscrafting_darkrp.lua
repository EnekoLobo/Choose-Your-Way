--[[ ADDS ENTITIES TO F4 MENU ]]--
local function addCraftingBenchesToShop()
    for k, v in pairs( BRICKSCRAFTING.CONFIG.Crafting ) do
        DarkRP.createEntity( v.Name, {
            ent = "brickscrafting_bench_" .. string.Replace( string.lower( k ), " ", "" ),
            model = v.model,
            price = 150,
            max = 1,
            cmd = "buycrafting_bench_" .. string.Replace( string.lower( k ), " ", "" ),
            category = "Crafting"
        })
    end
end

if( BRICKSCRAFTING.CONFIGLOADED ) then
    addCraftingBenchesToShop()
else
    hook.Add( "BRCS.ConfigLoaded", "BRCS.ConfigLoaded.DarkRP", addCraftingBenchesToShop )
end
	
DarkRP.createCategory {
    name = "Crafting",
    categorises = "entities",
    startExpanded = true,
    color = Color( 125, 125, 125 ),
    canSee = function(ply) return true end,
    sortOrder = 1
}

--[[ JOBS ]]--
-- TEAM_MINER = DarkRP.createJob("Miner", {
--     color = Color(196, 196, 196, 255),
--     model = {"models/player/eli.mdl"},
--     description = [[The Miner must go into the mines and collect precious stones and ores in order to craft items!]],
--     weapons = {"bcs_pickaxe"},
--     command = "miner",
--     max = 0,
--     salary = 25,
--     admin = 0,
--     vote = false,
--     hasLicense = false,
--     candemote = false,
--     category = "Citizens"
-- })

-- TEAM_LUMBERJACK = DarkRP.createJob("Lumberjack", {
--     color = Color(196, 196, 196, 255),
--     model = {"models/player/odessa.mdl"},
--     description = [[The lumberjack must go into the forest and cut down trees for wood and other materials!]],
--     weapons = {"bcs_axe"},
--     command = "lumberjack",
--     max = 0,
--     salary = 25,
--     admin = 0,
--     vote = false,
--     hasLicense = false,
--     candemote = false,
--     category = "Citizens"
-- })