alias vup="amixer set 'Master' 10%+"
alias vdown="amixer set 'Master' 10%-"
alias bat="upower -i /org/freedesktop/UPower/devices/battery_BAT0"

# I don't really know what they do but they help in setting up the virtualenv for non free version of opencv
# https://www.pyimagesearch.com/2015/06/22/install-opencv-3-0-and-python-2-7-on-ubuntu/
export WORKON_HOME=$HOME/.virtualenvs
source /usr/local/bin/virtualenvwrapper.sh
