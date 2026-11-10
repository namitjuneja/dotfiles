# Dotfiles

Hyprland desktop config. Restore from scratch by working through `hypr/README.md`
first (it lists every package to install), then the per-component notes below.

---

## Components

| Directory | What it is | Docs |
|---|---|---|
| `hypr/` | Hyprland compositor config, keybinds, autostart, hypridle | [`hypr/README.md`](hypr/README.md) |
| `waybar/` | Status bar | [`waybar/README.md`](waybar/README.md) |
| `firefox/` | Tracked Firefox profile config (YT Music, Google Home) | [`firefox/README.md`](firefox/README.md) |

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
- **keyd (`/etc/keyd/default.conf`; backup copy: `keyd/default.conf`):** niri cannot bind a bare modifier, so keyd sends the trigger.

  - Config: `keyd/default.conf` (hardcodes user `namit`, UID 1000, `wayland-1`).

  - `altwin:swap_alt_win` makes the Alt keys act as Super and the Win keys as Alt.
  - Tapping Alt flashes the bar; holding it stays a normal modifier.
  - Pressing a Win key sends F19 (flashes on every press). Not yet confirmed working.
  - Apply with `sudo keyd reload`; undo with `sudo systemctl disable --now keyd`.
- **Gotchas:**
  - `noctalia msg` needs `WAYLAND_DISPLAY`.
  - keyd keys must sit under `[main]`, before layer headers.
  - On this layout F20 is `XF86AudioMicMute`; F19 is plain `F19`.

---

## Firefox

Three profiles, each a separate Firefox instance. Only `user.js` and `chrome/userChrome.css` are tracked (the repo is public; profile dirs hold cookies and logins). `userChrome.css` needs `toolkit.legacyUserProfileCustomizations.stylesheets=true` in `user.js`.

| Profile | Path | Launch | UI |
|---|---|---|---|
| Main | `mozilla/firefox/oqk2vkmz.default-release-*` (in repo) | `Mod+F1`, `KP_Add`, `KP_Subtract` | Tab strip and sidebar header hidden, square corners |
| YT Music | `~/.local/share/ytm-firefox` ← `firefox/ytm-firefox/` | `Mod+F9` | None (page only) |
| Google Home | `~/.local/share/home-firefox` ← `firefox/home-firefox/` | `KP_Multiply` | None, floating panel |

The two `~/.local/share` profiles symlink `user.js` and `chrome/` into `firefox/`. On a new machine create the dirs, then relink.

**YT Music**
- `firefox --no-remote --profile ~/.local/share/ytm-firefox --new-window music.youtube.com` on workspace 9. `--no-remote` starts its own process instead of joining the main one.
- `userChrome.css` collapses `#TabsToolbar`, `#nav-bar`, `#PersonalToolbar`, `#titlebar` and the sidebar. Extensions: Vimium C, LeechBlock.
- Media keys target only this instance: `niri/ytm-player.sh` finds the MPRIS name for its PID and the binds call `playerctl -p`.
- While it runs, a second `--no-remote` launch on the profile fails. Drop `--no-remote` to open another window in the running instance.

**Google Home** (`KP_Multiply`)
- Same chromeless setup, plus `--name home-panel`, which sets the Wayland app-id so only this window is matched.
- The bind starts Firefox, then polls for a non-floating `home-panel` window and runs `move-window-to-floating`, `set-window-width 480`, `set-window-height 640`, `center-window`. The `open-floating` window rule alone floated it unreliably (kept as fallback).
- Login: Google cookies copied from the YT Music profile. If Google expires them, sign in once (see below).
- Session restore is off (`user.js`); a crash otherwise reopens stray blank windows.
- Loads in ~7s versus ~1.4s in the main profile. Cause: a new process has cold connections and a cold app, not extensions (safe mode was no faster). Fix if needed: keep an instance running from login.

**Mail** (main profile): `KP_Subtract` opens Gmail in a new window. `KP_Add` opens Gmail, sleeps 1s, then `--new-tab` UB mail, which lands in that new window. Binding `Num_Lock` was dropped: the key toggles the lock even when bound.

**Gotchas**
- A normal window on a chromeless profile: move `chrome/userChrome.css` aside, launch the profile, restore the file once the window is up (CSS is read at startup). Quit the profile's running instance first.
- `pgrep -f` or `pkill -f` with a profile name can match your own shell command.

## Default apps
`mimeapps.list`: Firefox (`firefox.desktop`) handles `text/html`, `http(s)`, `about`, `unknown` and `xhtml`.
