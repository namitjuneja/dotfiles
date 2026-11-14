--!nonstrict

-- Natural-language subtitle for the snow widget and panel.
-- Picks a template by situation; the choice is stable for a given day.
-- Placeholders: {win} {from} {to} {peak} {in} {pct} {day} {n} {cnt} {fromS}

local M = {}

local DAYS = { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" }
local STORM_IN = 4

local T = {
  -- today, snow still to come
  upcoming = {
    "Snow {win} · peak {peak}",
    "Flakes arrive around {from}, heaviest near {peak}",
    "Expect {in} of snow, starting {from}",
    "Snow's on the way — {win}",
    "Bundle up, snow rolls in at {from}",
    "{in} on the way, mostly around {peak}",
    "Snow starts {from} and tapers off by {to}",
    "Quiet for now — snow from {from}, {pct}% likely",
  },
  -- today, snowing now, peak still ahead
  ongoing_peak = {
    "Snowing now, heaviest around {peak}",
    "Snow until {to} · peak {peak}",
  },
  -- today, snowing now, peak behind us
  ongoing = {
    "Snowing now, easing around {to}",
    "It's coming down — clears by {to}",
    "Past the heaviest — snow until {to}",
    "Still snowing, {in} total today",
    "Snow continues until {to}",
    "Flakes falling till {to}, {in} total",
    "In the thick of it — wraps up near {to}",
  },
  -- today, snow finished
  ended = {
    "Snow wrapped up at {to}",
    "All done — snow ended {to}",
    "Today's snow is behind us, {in} fell",
    "Flurries finished around {to}",
    "Snow's over for today",
  },
  -- today, snow but no hourly detail
  today_plain = {
    "Snow expected today · {in}",
    "Some snow today, {pct}% chance",
    "Flurries possible today",
  },
  -- dry today, snow tomorrow
  tomorrow = {
    "Dry today · snow tomorrow, {in}",
    "Nothing today, but snow tomorrow{fromS}",
    "Enjoy the dry day — snow tomorrow",
    "Snow returns tomorrow — {in} expected",
    "No snow today · tomorrow brings {in}",
    "Quiet today, flakes tomorrow{fromS}",
  },
  -- dry today, snow in 2–3 days
  near = {
    "No snow today · next up {day}",
    "Dry until {day}, then {in} of snow",
    "Snow returns {day}{fromS}",
    "Next snow {day}, {in} expected",
    "Clear for {n} days — snow {day}",
    "A calm stretch — flakes on {day}",
    "Nothing today. {day} brings snow",
  },
  -- dry today, snow 4+ days out
  far = {
    "Quiet week so far — snow {day}",
    "Dry for {n} days, snow on {day}",
    "Nothing soon · next snow {day}",
    "Clear stretch ahead, snow {day}",
    "Next snow is a few days out — {day}",
  },
  -- dry today, several snowy days later
  snowy_week = {
    "Dry today, {cnt} snowy days ahead",
    "A snowy week ahead — starting {day}",
    "Today's clear · snow on {cnt} days this week",
    "Calm today, then snow on and off",
  },
  -- dry today, a big storm coming
  storm = {
    "Big one coming — {in} on {day}",
    "Storm watch: {in} forecast {day}",
    "Quiet now, but {day} looks heavy — {in}",
    "Brace for {day}: {in} of snow",
  },
  -- nothing all week
  none = {
    "Clear all week",
    "No snow in sight this week",
    "Snow-free week ahead",
    "Nothing but dry days ahead",
    "Not a flake in the 7-day forecast",
    "Smooth sailing — no snow all week",
  },
}

local function ampm(h) return ((h + 11) % 12 + 1) .. (h % 24 < 12 and " am" or " pm") end

-- Weekday index (1=Sun) from "YYYY-MM-DD" (Sakamoto).
local function weekday(date)
  local y, m, d = date:match("(%d+)-(%d+)-(%d+)")
  y, m, d = tonumber(y), tonumber(m), tonumber(d)
  local t = { 0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4 }
  if m < 3 then y = y - 1 end
  return (y + math.floor(y / 4) - math.floor(y / 100) + math.floor(y / 400) + t[m] + d) % 7 + 1
end

-- "2–6 pm", "10 am–2 pm", or "around 4 pm" for a one-hour burst.
local function window(d)
  if d.to - d.from <= 1 then return "around " .. ampm(d.from) end
  local a, b = ampm(d.from), ampm(d.to)
  if a:sub(-2) == b:sub(-2) then a = a:sub(1, -4) end
  return a .. "–" .. b
end

local function amount(d)
  if (d.inches or 0) < 0.3 then return "a dusting" end
  return tostring(d.inches) .. '"'
end

local function seedOf(s)
  local n = 0
  for i = 1, #s do n = (n * 31 + s:byte(i)) % 100003 end
  return n
end

local function fill(tpl, vars)
  local out = tpl:gsub("{(%w+)}", function(k) return vars[k] or "" end)
  return (out:gsub("^%l", string.upper))
end

local function pick(list, seed) return list[seed % #list + 1] end

function M.make(days, now)
  local t = days[1]
  local seed = seedOf(t.date)
  local vars = { ["in"] = amount(t), pct = tostring(math.floor(t.pct or 0)) }

  if t.snow then
    if not t.from then return fill(pick(T.today_plain, seed), vars) end
    vars.from, vars.to, vars.peak, vars.win = ampm(t.from), ampm(t.to), ampm(t.peak or t.from), window(t)
    if now >= t.to then return fill(pick(T.ended, seed), vars) end
    if now >= t.from then
      if (t.peak or 0) > now then return fill(pick(T.ongoing_peak, seed), vars) end
      return fill(pick(T.ongoing, seed), vars)
    end
    return fill(pick(T.upcoming, seed), vars)
  end

  local first, cnt = nil, 0
  for i = 2, #days do
    if days[i].snow then
      cnt = cnt + 1
      first = first or i
    end
  end
  if not first then return fill(pick(T.none, seed), vars) end

  local d = days[first]
  vars = { ["in"] = amount(d), pct = tostring(math.floor(d.pct or 0)), cnt = tostring(cnt), n = tostring(first - 1),
    day = DAYS[weekday(d.date)], fromS = d.from and (" from " .. ampm(d.from)) or "" }
  if (d.inches or 0) >= STORM_IN then return fill(pick(T.storm, seed), vars) end
  if first == 2 then return fill(pick(T.tomorrow, seed), vars) end
  if cnt >= 3 and seed % 3 == 0 then return fill(pick(T.snowy_week, seed), vars) end
  if first <= 4 then return fill(pick(T.near, seed), vars) end
  return fill(pick(T.far, seed), vars)
end

return M
