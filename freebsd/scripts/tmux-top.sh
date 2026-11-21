#!/usr/bin/env sh

session=ax-top
attach=attach-session
[ -n "$TMUX" ] && attach=switch-client

if ! tmux has-session -t "=$session" 2>/dev/null; then
    tmux new-session -d -s "$session" -n "$session" btop
    tmux split-window -h -l 45% -t "=$session" "top -P"
    pigs=$(tmux split-window -v -t "=$session" -P -F '#{pane_id}' "systat -pigs 1")
    tmux set-hook -t "=$session" window-layout-changed \
        "run-shell -b 'tmux respawn-pane -k -t $pigs 2>/dev/null || true'"
fi

exec tmux "$attach" -t "=$session"
