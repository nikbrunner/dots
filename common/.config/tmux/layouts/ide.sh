#!/usr/bin/env bash
#
# IDE layout: claude + editor + terminal
#
# Layout:
# ┌─────────┬───────────────────────────┐
# │         │                           │
# │ claude  │         editor            │
# │  (25%)  │          (75%)            │
# │         ├───────────────────────────┤
# │         │    terminal (20%)         │
# └─────────┴───────────────────────────┘
#
# Usage: ide.sh <session_name> <working_dir>

set -euo pipefail

session_name="${1:?Session name required}"
working_dir="${2:?Working directory required}"

# Split horizontally: left pane (25%), right side (75%)
tmux split-window -h -t "${session_name}:1" -c "$working_dir" -l 75%

# Split the right pane vertically: editor on top (80%), terminal below (20%)
tmux split-window -v -t "${session_name}:1.2" -c "$working_dir" -l 20%

# Start nvim in the top-right pane (pane 2)
tmux send-keys -t "${session_name}:1.2" "nvim" Enter

# Start claude in the left pane (pane 1)
tmux send-keys -t "${session_name}:1.1" "claude" Enter

# In bottom-right pane (pane 3): run nvm use if .nvmrc exists, then clear
tmux send-keys -t "${session_name}:1.3" "[[ -f .nvmrc ]] && nvm use; clear" Enter

# Focus the left pane (claude) - pane 1
tmux select-pane -t "${session_name}:1.1"
