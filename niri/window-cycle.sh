#!/usr/bin/env bash
# Usage: window-cycle.sh next|prev|float-next|float-prev|list|skip|unskip|restore ID
# next/prev (Mod+Tab) cycle the tiled windows of the current workspace in on-screen order
# (left to right, then top to bottom) and tuck every floating window away.
# float-next/float-prev (Mod+`) cycle the floating windows (by position) and bring each one back
# as it is reached, so repeated presses make them appear one by one.
# From a floating window, next/prev return to the tiled window last focused through this script.
# skip:    minimize the focused window (Mod+N): focus moves to the next window and the window
#          is parked on the "stash" workspace; its origin is recorded in $XDG_RUNTIME_DIR/niri-skip/<id>.
#          On an already minimized window it restores it instead.
# unskip:  restore the most recently minimized window that came from the current workspace (Mod+Shift+N).
# (cycle details) focusing a floating window that was stashed brings it back; focusing a tiled
#          window stashes every floating window of the workspace (they stay in the taskbar).
# watch:   daemon (started from niri config): opening a new tiled window tucks away floating ones, and a
#          new floating terminal is nudged by a random offset so they do not stack exactly.
# restore: restore the given window id to its origin workspace and focus it (taskbar click).

state="${XDG_RUNTIME_DIR:-/tmp}/niri-floating-stash"
skipdir="${XDG_RUNTIME_DIR:-/tmp}/niri-skip"
anchorfile="${XDG_RUNTIME_DIR:-/tmp}/niri-last-tiled"

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

# stash_floating: park every visible floating window of the focused workspace on the stash workspace,
# marked "auto" so the cycle (and the taskbar) still know them; they come back via the cycle or a click.
stash_floating() {
    local wsid wsinfo id
    wsid=${1:-$(niri msg --json workspaces | jq '.[] | select(.is_focused) | .id')}
    wsinfo=$(niri msg --json workspaces | jq -c --argjson ws "$wsid" '.[] | select(.id == $ws)')
    [[ $(jq -r .name <<<"$wsinfo") == "$stash" ]] && return
    mkdir -p "$skipdir"
    for id in $(niri msg --json windows | jq -r --argjson ws "$wsid" '.[] | select(.workspace_id == $ws and .is_floating) | .id'); do
        [[ -e $skipdir/$id ]] && continue
        jq -nc --argjson w "$wsinfo" '{ws: $w.id, name: $w.name, col: null, auto: true}' >"$skipdir/$id"
        niri msg action move-window-to-workspace --window-id "$id" --focus false "$stash"
    done
    refresh_widget
}

minimize=
case $1 in
    watch)
        # Daemon: a newly opened tiled window tucks away the floating windows of its workspace.
        seen=" "
        niri msg event-stream | while IFS= read -r line; do
            case $line in
                "Windows changed:"*)
                    seen=" $(grep -oE 'Window \{ id: [0-9]+' <<<"$line" | grep -oE '[0-9]+' | tr '\n' ' ')"
                    ;;
                "Window opened or changed:"*)
                    id=$(sed -nE 's/^[^{]*\{ id: ([0-9]+),.*/\1/p' <<<"$line")
                    [[ -n $id && $seen != *" $id "* ]] || continue
                    seen+="$id "
                    if [[ $line == *'app_id: Some("floating-term")'* ]]; then
                        # keep new floating terminals from landing exactly on top of each other
                        niri msg action move-floating-window --id "$id" \
                            -x "$(printf '%+d' $((RANDOM % 301 - 150)))" -y "$(printf '%+d' $((RANDOM % 201 - 100)))"
                        continue
                    fi
                    [[ $line == *"is_floating: false"* ]] || continue
                    wsid=$(sed -nE 's/.*workspace_id: Some\(([0-9]+)\).*/\1/p' <<<"$line")
                    [[ -n $wsid ]] && stash_floating "$wsid"
                    ;;
            esac
        done
        exit
        ;;
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

