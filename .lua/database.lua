local db = {}

local sql = luasql.sqlite()

function db.withConnection(f)
    local con = sql:connect('smarthome.db')
    local ok, err = pcall(function() f(con) end)
    if not ok then trace("problem running SQL operation", err) end
    con:close()
end

db.withConnection(function(con)

assert(con:execute [[
CREATE TABLE IF NOT EXISTS Temperature (
  time    INTEGER UNIQUE NOT NULL,
  value   REAL    NOT NULL,
  name    TEXT    NOT NULL,
  UNIQUE(time, name)
)
]])

assert(con:execute [[
CREATE TABLE IF NOT EXISTS Humidity (
  time    INTEGER UNIQUE NOT NULL,
  value   INTEGER,
  name    TEXT    NOT NULL,
  UNIQUE(time, name)
)
]])

assert(con:execute [[
CREATE TABLE IF NOT EXISTS Pressure (
  time    INTEGER UNIQUE NOT NULL,
  value   REAL    NOT NULL,
  name    TEXT    NOT NULL,
  UNIQUE(time, name)
)
]])

assert(con:execute [[
CREATE INDEX IF NOT EXISTS idx_Temperature ON Temperature (name, time);
CREATE INDEX IF NOT EXISTS idx_Humidity ON Humidity (name, time);
CREATE INDEX IF NOT EXISTS idx_Pressure ON Pressure (name, time);
]])

assert(con:execute [[
CREATE TABLE IF NOT EXISTS Weather (
  time    INTEGER NOT NULL PRIMARY KEY,
  temp    REAL    NOT NULL,
  humi    REAL    NOT NULL,
  pres    REAL    NOT NULL,
  rain    REAL,
  snow    REAL,
  desc    TEXT
)
]])

trace('db initialized')

end)

local function insertEntry(state, t, name)
    db.withConnection(function(con)
        local value, query
        if state.humidity then
            query = "INSERT INTO Humidity (time,value,name) VALUES(?,?,?)"
            value = state.humidity
        end
        if state.temperature then
            query = "INSERT INTO Temperature (time,value,name) VALUES(?,?,?)"
            value = state.temperature
        end
        if state.pressure then
            query = "INSERT INTO Pressure (time,value,name) VALUES(?,?,?)"
            value = state.pressure
        end
        if value then
            -- trace ('INSERT', t, name, value)
            local p = con:prepare(query)
            p:bind { {"INTEGER", t}, {"FLOAT", value}, {"TEXT", name} }
            p:execute()
        end
    end)
end

--- Insert Sensor Data.
--- The data must be in the format returned by the deCONZ API.
function db.insertData(data)
    for id, sensor in pairs(data) do
        if sensor.state and sensor.name then
            local st, name = sensor.state, sensor.name
            if st.lastupdated then
                local t = ba.datetime(st.lastupdated .. 'Z'):ticks()
                pcall(function() insertEntry(st, t, name) end)
            end
        end
    end
end

local function insertWeatherEntry(data)
   local time, humi, temp, pres, rain, snow, desc = data.time, data.humi, data.temp, data.pres, data.rain, data.snow, data.desc
   db.withConnection(function(con)
         local query = "INSERT INTO Weather (time,humi,temp,pres,rain,snow,desc) VALUES(?,?,?,?,?,?,?)"
         local p = con:prepare(query)
         p:bind { {"INTEGER", time}, {"FLOAT", humi}, {"FLOAT", temp}, {"FLOAT", pres}, {"FLOAT", rain}, {"FLOAT", snow}, {"TEXT", desc} }
         p:execute()
   end)
end

--- Insert Weather Data.
--- The data must be in the format returned by the OpenWeatherMap API.
function db.insertWeather(data)
   return pcall(function() insertWeatherEntry(data) end)
end

local function rows(con, sql_statement)
  local cursor = assert(con:execute(sql_statement))
  return function()
    return cursor:fetch()
  end
end

local twoWeeks <const> = 14 * 24 * 60 * 60

local function sqlWhereDates(startTime, endTime)
    startTime = startTime or (os.time() - twoWeeks)
    endTime = endTime or os.time()
    return " WHERE time <= " .. endTime .. " AND time >= " .. startTime
end

local function forEach(tbl, callback, startTime, endTime)
    
    db.withConnection(function(con)
        for time, name, value in rows(con,
            "SELECT time, name, value FROM " .. tbl .. 
            sqlWhereDates(startTime, endTime)) do
            callback(time, name, value)
        end
    end)
end

function db.forEachTemperature(callback)
    forEach("Temperature", callback)
end

function db.forEachHumidity(callback)
    forEach("Humidity", callback)
end

function db.forEachPressure(callback)
    forEach("Pressure", callback)
end

function db.forEachWeatherEntry(callback, startTime, endTime)
    db.withConnection(function(con)
        for time, humi, temp, pres, rain, snow, desc in
        rows(con, "SELECT time, humi, temp, pres, rain, snow, desc FROM Weather" ..
                sqlWhereDates(startTime, endTime)) do
            callback(time, humi, temp, pres, rain, snow, desc)
        end
    end)
end

return db
