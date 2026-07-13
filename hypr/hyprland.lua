-- Hyprland Lua config.
-- 1:1 translation of hyprland.conf for Hyprland >= 0.55 (hyprlang is deprecated
-- in favor of Lua as of 0.55; old .conf syntax is only supported 1-2 releases
-- more, per https://hypr.land/news/26_lua/).
--
-- IMPORTANT: Hyprland checks for this file ONLY at startup. If hyprland.lua
-- exists, it is loaded INSTEAD of hyprland.conf -- the two are not merged.
-- Keep only one of them around once you've confirmed this works, otherwise
-- you'll have to hand-edit both on every change.
--
-- Reference: https://wiki.hypr.land/Configuring/Start/


------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({ output = "",         mode = "preferred",       position = "auto", scale = 2 })
hl.monitor({ output = "HDMI-A-2", mode = "3440x1440@50",    position = "0x0",  scale = 1.6 })
hl.monitor({ output = "DP-4",     mode = "3440x1440@50",    position = "0x0",  scale = 1.6 })


---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "kitty"
local fileManager = "dolphin"
local menu        = "rofi -show run"


-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("hyprsunset --temperature 5000")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")   -- Stores text data
    hl.exec_cmd("wl-paste --type image --watch cliphist store")  -- Stores only image data
end)

-- Push waybar's custom/windows module (workspace-windows.sh) to redraw immediately on
-- any change instead of waiting on its poll interval. Matches "signal": 8 in
-- ~/.config/waybar/modules.json -- SIGRTMIN+8 is what waybar listens for.
local function refreshWaybarWindows()
    hl.exec_cmd("pkill -RTMIN+8 waybar")
end
for _, ev in ipairs({ "window.active", "window.fullscreen", "workspace.active", "window.open", "window.close", "window.title" }) do
    hl.on(ev, refreshWaybarWindows)
end


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
hl.env("WLR_NO_HARDWARE_CURSORS", "1")


-----------------------
----- PERMISSIONS -----
-----------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Please note permission changes here require a Hyprland restart and are not
-- applied on-the-fly for security reasons.

-- hl.config({
--   ecosystem = {
--     enforce_permissions = true,
--   },
-- })

-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")


-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 5,

        border_size = 3,

        col = {
            active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(59595966)",
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing = false,

        layout = "master",
    },

    decoration = {
        dim_special  = 0.8,
        dim_inactive = true,
        dim_strength = 0.2,

        rounding       = 0,
        rounding_power = 2,

        -- Change transparency of focused and unfocused windows
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = false,
            range        = 4,
            render_power = 3,
            color        = "rgba(1a1a1aee)",
        },

        -- See https://wiki.hypr.land/Configuring/Basics/Variables/#blur
        blur = {
            enabled            = false,
            size               = 12,
            passes             = 4,
            new_optimizations  = true,
            xray               = false,

            vibrancy           = 0.8,
            vibrancy_darkness  = 0.5,
            brightness         = 1.1,
            contrast           = 0.9,
            noise              = 0.02,
            popups             = true,
        },
    },

    animations = {
        enabled = false,  -- "enabled = no, please :)" in the old config
    },
})

-- Default curves, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/#curves
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}   } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}   } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}      } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}   } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}    } })

-- Default animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 1,    bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 1,    bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 1,    bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 0.5,  bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 0.5,  bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 0.5,  bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 0.5,  bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 1,    bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 1,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 0.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 0.5,  bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 0.5,  bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = false, speed = 1.94, bezier = "almostLinear", style = "slide" })
hl.animation({ leaf = "workspacesIn",  enabled = false, speed = 1.21, bezier = "almostLinear", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = false, speed = 1.94, bezier = "almostLinear", style = "slide" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 1.5,  bezier = "quick" })

-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
hl.workspace_rule({ workspace = "1", persistent = true })
hl.workspace_rule({ workspace = "2", persistent = true })
hl.workspace_rule({ workspace = "3", persistent = true })
hl.workspace_rule({ workspace = "4", persistent = true })
hl.workspace_rule({ workspace = "5", persistent = true })
hl.workspace_rule({ workspace = "6", persistent = true })
hl.workspace_rule({ workspace = "7", persistent = true })
hl.workspace_rule({ workspace = "8", persistent = true })
hl.workspace_rule({ workspace = "9", persistent = true })

