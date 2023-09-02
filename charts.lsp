<?lsp
chartsPageActive = 'active'
headerAdditions = '<link rel="stylesheet" href="/smarthome/charts.css">'
response:include "/smarthome/.fragments/header.lsp"

local selectedClass = 'selected-chart'
local dataKind = request:data('kind') or 'temp'
local tempClass, humiClass, pressClass = '', '', ''
if dataKind == 'humi' then
   humiClass = selectedClass
elseif dataKind == 'pres' then
   pressClass = selectedClass
else
   tempClass = selectedClass
end
?>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<div class="chart-selector">
  <a class="<?lsp= tempClass ?>" href="?kind=temp">Temperature</a>
  <a class="<?lsp= humiClass ?>" href="?kind=humi">Humidity</a>
  <a class="<?lsp= pressClass ?>" href="?kind=pres">Pressure</a>
</div>
<?lsp

local db = require "database"

weatherData = {times = {}, values = {}} -- global so the included LSP page can use it

if dataKind == 'temp' then
   db.forEachWeatherEntry(function(time, humi, temp, pres, rain, snow, desc)
         table.insert(weatherData.times, 1*time)
         table.insert(weatherData.values, 1*temp) -- temperatures already in C
   end)
end

local dbForEach

if dataKind == 'humi' then
   dbForEach = db.forEachHumidity
   dataLegend = 'Humidity (%)'
elseif dataKind == 'pres' then
   dbForEach = db.forEachPressure
   dataLegend = 'Pressure (Pa/10)'
else
   dbForEach = db.forEachTemperature
   dataLegend = 'Temperature (C)'
end


local sensorsData = {}
local n = 1
dbForEach(function(time, name, value)
    local data = sensorsData[name]
    if not data then -- initialize the data table
       data = {values = {}, times = {}, id = tostring(n)}
       n = n + 1
       sensorsData[name] = data
    end
    table.insert(data.times, 1*time)
    table.insert(data.values, value/100)
end)

-- write one canvas tag for each sensor
for lname, data in pairs(sensorsData) do
   -- must be global so the included LSP page can use it
   name, sensorData = lname, data
   response:include('.fragments/chart.lsp', true)
end

response:include "/smarthome/.fragments/footer.html"
?>
