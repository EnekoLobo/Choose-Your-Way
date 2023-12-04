Aden_DC.Model = Aden_DC.Model or {}
Aden_DC.Model.SpawnIcon = Aden_DC.Model.SpawnIcon or {}
Aden_DC.Model.TempsIcon = Aden_DC.Model.TempsIcon or {}

function Aden_DC.Model:GenerateSpawnIcon(mdl, skin)
    if self:IsValidModel(mdl) then return end
    util.PrecacheModel(mdl)

    local tempModel = ClientsideModel(mdl)
    local idSeq = tempModel:LookupSequence("walk_all")
    tempModel:ResetSequence(idSeq)
    tempModel:SetNoDraw(true)
    if skin then
        tempModel:SetSkin(skin)
    end

    local model = vgui.Create("SpawnIcon")
    model:SetSize(150, 150)
    model:SetModel((skin or "") .. mdl)
    model.OnRemove = function()
        if IsValid(tempModel) then
            tempModel:Remove()
        end
    end

    if !file.Exists(string.Replace("materials/spawnicons/" .. (skin or "") .. mdl, ".mdl", "_256.png"), "GAME") then
        local tab = {}
        tab.ent = tempModel
        tab.cam_pos = Vector(61.640408, -18.020460, 75.309029)
        tab.cam_ang = Angle(7.424, 164.692, -0.012)
        tab.cam_fov = 30

        model:RebuildSpawnIconEx(tab)
    end
    model:SetPaintedManually(true)
    self.SpawnIcon[mdl .. (skin or "")] = model
end

function Aden_DC.Model:GetSpawnIcon(mdl)
    if !self:IsValidModel(mdl) then
        self:GenerateSpawnIcon(mdl)
    end
    return self.SpawnIcon[mdl]
end

function Aden_DC.Model:IsValidModel(mdl)
    return self.SpawnIcon[mdl] and IsValid(self.SpawnIcon[mdl])
end
