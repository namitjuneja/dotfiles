# Dotfiles

Hyprland desktop config. Restore from scratch by working through `hypr/README.md`
first (it lists every package to install), then the per-component notes below.

---

## Components

| Directory | What it is | Docs |
|---|---|---|
| `hypr/` | Hyprland compositor config, keybinds, autostart, hypridle | [`hypr/README.md`](hypr/README.md) |
| `waybar/` | Status bar | [`waybar/README.md`](waybar/README.md) |
| `swaync/` | Notification sidebar (`Super + S`) — volume/brightness sliders, notifications, quick actions | [`swaync/README.md`](swaync/README.md) |

---

## Brightness Control Quick Reference

The swaync sidebar's brightness slider works on both laptops and desktops without
any config changes — `swaync/scripts/brightness-get.sh` / `brightness-set.sh`
auto-detect which method to use:

- **Laptop** (real backlight device) → `brightnessctl`, near-instant.
- **Desktop with external monitor** (no backlight device, e.g. this machine's LG
  monitor on `DP-4`) → `ddcutil` over DDC/CI, ~0.4-0.6s per change (protocol-level
  limit, not fixable in config).

Requires `ddcutil` for the desktop path (`sudo pacman -S ddcutil`) and I2C
permissions (user in the `i2c` group or a udev rule for `/dev/i2c-*`). Full details,
including a swaync 0.12.6 slider bug workaround, in
[`swaync/README.md`](swaync/README.md).
