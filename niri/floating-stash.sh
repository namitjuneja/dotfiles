#!/usr/bin/env bash
# Park unfocused floating windows in the bottom-right corner, where niri leaves
# only a small strip of them on screen (the window-rule in config.kdl makes them
# transparent), and move them back to their saved position when they regain focus.

state="${XDG_RUNTIME_DIR:-/tmp}/niri-floating-stash"
mkdir -p "$state"
rm -f "$state"/*

restore() {
    local id=$1 x y
    read -r x y <"$state/$id" || return
    rm -f "$state/$id"
    niri msg action move-floating-window --id "$id" -x "$x" -y "$y"
}

park() {
    local id=$1 x y
    read -r x y < <(niri msg --json windows | jq -r --argjson id "$id" \
        '.[] | select(.id == $id) | "\(.layout.tile_pos_in_workspace_view[0]) \(.layout.tile_pos_in_workspace_view[1])"')
    echo "$x $y" >"$state/$id"
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
sync "$(niri msg --json focused-window | jq '.id // empty')"

# Run the loop in the background and wait on it so the trap fires promptly on TERM.
while read -r line; do
    if [[ $line =~ ^Window\ focus\ changed:\ (Some\(([0-9]+)\)|None) ]]; then
        sync "${BASH_REMATCH[2]}"
    fi
done < <(niri msg event-stream) &
loop=$!
trap 'kill "$loop" 2>/dev/null; restore_all; exit' EXIT INT TERM
wait "$loop"
