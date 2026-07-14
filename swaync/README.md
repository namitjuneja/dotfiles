# SwayNC Config — Setup Notes

SwayNotificationCenter (`swaync`) provides the notification sidebar, toggled with
`Super + S` (see `hypr/hyprland.conf`).

---

## File Structure

```
~/.config/swaync/
├── config.json                # widget layout and behavior
├── style.css                  # visual styling (matches cyan/green accent theme)
└── scripts/
    ├── brightness-get.sh      # reads current brightness (0-100)
    └── brightness-set.sh      # sets brightness (0-100)
```

---

## Sidebar Widgets (config.json)

```json
"widgets": [
  "title",
  "dnd",
  "volume",
  "slider",
  "notifications",
  "mpris",
  "buttons-grid"
]
```

- `volume` — built-in widget, controls the default PulseAudio sink.
- `slider` — SwayNC's generic slider widget, repurposed here as a brightness control
  (see below). SwayNC's dedicated `backlight` widget only supports laptop panels via
  `/sys/class/backlight`, which doesn't exist on a desktop with an external monitor —
  hence the generic `slider` + custom scripts approach.

### Known swaync bug: `slider` widget stuck at 0 / unresponsive to drag

`min_limit`, `max_limit`, and `value_scale` are documented as optional (defaulting to
`min`, `max`, and `0`), but in swaync 0.12.6 omitting them breaks the slider's internal
value/position mapping — it renders stuck near zero and misreads clicks/drags. Fix
(confirmed via [GitHub issue #628](https://github.com/ErikReider/SwayNotificationCenter/issues/628)):
set them explicitly even though they duplicate `min`/`max`:

```json
"slider": {
  "label": "󰃟",
  "cmd_setter": "$HOME/.config/swaync/scripts/brightness-set.sh $value",
  "cmd_getter": "$HOME/.config/swaync/scripts/brightness-get.sh",
  "min": 0,
  "max": 100,
  "min_limit": 0,
  "max_limit": 100,
  "value_scale": 0
}
```

---

## Brightness Scripts (Laptop vs. Desktop)

`brightness-get.sh` / `brightness-set.sh` auto-detect which brightness control method
is available, so this config is portable between machines without editing:

1. **Laptop (real backlight device)** — uses `brightnessctl -c backlight`, which reads/writes
   `/sys/class/backlight` directly. Near-instant.
2. **Desktop with external monitor (no backlight device)** — falls back to `ddcutil`,
   which controls monitor brightness over DDC/CI (I2C). This machine has an LG external
   monitor on `DP-4`; VCP feature code `10` is the standard "Brightness" control.
   - Requires `ddcutil` installed and I2C permissions (user in the `i2c` group, or a udev
     rule granting access to `/dev/i2c-*`).
   - DDC/CI is inherently slow (~0.4-0.6s per command — it's a low-speed serial protocol,
     and most monitors need a minimum delay between commands or they drop them). The
     setter uses `--noverify` to skip ddcutil's default read-back verification, since the
     UI doesn't need it — this cuts the round-trip roughly in half. Don't expect it to
     ever feel as instant as a native backlight; that's a hardware/protocol limit, not a
     config issue.

Detection logic (`brightness-get.sh`):
```sh
if brightnessctl -c backlight g >/dev/null 2>&1; then
    # real backlight device exists — use it
else
    # fall back to ddcutil
fi
```

If porting to a machine with a different external monitor, check its VCP brightness
feature code (usually `10`) with `ddcutil capabilities`, and confirm which display index
`ddcutil detect` assigns it if you have more than one DDC-capable monitor (the scripts
assume display 1, the default).
