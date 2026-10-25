# Niri Taskbar

A Noctalia bar widget (`namitjuneja/niri-taskbar:taskbar`) that replaces the built-in taskbar
and adds a "minimized" state for niri, which has no minimize of its own.

## How minimize works

Minimizing is split between `niri/window-cycle.sh` and this plugin.

- `Mod+N` (`window-cycle.sh skip`) moves focus to the next window, then parks the focused
  window on the named workspace `stash` (declared in `niri/config.kdl`).
- Before moving it, the script writes `$XDG_RUNTIME_DIR/niri-skip/<window id>`, a JSON mark
  `{"ws": <origin workspace id>, "name": <origin workspace name or null>, "col": <column or null>}`.
- Restoring (`Mod+N` on a minimized window, `Mod+Shift+N`, or a taskbar click, i.e.
  `window-cycle.sh restore <id>`) moves the window back to its origin workspace (by name, else
  by id, else the focused workspace), puts a tiled window back in its column, focuses it and
  deletes the mark. Marks of closed windows are dropped the next time `Mod+Tab` runs.

## Floating windows and Mod+Tab / Mod+`

`Mod+Tab` / `Mod+Shift+Tab` (`window-cycle.sh next|prev`) cycle only the tiled windows and park every
floating window of the workspace on `stash`, using the same mechanism with an extra `"auto": true` in the mark.
From a floating window they return to the tiled window last focused through the script.

`Mod+\`` / `Mod+Shift+\`` (`float-next|float-prev`) cycle the floating windows; each press brings the next
one back in front, so they appear one by one.

- `window-cycle.sh watch` (started from `niri/config.kdl`) also tucks the floating windows away when a new tiled
  window opens, and nudges each new `floating-term` window (`Mod+Shift+Return`) by a random offset so they don't stack.
- Auto-stashed windows stay in the taskbar (styled like ordinary unfocused windows). Focus changes by other
  means (mouse, `Alt+Tab`, arrows) don't stash.

## What the taskbar shows

One item per window (icon, title), in on-screen order: tiled windows by column then row,
then floating ones. A minimized window keeps its slot (tiled: its old column; floating: among the floating ones) and is just dimmed. It is listed under the workspace
it came from, not under `stash`. With `only_active_workspace` (default) the bar shows the
focused workspace's windows plus its minimized ones.

| State | Style |
| --- | --- |
| Focused | bold title, accent (`primary`) pill at 35% |
| Unfocused | soft grey tile (`on_surface` at 24%), title and icon at `inactive_opacity` (75%) |
| Minimized | no background, dimmer (`skipped_opacity`, 40%), `skipped_color` title |

The strikethrough and eye-off badge are still available but off by default (`skipped_strikethrough`,
`skipped_badge`). A thin `│` separates the tiled windows from the floating ones.

Windows the Mod+Tab cycle auto-stashed look like ordinary unfocused windows (only Mod+N minimizes visibly). Clicking a window focuses it; clicking a parked one restores it.

## Updates

No timer. A `niri msg event-stream` follower repolls on window and workspace events, and
`window-cycle.sh` pushes a `refresh` IPC event to the widget when it changes a mark. The widget only redraws
when the window list actually changed and caches icon lookups, because Noctalia disables a widget whose
callbacks exceed its CPU budget.

## Settings

`icon_size`, `show_window_title`, `title_max_chars`, `only_active_workspace`,
`inactive_opacity`, `skipped_opacity`, `skipped_color`, `skipped_strikethrough`, `skipped_badge`.

## Setup

1. Keep `workspace "stash"` in `niri/config.kdl` (after the numbered workspaces).
2. Enable the plugin and put `niri-taskbar` in the bar's widget list; define
   `[widget.niri-taskbar]` with `type = "namitjuneja/niri-taskbar:taskbar"`.
   Noctalia's live bar layout is in `~/.local/state/noctalia/settings.toml`, which overrides
   `~/.config/noctalia/settings.toml`.
3. Requires `niri`, `jq` and `sh`.

Not copied from the built-in taskbar: the focused-window underline, grouping options and
other click actions.
