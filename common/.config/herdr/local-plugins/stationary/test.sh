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
      fresh|empty-panes) printf '%s\n' '{"result":{"tabs":[{"tab_id":"t-root"}]}}' ;;
      repairable) printf '%s\n' '{"result":{"tabs":[{"tab_id":"t-work","label":"Work"},{"tab_id":"t-servers","label":"Servers"}]}}' ;;
      reapply) printf '%s\n' '{"result":{"tabs":[{"tab_id":"t-root"},{"tab_id":"t-extra"}]}}' ;;
      empty-tabs) printf '%s\n' '{"result":{"tabs":[]}}' ;;
      *) printf '%s\n' '{"result":{"tabs":[{"tab_id":"t-root"},{"tab_id":"t-extra"}]}}' ;;
    esac
    ;;
  "pane list --workspace w-test")
    case "${FAKE_STATE:-fresh}" in
      fresh|empty-tabs) printf '%s\n' '{"result":{"panes":[{"pane_id":"p-root"}]}}' ;;
      repairable) printf '%s\n' '{"result":{"panes":[{"pane_id":"p-root","tab_id":"t-work","label":"Agent"},{"pane_id":"p-nvim","tab_id":"t-work","label":"Nvim"},{"pane_id":"p-shell","tab_id":"t-work","label":"Shell"},{"pane_id":"p-server1","tab_id":"t-servers","label":"Server I"},{"pane_id":"p-server2","tab_id":"t-servers","label":"Server II"},{"pane_id":"p-server3","tab_id":"t-servers","label":"Server III"},{"pane_id":"p-server4","tab_id":"t-servers","label":"Server IV"}]}}' ;;
      reapply) printf '%s\n' '{"result":{"panes":[{"pane_id":"p-root"},{"pane_id":"p-extra"}]}}' ;;
      empty-panes) printf '%s\n' '{"result":{"panes":[]}}' ;;
      *) printf '%s\n' '{"result":{"panes":[{"pane_id":"p-root"},{"pane_id":"p-extra"}]}}' ;;
    esac
    ;;
  "pane split --pane p-root --direction right --ratio 0.3 --focus"|\
  "pane split --pane p-root --direction right --ratio 0.25 --focus"|\
  "pane split --pane p-root --direction right --ratio 0.2 --focus")
    if [ "${FAKE_FAIL_SPLIT:-0}" = 1 ]; then exit 1; fi
    printf '%s\n' '{"result":{"pane":{"pane_id":"p-nvim"}}}'
    ;;
  "pane split --pane p-root --direction down --ratio 0.65 --no-focus")
    printf '%s\n' '{"result":{"pane":{"pane_id":"p-shell1"}}}'
    ;;
  "pane split --pane p-nvim --direction down --ratio 0.65 --no-focus"|\
  "pane split --pane p-nvim --direction down --ratio 0.8 --no-focus")
    printf '%s\n' '{"result":{"pane":{"pane_id":"p-shell2"}}}'
    ;;
  "pane split --pane p-root --direction down --ratio 0.8 --no-focus")
    printf '%s\n' '{"result":{"pane":{"pane_id":"p-shell2"}}}'
    ;;
  "pane split --pane p-reapply --direction right --ratio 0.25 --focus")
    printf '%s\n' '{"result":{"pane":{"pane_id":"p-reapply-nvim"}}}'
    ;;
  "pane split --pane p-reapply-nvim --direction down --ratio 0.8 --no-focus")
    printf '%s\n' '{"result":{"pane":{"pane_id":"p-reapply-shell"}}}'
    ;;
  "pane layout --pane p-root")
    printf '%s\n' '{"result":{"layout":{"splits":[{"direction":"right","ratio":0.3},{"direction":"down","ratio":0.7}]}}}'
    ;;
  "pane layout --pane p-server1")
    printf '%s\n' '{"result":{"layout":{"splits":[{"direction":"right","ratio":0.4},{"direction":"down","ratio":0.6},{"direction":"down","ratio":0.4}]}}}'
    ;;
  "tab create --workspace w-test --cwd /tmp/stationary --label default --no-focus")
    printf '%s\n' '{"result":{"tab":{"tab_id":"t-reapply"},"root_pane":{"pane_id":"p-reapply"}}}'
    ;;
  "tab create --workspace w-test --label Servers --no-focus")
    printf '%s\n' '{"result":{"tab":{"tab_id":"t-servers"},"root_pane":{"pane_id":"p-server1"}}}'
    ;;
  "pane split --pane p-server1 --direction right --ratio 0.5 --no-focus")
    printf '%s\n' '{"result":{"pane":{"pane_id":"p-server2"}}}'
    ;;
  "pane split --pane p-server1 --direction down --ratio 0.5 --no-focus")
    printf '%s\n' '{"result":{"pane":{"pane_id":"p-server3"}}}'
    ;;
  "pane split --pane p-server2 --direction down --ratio 0.5 --no-focus")
    printf '%s\n' '{"result":{"pane":{"pane_id":"p-server4"}}}'
    ;;
  notification\ show*)
    printf '%s\n' "$*" >> "$FAKE_NOTIFICATIONS"
    ;;
  *) printf '%s\n' '{"result":{}}' ;;
