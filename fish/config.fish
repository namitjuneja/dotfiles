export PATH="$HOME/.local/bin:$PATH"
set fish_greeting ""

# jupyter lab
alias jl="jupyter-lab"

# ls: long, oldest first (newest at bottom), human sizes
alias ll="ls -ltrh --color=auto"

# history grep: list all matching past commands (Ctrl+R = interactive, one at a time)
alias hg="history search"

# --- git ---

# status, then commit all tracked changes: gc "msg"
function gc
    git status
    git commit -am "$argv[1]"
end

# clear screen, then git diff
function gd
    clear
    git diff $argv
end

# pretty one-line log
alias gl="git log --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

alias gs="git status"

# last commit with changed files
alias glast="git log -1 HEAD --stat"

# pull upstream master with rebase
alias gpumr="git pull upstream master --rebase"

# push current branch to origin
function gpo
    git push origin (git symbolic-ref --short HEAD)
end

# amend last commit, keep message
alias gcane="git commit --amend --no-edit"

# recent branches by commit date
alias grecent="git for-each-ref --sort=-committerdate refs/heads/ --format='%(committerdate:short) %(authorname) %(refname:short)'"

# --- misc ---

# Cisco AnyConnect UI (URL: vpn.buffalo.edu/UBVPN)
alias vpn="/opt/cisco/anyconnect/bin/vpnui"

# ssh to CCR server
alias ccr="ssh namitjun@vortex.ccr.buffalo.edu"
