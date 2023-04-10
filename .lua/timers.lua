local deconz = require "deconz"
local db = require "database"
local weather = require "weather"

-- must be global so it won't be GC'ed,
-- and can be restarted.
if sensorDataCollectionTime then sensorDataCollectionTime:cancel() end
sensorDataCollectionTime = ba.timer(function()
    local data, err = deconz.getSensorsData()
    if data then
        db.insertData(data)
        trace('sensor data has been inserted')
    else
        trace('error collecting sensor data', err)
    end
    return true
end)

if weatherDataCollectionTime then weatherDataCollectionTime:cancel() end
weatherDataCollectionTime = ba.timer(function()
    local data, err = weather.current()
    if data then
        db.insertWeather(data)
        trace('weather data has been inserted')
    else
        trace('error collecting weather data', err)
    end
    return true
end)

local function connectDeconzWebSocket(notifier)
   return ba.timer(function()
         local ok, err = pcall(function() deconz.connectWebSocket(notifier) end)
         if not ok then
            trace('error starting deconz websocket', err)
            return true -- retry connection
         end
         return false -- timer used only for retries
   end)
end

local timers = {}

function timers.startCollectingSensorData(period)
    sensorDataCollectionTime:set(period, false, true)
end

function timers.startCollectingWeatherData(period)
    weatherDataCollectionTime:set(period, false, true)
end

function timers.startDeconzWebSocket(period)
   local listeners = {}
   connectDeconzWebSocket(function (event)
         local removals = {}
         for i, listener in pairs(listeners) do
            local ok, err = pcall(function () listener(event) end)
            if not ok then
               trace('Removing deCONZ event listener', listener, err)
               table.insert(removals, i)
            end
         end
         for i, listenerIndex in pairs(removals) do
            table.remove(listeners, listenerIndex - (i - 1))
         end
         if #removals > 0 then
            trace('Number of deCONZ listeners', #listeners)
         end
   end):set(period, true, false)
   return listeners
end

return timers
