#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT HUP INT TERM

FAKE_HERDR="$TMP_DIR/herdr"
FAKE_RELAY="$TMP_DIR/herdr-somars-relay"
CALLS="$TMP_DIR/calls"
STATE_DIR="$TMP_DIR/state"
mkdir -p "$STATE_DIR"

cat >"$FAKE_RELAY" <<'FAKE'
#!/bin/sh
set -eu
printf 'relay %s\n' "$*" >> "$FAKE_CALLS"
FAKE
chmod +x "$FAKE_RELAY"

cat >"$FAKE_HERDR" <<'FAKE'
#!/bin/sh
set -eu
printf '%s\n' "$*" >> "$FAKE_CALLS"

case "$*" in
  "plugin pane open --plugin dots.herdr-somars --entrypoint player --placement popup --width 80% --height 80%")
    exit 0
    ;;
  "tab create --workspace w-test --label Somars --cwd /tmp/somars-cwd --no-focus")
    printf '%s\n' '{"result":{"tab":{"tab_id":"w-test:t-somars"},"root_pane":{"pane_id":"w-test:p1"}}}'
    ;;
  "pane get w-test:p1")
    printf '%s\n' '{"result":{"pane":{"pane_id":"w-test:p1","terminal_id":"term-somars"}}}'
    ;;
  "pane process-info --pane w-test:p1")
    case "${FAKE_PROCESS:-somars}" in
      somars)
        printf '%s\n' '{"result":{"process_info":{"foreground_processes":[{"name":"somars"}],"pane_id":"w-test:p1"}}}'
        ;;
      shell)
        printf '%s\n' '{"result":{"process_info":{"foreground_processes":[{"name":"zsh"}],"pane_id":"w-test:p1"}}}'
        ;;
      missing)
        exit 1
        ;;
    esac
    ;;
  "pane rename w-test:p1 Somars"|"pane run w-test:p1 somars; exit")
    ;;
  *)
    printf 'unexpected fake Herdr call: %s\n' "$*" >&2
    exit 1
    ;;
esac
FAKE
chmod +x "$FAKE_HERDR"

fail() {
    printf 'not ok - %s\n' "$1" >&2
    exit 1
}

run_action() {
    : >"$CALLS"
    FAKE_CALLS="$CALLS" \
        HERDR_BIN_PATH="$FAKE_HERDR" \
        HERDR_PLUGIN_ID=dots.herdr-somars \
        /bin/sh "$SCRIPT_DIR/open.sh"
}

run_player() {
    : >"$CALLS"
    FAKE_CALLS="$CALLS" \
        FAKE_PROCESS="${FAKE_PROCESS:-}" \
        HERDR_BIN_PATH="$FAKE_HERDR" \
        HERDR_PLUGIN_ID=dots.herdr-somars \
        HERDR_PLUGIN_STATE_DIR="$STATE_DIR" \
        HERDR_SOMARS_RELAY_BIN="$FAKE_RELAY" \
        HERDR_WORKSPACE_ID=w-test \
        HERDR_PLUGIN_CONTEXT_JSON='{"workspace_id":"w-test","focused_pane_cwd":"/tmp/somars-cwd"}' \
        /bin/sh "$SCRIPT_DIR/player.sh"
}

run_action || fail "open action failed"
printf '%s\n' \
    'plugin pane open --plugin dots.herdr-somars --entrypoint player --placement popup --width 80% --height 80%' \
    >"$TMP_DIR/expected-action"
cmp -s "$TMP_DIR/expected-action" "$CALLS" || fail "open action emitted the wrong command"
printf 'ok - action opens the Somars popup\n'

rm -f "$STATE_DIR/pane"
FAKE_PROCESS=missing
run_player || fail "first player launch failed"
printf '%s\n' \
    'tab create --workspace w-test --label Somars --cwd /tmp/somars-cwd --no-focus' \
    'pane rename w-test:p1 Somars' \
    'pane run w-test:p1 somars; exit' \
    'pane get w-test:p1' \
    'relay term-somars' \
    >"$TMP_DIR/expected-first"
cmp -s "$TMP_DIR/expected-first" "$CALLS" || fail "first launch emitted the wrong commands"
printf 'ok - first launch creates and attaches the persistent pane\n'

printf '%s\n' 'w-test:p1' >"$STATE_DIR/pane"
FAKE_PROCESS=somars
run_player || fail "reattach failed"
printf '%s\n' \
    'pane process-info --pane w-test:p1' \
    'pane get w-test:p1' \
    'relay term-somars' \
    >"$TMP_DIR/expected-reattach"
cmp -s "$TMP_DIR/expected-reattach" "$CALLS" || fail "reattach emitted the wrong commands"
printf 'ok - running Somars is reattached without restarting it\n'

FAKE_PROCESS=shell
run_player || fail "restart failed"
printf '%s\n' \
    'pane process-info --pane w-test:p1' \
    'pane run w-test:p1 somars; exit' \
    'pane get w-test:p1' \
    'relay term-somars' \
    >"$TMP_DIR/expected-restart"
cmp -s "$TMP_DIR/expected-restart" "$CALLS" || {
    diff -u "$TMP_DIR/expected-restart" "$CALLS" >&2 || true
    fail "restart emitted the wrong commands"
}
printf 'ok - an existing pane restarts Somars before attaching\n'
