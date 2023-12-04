if SERVER then return end
local MODULE = MODULE

surface.CreateFont('mvp.Wheelmenu.Title', {
    font = 'Proxima Nova Rg',
    extended = true,
    weight = 800,
    size = 36
})

surface.CreateFont('mvp.Wheelmenu.Hint', {
    font = 'Proxima Nova Rg',
    extended = 500,
    weight = 200,
    size = 18
})

local soundClick = Sound('mvp/click.ogg')
local soundHover = Sound('mvp/hover.ogg')
local iconLeftClick, iconRightClick = Material('mvp/perfecthands/leftclick.png', 'mips smooth'), Material('mvp/perfecthands/rightclick.png', 'mips smooth')

local clrBlack = Color(0, 0, 0, 100)
local clrGray = Color(41, 41, 41, 200)
local clrWhite = Color(255, 255, 255)

local function drawCircle(x, y, r, step, cache)
    local positions = {}

    for i = 0, 360, step do
        table.insert(positions, {
            x = x + math.cos(math.rad(i)) * r,
            y = y + math.sin(math.rad(i)) * r
        })
    end

    return (cache and positions) or surface.DrawPoly(positions)
end

local function drawSubSection(cx,cy,radius,thickness,startang,endang,roughness, cache)
	local triarc = {}
	-- local deg2rad = math.pi / 180
	
	-- Define step
	local roughness = math.max(roughness or 1, 1)
	local step = roughness
	
	-- Correct start/end ang
	local startang,endang = startang or 0, endang or 0
	
	if startang > endang then
		step = math.abs(step) * -1
	end
	
	-- Create the inner circle's points.
	local inner = {}
	local r = radius - thickness
	for deg=startang, endang, step do
		local rad = math.rad(deg)
		-- local rad = deg2rad * deg
		local ox, oy = cx+(math.cos(rad)*r), cy+(-math.sin(rad)*r)
		table.insert(inner, {
			x=ox,
			y=oy,
			u=(ox-cx)/radius + .5,
			v=(oy-cy)/radius + .5,
		})
	end
	
	
	-- Create the outer circle's points.
	local outer = {}
	for deg=startang, endang, step do
		local rad = math.rad(deg)
		-- local rad = deg2rad * deg
		local ox, oy = cx+(math.cos(rad)*radius), cy+(-math.sin(rad)*radius)
		table.insert(outer, {
			x=ox,
			y=oy,
			u=(ox-cx)/radius + .5,
			v=(oy-cy)/radius + .5,
		})
	end
	
	
	-- Triangulize the points.
	for tri=1,#inner*2 do -- twice as many triangles as there are degrees.
		local p1,p2,p3
		p1 = outer[math.floor(tri/2)+1]
		p3 = inner[math.floor((tri+1)/2)+1]
		if tri%2 == 0 then --if the number is even use outer.
			p2 = outer[math.floor((tri+1)/2)]
		else
			p2 = inner[math.floor((tri+1)/2)]
		end
	
		table.insert(triarc, {p1,p2,p3})
	end
	
    if cache then
        return triarc
    else
        for k,v in pairs(triarc) do 
            surface.DrawPoly(v)
        end
    end
end

