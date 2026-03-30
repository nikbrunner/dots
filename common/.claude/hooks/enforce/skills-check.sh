#!/bin/bash
# UserPromptSubmit hook: Smart skill recommendation based on prompt content.
# Reads the user's prompt, matches keywords, and suggests specific skills.
# Falls back to generic reminder if no specific match found.

set -euo pipefail

# Read prompt from stdin JSON
PROMPT=$(cat | jq -r '.prompt // empty' 2>/dev/null || echo "")

# Gather context
CWD=$(pwd)
REPO=$(basename "$CWD")
REPO_OWNER=$(basename "$(dirname "$CWD")")

# Lowercase prompt for matching
prompt_lower=$(echo "$PROMPT" | tr '[:upper:]' '[:lower:]')

# Collect matching skills
matches=()

# dev:flow assess — explicit task start signals (not casual discussion)
if echo "$prompt_lower" | grep -qiE '(^(implement|build|refactor|fix|add|create|migrate|remove|delete|update|upgrade) |lets (start|begin|work on)|i want to (start|begin|work on)|can you (implement|build|fix|add|create))'; then
    matches+=("dev:flow assess — Orient and assess before implementation")
fi

# dev:flow plan — explicit planning requests
if echo "$prompt_lower" | grep -qiE '(^plan |write.*(prd|plan|spec)|break.*(down|into)|create.*(issues|tickets|tasks))'; then
    matches+=("dev:flow plan — Create a plan or PRD")
fi

# dev:util:commit — committing code
if echo "$prompt_lower" | grep -qiE '(^commit|lets commit|create a commit|commit (this|these|the))'; then
    matches+=("dev:util:commit — Commit format and strategy")
fi

# dev:style:tdd — explicit TDD requests
if echo "$prompt_lower" | grep -qiE '(use tdd|red.green.refactor|write.*tests? first|test.driven)'; then
    matches+=("dev:style:tdd — TDD discipline and test strategy")
fi

# dev:flow close — explicit close/ship requests
if echo "$prompt_lower" | grep -qiE '(^(close|ship|finish|wrap up)|lets (close|ship|finish|wrap up)|create a pr|open a pr|merge (this|to))'; then
    matches+=("dev:flow close — Verify, ship, and close")
fi

# dev:audit — explicit audit/review requests
if echo "$prompt_lower" | grep -qiE '(^(audit|review)|run.*(audit|review)|check.*(quality|conventions|a11y|accessibility))'; then
    matches+=("dev:audit — Audit code quality (ui, style, arch, docs)")
fi

# dots:add / dots:remove — dotfiles management
if [[ "$REPO" == "dots" ]]; then
    if echo "$prompt_lower" | grep -qiE '(add.*config|new.*config|symlink|dotfile)'; then
        matches+=("dots:add — Add config to dots")
    fi
    if echo "$prompt_lower" | grep -qiE '(remove.*config|delete.*config|unlink)'; then
        matches+=("dots:remove — Remove config from dots")
    fi
fi

# Build output
if [[ ${#matches[@]} -gt 0 ]]; then
    skill_list=""
    for match in "${matches[@]}"; do
        skill_list="${skill_list}\n  -> ${match}"
    done
    context="SKILL ACTIVATION CHECK — Before responding, invoke the relevant skill(s):\n${skill_list}\n\nACTION: Use the Skill tool BEFORE any response. Current context: repo=${REPO}, owner=${REPO_OWNER}"
else
    context="Skills check: Before responding, scan the available skills list and invoke any relevant skill first. Current context: repo=${REPO}, owner=${REPO_OWNER}, cwd=${CWD}"
fi

# Escape for JSON
context_escaped=$(echo -e "$context" | sed 's/\\/\\\\/g; s/"/\\"/g' | tr '\n' ' ')

printf '{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "%s"
  }
}\n' "$context_escaped"
exit 0
