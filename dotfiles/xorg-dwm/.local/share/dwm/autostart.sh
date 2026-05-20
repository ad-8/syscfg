#!/usr/bin/env sh

xbacklight -set 40 &

xset b off
# xset s off
# xset -dpms
# xset s 5400 0
# xset dpms 0 0 5400

# set delay before autorepeat starts and repeat rate
xset r rate 200 35

setxkbmap de -option caps:escape

# autostart programs
# ----------------------------------------------------------
dunst &
dwmblocks &
emacs ~/org/todo.org &
sleep 0.5
feh --bg-max ~/sync/openbsd-art/openbsd-7.9-PinkPuffy.png
sleep 0.5
firefox &
sleep 0.5
st -T ax-top -e ~/x/openbsd/tmux-monitor.sh &
sxhkd -t 3 &
sleep 0.5
syncthing --no-browser &
xautolock -time 30 -locker slock &
# ----------------------------------------------------------

