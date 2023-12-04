local OBJ = RDV.COMPANIONS.AddAbility("Reparación")

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

OBJ:SetPrice(200)

OBJ:SetCooldown(30)

--[[]
OBJ:SetGroups({
    ["user"] = true,
})
--]]

if SERVER then
    local function SendNotification(ply, msg)
        local CFG = {
            Appension = RDV.LIBRARY.GetConfigOption("COMP_prefix"),
            Color = RDV.LIBRARY.GetConfigOption("COMP_prefixColor"),
        }
        
        RDV.LIBRARY.AddText(ply, CFG.Color, "[" .. CFG.Appension .. "] ", COL_1, msg)
    end

    function OBJ:Initialize(ply, C_E)
        C_E:SetHealth(C_E:GetMaxHealth())

        local effectdata = EffectData()
        effectdata:SetOrigin(C_E:GetPos())
        effectdata:SetMagnitude(2.5)
        effectdata:SetScale(5)
        effectdata:SetRadius(10)

        util.Effect("ElectricSpark", effectdata)

        C_E:EmitSound("ambient/energy/spark1.wav", nil, nil, nil, 0.01, 25)
        
        SendNotification(ply, RDV.LIBRARY.GetLang(nil, "COMP_healsuccess"))
    end
end