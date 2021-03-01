export PATH="$PATH:/home/namit/dotfiles/scripts"
#fortune | cowsay -y | lolcat


alias jl="jupyter-lab"
alias meads="cd /home/namit/codes/meads/morphology-similarity/"
alias sf="cd /home/namit/sf/sfox-web"
alias qtb="~/qutebrowser/.venv/bin/python3 -m ~/qutebrowser/.venv/bin/qutebrowser"
alias rem="wine /home/namit/.wine/drive_c/Program\ Files/reMarkable/reMarkable.exe"
alias lstash="git stash push .watchmanconfig"
alias rstash="cp ~/.watchmanconfig /home/namit/sf/sfox-web/"
# folloew this link for installing qutebrowser with tox
# https://www.qutebrowser.org/doc/install.html#tox

# monitor setup
alias home_mon="xrandr --output eDP-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output DP-1 --off --output HDMI-1 --off --output DP-2 --mode 1920x1080 --pos 1920x0 --rotate normal --output HDMI-2 --off"
alias laptop_mon="xrandr --output eDP-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output DP-1 --off --output HDMI-1 --off --output DP-2 --off --output HDMI-2 --off"
alias external_mon="xrandr --output eDP-1 --off --output DP-1 --off --output HDMI-1 --off --output DP-2 --mode 3440x1440     --pos 0x0 --rotate normal --output HDMI-2 --off"


# uncomment all etc/hosts entries
function reset_etchosts 
{
	sudo awk '{if ($0 ~ /127.0.1.1/) gsub("#", "", $0); print > "/etc/hosts";}' /etc/hosts;
}

alias rr="reset_etchosts"


#ls is ls -ltrh
alias ll="ls -ltrh --color=auto"

# better image viewer
alias pq='pqiv -z 0.3 --browse --sort --bind-key="q { goto_file_relative(-1); }" --bind-key="w { goto_file_relative(1); }" ./ &'

# cd Entropy Isomap folder faster
alias ent="cd /home/namit/codes/Entropy-Isomap/"

# find size of files without recursion
alias size="du -sh"

# add branch name to the prompt
parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export PS1="\u@\h \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "

# quick start server
alias sss="sf; gpa wtch; rstash; yarn run start:staging"
alias ssq="sf; gpa wtch; rstash; yarn run start:qa02"

# ub server 
alias vpn="/opt/cisco/anyconnect/bin/vpnui"
# URL: vpn.buffalo.edu/UBVPN
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

# play the youtube video from clipboard URL
function mpp() {
    notify-send "Playing video:
    $(clipster -o -c)";
    echo "Playing video: $(clipster -o -c)";
    mpv "$(clipster -o -c)";
}
alias mp="echo \"Playing youtube video: $(clipster -o -c)\"; notify-send \"Playing youtube video: $(clipster -o -c)\"; mpv $(clipster -o -c)"
