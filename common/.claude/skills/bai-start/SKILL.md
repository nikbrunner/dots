---
name: bai:start
user-invocable: false
description: Start working on a Black Atom issue — Linear context wrapper around dev:start.
allowed-tools: ["mcp__linear__list_issues", "mcp__linear__get_issue", "mcp__linear__save_issue", "mcp__linear__list_issue_statuses", "mcp__linear__create_comment", "AskUserQuestion", "Bash"]
---

# Black Atom Start

BAI wrapper around `dev:start`. Handles Linear issue management, then delegates to the generic dev pipeline.

## Arguments

`$ARGUMENTS` - Issue identifier (optional)

Examples:
- `DEV-123`
- `` (no args) — show ready issues to pick from

## Process

### 1. Identify the issue

**If argument provided:** Get issue with `mcp__linear__get_issue` (includeRelations: true)

**If no argument:** Run the `bai:ready` logic to find unblocked issues assigned to me, then present them with `AskUserQuestion` for selection.

### 2. Validate

- Confirm issue is not already "In Progress" or "Done"
- Check for unresolved `blockedBy` relations — warn if blocked

### 3. Set status to In Progress

- Get team statuses via `mcp__linear__list_issue_statuses`
- Find "In Progress" status
- Update issue via `mcp__linear__save_issue`

### 4. Create feature branch

Derive branch name from the issue:

```
feature/<identifier-lowercase>-<slugified-title>
```

Example: `DEV-123 Implement theme generator` → `feature/dev-123-implement-theme-generator`

Rules:
- Lowercase everything
- Replace spaces/special chars with hyphens
- Truncate slug to keep branch name reasonable (~60 chars max)
- Branch from current main/master

Use `shiplog branch --smart --yes` with the issue title as input, or create manually:

```bash
git checkout main && git pull && git checkout -b feature/<branch-name>
```

### 5. Route via dev:start

With the issue context now established (branch created, status set), invoke `dev:start` to assess scope and route to the appropriate pipeline depth. Pass the issue title and description as context for scope assessment.

### 6. Confirm

Show summary:

```
Started [DEV-123]: Implement theme generator
Status: Todo → In Progress
Branch: feature/dev-123-implement-theme-generator
https://linear.app/black-atom-industries/issue/DEV-123/implement-theme-generator
Pipeline: [scope] → [routed skills]
```

If blocked:

```
⚠ [DEV-123] is blocked by:
  - [DEV-120] Set up CI pipeline (In Progress)

Start anyway? (issue will be set to In Progress despite blockers)
```

## Notes

- Always branch from an up-to-date main/master
- **URL format**: Always show issue links as `https://linear.app/` web URLs (use the `url` field from the API directly)
- If the branch already exists, ask whether to check it out instead of creating
- For non-BAI projects, use `dev:start` directly
