#!/usr/bin/env bash
# Usage: window-cycle.sh next|prev|list|skip|unskip
# Focus the next/previous window on the current workspace in on-screen order
# (left to right, then top to bottom), floating windows interleaved by position.
# Parked floating windows (see floating-stash.sh) are placed by their saved position.
# Windows marked with the skip bind (Mod+Shift+N) are left out unless focused.
# skip:   toggle the focused window's mark; marking it also moves focus on to the next window.
# unskip: clear the most recently marked window on the current workspace and focus it (Mod+Ctrl+N).

state="${XDG_RUNTIME_DIR:-/tmp}/niri-floating-stash"
skipdir="${XDG_RUNTIME_DIR:-/tmp}/niri-skip"

# Tell the niri-skipped Noctalia widget to recount (no-op if Noctalia or the plugin is absent).
refresh_widget() {
    noctalia msg plugin namitjuneja/niri-skipped:skipped all refresh >/dev/null 2>&1
}

case $1 in
    unskip)
        ws=$(niri msg --json workspaces | jq '.[] | select(.is_focused) | .id')
        on_ws=$(niri msg --json windows | jq -r --argjson ws "$ws" '.[] | select(.workspace_id == $ws) | .id')
        last=
        for id in $(ls -t "$skipdir" 2>/dev/null); do
            if grep -qx "$id" <<<"$on_ws"; then
                last=$id
                break
            fi
        done
        if [[ -n $last ]]; then
            rm -f "$skipdir/$last"
            niri msg action focus-window --id "$last"
            refresh_widget
        fi
        exit
        ;;
    skip)
        id=$(niri msg --json focused-window | jq .id)
        [[ $id != null ]] || exit
        mkdir -p "$skipdir"
        if [[ -e $skipdir/$id ]]; then
            rm "$skipdir/$id"
            refresh_widget
            exit
        fi
        touch "$skipdir/$id"
        refresh_widget
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
