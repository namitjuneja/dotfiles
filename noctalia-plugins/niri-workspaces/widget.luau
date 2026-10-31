--!nonstrict

-- Workspace indicator for niri. Like the built-in workspaces widget (one pill per workspace,
-- focused one highlighted, click to switch) but only lists workspaces 1..max_workspace, so the
-- "stash" workspace used for minimized windows and the trailing empty workspace never show.
--
-- Event driven, no timer: a niri event-stream follower repolls when workspaces change.

local EVENTS_CMD = "niri msg event-stream | grep --line-buffered -E '^(Workspace|Window)'"

-- Workspaces of the focused output as [{idx, focused, occupied}], by idx.
local LIST_CMD = [[
niri msg --json workspaces | jq -c '
  (map(select(.is_focused) | .output) | first) as $out
  | map(select($out == null or .output == $out))
  | sort_by(.idx)
  | map({idx, focused: .is_focused, occupied: (.active_window_id != null)})'
]]

local spaces = nil
local lastJson = nil
local busy = false
local again = false

local function switchTo(idx)
  noctalia.runAsync({ "niri", "msg", "action", "focus-workspace", tostring(idx) }, function() end)
end

local function render()
  if spaces == nil then
    barWidget.setVisible(false)
    return
  end
  local last = noctalia.getConfig("max_workspace") or 9
  local scale = (noctalia.getConfig("scale") or 120) / 100
  local activeColor = noctalia.getConfig("active_color") or "primary"
  local occupiedColor = noctalia.getConfig("occupied_color") or "surface_variant"
  local emptyColor = noctalia.getConfig("empty_color") or "on_primary"

  local items = {}
  for _, w in ipairs(spaces) do
    if w.idx <= last then
      local idx = w.idx
      local fill = w.focused and activeColor or (w.occupied and occupiedColor or (emptyColor .. "/0.35"))
      local text = w.focused and "on_primary" or (w.occupied and "on_surface_variant" or "on_surface_variant")
      table.insert(items, ui.row({
        key = "ws-" .. tostring(idx),
        align = "center",
        paddingH = math.floor(7 * scale),
        paddingV = math.floor(2 * scale),
        radius = math.floor(4 * scale),
        fill = fill,
        onClick = function()
          switchTo(idx)
        end,
      }, {
        ui.label({
          text = tostring(idx),
          color = text,
          fontWeight = "bold",
          fontSize = 11 * scale,
        }),
      }))
    end
  end

  barWidget.setVisible(#items > 0)
  local props = { gap = math.floor(4 * scale), align = "center" }
  barWidget.render(barWidget.isVertical() and ui.column(props, items) or ui.row(props, items))
end

local function poll()
  if busy then
    again = true
    return
  end
  busy = true
  noctalia.runAsync({ "sh", "-c", LIST_CMD }, function(result)
    busy = false
    if result.exitCode == 0 then
      local out = noctalia.string.trim(result.stdout or "")
      if out ~= lastJson then
        local ok, decoded = pcall(noctalia.json.decode, out)
        if ok and type(decoded) == "table" then
          lastJson = out
          spaces = decoded
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
