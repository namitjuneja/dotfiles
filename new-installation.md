# New installation guide

Restore this repo on a fresh Arch/CachyOS machine. Main desktop: **niri + Noctalia**. `hypr/` and `waybar/` are the older Hyprland setup, kept as fallback.

> The user follows `new_installation_playbook.md` (short, step order). Follow its order: packages before configs; Noctalia must work with niri before the rest.

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
- **niri stack:** `niri`, `noctalia`, `kitty`, `fish`, `rofi-wayland`, `jq`, `playerctl`, `wireplumber` (`wpctl`), `brightnessctl`, `ddcutil` (external monitor brightness; needs I2C permissions), `firefox`, `solaar`, `htop`, `micro`, `keyd`.
- **Default-app programs:** `evince` (PDF), `ark` (archives), `loupe` (images), `vlc` (video).
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
| `keyd/` | `default.conf` for `/etc/keyd/` | Not copied by default; see 7b (sudo) |
| `fish/` | `config.fish` (aliases, git helpers) | Used as-is; sets `$PATH` |
| `solaar/` | Logitech device config and rules | Used as-is |
| `firefox/` | `user.js` + `userChrome.css` for YT Music and Google Home profiles | See step 5 |
| `mozilla/firefox/<main-profile>/chrome/` | `userChrome.css` for main profile | See step 5 |
| `rofi/`, `micro/`, `qt6ct/`, `gtk-3.0/`, `gtk-4.0/`, `nwg-displays/`, `neofetch/`, `networkmanager-dmenu/`, `swaync/` | App configs | Used as-is |
| `mimeapps.list` | Old default apps, machine-specific names | **Do not copy.** See "Default apps" |
| `user-dirs.dirs` | XDG dirs | Ask before overwriting |
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

6. Google Calendar: `[calendar.account.personal_google]` (type `google`) is in the config; sign in once from Noctalia's settings (Calendar section). Login is not tracked in the repo.

Notes:
- `niri-taskbar` needs `workspace "stash"` in `niri/config.kdl` (already there) and `jq`.
- Known validate warnings on the old machine: `[panels]` unknown section, missing plugins `gcap0n1/f1` and `namitjuneja/ytm-media`. Harmless; ask before removing.

## 4b. Monitors and brightness (hardware-specific)

`niri/config.kdl` has `output` blocks for this machine's monitors (`DP-4`, `HDMI-A-2`: `mode`, `scale`, `position`). They will not match a new machine. Ask before changing.

1. Run `niri msg outputs`; show the user the names, modes and scales.
2. Propose new `output` blocks; replace the old ones after a yes.
3. Brightness:
   - Desktop with external monitor (no backlight): `ddcutil` over DDC/CI. Keep `enable_ddcutil = true` in `noctalia/noctalia-config.toml`; needs `ddcutil` and I2C permissions.
   - Laptop (backlight device): `brightnessctl`. Set `enable_ddcutil = false`.
4. Test `Mod+Shift+=` / `Mod+Shift+-` (they call `noctalia msg brightness-up/down`).

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
- `keyd/default.conf` (`runuser -u namit`, UID 1000, `WAYLAND_DISPLAY=wayland-1`). See 7b.

## 7. Optional extras

- **Logitech MX Keys S:** niri binds assume Lock = `Alt+L`, Print Screen = `Alt+Shift+S`.
- **Wallpaper / lock screen:** Hyprland only (`hyprpaper`, `hyprlock`); Noctalia handles these under niri.

## 7b. keyd (required; needs sudo)

Config is tracked at `keyd/default.conf`; live path is `/etc/keyd/default.conf`. Tap Alt flashes the Noctalia peek bar; Win key sends F19. Ask before each step.

1. Check `keyd/default.conf` against the new machine: `whoami` (file says `namit`), `id -u` (file says `1000`), `echo $WAYLAND_DISPLAY` (file says `wayland-1`). Propose fixes.
2. Show the file. After a yes: `sudo cp keyd/default.conf /etc/keyd/default.conf`.
3. After a yes: `sudo systemctl enable --now keyd`, then `sudo keyd reload`.
4. Test: tap Alt, the peek bar should flash. Needs Noctalia running (see 4).
5. Undo: `sudo systemctl disable --now keyd`.

## 7c. Default apps (last step)

Do not copy `mimeapps.list`. Its `.desktop` names (`evince-6`, `ark-2`, `loupe-2`, `vlc-3`) are numbered duplicates from the old machine. Build it fresh:

1. Install the programs first (see Packages).
2. Find real names: `ls /usr/share/applications | grep -i -E "firefox|evince|ark|loupe|vlc|nautilus"`.
3. Map these types (show the user the mapping, wait for a yes, then write):
   - `x-scheme-handler/http`, `x-scheme-handler/https`, `x-scheme-handler/about`, `x-scheme-handler/unknown`, `text/html`, `application/xhtml+xml` → Firefox
   - `application/pdf` → Evince
   - `application/zip`, `application/vnd.rar` → Ark
   - `image/png`, `image/jpeg` → Loupe
   - `video/mp4`, `video/x-matroska` → VLC
   - `inode/directory` → Nautilus (`org.gnome.Nautilus.desktop`; else folders open in kitty)
4. Set each with `xdg-mime default <real>.desktop <type>` (writes `~/.config/mimeapps.list`).
5. Check: `xdg-mime query default <type>`.

## 8. Verify

- `niri validate` — config parses.
- `noctalia config validate` — config loads.
- Log in to a niri session; the bar shows `niri-workspaces` and `niri-taskbar`.
- Check binds: `Mod+Return` (terminal), `Mod+F1` (Firefox), `Mod+F9` (YT Music), media keys, volume keys.

## Not in the repo

- App data and logins: Firefox, Chrome, Slack, Code, Obsidian, Todoist.
- `fish_history`, KDE and Dolphin prefs, `kdeconnect` pairing keys.
- Firefox extensions and cookies.
