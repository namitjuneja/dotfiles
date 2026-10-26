#!/usr/bin/env bash
# Edge struts that only appear where they hint at off-screen columns. When every column of
# the focused workspace fits, both struts are 0 (windows flush to the edges). When they
# overflow, the left strut is $STRUT if columns exist left of the focused one, the right
# strut likewise, so no empty strip is wasted on a side with nothing beyond it.
# Writes struts.kdl, which niri live-reloads.

STRUT=36
GAP=10
file="$(dirname "$(readlink -f "$0")")/struts.kdl"

evaluate() {
    local ow cl cr fits idx n l r
    ow=$(niri msg --json focused-output | jq -r '.logical.width') || return
    read -r cl cr < <(awk '/left/ {l=$2} /right/ {r=$2} END {print l+0, r+0}' "$file" 2>/dev/null)
    # Fit is judged against the working width of the *current* struts so the result is stable.
    read -r fits idx n < <(niri msg --json windows | jq -r --argjson ow "$ow" --argjson s "$((cl + cr))" --argjson g "$GAP" '
        (map(select(.is_focused)) | .[0]) as $f
        | [.[] | select(.workspace_id == $f.workspace_id and (.is_floating | not) and .layout.pos_in_scrolling_layout != null)]
        | group_by(.layout.pos_in_scrolling_layout[0])
        | map(map(.layout.tile_size[0]) | max) as $cols
        | (if ($cols | length) <= 1 then true
           else (($cols | add) + ($cols | length - 1) * $g) <= ($ow - $s - 2 * $g + 1) end) as $fit
        | "\($fit) \($f.layout.pos_in_scrolling_layout[0] // 1) \($cols | length)"')
    l=0 r=0
    if [[ $fits != true ]]; then
        (( idx > 1 )) && l=$STRUT
        (( idx < n )) && r=$STRUT
    fi
    [[ $cl == "$l" && $cr == "$r" ]] && return
    printf 'layout {\n    struts {\n        left %s\n        right %s\n    }\n}\n' "$l" "$r" >"$file"
}

evaluate
niri msg --json event-stream | while read -r _; do
    while read -r -t 0.05 _; do :; done
    evaluate
done
