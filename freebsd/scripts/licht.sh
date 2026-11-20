#!/bin/sh
# Usage: licht.sh [preset]
# Without args, opens rofi picker. With arg, applies the preset directly.
# FreeBSD port of scripts/bb/licht.clj: internal screen + gammastep only.

presets='max Max 100 6500
hi High 80 6000
hi+ High+ 90 6500
hi2 High2 67 5500
hi3 High3 59 4900
med Medium 50 4250
lo Low 23 3750
ul1 Ultra-Low-1 20 3000
ul2 Ultra-Low-2 10 3000
ni Night 2 3000
ni2 Night-2 2 2000'

key=$1
if [ -z "$key" ]; then
    n=$(printf '%s\n' "$presets" | wc -l | tr -d ' ')
    key=$(printf '%s\n' "$presets" | awk '{ printf "%-3s   %-11s   %3s   %s\n", $1, $2, $3, $4 }' |
        rofi -dmenu -i -l "$n" -p licht -theme picker | awk '{ print $1 }')
    [ -z "$key" ] && exit 0
fi
set -- $(printf '%s\n' "$presets" | awk -v k="$key" '$1 == k')
[ $# -eq 4 ] || { echo "licht: unknown preset: $key" >&2; exit 1; }

backlight "$3"
printf '%s %s\n' "$key" "$3" > /tmp/licht-curr-val
pkill -x gammastep
i=0; while pgrep -x gammastep >/dev/null && [ $i -lt 30 ]; do sleep 0.1; i=$((i + 1)); done
nohup gammastep -O "$4" -P >/dev/null 2>&1 &
notify-send --app-name dwm-licht --expire-time 4000 --icon brightness-high-symbolic \
    --replace-id 126 Licht "$2"
