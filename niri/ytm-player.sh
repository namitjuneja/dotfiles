#!/bin/sh
# Print the MPRIS name of the YouTube Music Firefox (the one running the ytm-firefox profile),
# so the media keys control only it. Prints a name that matches nothing when it isn't running.
pid=$(pgrep -of 'firefox --no-remote --profile .*ytm-firefox')
busctl --user list --no-legend 2>/dev/null \
  | awk -v p="$pid" -v pre="org.mpris.MediaPlayer2." '$2 == p && index($1, pre "firefox") == 1 { print substr($1, length(pre) + 1); f = 1 } END { if (!f) print "ytm-not-running" }' \
  | head -n1
