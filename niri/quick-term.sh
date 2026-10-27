#!/usr/bin/env bash
# Quick terminal toggle (Volume Up key): open a floating "quick-term" kitty; pressed again while it is
# focused, switch focus back to the tiled windows and tuck the floating window away right away (window-cycle.sh tuck).
# Pressed while it is tucked away or on another
# workspace, bring it to the current workspace and focus it.

skipdir="${XDG_RUNTIME_DIR:-/tmp}/niri-skip"

win=$(niri msg --json windows | jq -c '[.[] | select(.app_id == "quick-term")][0] // empty')
if [[ -z $win ]]; then
    exec kitty --class quick-term
fi

id=$(jq .id <<<"$win")
if [[ $(jq .is_focused <<<"$win") == true ]]; then
    # Tuck the floating window right away, like Mod+Tab does, instead of waiting for the watch daemon.
    niri msg action switch-focus-between-floating-and-tiling
    exec ~/.config/niri/window-cycle.sh tuck
fi

ws=$(niri msg --json workspaces | jq '.[] | select(.is_focused) | .id')
if [[ $(jq .workspace_id <<<"$win") != "$ws" ]]; then
    niri msg action move-window-to-workspace --window-id "$id" --focus false "$(niri msg --json workspaces | jq '.[] | select(.is_focused) | .idx')"
fi
rm -f "$skipdir/$id"
niri msg action focus-window --id "$id"
noctalia msg plugin namitjuneja/niri-taskbar:taskbar all refresh >/dev/null 2>&1
