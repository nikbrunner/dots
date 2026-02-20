#!/usr/bin/env bash
#
# Reset dev layout proportions for the current window
#
# Resizes existing panes to their intended proportions.
# Use after resizing terminal or when pane sizes get out of whack.
#
# Window 1 (claude) - 3 panes:
# ┌─────────┬───────────────────────────┐
# │         │                           │
# │  pane 1 │        pane 2             │
# │  (25%)  │         (75%)             │
# │         ├───────────────────────────┤
# │         │      pane 3 (20%)         │
# └─────────┴───────────────────────────┘
#
# Window 2 (server) - 2 panes:
# ┌─────────────────┬─────────────────┐
# │     pane 1      │     pane 2      │
# │      (50%)      │     (50%)       │
# └─────────────────┴─────────────────┘

set -euo pipefail

width=$(tmux display-message -p '#{window_width}')
height=$(tmux display-message -p '#{window_height}')
pane_count=$(tmux list-panes | wc -l | tr -d ' ')

if [[ "$pane_count" -eq 3 ]]; then
    # Claude window: 25% left, 20% bottom-right
    tmux resize-pane -t 1 -x $((width * 25 / 100)) 2>/dev/null || true
    tmux resize-pane -t 3 -y $((height * 20 / 100)) 2>/dev/null || true
elif [[ "$pane_count" -eq 2 ]]; then
    # Server window: 50/50
    tmux resize-pane -t 1 -x $((width * 50 / 100)) 2>/dev/null || true
fi
