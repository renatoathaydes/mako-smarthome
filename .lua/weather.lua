local http = require "http"
local conf = require "loadconf"

local weatherApiKey = conf.weatherApiKey
local lat, lon = conf.latitude, conf.longitude

local weather = {}

local requestUrl = "https://api.openweathermap.org/data/2.5/weather"

--- Returns the current weather information:
---   time = epoch seconds
---   temp = temperature in degrees Celsius
---   humi = humidity in %
---   pres = pressure in hPa
---   desc = text describing the wheather conditions
---   rain = rain in the last one hour in mm
---   snow = snow in the last one hour in mm
function weather.current()
    local req = http.create()
    local ok, err = req:request { url = requestUrl, query = { units = 'metric', lat = lat, lon = lon, appid = weatherApiKey } }
    local data
    if ok and req:status() == 200 then
        local body = req:read "*a"
        data = ba.json.decode(body)
    end
    req:close() 
    return data, err
end

return weather