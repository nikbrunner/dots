---
description: Review and clean up Black Atom issues
allowed-tools: ["mcp__linear__list_issues", "mcp__linear__get_issue", "mcp__linear__update_issue", "mcp__linear__create_comment", "mcp__linear__list_issue_statuses", "AskUserQuestion"]
---

# Black Atom Review

Review active issues to re-evaluate priorities, close stale items, and clean up.

## Arguments

`$ARGUMENTS` - Optional filter (team, project, or search term)

Examples:
- `` (no args) - Review all active issues
- `Development` - Review Development team issues only
- `Black Atom - 1.0` - Review issues in the 1.0 project
- `theme` - Review issues with "theme" in title/description

## Context

**Teams**: Development, Design, Operations, Website
**Projects**: Black Atom - 1.0 (active), Black Atom - Core Creator (backlog)

## Process

1. Fetch active issues with `mcp__linear__list_issues`:
   - `assignee: "me"`
   - `includeArchived: false`
   - Apply filter if argument provided

2. Get full details for each with `mcp__linear__get_issue` (includeRelations: true)

3. For each issue, present for review:
   ```
   [DEV-123] Issue title
   Team: Development | Project: Black Atom - 1.0
   Status: In Progress | Priority: P2 | Created: 2 weeks ago
   Relations: Blocks DEV-124, DEV-125

   Description snippet...

   Actions: [Keep] [Update] [Close] [Skip]
   ```

4. Use `AskUserQuestion` tool for each issue:
   - **Keep**: No changes
   - **Update**: Change status, priority, relations, or add comment
   - **Close**: Mark done or canceled with reason
   - **Skip**: Come back later

5. After all issues, provide summary

## Review Prompts

For each issue ask:
- Is this still relevant to Black Atom v1 goals?
- Is the priority accurate?
- Are the blocking relations still correct?
- Should this be closed or moved to a different project?

## Flags

Highlight issues that:
- Have no updates in 30+ days (stale)
- Are blocking other issues (high impact)
- Are in "In Progress" but seem stuck
- Have unclear descriptions

## Output Summary

```
Review complete:
- Kept: 3
- Updated: 2 (priorities adjusted)
- Closed: 4 (2 done, 2 canceled)
- Skipped: 1
```
