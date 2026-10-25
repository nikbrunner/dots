#!/bin/sh
# Tab bar entry: active workspace@branch, plus the worktree when the focused pane sits in a linked one,
# then helm-herdr's jump-back workspace when there is one.
# Runs under /bin/sh -lc without mise on PATH, so no jq.

herdr=${HERDR_BIN_PATH:-herdr}
label=$("$herdr" workspace get "$HERDR_ACTIVE_WORKSPACE_ID" 2>/dev/null |
    sed -n 's/.*"label":"\([^"]*\)".*/\1/p')
out=$label

cwd=$HERDR_ACTIVE_PANE_CWD
if [ -n "$cwd" ]; then
    branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
    [ -n "$branch" ] && out="$out@$branch"

    git_dir=$(git -C "$cwd" rev-parse --absolute-git-dir 2>/dev/null)
    common_dir=$(cd "$cwd" 2>/dev/null && cd "$(git rev-parse --git-common-dir 2>/dev/null)" 2>/dev/null && pwd -P)
    if [ -n "$git_dir" ] && [ "$git_dir" != "$common_dir" ]; then
        worktree=$(basename "$(git -C "$cwd" rev-parse --show-toplevel)")
        case $worktree in
        "$label" | "$branch") out="$out 󰙅" ;;
        *) out="$out 󰙅 $worktree" ;;
        esac
    fi
fi

last=$("$(dirname "$0")/helm-last.sh")
[ -n "$last" ] && out="$out   $last"

# Braille blanks pad the group toward the middle of the tab bar, down to none when space is short;
# Herdr trims trailing spaces. 40 is roughly the width of the entries to the right.
width=$("$(dirname "$0")/tab-width.sh")
pad=$((width / 2 - 40 - $(printf %s "$out" | wc -m) / 2))
[ "$pad" -lt 0 ] && pad=0
gap=$(
    i=0
    while [ $i -lt $pad ]; do
        printf '⠀'
        i=$((i + 1))
    done
)

echo "${out}${gap}"
