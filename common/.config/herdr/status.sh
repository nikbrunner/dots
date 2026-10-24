#!/bin/sh
# Tab bar entry: active workspace name and the focused pane's branch, plus the worktree when it sits in a linked one.
# Runs under /bin/sh -lc without mise on PATH, so no jq.

herdr=${HERDR_BIN_PATH:-herdr}
out=$("$herdr" workspace get "$HERDR_ACTIVE_WORKSPACE_ID" 2>/dev/null |
    sed -n 's/.*"label":"\([^"]*\)".*/\1/p')
label=$out

cwd=$HERDR_ACTIVE_PANE_CWD
if [ -n "$cwd" ]; then
    branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
    [ -n "$branch" ] && out="$out  $branch"

    git_dir=$(git -C "$cwd" rev-parse --absolute-git-dir 2>/dev/null)
    common_dir=$(cd "$cwd" 2>/dev/null && cd "$(git rev-parse --git-common-dir 2>/dev/null)" 2>/dev/null && pwd -P)
    if [ -n "$git_dir" ] && [ "$git_dir" != "$common_dir" ]; then
        worktree=$(basename "$(git -C "$cwd" rev-parse --show-toplevel)")
        case $worktree in
        "$label" | "$branch") out="$out ⎇" ;;
        *) out="$out ⎇ $worktree" ;;
        esac
    fi
fi

echo "$out"
