#!/bin/sh
# Sets brightness to $1 (0-100). Prefers a real backlight device (laptops);
# falls back to DDC/CI control of an external monitor (desktops).
value=$1
if brightnessctl -c backlight g >/dev/null 2>&1; then
    brightnessctl -c backlight set "${value}%" >/dev/null
else
    ddcutil setvcp 10 "$value" --noverify >/dev/null 2>&1
fi
