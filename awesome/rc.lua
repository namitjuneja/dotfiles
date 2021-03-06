-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")


-- Widget and layout library
local wibox = require("wibox")

-- Add Lain layout
local lain = require("lain")


-- Theme handling library
local beautiful = require("beautiful")


-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget


-- Volume control widget
local volume_control = require("volume-control")
volumecfg = volume_control({device="pulse"})

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- Load Debian menu entries
local debian = require("debian.menu")
local has_fdo, freedesktop = pcall(require, "freedesktop")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(awful.util.getdir("config") .. "themes/default_modified/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "x-terminal-emulator"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"


-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    lain.layout.centerwork,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
    awful.layout.suit.floating,
    lain.layout.termfair.center,
}
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() return false, hotkeys_popup.show_help end},
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end}
}

local menu_awesome = { "awesome", myawesomemenu, beautiful.awesome_icon }
local menu_terminal = { "open terminal", terminal }

if has_fdo then
    mymainmenu = freedesktop.menu.build({
        before = { menu_awesome },
        after =  { menu_terminal }
    })
else
    mymainmenu = awful.menu({
        items = {
                  menu_awesome,
                  { "Debian", debian.menu.Debian_menu.Debian },
                  menu_terminal,
                }
    })
end


mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() and c.first_tag then
                                                      c.first_tag:view_only()
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, client_menu_toggle_fn()),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))
function getScreenFromIndex(index)
 for s in screen do
    if s.index == index then
	return s	
    end
 end
 naughty.notify({title="No Screen Found"})
end



local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end



-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table and layout.
    local layouts = {lain.layout.termfair.center,
                     lain.layout.termfair.center,
                     lain.layout.termfair.center,
                     lain.layout.termfair.center,
                     lain.layout.termfair.center,
                     lain.layout.termfair.center,
                     lain.layout.termfair.center,
                     lain.layout.termfair.center,
                     lain.layout.termfair.center,
                     lain.layout.termfair.center}

    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, layouts)

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "bottom", screen = s, height = 30})

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            --mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
	    require("battery-widget") {battery_prefix = "🔋", ac_prefix = "🔌", alert_threshold = 10, percent_colors = {{999, "white" }}},
            wibox.widget.systray(),
            mytextclock,
	    volumecfg.widget,
            s.mylayoutbox,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", function() goToLastTag() end,
              {description = "go back", group = "tag"}),  -- custom history function
    awful.key({ modkey,           }, "`", function() goToLastTag() end,
              {description = "go back", group = "tag"}),  -- custom history function
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),
    awful.key({ modkey,"Shift" }, "Delete", function () awful.spawn("shutdown now") end,
              {description = "shutdown computer", group = "awesome"}),
    awful.key({ modkey,"Control",   "Shift" }, "Delete", function () awful.spawn("shutdown -r now") end,
              {description = "restart computer", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey,           }, "z", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey,           }, "c", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
        
    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey,  "Shift"  }, "Return", function () awful.spawn("gnome-terminal --window-with-profile=float", {floating=true, placement=awful.placement.centered}) end,
              {description = "open a floating terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "r",     function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "r",     function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "Right", function () awful.tag.incmwfact( 0.01)          end,
              {description = "Increase width", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "Left",  function () awful.tag.incmwfact(-0.01)          end,
              {description = "Decrease width", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "Down",  function () awful.client.incwfact( 0.01)        end,
              {description = "Increase height", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "Up",    function () awful.client.incwfact(-0.01)        end,
              {description = "Decrease height", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ "Mod4" }, "space", function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "'",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}), 

    -- Volume Control
    awful.key({modkey}, "equal", function() volumecfg:up() end),
    awful.key({modkey}, "minus", function() volumecfg:down() end),
    awful.key({modkey}, "0",     function() volumecfg:toggle() end),

    -- Switch audio card profiles
    -- (Headphones/speakers)
    awful.key({ modkey,}, "/", function () awful.spawn.with_shell("/home/namit/dotfiles/scripts/switch_pulseaudio_profile") end,
              {description = "toggle headph/spk", group = "volume"}),

    -- Program Shortcuts
    awful.key({ modkey,           }, "F1", function () awful.spawn("firefox") end,
              {description = "Firefox", group = "launcher"}),
    awful.key({ modkey,           }, "F3", function () awful.spawn("subl") end,
              {description = "Sublime Text", group = "launcher"}),
    awful.key({ modkey,           }, "F5", function () awful.spawn("nautilus") end,
              {description = "File Browser", group = "launcher"}),
    awful.key({ modkey,           }, "F6", function () awful.spawn("slack") end,
              {description = "Slack", group = "launcher"}),
    awful.key({ modkey,           }, "F7", function () awful.spawn("google-chrome") end,
              {description = "Google Chrome", group = "launcher"}),
    awful.key({ modkey,           }, "F9", function () awful.spawn("firefox --new-window \"music.youtube.com\"") end,
              {description = "Youtube Music", group = "launcher"}),

    -- clipboard manager roficlip launcher
    awful.key({ modkey,}, "b", function () awful.spawn("/home/namit/dotfiles/scripts/roficlip") end,
              {description = "Clipboard Manager", group = "launcher"}),
   
    -- screenshot 
    -- need to use util.spawn_will_shell because using arguments and bash functions for date 
    awful.key({modkey,}, "Print", function () awful.util.spawn_with_shell("scrot ~/Pictures/Screenshots/Screenshot\\ on\\ %Y-%m-%d\\ at\\ %r.jpg") end,
              {description = "Screenshot", group = "launcher"}),

    -- screen clipper
    awful.key({modkey, "Shift"   }, "Print", function () awful.util.spawn_with_shell("sleep 0.5 && scrot -s ~/Pictures/Screenshots/Screenshot\\ on\\ %Y-%m-%d\\ at\\ %r.jpg") end,
              {description = "Screen Clipper", group = "launcher"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey,           }, "BackSpace",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ "Mod4", "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "x",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"}),
    awful.key({ modkey,           }, "a",
        function (c)
	    local active_tag = awful.screen.focused().selected_tag
	    local clients = active_tag:clients()
	    for _, c in ipairs(clients) do
		c.maximized = false
  		c.maximized_horizontal = false
  		c.maximized_vertical = false
		c.floating = false
		c.ontop = false
	    end
        end ,
        {description = "un-maximize (total/vertical/horizontal), un-float all windows, un-ontop all windows", group = "client"})

 
)


