# Waybar Config — Setup Notes

Based on [`shivam-salkar/minimal-waybar-config`](https://github.com/shivam-salkar/minimal-waybar-config)
as a starting point, customized for this setup.

---

## File Structure

```
~/.config/waybar/
├── config.jsonc              # bar layout — which modules go where
├── modules.json              # module definitions — how each module behaves
├── style.css                 # visual styling (pill-style dark theme)
└── scripts/
    ├── launch.sh             # kill + restart waybar
    ├── sysmon.sh             # CPU/RAM/GPU usage for tooltip
    ├── power-profiles.sh     # rofi power profile picker (Performance/Balanced/Saver)
    └── powermenu.sh          # rofi power menu (Shutdown/Reboot/Suspend/Lock)
```

---

## Dependencies

These need to be installed for all modules to work:

```bash
# pacman
sudo pacman -S waybar pavucontrol playerctl networkmanager

# AUR
yay -S rofi-bluetooth-git

# For network menu
# networkmanager_dmenu needs to be cloned/installed separately:
# https://github.com/firecat53/networkmanager-dmenu
# OR use: sudo pacman -S networkmanager-dmenu (if available in your repos)
```

Also requires:
- `nvidia-smi` — for GPU usage in sysmon (falls back to "N/A" if not present)
- `powerprofilesctl` — for the power profiles script (`power-profiles-daemon` package)
- `rofi-wayland` — used by powermenu and power-profiles scripts
- `hyprlock` — called by the Lock option in powermenu
- `JetBrainsMono Nerd Font` — used in rofi scripts and CSS

```bash
sudo pacman -S power-profiles-daemon rofi-wayland
yay -S ttf-jetbrains-mono-nerd
```

---

## Bar Layout (config.jsonc)

```
Position:  bottom
Height:    42px
Spacing:   6px
```

| Section | Modules |
|---|---|
| Left | `hyprland/workspaces` |
| Center | `hyprland/window` |
| Right | `pulseaudio`, `bluetooth`, `network`, `custom/sysmon`, `battery`, `clock`, `custom/power` |

Module definitions are split into `modules.json` and loaded via `"include"`.
This keeps `config.jsonc` clean — it only handles layout.

---

## Module Definitions (modules.json)

### hyprland/workspaces

- Scroll disabled on the workspace bar
- Shows workspaces from all outputs (`all-outputs: true`)
- **Always shows workspaces 1–10** regardless of whether they have windows
  (`persistent-workspaces: { "*": [1..10] }`)
- Format: just the workspace name (number)

### hyprland/window

- Shows current window title with a leading spaces/icon prefix: `   {}`

### pulseaudio

- Shows volume icon + percentage
- Max volume: 150% (allows boosting past 100%)
- Scroll step: 5%
- Muted icon: ``
- Click opens `pavucontrol`

### bluetooth

- Shows a single bluetooth icon ``
- Tooltip shows connection status
- Click opens `rofi-bluetooth` (requires `rofi-bluetooth-git` from AUR)

### network

- WiFi icon: `` / Ethernet icon: `` / Disconnected: `⚠`
- Tooltip shows SSID, signal strength, and up/down bandwidth
- Refreshes every 2 seconds
- Click opens `networkmanager_dmenu`

### custom/sysmon

- Shows a single icon `` with a tooltip
- Tooltip runs `scripts/sysmon.sh` every 2 seconds
- Tooltip content: `CPU: X% | MEM: X% | GPU: X%`
- GPU detection: tries `nvidia-smi` first, falls back to "N/A"

### battery

- Warning at 30%, critical at 15%
- Icons: `     ` (empty → full)
- Charging: ` {capacity}%`
- Plugged: ` {capacity}%`
- Click runs `scripts/power-profiles.sh` — opens rofi picker for
  Performance / Balanced / Power Saver mode (uses `powerprofilesctl`)

### clock

- Format: ` 03:45 PM    6 April`  (12-hour time, day + month)
- Tooltip: calendar view for current month

### custom/power

- Shows `` (power icon)
- Click runs `scripts/powermenu.sh` — opens rofi menu with:
  - Shutdown → `systemctl poweroff`
  - Reboot → `systemctl reboot`
  - Suspend → `hyprctl dispatch exit` *(note: this exits Hyprland, not suspends — may want to fix to `systemctl suspend`)*
  - Lock → `hyprlock`

---

## Styling (style.css)

### Theme overview

- **Pill-style** dark bar — each section (left/center/right) is a rounded pill
- Background: transparent window, `#0b1220` (dark navy) pills
- Text: `#e6e8ee` (off-white)
- Hover background: `#111a2e` (slightly lighter navy)
- Font: `SpaceMono Nerd Font` / `JetBrainsMono Nerd Font`

### Workspaces

- Inactive buttons: transparent background, `#e6e8ee` text
- Active button: `#c9c6ff` (light lavender) background, `#0b1220` dark text
- Hover: same as active

### Module padding

All standard modules get `padding: 0 10px` and `border-radius: 100px` for
the pill shape within the right section.

### Notable per-module overrides

| Module | Notes |
|---|---|
| `#custom-sysmon` | `font-size: 20px` (larger icon) |
| `#custom-power` | Color `#e06c75` (soft red), turns blue on hover |
| `.modules-left` | No padding (workspaces flush to edge) |
| `.modules-center` | Extra horizontal padding (`0 10px`) |

---

## Scripts

### scripts/launch.sh

```bash
killall -9 waybar
waybar &
```

Use this to restart waybar after config changes. Can also run:
```bash
killall waybar; waybar &
```

### scripts/sysmon.sh

Reads CPU usage from `top`, RAM from `free`, GPU from `nvidia-smi`.
Output format: `CPU: 12% | MEM: 45% | GPU: 8%`

### scripts/power-profiles.sh

Rofi dmenu for switching power profiles via `powerprofilesctl`.
Sends a desktop notification on change (`notify-send`).
Options: Performance / Balanced / Power Saver.

Requires: `power-profiles-daemon` (systemd service, enable if not running):
```bash
sudo systemctl enable --now power-profiles-daemon
```

### scripts/powermenu.sh

Rofi dmenu for system power actions.
Font: JetBrainsMono Nerd Font 16, window width 24%.

> **Bug:** The "Suspend" option calls `hyprctl dispatch exit` which exits
> Hyprland rather than suspending the system. To fix, change that line to:
> ```bash
> *Suspend*) systemctl suspend ;;
> ```
