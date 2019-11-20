.xprofile
(This file gets executed at the beginning of the X session)
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
- start redshift
- space mods code

compton.conf (soft linked to .config/compton.conf)
- to din inactive windows

crontab -e
- play sound every hour
  paplay /usr/share/sounds/ubuntu/stereo/service-login.ogg


sudo crontab -e
- ~~modify /etc/hosts/~~
  ~~remove "#" (comment) from any line that contains 127.0.0.1 (local DNS)~~
  ~~`awk '{if ($0 ~ /127.0.1.1/) gsub("#", "", $0); print > "/etc/hosts";}' /etc/hosts`~~
  moved this to an alias in bashrc

Note
changed key press delay to improve vim usability using the below commands

gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 1

gsettings set org.gnome.desktop.peripherals.keyboard delay 1

should be ideally

gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 30

gsettings set org.gnome.desktop.peripherals.keyboard delay 250


Firefox modifications
userChrome.css
- used to modify UI of Firefox (use this with vivaldi firefox addon)
- used for xml hack to inect JS which operates when new tab opens to open a custom page, keep the focus to the adress bar and clear any url which is there
- enable ESNI and DoH from Cloudflare to prevent tracking

userChrome.xml
userChrome.js

userContent.css
- used to make background of new window page black

List of about:config changes
- devpixels scaling to 1.2
- remove popup for notification permissions
- remove fullscreen warning notification
- enable ctrl q quit firefox warning - to prevent accidental presses
- privacy.firstparty.isolate;true (cookies cannot be used by anyone except the domain that set it)
- fullscreen enter and leave duration
  full-screen-api.transition-duration.enter;300
  full-screen-api.transition-duration.leave;300
- Reomove full screen warning by reducing its timeout to 0
  full-screen-api.warning.timeout;0

Firefox TODO
- get similar behaviour in new window action
- figure out a way to include firefox profile in dotfiles, which includes about:config changes

REQUIREMENTS
-ksuperkey
-i3lock-fancy
	-i3lock
	-scrot

TODO
- invalidate Firefox's DNS cache so that /etc/hosts/ takes effect immediately





NOTES
Removed all options in setxkbmap to be able to use alt + shift shortcut (for bspwm & sublime)
It can be restored using the following command
setxkbmap -option "grp:alt_shift_toggle,grp_led:scroll"
For a list of other options run man xkeyboard-config
