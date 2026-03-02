#!/bin/bash
# Persistent popup for notes (Penny workspace)
# Creates a background session that persists when dismissed

session_name="Penny"

# If we're already in the penny session, detach instead
current_session=$(tmux display-message -p '#S')
if [[ "$current_session" == "$session_name" ]]; then
    tmux detach-client
    exit 0
fi

if ! tmux list-sessions -F "#{session_name}" 2>/dev/null | grep -qx "$session_name"; then
    tmux new-session -d -s "$session_name" -c ~/repos/nikbrunner/notes
    tmux set -t "$session_name" status off
fi

tmux attach -t "$session_name"
