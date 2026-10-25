#!/usr/bin/env bash
# Mod+F: toggle floating. A tiled window that fills (nearly) the whole screen height would
# float as a screen-sized window, so shrink and center it to look like a real float.

win=$(niri msg --json focused-window) || exit 0
read -r floating w h < <(jq -r '"\(.is_floating) \(.layout.tile_size[0]) \(.layout.tile_size[1])"' <<<"$win")
read -r ow oh < <(niri msg --json focused-output | jq -r '"\(.logical.width) \(.logical.height)"')

niri msg action toggle-window-floating

[[ $floating == false ]] || exit 0
if awk -v w="$w" -v h="$h" -v ow="$ow" -v oh="$oh" 'BEGIN { exit !(h >= oh*0.85) }'; then
    # Size from the height at a 3:2 aspect, so ultrawide screens don't get ultrawide floats.
    read -r nw nh < <(awk -v ow="$ow" -v oh="$oh" 'BEGIN {
        nh = oh * 0.65; nw = nh * 1.5
        if (nw > ow * 0.8) { nw = ow * 0.8; nh = nw / 1.5 }
        printf "%d %d", nw, nh }')
    niri msg action set-window-width "$nw"
    niri msg action set-window-height "$nh"
    niri msg action center-window
fi
