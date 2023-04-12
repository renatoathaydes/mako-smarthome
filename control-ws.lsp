<?lsp
local deconz = require "deconz"

local function createDeconzEventListener(listener)
   return function(event)
      if not listener.listening then
         error "stopped listening"
      end
      if event.id then
         local sock = listener.sock
         if event.e == 'changed'
            and event.r == 'lights'
            and event.state then
            sock:write(ba.json.encode({
                             id = event.id,
                             type = 'changed',
                             state = event.state
                                     }), true)
         elseif event.e == 'deleted' then
            sock:write(ba.json.encode({
                             id = event.id,
                             type = 'deleted'
                                     }), true)
         end
      end
   end
end

-- handle websocket requests
local function socketHandler(listener)
   return function(sock)
      while true do
         local data = sock:read()
         if not data then break end
         trace('socketHandler handling data: ' .. data)
         data = ba.json.decode(data)
         local response
         if data.id and data.r == 'lights' then
            local res, err = deconz.setLightState(data.id, data)
            if err then
               response = ba.json.encode { error = err }
            elseif #res == 1 and res[1].success then
               response = '{"ok": true}'
            else
               response = ba.json.encode { error = ba.json.encode(res) }
            end
         else
            response = '{"error":"unrecognized WebSocket command"}'
         end
         ba.thread.run(function() sock:write(response, true) end)
      end
      trace 'socketHandler end'
      listener.listening = false
      listener.sock = nil
   end
end

if request:header "Sec-WebSocket-Key" then
   local sock = ba.socket.req2sock(request)
   if sock then
      local listener = { listening = true, sock = sock }
      table.insert(app.deconzListeners, createDeconzEventListener(listener))
      sock:event(socketHandler(listener), "s")
      request:abort()
   end
end
response:senderror(403, "Invalid request")
?>
