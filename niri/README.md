# niri config notes

## Dynamic struts

Hint that more columns exist off-screen, without wasting space when everything fits.

- `dynamic-struts.sh` follows niri's event stream and rewrites `struts.kdl` (generated, changes constantly).
- `config.kdl` pulls it in with `include "struts.kdl"` at the bottom (niri only allows `include` at top level). The `layout { struts }` block in `config.kdl` itself is empty on purpose.
- Rules, evaluated for the focused workspace's tiled columns:
  - All columns fit (or only one column): left and right struts are 0.
  - Overflow: left strut is `STRUT` if a column exists left of the focused one, right strut likewise on the right.
- Tunables at the top of the script: `STRUT=36` (peek width + gap), `GAP=10` (must match `layout { gaps }`), and the 0.05s debounce in the event loop (a longer one adds a second visible jolt after a window opens).
- Started from `spawn-at-startup` in `config.kdl`.
- Niri does not re-scroll the view when struts change, so the left peek may only appear after one focus move.

### Disable

1. Stop the script: find it with `ps -eo pid,args | grep '[d]ynamic-struts'` and kill the PIDs. Do NOT use `pkill -f dynamic-struts` from a shell command containing that text; it kills the calling shell.
2. Delete the `spawn-at-startup ... dynamic-struts.sh` line in `config.kdl`.
3. Overwrite `struts.kdl` with fixed values (keep the file and the `include`, or the config fails to load):

       layout {
           struts {
               left 0
               right 0
           }
       }

   Use a fixed number instead of 0 for permanent edge peeks.

### Re-enable

Restore the `spawn-at-startup` line and start `./dynamic-struts.sh` (`setsid nohup`).

`struts.kdl` is generated; consider keeping it out of commits.

## Mod+F

`float-toggle.sh`: toggles floating; a tiled window at least 85% of screen height gets resized to 65% of screen height at 3:2 and centered.
