--[[---------------------------------------------------------------------------
DarkRP custom shipments and guns
---------------------------------------------------------------------------

This file contains your custom shipments and guns.
This file should also contain shipments and guns from DarkRP that you edited.

Note: If you want to edit a default DarkRP shipment, first disable it in darkrp_config/disabled_defaults.lua
    Once you've done that, copy and paste the shipment to this file and edit it.

The default shipments and guns can be found here:
https://github.com/FPtje/DarkRP/blob/master/gamemode/config/addentities.lua

For examples and explanation please visit this wiki page:
https://darkrp.miraheze.org/wiki/DarkRP:CustomShipmentFields


Add shipments and guns under the following line:
---------------------------------------------------------------------------]]
DarkRP.createShipment("Jetpack", {
    model = "models/thrusters/jetpack.mdl",
    entity = "jet_mk1",
    price = 3500,
    amount = 1,
    separate = false,
    pricesep = 215,
    noship = true,
    allowed = {TEAM_JAWA},
    category = "Jetpack",
})

DarkRP.createShipment("Granada Dioxis", {
    model = "models/cs574/explosif/grenade_dioxis.mdl",
    entity = "rw_sw_nade_dioxis",
    price = 500,
    amount = 1,
    separate = false,
    pricesep = 215,
    noship = true,
    allowed = {TEAM_JAWA},
    category = "Granadas",
})

DarkRP.createShipment("Granada Flash", {
    model = "models/cs574/explosif/grenade_flash.mdl",
    entity = "rw_sw_nade_flash",
    price = 500,
    amount = 1,
    separate = false,
    pricesep = 215,
    noship = true,
    allowed = {TEAM_JAWA},
    category = "Granadas",
})

DarkRP.createShipment("Granada Humo", {
    model = "models/cs574/explosif/grenade_smoke.mdl",
    entity = "rw_sw_nade_smoke",
    price = 500,
    amount = 1,
    separate = false,
    pricesep = 215,
    noship = true,
    allowed = {TEAM_JAWA},
    category = "Granadas",
})

DarkRP.createShipment("Granada Fragmentacion", {
    model = "models/weapons/tfa_starwars/w_thermal.mdl",
    entity = "rw_sw_nade_thermal",
    price = 500,
    amount = 1,
    separate = false,
    pricesep = 215,
    noship = true,
    allowed = {TEAM_JAWA},
    category = "Granadas",
})

DarkRP.createShipment("Granada Indendiaria", {
    model = "models/weapons/tfa_starwars/w_incendiary.mdl",
    entity = "rw_sw_nade_incendiary",
    price = 500,
    amount = 1,
    separate = false,
    pricesep = 215,
    noship = true,
    allowed = {TEAM_JAWA},
    category = "Granadas",
})

DarkRP.createCategory{
    name = "Jetpack",
    categorises = "shipments",
    startExpanded = true,
    color = Color(0, 107, 0, 255),
    canSee = fp{fn.Id, true},
    sortOrder = 101,
}

DarkRP.createCategory{
    name = "Granadas",
    categorises = "shipments",
    startExpanded = true,
    color = Color(0, 107, 0, 255),
    canSee = fp{fn.Id, true},
    sortOrder = 102,
}