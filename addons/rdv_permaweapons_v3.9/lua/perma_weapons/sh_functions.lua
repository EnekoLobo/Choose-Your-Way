function RDV.PERMAWEAPONS.CanUse(ply, wep)
    if !IsValid(ply) then return false end

    if !RDV.PERMAWEAPONS.CFG.Weapons[wep] then 
        return false 
    end

    local CAN = hook.Run("RDV_PMW_CanUseWeapon", ply, wep)
    if CAN == false then return false end

    local TAB = RDV.PERMAWEAPONS.CFG.Weapons[wep]

    if CAN == true then
        goto skipcheck
    end

    if TAB.Teams and !TAB.Teams[ply:Team()] then return false end
    if TAB.Level and RDV.SAL and RDV.SAL.GetLevel(ply) < TAB.Level then return false end

    if TAB.RANKS then
        local B, R = nil, nil

        if RDV.RANK then
            B = RDV.RANK.GetPlayerRankTree(ply)
            R = RDV.RANK.GetPlayerRank(ply)
        elseif MRS then
            B = MRS.GetPlayerGroup(ply:Team())
            R = MRS.GetPlyRank(ply, B)
        end

        if TAB.RANKS[B] then
            if (TAB.RANKS[B] > R ) then return false end
        else
            return false
        end
    end

    ::skipcheck::

    return true
end