esac
FAKE
chmod +x "$FAKE_HERDR"

fail() {
    printf 'not ok - %s\n' "$1" >&2
    exit 1
}

run_hook() {
    script=${TEST_SCRIPT:-$SCRIPT_DIR/apply-layout.sh}
    : >"$CALLS"
    : >"$NOTIFICATIONS"
    PATH="${TEST_PATH:-$PATH}" \
        FAKE_CALLS="$CALLS" \
        FAKE_NOTIFICATIONS="$NOTIFICATIONS" \
        FAKE_STATE="${FAKE_STATE:-fresh}" \
        FAKE_FAIL_SPLIT="${FAKE_FAIL_SPLIT:-0}" \
        HERDR_BIN_PATH="$FAKE_HERDR" \
        HERDR_WORKSPACE_ID="${TEST_WORKSPACE_ID-w-test}" \
        HERDR_TAB_ID="${TEST_TAB_ID-t-root}" \
        HERDR_PANE_ID="${TEST_PANE_ID-p-root}" \
        HERDR_ACTIVE_PANE_CWD="${TEST_PANE_CWD-/tmp/stationary}" \
        /bin/sh "$script" "$@" >"$TMP_DIR/stdout" 2>"$TMP_DIR/stderr"
}

assert_no_mutation() {
    if grep -E '^(tab rename|tab create|tab focus|pane rename|pane split|pane run|pane focus)' "$CALLS" >/dev/null; then
        fail "$1 mutated the workspace"
    fi
}

if run_hook; then fail "missing layout name succeeded"; fi
assert_no_mutation "missing layout name"
grep -q '^notification show Stationary configuration failed ' "$NOTIFICATIONS" || fail "missing layout name sent no notification"
printf 'ok - layout name is required before mutation\n'

for missing_id in HERDR_WORKSPACE_ID HERDR_TAB_ID HERDR_PANE_ID; do
    TEST_WORKSPACE_ID=w-test
    TEST_TAB_ID=t-root
    TEST_PANE_ID=p-root
    case "$missing_id" in
      HERDR_WORKSPACE_ID) TEST_WORKSPACE_ID='' ;;
      HERDR_TAB_ID) TEST_TAB_ID='' ;;
      HERDR_PANE_ID) TEST_PANE_ID='' ;;
    esac
    if run_hook default; then fail "missing $missing_id succeeded"; fi
    [ ! -s "$CALLS" ] || fail "missing $missing_id reached Herdr"
done
unset TEST_WORKSPACE_ID TEST_TAB_ID TEST_PANE_ID
printf 'ok - each missing required ID fails before mutation\n'

MISSING_RECIPE_DIR="$TMP_DIR/missing-recipe"
mkdir -p "$MISSING_RECIPE_DIR"
cp "$SCRIPT_DIR/apply-layout.sh" "$MISSING_RECIPE_DIR/apply-layout.sh"
TEST_SCRIPT="$MISSING_RECIPE_DIR/apply-layout.sh"
if run_hook default; then fail "missing recipe succeeded"; fi
assert_no_mutation "missing recipe"
grep -q 'Layout recipe is unavailable' "$TMP_DIR/stderr" || fail "missing recipe was not logged"
unset TEST_SCRIPT

for missing_tool in jq yq; do
    tool_dir="$TMP_DIR/missing-$missing_tool"
    mkdir -p "$tool_dir"
    ln -s "$(command -v dirname)" "$tool_dir/dirname"
    case "$missing_tool" in
      jq) ln -s "$(command -v yq)" "$tool_dir/yq" ;;
      yq) ln -s "$(command -v jq)" "$tool_dir/jq" ;;
    esac
    TEST_PATH="$tool_dir"
    if run_hook default; then fail "missing $missing_tool succeeded"; fi
    assert_no_mutation "missing $missing_tool"
    grep -q "$missing_tool is unavailable" "$TMP_DIR/stderr" || fail "missing $missing_tool was not logged"
