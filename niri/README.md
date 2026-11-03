# niri config notes

## Mod+F

`float-toggle.sh`: toggles floating; a tiled window at least 85% of screen height gets resized to 65% of screen height at 3:2 and centered.

## Mod+M
`scripts/maximize-focused.sh`: focused window → tiled + maximized to edges (floating gets tiled first). Press again: unmaximize, stays tiled.
- Floating windows still open floating: `kitty/kitty.conf` sets `remember_window_size no`, else kitty restores "maximized" and niri tiles it.
- `scripts/maximize-all.sh` (old: maximize every column) is unused.

## Mod+Shift+B
`scripts/cycle-audio-sink.sh`: cycles default audio sink (all sinks, wraps), moves playing streams, notifies "name · volume" (replaces itself).
