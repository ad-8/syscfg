#!/usr/bin/env sh

# glyphs as octal utf-8 so this file stays pure ascii in transit
ico_licht=$(printf '\357\203\253')     # U+F0EB
ico_load=$(printf '\357\213\233')      # U+F2DB
ico_vol=$(printf '\357\200\250')       # U+F028
ico_vol_mute=$(printf '\356\273\250')  # U+EEE8
ico_disk=$(printf '\363\260\213\212')  # U+F02CA
ico_ram=$(printf '\363\260\215\233')   # U+F035B
sep=$(printf ' \342\200\242 ')         # U+2022

status_fifo="${1:-$XDG_RUNTIME_DIR/kwm-status}"

if [ ! -e "$status_fifo" ]; then
	echo "kwm-status: $status_fifo does not exist, is river's init running?" >&2
	exit 1
fi

volume() {
	# [MUTED] is a glob, so keep pathname expansion off while splitting
	set -f
	set -- $(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)

	if [ -z "$2" ]; then
		printf '%s  --' "$ico_vol_mute"
	elif [ "$3" = '[MUTED]' ]; then
		printf '%s  MUTED' "$ico_vol_mute"
	else
		awk -v v="$2" -v ico="$ico_vol" 'BEGIN { printf "%s  %.0f%%", ico, v * 100 }'
	fi
}

licht() {
	val=$(cat /tmp/licht-curr-val 2>/dev/null)
	printf '%s %s' "$ico_licht" "${val:-"--"}"
}

load() {
	read -r one rest < /proc/loadavg
	printf '%s %s' "$ico_load" "$one"
}

disk() {
	printf '%s %s' "$ico_disk" "$(df -h / --output=avail | tail -n1 | tr -d ' ')"
}

ram() {
	free -m | awk -v ico="$ico_ram" '/^Mem:/ { printf "%s %d%%", ico, $3 / $2 * 100 }'
}

tick=0
prev=
while :; do
	if [ $((tick % 3)) -eq 0 ]; then
		load_s=$(load)
	fi

	if [ $((tick % 15)) -eq 0 ]; then
		disk_s=$(disk)
		ram_s=$(ram)
	fi

	line="$(volume)$sep$(licht)$sep$load_s$sep$disk_s$sep$ram_s$sep$(/home/ax/syscfg/scripts/freebsd/datetime.sh)"
	if [ "$line" != "$prev" ]; then
		printf '%s\n' "$line" > "$status_fifo"
		prev=$line
	fi

	tick=$((tick + 1))
	sleep 2
done
