#!/usr/bin/env bash
# UserPromptSubmit hook: Suggest skills that match the shape of the prompt.
# Matches only on prompts that open with an explicit task verb — a mention of
# "commit" mid-sentence is discussion, not a request to commit.
# Emits an empty object when nothing matches, so no context is spent.

set -euo pipefail

prompt_lower=$(jq -r '(.prompt // "") | ascii_downcase' 2>/dev/null || echo "")
REPO=$(basename "$(pwd)")
matches=()

if [[ "$prompt_lower" =~ ^(implement|build|refactor|fix|add|migrate|remove|delete|update|upgrade)\  ||
    "$prompt_lower" =~ ^can\ you\ (implement|build|fix|add)\  ]]; then
    matches+=("Implementation: load the project's convention skills and the matching nbr-conventions topics before editing (typescript, react, css, state, tanstack). Keep selection to the code being changed.")
fi

if [[ "$prompt_lower" =~ ^(use\ tdd|red.green.refactor|write\ tests?\ first|test.driven)([[:space:][:punct:]]|$) ||
    "$prompt_lower" =~ ^(implement|build|fix)\ .*\ (using|with)\ tdd([[:space:][:punct:]]|$) ]]; then
    matches+=("Explicit TDD request: load tdd and follow its red-green-refactor discipline for this task.")
fi

if [[ "$prompt_lower" =~ ^(audit|review)([[:space:]]|$) ||
    "$prompt_lower" =~ ^run\ (an?\ )?(audit|review)([[:space:]]|$) ||
    "$prompt_lower" =~ ^check\ .*(quality|conventions|a11y|accessibility) ]]; then
    matches+=("Review/audit request: load nbr-audit for a convention audit, or code-review for a branch or PR review. Report findings; start implementation or shipping work only when explicitly requested.")
fi

if [[ "$prompt_lower" =~ ^(commit|lets\ commit|let\'s\ commit)([[:space:]]|$) ||
    "$prompt_lower" =~ ^create\ a\ commit([[:space:]]|$) ]]; then
    matches+=("Commit request: load nbr-commit for commit format, selective staging, and approval requirements. Stay within the requested commit scope.")
fi

if [[ "$REPO" == "dots" &&
    ("$prompt_lower" =~ ^(add|create|remove|delete)\ .*config ||
    "$prompt_lower" =~ ^(unlink|symlink)\ ) ]]; then
    matches+=("Dotfiles change: follow this repository's AGENTS.md symlink conventions for the requested config change.")
fi

if [[ ${#matches[@]} -eq 0 ]]; then
    printf '{}\n'
    exit 0
fi

context=$(printf '%s\n' "${matches[@]}" "Reuse matching skills already loaded in this session.")

jq -n --arg context "$context" '{
  hookSpecificOutput: {
    hookEventName: "UserPromptSubmit",
    additionalContext: $context
  }
}'
