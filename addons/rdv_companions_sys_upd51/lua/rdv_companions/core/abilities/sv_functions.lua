local COL_WHITE = Color(255,255,255)

local function SendNotification(ply, msg)
    local CFG = {
		Appension = RDV.LIBRARY.GetConfigOption("COMP_prefix"),
		Color = RDV.LIBRARY.GetConfigOption("COMP_prefixColor"),
	}

	RDV.LIBRARY.AddText(ply, CFG.Color, "["..CFG.Appension.."] ", COL_WHITE, msg)
end

hook.Add("PlayerButtonDown", "RDV.COMPANIONS.SELECT_TARGET", function(ply, BUTTON)
    local SID64 = ply:SteamID64()
    local TAB = RDV.COMPANIONS.TARGETS[SID64]

    if (BUTTON == KEY_E) and TAB then

        local C = RDV.COMPANIONS.GetPlayerCompanion(ply)

        if not IsValid(C) then
            return
        end

        local eye = ply:GetEyeTrace().Entity

        if not IsValid(eye) then
            RDV.LIBRARY.PlaySound(ply, "addoncontent/pets/droids/task_denied.ogg")

            return
        end

        if TAB.Callback then
            TAB.Callback(eye)
        end
    elseif (BUTTON == KEY_G) and TAB then
        RDV.LIBRARY.PlaySound(ply, "addoncontent/pets/droids/task_denied.ogg")

        RDV.COMPANIONS.StopSelectingTarget(ply)
    end
end)

function RDV.COMPANIONS.StartSelectingTarget(ply, callback)
    if not ply:IsPlayer() then
        return
    end

    local SID64 = ply:SteamID64()

    if not callback then
        return
    end

    SendNotification(ply, RDV.LIBRARY.GetLang(nil, "COMP_selStarted"))

    RDV.COMPANIONS.TARGETS[SID64] = {
        Callback = callback,
    }
end

function RDV.COMPANIONS.StopSelectingTarget(ply)
    if not ply:IsPlayer() then
        return
    end

    local SID64 = ply:SteamID64()

    if !RDV.COMPANIONS.TARGETS[SID64] then return end
    
    RDV.COMPANIONS.TARGETS[SID64] = nil
end