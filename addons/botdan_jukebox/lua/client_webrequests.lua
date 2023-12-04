-- Handles immitating http.Fetch requests using net messages
local fetches = {}

-- Makes a "fetch request" to the server
function JukeBox:Fetch(data, onsuccess, onfailure)
    -- Give the request an ID
    local id = 1
    while fetches[id] ~= nil do
        id = id + 1
    end
    -- Save the request locally
    fetches[id] = {onsuccess = onsuccess, onfailure = onfailure}
    -- Make the request
    net.Start("JukeBox_WebRequest")
        net.WriteUInt(id, 8)
        net.WriteTable(data)
    net.SendToServer()
end

-- Handles returning net messages, ready for dispatch
local function handleResponse()
    -- Check we know what this request is for
    local id = net.ReadUInt(8)
    local callbacks = fetches[id]
    if (callbacks == nil) then return end
    -- Check if we got an error
    local success = net.ReadBool()
    if not success then
        -- Run the failure callback
        callbacks.onfailure()
    else
        -- Run the callback function with the aquired data
        local data = net.ReadTable()
        callbacks.onsuccess(data)
    end
    -- Remove the callbacks so the ID can be recycled
    fetches[id] = nil
end
net.Receive("JukeBox_WebRequest", function() handleResponse() end)