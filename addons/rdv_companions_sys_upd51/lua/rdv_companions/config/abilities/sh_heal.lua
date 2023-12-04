local OBJ = RDV.COMPANIONS.AddAbility("Heal")

OBJ:AddCompanion("Massiff")

OBJ:SetPrice(500)

OBJ:SetCooldown(30)

--[[
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

    function OBJ:Initialize(ply, pet)
        pet:SetHealth(pet:GetMaxHealth())

        pet:EmitSound("ambient/machines/thumper_dust.wav", nil, nil, nil, 0.01, 25)
        SendNotification(ply, RDV.LIBRARY.GetLang(nil, "COMP_healsuccess"))
    end
end