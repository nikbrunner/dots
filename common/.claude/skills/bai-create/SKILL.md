---
name: bai:create
user-invocable: false
description: Create a new Black Atom Industries issue
allowed-tools:
  [
    "mcp__linear__save_issue",
    "mcp__linear__list_teams",
    "mcp__linear__list_projects",
    "mcp__linear__list_milestones",
    "mcp__linear__list_issue_labels",
    "mcp__linear__list_issue_statuses",
    "mcp__linear__list_issues",
    "AskUserQuestion",
  ]
---

# Black Atom Create

Create a new issue in the Black Atom Industries workspace.

## Arguments

`$ARGUMENTS` - Issue title and optional details

Examples:

- `Fix theme contrast in dark mode`
- `"Add nvim telescope support" project:livery`
- `Design new logo for v1 team:Design`

## Context

**Teams** (default: Development):

- Development — Code, features, bugs
- Design — Visual design, UI/UX
- Operations — Releases, infrastructure
- Website — Marketing site

**Projects**:

- Black Atom - 1.0 — Ship polished theme collections (High, target: 2026-03-31)
- livery — Desktop theme manager app (Medium, in progress)
- helm — TUI session manager for tmux (Low, in progress)
- radar.nvim — Neovim spatial file navigation (Low, in progress)
- Black Atom - Core Creator — Web theme editor (Medium, backlog)

**Statuses** (default: Backlog):

- Backlog — Not yet planned
- Todo — Planned, not started
- In Progress — Actively being worked on
- In Review — Awaiting review
- Done — Completed
- Canceled

**Labels** (common):

- Type: `feat`, `fix`, `refactor`, `chore`, `docs`, `perf`, `ci`
- Repo: `neovim`, `ghostty`, `tmux`, `zed`, `vscode`, `obsidian`, `helm`, `radar.nvim`, `core`, `terminal`, `wezterm`
- Other: `theme-inspiration`

## Process

1. **Parse** title and any inline hints (project, team, labels) from arguments

2. **Determine team**:
   - Default to **Development** for code/feature work
   - Use **Design** if clearly design-related (logo, visual, UI)
   - Use **Operations** for release/infra work
   - **Push back** if team choice seems wrong for the content

3. **Fetch milestones** for the target project using `mcp__linear__list_milestones` so you can suggest one

4. **Ask with `AskUserQuestion`** — combine into a single call with up to 4 questions for what's missing. The user typically provides the project and issue description directly, so only ask for what wasn't given:
   - **Priority** — 1=Urgent, 2=High, 3=Normal (default), 4=Low
   - **Status** — suggest Backlog (default) or Todo if it's planned soon
   - **Milestone** — suggest from fetched milestones if any exist, otherwise skip
   - **Labels** — only if ambiguous; otherwise infer from context (e.g., ghostty-related → `ghostty` + `feat`)

5. **Check for related issues** — search briefly, suggest linking if relevant

6. **Create with `mcp__linear__save_issue`**:
   - `title`: from arguments
   - `team`: determined team
   - `assignee`: "me" (always assign to me)
   - `project`: from answer
   - `priority`: from answer
   - `state`: from answer
   - `milestone`: from answer (if applicable)
   - `labels`: inferred or specified
   - `blocks` / `blockedBy` / `relatedTo`: if dependencies identified

## Output

```
Created issue:
[DEV-127] Fix theme contrast in dark mode
Team: Development | Project: Black Atom - 1.0 | P3 | Backlog
Milestone: Alpha | Labels: feat, ghostty
https://linear.app/black-atom-industries/issue/DEV-127/fix-theme-contrast-in-dark-mode
```

## Notes

- Always suggest a project — pick the most relevant one, don't default blindly
- If creating multiple related issues, suggest setting up blockedBy relations
- Push back on team choice if it seems mismatched (e.g., code work assigned to Design)
- **URL format**: Always show issue links as `https://linear.app/` web URLs (use the `url` field from the API directly)