done
unset TEST_PATH
printf 'ok - missing recipe dependencies fail before mutation\n'

FAKE_STATE=not-fresh
run_hook default || fail "non-fresh workspace failed"
assert_no_mutation "non-fresh workspace"
grep -q 'Skipping Stationary' "$TMP_DIR/stderr" || fail "non-fresh skip was not logged"
unset FAKE_STATE
printf 'ok - non-fresh workspace is skipped\n'

for FAKE_STATE in empty-tabs empty-panes; do
    run_hook default || fail "$FAKE_STATE workspace failed"
    assert_no_mutation "$FAKE_STATE workspace"
    grep -q 'Skipping Stationary' "$TMP_DIR/stderr" || fail "$FAKE_STATE skip was not logged"
done
unset FAKE_STATE
printf 'ok - empty tab and pane arrays are skipped\n'

run_hook default || {
    cat "$TMP_DIR/stderr" >&2
    fail "fresh workspace failed"
}
cat >"$TMP_DIR/expected" <<'EXPECTED'
tab list --workspace w-test
pane list --workspace w-test
tab rename t-root Work
pane rename p-root Agent
pane split --pane p-root --direction right --ratio 0.25 --focus
pane rename p-nvim Nvim
pane split --pane p-nvim --direction down --ratio 0.8 --no-focus
pane rename p-shell2 Shell
tab create --workspace w-test --label Servers --no-focus
pane rename p-server1 Server I
pane split --pane p-server1 --direction right --ratio 0.5 --no-focus
pane rename p-server2 Server II
pane split --pane p-server1 --direction down --ratio 0.5 --no-focus
pane rename p-server3 Server III
pane split --pane p-server2 --direction down --ratio 0.5 --no-focus
pane rename p-server4 Server IV
pane run p-nvim nvim
tab focus t-root
EXPECTED
cmp -s "$TMP_DIR/expected" "$CALLS" || {
    diff -u "$TMP_DIR/expected" "$CALLS" >&2 || true
    fail "fresh workspace calls differ"
}
[ "$(grep -c '^pane run p-nvim nvim$' "$CALLS")" -eq 1 ] || fail "Nvim was not started exactly once"
if grep -E '^(agent start|pane run)' "$CALLS" | grep -v '^pane run p-nvim nvim$' >/dev/null; then
    fail "unexpected command-bearing operation found"
fi
printf 'ok - default recipe creates the exact layout and starts Nvim\n'

FIXTURE_DIR="$TMP_DIR/fixture-plugin"
mkdir -p "$FIXTURE_DIR"
cp "$SCRIPT_DIR/apply-layout.sh" "$FIXTURE_DIR/apply-layout.sh"
sed 's/ratio = 0.25/ratio = 0.20/' "$SCRIPT_DIR/layouts.toml" >"$FIXTURE_DIR/layouts.toml"
TEST_SCRIPT="$FIXTURE_DIR/apply-layout.sh"
run_hook default || fail "custom ratio fixture failed"
grep -q '^pane split --pane p-root --direction right --ratio 0.2 --focus$' "$CALLS" || fail "custom ratio was not interpreted"
unset TEST_SCRIPT
printf 'ok - recipe values control emitted splits\n'

BASE_JSON="$TMP_DIR/base.json"
yq -p toml -o json '.' "$SCRIPT_DIR/layouts.toml" >"$BASE_JSON"

BACKSLASH_PANE_DIR="$TMP_DIR/backslash-pane"
mkdir -p "$BACKSLASH_PANE_DIR"
cp "$SCRIPT_DIR/apply-layout.sh" "$BACKSLASH_PANE_DIR/apply-layout.sh"
jq '
  .layouts.default.tabs.Work.root.pane = "Agent\\t" |
  .layouts.default.tabs.Work.splits[0].source = "Agent\\t" |
  .layouts.default.tabs.Work.splits[1].source = "Agent\\t"
' "$BASE_JSON" | yq -p json -o toml '.' >"$BACKSLASH_PANE_DIR/layouts.toml"
TEST_SCRIPT="$BACKSLASH_PANE_DIR/apply-layout.sh"
run_hook default || fail "literal backslash-t pane source failed"
BACKSLASH_PANE='Agent\t'
grep -Fqx "pane rename p-root $BACKSLASH_PANE" "$CALLS" || fail "literal backslash-t pane label was not preserved"
unset TEST_SCRIPT

