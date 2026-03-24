#!/usr/bin/env bash
# SessionStart hook: Inject meta-enforcement skill content at session start.
# Fires on startup, resume, clear, and compact — ensures enforcement
# survives context compaction in long sessions.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# Navigate from hooks/enforce/ up to .claude/skills/meta-enforcement/
SKILL_FILE="${SCRIPT_DIR}/../../skills/meta-enforcement/SKILL.md"

if [[ ! -f "$SKILL_FILE" ]]; then
    echo "Warning: meta-enforcement skill not found at $SKILL_FILE" >&2
    exit 0
fi

# Read skill content, strip YAML frontmatter (everything between first --- pair)
skill_content=$(awk 'BEGIN{skip=0} /^---$/{skip++; next} skip<2{next} {print}' "$SKILL_FILE")

# Gather context
CWD=$(pwd)
REPO=$(basename "$CWD")
REPO_OWNER=$(basename "$(dirname "$CWD")")

context_header="Current context: repo=${REPO}, owner=${REPO_OWNER}, cwd=${CWD}"

# JSON-escape content using bash parameter substitution
escape_for_json() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    printf '%s' "$s"
}

escaped_content=$(escape_for_json "$skill_content")
escaped_header=$(escape_for_json "$context_header")

printf '{\n  "hookSpecificOutput": {\n    "hookEventName": "SessionStart",\n    "additionalContext": "%s\\n\\n%s"\n  }\n}\n' "$escaped_content" "$escaped_header"

exit 0
