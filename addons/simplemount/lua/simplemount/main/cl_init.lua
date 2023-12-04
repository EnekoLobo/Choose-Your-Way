
simplemount.cache = simplemount.cache or {}
simplemount.badCache = simplemount.badCache or {}
simplemount.matCache = simplemount.matCache or {}
simplemount.mountedCache = simplemount.mountedCache or {}
simplemount.firstLoad = simplemount.firstLoad or false
simplemount.autoLoad = simplemount.autoLoad or false

if not simplemount.firstLoad then
    hook.Add("HUDPaint", "SimpleMount.Loader", function()
        timer.Simple(2, function()
        simplemount.preLoad()
        end)
        hook.Remove("HUDPaint", "SimpleMount.Loader")
        simplemount.firstLoad = true
    end)
end

function simplemount.fetchOrGetImage(id)
    if not id then return end
    if simplemount.matCache[id] and not simplemount.matCache[id].isDownloading then
        return simplemount.matCache[id]
    end

    if simplemount.matCache[id] and simplemount.matCache[id].isDownloading then
        return "downloading image..."
    end

    simplemount.matCache[id] = {
        isDownloading = true
    }

    steamworks.Download(id, true, function(name)
        if name then
            simplemount.matCache[id] = AddonMaterial(name)
        end
    end)
end

function simplemount.loadWorkshops(fnc, count)
    count = count or 1

    if count > #simplemount.badCache then
        if not simplemount.autoLoad then
            hook.Run("SimpleMount.FullyLoaded")
        end
        if fnc then
            fnc()
        end

        return
    end

    if simplemount.badCache[count] and simplemount.badCache[count].previewId then
        simplemount.loadWorkshops(fnc, count + 1)
    else
        steamworks.FileInfo(simplemount.badCache[count].id, function(results)
            if results and results.previewid and simplemount.badCache and simplemount.badCache[count] then
                simplemount.badCache[count].previewId = results.previewid
                simplemount.badCache[count].name = results.title
                simplemount.loadWorkshops(fnc, count + 1)
            end
        end)
    end
end

function simplemount.load(bOpenMenu, bClearCache)
    if simplemount.cache and not table.IsEmpty(simplemount.cache) then
        -- build
        for k,v in pairs(simplemount.cache) do
            if simplemount.badCache[k] then continue end
            if not steamworks.IsSubscribed(v) then
                table.insert(simplemount.badCache, {id = v})
            end
        end
        
        simplemount.loadWorkshops(function()
            -- invalidate --
            if simplemount.badCache then
                for k,v in pairs(simplemount.badCache) do
                    if not v.id then
                        simplemount.badCache[k] = nil
                    end
                end
                simplemount.notify("You are subscribed to all the content for our server!")
                if simplemount.config.openWindowAuto and !bOpenMenu and !simplemount.config.autoDownload and #simplemount.badCache > 0 then
                    -- open window if possible
                    if simplemount.window and IsValid(simplemount.window) then
                        simplemount.window:Remove()
                    end
        
                    simplemount.window = vgui.Create("SimpleMount.MainMenu")
                    simplemount.window:Build() -- build content images
                end
            end
        end)

    end
    print("simplemount - finished loading collection")
end

function simplemount.preLoad(bDontOpen, bClearCache)
    print("simplemount - loading collection")

    simplemount.badCache = {}

    if not bDontOpen then
        simplemount.notify(simplemount.config.text.loading)
    end
  
    steamworks.FileInfo(simplemount.config.workshopCollectionId, function(results)
        if results and results.children then 
            simplemount.cache = results.children

            simplemount.load(bDontOpen, bClearCache)
        else
            ErrorNoHalt("Unable to get workshop collection id from steamworks.FileInfo\n")
        end
    end)
end

function simplemount.startDownload()
    print("simplemount - starting download")
    notification.AddProgress("SimpleMount.Progress", simplemount.config.text.downloading_collection, 0)
    simplemount.downloadLoop(1)
    print("simplemount - ending download")
end


local didMount = 0
local loaded = loaded or false
function simplemount.downloadLoop(iCount)
    iCount = iCount or 1
    local workshop = simplemount.cache[iCount]

    if iCount > #simplemount.cache then
        notification.Kill("SimpleMount.Progress")
        simplemount.preLoad(true, true)
        loaded = true
        return
    end

    if iCount == 0 then
        didMount = 1
    end

    notification.AddProgress("SimpleMount.Progress", simplemount.config.text.downloading_collection, didMount / #simplemount.cache)
    didMount = didMount + 1

    if workshop then
        if simplemount.mountedCache[workshop] then
            simplemount.downloadLoop(iCount + 1)
        else

            steamworks.DownloadUGC(workshop, function(path, filePath)
                if path and filePath then
                    local didMount = game.MountGMA(path)
                    simplemount.mountedCache[workshop] = true
                end
                simplemount.downloadLoop(iCount + 1)
            end)
        end

    end
end


net.Receive("SimpleMount.ChatCommand", function()
    if simplemount.window and IsValid(simplemount.window) then
        simplemount.window:Remove()
    end

    simplemount.window = vgui.Create("SimpleMount.MainMenu")
    simplemount.window:Build()
end)

net.Receive("SimpleMount.CheckContent", function()
    local isMissing = false
    if simplemount.badCache then
        for k,v in pairs(simplemount.badCache) do
            if !simplemount.mountedCache[v.id] then
                isMissing = true 
                break
            end
        end
    end
        
    net.Start("SimpleMount.CheckContentCallback")
        net.WriteBool(isMissing)
    net.SendToServer()
end)

net.Receive("SimpleMount.ForceDownload", function ()
    simplemount.startDownload()
end)

hook.Add("SimpleMount.FullyLoaded", "SimpleMount.FullyLoaded", function()
    simplemount.autoLoad = true
    if simplemount.config.autoDownload then
        simplemount.startDownload()
        return
    end
end)