BACKSLASH_TAB_DIR="$TMP_DIR/backslash-tab"
mkdir -p "$BACKSLASH_TAB_DIR"
cp "$SCRIPT_DIR/apply-layout.sh" "$BACKSLASH_TAB_DIR/apply-layout.sh"
jq '
  .layouts.default.tabs["Work\\t"] = .layouts.default.tabs.Work |
  del(.layouts.default.tabs.Work) |
  .layouts.default.focus = "Work\\t"
' "$BASE_JSON" | yq -p json -o toml '.' >"$BACKSLASH_TAB_DIR/layouts.toml"
TEST_SCRIPT="$BACKSLASH_TAB_DIR/apply-layout.sh"
run_hook default || fail "literal backslash-t tab focus failed"
BACKSLASH_TAB='Work\t'
grep -Fqx "tab rename t-root $BACKSLASH_TAB" "$CALLS" || fail "literal backslash-t tab label was not preserved"
grep -qx 'tab focus t-root' "$CALLS" || fail "literal backslash-t tab was not focused"
unset TEST_SCRIPT
printf 'ok - literal backslashes survive pane and tab map lookups\n'

FAKE_STATE=repairable
TEST_TAB_ID=t-work
run_hook default --reapply || {
    cat "$TMP_DIR/stderr" >&2
    fail "repairable layout failed"
}
for expected_call in \
    'pane resize --pane p-root --direction left --amount 0.05' \
    'pane resize --pane p-nvim --direction down --amount 0.1' \
    'pane resize --pane p-server1 --direction right --amount 0.1' \
    'pane resize --pane p-server1 --direction up --amount 0.1' \
    'pane resize --pane p-server2 --direction down --amount 0.1' \
    'tab focus t-work' \
    'pane focus --pane p-root --direction right'; do
    grep -Fqx "$expected_call" "$CALLS" || fail "repair omitted: $expected_call"
done
if grep -E '^(tab create|tab close|pane split|pane run)' "$CALLS" >/dev/null; then
    fail "repairable layout was rebuilt"
fi
unset TEST_TAB_ID
unset FAKE_STATE
printf 'ok - repairable layout is fixed without rebuilding\n'

FAKE_STATE=reapply
run_hook default --reapply || {
    cat "$TMP_DIR/stderr" >&2
    fail "reapply mode failed"
}
cat >"$TMP_DIR/expected-reapply" <<'EXPECTED'
tab list --workspace w-test
pane list --workspace w-test
tab create --workspace w-test --cwd /tmp/stationary --label default --no-focus
tab rename t-reapply Work
pane rename p-reapply Agent
pane split --pane p-reapply --direction right --ratio 0.25 --focus
pane rename p-reapply-nvim Nvim
pane split --pane p-reapply-nvim --direction down --ratio 0.8 --no-focus
pane rename p-reapply-shell Shell
tab create --workspace w-test --label Servers --no-focus
pane rename p-server1 Server I
pane split --pane p-server1 --direction right --ratio 0.5 --no-focus
pane rename p-server2 Server II
pane split --pane p-server1 --direction down --ratio 0.5 --no-focus
pane rename p-server3 Server III
pane split --pane p-server2 --direction down --ratio 0.5 --no-focus
pane rename p-server4 Server IV
pane run p-reapply-nvim nvim
tab focus t-reapply
tab close t-root
tab close t-extra
EXPECTED
cmp -s "$TMP_DIR/expected-reapply" "$CALLS" || {
    diff -u "$TMP_DIR/expected-reapply" "$CALLS" >&2 || true
    fail "reapply calls differ"
}
unset FAKE_STATE
printf 'ok - reapply mode rebuilds the workspace\n'

INVALID_DIR="$TMP_DIR/invalid"
mkdir -p "$INVALID_DIR"

