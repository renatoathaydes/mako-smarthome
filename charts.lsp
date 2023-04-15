<?lsp
chartsPageActive = 'active'
response:include "/smarthome/.fragments/header.lsp"
?>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<?lsp

local db = require "database"

weatherData = {times = {}, temps = {}} -- global so the included LSP page can use it
db.forEachWeatherEntry(function(time, humi, temp, pres, rain, snow, desc)
    table.insert(weatherData.times, 1*time)
    table.insert(weatherData.temps, 1*temp) -- temperatures already in C
end)

local sensorsData = {}
local n = 1
db.forEachTemperature(function(time, name, value)
    local data = sensorsData[name]
    if not data then
        data = {temps = {}, times = {}, id = tostring(n)}
        n = n + 1
        sensorsData[name] = data
    end
    table.insert(data.times, 1*time)
    table.insert(data.temps, value / 100) -- temperatures come in as 100 * C
end)

-- write one canvas tag for each sensor
for lname, data in pairs(sensorsData) do
    name, sensorData = lname, data -- must be global so the included LSP page can use it
    response:include('.fragments/chart.lsp', true)
end

response:include "/smarthome/.fragments/footer.html"
?>
