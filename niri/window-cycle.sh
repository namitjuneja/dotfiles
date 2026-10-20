#!/usr/bin/env bash
# Usage: window-cycle.sh next|prev|list
# Focus the next/previous window on the current workspace in on-screen order
# (left to right, then top to bottom), floating windows interleaved by position.
# Parked floating windows (see floating-stash.sh) are placed by their saved position.

state="${XDG_RUNTIME_DIR:-/tmp}/niri-floating-stash"

saved='{}'
for f in "$state"/*; do
    [[ -f $f ]] || continue
    read -r x y <"$f"
    saved=$(jq -c --arg id "$(basename "$f")" --argjson x "$x" --argjson y "$y" '. + {($id): [$x, $y]}' <<<"$saved")
done

ws=$(niri msg --json workspaces | jq '.[] | select(.is_focused) | .id')

order=$(niri msg --json windows | jq -c --argjson ws "$ws" --argjson saved "$saved" '
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
