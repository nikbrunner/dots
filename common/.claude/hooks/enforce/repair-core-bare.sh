#!/usr/bin/env bash
# Claude Code's worktree handling can set core.bare=true in a normal repo's shared config.
# https://github.com/anthropics/claude-code/issues/58345
# https://github.com/anthropics/claude-code/issues/69802

common=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || exit 0
[ "$(basename "$common")" = .git ] || exit 0
[ "$(git config --file "$common/config" --get core.bare)" = true ] || exit 0
git config --file "$common/config" core.bare false
echo "Reset core.bare=false in $common/config" >&2
exit 0
