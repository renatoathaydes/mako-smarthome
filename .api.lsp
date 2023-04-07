<?lsp
local data = {}
for p in paths do
  table.insert(data, p)
end
response:json({data = data})
?>