-- tag to screen mapping
primary_screen_index = screen.primary.index

-- handle the cse when there is only one screen
if screen.count() == 2 then
	secondary_screen_index = primary_screen_index+1
else
	secondary_screen_index = primary_screen_index
end

-- defining what tags belong to what screen
-- personal workflow choice
tag_to_screen = {[1]=secondary_screen_index,
		 [2]=secondary_screen_index,
		 [3]=secondary_screen_index,
		 [4]=secondary_screen_index,
		 [7]=secondary_screen_index,
		 [8]=primary_screen_index,
		 [5]=secondary_screen_index,
		 [6]=secondary_screen_index,
		 [9]=secondary_screen_index}



--[[
I wanted to go to the last tag irrespective of the screen that it belonged to
awful.tag.history.restore only restore's the last tag on the current screen
updating the history was also not an option since it contained a seaprate queue for
each screen.
So I wrote my own function that restores to the last screen and last tag which is 
stored in the last_screen and last_tag global varible. 
This function is invoked by the mod + esc combination mentioned somewhere up. 
--]]
function goToLastTag()
	-- Store the current screen and tag in a temp variable
	local temp_last_screen = awful.screen.focused()
	local temp_last_tag = temp_last_screen.selected_tag.index

	-- Restore the last screen and tag 
	local sc = getScreenFromIndex(last_screen.index)
	local tg = sc.tags[last_tag]:view_only()
	-- you need to focus the screen as well along with call tag view_only function
	awful.screen.focus (sc) 

	-- after channging to the last screen-tag set last screen-tag to the current screen-tag
	last_screen = temp_last_screen
	last_tag = temp_last_tag
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
	-- View a particular tag
	-- keycode #67 is F1 hence i+66
        awful.key({        }, "#" .. i + 66,
                  function ()
			-- store the current screen-tag to be later
			-- stored in last screen-tag
                        local temp_last_screen = awful.screen.focused()
			local temp_last_tag = temp_last_screen.selected_tag.index
			
			-- get screen corresponding to the tag and set to that screen-tag
                        local screen = getScreenFromIndex(tag_to_screen[i])
                        local tag = screen.tags[i]
			awful.screen.focus (tag_to_screen[i])
                        if tag then
                           tag:view_only()
                        end

			-- if the screen-tag is not the same as the current screen-tag 
			-- set the current screen-tag to last screen-tag
			-- this prevents infinite loop situation
			if not (temp_last_screen.index==tag_to_screen[i] and temp_last_tag==i) then
				last_screen = temp_last_screen
				last_tag = temp_last_tag
			end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
	-- view multiple tags together
        awful.key({ "Control" }, "#" .. i + 66,
                  function ()
                      --local screen = awful.screen.focused()
                      local screen = getScreenFromIndex(tag_to_screen[i])
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
	-- Move a window to another tag 
        awful.key({ "Shift" }, "#" .. i + 66,
                  function ()
                      if client.focus then
                          local current_screen = awful.screen.focused()
                          --local tag = client.focus.screen.tags[i]
                          local screen = getScreenFromIndex(tag_to_screen[i])
                          local tag = screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
			  awful.screen.focus(current_screen)
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({  "Control", "Shift" }, "#" .. i + 66,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
        },
        class = {
          "Arandr",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Wpa_gui",
          "pinentry",
          "veromix",
          "xtightvncviewer"},

        name = {
          "Event Tester",  -- xev.
	  "Print",
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = false }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --  properties = { fullscreen = true} },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)



-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then

        local temp_last_focussed_client = client.focus and client.focus.first_tag or nil
	if  temp_last_focussed_client ~= nil then
		temp_last_screen = temp_last_focussed_client.screen
	else
		temp_last_screen = awful.screen.focused()
	end
	local temp_last_tag = temp_last_screen.selected_tag.index
	local t = client.focus and client.focus.first_tag or nil

        client.focus = c

	-- Update last screen-tag variable 
	-- for the custom history function

	-- if the screen-tag is not the same as the current screen-tag 
	-- set the current screen-tag to last screen-tag
	-- this prevents infinite loop situation
	local focussed_screen = client.focus.screen

	if not (temp_last_screen.index==focussed_screen.index 
		and temp_last_tag==focussed_screen.selected_tag.index) then
		last_screen = temp_last_screen
		last_tag = temp_last_tag
	end

    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- restart awesome on screen connected/removed in order to 
-- get new custom screen distribution into effect
screen.connect_signal("removed", awesome.restart)
screen.connect_signal("added", awesome.restart)

-- restart pkill when a screen is added
-- pkill needs to be reconfigured for the new keyboard layout
screen.connect_signal("added", function() awful.shell("pkill xcape; /home/namit/dotfiles/startup/startup.sh") end)

awful.screen.connect_for_each_screen(function(s)
	s.app_switcher = awful.popup {
	      	       widget = awful.widget.tasklist {
	      	           screen   = s, 
	      	           filter   = awful.widget.tasklist.filter.currenttags,
	      	           buttons  = tasklist_buttons,
	      	           style    = {
	      	               shape = gears.shape.rectangle,
	      	           },
	      	           layout   = {
	      	               spacing = 10,
	      	               layout = wibox.layout.grid.horizontal
	      	           },
	      	           widget_template = {
	      	               {
	      	                   {
	      	                       id     = 'clienticon',
	      	                       widget = awful.widget.clienticon,
	      	                   },
	      	                   margins = 4,
	      	                   widget  = wibox.container.margin,
	      	               },
	      	               id              = 'background_role',
	      	               forced_width    = 48,
	      	               forced_height   = 48,
	      	               widget          = wibox.container.background,
	      	               create_callback = function(self, c, index, objects) --luacheck: no unused
	      	                   self:get_children_by_id('clienticon')[1].client = c
	      	               end,
	      	           },
	      	       },
	      	       border_color = '#777777',
	      	       border_width = 2,
	      	       ontop        = true,
	      	       visible      = false,
		       screen 	    = s,
	      	       placement    = awful.placement.centered,
	      	       shape        = gears.shape.rounded_rect
		}
end)


tag.connect_signal("request::screen", function(t)
    for s in screen do
        if s ~= t.screen and
           s.geometry.x == t.screen.geometry.x and
           s.geometry.y == t.screen.geometry.y and
           s.geometry.width == t.screen.geometry.width and
           s.geometry.height == t.screen.geometry.height then
            local t2 = awful.tag.find_by_name(s, t.name)
            if t2 then
                t:swap(t2)
            else
                t.screen = s
            end
            return
        end
    end
end)




awful.keygrabber {
    auto_start     = true,
    start_callback     = function() awful.screen.focused().app_switcher.visible = true; end,
    stop_callback      = function() awful.screen.focused().app_switcher.visible = false; end,
    keybindings = {
        { { modkey         }, "Tab", function() awful.client.focus.byidx( 1) end, 
		{description = "focus previous client in history", group = "client"}},

	    { { modkey, 'Shift'}, 'Tab', function() awful.client.focus.byidx(-1) end ,
		{description = "focus next client in history", group = "client"}},
    },
    stop_key           = modkey,
    stop_event         = 'release',
    export_keybindings = true,
}
