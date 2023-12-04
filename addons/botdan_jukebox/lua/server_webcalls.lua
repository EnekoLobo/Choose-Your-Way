-- PLEASE READ:
-- If you want to use video search and length checks,
-- you need to provide your own API key.
-- Read more: https://www.gmodstore.com/help/addon/1505/api-2/topics/how-to-obtain-a-youtube-api-key
local apiKey = "AIzaSyBs7nmRzEsIeXyLvTMmw39m0DuJsCOgFAE"

JukeBox.WebCalls = {}

util.AddNetworkString("JukeBox_WebRequest")

local timeConverts = {
    S = 1,
    M = 60,
    H = 60*60
}
local function toSeconds(googleTime)
    local secs = 0
    -- Read the string from right to left until we dont understand it
    local mul = string.sub(googleTime, -1)
    googleTime = string.sub(googleTime, 0, -2)
    while timeConverts[mul] and #googleTime > 1 do
        -- Find the parts that are a number
        local num = ""
        while tonumber(string.sub(googleTime, -1)) ~= nil do
            num = string.sub(googleTime, -1) .. num
            googleTime = string.sub(googleTime, 0, -2)
        end
        -- Add this number to the total
        secs = secs + tonumber(num) * timeConverts[mul]
        -- Move onto the next bit
        mul = string.sub(googleTime, -1)
        googleTime = string.sub(googleTime, 0, -2)
    end
    return secs
end

-- Function to get the length of a given song
function JukeBox.WebCalls:GetSongLength(ply, reqId, data)
    if not data.id then self:SendError(ply, reqId) return end
    http.Fetch("https://www.googleapis.com/youtube/v3/videos?id="..data.id.."&part=contentDetails&key="..apiKey,
        function(body, len, headers, code)
            if (code == 200) then
                -- Response should be good, find the time and send to client
                local data = util.JSONToTable(body)
                if data.items and data.items[1] then
                    local vid = data.items[1]
                    local time = toSeconds(vid.contentDetails.duration)
                    local ret = {
                        exists = true,
                        duration = time
                    }
                    self:SendResponse(ply, reqId, ret)
                else
                    self:SendResponse(ply, reqId, {exists = false})
                end
            else
                -- There was an error somewhere
                self:SendError(ply, reqId)
            end
        end,
        function(error)
            self:SendError(ply, reqId)
        end
    )
end

-- Function to get search results from YouTube
function JukeBox.WebCalls:Search(ply, reqId, data)
    if not data.q then self:SendError(ply, reqId) return end
    local q = string.Replace(data.q, " ", "+")
    http.Fetch("https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&maxResults=20&key="..apiKey.."&q="..q,
        function(body, len, headers, code)
            if (code == 200) then
                -- Response should be good, return the list of songs
                local data = util.JSONToTable(body)
                local results = {}
                if data.items then
                    for k, v in pairs(data.items) do
                        -- Extract useful information
                        local vid = {
                            image = v.snippet.thumbnails.medium.url,
                            title = v.snippet.title,
                            desc = v.snippet.description,
                            url = v.id.videoId
                        }
                        table.insert(results, vid)
                    end
                end
                self:SendResponse(ply, reqId, {results = results})
            else
                -- There was an error somewhere
                self:SendError(ply, reqId)
            end
        end,
        function(error)
            self:SendError(ply, reqId)
        end
    )
end

-- Function to get playlist results from YouTube
function JukeBox.WebCalls:Playlist(ply, reqId, data)
    if not data.id then self:SendError(ply, reqId) return end
    JukeBox.WebCalls:getPlaylistSongs(data.id,
        function(results)
            if not results then
                self:SendError(ply, reqId)
                return
            end
            -- We now have the results, but we need the video lengths fo reach as well...
            JukeBox.WebCalls:getSongLengths(results,
                function(final)
                    if not final then
                        self:SendError(ply, reqId)
                        return
                    end
                    self:SendResponse(ply, reqId, final)
                end
            )
        end
    )
end

-- gets a playlist from YouTube0
function JukeBox.WebCalls:getPlaylistSongs(id, callback, pageToken, results)
    results = results or {}
    if table.Count(results) >= 200 then
        callback(results)
    end
    local url = "https://www.googleapis.com/youtube/v3/playlistItems?maxResults=50&part=snippet,contentDetails&key="..apiKey.."&playlistId="..id
    if pageToken then
        url = url.."&pageToken="..pageToken
    end
    http.Fetch(url,
        function(body, len, headers, code)
            if (code == 200) then
                local data = util.JSONToTable(body)
                if data.items then
                    for k, v in pairs(data.items) do
                        -- Hacky check to see if video is private...
                        if v.contentDetails.videoPublishedAt then
                            local vid = {
                                --image = v.snippet.thumbnails.medium.url,
                                title = v.snippet.title,
                                --desc = v.snippet.description,
                                id = v.contentDetails.videoId
                            }
                            table.insert(results, vid)
                        end
                    end
                    if data.nextPageToken then
                        JukeBox.WebCalls:getPlaylistSongs(id, callback, data.nextPageToken, results)
                    else
                        callback(results)
                    end
                end
            else
                -- There was an error somewhere
                callback(nil)
            end
        end,
        function(error)
            callback(nil)
        end
    )
end

-- Recursively gets the lengths of all the given songs
function JukeBox.WebCalls:getSongLengths(songs, callback, start)
    start = start or 1
    local ids = {}
    -- Loop through in sets of 50 to prevent destroying the API quota
    for i=start, math.min(table.Count(songs), start+49) do
        table.insert(ids, songs[i].id)
    end
    local idsString = table.concat(ids, ",")
    http.Fetch("https://www.googleapis.com/youtube/v3/videos?id="..idsString.."&part=contentDetails&key="..apiKey,
        function(body, len, headers, code)
            if (code == 200) then
                -- Response should be good, find the time and send to client
                local data = util.JSONToTable(body)
                if data.items then
                    for k, vid in pairs(data.items) do
                        local time = toSeconds(vid.contentDetails.duration)
                        songs[start + k - 1].length = time
                    end
                end
                if start + 49 < table.Count(songs) then
                    JukeBox.WebCalls:getSongLengths(songs, callback, start + 50)
                else
                    callback(songs)
                end
            else
                -- There was an error somewhere
                callback(nil)
            end
        end,
        function(error)
            callback(nil)
        end
    )
end

function JukeBox.WebCalls:SendError(ply, reqId)
    net.Start("JukeBox_WebRequest")
        net.WriteUInt(reqId, 8)
        net.WriteBool(false)
    net.Send(ply)
end

function JukeBox.WebCalls:SendResponse(ply, reqId, data)
    net.Start("JukeBox_WebRequest")
        net.WriteUInt(reqId, 8)
        net.WriteBool(true)
        net.WriteTable(data)
    net.Send(ply)
end

-- Recieves net requests for YouTube resources
function JukeBox.WebCalls:HandleRequest(ply)
    local reqId = net.ReadUInt(8)
    local data = net.ReadTable()
    if not data.request then self:SendError(ply, reqId) return end
    -- Handle the appropriate request types
    if data.request == "length" then
        self:GetSongLength(ply, reqId, data)
    elseif data.request == "search" then
        self:Search(ply, reqId, data)
    elseif data.request == "playlist" then
        self:Playlist(ply, reqId, data)
    end
end
net.Receive("JukeBox_WebRequest", function(len, ply) JukeBox.WebCalls:HandleRequest(ply) end)
