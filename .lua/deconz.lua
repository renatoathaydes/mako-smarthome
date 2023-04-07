local http = require "http"
local conf = require "loadconf"

local deconz = {}

function deconz.getSensorsData()
    local req = http.create()
    local ok, err = req:request { url = "http://192.168.1.2/api/" .. conf.deconzKey .. "/sensors/" }
    local data
    if ok then
        local body = req:read "*a"
        data = ba.json.decode(body)
    end
    req:close() 
    return data, err
end

return deconz