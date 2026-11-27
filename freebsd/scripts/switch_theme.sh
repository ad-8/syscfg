#!/bin/sh
# Usage: switch_theme.sh [theme]
# Without args, opens rofi picker. With arg, switches directly.
# FreeBSD port of scripts/bb/switch_theme.clj: only the laptop's apps, flat picker only.

T=$HOME/syscfg/themes
C=${XDG_CONFIG_HOME:-$HOME/.config}
MENU=$HOME/syscfg/freebsd/dotfiles/wlr-which-key/.config/wlr-which-key/menu.yaml
rc=0

missing() {
    echo "switch_theme: missing $1" >&2
    command -v notify-send >/dev/null && notify-send -u critical switch_theme "missing: ${1##*/}"
}

link() {
    [ -e "$T/$theme/$1" ] || { missing "$T/$theme/$1"; rc=1; return 1; }
    mkdir -p "${2%/*}" && ln -sf "$T/$theme/$1" "$2" || { rc=1; return 1; }
}

foot_osc() {
    awk -v E="$(printf '\033')" -v B="$(printf '\007')" '
        { i = index($0, "="); if (!i) next; k = substr($0, 1, i - 1); v = substr($0, i + 1) }
        k == "foreground" { printf "%s]10;#%s%s", E, v, B }
        k == "background" { printf "%s]11;#%s%s", E, v, B }
        k == "cursor" && split(v, a, " ") >= 2 { printf "%s]12;#%s%s", E, a[2], B }
        k ~ /^regular[0-7]$/ { printf "%s]4;%s;#%s%s", E, substr(k, 8), v, B }
        k ~ /^bright[0-7]$/ { printf "%s]4;%d;#%s%s", E, 8 + substr(k, 7), v, B }
    ' "$1"
}

reload_foot() {
    osc=$(foot_osc "$1")
    for p in $(pgrep -x foot); do
        for c in $(pgrep -P "$p"); do
            tty=$(ps -o tty= -p "$c" | tr -d ' ')
            case $tty in pts/*) printf '%s' "$osc" >>"/dev/$tty" 2>/dev/null ;; esac
        done
    done
}

reload_dunst() {
    paused=$(dunstctl is-paused 2>/dev/null)
    dunstctl reload "$C/dunst/dunstrc" "$C/dunst/active-theme.conf" 2>/dev/null
    [ "$paused" = true ] && dunstctl set-paused true
}

reload_waybar() {
    pgrep -x waybar >/dev/null || return 0
    cfg=$C/waybar/config-freebsd
    pkill -x waybar
    i=0; while pgrep -x waybar >/dev/null && [ $i -lt 30 ]; do sleep 0.1; i=$((i + 1)); done
    nohup waybar -c "$cfg" >/dev/null 2>&1 &
}

which_key() {
    src=$T/$theme/wlr-which-key.yaml dest=$C/wlr-which-key/config.yaml
    for f in "$src" "$MENU"; do [ -e "$f" ] || { missing "$f"; rc=1; return 1; }; done
    mkdir -p "${dest%/*}" && { cat "$src"; echo; cat "$MENU"; } >"$dest.tmp" && mv -f "$dest.tmp" "$dest" ||
        { rm -f "$dest.tmp"; rc=1; return 1; }
}

# TODO: mango 0.18 (2027Q1) takes the theme file as is; then link it like the others
mango_theme() {
    src=$T/$theme/mango.conf dest=$C/mango/active-theme.conf
    [ -e "$src" ] || { missing "$src"; rc=1; return 1; }
    mkdir -p "${dest%/*}" && sed \
        -e '/^# deck \/ monocle tab bar$/d' \
        -e '/^tab_bar_decorate_/d' \
        -e 's/^root_color=/rootcolor=/' \
        -e 's/^focus_color=/focuscolor=/' \
        -e 's/^border_color=/bordercolor=/' \
        -e 's/^urgent_color=/urgentcolor=/' \
        -e 's/^maximized_screen_color=/maximizescreencolor=/' \
        -e 's/^scratchpad_color=/scratchpadcolor=/' \
        -e 's/^global_color=/globalcolor=/' \
        -e 's/^overlay_color=/overlaycolor=/' \
        -e 's/^drop_color=/dropcolor=/' \
        -e 's/^split_color=/splitcolor=/' \
        "$src" >"$dest.tmp" && mv -f "$dest.tmp" "$dest" ||
        { rm -f "$dest.tmp"; rc=1; return 1; }
}

theme=$1
if [ -z "$theme" ]; then
    list=$(for d in "$T"/*/; do d=${d%/}; case ${d##*/} in _*) continue ;; esac; echo "${d##*/}"; done)
    n=$(printf '%s\n' "$list" | wc -l | tr -d ' ')
    theme=$(printf '%s\n' "$list" | rofi -dmenu -l "$n" -p "select theme ($n): " -theme picker)
    [ -z "$theme" ] && exit 0
fi
[ "${theme#_}" = "$theme" ] && [ -d "$T/$theme" ] || {
    echo "Unknown theme: $theme" >&2
    command -v notify-send >/dev/null && notify-send -u critical switch_theme "unknown theme: $theme"
    exit 1
}

link btop.theme "$C/btop/themes/active.theme" && pkill -USR2 -x btop
link foot.theme "$C/foot/active-theme" && reload_foot "$T/$theme/foot.theme"
link tmux.conf "$C/tmux/active-theme.conf" &&
    { tmux list-sessions >/dev/null 2>&1 && tmux source-file "$T/$theme/tmux.conf"; }
link waybar.css "$C/waybar/active-theme.css" && reload_waybar
link emacs-theme.el "$C/doom/active-theme.el"
link rofi.rasi "$C/rofi/active-theme.rasi"
link dillorc "$HOME/.dillo/dillorc"
link style.css "$HOME/.dillo/style.css"
link dunst.conf "$C/dunst/active-theme.conf" && reload_dunst
which_key
mango_theme && { pgrep -x mango >/dev/null && mmsg dispatch reload_config; }
exit $rc
