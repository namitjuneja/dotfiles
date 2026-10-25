#!/bin/bash
# Minimize/restore that puts a window back exactly as it was. mango's
# restore_minimized reinserts at the end of the stack, always tiled, on the current tag,
# so remember tag, floating state and stack position at minimize time and replay them.
state=${XDG_RUNTIME_DIR:-/tmp}/mango-minimized

# Position of $2 among the tiled, non-minimized windows of tag $1 (empty if not tiled there)
stack_index() {
    mmsg get all-clients | jq --argjson t "$1" --argjson id "$2" \
        '[.clients[] | select((.tags | index($t)) and (.is_floating | not) and (.is_minimized | not)) | .id] | index($id) // empty'
}

case $1 in
min)
    c=$(mmsg get focusing-client)
    id=$(jq -r '.id // empty' <<<"$c")
    [ -z "$id" ] && exit
    tag=$(jq -r '.tags[0]' <<<"$c")
    floating=$(jq -r .is_floating <<<"$c")
    idx=$(stack_index "$tag" "$id")
    echo "$id $floating $tag ${idx:--1}" >>"$state"
    mmsg dispatch minimized client,"$id"
    ;;
restore)
    while [ -s "$state" ]; do
        read -r id floating tag idx < <(tail -n1 "$state")
        sed -i '$d' "$state"
        mmsg get client "$id" | jq -e '.is_minimized' >/dev/null 2>&1 || continue
        mmsg dispatch view,"$tag",0
        mmsg dispatch restore_minimized client,"$id"
        sleep 0.2
        if [ "$floating" = true ]; then
            mmsg dispatch togglefloating client,"$id"
        elif [ "$idx" -ge 0 ]; then
            cur=$(stack_index "$tag" "$id")
            for ((; cur > idx; cur--)); do
                mmsg dispatch exchange_stack_client,prev client,"$id"
            done
        fi
        break
    done
    ;;
esac
