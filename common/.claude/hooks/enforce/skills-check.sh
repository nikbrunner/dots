#!/bin/bash
# UserPromptSubmit hook: Remind Claude to check skills before responding.
# Injects working directory and repo context so Claude can correctly
# evaluate which skills apply (e.g. bai:commit only for BAI repos).

CWD=$(pwd)
REPO=$(basename "$CWD")
REPO_OWNER=$(basename "$(dirname "$CWD")")

printf '{"hookSpecificOutput": {"hookEventName": "UserPromptSubmit", "additionalContext": "⚡ Skills check: Before responding, scan the available skills list and invoke any relevant skill first. Current context: repo=%s, owner=%s, cwd=%s"}}\n' \
    "$REPO" "$REPO_OWNER" "$CWD"
exit 0
