---
description: Close a Black Atom issue
allowed-tools: ["mcp__linear__update_issue", "mcp__linear__create_comment", "mcp__linear__list_issue_statuses", "mcp__linear__get_issue", "AskUserQuestion"]
---

# Black Atom Close

Mark an issue as Done or Canceled.

## Arguments

`$ARGUMENTS` - Issue identifier and optional closing comment

Examples:
- `DEV-123`
- `DEV-123 Completed implementation`
- `DEV-123 canceled: No longer needed`

## Process

1. Parse issue identifier

2. Get issue with `mcp__linear__get_issue` to find its team and current state

3. Get available statuses with `mcp__linear__list_issue_statuses`

4. Determine close type:
   - Default: "Done" (type: completed)
   - If "canceled" in comment: "Canceled" (type: canceled)

5. Update issue status

6. If closing comment provided, add via `mcp__linear__create_comment`

7. Check if this unblocks other issues - mention them

## Output

```
Closed [DEV-123]: Implement theme generator
Status: In Progress → Done

This unblocks:
- [DEV-124] Publish to npm
- [DEV-125] Update documentation
```

or with comment:

```
Closed [DEV-123]: Old feature request
Status: Backlog → Canceled
Comment: "No longer needed after architecture change"
```

## Notes

- Check for issues this was blocking and highlight them
- Use "Canceled" status for won't-do items
- Reference related commits if closing after implementation