-- "Smart gaps" / "No gaps when only"
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })

hl.window_rule({
    name  = "no-gaps-wtv1",
    match = { float = false, workspace = "w[tv1]" },

    border_size = 0,
    rounding    = 0,
})

hl.window_rule({
    name  = "no-gaps-f1",
    match = { float = false, workspace = "f[1]" },

    border_size = 0,
    rounding    = 0,
})

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
    dwindle = {
        preserve_split = true, -- You probably want this
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
    master = {
        new_status = "slave",
    },
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#misc
hl.config({
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
    },
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#debug
hl.config({
    debug = {
        vfr = true, -- Do not turn off unless debugging
    },
})


---------------
---- INPUT ----
---------------

-- https://wiki.hypr.land/Configuring/Basics/Variables/#input
hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "altwin:swap_alt_win,caps:escape",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 1, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = false,
        },
    },

    cursor = {
        no_hardware_cursors = true,
    },
})

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})


---------------------
---- KEYBINDINGS ----
---------------------

-- See https://wiki.hypr.land/Configuring/Basics/Binds/
local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Dispatchers/ for more
hl.bind(mainMod .. " + return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + return", hl.dsp.exec_cmd(terminal, { float = true, size = { 800, 500 } }))
hl.bind(mainMod .. " + backspace", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + delete", hl.dsp.exec_cmd("systemctl poweroff"))
hl.bind(mainMod .. " + SHIFT + CTRL + delete", hl.dsp.exec_cmd("systemctl reboot"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + F", hl.dsp.window.float())
hl.bind(mainMod .. " + M", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mainMod .. " + space", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo()) -- dwindle
hl.bind(mainMod .. " + backslash", hl.dsp.layout("swapwithmaster"))
hl.bind(mainMod .. " + bracketright", hl.dsp.layout("addmaster"))
hl.bind(mainMod .. " + bracketleft", hl.dsp.layout("removemaster"))
-- Cycle master orientation and push the new state to waybar's custom/orientation
-- module (signal 9) -- see ~/.config/waybar/scripts/orientation-cycle.sh for why
-- this needs a script rather than a plain layoutmsg dispatch.
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("~/.config/waybar/scripts/orientation-cycle.sh"))

-- Clipboard manager
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("cliphist list | rofi -dmenu -display-columns 2 | cliphist decode | wl-copy"))

-- Quick menus
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("rofi-bluetooth"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("networkmanager_dmenu"))

-- App shortcuts
hl.bind(mainMod .. " + F1", hl.dsp.exec_cmd("firefox"))
hl.bind(mainMod .. " + F3", hl.dsp.exec_cmd("code"))
hl.bind(mainMod .. " + F4", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + F5", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + F6", hl.dsp.exec_cmd("OBSIDIAN_USE_WAYLAND=1 obsidian -enable-features=UseOzonePlatform -ozone-platform=wayland"))
hl.bind(mainMod .. " + F7", hl.dsp.exec_cmd("google-chrome-stable"))
hl.bind(mainMod .. " + F9", hl.dsp.exec_cmd("firefox --new-window music.youtube.com"))

-- Move focus with mainMod + arrow keys (left/right shift workspace, up/down move focus -- kept
-- exactly as the original .conf had it, even though it's an odd/inconsistent mapping)
hl.bind(mainMod .. " + left",  hl.dsp.focus({ workspace = "-1" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ workspace = "+1" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "d" }))

-- Move focus with mainMod + hjkl
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "d" }))

