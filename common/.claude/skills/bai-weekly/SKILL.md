---
name: bai:weekly
user-invocable: true
description: Weekly Black Atom issue review — board health, staleness, priority check, project progress
allowed-tools:
  [
    "mcp__linear__list_issues",
    "mcp__linear__get_issue",
    "mcp__linear__save_issue",
    "mcp__linear__list_projects",
    "AskUserQuestion",
    "Bash",
    "Grep",
  ]
---

# Black Atom Weekly

Weekly review of all Black Atom Industries issues across projects. Checks board health, flags staleness, and surfaces decisions.

## Arguments

`$ARGUMENTS` - Optional focus (project name or "quick" for summary only)

Examples:

- `` (no args) - Full weekly review
- `livery` - Focus on livery project only
- `quick` - Summary dashboard only, no interactive review

## Context

**Teams**: Development, Design, Operations, Website
**Projects** (active): Black Atom - 1.0, livery, Black Atom - Monitor
**Projects** (low priority): helm, radar.nvim

## Process

### 1. Gather Data

Query `mcp__linear__list_issues` three times (to avoid oversized responses):

- `assignee: "me"`, `state: "In Progress"`, `includeArchived: false`
- `assignee: "me"`, `state: "Todo"`, `includeArchived: false`
- `assignee: "me"`, `state: "Backlog"`, `includeArchived: false`

### 2. Dashboard Summary

Present a high-level overview:

```
## Black Atom Weekly — {date}

| Status | Count |
|-|-|
| In Progress | X |
| Todo | Y |
| Backlog | Z |

### By Project

| Project | In Progress | Todo | Backlog |
|-|-|-|-|
| Black Atom - 1.0 | X | Y | Z |
| livery | X | Y | Z |
| Monitor | X | Y | Z |
| helm | X | Y | Z |
| radar.nvim | X | Y | Z |
| (no project) | X | Y | Z |
```

### 3. Reality Check (Git Cross-Reference)

Before flagging issues, verify Linear state against actual git activity across all Black Atom repos. This catches issues that are done but not updated in Linear, or marked "In Progress" with no real commits.

**Repos to check** (all under `~/repos/black-atom-industries/`):
`core`, `livery`, `helm`, `adapter-neovim`, `adapter-ghostty`, `adapter-tmux`, `adapter-zed`, `adapter-vscode`, `adapter-obsidian`, `adapter-delta`, `adapter-wezterm`, `radar.nvim`

**How to check:**
Use the reality check script:

```bash
# Check specific issues
bai-reality-check DEV-266 DEV-290 DEV-299

# Scan all repos for any issue references (broader, slower)
bai-reality-check
```

**What to look for:**

- Issue marked "In Progress" but no commits in any repo → likely stale, suggest moving to Todo
- Issue marked "Todo"/"Backlog" but has a branch → work has started, likely should be "In Progress"
- Issue marked "Todo"/"Backlog" but has recent commits → likely done or in progress, suggest status update
- Issue has a branch but no recent commits on it → work started but stalled

Present findings as part of the health flags: "Linear says X, but git shows Y"

### 4. Health Flags (enriched by git data)

Automatically flag and highlight:

**Stale "In Progress"** — issues in "In Progress" with no updates in 14+ days.
Action: Ask if they should move back to Todo or if there's unreported progress.

**P1/Urgent in Backlog** — high-priority issues sitting in Backlog.
Action: Should these be promoted to Todo or are they deprioritized?

**Orphaned issues** — issues with no project assignment.
Action: Should they be assigned to a project or canceled?

**Stale blockers** — issues that block others but haven't been updated in 21+ days.
Action: Are these still blocking? Should the relationship be removed?

**Recently created** — issues created in the last 7 days (to confirm they're properly triaged).
Action: Quick confirmation that priority, project, and status are correct.

### 5. Interactive Review (unless "quick" mode)

Include git reality-check findings when presenting issues (e.g., "Linear: Todo, Git: 3 commits on branch last week — should this be In Progress?").

For each flagged issue, use `AskUserQuestion` with options:

- **Keep** — No changes needed
- **Update** — Change status, priority, or project
- **Close** — Done or canceled
- **Skip** — Revisit later

Group flagged issues by category (stale, priority mismatch, etc.) rather than reviewing every single issue.

### 6. Summary

```
## Weekly Summary

Reviewed: X issues
- Kept: X
- Updated: X
- Closed: X
- Skipped: X

Next actions:
- [list any decisions that need follow-up]
```

## Output Format

- Use markdown tables for the dashboard (keep separators minimal: `|-|-|`)
- Show Linear URLs for every issue mentioned
- Group issues by project, then by status within each project
- For the interactive review, batch related issues together in a single AskUserQuestion when possible

## Notes

- **Query pattern**: Don't fetch all issues at once — split by state to avoid oversized responses
- **URL format**: Always show issue links as `https://linear.app/` web URLs
- **Staleness calculation**: Use `updatedAt` field, calculate days since last update
- **Keep it focused**: The weekly is about board hygiene, not deep-diving into implementation details
- **Never modify issue state without explicit confirmation** — always ask via AskUserQuestion before changing status, priority, or any field
