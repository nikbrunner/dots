---
description: Show Black Atom issues ready to work (no blockers)
allowed-tools: ["mcp__linear__list_issues", "mcp__linear__get_issue"]
---

# Black Atom Ready

Show issues that are ready to pick up - not blocked by other issues.

## Arguments

`$ARGUMENTS` - Optional filter (team or project)

## Context

**Teams**: Development, Design, Operations, Website
**Projects**: Black Atom - 1.0 (active), Black Atom - Core Creator (backlog)

## Process

1. Query `mcp__linear__list_issues` with:
   - `assignee: "me"`
   - `includeArchived: false`
   - Filter to non-completed states

2. For each issue, call `mcp__linear__get_issue` with `includeRelations: true`

3. Filter out issues that have unresolved `blockedBy` relations

4. Sort by priority (P1 before P2, etc.)

## Output Format

```
### Ready to Work

1. [DEV-123] Implement theme generator (P2)
   Team: Development | Project: Black Atom - 1.0
   No blockers

2. [DEV-126] Write README (P3)
   Team: Development | Project: Black Atom - 1.0
   No blockers

### Blocked (for reference)

- [DEV-124] Publish to npm
  Blocked by: DEV-123 (Implement theme generator)
```

## Notes

- An issue is "ready" if it has no unresolved blockedBy relations
- Show blocked issues separately so you know what's waiting
- Prioritize by priority level
