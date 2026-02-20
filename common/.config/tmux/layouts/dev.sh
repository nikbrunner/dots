#!/usr/bin/env bash
#
# Dev layout: 2 windows for development workflow
#
# Windows:
# 1. claude   - Claude + Editor + terminal (ide layout)
# 2. server   - Two panes for server/output
#
# Window 1 (claude):
# ┌─────────┬───────────────────────────┐
# │         │                           │
# │ claude  │         editor            │
# │  (25%)  │          (75%)            │
# │         ├───────────────────────────┤
# │         │    terminal (20%)         │
# └─────────┴───────────────────────────┘
#
# Window 2 (server):
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
    tmux split-window -h -t "${session_name}:1" -c "$working_dir" -l 75%
    tmux split-window -v -t "${session_name}:1.2" -c "$working_dir" -l 20%
    tmux send-keys -t "${session_name}:1.1" "[[ -f .nvmrc ]] && nvm use; claude" Enter
    tmux send-keys -t "${session_name}:1.2" "[[ -f .nvmrc ]] && nvm use; nvim" Enter
    tmux send-keys -t "${session_name}:1.3" "[[ -f .nvmrc ]] && nvm use; clear" Enter

    # Window 2: server (two panes)
    tmux new-window -t "${session_name}" -n "server" -c "$working_dir"
    tmux split-window -h -t "${session_name}:2" -c "$working_dir" -l 50%
    tmux send-keys -t "${session_name}:2.1" "[[ -f .nvmrc ]] && nvm use; clear" Enter
    tmux send-keys -t "${session_name}:2.2" "[[ -f .nvmrc ]] && nvm use; clear" Enter

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
        tmux split-window -h -t '${session_name}:1' -c '${working_dir}' -l 75%
        tmux split-window -v -t '${session_name}:1.2' -c '${working_dir}' -l 20%
        tmux send-keys -t '${session_name}:1.1' '[[ -f .nvmrc ]] && nvm use; claude' Enter
        tmux send-keys -t '${session_name}:1.2' '[[ -f .nvmrc ]] && nvm use; nvim' Enter
        tmux send-keys -t '${session_name}:1.3' '[[ -f .nvmrc ]] && nvm use; clear' Enter
        tmux new-window -t '${session_name}' -n 'server' -c '${working_dir}'
        tmux split-window -h -t '${session_name}:2' -c '${working_dir}' -l 50%
        tmux send-keys -t '${session_name}:2.1' '[[ -f .nvmrc ]] && nvm use; clear' Enter
        tmux send-keys -t '${session_name}:2.2' '[[ -f .nvmrc ]] && nvm use; clear' Enter
        tmux select-window -t '${session_name}:1'
        tmux select-pane -t '${session_name}:1.1'
        tmux set-hook -u -t '${session_name}' client-attached
    "
    tmux set-hook -t "${session_name}" client-attached "run-shell \"${layout_commands}\""
fi
