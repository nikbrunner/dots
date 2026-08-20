#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT HUP INT TERM

FAKE_HERDR="$TMP_DIR/herdr"
CALLS="$TMP_DIR/calls"
NOTIFICATIONS="$TMP_DIR/notifications"

cat >"$FAKE_HERDR" <<'FAKE'
#!/bin/sh
set -eu
printf '%s\n' "$*" >> "$FAKE_CALLS"

case "$*" in
  "tab list --workspace w-test")
    case "${FAKE_STATE:-fresh}" in
      fresh|empty-panes)
        printf '%s\n' '{"result":{"tabs":[{"tab_id":"t-root"}]}}'
        ;;
      empty-tabs)
        printf '%s\n' '{"result":{"tabs":[]}}'
        ;;
      *)
        printf '%s\n' '{"result":{"tabs":[{"tab_id":"t-root"},{"tab_id":"t-extra"}]}}'
        ;;
    esac
    ;;
  "pane list --workspace w-test")
    case "${FAKE_STATE:-fresh}" in
      fresh|empty-tabs)
        printf '%s\n' '{"result":{"panes":[{"pane_id":"p-root"}]}}'
        ;;
      empty-panes)
        printf '%s\n' '{"result":{"panes":[]}}'
        ;;
      *)
        printf '%s\n' '{"result":{"panes":[{"pane_id":"p-root"},{"pane_id":"p-extra"}]}}'
        ;;
    esac
    ;;
  "pane split --pane p-root --direction right --ratio 0.70 --no-focus")
    if [ "${FAKE_FAIL_SPLIT:-0}" = 1 ]; then
      exit 1
    fi
    printf '%s\n' '{"result":{"pane":{"pane_id":"p-agent"}}}'
    ;;
  "pane split --pane p-agent --direction down --ratio 0.65 --no-focus")
    printf '%s\n' '{"result":{"pane":{"pane_id":"p-shell"}}}'
    ;;
  "tab create --workspace w-test --label Servers --no-focus")
    printf '%s\n' '{"result":{"tab":{"tab_id":"t-servers"},"root_pane":{"pane_id":"p-server1"}}}'
    ;;
  "pane split --pane p-server1 --direction right --ratio 0.50 --no-focus")
    printf '%s\n' '{"result":{"pane":{"pane_id":"p-server2"}}}'
    ;;
  "pane split --pane p-server1 --direction down --ratio 0.50 --no-focus")
    printf '%s\n' '{"result":{"pane":{"pane_id":"p-server3"}}}'
    ;;
  "pane split --pane p-server2 --direction down --ratio 0.50 --no-focus")
    printf '%s\n' '{"result":{"pane":{"pane_id":"p-server4"}}}'
    ;;
  notification\ show*)
    printf '%s\n' "$*" >> "$FAKE_NOTIFICATIONS"
    ;;
  *)
    printf '%s\n' '{"result":{}}'
    ;;
esac
FAKE
chmod +x "$FAKE_HERDR"

fail() {
    printf 'not ok - %s\n' "$1" >&2
    exit 1
}

run_hook() {
    : >"$CALLS"
    : >"$NOTIFICATIONS"
    FAKE_CALLS="$CALLS" \
        FAKE_NOTIFICATIONS="$NOTIFICATIONS" \
        FAKE_STATE="${FAKE_STATE:-fresh}" \
        FAKE_FAIL_SPLIT="${FAKE_FAIL_SPLIT:-0}" \
        HERDR_BIN_PATH="$FAKE_HERDR" \
        HERDR_WORKSPACE_ID="${TEST_WORKSPACE_ID-w-test}" \
        HERDR_TAB_ID="${TEST_TAB_ID-t-root}" \
        HERDR_PANE_ID="${TEST_PANE_ID-p-root}" \
        sh "$SCRIPT_DIR/apply-layout.sh" >"$TMP_DIR/stdout" 2>"$TMP_DIR/stderr"
}

