export PATH="$PATH:/home/namit/.local/bin:/home/namit/dotfiles/scripts"

alias jl="jupyter-lab"

# monitor setup
alias home_mon="xrandr --output eDP-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output DP-1 --off --output HDMI-1 --off --output DP-2 --mode 1920x1080 --pos 1920x0 --rotate normal --output HDMI-2 --off"
alias laptop_mon="xrandr --output eDP-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output DP-1 --off --output HDMI-1 --off --output DP-2 --off --output HDMI-2 --off"
alias external_mon="xrandr --output eDP-1 --off --output DP-1 --off --output HDMI-1 --off --output DP-2 --mode 3440x1440     --pos 0x0 --rotate normal --output HDMI-2 --off"
alias lab_mon="xrandr --output eDP-1 --off --output DP-1 --off --output HDMI-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output DP-2 --off --output HDMI-2 --off"

#ls is ls -ltrh
alias ll="ls -ltrh --color=auto"

# better image viewer
alias pq='pqiv -z 0.3 --browse --sort --bind-key="q { goto_file_relative(-1); }" --bind-key="w { goto_file_relative(1); }" ./ &'

# project folders
alias ent="cd /home/namit/codes/Entropy-Isomap/"
alias meads="cd /home/namit/codes/meads/morphology-similarity/"
alias pha="cd /home/namit/codes/PhaFiCContainer/; conda activate phafic"

# add branch name to the prompt
force_color_prompt=yes
color_prompt=yes
parse_git_branch() {
 git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
if [ "$color_prompt" = yes ]; then
 PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]: \[\033[01;34m\]\w\[\033[01;31m\] $(parse_git_branch)\[\033[00m\] \$ '
else
 PS1='${debian_chroot:+($debian_chroot)}\u@\h: \w $(parse_git_branch) \$ '
fi
unset color_prompt force_color_prompt

# VPN connection
alias vpn="/opt/cisco/anyconnect/bin/vpnui"
# URL: vpn.buffalo.edu/UBVPN

# connect to the CCR server
alias ccr="ssh namitjun@vortex.ccr.buffalo.edu"
# scp -r namitjun@vortex.ccr.buffalo.edu:/projects/academic/olgawodo/NLDR/constDt-5replicas-noPer/* ./

# git patch
# save diff to a patch in patches foleder
function gp(){
    git diff > ~/patches/$1
}

# apply a patch from the patches folder
function gpa(){
   git apply ~/patches/$1
} 

# revert a patch from the patches folder
function gpr(){
    git apply -R ~/patches/$1
}

# view a patch from the patches folder
function gpv(){
    cat ~/patches/$1
}

# git commit 
function gc() {
    git status
    git commit -am "$1"
}

# git commit with watchman
function gcs() {
    gpr wtch
    git status
    gpa wtch
    git commit -am "$1"
}

# git diff
function gd() {
   clear 
   git diff $@
}

# git log
alias gl="git log  --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# git status
alias gs="git status"

# git last
alias glast="git log -1 HEAD --stat"

# git pull rebase
function gpumr(){
    git pull upstream master --rebase
}

# git push origin branch
alias gpo='git push origin "$(git symbolic-ref --short HEAD)"'

# git commit ammend no edit
alias gcane="git commit --amend --no-edit"

# view the most recent branches
alias grecent="git for-each-ref --sort=-committerdate refs/heads/
--format='%(committerdate:short) %(authorname) %(refname:short)'"

# play the youtube video from clipboard URL
function vlc0() {
    notify-send "Playing video:
    $(clipster -o -c)";
    echo "Playing video: $(clipster -o -c)";
    vlc --open "$(clipster -o -c)" -f;
}
# update vlc's youtube parser
# sudo rm youtube.luac; sudo wget https://raw.githubusercontent.com/videolan/vlc/master/share/lua/playlist/youtube.lua

alias mpp="echo \"Playing youtube video: $(clipster -o -c)\"; notify-send \"Playing youtube video: $(clipster -o -c)\"; mpv $(clipster -o -c)"

# erase clipboard
alias ec="clipster --erase-entire-board --clipboard"

# run keychron k2 windows keys
alias k2='/bin/bash -c "echo 0 > /sys/module/hid_apple/parameters/fnmode"'

# quick start work env
alias phafic="cd ~/codes/phafic; source venv/bin/activate"

# record screen
# install this using - sudo apt install recordmydesktop
alias record="recordmydesktop --on-the-fly-encoding"

# mini history tutorial so I dont forget
# search for past commands
# history | grep "<search query>"
# !<line_number>
# easier way is to use `hg` (history grep) alias
alias hg='history | grep -i'

# don't put duplicate lines or lines starting with space in the history.
# and erase any duplicates that exist
# See bash(1) for more options
HISTCONTROL=ignoreboth:earsedups

# ensure history commands are not blindly executed, but instead filled in on the command line so you can ensure they will do no evil before executing
shopt -s histverify

HISTFILESIZE=
HISTSIZE=
HISTTIMEFORMAT="[%F %T] "
# Force prompt to write history after every command.
# http://superuser.com/questions/20900/bash-history-loss
# -a to make sure appended not overwritten
# -n appended after every command and not just at the end of session
# helps if want to search through same command in another bash session
PROMPT_COMMAND="history -a; history -n; $PROMPT_COMMAND"


