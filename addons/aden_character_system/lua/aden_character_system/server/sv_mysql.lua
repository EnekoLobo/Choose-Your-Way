if Aden_DC.Func:ModuleAvailable("mysqloo") then
    require("mysqloo")
else
    print("ADC - mysqloo NOT FOUND !")
end

local newCollumn = {
    ["withlist"] = "JSON",
    ["info"] = "JSON",
    ["cClass"] = "INT",
}

function Aden_DC.SQL:Enable(localhost)
    if localhost then
        print("ADC - Database has connected (LOCALHOST) !!")
        function Aden_DC:SQLRequest(query, callback, failed) // SQLite Request
            local data = sql.Query(query)
            if data == false then
                print("[SQL Error] ", query, sql.LastError())
                if failed then
                    failed()
                end
            else
                if callback then
                    callback(data)
                end
            end
        end
        function Aden_DC:Format(query, ...) // SQLite Format
            local arrayFormat = {...}
            for k, v in ipairs(arrayFormat) do
                arrayFormat[k] = tonumber(v) and v or istable(v) and SQLStr(util.TableToJSON(v)) or SQLStr(v)
            end
            return query:format(unpack(arrayFormat))
        end
    else
        function Aden_DC:SQLRequest(query, callback, failed) // Mysql Request
            local q = self.SQL.dataBase:query(query)
            function q:onSuccess(data)
                if callback then
                    callback(data)
                end
            end
            function q:onError(err, sql)
                print("[SQL Error] ", sql, err)
                if failed then
                    failed()
                end
            end
            q:start()
        end
        function Aden_DC:Format(query, ...) // Mysql Format
            local arrayFormat = {...}
            for k, v in ipairs(arrayFormat) do
                arrayFormat[k] = tonumber(v) and v or istable(v) and self.SQL.dataBase:escape(util.TableToJSON(v)) or self.SQL.dataBase:escape(v)
                arrayFormat[k] = "'" .. arrayFormat[k] .. "'" // Need to add quote
            end
            return query:format(unpack(arrayFormat))
        end
    end

    local autoIncrement = "AUTOINCREMENT"
    if !localhost then
        autoIncrement = "AUTO_INCREMENT" // Mysql
    end
    Aden_DC:SQLRequest([[
        CREATE TABLE IF NOT EXISTS `arrayCharacter` (
        `index` INTEGER PRIMARY KEY ]] .. autoIncrement .. [[,
        `steamid64` VARCHAR(45),
        `firstName` TEXT,
        `lastName` TEXT,
        `day` INT,
        `month` INT,
        `years` INT,
        `cDesc` TEXT,
        `cFaction` INT,
        `cModel` TEXT,
        `bodyGroups` JSON,
        `mScale` FLOAT,
        `nAvailable` BOOLEAN,
        `cMoney` INT,
        `cJob` INT,
        `cHealth` INT NOT NULL DEFAULT 100,
        `cArmor` INT NOT NULL DEFAULT 0,
        `cFood` INT NOT NULL DEFAULT 100,
        `cWeapons` JSON,
        `posX` INT,
        `posY` INT,
        `posZ` INT,
        `withlist` JSON,
        `info` JSON,
        `cClass` INT
    )]])

    Aden_DC:SQLRequest([[
        CREATE TABLE IF NOT EXISTS `arrayNotif` (
        `steamid64` VARCHAR(45),
        `reason` TEXT,
        `type` TEXT
    )]])

    Aden_DC:SQLRequest([[
        CREATE TABLE IF NOT EXISTS `arrayNPC` (
        `map` TEXT,
        `posX` INT,
        `posY` INT,
        `posZ` INT,
        `angX` INT,
        `angY` INT,
        `angZ` INT
    )]])

    for k, v in pairs(newCollumn) do
        Aden_DC:SQLRequest([[SELECT ]] .. k .. [[ FROM `arrayCharacter` LIMIT 1]], nil, function(data) // Update SQL Tab i need to add columns
            Aden_DC:SQLRequest([[
                ALTER TABLE `arrayCharacter`
                ADD COLUMN `]] .. k .. [[` ]] .. v)
        end)
    end
end

if !Aden_DC.SQL.dataBase then // Lua refresh
    if !mysqloo then
        Aden_DC.SQL:Enable(true)
        return
    end
    Aden_DC.SQL.dataBase = mysqloo.connect(Aden_DC.SQL.ip, Aden_DC.SQL.username, Aden_DC.SQL.password, Aden_DC.SQL.database, 3306)
    function Aden_DC.SQL.dataBase:onConnected()
        print("ADC - Database has connected !!")
        Aden_DC.SQL:Enable(false) // Connection succes to the MYSQL Server
    end

    function Aden_DC.SQL.dataBase:onConnectionFailed(err)
        print("ADC - Connection to database failed !!\nSwitch to local")
        print("[SQL Error] ", err)
        Aden_DC.SQL:Enable(true) // If the connection failed go to local
    end
    Aden_DC.SQL.dataBase:connect()
end
