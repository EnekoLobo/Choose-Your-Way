--[[---------------------------------]]--    
--  Local Helpers & Vars
--[[---------------------------------]]--

local COL_1 = Color(255, 255, 255)
local COL_3 = Color(41, 120, 185)
local COL_4 = Color(23, 23, 23, 255)

local COL_GREEN = Color(133,187,101)
local COL_RED = Color(200,60,60)

--[[---------------------------------]]--    
--  Network Companion Abilities
--[[---------------------------------]]--

net.Receive("RDV_COMP_NetworkAbility", function()
    local PET = net.ReadString()
    local MLT = net.ReadBool()

    if !RDV.COMPANIONS.PLAYERS[PET] then return end

    RDV.COMPANIONS.PLAYERS[PET].ABILITIES = RDV.COMPANIONS.PLAYERS[PET].ABILITIES or {}

    if MLT then
        RDV.COMPANIONS.PLAYERS[PET].ABILITIES = {}
        
        local CNT = net.ReadUInt(8)

        for i = 1, CNT do
            local ABILITY = net.ReadString()

            RDV.COMPANIONS.PLAYERS[PET].ABILITIES[ABILITY] = true
        end
    else
        local ABILITY = net.ReadString()

        RDV.COMPANIONS.PLAYERS[PET].ABILITIES[ABILITY] = true
    end
end)