for missing_id in HERDR_WORKSPACE_ID HERDR_TAB_ID HERDR_PANE_ID; do
    TEST_WORKSPACE_ID=w-test
    TEST_TAB_ID=t-root
    TEST_PANE_ID=p-root
    case "$missing_id" in
    HERDR_WORKSPACE_ID) TEST_WORKSPACE_ID='' ;;
    HERDR_TAB_ID) TEST_TAB_ID='' ;;
    HERDR_PANE_ID) TEST_PANE_ID='' ;;
    esac
    if run_hook; then
        fail "missing $missing_id succeeded"
    fi
    [ ! -s "$CALLS" ] || fail "missing $missing_id reached Herdr"
done
unset TEST_WORKSPACE_ID TEST_TAB_ID TEST_PANE_ID
printf 'ok - each missing required ID fails before mutation\n'

FAKE_STATE=not-fresh
run_hook || fail "non-fresh workspace failed"
if grep -Ev '^(tab|pane) list --workspace w-test$' "$CALLS" | grep -q .; then
    fail "non-fresh workspace was mutated"
fi
grep -q 'Skipping default layout' "$TMP_DIR/stderr" || fail "non-fresh skip was not logged"
unset FAKE_STATE
printf 'ok - non-fresh workspace is skipped\n'

for FAKE_STATE in empty-tabs empty-panes; do
    run_hook || fail "$FAKE_STATE workspace failed"
    if grep -Ev '^(tab|pane) list --workspace w-test$' "$CALLS" | grep -q .; then
        fail "$FAKE_STATE workspace was mutated"
    fi
    grep -q 'Skipping default layout' "$TMP_DIR/stderr" || fail "$FAKE_STATE skip was not logged"
done
unset FAKE_STATE
printf 'ok - empty tab and pane arrays are skipped\n'

run_hook || fail "fresh workspace failed"
cat >"$TMP_DIR/expected" <<'EXPECTED'
tab list --workspace w-test
pane list --workspace w-test
tab rename t-root Work
pane rename p-root Nvim
pane split --pane p-root --direction right --ratio 0.70 --no-focus
pane rename p-agent Agent
pane split --pane p-agent --direction down --ratio 0.65 --no-focus
pane rename p-shell Shell
tab create --workspace w-test --label Servers --no-focus
pane rename p-server1 Server I
pane split --pane p-server1 --direction right --ratio 0.50 --no-focus
pane rename p-server2 Server II
pane split --pane p-server1 --direction down --ratio 0.50 --no-focus
pane rename p-server3 Server III
pane split --pane p-server2 --direction down --ratio 0.50 --no-focus
pane rename p-server4 Server IV
pane run p-root nvim
tab focus t-root
EXPECTED
cmp -s "$TMP_DIR/expected" "$CALLS" || {
    diff -u "$TMP_DIR/expected" "$CALLS" >&2 || true
    fail "fresh workspace calls differ"
}
[ "$(grep -c '^pane run p-root nvim$' "$CALLS")" -eq 1 ] || fail "Nvim pane was not started exactly once"
if grep -E '^(agent start|pane run)' "$CALLS" | grep -v '^pane run p-root nvim$' >/dev/null; then
    fail "unexpected command-bearing operation found"
fi
printf 'ok - fresh workspace gets the exact static layout and starts Nvim\n'

FAKE_FAIL_SPLIT=1
if run_hook; then
    fail "forced split failure succeeded"
fi
cat >"$TMP_DIR/expected-failure" <<'EXPECTED'
tab list --workspace w-test
pane list --workspace w-test
tab rename t-root Work
pane rename p-root Nvim
pane split --pane p-root --direction right --ratio 0.70 --no-focus
notification show Default layout failed --body Workspace w-test may have a partial layout. --sound request
EXPECTED
cmp -s "$TMP_DIR/expected-failure" "$CALLS" || {
    diff -u "$TMP_DIR/expected-failure" "$CALLS" >&2 || true
    fail "mutation continued after split failure"
}
grep -q '^notification show ' "$NOTIFICATIONS" || fail "split failure sent no notification"
grep -q 'Failed to apply default layout' "$TMP_DIR/stderr" || fail "split failure was not logged"
unset FAKE_FAIL_SPLIT
printf 'ok - mutation failure stops and notifies\n'
