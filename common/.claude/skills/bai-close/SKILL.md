---
name: bai:close
user-invocable: false
description: Close a Black Atom issue — Linear context wrapper around dev:close.
allowed-tools: ["mcp__linear__save_issue", "mcp__linear__create_comment", "mcp__linear__list_issue_statuses", "mcp__linear__get_issue", "AskUserQuestion", "Bash"]
---

# Black Atom Close

BAI wrapper around `dev:close`. Runs the generic dev completion flow, then handles Linear issue closure.

## Arguments

`$ARGUMENTS` - Issue identifier and optional closing comment

Examples:
- `DEV-123`
- `DEV-123 Completed implementation`
- `DEV-123 canceled: No longer needed`

## Process

### 1. Run dev:close

Invoke `dev:close` to handle verification and branch shipping (merge/PR/keep/discard).

### 2. Close the Linear issue

1. Parse issue identifier from arguments or branch name
2. Get issue with `mcp__linear__get_issue` to find its team and current state
3. Get available statuses with `mcp__linear__list_issue_statuses`
4. Determine close type:
   - Default: "Done" (type: completed)
   - If "canceled" in comment: "Canceled" (type: canceled)
5. Update issue status via `mcp__linear__save_issue`
6. If closing comment provided, add via `mcp__linear__create_comment`

### 3. Check unblocked issues

Check if this unblocks other issues — mention them.

## Output

```
Closed [DEV-123]: Implement theme generator
Status: In Progress → Done
https://linear.app/black-atom-industries/issue/DEV-123/implement-theme-generator

This unblocks:
- [DEV-124] Publish to npm — https://linear.app/black-atom-industries/issue/DEV-124/publish-to-npm
- [DEV-125] Update documentation — https://linear.app/black-atom-industries/issue/DEV-125/update-documentation
```

## Notes

- **URL format**: Always show issue links as `https://linear.app/` web URLs (use the `url` field from the API directly)
- Use "Canceled" status for won't-do items
- Reference related commits if closing after implementation
- For non-BAI projects, use `dev:close` directly
