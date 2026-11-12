# New installation playbook

For me. Follow in order. Claude's version: `new-installation.md`.

## 1. Basics + Firefox
- Install `git` and `yay` only:
  ```
  sudo pacman -S --needed git base-devel
  git clone https://aur.archlinux.org/yay-bin.git ~/yay-bin
  cd ~/yay-bin && makepkg -si
  ```
  - CachyOS may ship `yay` already: check `yay --version` first.
- Install Firefox, open it once, log in to Firefox and Google accounts, quit.
  ```
  sudo pacman -S firefox
  ```
  - Why: this creates the profile folder step 8 needs.

## 2. Claude Code
- Install Claude Code in the terminal and log in:
  ```
  curl -fsSL https://claude.ai/install.sh | bash
  claude
  ```
  - Restart the shell if `claude` is not found (installs to `~/.local/bin`).

## 3. Dotfiles
- Clone the dotfiles into a separate folder, not `~/.config`, and switch to `niri` (default is `master`, the old Hyprland setup):
  ```
  git clone https://github.com/namitjuneja/dotfiles ~/dotfiles-src
  cd ~/dotfiles-src && git checkout niri
  ```

## 4. Packages (before any config)
- Ask Claude: one install command per group, plus one line on what each package is for.
- Must include:
  - niri, noctalia
  - kitty, fish, rofi, jq, playerctl, wireplumber, brightnessctl, solaar, htop, micro
  - default-app programs: `evince` (PDF), `ark` (archives), `loupe` (images), `vlc` (video)
  - fonts
  - `ddcutil` (monitor brightness; needs I2C permissions)
  - `keyd` (Alt/Win tap keys; config goes in `/etc/keyd/default.conf`)
- Approve each group before it installs.
- Why first: the niri config calls these tools. Without them the keybinds break.

## 5. niri config
- Ask Claude to copy `niri/` (and `kitty/`).
- Run `niri validate`.
- Fix monitors and brightness for the new machine (Claude does it, ask first):
  - Run `niri msg outputs`. Replace the old output names (`DP-4`, `HDMI-A-2`) and their `mode`, `scale`, `position` in `config.kdl`.
  - Desktop with external monitor: brightness uses `ddcutil` (`enable_ddcutil = true` in the Noctalia config).
  - Laptop: brightness uses `brightnessctl`; set `enable_ddcutil = false`.

## 6. Noctalia
- Ask Claude to copy `noctalia/` and `noctalia-plugins/`.
- Check the plugin path in the config (it says `/home/namit/...`).
- Copy plugin data (e.g. world clock zones) from the old machine, then restart Noctalia: `cp -r <old>/.local/state/noctalia/plugins/data ~/.local/state/noctalia/plugins/`
- Clear the GUI override: `rm ~/.local/state/noctalia/settings.toml`, then restart Noctalia. Else its defaults beat the restored config (lock screen, wallpaper).
- Rename old monitor names (e.g. `DP-4`) to the new ones from `niri msg outputs`: `sed -i 's/DP-4/DP-2/g' ~/.config/noctalia/noctalia-config.toml`.
- Old machine, before wiping: `noctalia config export > ~/.config/noctalia/noctalia-config.toml` (merges GUI changes).
- Run `noctalia config validate`.
- Confirm niri and Noctalia work together: bar shows, workspaces and taskbar show, keybinds work.
- Log in to Google Calendar: account `personal_google` is already in the config; sign in from Noctalia's settings (Calendar section). Login is not stored in the repo.
- Do not go on until this works.

## 7. Remaining configs, one by one
- For each: Claude shows the file, says what it does, asks me, then copies on my yes.
- Skip `mimeapps.list`: step 12 rebuilds it.
- Skip `hypr/` and `waybar/` (old setup) unless I want them.

## 7b. keyd (needs sudo)
- Config is in the repo: `keyd/default.conf` (tap Alt flashes the bar, Win key sends F19).
- Ask Claude to:
  - Check it matches the new machine: username (`namit`), UID (`1000`), Wayland display (`wayland-1`). Fix if not.
  - Show me the file, then `sudo cp` it to `/etc/keyd/default.conf`.
  - `sudo systemctl enable --now keyd`, then `sudo keyd reload`.
- Test: tap Alt, the peek bar flashes.
- Claude asks before each `sudo` step.

## 8. Firefox profiles
- Main profile: copy `userChrome.css`, set the `about:config` pref.
- Main profile `about:config` prefs:
  - `sidebar.position_start` = `false`
  - `browser.nova.enabled` = `true`
  - `full-screen-api.warning.timeout` = `0`
