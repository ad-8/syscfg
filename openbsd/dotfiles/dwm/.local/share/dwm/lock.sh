#!/usr/bin/bash

# why only visible after unlocking?
/usr/bin/notify-send "LOCKING NOW YO"

# xss-lock seems to disable dpms - needed when wanna turn off screen
#xset +dpms

sleep 2

i3lock -n --color 2e3440 &

sleep 3 && xset dpms force off
