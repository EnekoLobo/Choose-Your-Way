include("shared.lua")

function ENT:Draw()
    self:DrawModel()

    local TRACE = LocalPlayer():GetEyeTrace()

    if ( TRACE.Entity == self ) and IsValid(self:GetPetOwner()) then
        local LSTAYING = RDV.LIBRARY.GetLang(nil, "COMP_stayingCommand")

        local NAME = self:GetNW2String("RDV.COMPANIONS.NAME", self:GetPetType())

        if NAME == "N/A" then
            NAME = self:GetPetType()
        end
        
        cam.Start3D2D(self:LocalToWorld(Vector(0,0,self:OBBMaxs().z)), Angle(0, Angle(0, (LocalPlayer():GetPos() - self:GetPos()):Angle().y + 90, 90).y, 90), 0.15)
            draw.SimpleText(self:GetPetOwner():Name(), "RD_FONTS_CORE_OVERHEAD_SMALL", 0, -20, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(NAME, "RD_FONTS_CORE_OVERHEAD_SMALL", 0, -40, Color(255, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End3D2D()
    end
end

--[[
function ENT:CustomThink()
    if IsValid(self) and IsValid(self:GetPetOwner()) then
        hook.Run("RDV_COMPS_Think", self, self:GetPetType(), self:GetPetOwner())
    end
end
--]]