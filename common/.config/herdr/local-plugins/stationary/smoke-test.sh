#!/bin/sh
set -eu

if [ "${HERDR_ENV:-}" != 1 ]; then
    printf 'smoke test must run inside Herdr\n' >&2
    exit 1
fi

TMP_DIR=
ORDINARY_WORKSPACE_ID=
WORKTREE_WORKSPACE_ID=
WORKTREE_PATH=
WORKTREE_BRANCH=

cleanup() {
    status=$?
    trap - EXIT HUP INT TERM
    set +e
    cleanup_failed=0

    if [ -n "$WORKTREE_WORKSPACE_ID" ]; then
        herdr worktree remove --workspace "$WORKTREE_WORKSPACE_ID" --force >/dev/null 2>&1 || cleanup_failed=1
    fi
    if [ -n "$ORDINARY_WORKSPACE_ID" ]; then
        herdr workspace close "$ORDINARY_WORKSPACE_ID" >/dev/null 2>&1 || cleanup_failed=1
    fi
    if [ -n "$WORKTREE_BRANCH" ] && [ -n "$TMP_DIR" ] && [ -d "$TMP_DIR/repo/.git" ]; then
        git -C "$TMP_DIR/repo" branch -D "$WORKTREE_BRANCH" >/dev/null 2>&1 || cleanup_failed=1
    fi
    if [ -n "$TMP_DIR" ]; then
        rm -rf "$TMP_DIR" || cleanup_failed=1
    fi

    if [ "$cleanup_failed" -ne 0 ]; then
        printf 'smoke cleanup failed\n' >&2
        exit 1
    fi
    exit "$status"
}
trap cleanup EXIT HUP INT TERM

TMP_DIR=$(mktemp -d)
REPO_PATH="$TMP_DIR/repo"
WORKTREE_PATH="$TMP_DIR/worktree"
WORKTREE_BRANCH=stationary-smoke
mkdir -p "$REPO_PATH"
git -C "$REPO_PATH" init -q
git -C "$REPO_PATH" config user.name "Herdr Smoke Test"
git -C "$REPO_PATH" config user.email "herdr-smoke@example.invalid"
printf 'smoke\n' >"$REPO_PATH/README.md"
git -C "$REPO_PATH" add README.md
git -C "$REPO_PATH" commit -qm initial

RESULT=$(herdr workspace create --cwd "$REPO_PATH" --label stationary-smoke-ordinary --no-focus)
ORDINARY_WORKSPACE_ID=$(printf '%s\n' "$RESULT" | jq -er '.result.workspace.workspace_id')

RESULT=$(herdr worktree create --cwd "$REPO_PATH" --branch "$WORKTREE_BRANCH" \
    --base HEAD --path "$WORKTREE_PATH" --label stationary-smoke-worktree --no-focus)
WORKTREE_WORKSPACE_ID=$(printf '%s\n' "$RESULT" | jq -er '.result.workspace.workspace_id')

layout_has_exact_labels() {
    tabs=$1
    panes=$2
    jq -en --argjson tabs "$tabs" --argjson panes "$panes" '
    $tabs.result.tabs as $tabs |
    $panes.result.panes as $panes |
    ($tabs | map(select(.label == "Work")) | if length == 1 then .[0].tab_id else null end) as $work_id |
    ($tabs | map(select(.label == "Servers")) | if length == 1 then .[0].tab_id else null end) as $servers_id |
    ([ $tabs[].label ] | sort) == ["Servers", "Work"] and
    ([ $panes[].label ] | sort) ==
      ["Agent", "Nvim", "Server I", "Server II", "Server III", "Server IV", "Shell I", "Shell II"] and
    ([ $panes[] | select(.tab_id == $work_id) | .label ] | sort) ==
      ["Agent", "Nvim", "Shell I", "Shell II"] and
    ([ $panes[] | select(.tab_id == $servers_id) | .label ] | sort) ==
      ["Server I", "Server II", "Server III", "Server IV"]
  ' >/dev/null
}

wait_for_layout() {
    workspace_id=$1
    attempt=0
    while [ "$attempt" -lt 40 ]; do
        tabs=$(herdr tab list --workspace "$workspace_id")
        panes=$(herdr pane list --workspace "$workspace_id")
        if layout_has_exact_labels "$tabs" "$panes"; then
            return 0
        fi
        attempt=$((attempt + 1))
        sleep 0.25
    done
    printf 'layout timed out for workspace %s\n' "$workspace_id" >&2
    return 1
}

