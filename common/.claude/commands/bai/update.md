---
description: Update a Black Atom issue (status, labels, relations, etc.)
allowed-tools: ["mcp__linear__update_issue", "mcp__linear__create_comment", "mcp__linear__list_issue_statuses", "mcp__linear__get_issue", "mcp__linear__list_teams", "mcp__linear__list_issues", "AskUserQuestion"]
---

# Black Atom Update

Update an issue's status, add comments, manage relations, or change metadata.

## Arguments

`$ARGUMENTS` - Issue identifier and what to update

Examples:
- `DEV-123 to In Progress`
- `DEV-123 comment: Started working on this`
- `DEV-123 priority 2`
- `DEV-123 blocks DEV-124`
- `DEV-123 project "Black Atom - 1.0"`

## Context

**Status workflow** (Development team):
- Backlog → Todo → In Progress → In Review → Done

**Teams**: Development, Design, Operations, Website

## Process

1. Parse issue identifier (e.g., "DEV-123")

2. Get current issue state with `mcp__linear__get_issue` (includeRelations: true)

3. Determine update type and execute:

   **Status change** ("to [status]"):
   - Get team's available statuses
   - Find matching status (case-insensitive)
   - Update issue

   **Comment** ("comment: [text]"):
   - Create comment via `mcp__linear__create_comment`

   **Priority** ("priority [0-4]"):
   - Update priority field

   **Relations** ("blocks/blockedBy/relatedTo [issue]"):
   - Get current relations
   - Add new relation (remember: replaces all, so include existing)
   - Update issue

   **Project** ("project [name]"):
   - Update project assignment

   **Labels** ("label [name]"):
   - Add label to issue

4. Confirm what was changed

## Output

```
Updated [DEV-123]:
Status: Todo → In Progress
```

or

```
Updated [DEV-123]:
Now blocks: DEV-124, DEV-125
```

## Notes

- Relations are REPLACED not appended - always include existing relations when adding new ones
- Show current state before and after for clarity
