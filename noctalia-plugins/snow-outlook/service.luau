--!nonstrict

-- Fetches the outlook (fetch.py -> Open-Meteo) every 30 min and publishes it
-- to noctalia.state "snow.data" for the desktop widget, bar widget and panel.

local REFRESH_MS = 30 * 60 * 1000
local busy = false

local function refresh()
  if busy then return end
  busy = true
  noctalia.runAsync({ "python3", noctalia.pluginDir() .. "/fetch.py" }, function(r)
    busy = false
    if r.exitCode == 0 then
      local ok, decoded = pcall(noctalia.json.decode, r.stdout)
      if ok and type(decoded) == "table" and decoded.days and #decoded.days > 0 then
        noctalia.state.set("snow.data", decoded)
      end
    else
      noctalia.log("snow-outlook fetch failed: " .. tostring(r.stderr))
    end
  end)
end

function update()
  noctalia.setUpdateInterval(REFRESH_MS)
  refresh()
end

noctalia.setUpdateInterval(REFRESH_MS)
refresh()
