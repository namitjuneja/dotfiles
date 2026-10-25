--!nonstrict

-- Taskbar for niri. Same idea as the built-in taskbar (icon + title per window, click to
-- focus), but windows marked with the niri skip bind (window-cycle.sh skip, Mod+N)
-- are minimized: window-cycle.sh parks them on the "stash" workspace, and this taskbar still
-- lists them under the workspace they came from, drawn dimmer in its original slot;
-- clicking one restores it. Marks are files named after window ids in
-- $XDG_RUNTIME_DIR/niri-skip holding the origin workspace as JSON.
--
-- Event driven, no timer: a niri event-stream follower repolls when windows or workspaces
-- change, and window-cycle.sh pushes a "refresh" IPC event whenever it changes a mark.

local ICON_RASTER_SIZE = 64

local EVENTS_CMD = "niri msg event-stream | grep --line-buffered -E '^(Window|Workspace)'"

-- One JSON array: the windows to show, in on-screen order (tiled by column then row,
-- floating last), with focus and skip state.
local LIST_CMD = [[
d="${XDG_RUNTIME_DIR:-/tmp}/niri-skip"
marks=$(for f in "$d"/*; do [ -f "$f" ] && printf '%s %s\n' "${f##*/}" "$(cat "$f")"; done 2>/dev/null \
  | jq -Rn '[inputs | split(" ") | {key: .[0], value: (.[1:] | join(" ") | fromjson? // {})}] | from_entries')
ws=$(niri msg --json workspaces | jq '.[] | select(.is_focused) | .id')
niri msg --json windows | jq -c --argjson ws "${ws:-null}" --argjson marks "${marks:-{\}}" --arg only "$ONLY_ACTIVE" '
  # a minimized window lives on the stash workspace but belongs to the workspace it came from
  map(. + {skipped: ($marks[.id | tostring] != null and ($marks[.id | tostring].auto | not)),
           parked: ($marks[.id | tostring] != null),
           home: ($marks[.id | tostring].ws // .workspace_id)})
  | [.[] | select($only != "1" or .home == $ws)]
  # a minimized window keeps its slot: tiled ones sit at their old column, floating ones with floating
  | map(. + {col: (if .parked then $marks[.id | tostring].col else .layout.pos_in_scrolling_layout[0] end),
             row: (if .parked and $marks[.id | tostring].col != null then -1 else (.layout.pos_in_scrolling_layout[1] // 0) end)})
  | sort_by([.home, (if .col == null then 1 else 0 end), (.col // 0), .row, .id])
  | map({id, app_id: (.app_id // ""), title: (.title // ""), focused: .is_focused, skipped, parked, floating: (.col == null)})'
]]

local windows = nil
local lastJson = nil
local iconCache = {}
local busy = false
local again = false

local function utf8Sub(s, n)
  local len = utf8.len(s)
  if not len or len <= n then
    return s
  end
  local cut = utf8.offset(s, n) or (#s + 1)
  return s:sub(1, cut - 1) .. "…"
end

-- Combining long stroke overlay after each character; plain text if not valid UTF-8.
local function strike(text)
  if text == "" or utf8.len(text) == nil then
    return text
  end
  local out = {}
  for _, code in utf8.codes(text) do
    table.insert(out, utf8.char(code))
    table.insert(out, "\u{0336}")
  end
  return table.concat(out)
end

local function focusWindow(id)
  noctalia.runAsync({ "niri", "msg", "action", "focus-window", "--id", tostring(id) }, function() end)
end

-- A skipped window is minimized on the stash workspace: bring it back to where it came from.
local function restoreWindow(id)
  noctalia.runAsync({ "sh", "-c", '"$HOME/.config/niri/window-cycle.sh" restore ' .. tostring(id) }, function() end)
end

local function render()
  if windows == nil or #windows == 0 then
    barWidget.setVisible(false)
    return
  end
  barWidget.setVisible(true)

  local iconSize = noctalia.getConfig("icon_size") or 22
  local showTitle = noctalia.getConfig("show_window_title")
  if showTitle == nil then
    showTitle = true
  end
  local maxChars = noctalia.getConfig("title_max_chars") or 24
  local inactive = (noctalia.getConfig("inactive_opacity") or 75) / 100
  local skippedOpacity = (noctalia.getConfig("skipped_opacity") or 40) / 100
  local skippedColor = noctalia.getConfig("skipped_color") or "on_surface_variant"
  local useStrike = noctalia.getConfig("skipped_strikethrough")
  if useStrike == nil then
    useStrike = false
  end
  local useBadge = noctalia.getConfig("skipped_badge")
  if useBadge == nil then
    useBadge = false
  end

  local items = {}
  local prev = nil
  for _, w in ipairs(windows) do
    -- thin divider where the tiled windows end and the floating ones begin
    if prev and w.floating and not prev.floating then
      table.insert(items, ui.row({ key = "sep", opacity = 0.4, align = "center", paddingH = 2 }, { ui.label({ text = "│", color = "on_surface_variant" }) }))
    end
    prev = w
    local id = w.id
    local isSkipped = w.skipped
    local opacity = 1.0
    if not w.focused then
      opacity = isSkipped and skippedOpacity or inactive
    end

    local kids = {}
    local iconPath = nil
    if w.app_id ~= "" then
      iconPath = iconCache[w.app_id]
      if iconPath == nil then
        iconPath = noctalia.appIconPath(w.app_id, ICON_RASTER_SIZE) or false
        iconCache[w.app_id] = iconPath
      end
    end
    if iconPath then
      table.insert(kids, ui.image({ path = iconPath, width = iconSize, height = iconSize, fit = "contain" }))
    else
      table.insert(kids, ui.glyph({ name = "app-window-filled", size = iconSize, color = "on_surface" }))
    end
    if isSkipped and useBadge then
      table.insert(kids, ui.glyph({ name = "eye-off", size = math.max(10, math.floor(iconSize * 0.6)), color = skippedColor }))
    end
    if showTitle then
      local title = utf8Sub(w.title ~= "" and w.title or w.app_id, maxChars)
      if isSkipped and useStrike then
        title = strike(title)
      end
      table.insert(kids, ui.label({
        text = title,
        color = isSkipped and skippedColor or "on_surface",
        fontWeight = w.focused and "bold" or "normal",
        maxLines = 1,
      }))
    end

    table.insert(items, ui.row({
      key = "win-" .. tostring(id),
      gap = 6,
      align = "center",
      paddingH = 8,
      paddingV = 3,
      radius = 8,
      opacity = opacity,
      fill = w.focused and "primary/0.35" or (isSkipped and "primary/0.0" or "on_surface/0.24"),
      onClick = function()
        if w.parked then
          restoreWindow(id)
        else
          focusWindow(id)
        end
      end,
    }, kids))
  end

  local props = { gap = 4, align = "center" }
  barWidget.render(barWidget.isVertical() and ui.column(props, items) or ui.row(props, items))
end

local function poll()
  if busy then
    again = true
    return
  end
  busy = true
  local only = noctalia.getConfig("only_active_workspace")
  if only == nil then
    only = true
  end
  noctalia.runAsync({ "sh", "-c", "ONLY_ACTIVE=" .. (only and "1" or "0") .. "\n" .. LIST_CMD }, function(result)
    busy = false
    if result.exitCode == 0 then
      local out = noctalia.string.trim(result.stdout or "")
      -- the event stream fires many times per action; only redraw when the list really changed
      if out ~= lastJson then
        local ok, decoded = pcall(noctalia.json.decode, out)
        if ok and type(decoded) == "table" then
          lastJson = out
          windows = decoded
          render()
        end
      end
    end
    if again then
      again = false
      poll()
    end
  end)
end

function onIpc(ev)
  if ev == "refresh" then
    poll()
  end
end

noctalia.runStream(EVENTS_CMD, function()
  poll()
end)
poll()
