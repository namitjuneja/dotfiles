--!nonstrict

-- Panel: same outlook as the desktop widget, opened by clicking the bar icon.

local WD = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" }

-- Weekday index (1=Sun) from "YYYY-MM-DD" (Sakamoto).
local function weekday(date)
  local y, m, d = date:match("(%d+)-(%d+)-(%d+)")
  y, m, d = tonumber(y), tonumber(m), tonumber(d)
  local t = { 0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4 }
  if m < 3 then y = y - 1 end
  return (y + math.floor(y / 4) - math.floor(y / 100) + math.floor(y / 400) + t[m] + d) % 7 + 1
end

local function subtitle(days)
  if days[1].snow then return "Snow expected today" end
  for i, d in ipairs(days) do
    if d.snow then return "Next snow " .. (i == 2 and "tomorrow" or WD[weekday(d.date)]) end
  end
  return "Clear all week"
end

local STORM_IN = 4 -- forecast inches that count as a snowstorm

local function columns(data, size, gap)
  local cols = {}
  for i, day in ipairs(data.days) do
    local snow = day.snow
    local storm = snow and (day.inches or 0) >= STORM_IN
    local kids = {
      ui.label({ text = i == 1 and "Today" or WD[weekday(day.date)], fontSize = 12,
        color = i == 1 and "on_surface" or "on_surface_variant", fontWeight = i == 1 and "bold" or nil, opacity = i == 1 and 1 or 0.7 }),
      ui.box({ width = 1, height = math.max(1, 6 - gap), fill = "#00000000" }),
      (storm and ui.image({ path = noctalia.pluginDir() .. "/assets/storm.png", width = size, height = size * 0.888, fit = "contain" })
        or ui.glyph({ name = "snowflake", size = size, color = snow and "primary" or "on_surface_variant",
          opacity = snow and 1 or 0.15 })),
      ui.box({ width = 1, height = math.max(1, 7 - gap), fill = "#00000000" }), -- flake centred between label and amount
    }
    kids[#kids + 1] = ui.label({ text = snow and (day.inches > 0 and (tostring(day.inches) .. '"') or "snow") or " ",
      fontSize = 12, color = "primary" })
    kids[#kids + 1] = ui.label({ text = snow and (tostring(math.floor(day.pct or 0)) .. "%") or " ",
      fontSize = 11, color = "on_surface_variant", opacity = 0.7 })
    kids[#kids + 1] = ui.box({ width = 1, height = math.max(1, 7 - gap), fill = "#00000000" }) -- separates snow info from temps
    kids[#kids + 1] = ui.column({ gap = 1, align = "center" }, {
      ui.label({ text = tostring(day.hi) .. "°", fontSize = 12, color = "on_surface" }),
      ui.label({ text = tostring(day.lo) .. "°", fontSize = 12, color = "on_surface_variant", opacity = 0.5 }),
    })
    cols[#cols + 1] = ui.column({ gap = gap, align = "center", width = 62, height = 170, paddingV = 12, radius = 14,
      fill = i == 1 and "on_surface/0.11" or nil }, kids)
  end
  return ui.row({ gap = 4, align = "center" }, cols)
end

-- Side card: today's temperature through the day. Same height and fill as the Today pill.
local function sideCard(data)
  local items = {}
  for i, p in ipairs(data.periods or {}) do
    if i > 1 then items[#items + 1] = ui.box({ width = 108, height = 1, fill = "on_surface/0.07" }) end
    items[#items + 1] = ui.row({ width = 108, flexGrow = 1, align = "center" }, {
      ui.column({ flexGrow = 1, align = "start" }, {
        ui.label({ text = p.name, fontSize = 12, color = "on_surface_variant", opacity = 0.6 }),
      }),
      ui.row({ gap = 5, align = "end" }, {
        ui.label({ text = tostring(p.c) .. "°", fontSize = 13, color = "on_surface", opacity = 0.8 }),
        ui.label({ text = tostring(p.f or "–") .. "°F", fontSize = 10, color = "on_surface_variant", opacity = 0.45 }),
      }),
    })
  end
  return ui.column({ gap = 0, align = "center", width = 132, height = 170,
    paddingH = 12, radius = 14, fill = "on_surface/0.11" }, items)
end

local function windWord(mph)
  if type(mph) ~= "number" then return "" end
  if mph < 4 then return "Calm" elseif mph < 12 then return "Light"
  elseif mph < 20 then return "Breezy" elseif mph < 30 then return "Windy" end
  return "Strong"
end

local data = noctalia.state.get("snow.data")

local function render()
  if data == nil or data.days == nil then
    panel.render(ui.label({ text = "…", fontSize = 14, color = "on_surface_variant" }))
    return
  end
  panel.render(ui.column({ gap = 16, align = "start", paddingTop = 18, paddingBottom = 28, paddingH = 20 }, {
    ui.row({ width = 612, align = "end" }, {
      ui.column({ gap = 4, align = "start", flexGrow = 1 }, {
        ui.label({ text = data.days[1].snow and "Snow today" or "No snow today",
          fontSize = 26, fontWeight = "bold", color = "on_surface" }),
        ui.label({ text = subtitle(data.days), fontSize = 12, color = "on_surface_variant", opacity = 0.6 }),
      }),
      ui.column({ gap = 4, align = "end" }, {
        ui.label({ text = tostring(data.now_c or "–") .. "°C", fontSize = 26, fontWeight = "bold", color = "on_surface" }),
        ui.row({ gap = 6, align = "center" }, {
          ui.label({ text = "Feels " .. tostring(data.feels_c or "–") .. "°", fontSize = 12, color = "on_surface_variant", opacity = 0.6 }),
          ui.glyph({ name = "wind", size = 13, color = "on_surface_variant", opacity = 0.6 }),
          ui.label({ text = windWord(data.wind) .. " · " .. tostring(data.wind or "–") .. " mph", fontSize = 12, color = "on_surface_variant", opacity = 0.6 }),
        }),
      }),
    }),
    ui.row({ gap = 16, align = "start" }, { columns(data, 26, 5), sideCard(data) }),
  }))
end

noctalia.state.watch("snow.data", function(v)
  if type(v) == "table" then
    data = v
    render()
  end
end)

function onOpen(_context)
  data = noctalia.state.get("snow.data") or data
  render()
end

render()
