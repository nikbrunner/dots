#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
HERDR_BIN=${HERDR_BIN_PATH:-herdr}
STATE_FILE="${HERDR_PLUGIN_STATE_DIR:?}/pane"
PANE_ID=
pane_available=false

if [ -f "$STATE_FILE" ]; then
    PANE_ID=$(head -n 1 "$STATE_FILE")
fi

somars_running=false
if [ -n "$PANE_ID" ] && PROCESS_INFO=$("$HERDR_BIN" pane process-info --pane "$PANE_ID" 2>/dev/null); then
    pane_available=true
    if printf '%s\n' "$PROCESS_INFO" | jq -e \
        'any(.result.process_info.foreground_processes[]?; .name == "somars")' \
        >/dev/null; then
        somars_running=true
    fi
fi

if [ "$pane_available" = true ] && [ "$somars_running" != true ]; then
    "$HERDR_BIN" pane run "$PANE_ID" 'somars; exit' >/dev/null
elif [ "$pane_available" != true ]; then
    WORKSPACE_ID=${HERDR_WORKSPACE_ID:-}
    if [ -z "$WORKSPACE_ID" ]; then
        WORKSPACE_ID=$(printf '%s\n' "${HERDR_PLUGIN_CONTEXT_JSON:-}" | \
            jq -r '.workspace_id // empty' 2>/dev/null || true)
    fi
    [ -n "$WORKSPACE_ID" ] || exit 1

    CWD=$(printf '%s\n' "${HERDR_PLUGIN_CONTEXT_JSON:-}" | \
        jq -r '.focused_pane_cwd // .workspace_cwd // empty' 2>/dev/null || true)
    CWD=${CWD:-${HERDR_ACTIVE_PANE_CWD:-$PWD}}

    RESULT=$("$HERDR_BIN" tab create \
        --workspace "$WORKSPACE_ID" --label Somars --cwd "$CWD" --no-focus)
    PANE_ID=$(printf '%s\n' "$RESULT" | jq -er '.result.root_pane.pane_id')
    "$HERDR_BIN" pane rename "$PANE_ID" Somars >/dev/null
    "$HERDR_BIN" pane run "$PANE_ID" 'somars; exit' >/dev/null
    mkdir -p "${HERDR_PLUGIN_STATE_DIR}"
    printf '%s\n' "$PANE_ID" >"$STATE_FILE"
fi

PANE_INFO=$("$HERDR_BIN" pane get "$PANE_ID")
TERMINAL_ID=$(printf '%s\n' "$PANE_INFO" | jq -er '.result.pane.terminal_id')
if [ -n "${HERDR_SOMARS_RELAY_BIN:-}" ]; then
    RELAY_BIN=$HERDR_SOMARS_RELAY_BIN
elif [ -x "$HOME/.local/bin/herdr-somars-relay" ]; then
    RELAY_BIN="$HOME/.local/bin/herdr-somars-relay"
else
    RELAY_BIN="$SCRIPT_DIR/../../../../.local/bin/herdr-somars-relay"
fi

exec "$RELAY_BIN" "$TERMINAL_ID"
