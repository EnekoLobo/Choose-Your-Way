local MODULE = MODULE

--[[
    How to add own animations?
    use this function
    
    MODULE.config.AddAnimation(string ID, string Name, string Description, material or string Icon, table BonesAngles)

    where ID you put id of the animation, this is the sustem id, that never shows to player
    where Name you put name of the animation
    where Description you put short description of the animation
    where Icon you can put Material('path/to/icon') or 'path/to/icon', this is the icon in menu for animation
    where BonesAngles you put table with angles for bones

    see example bellow
]]--

--[[
    How I can add entities that cannot be picked up?
    use this function
    
    MODULE.config.AddBlaclistedEntity(string Class)

    where Class you put class of the entity that need to be ignored

    example: MODULE.config.AddBlaclistedEntity('prop_physics')
]]--

MODULE.config.AddAnimation('surrender', 'ph#surrender', 'ph#surrenderDesc', {
    ['ValveBiped.Bip01_L_Forearm'] = Angle(25, -65, 25),
    ['ValveBiped.Bip01_R_Forearm'] = Angle(-25, -65, -25),
    ['ValveBiped.Bip01_L_UpperArm'] = Angle(-70, -180, 70),
    ['ValveBiped.Bip01_R_UpperArm'] = Angle(70, -180, -70)
})

MODULE.config.AddAnimation('armsinfront', 'ph#armsinfront', 'ph#armsinfrontDesc', {
    ['ValveBiped.Bip01_R_Forearm'] = Angle(-43, -107, 15),
    ['ValveBiped.Bip01_R_UpperArm'] = Angle(20, -57, -6),
    ['ValveBiped.Bip01_L_UpperArm'] = Angle(-28, -59, 1),
    ['ValveBiped.Bip01_R_Thigh'] = Angle(4, -6, -0),
    ['ValveBiped.Bip01_L_Thigh'] = Angle(-7, -0, 0),
    ['ValveBiped.Bip01_L_Forearm'] = Angle(51, -120, -18),
    ['ValveBiped.Bip01_R_Hand'] = Angle(14, -33, -7),
    ['ValveBiped.Bip01_L_Hand'] = Angle(25, 31, -14),
})

MODULE.config.AddAnimation('armsbehind', 'ph#armsbehind', 'ph#armsbehindDesc', {
    ['ValveBiped.Bip01_R_UpperArm'] = Angle(3, 15, 2),
    ['ValveBiped.Bip01_R_Forearm'] = Angle(-63, 1 , -84),
    ['ValveBiped.Bip01_L_UpperArm'] = Angle(3, 15, 2.654),
    ['ValveBiped.Bip01_L_Forearm'] = Angle(53, -29, 31),
    ['ValveBiped.Bip01_R_Thigh'] = Angle(4, 0, 0),
    ['ValveBiped.Bip01_L_Thigh'] = Angle(-8, 0, 0),
})

MODULE.config.AddAnimation('comlink', 'ph#comlink', 'ph#comlinkDesc', {
    ['ValveBiped.Bip01_R_UpperArm'] = Angle(32.9448, -103.5211, 2.2273),
    ['ValveBiped.Bip01_R_Forearm'] = Angle(-90.3271, -31.3616, -41.8804),
    ['ValveBiped.Bip01_R_Hand'] = Angle(0,0,-24),
})

MODULE.config.AddAnimation('highfive', 'ph#highfive', 'ph#highfiveDesc', {
    ['ValveBiped.Bip01_L_Forearm'] = Angle(25,-65,25),
    ['ValveBiped.Bip01_L_UpperArm'] = Angle(-70,-180,70),
})

MODULE.config.AddAnimation('hololink', 'ph#hololink', 'ph#hololinkDesc', {
    ['ValveBiped.Bip01_R_UpperArm'] = Angle(10,-20),
    ['ValveBiped.Bip01_R_Hand'] = Angle(0,1,50),
    ['ValveBiped.Bip01_Head1'] = Angle(0,-30,-20),
    ['ValveBiped.Bip01_R_Forearm'] = Angle(0,-65,39.8863),
})

