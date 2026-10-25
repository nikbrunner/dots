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

# Braille blanks pad the group away from the next entry; Herdr trims trailing spaces.
echo "${out}⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
