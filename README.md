# Dotfiles

Hyprland desktop config. Restore from scratch by working through `hypr/README.md`
first (it lists every package to install), then the per-component notes below.

---

## Components

| Directory | What it is | Docs |
|---|---|---|
| `hypr/` | Hyprland compositor config, keybinds, autostart, hypridle | [`hypr/README.md`](hypr/README.md) |
| `waybar/` | Status bar | [`waybar/README.md`](waybar/README.md) |

---

## Brightness Control Quick Reference

Hyprland's brightness binds use `swaync/scripts/brightness-get.sh` / `brightness-set.sh`
(kept after swaync itself was removed); they auto-detect the method:

- **Laptop** (real backlight device) → `brightnessctl`, near-instant.
- **Desktop with external monitor** (no backlight device, e.g. this machine's LG
  monitor on `DP-4`) → `ddcutil` over DDC/CI, ~0.4-0.6s per change.

Under niri, `Mod+Shift+=` / `Mod+Shift+-` call `noctalia msg brightness-up/down`
(`enable_ddcutil = true` in `noctalia/settings.toml`). Needs `ddcutil` and I2C permissions.

---

## Noctalia peek bar (niri)

A transparent bottom bar, `peek`, that shows the current track for 2.5 s and hides.

- **Bar:** `[bar.peek]` and `[widget.peek-media]` in `noctalia/settings.toml`. The niri blur rule matches only `noctalia-bar-default`; the peek surface exists while hidden and would leave a blurred strip.
- **Flash command:** `noctalia msg bar-show peek; sleep 2.5; noctalia msg bar-hide peek`
- **Triggers in `niri/config.kdl`:**
  - `Mod+P` and `F19`.
  - Previous/next binds (`Mod+;`, `Mod+'`, media keys): they wait for the new title, then flash.
- **Optional keyd (`/etc/keyd/default.conf`, not in this repo):** niri cannot bind a bare modifier, so keyd sends the trigger.

  ```
  [global]
  overload_tap_timeout = 250

  [ids]
  *

  [main]
  leftalt = overload(alt, command(runuser -u namit -- env XDG_RUNTIME_DIR=/run/user/1000 WAYLAND_DISPLAY=wayland-1 sh -c 'noctalia msg bar-show peek; sleep 2.5; noctalia msg bar-hide peek'))
  rightalt = overload(alt, command(runuser -u namit -- env XDG_RUNTIME_DIR=/run/user/1000 WAYLAND_DISPLAY=wayland-1 sh -c 'noctalia msg bar-show peek; sleep 2.5; noctalia msg bar-hide peek'))
  leftmeta = layerm(meta, macro(f19))
  rightmeta = layerm(meta, macro(f19))

  [alt:A]

  [meta:M]
  ```

  - `altwin:swap_alt_win` makes the Alt keys act as Super and the Win keys as Alt.
  - Tapping Alt flashes the bar; holding it stays a normal modifier.
  - Pressing a Win key sends F19 (flashes on every press). Not yet confirmed working.
  - Apply with `sudo keyd reload`; undo with `sudo systemctl disable --now keyd`.
- **Gotchas:**
  - `noctalia msg` needs `WAYLAND_DISPLAY`.
  - keyd keys must sit under `[main]`, before layer headers.
  - On this layout F20 is `XF86AudioMicMute`; F19 is plain `F19`.
