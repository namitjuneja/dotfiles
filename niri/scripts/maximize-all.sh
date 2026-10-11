#!/usr/bin/env bash
# Maximize-to-edges every tiled column of the focused workspace; if all are already maximized, un-maximize them all.
# State is read from niri itself (a maximized tile is as wide as the output), so manual changes are respected.
set -e
ws_json=$(niri msg -j workspaces | jq '.[] | select(.is_focused)')
ws=$(jq '.id' <<<"$ws_json")
out=$(jq -r '.output' <<<"$ws_json")
out_w=$(niri msg -j outputs | jq --arg o "$out" '.[$o].logical.width')
windows=$(niri msg -j windows)

# one window per tiled column: "id maximized(0/1)"
cols=$(jq -r --argjson ws "$ws" --argjson w "$out_w" '
    [.[] | select(.workspace_id==$ws and (.is_floating|not) and .layout.pos_in_scrolling_layout != null)]
    | group_by(.layout.pos_in_scrolling_layout[0]) | map(.[0])
    | .[] | "\(.id) \(if .layout.tile_size[0] >= $w - 1 then 1 else 0 end)"' <<<"$windows")
[ -z "$cols" ] && exit 0

if grep -q ' 0$' <<<"$cols"; then
    ids=$(awk '$2==0{print $1}' <<<"$cols")   # maximize the ones that aren't
else
    ids=$(awk '{print $1}' <<<"$cols")        # all maximized: restore
fi

for id in $ids; do
    niri msg action maximize-window-to-edges --id "$id"
done
exit 0
