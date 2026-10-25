# Niri Taskbar

A Noctalia bar widget (`namitjuneja/niri-taskbar:taskbar`) that replaces the built-in taskbar
and adds a "minimized" state for niri, which has no minimize of its own.

## How minimize works

Minimizing is split between `niri/window-cycle.sh` and this plugin.

- `Mod+Shift+N` (`window-cycle.sh skip`) moves focus to the next window, then parks the focused
  window on the named workspace `stash` (declared in `niri/config.kdl`).
- Before moving it, the script writes `$XDG_RUNTIME_DIR/niri-skip/<window id>`, a JSON mark
  `{"ws": <origin workspace id>, "name": <origin workspace name or null>, "col": <column or null>}`.
- Restoring (`Mod+Shift+N` on a minimized window, `Mod+Ctrl+N`, or a taskbar click, i.e.
  `window-cycle.sh restore <id>`) moves the window back to its origin workspace (by name, else
  by id, else the focused workspace), puts a tiled window back in its column, focuses it and
  deletes the mark. Marks of closed windows are dropped the next time `Mod+Tab` runs.

## Floating windows and Mod+Tab

`Mod+Tab` / `Mod+Shift+Tab` (`window-cycle.sh next|prev`) also stash floating windows, using the
same mechanism with an extra `"auto": true` in the mark:

- Cycling onto a **tiled** window parks every visible floating window of the workspace on `stash`.
- Cycling onto a **stashed floating** window brings just that one back in front; the other
  floating windows keep their state, so cycling floating to floating never stashes anything.
- Auto-stashed windows stay in the Mod+Tab order of their origin workspace and in the taskbar
  (styled like minimized ones). Focus changes by other means (mouse, `Alt+Tab`, arrows) don't stash.

## What the taskbar shows

One item per window (icon, title), in on-screen order: tiled windows by column then row,
then floating ones, then minimized ones. A minimized window is listed under the workspace
it came from, not under `stash`. With `only_active_workspace` (default) the bar shows the
focused workspace's windows plus its minimized ones.

| State | Style |
| --- | --- |
| Focused | bold title, highlighted background |
| Unfocused | dimmed (`inactive_opacity`) |
| Minimized | dimmer (`skipped_opacity`), `skipped_color`, struck-through title, eye-off badge |

Clicking a window focuses it; clicking a minimized window restores it.

## Updates

No timer. A `niri msg event-stream` follower repolls on window and workspace events, and
`window-cycle.sh` pushes a `refresh` IPC event to the widget when it changes a mark.

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
