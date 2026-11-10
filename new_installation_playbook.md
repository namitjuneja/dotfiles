# New installation playbook

For me. Follow in order. Claude's version: `new-installation.md`.

## 1. Basics + Firefox
- Install `git` and `yay` only.
- Install Firefox, open it once, log in to Firefox and Google accounts, quit.
  - Why: this creates the profile folder step 8 needs.

## 2. Claude Code
- Install Claude Code in the terminal and log in.

## 3. GitHub
- Install `gh`, log in (`gh auth login`).
- Clone the dotfiles into a separate folder, not `~/.config`.
- `git checkout niri` (default is `master`, the old Hyprland setup).

## 4. Packages (before any config)
- Ask Claude: one install command per group, plus one line on what each package is for.
- Must include:
  - niri, noctalia
  - kitty, fish, rofi, jq, playerctl, wireplumber, brightnessctl, solaar, htop, micro
  - fonts
  - `ddcutil` (monitor brightness; needs I2C permissions)
  - `keyd` (Alt/Win tap keys; config goes in `/etc/keyd/default.conf`)
- Approve each group before it installs.
- Why first: the niri config calls these tools. Without them the keybinds break.

## 5. niri config
- Ask Claude to copy `niri/` (and `kitty/`).
- Run `niri validate`.

## 6. Noctalia
- Ask Claude to copy `noctalia/` and `noctalia-plugins/`.
- Check the plugin path in the config (it says `/home/namit/...`).
- Run `noctalia config validate`.
- Confirm niri and Noctalia work together: bar shows, workspaces and taskbar show, keybinds work.
- Do not go on until this works.

## 7. Remaining configs, one by one
- For each: Claude shows the file, says what it does, asks me, then copies on my yes.
- Includes the keyd config.
- Skip `hypr/` and `waybar/` (old setup) unless I want them.

## 8. Firefox profiles
- Main profile: copy `userChrome.css`, set the `about:config` pref.
- YT Music and Google Home: make the dirs and symlinks.
- Restart Firefox. Test `Mod+F9` (YT Music) and `KP_Multiply` (Home).
- Details: `firefox/README.md`.
