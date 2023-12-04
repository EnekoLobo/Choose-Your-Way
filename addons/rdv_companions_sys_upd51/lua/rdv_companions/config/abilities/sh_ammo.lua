local OBJ = RDV.COMPANIONS.AddAbility("Repartir Munición")

OBJ:AddCompanion("3C-FD")
OBJ:AddCompanion("G3-SP")
OBJ:AddCompanion("M3-LN")
OBJ:AddCompanion("T3-C4")
OBJ:AddCompanion("T3-D3")
OBJ:AddCompanion("T3-H6")
OBJ:AddCompanion("T3-H8")
OBJ:AddCompanion("T3-K7")
OBJ:AddCompanion("T3-KT")
OBJ:AddCompanion("T3-LP")
OBJ:AddCompanion("T3-M3")
OBJ:AddCompanion("T3-M4")
OBJ:AddCompanion("T3-M5")
OBJ:AddCompanion("T3-QT")
OBJ:AddCompanion("T3-R2")
OBJ:AddCompanion("T3-RD")

OBJ:SetPrice(250)

OBJ:SetCooldown(30) -- 30 second cooldown on this ability.

--[[]
OBJ:SetGroups({
    ["user"] = true,
})
--]]

if SERVER then
    function OBJ:Initialize(ply, C_E)
        for k, v in ipairs(ents.FindInSphere(C_E:GetPos(), 150)) do
            if v:IsPlayer() then
                v:GiveAmmo( 500, 1 )
            end
        end

        local effectdata = EffectData()
        effectdata:SetOrigin(pet:GetPos())
        effectdata:SetMagnitude(0.1)
        effectdata:SetScale(0.1)
        effectdata:SetRadius(10)
        util.Effect("effect_bactanade", effectdata)

        pet:EmitSound("ambient/machines/thumper_dust.wav", nil, nil, nil, 0.01, 25)
    end
end