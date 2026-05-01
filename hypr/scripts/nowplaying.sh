#!/bin/bash
playerctl --follow metadata --format "{{title}}\n{{artist}}" | while IFS= read -r line; do
    notify-send -i audio-headphones "Now Playing" "$line"
done
