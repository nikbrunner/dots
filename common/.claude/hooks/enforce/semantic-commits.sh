#!/bin/bash
# PreToolUse hook: Block git commits without semantic prefixes.
# Receives JSON on stdin with tool_input.command.
# Exit 0 = allow, Exit 2 = block with feedback.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only check git commit commands
if ! echo "$COMMAND" | grep -qE '^git commit'; then
    exit 0
fi

# Extract the commit message from -m flag
# Handles: git commit -m "msg", git commit -m 'msg'
MSG=$(echo "$COMMAND" | sed -n "s/.*-m[[:space:]]*[\"']\(.*\)[\"'].*/\1/p")

# Also try without quotes: git commit -m msg
if [ -z "$MSG" ]; then
    MSG=$(echo "$COMMAND" | sed -n 's/.*-m[[:space:]]*\([^"'"'"'][^[:space:]]*\).*/\1/p')
fi

# Handle heredoc style: -m "$(cat <<'EOF' ... EOF )"
if [ -z "$MSG" ]; then
    MSG=$(echo "$COMMAND" | grep -oE "cat <<['\"]?EOF['\"]?" > /dev/null && echo "$COMMAND" | sed -n '/cat <<.*EOF/,/EOF/p' | grep -v 'cat <<' | grep -v 'EOF' | head -1 | sed 's/^[[:space:]]*//')
fi

# If we can't extract a message, allow it (might be amend without -m, or interactive)
if [ -z "$MSG" ]; then
    exit 0
fi

# Check for semantic prefix
if echo "$MSG" | grep -qE '^\s*(feat|fix|refactor|chore|docs|style|test|ci|perf)(\(.+\))?(!)?:'; then
    exit 0
fi

echo "BLOCKED: Commit message must start with a semantic prefix." >&2
echo "Valid prefixes: feat:, fix:, refactor:, chore:, docs:, style:, test:, ci:, perf:" >&2
echo "Example: feat(nvim): add telescope extension" >&2
echo "Your message was: $MSG" >&2
exit 2
