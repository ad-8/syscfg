#!/usr/bin/env sh

session=ax-top

if tmux has-session -t "=$session" 2>/dev/null; then
    exec tmux attach-session -t "=$session"
fi

exec tmux new-session -s "$session" -n "$session" btop \; \
    split-window -h -l 45% "top -P" \; \
    split-window -v "systat -pigs 1"
