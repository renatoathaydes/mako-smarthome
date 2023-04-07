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

local timers = {}

function timers.startCollectingSensorData(period)
    sensorDataCollectionTime:set(period, false, true)
end

function timers.startCollectingWeatherData(period)
    weatherDataCollectionTime:set(period, false, true)
end

return timers