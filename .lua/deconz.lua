local http = require "http"
local conf = require "loadconf"

local sensorsUrl = conf.sensorsServerUrl .. "/api/" .. conf.deconzKey .. "/sensors/"
local lightsUrl = conf.sensorsServerUrl .. "/api/" .. conf.deconzKey .. "/lights/"

local deconz = {}

local function getJsonData(url)
   local req = http.create()
   local ok, err = req:request { url = url }
   local data
   if ok then
      local body = req:read "*a"
      data = ba.json.decode(body)
   end
   req:close()
   return data, err
end

local function putJsonData(url, path, data)
   local req = http.create()
   local ok, err = req:request {
      url = string.format('%s%s', url, path),
      method = "PUT",
      header = {["Content-Type"] = "application/json"} }
   local res
   if ok then
      ok, err = req:write(ba.json.encode(data))
      if ok then
         local body = req:read "*a"
         res = ba.json.decode(body)
      end
   end
   req:close()
   return res, err
end

function deconz.getSensorsData()
   return getJsonData(sensorsUrl)
end

function deconz.getLightsData()
   return getJsonData(lightsUrl)
end

function deconz.setLightState(id, on, bri, hue, sat, transitiontime)
   return putJsonData(lightsUrl, id .. '/state',
                      {on = on, bri = bri, sat = sat, transitiontime = transitiontime})
end

return deconz
