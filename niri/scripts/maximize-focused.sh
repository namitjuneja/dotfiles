#!/usr/bin/env bash
# Mod+M: tile the focused window (if floating) and maximize it to the edges; if it is already
# tiled and maximized (as wide as the output), restore it.
set -e
win=$(niri msg -j focused-window) || exit 0
id=$(jq '.id' <<<"$win")
floating=$(jq '.is_floating' <<<"$win")
w=$(jq '.layout.tile_size[0]' <<<"$win")
out_w=$(niri msg -j focused-output | jq '.logical.width')

if [ "$floating" = true ]; then
    niri msg action move-window-to-tiling --id "$id"
    niri msg action maximize-window-to-edges --id "$id"
elif awk -v w="$w" -v o="$out_w" 'BEGIN { exit !(w >= o - 1) }'; then
    niri msg action maximize-window-to-edges --id "$id"   # already maximized: restore
else
    niri msg action maximize-window-to-edges --id "$id"
fi