process_is_idle() {
    herdr pane process-info --pane "$1" | jq -e '
    .result.process_info as $process |
    ($process.foreground_processes == []) or
    (($process.foreground_processes | length) == 1 and
     $process.foreground_processes[0].pid == $process.shell_pid)
  ' >/dev/null
}

process_is_nvim() {
    herdr pane process-info --pane "$1" | jq -e '
    .result.process_info.foreground_processes as $processes |
    ($processes | length) == 1 and
    ($processes[0] |
      .name == "nvim" or
      .argv0 == "nvim" or
      (.argv0 | endswith("/nvim")))
  ' >/dev/null
}

processes_match_layout() {
    panes=$1
    while IFS='	' read -r pane_id label; do
        case "$label" in
        Nvim) process_is_nvim "$pane_id" || return 1 ;;
        *) process_is_idle "$pane_id" || return 1 ;;
        esac
    done <<EOF
$(printf '%s\n' "$panes" | jq -r '.result.panes[] | [.pane_id, .label] | @tsv')
EOF
}

wait_for_expected_processes() {
    workspace_id=$1
    attempt=0
    while [ "$attempt" -lt 40 ]; do
        panes=$(herdr pane list --workspace "$workspace_id")
        if processes_match_layout "$panes"; then
            return 0
        fi
        attempt=$((attempt + 1))
        sleep 0.25
    done
    printf 'pane processes did not match the layout for workspace %s\n' "$workspace_id" >&2
    return 1
}

verify_layout() {
    workspace_id=$1
    tabs=$(herdr tab list --workspace "$workspace_id")
    panes=$(herdr pane list --workspace "$workspace_id")

    layout_has_exact_labels "$tabs" "$panes"

    work_tab_id=$(printf '%s\n' "$tabs" | jq -er '.result.tabs[] | select(.label == "Work") | .tab_id')
    servers_tab_id=$(printf '%s\n' "$tabs" | jq -er '.result.tabs[] | select(.label == "Servers") | .tab_id')
    herdr workspace get "$workspace_id" | jq -e --arg id "$work_tab_id" '
    .result.workspace.active_tab_id == $id
  ' >/dev/null

    work_pane_id=$(printf '%s\n' "$panes" | jq -er --arg id "$work_tab_id" '.result.panes[] | select(.tab_id == $id) | .pane_id' | head -n 1)
    nvim_pane_id=$(printf '%s\n' "$panes" | jq -er --arg id "$work_tab_id" '.result.panes[] | select(.tab_id == $id and .label == "Nvim") | .pane_id')
    servers_pane_id=$(printf '%s\n' "$panes" | jq -er --arg id "$servers_tab_id" '.result.panes[] | select(.tab_id == $id) | .pane_id' | head -n 1)
    work_layout=$(herdr pane layout --pane "$work_pane_id")
    servers_layout=$(herdr pane layout --pane "$servers_pane_id")

    printf '%s\n' "$work_layout" | jq -e --arg nvim_id "$nvim_pane_id" '
    def near($n): ((. - $n) | fabs) < 0.001;
    .result.layout as $layout |
    $layout.splits as $s |
    $layout.focused_pane_id == $nvim_id and
    ($s | length) == 3 and
    ([ $s[] | select(.direction == "right" and (.ratio | near(0.25))) ] | length) == 1 and
    ([ $s[] | select(.direction == "down" and (.ratio | near(0.65))) ] | length) == 1 and
    ([ $s[] | select(.direction == "down" and (.ratio | near(0.80))) ] | length) == 1
  ' >/dev/null
    printf '%s\n' "$servers_layout" | jq -e '
    def near($n): ((. - $n) | fabs) < 0.001;
    .result.layout.splits as $s |
    ($s | length) == 3 and
    ([ $s[] | select(.direction == "right" and (.ratio | near(0.50))) ] | length) == 1 and
    ([ $s[] | select(.direction == "down" and (.ratio | near(0.50))) ] | length) == 2
  ' >/dev/null

    processes_match_layout "$panes"
}

wait_for_layout "$ORDINARY_WORKSPACE_ID"
wait_for_layout "$WORKTREE_WORKSPACE_ID"
wait_for_expected_processes "$ORDINARY_WORKSPACE_ID"
wait_for_expected_processes "$WORKTREE_WORKSPACE_ID"
verify_layout "$ORDINARY_WORKSPACE_ID"
verify_layout "$WORKTREE_WORKSPACE_ID"
printf 'ok - ordinary and worktree workspaces received the Stationary layout and started Nvim\n'
