#!/bin/sh
# Prints current brightness as 0-100. Prefers a real backlight device
# (laptops); falls back to DDC/CI control of an external monitor (desktops).
if brightnessctl -c backlight g >/dev/null 2>&1; then
    cur=$(brightnessctl -c backlight g)
    max=$(brightnessctl -c backlight m)
    echo $((cur * 100 / max))
else
    ddcutil getvcp 10 --brief 2>/dev/null | awk '{print $4}'
fi
