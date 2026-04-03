#!/usr/bin/env sh

life=$(apm -l 2>/dev/null)
time=$(apm -m 2>/dev/null)
rate=$(sysctl -n hw.sensors.acpibat0.power0 2>/dev/null | sed 's/ (rate)//')


if [ "$time" = "unknown" ] 2>/dev/null; then
    time_str="AC"
else
    hours=$((time / 60))
    mins=$((time % 60))
    time_str="${hours}h${mins}m"
fi


printf "󰄌 %s%% %s %s\n" "$life" "$time_str" "$rate"

