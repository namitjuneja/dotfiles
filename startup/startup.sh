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

# redshift for eye health
#redshift -O 3500
# Little less brightness for the big monitor
redshift -m randr:crtc=1 -b 0.6 -O 3500
# Normal brightness for the laptop screen
redshift -m randr:crtc=0 -b 1 -O 3500

# eye blink reminder
safeeyes &

# make caps lock into escape and xcape control
# I coldnt figure out how to this using xmodmap
setxkbmap -option ctrl:nocaps
xcape -e "Control_L=Escape"

# reload xmodmap to set mod3 to Hyper_L
# I think hyper_l is not mapped to any key 
# and hence can be used
xmodmap /home/namit/dotfiles/xmodmap/.Xmodmap

spare_modifier="Hyper_L"

xmodmap -e "keycode 65 = $spare_modifier"
xmodmap -e "add mod3 = $spare_modifier"
xmodmap -e "keycode any = space"
xcape -e "$spare_modifier=space"
