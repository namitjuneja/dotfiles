# New installation guide

Restore this repo on a fresh Arch/CachyOS machine. Main desktop: **niri + Noctalia**. `hypr/` and `waybar/` are the older Hyprland setup, kept as fallback.

## Rules for whoever follows this (human or AI)

- **Ask before every change.** Say what you will do and which files it touches. Wait for a yes.
- Never overwrite existing files. Show a diff and ask. Back up first: `mv X X.bak`.
- Never run `sudo`, install packages, enable services or edit `/etc` without asking.
- Do not guess. If a step fails, stop and report.
- Skip any section the user does not want.

## 0. Check first (read-only)

- `whoami` — configs hardcode `/home/namit`; see step 6.
- `ls -A ~/.config` — note what already exists; step 1 may clash.
- `pacman -Q niri noctalia yay` — see what is installed.

## 1. Get the repo

The repo is `~/.config` itself.

- Empty `~/.config`: `git clone https://github.com/namitjuneja/dotfiles ~/.config`
- Existing `~/.config`: clone elsewhere, then copy per component (ask for each).
- Branch: `niri` (main desktop). `master` is the older Hyprland setup.

## 2. Packages

Ask before installing. Lists live in the READMEs; install only what the user picks.

- **yay** (AUR helper): see `hypr/README.md` § yay.
- **niri stack:** `niri`, `noctalia`, `kitty`, `fish`, `rofi-wayland`, `jq`, `playerctl`, `wireplumber` (`wpctl`), `brightnessctl`, `ddcutil` (external monitor brightness; needs I2C permissions), `firefox`, `solaar`, `htop`, `micro`.
- **Fonts:** `ttf-meslo-nerd`, `ttf-jetbrains-mono-nerd`, Adwaita Mono (used by the bar).
- **Hyprland fallback:** `hypr/README.md` § Packages (pacman + AUR lists).
- **Waybar fallback:** `waybar/README.md` § Dependencies.

## 3. What each directory is

| Path | What | Action |
|---|---|---|
| `niri/` | `config.kdl` (binds, rules, autostart) + helper scripts | Used as-is. Notes: `niri/README.md` |
| `noctalia/` | `noctalia-config.toml`, a merged export of the live config | See step 4 |
| `noctalia-plugins/` | Local plugins `niri-taskbar`, `niri-workspaces` | Loaded via the `local` plugin source |
| `kitty/` | Terminal config | Used as-is |
| `fish/` | `config.fish` (aliases, git helpers) | Used as-is; sets `$PATH` |
| `solaar/` | Logitech device config and rules | Used as-is |
| `firefox/` | `user.js` + `userChrome.css` for YT Music and Google Home profiles | See step 5 |
| `mozilla/firefox/<main-profile>/chrome/` | `userChrome.css` for main profile | See step 5 |
| `rofi/`, `micro/`, `qt6ct/`, `gtk-3.0/`, `gtk-4.0/`, `nwg-displays/`, `neofetch/`, `networkmanager-dmenu/`, `swaync/` | App configs | Used as-is |
| `mimeapps.list`, `user-dirs.dirs` | Default apps (Firefox), XDG dirs | Ask before overwriting |
| `hypr/`, `waybar/` | Old Hyprland desktop | Only if the user wants Hyprland |

## 4. Noctalia

Noctalia loads **every `*.toml` in `~/.config/noctalia/`**, then `~/.local/state/noctalia/settings.toml` overrides. `noctalia-config.toml` is the merged result of both, so no state file is needed on the new machine.

1. Fix the local plugin path in `noctalia-config.toml` (`[[plugins.source]]`, `name = "local"`): `/home/namit/.config/noctalia-plugins` → `<new home>/.config/noctalia-plugins`.
2. `noctalia config validate`. Expect warnings about unknown or missing plugins until step 3.
3. Start Noctalia (niri autostarts it: `spawn-at-startup "noctalia"`).
4. Plugins from the `official` and `community` git sources download on first run. Enabled list: `[plugins] enabled` in the config.
5. If a local plugin looks stale, reload it:
   `noctalia msg plugins disable <id>; sleep 2; noctalia msg plugins enable <id>`
   (ids: `namitjuneja/niri-taskbar`, `namitjuneja/niri-workspaces`)

Notes:
- `niri-taskbar` needs `workspace "stash"` in `niri/config.kdl` (already there) and `jq`.
- Known validate warnings on the old machine: `[panels]` unknown section, missing plugins `gcap0n1/f1` and `namitjuneja/ytm-media`. Harmless; ask before removing.

## 5. Firefox

Only config files are tracked. Cookies, logins and extensions are **not** (repo is public). Use Firefox Sync for those.

**Main profile**
1. Launch Firefox once, then quit. It creates a profile dir with a new random name.
2. Find it in `~/.mozilla/firefox/` (or `~/.config/mozilla/firefox/` if the tree is `XDG`-style). Ask which one is the default profile.
3. Copy `mozilla/firefox/oqk2vkmz.default-release-*/chrome/userChrome.css` into `<profile>/chrome/`.
4. In `about:config`, set `toolkit.legacyUserProfileCustomizations.stylesheets` = `true` (there is no tracked main-profile `user.js`).

**YT Music and Google Home** (separate instances)
```
mkdir -p ~/.local/share/ytm-firefox ~/.local/share/home-firefox
ln -s ~/.config/firefox/ytm-firefox/user.js  ~/.local/share/ytm-firefox/user.js
ln -s ~/.config/firefox/ytm-firefox/chrome   ~/.local/share/ytm-firefox/chrome
ln -s ~/.config/firefox/home-firefox/user.js ~/.local/share/home-firefox/user.js
ln -s ~/.config/firefox/home-firefox/chrome  ~/.local/share/home-firefox/chrome
```
- Launch once with the niri binds (`Mod+F9`, `KP_Multiply`) and sign in. Google Home needs a Google login.
- Details: `firefox/README.md`, and the Firefox section in `README.md`.

## 6. Hardcoded paths

Tracked files containing `/home/namit` (ask before editing each; or just keep the username `namit`):
- `noctalia/noctalia-config.toml` (local plugin source)
- `hypr/hyprlock.conf`, `hypr/hyprpaper.conf` (Hyprland only)
- `gtk-3.0/bookmarks`, `fish/fish_variables`
- Optional keyd config in `README.md` § Noctalia peek bar (`runuser -u namit`, UID 1000).

## 7. Optional extras

- **keyd** (tap Alt to flash the peek bar): `/etc/keyd/default.conf`, config in `README.md`. Needs `sudo`; ask first.
- **Logitech MX Keys S:** niri binds assume Lock = `Alt+L`, Print Screen = `Alt+Shift+S`.
- **Wallpaper / lock screen:** Hyprland only (`hyprpaper`, `hyprlock`); Noctalia handles these under niri.

## 8. Verify

- `niri validate` — config parses.
- `noctalia config validate` — config loads.
- Log in to a niri session; the bar shows `niri-workspaces` and `niri-taskbar`.
- Check binds: `Mod+Return` (terminal), `Mod+F1` (Firefox), `Mod+F9` (YT Music), media keys, volume keys.

## Not in the repo

- App data and logins: Firefox, Chrome, Slack, Code, Obsidian, Todoist.
- `fish_history`, KDE and Dolphin prefs, `kdeconnect` pairing keys.
- Firefox extensions and cookies.
