#!/bin/bash
# Prints an icon for the master layout's current split orientation, on the active
# workspace. `hyprctl getoption master:orientation` only ever reports the static
# config default -- layoutmsg orientationnext changes the orientation per-workspace
# at runtime but Hyprland exposes no IPC query for that live value. So the R
# keybind (see hyprland.lua/hyprland.conf) is the sole place orientation ever
# changes, and it records the new value here, keyed by workspace id, for this
# script to read back.

STATE_FILE="$HOME/.cache/hypr-master-orientation"
ws=$(hyprctl activeworkspace -j | jq -r '.id')

orientation=$(awk -F= -v ws="$ws" '$1 == ws { print $2 }' "$STATE_FILE" 2>/dev/null | tail -n1)
if [[ -z "$orientation" ]]; then
    orientation=$(hyprctl getoption master:orientation | grep -oP '(?<=str: ).*')
fi

case "$orientation" in
    left)   echo "⬅" ;;
    top)    echo "⬆" ;;
    right)  echo "➡" ;;
    bottom) echo "⬇" ;;
    center) echo "⏺" ;;
    *)      echo "?" ;;
esac
