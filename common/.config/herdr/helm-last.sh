#!/bin/sh
# helm-herdr's jump-back target as workspace@branch, the workspace alt+shift+o returns to; status.sh shows it.
# The branch comes from the first pane of that workspace's active tab.
# Prints nothing when that workspace is gone or already focused.

herdr=${HERDR_BIN_PATH:-herdr}
state=~/.config/herdr/plugins/config/helm-herdr/jump-back-workspace
id=$(sed -n 's/.*"workspace_id":"\([^"]*\)".*/\1/p' "$state" 2>/dev/null)
[ -n "$id" ] && [ "$id" != "$HERDR_ACTIVE_WORKSPACE_ID" ] || exit 0

info=$("$herdr" workspace get "$id" 2>/dev/null)
label=$(echo "$info" | sed -n 's/.*"label":"\([^"]*\)".*/\1/p')
[ -n "$label" ] || exit 0
tab=$(echo "$info" | sed -n 's/.*"active_tab_id":"\([^"]*\)".*/\1/p')

branch=$("$herdr" pane list --workspace "$id" 2>/dev/null |
    grep -o "\"tab_id\":\"$tab\"[^{]*\"tokens\":{\"branch\":\"[^\"]*\"" | head -1 |
    sed 's/.*"branch":"//; s/"$//; s/.* //')

if [ -n "$branch" ]; then echo "$label@$branch"; else echo "$label"; fi
