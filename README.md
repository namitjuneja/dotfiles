.xprofile
- to make touchpad tap work in bspwm
- to increase pointer acceleration to max

baspwmrc and sxhkdrc
- to setup bspwm 

.bashrc
- mostly aliases
- <location>/.bashrc to original bashrc

startup.sh (currently run by keeping a soft link in /etc/profile.d directory which means it runs everytime a user logs in)
- set background using feh 
- start compton
- start ksuperkey to use modkey(independantly) to get system notification

compton.conf (soft linked to .config/compton.conf)
- to din inactive windows




REQUIREMENTS
-ksuperkey
-i3lock-fancy
	-i3lock
	-scrot

NOTES
Removed all options in setxkbmap to be able to use alt + shift shortcut (for bspwm & sublime)
It can be restored using the following command
setxkbmap -option "grp:alt_shift_toggle,grp_led:scroll"
For a list of other options run man xkeyboard-config
