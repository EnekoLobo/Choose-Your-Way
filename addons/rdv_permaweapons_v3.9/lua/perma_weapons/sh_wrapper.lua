local LIST = {}

local CATS = {}

local WEP_META = {
    GetClass = function(self)
        return self.CLASS
    end,
    SetBuyable = function(self, val)
        self.BUYABLE = val
    end,
    SetRankRequirement = function(self, tab)
        self.RANKS = tab
    end,
    SetName = function(self, NAME)
        self.NAME = NAME
    end,
    SetPrice = function(self, price)
        self.PRICE = price
    end,
    SetModel = function(self, model)
        self.MODEL = model
    end,
    SetCategory = function(self, cat)
        self.CATEGORY = cat
    end,
    SetTeams = function(self, tms)
        if !istable(tms) then return end

        self.TEAMS = self.TEAMS or {}

        for k, v in ipairs(tms) do
            self.TEAMS[v] = true
        end
    end,
    AddTeams = function(self, tms)
        self:SetTeams(tms)
    end,
    AddTeamCategory = function(self, cat)
        if !RPExtraTeams then return end
        
        self.TEAMS = self.TEAMS or {}

        for k, v in ipairs(RPExtraTeams) do
            if v.category and ( v.category == cat ) then
                self.TEAMS[k] = true
            end
        end
    end,
    SetLevel = function(self, level)
        self.Level = level
    end,
    Register = function(self, bl)
        if bl == false then return end
        
        RDV.PERMAWEAPONS.CFG.Weapons[self.CLASS] = {
            Model = self.MODEL,
            Category = self.CATEGORY or "Invalid",
            Name = self.NAME or "Invalid",
            Price = self.PRICE or 0,
            Teams = self.TEAMS,
            Level = self.Level,
            CanPurchase = self.CanPurchase or false,
            BUYABLE = tobool(self.BUYABLE),
            RANKS = self.RANKS,
        }
    end,
}

WEP_META.__index = WEP_META


function RDV.PERMAWEAPONS.Add(wep)
    LIST[wep] = {
        CLASS = wep,
        BUYABLE = true,
    }

    setmetatable( LIST[wep], WEP_META ) -- Setting up the metatable.

    return LIST[wep]
end