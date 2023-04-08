<?lsp
local deconz = require "deconz"

-- handle websocket requests
local function socketHandler(sock)
   while true do
      local data = sock:read()
      if not data then break end
      trace('socketHandler handling data: ' .. data)
      data = ba.json.decode(data)
      if data.id and data.on then
         deconz.setLightState(data.id, data.on)
         ba.thread.run(function() sock:write('refresh', true) end)
      else
         ba.thread.run(function() sock:write('unrecognized WebSocket command', true) end)
      end
   end
   trace 'socketHandler end'
end

if request:header "Sec-WebSocket-Key" then
   local sock = ba.socket.req2sock(request)
   if sock then
      sock:event(socketHandler, "s")
      request:abort()
   end
   response:senderror(403, "Invalid request")
end

-- handle HTTP requests
controlPageActive = 'active'
response:include "/smarthome/.fragments/header.lsp"
local deconz = require "deconz"
?>
<h2>Control Page</h2>
<div id='error-message' class='error'></div>   
<?lsp
local lightsData, err = deconz.getLightsData()
local lights = {}
if lightsData then
   lights = lightsData
else
   print('<pre>', 'ERROR: ', err, '</pre>')
end

for id, light in pairs(lights) do
   response:write('<div id="', id, '" class="light',
                  light.state.on and ' light-on' or '',
                  '"><span>', light.name, '</span><img src="',
                  light.state.on and 'images/light-bulb-solid.svg' or 'images/light-bulb.svg',
                  '"></span></div>')
end
?>
<script>
const url = window.location.toString();
const protocol = window.location.protocol;
webSocket = new WebSocket(url.replace(protocol, protocol == 'http:' ? 'ws:' : 'wss:'));
   webSocket.onopen = (event) => {
      Array.from(document.getElementsByClassName('light')).forEach((light) => {
        light.addEventListener('click', click => {
          webSocket.send(`{"id": "${light.id}", "on": ${!light.classList.contains('light-on')}}`);
        });
      });
   };
   webSocket.onmessage = (event) => {
      console.log('Got server message: ' + event.data);
      switch (event.data) {
         case 'refresh': window.location.reload(); break;
         default: document.getElementById('error-message').textContent = event.data;
      }
   };
</script>
<?lsp
response:include "/smarthome/.fragments/footer.html"
?>
