#!/usr/bin/env sh
# waybar custom modules for FreeBSD, POSIX sh port of scripts/waybar.clj.
# Used by freebsd/dotfiles/waybar/.config/waybar/config-freebsd.

waybar_date() {
    set -- $(LC_ALL=C date '+%a %d.%m.')
    case "$1" in
        Mon) wd="Mo" ;;
        Tue) wd="Di" ;;
        Wed) wd="Mi" ;;
        Thu) wd="Do" ;;
        Fri) wd="Fr" ;;
        Sat) wd="Sa" ;;
        Sun) wd="So" ;;
        *)   wd="$1" ;;
    esac
    printf '%s %s\n' "$wd" "$2"
}

waybar_licht() {
    cur=$(backlight | awk '{print $2}')
    set -- $(cat /tmp/licht-curr-val 2>/dev/null)
    if [ -n "$1" ] && [ "$2" = "$cur" ]; then
        val=$1
    else
        val=$cur
    fi
    printf " %s\n" "${val:---}"
}

waybar_volume() {
    val=$(mixer | awk '$1 == "vol" { split($3, a, ":"); if ($NF == "mute") printf "MUTED"; else printf "%.0f%%", a[1] * 100 }')
    printf "  %s\n" "${val:---}"
}

waybar_cpu() {
    printf " %s\n" "$(sysctl -n vm.loadavg | awk '{ print $2 }')"
}

waybar_disk() {
    printf "󰋊 %s\n" "$(df -h / | awk 'NR == 2 { print $4 }')"
}

waybar_memory() {
    printf "󰍛 %s\n" "$(sysctl -n -i vm.stats.vm.v_active_count vm.stats.vm.v_wire_count \
        vm.stats.vm.v_laundry_count vm.stats.vm.v_page_count vm.stats.vm.v_page_size \
        kstat.zfs.misc.arcstats.size |
        awk '{ v[NR] = $1 } END { printf "%.0f%%", (v[1] + v[2] + v[3] - v[6] / v[5]) / v[4] * 100 }')"
}

waybar_vpn() {
    ifs=$(ifconfig -g wg 2>/dev/null)
    if [ -n "$ifs" ]; then
        printf '{"text": " %s"}\n' "$(echo $ifs | sed 's/ / + /g')"
    else
        printf '{"text": "NO VPN CONN", "class": "down"}\n'
    fi
}

waybar_net() {
    if ! ifconfig wlan0 2>/dev/null | grep -q 'status: associated'; then
        state="NO WIFI"
    elif ping -c1 -t2 1.1.1.1 >/dev/null 2>&1; then
        state="NET OK"
    else
        router=$(netstat -rn -f inet 2>/dev/null | awk '$1 == "default" && $4 == "wlan0" { print $2; exit }')
        if [ -n "$router" ] && ping -c1 -t2 "$router" >/dev/null 2>&1; then
            state="NO INTERNET"
        else
            state="NO ROUTER"
        fi
    fi
    log="$HOME/.local/state/net.log"
    mkdir -p "${log%/*}"
    last=$(tail -n 1 "$log" 2>/dev/null | cut -d' ' -f3-)
    [ "$state" = "$last" ] || printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$state" >>"$log"
    if [ "$state" = "NET OK" ]; then
        printf '{"text": "%s", "class": "ok"}\n' "$state"
    else
        printf '{"text": "%s", "class": "down"}\n' "$state"
    fi
}

case "$1" in
    date) waybar_date ;;
    licht) waybar_licht ;;
    volume) waybar_volume ;;
    cpu) waybar_cpu ;;
    disk) waybar_disk ;;
    memory) waybar_memory ;;
    vpn) waybar_vpn ;;
    net) waybar_net ;;
    *)
        echo "usage: $0 date|licht|volume|cpu|disk|memory|vpn|net" >&2
        exit 1
        ;;
esac
