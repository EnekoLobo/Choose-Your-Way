include("shared.lua")
AddCSLuaFile()

function ENT:Draw()
    self:DrawModel()
end

function ENT:Initialize()
    RDV.LIBRARY.AddOverhead(self, {
        Accent = RDV.VEHICLE_REQ.CFG.OVR_COLOR,
        Position = true, -- OBBMax or Head Position (you can also use a vector relative to the entities position.)
        Lines = {
            {
                Text = RDV.LIBRARY.GetLang(nil, "VR_addonTitle"), 
                Color = Color(255,255,255),
                Font = "RD_FONTS_CORE_OVERHEAD",
            },
        }
    })
end

