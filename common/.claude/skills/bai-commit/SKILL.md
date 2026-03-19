---
name: bai:commit
user-invocable: false
description: Use when about to create a git commit in a Black Atom Industries repo and a Linear issue identifier is available in context (branch name, conversation, or recent issue lookup)
allowed-tools: ["Bash", "mcp__linear__get_issue", "mcp__linear__save_issue", "mcp__linear__list_issue_statuses", "AskUserQuestion"]
---

# Black Atom Commit

When committing in a BAI repo, include the issue ticket number in the commit message and offer to update the ticket status afterward.

## Issue Detection

Check in order:
1. **Branch name** — parse with `git branch --show-current`; look for pattern `[A-Z]+-[0-9]+` (e.g., `dev/DEV-123-add-theme-generator` → `DEV-123`)
2. **Conversation context** — issue mentioned by user or from a recent `bai:*` skill invocation
3. **Not found** — commit normally without a ticket reference

## Commit Message Format

Append the issue identifier in brackets at the end of the subject line:

```
feat(theme): add jpn-koyo-yoru colorscheme DEV-123
fix(adapter): correct contrast ratio for bg-subtle DEV-123
chore(deps): update black-atom-core to v2.1.0 DEV-123
```

Keep the existing semantic format (`type(scope): description`) — the ticket tag is additive only.

## After Committing

Ask:

> Commit done. Want me to update **DEV-123** on Linear? (e.g., mark In Progress → In Review, or Done)

- If yes: use `bai:update` or `bai:close` as appropriate
- If no: done

## Notes

- Never invent or guess a ticket number — only use one if clearly present in context
- Do not change the commit message structure, only append `ISSUE-ID`
- Linear automatically links commits containing its identifiers, so the format must be exact
