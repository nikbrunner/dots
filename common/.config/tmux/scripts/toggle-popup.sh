#!/bin/bash
set -e

# Toggle persistent popup shell for tmux
#
# Checks if the persistent popup session has active clients and either
# closes or opens it accordingly. This prevents display-popup from being
# called while a popup is already open, which avoids width/dimension
# artifacts when toggling.

CURRENT_SESSION=$(tmux display-message -p '#S')
POPUP_SESSION="_popup_${CURRENT_SESSION}"

# Check if the popup session has any attached client
CLIENT=$(tmux list-clients -t "$POPUP_SESSION" -F "#{client_name}" 2>/dev/null | head -1) || CLIENT=""

if [ -n "$CLIENT" ]; then
    # Popup is open — detach the nested client from the popup session.
    # This makes show-popup.sh's `tmux attach` return, the script exits,
    # and display-popup -E closes the popup cleanly.
    tmux detach-client -t "$CLIENT" 2>/dev/null || true
else
    # No popup — open persistent shell popup
    tmux display-popup \
        -d "#{pane_current_path}" \
        -w135 -h90% \
        -E "$HOME/.config/tmux/scripts/show-popup.sh"
fi
