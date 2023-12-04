function NCS_CHATCOMMANDS.IsAdmin(P, CB)
    if NCS_CHATCOMMANDS.CFG.camienabled then
        CAMI.PlayerHasAccess(P, "[NCS] Commands", function(ACCESS)
            CB(ACCESS)
        end )
    else
        if NCS_CHATCOMMANDS.CFG.admins[P:GetUserGroup()] then
            CB(true)
        else
            CB(false)
        end
    end
end