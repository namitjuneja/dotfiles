#!/bin/bash
# Lists every window on the currently focused workspace (with its title, not just
# the app class, so multiple windows of the same app are distinguishable), so waybar
# keeps showing the whole workspace even while one window is maximized/fullscreen.
#
# Styling: each entry gets a small per-app glyph (in that app's brand-ish color,
# dimmed when inactive) so the eye can scan "which app" without reading text. The
# active window gets a highlight rendered with Powerline half-circle caps instead
# of a flat span background, since Pango markup has no border-radius -- that's the
# only way to get rounded ends on inline text. Icon glyphs are all from the Nerd
# Font "md-" (Material Design) set, encoded here as \uXXXX surrogate pairs rather
# than raw UTF-8 -- pasting the raw glyphs for icons outside the BMP silently
# produced empty spans (kitty/files/chrome/spotify/steam all went blank) even
# though otfinfo confirmed the font has them, so escapes are the reliable path.
#
# Every entry -- active or not -- renders the exact same characters (cap glyphs,
# spaces, background span) in the exact same order; only the colors differ, with
# inactive entries' caps/background painted the bar's own background color so
# they're invisible. That's required, not cosmetic: if the inactive markup were
# shorter than the active one, the whole line would visibly reflow every time the
# focused window changes, shifting every entry after it.
#
# Every icon and cap glyph is pinned to font_family="MesloLGS Nerd Font Mono"
# explicitly. Without it, Pango/fontconfig picks whichever installed font covers
# that codepoint by its own fallback order, and for some glyphs that landed on an
# unpatched standalone icon font with much taller vertical metrics than the
# terminal-oriented Nerd Font Mono build -- which visibly clipped those icons top
# and bottom against the bar's fixed height. Pinning the font makes metrics
# consistent across every glyph. The cap glyphs are sized relative to the text
# (currently 90%) to control how rounded the highlight's corners look.

BAR_BG="#0b1220"

ws=$(hyprctl activeworkspace -j | jq -r '.id')
active=$(hyprctl activewindow -j | jq -r '.address // empty')

hyprctl clients -j | jq -r --arg ws "$ws" --arg active "$active" --arg barbg "$BAR_BG" '
  def esc: gsub("&"; "&amp;") | gsub("<"; "&lt;") | gsub(">"; "&gt;");
  def trunc(n): if (length > n) then .[0:n] + "…" else . end;
  # drop the redundant "<title> - <app name>" suffix browsers/editors append
  def declutter:
    sub("\\s+[-—]\\s+(Mozilla Firefox|Firefox|Google Chrome|Chromium Web Browser|Chromium|Brave|Microsoft Edge|Visual Studio Code)\\s*$"; ""; "i");
  def appinfo:
    ascii_downcase as $c |
    if ($c | test("firefox")) then {icon: "󰈹", fg: "#ff8a5c", dim: "#7a5240"}
    elif ($c | test("code|codium")) then {icon: "󰨞", fg: "#4fa3ff", dim: "#3d5878"}
    elif ($c | test("kitty|foot|alacritty|wezterm|term")) then {icon: "󰆍", fg: "#7ee787", dim: "#4a6b52"}
    elif ($c | test("thunar|nautilus|dolphin|files|nemo")) then {icon: "󰉋", fg: "#ffc64b", dim: "#7a6b45"}
    elif ($c | test("obsidian")) then {icon: "󱓧", fg: "#b18cff", dim: "#5f5480"}
    elif ($c | test("chrome|chromium")) then {icon: "󰊯", fg: "#5b9dff", dim: "#3d5878"}
    elif ($c | test("spotify")) then {icon: "󰓇", fg: "#3ddc73", dim: "#356b48"}
    elif ($c | test("discord|vesktop")) then {icon: "󰙯", fg: "#8b93ff", dim: "#4d5299"}
    elif ($c | test("slack")) then {icon: "󰒱", fg: "#f2c744", dim: "#7a6b3a"}
    elif ($c | test("steam")) then {icon: "󰓓", fg: "#7fd0ff", dim: "#4a6478"}
    else {icon: "󰆍", fg: "#9aa5c9", dim: "#5b6488"} end;
  [ .[] | select(.workspace.id == ($ws | tonumber)) ] |
  if length == 0 then
    "<span foreground=\"#555e7a\"> Desktop</span>"
  else
    map(
      ((.class // .initialClass) | esc) as $cls |
      ((.title // "") | esc | declutter | trunc(30)) as $ttl |
      ((.class // .initialClass) | appinfo) as $a |
      (if .address == $active then "#2d2456" else $barbg end) as $pill |
      (if .address == $active then $a.fg else $a.dim end) as $iconcol |
      (if .address == $active then "#f1eaff" else "#6b7590" end) as $clscol |
      (if .address == $active then "#c7b8ff" else "#8a93ac" end) as $ttlcol |
      "<span foreground=\"" + $pill + "\" font_family=\"MesloLGS Nerd Font Mono\" size=\"90%\"></span>" +
      "<span background=\"" + $pill + "\">  <span foreground=\"" + $iconcol + "\" font_family=\"MesloLGS Nerd Font Mono\">" + $a.icon + "</span>  <span foreground=\"" + $clscol + "\">" + $cls + "</span>  <span foreground=\"" + $ttlcol + "\">" + $ttl + "</span>  </span>" +
      "<span foreground=\"" + $pill + "\" font_family=\"MesloLGS Nerd Font Mono\" size=\"90%\"></span>"
    ) | join("<span foreground=\"#2a3252\"> │ </span>")
  end
'
