include("shared.lua")

function ENT:Draw()
    if self:GetPos():DistToSqr(LocalPlayer():GetPos()) > 1000000 then return end // 1000 * 1000 unit
    self:DrawModel()
    local camAng = self:GetAngles()
    camAng:RotateAroundAxis(camAng:Forward(), 90)
    camAng:RotateAroundAxis(camAng:Right(), -90)
    cam.Start3D2D(self:GetPos() + self:GetUp() * 80, camAng, 0.05)
        draw.DrawText(Aden_DC:GetPhrase("npc"), "ADCFont::4", 0, 0, color_white, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end
