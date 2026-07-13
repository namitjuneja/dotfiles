#!/bin/bash
# Bound to Super + R (hyprland.lua/hyprland.conf). Cycles the master layout's split
# orientation on the active workspace and records the new value so Waybar's
# custom/orientation module (master-orientation.sh) can display it -- see that
# script for why this bookkeeping is needed (Hyprland has no IPC query for the
# live per-workspace orientation).
#
# Deliberately dispatches an *explicit* orientation (layoutmsg orientationleft /
# orientationtop / ...) rather than the relative `orientationnext`. With a
# relative dispatch, our cached guess of "current" only stays valid if this
# script is the only thing that ever changes it -- any other path (manual
# `hyprctl dispatch`, testing, etc.) desyncs the cache from reality forever,
# since Hyprland exposes no query to notice or recover from that. Dispatching
# the explicit value we just wrote to the cache makes every keypress
# self-correcting: real state is forced to match the cache, not just assumed to.
#
# Cycle order matches Hyprland's own eOrientation enum (MasterAlgorithm.hpp):
# LEFT -> TOP -> RIGHT -> BOTTOM -> CENTER -> LEFT.

STATE_FILE="$HOME/.cache/hypr-master-orientation"
ws=$(hyprctl activeworkspace -j | jq -r '.id')

current=$(awk -F= -v ws="$ws" '$1 == ws { print $2 }' "$STATE_FILE" 2>/dev/null | tail -n1)
if [[ -z "$current" ]]; then
    current=$(hyprctl getoption master:orientation | grep -oP '(?<=str: ).*')
fi

case "$current" in
    left)   next=top ;;
    top)    next=right ;;
    right)  next=bottom ;;
    bottom) next=center ;;
    center) next=left ;;
    *)      next=left ;;
esac

{ [[ -f "$STATE_FILE" ]] && grep -v "^$ws=" "$STATE_FILE"; echo "$ws=$next"; } > "$STATE_FILE.tmp"
mv "$STATE_FILE.tmp" "$STATE_FILE"

hyprctl dispatch "hl.dsp.layout(\"orientation$next\")" >/dev/null
pkill -RTMIN+9 waybar
