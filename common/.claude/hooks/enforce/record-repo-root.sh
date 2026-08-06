#!/usr/bin/env bash
# Note which repo this session's directory belongs to, so a worktree can still
# be traced back to its source repo after being deleted. Fires on SessionStart
# and Stop; recording is idempotent. See tools/bic.

command -v bic >/dev/null 2>&1 || exit 0
bic record 2>/dev/null || true
exit 0