MODULE.config.AddAnimation('point', 'ph#point', 'ph#pointDesc', {
    ['ValveBiped.Bip01_R_Finger2'] = Angle(4, -52, 0),
    ['ValveBiped.Bip01_R_Finger21'] = Angle(0, -58, 0),
    ['ValveBiped.Bip01_R_Finger3'] = Angle(4, -52, 0),
    ['ValveBiped.Bip01_R_Finger31'] = Angle(0, -58, 0),
    ['ValveBiped.Bip01_R_Finger4'] = Angle(4, -52, 0),
    ['ValveBiped.Bip01_R_Finger41'] = Angle(0, -58, 0),
    ['ValveBiped.Bip01_R_UpperArm'] = Angle(25, -87, -0),
})

MODULE.config.AddAnimation('salute', 'ph#salute', 'ph#saluteDesc', {
    ['ValveBiped.Bip01_R_UpperArm'] = Angle(80, -95, -77.5),
    ['ValveBiped.Bip01_R_Forearm'] = Angle(35, -125, -5),
})

MODULE.config.AddAnimation('armsbehindhead', 'ph#armsbehindhead', 'ph#armsbehindheadDesc', {
    ['ValveBiped.Bip01_L_Forearm'] = Angle(25,-115,15),
    ['ValveBiped.Bip01_R_Forearm'] = Angle(-32,-115,-15),
    ['ValveBiped.Bip01_L_UpperArm'] = Angle(-50,-210,80),
    ['ValveBiped.Bip01_R_UpperArm'] = Angle(50,-210,-80),
})

MODULE.config.AddAnimation('armsonbelt', 'ph#armsonbelt', 'ph#armsonbeltDesc', {
    ['ValveBiped.Bip01_L_Forearm'] = Angle(50,-90,5),
    ['ValveBiped.Bip01_R_Forearm'] = Angle(-50,-90,5),
    ['ValveBiped.Bip01_L_UpperArm'] = Angle(-40,30,-20),
    ['ValveBiped.Bip01_R_UpperArm'] = Angle(40,30,20),
})

MODULE.config.AddAnimation('pensive', 'ph#pensive', 'ph#pensiveDesc', {
    ['ValveBiped.Bip01_R_Forearm'] = Angle(-14.4,-106.18412780762,76.318969154358),
    ['ValveBiped.Bip01_R_UpperArm'] = Angle(23.656689071655, -58.723915100098, -5.3269416809082),
    ['ValveBiped.Bip01_L_UpperArm'] = Angle(-28.913911819458, -59.408206939697, 1.0253102779388),
    ['ValveBiped.Bip01_R_Thigh'] = Angle(4.7250719070435, -6.0294013023376, -0.46876749396324),
    ['ValveBiped.Bip01_L_Thigh'] = Angle(-7.6583762168884, -0.21996378898621, 0.4060270190239),
    ['ValveBiped.Bip01_L_Forearm'] = Angle(51.038677215576, -120.44165039063, -18.86986541748),
    ['ValveBiped.Bip01_R_Hand'] = Angle(-6.224224853516, -7.906204223633, 10.8624106407166),
    ['ValveBiped.Bip01_L_Hand'] = Angle(25.959447860718, 31.564517974854, -14.979378700256),
})

MODULE.config.AddAnimation('typing', 'ph#typing', 'ph#typingDesc', {
    ['ValveBiped.Bip01_L_Forearm'] = Angle(0,0,0),
    ['ValveBiped.Bip01_R_Forearm'] = Angle(0,0,0),
    ['ValveBiped.Bip01_L_UpperArm'] = Angle(-28,-65,50),
    ['ValveBiped.Bip01_R_UpperArm'] = Angle(20,-65,-50),
})