cat >"$TMP_DIR/invalid-filters" <<'FILTERS'
document-extra|.extra = true
layouts-empty|.layouts = {}
layout-extra|.layouts.default.extra = true
layout-focus-type|.layouts.default.focus = 1
layout-focus-missing|.layouts.default.focus = "Missing"
tabs-empty|.layouts.default.tabs = {}
tab-extra|.layouts.default.tabs.Work.extra = true
order-type|.layouts.default.tabs.Work.order = "1"
order-gap|.layouts.default.tabs.Servers.order = 3
root-extra|.layouts.default.tabs.Work.root.extra = true
root-missing-pane|del(.layouts.default.tabs.Work.root.pane)
splits-type|.layouts.default.tabs.Work.splits = {}
split-missing-source|del(.layouts.default.tabs.Work.splits[0].source)
direction|.layouts.default.tabs.Work.splits[0].direction = "left"
ratio-type|.layouts.default.tabs.Work.splits[0].ratio = "0.3"
ratio-zero|.layouts.default.tabs.Work.splits[0].ratio = 0
ratio-one|.layouts.default.tabs.Work.splits[0].ratio = 1
duplicate-pane|.layouts.default.tabs.Work.splits[1].pane = "Nvim"
forward-source|.layouts.default.tabs.Work.splits[0].source = "Shell II"
run-empty|.layouts.default.tabs.Work.splits[0].run = ""
run-control|.layouts.default.tabs.Work.splits[0].run = "nvim\nexit"
pane-control|.layouts.default.tabs.Work.splits[0].pane = "Nvim\tbad"
tab-control|.layouts.default.tabs["Work\nbad"] = .layouts.default.tabs.Work | del(.layouts.default.tabs.Work) | .layouts.default.focus = "Work\nbad"
pane-c1-control|.layouts.default.tabs.Work.splits[0].pane = "Nvim\u0080bad"
run-next-line|.layouts.default.tabs.Work.splits[0].run = "nvim\u0085exit"
tab-line-separator|.layouts.default.tabs["Work\u2028bad"] = .layouts.default.tabs.Work | del(.layouts.default.tabs.Work) | .layouts.default.focus = "Work\u2028bad"
layout-paragraph-separator|.layouts["bad\u2029layout"] = .layouts.default
focus-type|.layouts.default.tabs.Work.splits[0].focus = "yes"
multiple-focus|.layouts.default.tabs.Work.root.focus = true
invalid-sibling|.layouts.bad = .layouts.default | .layouts.bad.tabs.Work.splits[0].direction = "left"
FILTERS

while IFS='|' read -r name filter; do
    fixture="$INVALID_DIR/$name"
    mkdir -p "$fixture"
    cp "$SCRIPT_DIR/apply-layout.sh" "$fixture/apply-layout.sh"
    jq "$filter" "$BASE_JSON" | yq -p json -o toml '.' >"$fixture/layouts.toml"
    TEST_SCRIPT="$fixture/apply-layout.sh"
    if run_hook default; then fail "invalid fixture $name succeeded"; fi
    assert_no_mutation "invalid fixture $name"
    grep -q '^notification show Stationary configuration failed ' "$NOTIFICATIONS" || fail "invalid fixture $name sent no notification"
done <"$TMP_DIR/invalid-filters"
unset TEST_SCRIPT

MALFORMED_DIR="$INVALID_DIR/malformed"
mkdir -p "$MALFORMED_DIR"
cp "$SCRIPT_DIR/apply-layout.sh" "$MALFORMED_DIR/apply-layout.sh"
printf '%s\n' '[layouts.default' >"$MALFORMED_DIR/layouts.toml"
TEST_SCRIPT="$MALFORMED_DIR/apply-layout.sh"
if run_hook default; then fail "malformed TOML succeeded"; fi
assert_no_mutation "malformed TOML"
unset TEST_SCRIPT

if run_hook missing; then fail "unknown selector succeeded"; fi
assert_no_mutation "unknown selector"
printf 'ok - invalid documents and selectors fail before mutation\n'

FAKE_FAIL_SPLIT=1
if run_hook default; then fail "forced split failure succeeded"; fi
cat >"$TMP_DIR/expected-failure" <<'EXPECTED'
tab list --workspace w-test
pane list --workspace w-test
tab rename t-root Work
pane rename p-root Agent
pane split --pane p-root --direction right --ratio 0.25 --focus
notification show Stationary failed --body Workspace w-test may have a partial layout. --sound request
EXPECTED
cmp -s "$TMP_DIR/expected-failure" "$CALLS" || {
    diff -u "$TMP_DIR/expected-failure" "$CALLS" >&2 || true
    fail "mutation continued after split failure"
}
grep -q 'Failed to apply Stationary' "$TMP_DIR/stderr" || fail "split failure was not logged"
unset FAKE_FAIL_SPLIT
printf 'ok - mutation failure stops and notifies\n'
