local CAT = "Companions"

RDV.LIBRARY.AddConfigOption("COMP_prefix", {  TYPE = RDV.LIBRARY.TYPE.ST,  CATEGORY = CAT,  DESCRIPTION = "Prefix Text",  DEFAULT = "COMPS", SECTION = "Prefix" })
RDV.LIBRARY.AddConfigOption("COMP_prefixColor", { TYPE = RDV.LIBRARY.TYPE.CO, CATEGORY = CAT, DESCRIPTION = "Prefix Color", DEFAULT = Color(255,0,0), SECTION = "Prefix" })
RDV.LIBRARY.AddConfigOption("COMP_overheadColor", { TYPE = RDV.LIBRARY.TYPE.CO, CATEGORY = CAT, DESCRIPTION = "Overhead Color", DEFAULT = Color(30,150,220), SECTION = "Cosmetic" })
RDV.LIBRARY.AddConfigOption("COMP_randomize", { TYPE = RDV.LIBRARY.TYPE.BL, CATEGORY = CAT, DESCRIPTION = "Randomize Vendor Appearance", DEFAULT = true, SECTION = "Cosmetic" })
RDV.LIBRARY.AddConfigOption("COMP_shopIcon", {  TYPE = RDV.LIBRARY.TYPE.ST,  CATEGORY = CAT,  DESCRIPTION = "Shop Icon",  DEFAULT = "fqEJFMb", SECTION = "Icons" })
RDV.LIBRARY.AddConfigOption("COMP_abilitiesIcon", {  TYPE = RDV.LIBRARY.TYPE.ST,  CATEGORY = CAT,  DESCRIPTION = "Abilities Icon",  DEFAULT = "MtpMBQd", SECTION = "Icons" })
RDV.LIBRARY.AddConfigOption("COMP_saveInterval", {  TYPE = RDV.LIBRARY.TYPE.NM,  CATEGORY = CAT,  DESCRIPTION = "Save Interval",  DEFAULT = 300, MIN = 60, MAX = 1000, SECTION = "Saving" })


--[[---------------------------------]]--
--	Restrictions
--[[---------------------------------]]--

RDV.COMPANIONS.CFG.Blacklisted = {
--	["gm_construct"] = true -- Maps in which pets will not be enabled.
}


RDV.COMPANIONS.CFG.Restriction = {
-- 	["superadmin"] = true, 
}