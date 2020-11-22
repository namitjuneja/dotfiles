export PATH="$PATH:/home/namit/dotfiles/scripts"
#fortune | cowsay -y | lolcat


alias jl="jupyter lab"
alias meads="cd /home/namit/codes/meads/morphology-similarity/; source venv/bin/activate"
alias sf="cd /home/namit/sf/sfox-web"
alias qtb="~/qutebrowser/.venv/bin/python3 -m ~/qutebrowser/.venv/bin/qutebrowser"
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

parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export PS1="\u@\h \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "
