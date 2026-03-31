#!/usr/bin/env sh

info=$(upower --battery)

percentage=$(echo "$info" | grep percentage | awk '{print $2}')
time=$(echo "$info" | grep -i 'time to empty' | awk '{gsub(/hours?/, "h"); print $4$5}')
rate=$(echo "$info" | grep 'energy-rate' | awk '{printf "%.1f %s\n", $2, $3}')

echo "$percentage $time $rate"

