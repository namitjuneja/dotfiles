#!/usr/bin/env bash
# Mod+Shift+B: cycle the default audio sink, move playing streams to it, notify with name + volume.
sinks=$(pactl -f json list sinks)
n=$(jq length <<<"$sinks")
[ "$n" -gt 0 ] || exit 0
cur=$(pactl get-default-sink)
i=$(jq --arg c "$cur" 'map(.name) | index($c) // -1' <<<"$sinks")
next=$(jq -c --argjson i "$i" '.[($i + 1) % length]' <<<"$sinks")
name=$(jq -r .name <<<"$next")
desc=$(jq -r .description <<<"$next")
vol=$(jq -r '.volume | to_entries[0].value.value_percent' <<<"$next")

pactl set-default-sink "$name"
for s in $(pactl -f json list sink-inputs | jq -r '.[].index'); do
    pactl move-sink-input "$s" "$name" 2>/dev/null
done

case $name in
    bluez_*) icon=audio-headphones ;;
    *) icon=audio-speakers ;;
esac
notify-send -a audio-sink -r 9123 -i "$icon" "Audio output" "$desc · $vol"
