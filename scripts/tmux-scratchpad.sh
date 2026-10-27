#!/usr/bin/env sh

session=scratchpad

if ! tmux has-session -t "=$session" 2>/dev/null; then
    tmux new-session -d -s "$session" -n btop btop
    tmux new-window -t "=$session:""clear && fastfetch; exec $SHELL"
fi

exec tmux attach-session -t "=$session"
