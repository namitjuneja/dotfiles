# Set wallpaper
# now handled by awesome theme lua script
#feh --bg-scale ~/Pictures/Wallpapers/vim.png

# start compton
compton &

# ksuperkey to use modkey for pc info
#ksuperkey

# remove alt+shift to toggle keyboard layout
# set it to shift+caps in order to prevent it to be default (win+space) - I use that for rofi launcher
# first clear all options, then add new options
#setxkbmap -option 
#setxkbmap -option "grp:shift_caps_toggle,grp_led:scroll"

# kill existing redshift first
redshift -x
# redshift for eye health
#redshift -O 3500
# Little less brightness for the big monitor
redshift -m randr:crtc=1 -b 1 -O 3700
# Normal brightness for the laptop screen
redshift -m randr:crtc=0 -b 1 -O 3500

# eye blink reminder
safeeyes &

# kill existing xcape bindings before redoing them
pkill xcape

# replace alt key with the window key
# awesome's modkey is set to super key(Mod4) but the alt
# key is the windows key. This is donw for 2 reasons
# 1. Use alt key since there are 2 of them
# 2. Do not forgo the alt key shortcuts that exist
# this should always be called before xcape command
setxkbmap -option 'altwin:swap_alt_win'


# caps lock = ctrl right
# control right = control right + escape on independant release(xcape)
# control left = remains same
# made this change in order to avoid accidental escapes when pressing control left
setxkbmap -option ctrl:nocaps
xmodmap -e "keycode  66 = Control_R NoSymbol Control_R"
xcape -e "Control_R=Escape" -t 1000

# reload xmodmap to set mod3 to Hyper_L
# I think hyper_l is not mapped to any key 
# and hence can be used
# xmodmap /home/namit/dotfiles/xmodmap/.Xmodmap

# spare_modifier="Hyper_L"

# xmodmap -e "keycode 65 = $spare_modifier"
# xmodmap -e "add mod3 = $spare_modifier"
# xmodmap -e "keycode any = space"
# xcape -e "$spare_modifier=space" -t 1000

# adjust timezone to another country
# restart for change to take effect
#TZ='Asia/Kolkata'; export TZ

# wifi indicator in the sys tray
nm-applet &


# clipboard manager - clipster
/home/namit/dotfiles/scripts/clipster -d &                                        

# set dark theme for nautilus and potentially any other GTK app
export GTK_THEME=Yaru:light
