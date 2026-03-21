---
name: bai:commit
user-invocable: false
description: BAI wrapper around dev:commit — appends Linear issue ID and offers status update afterward.
allowed-tools: ["Bash", "mcp__linear__get_issue", "mcp__linear__save_issue", "mcp__linear__list_issue_statuses", "AskUserQuestion"]
---

# Black Atom Commit

BAI wrapper around `dev:commit`. Adds Linear issue tracking to the commit workflow.

## Before Committing: Detect Issue

Check in order:
1. **Branch name** — parse with `git branch --show-current`; look for pattern `[A-Z]+-[0-9]+` (e.g., `feature/dev-123-add-theme-generator` → `DEV-123`)
2. **Conversation context** — issue mentioned by user or from a recent `bai:*` skill invocation
3. **Not found** — proceed without a ticket reference

## Commit

Follow `dev:commit` for the commit itself. Append the issue identifier at the end of the subject line:

```
feat(theme): add jpn-koyo-yoru colorscheme DEV-123
fix(adapter): correct contrast ratio for bg-subtle DEV-123
```

The ticket tag is additive — don't change the `type(scope): description` structure.

## After Committing

Ask:

> Commit done. Want me to update **DEV-123** on Linear? (e.g., mark In Progress → In Review, or Done)

- If yes: use `bai:update` or `bai:close` as appropriate
- If no: done

## Notes

- Never invent or guess a ticket number — only use one if clearly present in context
- Linear automatically links commits containing its identifiers, so the format must be exact
- Prefer `shiplog commit --smart --yes` for AI-generated commit messages — append issue ID to the result
