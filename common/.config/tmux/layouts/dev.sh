#!/usr/bin/env bash
#
# Dev layout: 3 windows for development workflow
#
# Windows:
# 1. claude   - Claude + command pane
# 2. code     - Editor
# 3. server   - Two panes for server/output
#
# Window 1 (claude):
# ┌─────────────────┬─────────────────┐
# │                 │                 │
# │     claude      │    terminal     │
# │      (50%)      │     (50%)       │
# │                 │                 │
# └─────────────────┴─────────────────┘
#
# Window 3 (server):
# ┌─────────────────┬─────────────────┐
# │                 │                 │
# │     server      │     server      │
# │      (50%)      │     (50%)       │
# │                 │                 │
# └─────────────────┴─────────────────┘
#
# Usage: dev.sh <session_name> <working_dir>

set -euo pipefail

session_name="${1:?Session name required}"
working_dir="${2:?Working directory required}"

apply_layout() {
    # Window 1: claude (already exists as window 1)
    tmux rename-window -t "${session_name}:1" "claude"
    tmux split-window -h -t "${session_name}:1" -c "$working_dir" -l 50%
    tmux send-keys -t "${session_name}:1.1" "claude" Enter
    tmux send-keys -t "${session_name}:1.2" "[[ -f .nvmrc ]] && nvm use; clear" Enter

    # Window 2: code
    tmux new-window -t "${session_name}" -n "code" -c "$working_dir"
    tmux send-keys -t "${session_name}:2" "nvim" Enter

    # Window 3: server (two panes)
    tmux new-window -t "${session_name}" -n "server" -c "$working_dir"
    tmux split-window -h -t "${session_name}:3" -c "$working_dir" -l 50%
    tmux send-keys -t "${session_name}:3.1" "[[ -f .nvmrc ]] && nvm use; clear" Enter
    tmux send-keys -t "${session_name}:3.2" "[[ -f .nvmrc ]] && nvm use; clear" Enter

    # Focus on claude window, first pane
    tmux select-window -t "${session_name}:1"
    tmux select-pane -t "${session_name}:1.1"
}

# Check if we're already inside tmux (client exists with proper dimensions)
if [[ -n "${TMUX:-}" ]]; then
    # Already attached - apply layout directly since dimensions are known
    apply_layout
else
    # Not attached yet - use a one-time hook that runs after client attaches
    layout_commands="
        tmux rename-window -t '${session_name}:1' 'claude'
        tmux split-window -h -t '${session_name}:1' -c '${working_dir}' -l 50%
        tmux send-keys -t '${session_name}:1.1' 'claude' Enter
        tmux send-keys -t '${session_name}:1.2' '[[ -f .nvmrc ]] && nvm use; clear' Enter
        tmux new-window -t '${session_name}' -n 'code' -c '${working_dir}'
        tmux send-keys -t '${session_name}:2' 'nvim' Enter
        tmux new-window -t '${session_name}' -n 'server' -c '${working_dir}'
        tmux split-window -h -t '${session_name}:3' -c '${working_dir}' -l 50%
        tmux send-keys -t '${session_name}:3.1' '[[ -f .nvmrc ]] && nvm use; clear' Enter
        tmux send-keys -t '${session_name}:3.2' '[[ -f .nvmrc ]] && nvm use; clear' Enter
        tmux select-window -t '${session_name}:1'
        tmux select-pane -t '${session_name}:1.1'
        tmux set-hook -u -t '${session_name}' client-attached
    "
    tmux set-hook -t "${session_name}" client-attached "run-shell \"${layout_commands}\""
fi
