#!/usr/bin/env bash
#
# IDE layout: terminal + editor + output pane
#
# Layout:
# ┌─────────┬───────────────────────────┐
# │         │                           │
# │ terminal│         editor            │
# │  (25%)  │          (75%)            │
# │         ├───────────────────────────┤
# │         │    small terminal (20%)   │
# └─────────┴───────────────────────────┘
#
# Usage: ide.sh <session_name> <working_dir>

set -euo pipefail

session_name="${1:?Session name required}"
working_dir="${2:?Working directory required}"

# Split horizontally: left terminal (25%), right side (75%)
tmux split-window -h -t "${session_name}:1" -c "$working_dir" -l 75%

# Split the right pane vertically: editor on top (80%), small terminal below (20%)
tmux split-window -v -t "${session_name}:1.2" -c "$working_dir" -l 20%

# Start nvim in the top-right pane (pane 2)
tmux send-keys -t "${session_name}:1.2" "nvim" Enter

# Focus the left pane (terminal) - pane 1
tmux select-pane -t "${session_name}:1.1"