function MODULE.ShowRadialMenu(sections)
    if not sections or #sections == 0 then
        Error('No sections passed')
        return 
    end

    local w, h = ScrW, ScrH
    
    local scale = h() / 900
    local calculeted = 325 * scale
    local rad = calculeted * 0.4
    local sectionSize = 360 / #sections

    local origin_w = w() * .5
    local origin_h = h() * .5

    if IsValid(MODULE.panel) then
        MODULE.panel:Remove() 
    end

    MODULE.panel = vgui.Create('DButton')
    MODULE.panel:SetSize(w(), h())
    MODULE.panel:Center()
    MODULE.panel:MakePopup()
    MODULE.panel:SetCursor('hand')
    MODULE.panel.selectedArea = 0
    MODULE.panel:SetText('')
    MODULE.panel.selectedText = ''

    function MODULE.panel:Think()
        if not sections[self.selectedArea + 1] then return end
        self.selectedOption = sections[self.selectedArea + 1]
    end

    function MODULE.panel:DrawMenu(w, h)
        local cursorAng = 360 - (math.deg(math.atan2(gui.MouseX() - origin_w, gui.MouseY() - origin_h)) + 180)
        local selectedArea = math.abs(cursorAng + sectionSize * .5) / sectionSize
        selectedArea = math.floor(selectedArea)
 
        if (selectedArea >= #sections) then
            selectedArea = 0
        end

        if (self.selectedArea ~= selectedArea) then
            surface.PlaySound(soundHover)
        end
        self.selectedArea = selectedArea
        
        local selectedAng = selectedArea * sectionSize
		local outerArcScale = math.Round(4)

        draw.NoTexture()
        surface.SetDrawColor(clrWhite)

        drawSubSection(origin_w, origin_h, calculeted + outerArcScale, outerArcScale, 90 - selectedAng - sectionSize * .5, 90 - selectedAng + sectionSize * .5, 1, false)

        surface.SetDrawColor(clrBlack)
        drawSubSection(origin_w, origin_h, calculeted, rad, 90 - selectedAng - sectionSize * .5, 90 - selectedAng + sectionSize * .5, 1, false)

        surface.SetDrawColor(clrGray)
        drawCircle(origin_w, origin_h, calculeted - rad, 1, false)

        for i, v in pairs(sections) do
            local ang = (i - 1) * sectionSize

            local radians = math.rad(ang)
            local size = (64 * scale)

            if (self.selectedArea and self.selectedArea + 1 == i) then
                size = (84 * scale)
            end


            local r = calculeted - rad * .5
            local sin = math.sin(radians) * r
            local cos = math.cos(radians) * r
            local x = origin_w - size * .5 + sin
            local y = origin_h - size * .5 - cos

            surface.SetDrawColor(Color(41, 41, 41, 150))
            draw.NoTexture()
            drawSubSection(origin_w, origin_h, calculeted, rad, 90 - ang - sectionSize * .5, 90 - ang + sectionSize * .5, 1, false)

            surface.SetMaterial(v.icon)
            surface.SetDrawColor(v.col or clrWhite)
            surface.DrawTexturedRect(x, y, size, size)

            
        end

        draw.NoTexture() 
        surface.SetDrawColor(clrWhite)

        local innerArcScale = 6
        drawSubSection(origin_w, origin_h, calculeted - rad + innerArcScale * 2, innerArcScale, -cursorAng + 90 - sectionSize * .5 - 0, -cursorAng + 90 + sectionSize * .5, 1, false)
    end

    local offsetIconGroup = 55
    

    function MODULE.panel:Paint(w, h)
        MODULE.panel:DrawMenu(w, h)

        if not self.selectedOption then 
            draw.SimpleText('Select an option', 'mvp.Wheelmenu.Title', origin_w, origin_h + 35 - offsetIconGroup, clrWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        draw.SimpleText(self.selectedOption.title, 'mvp.Wheelmenu.Title', origin_w, origin_h + 35 - offsetIconGroup, clrWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        if self.selectedOption.description then
            draw.SimpleText(self.selectedOption.description, 'mvp.Wheelmenu.Hint', origin_w, origin_h + 60 - offsetIconGroup, clrWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        surface.SetMaterial(self.selectedOption.icon)
        surface.SetDrawColor(clrWhite)
        surface.DrawTexturedRect(origin_w - 128 * .5 * scale, origin_h - 128 * scale + 16 - offsetIconGroup, 128 * scale, 128 * scale)

        local textLeftClickW, textLeftClickH = draw.SimpleText(mvp.language.Get('ph#LMBSelect'), 'mvp.Wheelmenu.Hint', origin_w, origin_h + offsetIconGroup * .8, clrWhite, TEXT_ALIGN_CENTER)

        surface.SetMaterial(iconLeftClick)
        surface.SetDrawColor(clrWhite)
        surface.DrawTexturedRect(origin_w - textLeftClickW * .5 - 32, origin_h + offsetIconGroup * .8 - textLeftClickH * .5, 32, 32)

        draw.SimpleText(mvp.language.Get('ph#RMBClose'), 'mvp.Wheelmenu.Hint', origin_w, origin_h + offsetIconGroup * 1.4, clrWhite, TEXT_ALIGN_CENTER)

        surface.SetMaterial(iconRightClick)
        surface.SetDrawColor(clrWhite) 
        surface.DrawTexturedRect(origin_w - textLeftClickW * .5 - 28, origin_h + offsetIconGroup * 1.4 - textLeftClickH * .5, 32, 32)

        
    end

    function MODULE.panel:DoClick()
        surface.PlaySound(soundClick)

        if sections[self.selectedArea + 1].click then
            sections[self.selectedArea + 1].click(LocalPlayer())
        end
        self:Remove()
    end

    function MODULE.panel:DoRightClick()
        surface.PlaySound(soundClick)
        self:Remove()  
    end
end