local tables = {}

function tables.copy(tbl)
   local result = {}
   for k,v in pairs(tbl) do
      result[k] = v
   end
   return result
end

return tables
