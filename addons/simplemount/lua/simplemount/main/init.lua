simplemount = simplemount or {}
simplemount.playerQueue = simplemount.playerQueue or {}

util.AddNetworkString("SimpleMount.ChatCommand")
util.AddNetworkString("SimpleMount.CheckContent")
util.AddNetworkString("SimpleMount.CheckContentCallback")
util.AddNetworkString("SimpleMount.ForceDownload")


hook.Add("PlayerSay", "SimpleMount.Chat.PlayerSay", function(pPlayer, text)
	if ( string.lower( text ) == simplemount.config.chatCommand ) then
        net.Start("SimpleMount.ChatCommand")
        net.Send(pPlayer)
		return ""
	end
end)

net.Receive("SimpleMount.CheckContent", function(len, pPlayer)
    if not simplemount.isAdmin(pPlayer) then return end

    local otherPlayer = net.ReadEntity()
    simplemount.contentCheck(pPlayer, otherPlayer)
end)

net.Receive("SimpleMount.CheckContentCallback", function(len, pPlayer)
    if not simplemount.playerQueue[pPlayer] then return end

    local bBool = net.ReadBool()

    simplemount.contentCheckCallback(pPlayer, bBool)
end)


net.Receive("SimpleMount.ForceDownload", function(len, pPlayer)
    if not simplemount.isAdmin(pPlayer) then return end
    local otherPlayer = net.ReadEntity()
    simplemount.forceDownload(pPlayer, otherPlayer)
end)


function simplemount.contentCheck(pAdmin, pPlayer)
    if not IsValid(pAdmin) then return end
    if not IsValid(pPlayer) then return end


    if simplemount.playerQueue[pPlayer] then return end
    simplemount.playerQueue[pPlayer] = pAdmin

    net.Start("SimpleMount.CheckContent")
    net.Send(pPlayer)
end

function simplemount.contentCheckCallback(pPlayer, bBool)
    if not IsValid(pPlayer) then return end
    if not simplemount.playerQueue[pPlayer] then return end

    local pAdmin = simplemount.playerQueue[pPlayer]
    if not IsValid(pAdmin) then return end

    if bBool then
        simplemount.notify(string.format(simplemount.config.text.missing_content, pPlayer:Nick()), pAdmin)
    else
        simplemount.notify(string.format(simplemount.config.text.not_missing, pPlayer:Nick()), pAdmin)

    end

    simplemount.playerQueue[pPlayer] = nil
end


function simplemount.forceDownload(pAdmin, pPlayer)
    if not IsValid(pAdmin) then return end
    if not IsValid(pPlayer) then 
        simplemount.notify(simplemount.config.text.not_valid, pPlayer)
        return 
    end
    net.Start("SimpleMount.ForceDownload")
    net.Send(pPlayer)
    simplemount.notify(string.format(simplemount.config.text.downloading_now, pPlayer:Nick()), pAdmin)
end