#!/bin/bash
# UserPromptSubmit hook: Remind Claude to check skills before responding.
# Injects a lightweight reminder treated as user-level instruction.

cat <<'EOF'
{"hookSpecificOutput": {"additionalContext": "⚡ Skills check: Before responding, scan the available skills list and invoke any relevant skill first."}}
EOF
