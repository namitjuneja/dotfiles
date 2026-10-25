#!/bin/bash
# Hide a floating window as soon as another window takes focus.
# It goes to mango's scratchpad (minimized); Mod+S brings it back.
prev= prev_floating=false
mmsg watch focusing-client | while read -r line; do
    id=$(jq -r '.id // empty' <<<"$line" 2>/dev/null)
    [ -z "$id" ] && continue
    if [ "$id" != "$prev" ] && [ "$prev_floating" = true ] &&
        mmsg get client "$prev" | jq -e '.is_minimized == false' >/dev/null 2>&1; then
        mmsg dispatch minimized client,"$prev" >/dev/null
    fi
    prev=$id
    prev_floating=$(jq -r '.is_floating' <<<"$line")
done
