#!/usr/bin/env sh

xbacklight -set 40 &

dwmblocks &
dunst &

xset b off
# xset s off
# xset -dpms
# xset s 5400 0
# xset dpms 0 0 5400

# set delay before autorepeat starts and repeat rate
xset r rate 200 35

setxkbmap de -option caps:escape

xautolock -time 20 -locker slock &

sleep 0.5

st -T ax-top -e ~/x/openbsd/tmux-monitor.sh &


feh --bg-max ~/sync/openbsd-art/openbsd-7.8-Terraodontidae.png
emacs --daemon &
sleep 1
firefox &
sleep 0.5
emacs ~/org/todo.org &
sleep 0.5
sxhkd -t 3 &
syncthing --no-browser &

