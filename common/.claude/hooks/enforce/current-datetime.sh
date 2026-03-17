#!/bin/bash
# UserPromptSubmit hook: Inject current date and time so Claude stays grounded.

DATETIME=$(date '+%Y-%m-%d %H:%M %Z (%A)')

printf '{"hookSpecificOutput": {"hookEventName": "UserPromptSubmit", "additionalContext": "Current date/time: %s"}}\n' "$DATETIME"
exit 0
