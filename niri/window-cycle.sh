#!/usr/bin/env bash
# Usage: window-cycle.sh next|prev|list|skip|unskip|restore ID
# Focus the next/previous window on the current workspace in on-screen order
# (left to right, then top to bottom), floating windows interleaved by position.
# Parked floating windows (see floating-stash.sh) are placed by their saved position.
# skip:    minimize the focused window (Mod+Shift+N): focus moves to the next window and the window
#          is parked on the "stash" workspace; its origin is recorded in $XDG_RUNTIME_DIR/niri-skip/<id>.
#          On an already minimized window it restores it instead.
# unskip:  restore the most recently minimized window that came from the current workspace (Mod+Ctrl+N).
# restore: restore the given window id to its origin workspace and focus it (taskbar click).

state="${XDG_RUNTIME_DIR:-/tmp}/niri-floating-stash"
skipdir="${XDG_RUNTIME_DIR:-/tmp}/niri-skip"

# Tell the niri-taskbar Noctalia widget to refresh (no-op if Noctalia or the plugin is absent).
refresh_widget() {
    noctalia msg plugin namitjuneja/niri-taskbar:taskbar all refresh >/dev/null 2>&1
}

stash=stash   # named niri workspace that holds minimized windows (see config.kdl)

# restore ID: send a minimized window back to the workspace it came from (and its column), focus it.
restore() {
    local id=$1 mark ws name col target
    mark=$(cat "$skipdir/$id" 2>/dev/null) || return
    name=$(jq -r '.name // empty' <<<"$mark")
    ws=$(jq -r '.ws // empty' <<<"$mark")
    col=$(jq -r '.col // empty' <<<"$mark")
    if [[ -n $name ]]; then
        target=$name
    else
        target=$(niri msg --json workspaces | jq -r --argjson ws "${ws:-null}" '
            (.[] | select(.id == $ws) | .idx) // (.[] | select(.is_focused) | .idx)')
    fi
    rm -f "$skipdir/$id"
    niri msg action move-window-to-workspace --window-id "$id" --focus false "$target"
    niri msg action focus-window --id "$id"
    [[ -n $col ]] && niri msg action move-column-to-index "$col"
    refresh_widget
}

minimize=
case $1 in
    restore)
        restore "$2"
        exit
        ;;
    unskip)
        ws=$(niri msg --json workspaces | jq '.[] | select(.is_focused) | .id')
        for id in $(ls -t "$skipdir" 2>/dev/null); do
            if [[ $(jq '.ws' "$skipdir/$id" 2>/dev/null) == "$ws" ]]; then
                restore "$id"
                break
            fi
        done
        exit
        ;;
    skip)
        win=$(niri msg --json focused-window)
        id=$(jq .id <<<"$win")
        [[ $id != null ]] || exit
        mkdir -p "$skipdir"
        if [[ -e $skipdir/$id ]]; then
            restore "$id"
            exit
        fi
        wsinfo=$(niri msg --json workspaces | jq -c --argjson ws "$(jq .workspace_id <<<"$win")" '.[] | select(.id == $ws)')
        [[ $(jq -r .name <<<"$wsinfo") == "$stash" ]] && exit
        jq -nc --argjson w "$wsinfo" --argjson win "$win" \
            '{ws: $w.id, name: $w.name, col: (if $win.is_floating then null else $win.layout.pos_in_scrolling_layout[0] end)}' >"$skipdir/$id"
        minimize=$id
        set -- next
        ;;
esac

saved='{}'
for f in "$state"/*; do
    [[ -f $f ]] || continue
    read -r x y <"$f"
    saved=$(jq -c --arg id "$(basename "$f")" --argjson x "$x" --argjson y "$y" '. + {($id): [$x, $y]}' <<<"$saved")
done

# Skip marks are files named after window ids; drop the ones whose window is gone.
ids=$(niri msg --json windows | jq -c '[.[].id]')
skip='[]'
for f in "$skipdir"/*; do
    [[ -f $f ]] || continue
    id=$(basename "$f")
    if jq -e --argjson id "$id" 'index($id)' <<<"$ids" >/dev/null; then
        skip=$(jq -c --argjson id "$id" '. + [$id]' <<<"$skip")
    else
        rm -f "$f"
    fi
done

ws=$(niri msg --json workspaces | jq '.[] | select(.is_focused) | .id')

order=$(niri msg --json windows | jq -c --argjson ws "$ws" --argjson saved "$saved" --argjson skip "$skip" '
    [.[] | select(.workspace_id == $ws)] as $all
    | [$all[] | select(.is_floating | not)] as $tiled
    # Niri reports no on-screen position for tiled windows, so estimate x from the
    # widths of the columns to their left (exact while the columns fit on screen).
    | ($tiled | group_by(.layout.pos_in_scrolling_layout[0])
        | map({col: .[0].layout.pos_in_scrolling_layout[0], w: (map(.layout.tile_size[0]) | max)})) as $cols
    | $all
    | map(. + {key:
        (if .is_floating then
            ($saved[.id | tostring] // .layout.tile_pos_in_workspace_view // [0, 0])
        else
            .layout.pos_in_scrolling_layout[0] as $c
            | [([$cols[] | select(.col < $c) | .w + 10] | add // 0) + 10,
               .layout.pos_in_scrolling_layout[1]]
        end)})
    | map(select(.is_focused or (.id as $i | ($skip | index($i)) | not)))
    | sort_by([.key[0], .key[1], .id])')

case $1 in
    list) jq -r '.[] | "\(.id)\t\(.app_id)\tfloating=\(.is_floating)\t\(.key)"' <<<"$order" ;;
    next | prev)
        id=$(jq --arg d "$1" '
            (map(.is_focused) | index(true)) as $i
            | length as $n
            | if $n == 0 then empty
              elif $i == null then (if $d == "next" then .[0] else .[$n - 1] end).id
              else .[(if $d == "next" then $i + 1 else $i - 1 + $n end) % $n].id end' <<<"$order")
        [[ -n $id ]] && niri msg action focus-window --id "$id"
        ;;
esac

# Focus has moved on; now park the minimized window on the stash workspace.
if [[ -n $minimize ]]; then
    niri msg action move-window-to-workspace --window-id "$minimize" --focus false "$stash"
    refresh_widget
fi
