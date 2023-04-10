<?lsp
controlPageActive = 'active'
response:include "/smarthome/.fragments/header.lsp"

local deconz = require "deconz"

local lightsData, err = deconz.getLightsData()
local lights, errorMessage = {}, ''
if lightsData then
   lights = lightsData
else
   errorMessage = err
end
?>

<div id='error-message' class='error'><?lsp= errorMessage ?></div>
<h2>Lights</h2>
<div id='lights'></div>
<script src="js/lights.js"></script>
<script>
const lightsData = <?lsp= ba.json.encode(lights) ?>;

// start websocket connection
const protocol = window.location.protocol;
const host = window.location.host;
const port = window.location.port ? ':' + window.location.port : '';
webSocket = new WebSocket((protocol == 'http:' ? 'ws:' : 'wss:') +
   '//' + host + port + '/smarthome/control-ws.lsp');
webSocket.onopen = (event) => Lights(lightsData, webSocket);
</script>
<?lsp
response:include "/smarthome/.fragments/footer.html"
?>
