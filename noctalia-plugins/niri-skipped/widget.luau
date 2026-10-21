--!nonstrict

-- Counts windows marked with the niri skip bind (window-cycle.sh skip, Mod+Shift+N)
-- on the focused workspace, so the widget only shows where it applies.
-- Marks are files named after window ids in $XDG_RUNTIME_DIR/niri-skip; only marks
-- whose window still exists on that workspace are counted. Click restores the most recent one.
--
-- Event driven, no timer: window-cycle.sh pushes a "refresh" IPC event whenever it
-- changes a mark, and a niri event-stream follower recounts when a window closes or
-- the focused workspace changes.

local glyph = noctalia.getConfig("glyph")
local color = noctalia.getConfig("color")
local hideWhenZero = noctalia.getConfig("hide_when_zero")

local EVENTS_CMD = "niri msg event-stream | grep --line-buffered -E '^(Window closed|Workspace (focused|activated))'"

local COUNT_CMD = [[
d="${XDG_RUNTIME_DIR:-/tmp}/niri-skip"
[ -d "$d" ] || { echo 0; exit; }
ws=$(niri msg --json workspaces | jq '.[] | select(.is_focused) | .id')
ids=" $(niri msg --json windows | jq -r --argjson ws "${ws:-null}" '.[] | select(.workspace_id == $ws) | .id' | tr '\n' ' ') "
n=0
for f in "$d"/*; do
  [ -f "$f" ] || continue
  case "$ids" in *" ${f##*/} "*) n=$((n + 1)) ;; esac
done
echo $n
]]

local count = -1

local function render()
  if count < 0 or (count == 0 and hideWhenZero) then
    barWidget.setVisible(false)
    return
  end

  barWidget.setVisible(true)
  local children = {
    ui.glyph({ name = glyph, color = color }),
    ui.label({ text = tostring(count), color = color, fontWeight = "bold" }),
  }
  local props = { gap = 4, align = "center" }
  barWidget.render(barWidget.isVertical() and ui.column(props, children) or ui.row(props, children))
  barWidget.setTooltip({
    { noctalia.tr("tooltip.skipped"), tostring(count) },
    { noctalia.tr("tooltip.restore"), "" },
  })
end

local function poll()
  noctalia.runAsync({ "sh", "-c", COUNT_CMD }, function(result)
    local n = tonumber(noctalia.string.trim(result.stdout or ""))
    if result.exitCode == 0 and n ~= nil and n ~= count then
      count = n
      render()
    end
  end)
end

function onIpc(ev)
  if ev == "refresh" then
    poll()
  end
end

function onClick()
  noctalia.runAsync({ "sh", "-c", '"$HOME/.config/niri/window-cycle.sh" unskip' }, function()
    poll()
  end)
end

noctalia.runStream(EVENTS_CMD, function()
  poll()
end)
poll()
