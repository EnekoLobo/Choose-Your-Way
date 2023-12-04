--[[-----------------------------------------------------------------------
Categories
---------------------------------------------------------------------------
The categories of the default F4 menu.

Please read this page for more information:
https://darkrp.miraheze.org/wiki/DarkRP:Categories

In case that page can't be reached, here's an example with explanation:

DarkRP.createCategory{
    name = "Citizens", -- The name of the category.
    categorises = "jobs", -- What it categorises. MUST be one of "jobs", "entities", "shipments", "weapons", "vehicles", "ammo".
    startExpanded = true, -- Whether the category is expanded when you open the F4 menu.
    color = Color(0, 107, 0, 255), -- The color of the category header.
    canSee = function(ply) return true end, -- OPTIONAL: whether the player can see this category AND EVERYTHING IN IT.
    sortOrder = 100, -- OPTIONAL: With this you can decide where your category is. Low numbers to put it on top, high numbers to put it on the bottom. It's 100 by default.
}


Add new categories under the next line!
---------------------------------------------------------------------------]]

DarkRP.createCategory {
    name = "Por Instruir",
    categorises = "jobs",
    startExpanded = true,
    color = Color(155, 155, 155),
    sortOrder = 1,
}

DarkRP.createCategory {
    name = "Orden Jedi",
    categorises = "jobs",
    startExpanded = true,
    color = Color(32, 110, 255),
    sortOrder = 2,
}

DarkRP.createCategory {
    name = "Tropas Jedi",
    categorises = "jobs",
    startExpanded = true,
    color = Color(32, 85, 255),
    sortOrder = 3,
}

DarkRP.createCategory {
    name = "Civiles",
    categorises = "jobs",
    startExpanded = true,
    color = Color(145,145,145),
    sortOrder = 4,
}

DarkRP.createCategory {
    name = "Imperio Esclavista Zygerriano",
    categorises = "jobs",
    startExpanded = true,
    color = Color(102,0,204),
    sortOrder = 5,
}

DarkRP.createCategory {
    name = "Sendero Oscuro",
    categorises = "jobs",
    startExpanded = true,
    color = Color(255, 0, 0),
    sortOrder = 6,
}

DarkRP.createCategory {
    name = "Renegado",
    categorises = "jobs",
    startExpanded = true,
    color = Color(64, 173, 208),
    sortOrder = 6,
}


DarkRP.createCategory {
    name = "Especial",
    categorises = "jobs",
    startExpanded = true,
    color = Color(236, 255, 0),
    sortOrder = 7,
}

DarkRP.createCategory {
    name = "Administración",
    categorises = "jobs",
    startExpanded = true,
    color = Color(175,0,0),
    sortOrder = 10000,
}