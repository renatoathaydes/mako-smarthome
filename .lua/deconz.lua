local http = require "http"
local conf = require "loadconf"

local sensorsUrl = conf.sensorsServerUrl .. "/api/" .. conf.deconzKey .. "/sensors/"

local deconz = {}

function deconz.getSensorsData()
    local req = http.create()
    local ok, err = req:request { url = sensorsUrl }
    local data
    if ok then
        local body = req:read "*a"
        data = ba.json.decode(body)
    end
    req:close() 
    return data, err
end

return deconz
