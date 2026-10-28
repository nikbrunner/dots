# shellcheck shell=bash
# file-picker adapter for herdr. herdr sets HERDR_ACTIVE_PANE_ID and
# HERDR_ACTIVE_PANE_CWD for the pane that had focus when the binding fired.

pane_is_agent() {
    local agent
    agent=$(herdr pane get "$HERDR_ACTIVE_PANE_ID" 2>/dev/null | jq -r '.result.pane.agent // empty' 2>/dev/null || true)
    [[ -n "$agent" ]]
}

pane_cwd() {
    printf '%s' "${HERDR_ACTIVE_PANE_CWD:-}"
}

pane_send() {
    herdr pane send-text "$HERDR_ACTIVE_PANE_ID" "$1"
}
