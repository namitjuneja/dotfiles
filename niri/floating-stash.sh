#!/usr/bin/env bash
# Park unfocused floating windows as 50x50 slivers in the bottom-right corner
# (the window-rule in config.kdl makes them transparent) and restore them to
# their saved size and position when they regain focus.

state="${XDG_RUNTIME_DIR:-/tmp}/niri-floating-stash"
mkdir -p "$state"
rm -f "$state"/*

restore() {
    local id=$1 w h x y
    read -r w h x y <"$state/$id" || return
    rm -f "$state/$id"
    niri msg action set-window-width --id "$id" "$w"
    niri msg action set-window-height --id "$id" "$h"
    niri msg action move-floating-window --id "$id" -x "$x" -y "$y"
}

park() {
    local id=$1 w h x y
    read -r w h x y < <(niri msg --json windows | jq -r --argjson id "$id" \
        '.[] | select(.id == $id) | "\(.layout.window_size[0]) \(.layout.window_size[1]) \(.layout.tile_pos_in_workspace_view[0]) \(.layout.tile_pos_in_workspace_view[1])"')
    echo "$w $h $x $y" >"$state/$id"
    niri msg action set-window-width --id "$id" 50
    niri msg action set-window-height --id "$id" 50
    niri msg action move-floating-window --id "$id" -x 100000 -y 100000
}

sync() {
    local focused=$1 id
    [[ -f "$state/$focused" ]] && restore "$focused"
    for id in $(niri msg --json windows | jq -r --argjson f "${focused:-null}" \
        '.[] | select(.is_floating and .id != $f) | .id'); do
        [[ -f "$state/$id" ]] || park "$id"
    done
}

restore_all() {
    local f
    for f in "$state"/*; do
        [[ -e $f ]] && restore "$(basename "$f")"
    done
}
trap 'restore_all; exit' EXIT INT TERM

sync "$(niri msg --json focused-window | jq '.id // empty')"
niri msg event-stream | while read -r line; do
    if [[ $line =~ ^Window\ focus\ changed:\ (Some\(([0-9]+)\)|None) ]]; then
        sync "${BASH_REMATCH[2]}"
    fi
done
