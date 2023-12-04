util.AddNetworkString("RDV.COMPANIONS.SetName")

local function SendNotification(ply, msg)
    local CFG = {
		Appension = RDV.LIBRARY.GetConfigOption("COMP_prefix"),
		Color = RDV.LIBRARY.GetConfigOption("COMP_prefixColor"),
	}

	RDV.LIBRARY.AddText(ply, CFG.Color, "["..CFG.Appension.."] ", Color(255,255,255), msg)
end


net.Receive("RDV.COMPANIONS.SetName", function(len, ply)
    local NAME = net.ReadString()

    --
    -- Check Length
    --

    local LEN = utf8.len(NAME)
    local MAX = RDV.COMPANIONS.NAME.Characters

    if LEN > MAX then
        local CFG = RDV.LIBRARY.GetLang(nil, "COMP_shortenName", {
            MAX,
        })

        SendNotification(ply, CFG)
        return
    end

    --
    -- Check Validity of Companion
    --

    local C_E = RDV.COMPANIONS.GetPlayerCompanion(ply)

    if !IsValid(C_E) then
        return
    end

    if NAME == "" then
        NAME = C_E:GetPetType()
    end

    --
    -- CanChangeName (HOOK)
    --

    local CAN, MSG = hook.Run("RDV_COMP_CanChangeName", ply, C_E, NAME)

    if CAN == false then
        if MSG and MSG ~= "" then
            SendNotification(ply, MSG)
        end

        return
    end

    --
    -- Set Data
    --

    C_E:SetNW2String("RDV.COMPANIONS.NAME", NAME)

    C_E:RDV_COMPS_SetVar("Name", NAME)

    --
    -- OnChangeName (HOOK)
    --

    hook.Run("RDV_COMP_OnCompanionNameChanged", ply, C_E, NAME)
end)

hook.Add("RDV_COMP_OnEquipped", "RDV.COMPANIONS.OnEquippedChangeName", function(ply, C_E)
    C_E:SetNW2String("RDV.COMPANIONS.NAME", C_E:RDV_COMPS_GetVar("Name", "N/A"))
end)