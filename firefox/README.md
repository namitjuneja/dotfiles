# Firefox

Three separate Firefox profiles, each its own instance with its own cookies, logins and extensions. Only `user.js` and `chrome/userChrome.css` are tracked here. The repo is public and profile dirs hold cookies and logins.

## Profiles

| | Main (browsing) | YT Music | Google Home |
|---|---|---|---|
| Path | `mozilla/firefox/oqk2vkmz.default-release-*` (in repo) | `~/.local/share/ytm-firefox` | `~/.local/share/home-firefox` |
| Tracked config | the profile dir itself | `firefox/ytm-firefox/` | `firefox/home-firefox/` |
| Launch | `Mod+F1`, `KP_Add`, `KP_Subtract` | `Mod+F9` (workspace 9) | `KP_Multiply` |
| Browser UI | Tab strip and sidebar header hidden, square corners | None, page only | None, page only |
| Window | Normal tiled | Normal tiled | Floating 480x640 panel, centered |
| Starts with `--no-remote` | No | Yes | Yes (plus `--name home-panel`) |
| Purpose | Everyday browsing, Gmail and UB mail | YouTube Music, controlled by media keys | Google Home dashboard popup |
| Wake locks | Default | Disabled (see below) | Default |

The two `~/.local/share` profiles symlink `user.js` and `chrome/` into `firefox/`. On a new machine, create the dirs, then relink.

`userChrome.css` needs `toolkit.legacyUserProfileCustomizations.stylesheets=true` in `user.js`.

### Why separate profiles
- **Separate process:** `--no-remote` starts a new Firefox instead of joining the main one. This gives YT Music its own MPRIS player name, so `niri/ytm-player.sh` can aim `playerctl -p` at it only. The Home panel gets its own Wayland app-id, so niri window rules match only it.
- **Chromeless UI:** the YT Music and Home profiles hide all toolbars with `userChrome.css`. The main profile keeps its toolbar.
- **Isolated settings:** prefs like the wake-lock ones below apply to music only, not to everyday browsing.

## YT Music wake locks (so noctalia still locks while music plays)

Goal: playing YouTube Music must not block idle, so noctalia locks after the idle timeout.

Two prefs, set in `firefox/ytm-firefox/user.js`:

| Pref | Value | What it does |
|---|---|---|
| `media.video-wakelock` | `false` | Firefox itself holds a wake lock while any `<video>` plays. Page does nothing. Note the hyphen in the name. |
| `dom.screenwakelock.enabled` | `false` | Disables the web Screen Wake Lock API (`navigator.wakeLock.request('screen')`), which is a page asking for a lock. |

You need both: the first stops Firefox's own lock, the second ignores the site's requests.

`media.wakelock.audio.delay-releasing.ms` only sets how long an audio lock lingers after playback stops. It does not turn the lock off. Left at default.

To verify: play music past the idle timeout and confirm noctalia locks. `systemd-inhibit --list` only shows logind inhibitors. Idle inhibit over the Wayland protocol does not appear there.

To change a pref by hand: open `about:config` in this profile with `firefox --profile ~/.local/share/ytm-firefox --new-tab about:config` (no `--no-remote`, so it joins the running instance). Prefs set that way land in `prefs.js`, which is untracked. Put them in `user.js` to keep them.

## Profile details

See the Firefox section of the [root README](../README.md#firefox) for launch commands, the Home floating-window bind, mail binds and gotchas.
