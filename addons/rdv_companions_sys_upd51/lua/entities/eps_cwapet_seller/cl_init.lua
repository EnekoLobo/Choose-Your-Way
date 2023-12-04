include("shared.lua")
AddCSLuaFile()

local w, h = 0, 0

local COL_1 = Color(0,0,0,180)
local COL_3 = Color(255,255,255)

function ENT:Draw()
    self:DrawModel()

    if self:GetPos():DistToSqr(LocalPlayer():GetPos()) > 200000 then
        return
    end

    local OVERHEAD = RDV.LIBRARY.GetLang(nil, "COMP_companionsLabel")

    local physBone = self:LookupBone("ValveBiped.Bip01_Head1") 
    local bone_pos
    local position

    if (physBone) then
        bone_pos = self:GetBonePosition(physBone) 
    end

    if (bone_pos) then
        position = bone_pos + Vector(0, 0, 15) 
    end 
    
    if position then
        cam.Start3D2D(position, Angle(0, Angle(0, (LocalPlayer():GetPos() - self:GetPos()):Angle().y + 90, 90).y, 90), 0.1)
            draw.RoundedBox(0, -( w / 2 ), 0, w, h, COL_1)
            draw.RoundedBox(0, -( w / 2), h - (h / 12), w, (h / 12), RDV.LIBRARY.GetConfigOption("COMP_overheadColor"))

            w, h = draw.SimpleText(OVERHEAD, "RD_FONTS_CORE_OVERHEAD", 0, 0, COL_3, TEXT_ALIGN_CENTER) 
        cam.End3D2D()

        w = w + 10
        h = h + 10
    end
end