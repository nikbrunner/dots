#!/usr/bin/env bash
#
# Reset IDE layout for current window
#
# Resizes existing panes to IDE proportions (25% / 75% with 20% terminal)
# Use this after resizing terminal to fix broken proportions
#
# Layout:
# ┌─────────┬───────────────────────────┐
# │         │                           │
# │  pane 1 │        pane 2             │
# │  (25%)  │         (75%)             │
# │         ├───────────────────────────┤
# │         │      pane 3 (20%)         │
# └─────────┴───────────────────────────┘

set -euo pipefail

# Get current window dimensions
width=$(tmux display-message -p '#{window_width}')
height=$(tmux display-message -p '#{window_height}')

# Calculate pane sizes
left_width=$((width * 25 / 100))
bottom_height=$((height * 20 / 100))

# Resize panes (assumes 3-pane IDE layout)
# Pane 1: left (25%)
tmux resize-pane -t 1 -x "$left_width" 2>/dev/null || true

# Pane 3: bottom-right (20% height)
tmux resize-pane -t 3 -y "$bottom_height" 2>/dev/null || true
