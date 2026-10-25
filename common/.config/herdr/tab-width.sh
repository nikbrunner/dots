#!/bin/sh
# Width of the active pane area, which the tab bar spans; 0 when Herdr can't tell.

w=$("${HERDR_BIN_PATH:-herdr}" pane layout --pane "$HERDR_ACTIVE_PANE_ID" 2>/dev/null |
    sed -n 's/.*"area":{[^}]*"width":\([0-9]*\).*/\1/p')
echo "${w:-0}"
