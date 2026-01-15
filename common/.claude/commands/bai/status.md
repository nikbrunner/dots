---
description: Show my Black Atom Industries issues
allowed-tools: ["mcp__linear__list_issues", "mcp__linear__get_issue"]
---

# Black Atom Status

Show issues assigned to me in the Black Atom Industries workspace.

## Arguments

`$ARGUMENTS` - Optional filter (team name or project)

Examples:
- `` (no args) - All my issues
- `Development` - Only Development team issues
- `Black Atom - 1.0` - Only issues in the 1.0 project

## Context

**Teams**: Development, Design, Operations, Website
**Projects**: Black Atom - 1.0 (active), Black Atom - Core Creator (backlog)

## Process

1. Query `mcp__linear__list_issues` with:
   - `assignee: "me"`
   - `includeArchived: false`
   - Apply team/project filter if argument provided

2. Group by status (In Progress → Todo → Backlog)

3. For each issue show:
   - Identifier and title
   - Team and project
   - Priority (P0-P4)
   - Labels if any
   - Blocking/blocked relations if any

## Output Format

```
### In Progress

[DEV-123] Implement theme generator
  Team: Development | Project: Black Atom - 1.0 | P2
  Blocks: DEV-124, DEV-125

### Todo

[DEV-126] Write README
  Team: Development | Project: Black Atom - 1.0 | P3

### Backlog

[DEV-130] Core Creator MVP
  Team: Development | Project: Core Creator | P4
```

## Notes

- Use `get_issue` with `includeRelations: true` to show blocking relationships
- Highlight any blocked issues clearly
