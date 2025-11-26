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

# Define the layout commands as a script that will run after client attaches
# This ensures the terminal has proper dimensions for percentage-based splits
layout_commands="
    tmux split-window -h -t '${session_name}:1' -c '${working_dir}' -l 66%
    tmux split-window -v -t '${session_name}:1.2' -c '${working_dir}' -l 20%
    tmux send-keys -t '${session_name}:1.2' 'nvim' Enter
    tmux send-keys -t '${session_name}:1.1' 'claude' Enter
    tmux send-keys -t '${session_name}:1.3' '[[ -f .nvmrc ]] && nvm use; clear' Enter
    tmux select-pane -t '${session_name}:1.1'
    tmux set-hook -u -t '${session_name}' client-attached
"

# Check if we're already inside tmux (client exists with proper dimensions)
if [[ -n "${TMUX:-}" ]]; then
    # Already attached - apply layout directly since dimensions are known
    tmux split-window -h -t "${session_name}:1" -c "$working_dir" -l 75%
    tmux split-window -v -t "${session_name}:1.2" -c "$working_dir" -l 20%
    tmux send-keys -t "${session_name}:1.2" "nvim" Enter
    tmux send-keys -t "${session_name}:1.1" "claude" Enter
    tmux send-keys -t "${session_name}:1.3" "[[ -f .nvmrc ]] && nvm use; clear" Enter
    tmux select-pane -t "${session_name}:1.1"
else
    # Not attached yet - use a one-time hook that runs after client attaches
    # The hook removes itself after running (set-hook -u)
    tmux set-hook -t "${session_name}" client-attached "run-shell \"${layout_commands}\""
fi
