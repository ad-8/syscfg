#!/usr/bin/env sh

backlight 40 &

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


# info terminals, sleep makes the correct tiling order more likely
alacritty -T ax-log -e tail -F /var/log/messages &
sleep 0.5
alacritty -T ax-top -e top &
sleep 0.5
alacritty -T ax-btop -e btop &


# feh --bg-scale --randomize ~/sync/wallpapers/wallpapers-ax-fav &
emacs --daemon &
sleep 1
firefox &
sleep 0.5
emacsclient --create-frame ~/org/todo.org
sxhkd -t 3 &
syncthing --no-browser &

