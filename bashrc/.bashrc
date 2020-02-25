export PATH="$PATH:/home/namit/dotfiles/scripts"
#fortune | cowsay -y | lolcat


alias jp="jupyter notebook"
alias qtb="~/qutebrowser/.venv/bin/python3 -m ~/qutebrowser/.venv/bin/qutebrowser"
# folloew this link for installing qutebrowser with tox
# https://www.qutebrowser.org/doc/install.html#tox

# monitor setup
alias lab_mon="xrandr --output eDP-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output DP-1 --off --output HDMI-1 --mode 1920x1080 --pos 1921x0 --rotate normal --output DP-2 --off --output HDMI-2 --off"


# uncomment all etc/hosts entries
function reset_etchosts 
{
	sudo awk '{if ($0 ~ /127.0.1.1/) gsub("#", "", $0); print > "/etc/hosts";}' /etc/hosts;
}

alias rr="reset_etchosts"


#ls is ls -ltrh
alias ll="ls -ltrh --color=auto"

# better image viewer
alias pq='pqiv -z 1.4  --browse --sort --bind-key="q { goto_file_relative(-1); }" --bind-key="w { goto_file_relative(1); }"'

# cd Entropy Isomap folder faster
alias ent="cd /home/namit/codes/Entropy-Isomap/"

# find size of files without recursion
alias size="du -sh"
