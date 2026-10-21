#!/usr/bin/env bash
# Unfloat every window on the focused workspace, then size all tiled columns equally so
# they fit on screen without scrolling, and scroll the workspace to its first column.
# Maximized columns are restored first.
set -e
state="${XDG_RUNTIME_DIR:-/tmp}/niri-floating-stash"
ws_json=$(niri msg -j workspaces | jq '.[] | select(.is_focused)')
ws=$(jq '.id' <<<"$ws_json")
out=$(jq -r '.output' <<<"$ws_json")
out_w=$(niri msg -j outputs | jq --arg o "$out" '.[$o].logical.width')
orig=$(niri msg -j focused-window | jq '.id // empty')

for id in $(niri msg -j windows | jq -r --argjson ws "$ws" '.[] | select(.workspace_id==$ws and .is_floating) | .id'); do
    rm -f "$state/$id"   # drop the parked-position record from floating-stash.sh
    niri msg action move-window-to-tiling --id "$id"
done

# one window per tiled column, left to right: "id maximized(0/1)"
cols=$(niri msg -j windows | jq -r --argjson ws "$ws" --argjson w "$out_w" '
    [.[] | select(.workspace_id==$ws and (.is_floating|not) and .layout.pos_in_scrolling_layout != null)]
    | group_by(.layout.pos_in_scrolling_layout[0]) | map(.[0])
    | .[] | "\(.id) \(if .layout.tile_size[0] >= $w - 1 then 1 else 0 end)"')
[ -z "$cols" ] && exit 0

n=$(wc -l <<<"$cols")
pct=$(awk -v n="$n" 'BEGIN { printf "%.4f", 100 / n }')

while read -r id maxed; do
    [ "$maxed" = 1 ] && niri msg action maximize-window-to-edges --id "$id"
    niri msg action focus-window --id "$id"
    niri msg action set-column-width "${pct}%"
done <<<"$cols"

# Scroll the workspace back to its first column, then hand focus back to the original window.
niri msg action focus-column-first
[ -n "$orig" ] && niri msg action focus-window --id "$orig"
exit 0
