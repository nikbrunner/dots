#!/bin/bash
# Persistent popup shell for tmux
# Creates a background session that persists when dismissed

current_session=$(tmux display-message -p '#S')

# If we're already in a popup session, detach instead
if [[ "$current_session" == _popup_* ]]; then
    tmux detach-client
    exit 0
fi

session_name="_popup_${current_session}"

if ! tmux has-session -t "$session_name" 2>/dev/null; then
    tmux new-session -d -s "$session_name"
    tmux set -t "$session_name" status off
fi

tmux attach -t "$session_name"
