#!/bin/bash
# PreToolUse hook: Block git commits without semantic prefixes.
# Receives JSON on stdin with tool_input.command.
# Exit 0 = allow, Exit 2 = block with feedback.

INPUT=$(cat)
COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')

# Only check git commit commands
if ! printf '%s' "$COMMAND" | head -1 | grep -qE '^git commit'; then
    exit 0
fi

# Strategy: extract the first meaningful line of the commit message.
# Supports: -m "msg", -m 'msg', -m msg, and heredoc style -m "$(cat <<'EOF'\n...\nEOF\n)"
MSG=""

# Try heredoc: look for first non-blank line after the heredoc delimiter
if printf '%s' "$COMMAND" | grep -q "cat <<"; then
    MSG=$(printf '%s\n' "$COMMAND" | sed -n "/cat <<['\"]\\{0,1\\}EOF['\"]\\{0,1\\}/,/^[[:space:]]*EOF/{/cat <</d;/^[[:space:]]*EOF/d;p;}" | sed '/^[[:space:]]*$/d' | head -1 | sed 's/^[[:space:]]*//')
fi

# Try single-line -m "msg" or -m 'msg'
if [ -z "$MSG" ]; then
    MSG=$(printf '%s' "$COMMAND" | head -1 | sed -n "s/.*-m[[:space:]]*[\"']\(.*\)[\"'].*/\1/p")
fi

# Try -m msg (no quotes)
if [ -z "$MSG" ]; then
    MSG=$(printf '%s' "$COMMAND" | head -1 | sed -n 's/.*-m[[:space:]]*\([^"'"'"'][^[:space:]]*\).*/\1/p')
fi

# If we can't extract a message, allow it (might be amend without -m, or interactive)
if [ -z "$MSG" ]; then
    exit 0
fi

# Check for semantic prefix
if printf '%s' "$MSG" | grep -qE '^\s*(feat|fix|refactor|chore|docs|style|test|ci|perf)(\(.+\))?(!)?:'; then
    exit 0
fi

echo "BLOCKED: Commit message must start with a semantic prefix." >&2
echo "Valid prefixes: feat:, fix:, refactor:, chore:, docs:, style:, test:, ci:, perf:" >&2
echo "Example: feat(nvim): add telescope extension" >&2
echo "Your message was: $MSG" >&2
exit 2
