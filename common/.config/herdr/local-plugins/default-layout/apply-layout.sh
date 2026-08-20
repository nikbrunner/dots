#!/bin/sh
set -eu

log() {
    printf 'dots.default-layout: %s\n' "$*" >&2
}

require_id() {
    name=$1
    eval "value=\${$name:-}"
    if [ -z "$value" ]; then
        log "Missing required event value: $name"
        exit 1
    fi
}

require_id HERDR_WORKSPACE_ID
require_id HERDR_TAB_ID
require_id HERDR_PANE_ID

if [ -z "${HERDR_BIN_PATH:-}" ] || ! HERDR_BIN=$(command -v "$HERDR_BIN_PATH" 2>/dev/null); then
    log "Herdr binary is unavailable"
    exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
    log "jq is unavailable"
    exit 1
fi

TABS_JSON=$("$HERDR_BIN" tab list --workspace "$HERDR_WORKSPACE_ID")
PANES_JSON=$("$HERDR_BIN" pane list --workspace "$HERDR_WORKSPACE_ID")
TAB_COUNT=$(printf '%s\n' "$TABS_JSON" | jq -er '.result.tabs | length')
PANE_COUNT=$(printf '%s\n' "$PANES_JSON" | jq -er '.result.panes | length')

if [ "$TAB_COUNT" -ne 1 ] || [ "$PANE_COUNT" -ne 1 ]; then
    log "Skipping default layout for non-fresh workspace $HERDR_WORKSPACE_ID"
    exit 0
fi

TAB_ID=$(printf '%s\n' "$TABS_JSON" | jq -er '.result.tabs[0].tab_id')
PANE_ID=$(printf '%s\n' "$PANES_JSON" | jq -er '.result.panes[0].pane_id')

if [ "$TAB_ID" != "$HERDR_TAB_ID" ] || [ "$PANE_ID" != "$HERDR_PANE_ID" ]; then
    log "Skipping default layout for non-fresh workspace $HERDR_WORKSPACE_ID"
    exit 0
fi

mutation_failed() {
    status=$?
    trap - EXIT HUP INT TERM
    log "Failed to apply default layout to workspace $HERDR_WORKSPACE_ID"
    "$HERDR_BIN" notification show "Default layout failed" \
        --body "Workspace $HERDR_WORKSPACE_ID may have a partial layout." \
        --sound request >/dev/null 2>&1 || true
    exit "$status"
}
trap mutation_failed EXIT HUP INT TERM

"$HERDR_BIN" tab rename "$TAB_ID" Work >/dev/null
"$HERDR_BIN" pane rename "$PANE_ID" Nvim >/dev/null

RESULT=$("$HERDR_BIN" pane split --pane "$PANE_ID" --direction right --ratio 0.70 --no-focus)
AGENT_PANE_ID=$(printf '%s\n' "$RESULT" | jq -er '.result.pane.pane_id')
"$HERDR_BIN" pane rename "$AGENT_PANE_ID" Agent >/dev/null

RESULT=$("$HERDR_BIN" pane split --pane "$AGENT_PANE_ID" --direction down --ratio 0.65 --no-focus)
SHELL_PANE_ID=$(printf '%s\n' "$RESULT" | jq -er '.result.pane.pane_id')
"$HERDR_BIN" pane rename "$SHELL_PANE_ID" Shell >/dev/null

RESULT=$("$HERDR_BIN" tab create --workspace "$HERDR_WORKSPACE_ID" --label Servers --no-focus)
SERVERS_TAB_ID=$(printf '%s\n' "$RESULT" | jq -er '.result.tab.tab_id')
SERVER_I_PANE_ID=$(printf '%s\n' "$RESULT" | jq -er '.result.root_pane.pane_id')
[ -n "$SERVERS_TAB_ID" ]
"$HERDR_BIN" pane rename "$SERVER_I_PANE_ID" "Server I" >/dev/null

RESULT=$("$HERDR_BIN" pane split --pane "$SERVER_I_PANE_ID" --direction right --ratio 0.50 --no-focus)
SERVER_II_PANE_ID=$(printf '%s\n' "$RESULT" | jq -er '.result.pane.pane_id')
"$HERDR_BIN" pane rename "$SERVER_II_PANE_ID" "Server II" >/dev/null

RESULT=$("$HERDR_BIN" pane split --pane "$SERVER_I_PANE_ID" --direction down --ratio 0.50 --no-focus)
SERVER_III_PANE_ID=$(printf '%s\n' "$RESULT" | jq -er '.result.pane.pane_id')
"$HERDR_BIN" pane rename "$SERVER_III_PANE_ID" "Server III" >/dev/null

RESULT=$("$HERDR_BIN" pane split --pane "$SERVER_II_PANE_ID" --direction down --ratio 0.50 --no-focus)
SERVER_IV_PANE_ID=$(printf '%s\n' "$RESULT" | jq -er '.result.pane.pane_id')
"$HERDR_BIN" pane rename "$SERVER_IV_PANE_ID" "Server IV" >/dev/null

"$HERDR_BIN" pane run "$PANE_ID" nvim >/dev/null
"$HERDR_BIN" tab focus "$TAB_ID" >/dev/null

trap - EXIT HUP INT TERM
log "Applied default layout to workspace $HERDR_WORKSPACE_ID"
