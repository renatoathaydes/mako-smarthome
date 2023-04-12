local http = require "http"
local conf = require "loadconf"

local sensorsUrl = conf.sensorsServerUrl .. "/api/" .. conf.deconzKey .. "/sensors/"
local lightsUrl = conf.sensorsServerUrl .. "/api/" .. conf.deconzKey .. "/lights/"
local metadataUrl = conf.sensorsServerUrl .. "/api/" .. conf.deconzKey .. "/config"

local deconz = {}

local function readJsonResponse(req)
   local status = req:status()
   local body = req:read "*a"
   if status == 200 then
      if string.match(req:header()['Content-Type'] or '', 'application/json') then
         return ba.json.decode(body), nil
      else
         return nil, string.format('not a JSON response: %s', body)
      end
   end
   return nil, string.format('bad status (%d): %s', status, body)
end

local function getJsonData(url)
   local req = http.create()
   local ok, err = req:request { url = url }
   local data
   if ok then
      data, err = readJsonResponse(req)
   end
   req:close()
   return data, err
end

local function putJsonData(url, path, data)
   local req = http.create()
   local body = ba.json.encode(data)
   local ok, err = req:request {
      url = string.format('%s%s', url, path),
      method = "PUT",
      size = #body
   }
   local res
   if ok then
      ok, err = req:write(body)
      if ok then
         res, err = readJsonResponse(req)
      end
   end
   req:close()
   return res, err
end

local function http2ws(url)
   return string.gsub(url, "http(s*)://", "ws://", 1)
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

local wsServer = http2ws(conf.sensorsServerUrl)

local function findWsPort()
   local meta = getJsonData(metadataUrl)
   return meta.websocketport
end

function deconz.connectWebSocket(notifier)
   local server = wsServer .. ':' .. tostring(findWsPort())
   local req = http.create()
   local ok, err = req:request { url = server }
   if not ok then req:close(); error(err) end
   if req:status() ~= 101 then
      trace("deCONZ server responded with unexpected status: ", req:status())
      req:close()
      error("deCONZ server did not open websocket: " .. server)
   end
   local sock = ba.socket.http2sock(req)
   sock:event(function(s)
         while true do
            local data = s:read()
            if not data then break end
            notifier(ba.json.decode(data))
         end
         trace 'deCONZ Websocket terminated'
   end)
end

return deconz
