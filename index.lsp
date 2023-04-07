<?lsp
response:include "/smarthome/.fragments/header.html"
?>
<table>
    <thead>
        <th>Time</th>
        <th>Sensor</th>
        <th>Value</th>
    </thead>
<tbody>
<?lsp
-- ok, err = ba.exec('systemctl --all list-unit-files')
-- if ok then print('<pre>',  ok, '</pre>')
-- else print('<pre>error:',  err, '</pre>') end

local db = require "database"

db.forEachTemperature(function(time, name, value)
    response:write('<tr>')
    response:write('<td>', ba.datetime(1*time):tostring(120), '</td>')
    response:write('<td>', name, '</td>')
    response:write('<td>', tostring(value), '</td>')
end)

?>
</tbody>
</table>
<?lsp
response:include "/smarthome/.fragments/footer.html"
?>
