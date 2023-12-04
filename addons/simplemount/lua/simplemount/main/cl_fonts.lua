

local function createFont(name, size, weight)
    surface.CreateFont(name, {
        font = "Montserrat Medium",
        size = size,
        weight = weight or 500,
        extended = true,
    })
end

local function createFonts()
    createFont("SimpleMount.Title", ScreenScale(9))
    createFont("SimpleMount.Notice", ScreenScale(9.5))
    createFont("SimpleMount.Button", ScreenScale(7))
    createFont("SimpleMount.Label", 16)
    createFont("SimpleMount.ViewBtn", 18)
end

createFonts()


hook.Add("OnScreenSizeChanged", "SimpleMount.ResizeFonts", function()
    createFonts()
end)