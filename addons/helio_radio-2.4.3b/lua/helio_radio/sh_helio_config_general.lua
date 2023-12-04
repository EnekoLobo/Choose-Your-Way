hradio.Config = {}
hradio.Config.MenuPosition = {}

-- Sounds can be annoying, you can disable them here.

hradio.Config.UISounds = true -- Ui sounds when the player clicks something, less annoying.
hradio.Config.IncomingTransmissionSounds = true -- Sounds when someone else starts talking, more annoying.

-- Should we show notifications from muted channels (so that you're aware someone's talking but you've muted them)?

hradio.Config.ShowMutedNotifications = true

-- Sequence name used to bring up/hide the radio. Defined in lua/vmanip/anims/vmanip_hradio.lua

hradio.Config.AnimName = "hradio_sw_comlink"
hradio.Config.UseCloseAnim = true
hradio.Config.AnimClose = "hradio_sw_comlink_close"
hradio.Config.OpenDelay = 0.4 -- In seconds, delay before menu shows up (sync this with your animation)

-- ADD YOUR OWN MODEL BY EDITING models/c_vmaniphradio.mdl
-- EDIT HOLD ANIMATION AND MODEL IN lua/vmanip/anims/vmanip_hradio.lua TO ADJUST FOR YOUR OWN MODEL
-- REFER TO https://steamcommunity.com/sharedfiles/filedetails/?id=2155366756&searchtext=vmanip FOR ADVANCED USAGE
 
-- Hologram configuration

------------------ DO NOT REPORT IF THIS IS BUGGY
-- EXPERIMENTAL -- DO NOT REPORT IF THIS IS BUGGY
------------------ DO NOT REPORT IF THIS IS BUGGY

hradio.Config.UseMasterHands = false -- Set this to a viewmodel path to force one hands model on ALL viewmodels. Will not reset after using radio. (e.g. hradio.Config.UseMasterHands = "models/weapons/v_hands.mdl")
hradio.Config.OverrideIndexWithBoneName = false -- Set this to bone name to override bone index with it and always use bone name instead of index. (e.g. hradio.Config.OverrideIndexWithBoneName = "ValveBiped.Bip01_L_Hand")

----------------------
-- END EXPERIMENTAL --
----------------------

hradio.Config.BoneIndex = 4 -- Counting from the viewmodel's origin (root) bone, which bone should the hologram attach to. For most hands (and vanilla hands, and the sw_comlink animfile, the wrist/hand bone is 4)

hradio.Config.IndividualBoneIndexes = { -- If you're having problems with particular viewmodels
	["models/error.mdl"] = 0, -- Example, VIEWMODEL's name followed by the appropriate bone index. (NOT PLAYERMODEL'S NAME)
	["models/weapons/v_hands.mdl"] = 1,
}

hradio.Config.MenuPosition.Up = 8.3 -- Menu display up offset
hradio.Config.MenuPosition.Forward = 0.4 -- Menu display forward offset
hradio.Config.MenuPosition.Right = -2.6 -- Menu display right offset
hradio.Config.MenuPosition.UpRot = -80 -- Menu display angle up position
hradio.Config.MenuPosition.FwdRot = 90  -- Menu display angle forward position
hradio.Config.MenuPosition.RgtRot = -10 -- Menu display angle right rotation
hradio.Config.MenuScale = 0.02

-- 1st Person VManip menu overrides

hradio.Config.AlwaysUse3PMenu = true -- Change this to true if you want to always use the 3rd person 2D menu.

hradio.Config.ExemptFrom1PMenu = { -- Add here weapons that have serious problems with displaying the 1P menu and/or don't have a viewmodel/hands.
	["weapon_example"] = true,
	["weapon_hands"] = true,
}

-- Do not modify below this line

include("sh_helio_config_channels.lua")