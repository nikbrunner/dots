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

# dev:flow — feature requests, bug reports, implementation tasks
if echo "$prompt_lower" | grep -qiE '(feature|implement|build|refactor|add .*(support|option|ability)|fix|bug|change|improve|enhance|idea|solve|how (could|can|do|should) we|could we|should we|do you have an idea)'; then
    matches+=("dev:flow — Development workflow entry point (orient, propose, build, close)")
fi

# dev:util:commit — committing code
if echo "$prompt_lower" | grep -qiE '(commit|push|ship it|merge|create a pr|pull request)'; then
    matches+=("dev:util:commit — Commit format and strategy")
fi

# dev:style:tdd — testing
if echo "$prompt_lower" | grep -qiE '\b(test|testing|tdd|vitest|jest|spec)\b'; then
    matches+=("dev:style:tdd — TDD discipline and test strategy")
fi

# dev:flow — design discussions (brainstorm is part of flow start)
if echo "$prompt_lower" | grep -qiE '(design|architecture|approach|trade.?off|pressure.?test|what do you think about)'; then
    matches+=("dev:flow start — Orient and brainstorm before implementation")
fi

# dev:flow propose — planning work
if echo "$prompt_lower" | grep -qiE '(plan|roadmap|scope|break.?down|phase|milestone)'; then
    matches+=("dev:flow propose — Design and plan before code")
fi

# dev:flow propose — propose a change (OpenSpec or PRD)
if echo "$prompt_lower" | grep -qiE '(prd|product requirements|requirements doc|spec.*write|write.*spec|propose|proposal|openspec)'; then
    matches+=("dev:flow propose — Propose a change (OpenSpec or PRD)")
fi

# bai:start — BAI project work
if [[ "$REPO_OWNER" == "black-atom-industries" ]]; then
    if echo "$prompt_lower" | grep -qiE '(feature|implement|build|refactor|fix|bug|change|improve|issue|ticket)'; then
        matches+=("bai:start — BAI development entry point (wraps dev:flow with Linear)")
    fi
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
