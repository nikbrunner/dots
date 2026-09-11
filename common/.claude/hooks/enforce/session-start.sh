#!/usr/bin/env bash
# SessionStart hook: Tell Claude which repo the session is rooted in.
# Fires on startup, resume, clear, and compact, so the context survives
# compaction in long sessions.

set -euo pipefail

CWD=$(pwd)
REPO=$(basename "$CWD")
REPO_OWNER=$(basename "$(dirname "$CWD")")

jq -n --arg context "Current context: repo=${REPO}, owner=${REPO_OWNER}, cwd=${CWD}" '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: $context
  }
}'
