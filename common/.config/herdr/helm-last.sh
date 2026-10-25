#!/bin/sh
# Tab bar entry: helm-herdr's jump-back target, the workspace alt+shift+o returns to.
# Prints nothing when that workspace is gone or already focused, so the entry hides.

state=~/.config/herdr/plugins/config/helm-herdr/jump-back-workspace
id=$(sed -n 's/.*"workspace_id":"\([^"]*\)".*/\1/p' "$state" 2>/dev/null)
[ -n "$id" ] && [ "$id" != "$HERDR_ACTIVE_WORKSPACE_ID" ] || exit 0

label=$("${HERDR_BIN_PATH:-herdr}" workspace get "$id" 2>/dev/null |
    sed -n 's/.*"label":"\([^"]*\)".*/\1/p')
[ -n "$label" ] && echo "󰋚 $label"
