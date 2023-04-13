<?lsp
controlPageActive = 'active'
response:include "/smarthome/.fragments/header.lsp"

local deconz = require "deconz"

function lightsData()
   local lightsData, err = deconz.getLightsData()
   local lights, errorMessage = {}, nil
   if lightsData then
      for id, data in pairs(lightsData) do
         local st = data.state
         lights[id] = { name = data.name, on = st.on, bri = st.bri, reachable = st.reachable,
                        hascolor = data.hascolor, type = data.type }
      end
   else
      errorMessage = err
   end
   return lights, errorMessage
end

function sensorsData()
   local sensorsData, err = deconz.getSensorsData()
   local sensors, errorMessage = {}, nil
   if sensorsData then
      for id, data in pairs(sensorsData) do
         local st = data.state
         local cf = data.config
         if st.temperature then
            st.temperature = st.temperature / 100
         end
         if st.humidity then
            st.humidity = st.humidity / 100
         end
         sensors[id] = { name = data.name, on = cf.on, reachable = cf.reachable,
                         daylight = st.daylight, sunrise = st.sunrise, sunset = st.sunset,
                         presence = st.presence,
                         humidity = st.humidity, temperature = st.temperature, pressure = st.pressure,
                         type = data.type }
      end
   else
      errorMessage = err
   end
   return sensors, errorMessage
end

local sensors = {}
local lights, errorMessage = lightsData()
if not errorMessage then
   sensors, errorMessage = sensorsData()
end

?>

<div id='error-message' class='error'><?lsp= errorMessage or '' ?></div>
<h2>Lights</h2>
<div id='lights'></div>
<h2>Sensors</h2>
<div id='sensors'></div>
<script src="js/lights.js"></script>
<script>
const lightsData = <?lsp= ba.json.encode(lights) ?>;
const sensorsData = <?lsp= ba.json.encode(sensors) ?>;

// start websocket connection
const protocol = window.location.protocol;
const host = window.location.host;
const port = window.location.port ? ':' + window.location.port : '';
webSocket = new WebSocket((protocol == 'http:' ? 'ws:' : 'wss:') +
   '//' + host + port + '/smarthome/control-ws.lsp');
webSocket.onopen = (event) => Control(lightsData, sensorsData, webSocket);
</script>
<?lsp
response:include "/smarthome/.fragments/footer.html"
?>
