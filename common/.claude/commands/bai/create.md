---
description: Create a new Black Atom Industries issue
allowed-tools: ["mcp__linear__create_issue", "mcp__linear__list_teams", "mcp__linear__list_projects", "mcp__linear__list_issue_labels", "mcp__linear__list_issues", "AskUserQuestion"]
---

# Black Atom Create

Create a new issue in the Black Atom Industries workspace.

## Arguments

`$ARGUMENTS` - Issue title and optional details

Examples:
- `Fix theme contrast in dark mode`
- `"Add nvim telescope support" project:"Black Atom - 1.0"`
- `Design new logo for v1 team:Design`

## Context

**Teams** (default: Development):
- Development - Code, features, bugs
- Design - Visual design, UI/UX
- Operations - Releases, infrastructure
- Website - Marketing site

**Projects**:
- Black Atom - 1.0 (active main project)
- Black Atom - Core Creator (backlog)

## Process

1. Parse title from arguments

2. Determine team:
   - Default to **Development** for code/feature work
   - Use **Design** if clearly design-related (logo, visual, UI)
   - Use **Operations** for release/infra work
   - **Push back** if team choice seems wrong for the content

3. Use `AskUserQuestion` tool for missing info:
   - Priority (0-4): 0=none, 1=urgent, 2=high, 3=normal, 4=low
   - Project (suggest Black Atom - 1.0 for most work)
   - Labels (optional)

4. Check for related issues - suggest linking if relevant

5. Create with `mcp__linear__create_issue`:
   - `title`: from arguments
   - `team`: determined team ID
   - `assignee`: "me" (always assign to Nik)
   - `project`: if specified or suggested
   - `priority`: if specified
   - `blocks` / `blockedBy` / `relatedTo`: if dependencies identified

## Output

```
Created issue:
[DEV-127] Fix theme contrast in dark mode
Team: Development | Project: Black Atom - 1.0 | P3
URL: https://linear.app/black-atom-industries/issue/DEV-127
```

## Notes

- Always suggest a project for new issues (usually Black Atom - 1.0)
- If creating multiple related issues, suggest setting up blockedBy relations
- Push back on team choice if it seems mismatched (e.g., code work assigned to Design)
