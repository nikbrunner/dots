#!/usr/bin/env bash
# Track last session for tmux status bar

echo "$(date): hook fired" >> /tmp/tmux-session-track.log

prev=$(tmux show-option -gqv @current_session)
curr=$(tmux display-message -p '#S')

echo "$(date): prev=$prev curr=$curr" >> /tmp/tmux-session-track.log

tmux set-option -g @last_session "$prev"
tmux set-option -g @current_session "$curr"
