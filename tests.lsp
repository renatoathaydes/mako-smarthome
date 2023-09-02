<?lsp
headerAdditions = '<link rel="stylesheet" href="/smarthome/js/home.css">'
response:include "/smarthome/.fragments/header.lsp"

print(ba.datetime"NOW")

page.count = (page.count or 0) + 1

print('You are visitor ', page.count)

if page.count % 5 == 0 then
?>
<h1>Wow cool</h1>
<?lsp
end
print('data:', ba.json.encode(request:data()))

--package.loaded["database"] = nil

local db = require "database"
    db.withConnection(function(con)
        -- local query = "SELECT * FROM Temperature WHERE name = 'Downstairs Thermometer' ORDER BY time DESC LIMIT 10"
          local query = "SELECT * FROM Pressure ORDER BY time DESC LIMIT 10"
          local cur = con:execute(query)
          local row = cur:fetch({}, "a")
        while row do
            row.time = ba.datetime(1 * row.time):tostring()
            print(ba.json.encode(row))
            row = cur:fetch({}, "a")
        end
    end)

-- local conf = require "loadconf"

-- local http = require "http"

-- local weatherApiKey = conf.weatherApiKey
-- local lat, lon = 0.0,0.0

-- local weather = {}

-- local requestUrl = "https://api.openweathermap.org/data/2.5/weather"

-- local function current()
--     local req = http.create()
--     local ok, err = req:request { url = requestUrl, query = { units = 'metric', lat = lat, lon = lon, appid = weatherApiKey } }
--     local data
--     if ok and req:status() == 200 then
--         local body = req:read "*a"
--         data = ba.json.decode(body)
--     end
--     req:close() 
--     return data, err
-- end

-- local data,err = current()

-- if data then
--     local time, humi, temp, pres = data.dt, data.main.humidity, data.main.temp, data.main.pressure
--     local rain = data.rain and data.rain['1h']
--     local snow = data.snow and data.snow['1h']
--     local desc = data.weather and data.weather[1] and data.weather[1].main

--     print(ba.json.encode({t=time, h=humi, temp=temp, pres=pres, rain=rain, snow=snow, desc=desc}))
-- else
--     print(err)
-- end


-- print(ba.datetime("2023-04-04T10:51:26.289z"):ticks())
-- print(ba.datetime(1680605486))

response:include "/smarthome/.fragments/footer.html"

?>
