--[[---------------------------------]]--
--	Don't touch anything here.
--[[---------------------------------]]--

RDV.VEHICLE_REQ.CFG = {
    MEN_MODEL = "models/buggy.mdl", -- Menu Model (Default)
    NPC_MODEL = "models/player/clone engineer/ccgi engineer.mdl",
    OVR_COLOR = Color(30,150,220), -- Overhead Accent Color.
    PRE_STRING = "ACR", -- Prefix String
    PRE_COLOR = Color(255,0,0), -- Color for the Prefix.
    DEN_TIME = 20, -- Time to wait before denying.
    HAN_SIZE = 200, -- Blockage Detection for Hangars. (Clearance amount of spawn Locations)
    SG_PERM = true, -- Can the player grant their own requests?
    DIS_HANGARS = false, -- Should we display Spawn Locations?
    MAX_DIST = false,
    VENDOR_RANDOMIZE = true,
    MAX_VEH = 0,
}

RDV.VEHICLE_REQ.CFG.Admins = {
    ["superadmin"] = true,
}

--[[---------------------------------]]--
--	Stance(s)
--[[---------------------------------]]--

RDV.VEHICLE_REQ.CFG.Stances = {	
    "pose_standing_02", 
    "idle_all_01",
    "idle_all_02"
}

RDV.VEHICLE_REQ.DF_VEHICLE = {
    NAME = false,
    CLASS = false,
    CATEGORY = false,
    REQUEST = true,
    CUSTOMIZABLE = true,
    MODEL = false,
    SKIN = 0,
    MAX = 0,
    SPAWNS = {},
    GTEAMS = {},
    RTEAMS = {},
    GRANKS = {},
    RANKS = {},
    S_CONFIG = {},
    LOADOUTS = {},
}

RDV.VEHICLE_REQ.DF_SPAWN = {
    NAME = false,
    POS = Vector(0,0,0),
    ANG = Angle(0,0,0),
    GTEAMS = {},
    RTEAMS = {},
    GRANKS = {},
    RANKS = {},
}