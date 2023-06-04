local http = require "http"
local conf = require "loadconf"
local tables = require "tables"

local weatherApiKey = conf.weatherApiKey
local lat, lon = conf.latitude, conf.longitude

local latestData = {
   -- immutable
   lat = lat,
   lon = lon,
   -- updatable fields
   temp = nil,
   humi = nil,
   pres = nil,
   desc = nil,
   rain = nil,
   snow = nil,
}

local function validateData(data)
   if not data.dt then return nil, "dt is missing" end
   if not data.main then return nil, "main is missing" end
   if not data.main.humidity then return nil, "humidity is missing" end
   if not data.main.temp then return nil, "temp is missing" end
   if not data.main.pressure then return nil, "pressure is missing" end
   if not data.weather or #data.weather == 0 then return nil, "weather section is missing" end
   if not data.weather[1].description then
      if data.weather[1].main then
         data.weather[1].description = data.weather[1].main
      else
         data.weather[1].description = ""
      end
   end
   return data, nil
end

-- Example data:
--{"coord":{"lon":17.8172,"lat":59.1954},
--"weather":[{"id":800,"main":"Clear","description":"clear sky","icon":"01d"}],
--"base":"stations",
--"main":{"temp":15.83,"feels_like":14.64,"temp_min":14.68,"temp_max":16.97,"pressure":1021,"humidity":45},
--"visibility":10000,"wind":{"speed":2.57,"deg":310},"clouds":{"all":0},"dt":1685888909,
--"sys":{"type":2,"id":2012100,"country":"SE","sunrise":1685842944,"sunset":1685908313}
--"timezone":7200,"id":2720114,"name":"Botkyrka Kommun","cod":200}
local function rememberData(rawData)
   local data, err = validateData(rawData)
   if err then
      return nil, err
   end
   local result = tables.copy(latestData)
   result.time = data.dt
   result.temp = data.main.temp
   result.humi = data.main.humidity
   result.pres = data.main.pressure
   result.desc = data.weather[1].description
   result.rain = data.rain and data.rain['1h']
   result.snow = data.snow and data.snow['1h']
   latestData = result
   return result, nil
end

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
      trace('weather data received', body)
      data, err = rememberData(ba.json.decode(body))
   end
   req:close()
   return data, err
end

--- Returns the latest collected data, plus the configured lat and lon (location).
function weather.latest()
   return latestData
end

return weather