-- Move window with mainMod + ctrl + hjkl
hl.bind(mainMod .. " + CTRL + h", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + CTRL + l", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + CTRL + k", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + CTRL + j", hl.dsp.window.move({ direction = "d" }))

-- Expand window with mainMod + shift + hjkl
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.resize({ x = -50, y = 0,  relative = true }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.resize({ x = 50,  y = 0,  relative = true }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.resize({ x = 0,   y = -50, relative = true }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.resize({ x = 0,   y = 50,  relative = true }))

-- Cycle windows, staying maximized if the active window is maximized.
-- NOTE: as of Hyprland 0.55's lua config, `hyprctl dispatch <name> <args>` no longer
-- accepts the old bare dispatcher-name syntax -- it's parsed as a lua expression, so
-- the dispatch call itself must be a lua expression like hl.dsp.window.cycle_next(...).
--
-- Order matters here to avoid a visible unmaximize-then-remaximize flicker: instead of
-- un-maximizing the old window before cycling, we cycle focus first, explicitly SET the
-- new window maximized (its maximize-in animation covers the old window), and only then
-- explicitly UNSET the old window's maximized flag once it's already hidden underneath.
hl.bind(mainMod .. " + tab", hl.dsp.exec_cmd([[bash -c '
old=$(hyprctl activewindow -j | jq -r .address)
fs=$(hyprctl activewindow -j | jq .fullscreen)
hyprctl dispatch "hl.dsp.window.cycle_next({next=true})"
if [ "$fs" != "0" ]; then
  hyprctl dispatch "hl.dsp.window.fullscreen({mode=\"maximized\", action=\"set\"})"
  hyprctl dispatch "hl.dsp.window.fullscreen({mode=\"maximized\", action=\"unset\", window=\"address:$old\"})"
fi']]))
hl.bind(mainMod .. " + SHIFT + tab", hl.dsp.exec_cmd([[bash -c '
old=$(hyprctl activewindow -j | jq -r .address)
fs=$(hyprctl activewindow -j | jq .fullscreen)
hyprctl dispatch "hl.dsp.window.cycle_next({next=false})"
if [ "$fs" != "0" ]; then
  hyprctl dispatch "hl.dsp.window.fullscreen({mode=\"maximized\", action=\"set\"})"
  hyprctl dispatch "hl.dsp.window.fullscreen({mode=\"maximized\", action=\"unset\", window=\"address:$old\"})"
fi']]))

-- Switch workspaces with F1-F9
-- Move active window to a workspace with SHIFT + F1-F9
for i = 1, 9 do
    hl.bind("F" .. i, hl.dsp.focus({ workspace = i }))
    hl.bind("SHIFT + F" .. i, hl.dsp.window.move({ workspace = i, follow = false }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + grave", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + grave", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),       { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),      { locked = true, repeating = true })
hl.bind(mainMod .. " + equal",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),  { locked = true, repeating = true })
hl.bind(mainMod .. " + minus",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),       { locked = true, repeating = true })
hl.bind(mainMod .. " + 0",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),      { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",       hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",    hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                { locked = true, repeating = true })

-- Lock screen
hl.bind(mainMod .. " + SHIFT + space", hl.dsp.exec_cmd("hyprlock"))

-- Screenshots (hyprshot)
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("hyprshot -m window"))
hl.bind(mainMod .. " + SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m region"))

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
hl.bind(mainMod .. " + comma",  hl.dsp.exec_cmd("playerctl previous"))
hl.bind(mainMod .. " + period", hl.dsp.exec_cmd("playerctl next"))
hl.bind(mainMod .. " + slash",  hl.dsp.exec_cmd("playerctl play-pause"))

-- Sidebar
hl.bind(mainMod .. " + s", hl.dsp.exec_cmd("swaync-client -t -sw"))

-- Toggle inactive dim (e.g. for presentations)
-- NOTE: `hyprctl keyword` is legacy-only and errors under the lua parser ("Use eval.");
-- live config changes now go through `hyprctl eval 'hl.config({...})'` instead. Also
-- getoption's JSON now reports booleans as .bool, not .int.
hl.bind(mainMod .. " + d", hl.dsp.exec_cmd([[bash -c 'cur=$(hyprctl getoption decoration:dim_inactive -j | jq .bool); [ "$cur" = "true" ] && hyprctl eval "hl.config({decoration={dim_inactive=false}})" || hyprctl eval "hl.config({decoration={dim_inactive=true}})"']]))

-- Toggle animations on/off entirely
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd([[bash -c 'cur=$(hyprctl getoption animations:enabled -j | jq .bool); [ "$cur" = "true" ] && hyprctl eval "hl.config({animations={enabled=false}})" || hyprctl eval "hl.config({animations={enabled=true}})"']]))


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/ for more
-- See https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/ for workspace rules

hl.window_rule({
    name  = "firefox-opacity",
    match = { class = "firefox" },

    opacity = "1 override 1 override",
})

hl.window_rule({
    name  = "obsidian-opacity",
    match = { class = "obsidian" },

    opacity = "1 override 1 override",
})

hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})
