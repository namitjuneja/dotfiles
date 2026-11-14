--!nonstrict

-- Bar icon: snowflake lit (yellow) when today's chance of snow >= threshold, dim otherwise.
-- Hover: 7-day summary tooltip. Click: panel.

local SNOW = "#FFEF00" -- accent for everything snow (matches assets/storm.png)
local WD = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" }
local data = noctalia.state.get("snow.data")

local function weekday(date)
  local y, m, d = date:match("(%d+)-(%d+)-(%d+)")
  y, m, d = tonumber(y), tonumber(m), tonumber(d)
  local t = { 0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4 }
  if m < 3 then y = y - 1 end
  return (y + math.floor(y / 4) - math.floor(y / 100) + math.floor(y / 400) + t[m] + d) % 7 + 1
end

local function render()
  local threshold = noctalia.getConfig("threshold") or 30
  local today = data and data.days and data.days[1]
  local lit = today ~= nil and today.snow and (today.pct or 0) >= threshold
  local storm = lit and (today.inches or 0) >= 4 -- snowstorm threshold (inches)
  barWidget.render(storm
    and ui.image({ path = noctalia.pluginDir() .. "/assets/storm.png", width = 16, height = 14.2, fit = "contain" })
    or ui.glyph({ name = "snowflake", color = lit and SNOW or "on_surface_variant", opacity = lit and 1 or 0.4 }))
  if data == nil or data.days == nil then
    barWidget.setTooltip("Snow outlook loading…")
    return
  end
  local lines = { string.format("Now %d°C / %d°F", data.now_c or 0, data.now_f or 0), "" }
  for i, day in ipairs(data.days) do
    local name = i == 1 and "Today" or WD[weekday(day.date)]
    lines[#lines + 1] = day.snow
      and string.format('%s  %d°/%d°  snow %s" · %d%%', name, day.hi or 0, day.lo or 0, tostring(day.inches), math.floor(day.pct or 0))
      or string.format('%s  %d°/%d°  no snow', name, day.hi or 0, day.lo or 0)
  end
  barWidget.setTooltip(table.concat(lines, "\n"))
end

noctalia.state.watch("snow.data", function(v)
  if type(v) == "table" then
    data = v
    render()
  end
end)

function update()
  render()
end

function onClick()
  noctalia.togglePanel("namitjuneja/snow-outlook:panel")
end

render()