ws=$(niri msg --json workspaces | jq '.[] | select(.is_focused) | .id')

# Marks are files named after window ids; drop the ones whose window is gone. Explicitly minimized
# windows ($skip) stay out of the cycle; floating windows stashed by the cycle itself ("auto" marks)
# that came from this workspace ($auto) stay in it, so the cycle can bring them back.
ids=$(niri msg --json windows | jq -c '[.[].id]')
skip='[]'
auto='[]'
for f in "$skipdir"/*; do
    [[ -f $f ]] || continue
    id=$(basename "$f")
    if jq -e --argjson id "$id" 'index($id)' <<<"$ids" >/dev/null; then
        if [[ $(jq -r '.auto // false' "$f") == true ]]; then
            [[ $(jq '.ws' "$f") == "$ws" ]] && auto=$(jq -c --argjson id "$id" '. + [$id]' <<<"$auto")
        else
            skip=$(jq -c --argjson id "$id" '. + [$id]' <<<"$skip")
        fi
    else
        rm -f "$f"
    fi
done

order=$(niri msg --json windows | jq -c --argjson ws "$ws" --argjson saved "$saved" --argjson skip "$skip" --argjson auto "$auto" '
    [.[] | select(.workspace_id == $ws or (.id as $i | $auto | index($i)))] as $all
    | [$all[] | select(.is_floating | not)] as $tiled
    # Niri reports no on-screen position for tiled windows, so estimate x from the
    # widths of the columns to their left (exact while the columns fit on screen).
    | ($tiled | group_by(.layout.pos_in_scrolling_layout[0])
        | map({col: .[0].layout.pos_in_scrolling_layout[0], w: (map(.layout.tile_size[0]) | max)})) as $cols
    | $all
    | map(. + {key:
        (if .is_floating then
            [0, .id]   # by id: stable whether the window is shown or stashed (position differs there)
        else
            .layout.pos_in_scrolling_layout[0] as $c
            | [([$cols[] | select(.col < $c) | .w + 10] | add // 0) + 10,
               .layout.pos_in_scrolling_layout[1]]
        end)})
    | map(select(.is_focused or (.id as $i | ($skip | index($i)) | not)))
    | sort_by([.key[0], .key[1], .id])')

case $1 in
    list) jq -r '.[] | "\(.id)\t\(.app_id)\tfloating=\(.is_floating)\t\(.key)"' <<<"$order" ;;
    next | prev | float-next | float-prev)
        dir=${1#float-}
        [[ $1 == float-* ]] && wantfloat=true || wantfloat=false
        anchor=$(cat "$anchorfile" 2>/dev/null)
        id=$(jq --arg d "$dir" --argjson fl "$wantfloat" --argjson anchor "${anchor:-null}" '
            map(select(.is_floating == $fl or .is_focused)) as $all
            | map(select(.is_floating == $fl)) as $l
            | ($l | length) as $n
            | ($l | map(.is_focused) | index(true)) as $i
            | if $n == 0 then empty
              elif $i != null then $l[(if $d == "next" then $i + 1 else $i - 1 + $n end) % $n].id
              elif $fl == false and ($l | map(.id) | index($anchor)) != null then $anchor
              else (if $d == "next" then $l[0] else $l[$n - 1] end).id end' <<<"$order")
        if [[ -n $id ]]; then
            if [[ -e $skipdir/$id ]]; then
                restore "$id"      # a floating window the cycle stashed: bring it back in front
            else
                niri msg action focus-window --id "$id"
            fi
            # Landing on a tiled window tucks every floating window away; landing on a floating one doesn't.
            if [[ $wantfloat == false && -z $minimize ]]; then
                echo "$id" >"$anchorfile"
                stash_floating
            fi
        fi
        ;;
esac

# Focus has moved on; now park the minimized window on the stash workspace.
if [[ -n $minimize ]]; then
    niri msg action move-window-to-workspace --window-id "$minimize" --focus false "$stash"
    refresh_widget
fi
