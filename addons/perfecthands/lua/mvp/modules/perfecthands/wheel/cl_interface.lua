local MODULE = MODULE

MODULE.WheelMenu = {
    New = function(self)
        return setmetatable({options = {}}, {__index = MODULE.WheelMenu})
    end,

    AddOption = function(self, title, description, icon, click)
        local newOption = MODULE.WheelMenuOption:New()

        newOption:SetTitle(title or '')
        newOption:SetDescription(description or '')
        newOption:SetIcon(icon or 'error')
        newOption:SetClick(click or function()
            
        end)

        self.options[#self.options + 1] = newOption

        return newOption
    end,

    Open = function(self)
        if #self.options == 0 then return end
        MODULE.ShowRadialMenu(self.options) 
    end
} 

MODULE.WheelMenuOption = {
    New = function(self)
        return setmetatable({subMenu = nil}, {__index = MODULE.WheelMenuOption})
    end,

    AddSubOption = function(self, title, description, icon, click) 
        if self.subMenu then
            return self.subMenu:AddOption(title, description, icon, click)
        end

        self.subMenu = MODULE.WheelMenu:New() 

        self.click = function()
            self.subMenu:Open()
        end

        return self.subMenu:AddOption(title, description, icon, click)
    end, 

    SetTitle = function(self, value)
        self.title = value

        return self
    end,
    SetDescription = function(self, value)
        self.description = value

        return self
    end,
    SetIcon = function(self, value)
        
        if type(value) ~= 'IMaterial' then
            value = Material(value or 'error', 'smooth mips')
        end

        self.icon = value

        return self
    end ,
    SetClick = function(self, value)
        self.click = value

        return self
    end 
}

function MODULE.Menu()
    return MODULE.WheelMenu:New()
end