- Settings → Search (address bar), main profile. Checked = on, rest off (pref in brackets):
  - Show search suggestions (`browser.search.suggest.enabled`): on.
  - Off: suggestions before history (`browser.urlbar.showSearchSuggestionsFirst`), in private windows (`browser.search.suggest.enabled.private`), trending (`browser.urlbar.trending.featureGate`).
  - Firefox Suggest: only Browsing history on (`browser.urlbar.suggest.history`).
  - Off: bookmarks (`.bookmark`), open tabs (`.openpage`), shortcuts (`.topsites`), recent searches (`.recentsearches`), search engines (`.engines`), quick actions (`.quickactions`), from Firefox (`.quicksuggest.nonsponsored`), sponsors (`.quicksuggest.sponsored`), all under `browser.urlbar.suggest`.
- Settings → Privacy and security → History → Advanced:
  - On: remember browsing and download history (`places.history.enabled`).
  - Off: always private (`browser.privatebrowsing.autostart`), remember search and form history (`browser.formfill.enable`), clear history on close (`privacy.sanitize.sanitizeOnShutdown`).
- YT Music and Google Home: make the dirs and symlinks.
- YT Music and Google Home: install [Vimium](https://addons.mozilla.org/firefox/addon/vimium-ff/) and [LeechBlock NG](https://addons.mozilla.org/firefox/addon/leechblock-ng/) in both, then import:
  - Vimium: Options → Backup and restore → [`firefox/vimium-options.json`](firefox/vimium-options.json).
  - LeechBlock: Options → Import → [`firefox/leechblock-options.txt`](firefox/leechblock-options.txt) (blocks everything except `home.google.com`, `music.youtube.com`).
  - Profiles run with `--no-remote`, so open the add-on pages from inside each window (`Ctrl+L`), or launch it by hand: `firefox --no-remote --profile ~/.local/share/<ytm|home>-firefox --new-window <url>`.
- Restart Firefox. Test `Mod+F9` (YT Music) and `KP_Multiply` (Home).
- Details: `firefox/README.md`.

## 9. Browser extensions
- Install uBlock Origin, Vimium, LeechBlock NG, Tab Center Reborn (Firefox Sync may bring the add-ons, not their settings).
- Vertical Custom (own add-on, unlisted): log in at AMO developer hub → "My Extension" → Manage Versions → download signed `.xpi` → open in Firefox. Bookmark: `https://addons.mozilla.org/en-US/firefox/addon/46a8e3abcda744e397f1/`.
- Restore settings in each:
  - uBlock: Settings → Backup/Restore → restore from file.
  - Vimium: Options → Backup and restore → import [`firefox/vimium-options.json`](firefox/vimium-options.json).
  - LeechBlock: Options → Import → [`firefox/leechblock-options.txt`](firefox/leechblock-options.txt).
  - Tab Center Reborn: Options → custom CSS → paste `firefox/tab-center-reborn.css` (main profile only).
- Do this in the main and YT Music profiles (separate profiles = separate extensions).
- Vimium and LeechBlock settings are in the repo; export uBlock's from the old PC first.

## 10. GitHub login (last)
- Only needed to push changes. Clone needs no login (repo is public).
  ```
  sudo pacman -S github-cli
  gh auth login
  ```

## 11. Apps (last)
- Obsidian, Slack, Nautilus:
  ```
  sudo pacman -S nautilus obsidian
  yay -S slack-desktop
  ```
- Log in to Slack, open the Obsidian vault.
- KDE Connect:
  ```
  sudo pacman -S kdeconnect
  cp -r <old>/.config/kdeconnect ~/.config/
  ```
  - Run command config comes from the repo (`kdeconnect/`); keys are not tracked (private key: never commit). Pair from the phone.
  - Needs autostart: `spawn-at-startup "kdeconnectd"` in `niri/config.kdl`.
  - Run command (Pixel 10a, after pairing): add `Disconnect All Bluetooth`, or copy `kdeconnect/<phone-id>/kdeconnect_runcommand/config` from the old machine.
    ```
    bluetoothctl devices Connected | awk '{print $2}' | xargs -r -n1 bluetoothctl disconnect
    ```
- niri already has binds and window rules for them (`Mod+F5` Nautilus, `Mod+F6` Obsidian).

## 12. Default apps (last)
- Do not copy `mimeapps.list` (its `.desktop` names are machine-specific).
- Ask Claude to build it fresh from this list, using the real `.desktop` names found on the new machine, and show me before writing:

  | Type | App |
  |---|---|
  | Web links, HTML (`http`, `https`, `about`) | Firefox |
  | PDF | Evince |
  | zip, rar | Ark |
  | png, jpeg | Loupe |
  | mp4, mkv | VLC |
  | Folders (`inode/directory`) | Nautilus (else folders open in kitty) |

- Test: open one file of each type.

## 13. KDE Connect firewall (last, needs sudo)
- Open the ports, restart the daemon, pair from the phone:
  ```
  sudo ufw allow 1714:1764/tcp && sudo ufw allow 1714:1764/udp
  pkill kdeconnectd; setsid -f kdeconnectd
  ```
- Phone and PC must be on the same LAN.
