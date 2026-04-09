---
name: bai-weekly
user-invocable: true
description: Weekly Black Atom issue review — board health, staleness, priority check, project progress
allowed-tools: ["Bash", "Grep", "AskUserQuestion"]
---

# Black Atom Weekly

Weekly review of all Black Atom Industries issues across repos. Checks board health, flags staleness, and surfaces decisions.

## Arguments

`$ARGUMENTS` - Optional focus (repo name or "quick" for summary only)

Examples:

- `` (no args) - Full weekly review
- `livery` - Focus on livery repo only
- `quick` - Summary dashboard only, no interactive review

## Context

**Repos**: .github, core, livery, helm, nvim, ghostty, tmux, zed, wezterm, obsidian, radar.nvim, ui, website
**Project**: Black Atom V1 (#7)

Load `about:bai` for GitHub project constants.

## Process

### 1. Gather Data

Query all project issues in one call:

```bash
gh project item-list 7 --owner black-atom-industries --format json
```

### 2. Dashboard Summary

```
## Black Atom Weekly — {date}

| Status | Count |
|-|-|
| In Progress | X |
| In Review | Y |
| Todo | Z |

### By Repo

| Repo | In Progress | Todo | Total |
|-|-|-|-|
| core | X | Y | Z |
| livery | X | Y | Z |
| helm | X | Y | Z |
| .github | X | Y | Z |
```

### 3. Reality Check (Git Cross-Reference)

Verify GitHub issue state against actual git activity across BAI repos at `~/repos/black-atom-industries/`.

**What to look for:**

- Issue "In Progress" but no commits → likely stale, suggest Todo
- Issue "Todo" but has a branch → work started, suggest In Progress
- Issue has a branch but no recent commits → stalled

Present findings: "GitHub says X, but git shows Y"

### 4. Health Flags

**Stale "In Progress"** — no updates in 14+ days. Ask: move to Todo or unreported progress?

**Urgent/High in Todo** — high-priority issues sitting idle. Promote or deprioritize?

**Stale blockers** — `state:blocked` label or native `blockedBy` relationships with no updates in 21+ days. Still blocked?

**Recently created** — last 7 days. Confirm triage is correct.

### 5. Interactive Review (unless "quick" mode)

For each flagged issue, use `AskUserQuestion`:

- **Keep** — No changes
- **Update** — Change status, priority, or type
- **Close** — Done or canceled
- **Skip** — Revisit later

Group by category, not one-by-one.

### 6. Summary

```
## Weekly Summary

Reviewed: X issues
- Kept: X
- Updated: X
- Closed: X
- Skipped: X

Next actions:
- [decisions needing follow-up]
```

## Notes

- Use `gh project item-list 7` for the primary data source
- **Staleness**: `gh issue view --json updatedAt`
- Keep it focused — board hygiene, not implementation details
- **Never modify issue state without explicit confirmation**
