
# Dotfiles
Each component is listed below along with what that component is, what is it used for and how it is used.

---
### .xprofile

**what**: This file gets executed at the beginning of the X session)

**how**: Softlinked `ln -s ~/dotfiles/xprofile/.xprofile ~/.xprofile`

**why**:
- to make touchpad tap work in bspwm
- to increase pointer acceleration to max
---
### .bashrc
**what**: This file gets executed at the starting of an *interactive* bash session.

**how**: Sourced from within the default .bashrc file `source ~/dotfiles/bashrc/.bashrc`

**why**:
- aliases
- appending directories to $PATH environment variable
---

### startup.sh 

**what**: This script runs everytime the user log in

**how**: Softlinked `ln -s ~/dotfiles/startup/startup.sh /etc/profile.d/startup.sh`

**why**:
- ~~set background using feh~~ awesomewm theme does this now
- start compton
- start redshift
- start safeeyes
- keyboard modifications
  - ~~start ksuperkey to use modkey(independantly) to get system notification~~ not using this anymore
  - ~~space mods~~ disabled for now. interferes with touch typing
  - replace windows key with the alt key
  - replace caps lock key with escape key and control key (xcape)
  - removing alt+shift shortcut used by default to change the keyboard layout. I cannot recall why I have disabled it.
- start wifi indicator in system tray (nm-applet)
- start clipster (clipboard manager)
- replace windows key with the alt key
- set dark theme on nautilus and any other gtk app

*Note: Might require chmod +x* 

---
### rc.local 

**what**: similar to startup.sh (runs upon logging in) but has root priviledges

**how**: Softlinked `sudo ln -s ~/dotfiles/startup/rc.local /etc/rc.local`

**why**:
- turn on thinkpad backlight on startup

*Note: Might require chmod +x* 

---

### compton.conf

**what**: Compositor

**how**: Softlinked `ln -s ~/dotfiles/compton/compton.conf .config/compton.conf`

**why**: 
- ~~to din inactive windows~~ diabled. causes problems while presenting
---

### crontab -e

**what**: run any periodic scheduled task

**how**: copy commands from README into crontab config accessed from `crontab -e`

**why**:
- play sound every hour
  `0 * * * * paplay /usr/share/sounds/ubuntu/stereo/service-login.ogg`
---
### sudo crontab -e

**what**: run any periodic scheduled task with root access

**how**: copy commands from README into crontab config accessed from `sudo crontab -e`

**why**: 
- ~~modify /etc/hosts/~~
  ~~remove "#" (comment) from any line that contains 127.0.0.1 (local DNS)~~
  ~~`awk '{if ($0 ~ /127.0.1.1/) gsub("#", "", $0); print > "/etc/hosts";}' /etc/hosts`~~
  discontinued. moved this to an alias to be triggered on demand.
---
### .vimrc

**what**: vim config

**how**: Softlinked `ln -s ~/dotfiles/vim/.vimrc ./.vimrc` 

**why**: 
- set number lines
- enable vim clipboard syncing with ubuntu clipboard
- many other vim editor configs (see config file for comments)
---
### Other modifications

- changed key press delay to improve vim usability using the below commands
  ```
  gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 1
  gsettings set org.gnome.desktop.peripherals.keyboard delay 1
  ```
   should be ideally
  ```
  gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 30
  gsettings set org.gnome.desktop.peripherals.keyboard delay 250
  ```
- Removed all options in setxkbmap to be able to use `alt + shift ` shortcut in sublime for splitting view

  It can be restored using the following command
  `setxkbmap -option "grp:alt_shift_toggle,grp_led:scroll"`
  
  For a list of other options run man `xkeyboard-config`
  It can be restored using the following command `setxkbmap -option "grp:alt_shift_toggle,grp_led:scroll"`
  For a list of other options run man `xkeyboard-config`
- added `kernel.sysrq=0` to `/etc/sysctl.conf`.

  This disables system_req commands initated using ALT+Print+<key> command. The system_req key combinations are used to issue direct commands to the linux kernel. It was interfering with Alt+Shift+Print shortcut for Clipping from the screen.
- create a profile named 'float' in gnome-terminal with zero transparency to be used as floating terminal.
- `gsettings set org.gnome.nautilus.preferences recursive-search
  'never'` - disables recursive search in gnome
- `sudo apt-get install yaru-theme-gtk`
  install dark theme for the environment variable in startup.sh to work
- uncomment or add `HandleLidSwitch=ignore` in
  `/etc/systemd/logind.conf` to make sure nothing happens when the lid
is closed
- wallpapers set by awesome are based on a function that reads the
  screens resolution and picks a random file from
`$HOME/Pictures/wallpapers/<screen_resolution>`
---

### Firefox modifications

misc/userChrome.css
- remove tabs bar in firefox

misc/userContent.css
- make background of new window page black
- make the splitter betwen page and sidebar black
- remove dropdown menu from the top of the sidebar

about:config changes
- pixel scaling for better readability on high res screens `layout.css.devPixelsPerPx=1.2`
- remove popup for notification permissions  (in settings)
- remove fullscreen warning notification `full-screen-api.warning.timeout=0`
- enable ctrl-q quit firefox warning - to prevent accidental presses `browser.sessionstore.warnOnQuit=true,browser.warnOnQuit=true`
- prevent cookies from being used by anyone except the domain that set it `privacy.firstparty.isolate=true` 
- enable ESNI and DoH from Cloudflare to prevent tracking
- Resist fingerprinting ~~`privacy.resistfingerprinting = true`~~ disabled. it started randomizing the timezone.
---

### REQUIREMENTS
- i3lock
- pqiv
- rofi
- clipster
- scrot
- mpv
- blueman
---
### NOTES

-
  - When setting up a new machine create a Screenshots folder in the Pictures folder for scrot keybinding to work. `mkdir ~/Pictures/Screenshots`
  - Pin the folder for ease
  - `mkdir ~/Pictures/wallpapers/3440x1440` replace the folder name with
    the screen's resolution. All randomized wallpapers will be picked
    from this folder
  - Install `vim-gtk3` for it to work with ubuntu clipbaord register
 ---
### TODO:

Write about :
- xmodmap config
- firefox extension config
- clipster and roficlip

Include gnome-terminal config to dotfiles
