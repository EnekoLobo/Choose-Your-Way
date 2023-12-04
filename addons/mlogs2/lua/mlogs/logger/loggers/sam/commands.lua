--[[
	mLogs 2 (M4D Logs 2)
	Created by M4D | http://m4d.one/ | http://steamcommunity.com/id/m4dhead |
	Copyright © 2023 M4D.one All Rights Reserved
	All 3rd party content is public domain or used with permission
	M4D.one is the copyright holder of all code below. Do not distribute in any circumstances.
--]]

mLogs.config.samBlacklist = mLogs.config.samBlacklist or {
	["noclip"] = true,
	["menu"] = true,
}

local category = "sam"
// SAM Command Logs
mLogs.addLogger("Commands","samcommand",category)

mLogs.addHook("ULibCommandCalled", category, function(ply,cmd,args)
	if(not IsValid(ply) or slient)then return end
	if(table.HasValue(mLogs.config.ulxBlacklist, cmd))then return end
	mLogs.log("ulxcommand", category, {player1=mLogs.logger.getPlayerData(ply),command=cmd,args=table.concat(args," ")})
end)

mLogs.addHook("SAM.RanCommand", category, function(ply,cmdName,args,cmd)
	if(not IsValid(ply))then return end
    if mLogs.config.samBlacklist[cmdName] then return end

    local cmd_args = cmd.args
    local cmd_args_n = #cmd_args

    local args2 = {}
    for i = 1, cmd_args_n do
        local arg = args[i]

        if arg == nil or arg == "" then
            arg = cmd_args[i].default
        end

        if arg == nil then
            local v = args[i + 1]
            if (v ~= nil and v ~= "") or (cmd_args[i + 1] and cmd_args[i + 1].default ~= nil) then
                table.insert(args2, "")
            end
        else
            table.insert(args2, tostring(arg))
        end
    end


	mLogs.log("samcommand", category, {player1=mLogs.logger.getPlayerData(ply),command=cmdName,args=table.concat(args," ")})
end)