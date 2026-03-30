---
name: bai:review
user-invocable: false
description: Review and clean up Black Atom issues
allowed-tools: ["Bash", "AskUserQuestion"]
---

# Black Atom Review

Review active issues to re-evaluate priorities, close stale items, and clean up.

## Arguments

`$ARGUMENTS` - Optional filter (repo name or search term)

Examples:

- `` (no args) - Review all active issues
- `core` - Review core repo issues only
- `livery` - Review livery repo issues
- `theme` - Review issues with "theme" in title

## Context

**Repos**: .github, core, livery, helm, nvim, ghostty, tmux, zed, wezterm, obsidian, radar.nvim, ui, website
**Project**: Black Atom V1 (#7)

Load `about:bai` for GitHub project constants.

## Process

1. Fetch active issues:

   ```bash
   gh project item-list 7 --owner black-atom-industries --format json
   ```

2. For each issue, present for review:

   ```
   [core#50] Finalize naming conventions
   Repo: core | Status: Todo | Priority: Urgent | Updated: 2 weeks ago
   Blocked: No
   https://github.com/black-atom-industries/core/issues/50

   Description snippet...

   Actions: [Keep] [Update] [Close] [Skip]
   ```

3. Use `AskUserQuestion` for each issue:
   - **Keep**: No changes
   - **Update**: Change status, priority, or add comment
   - **Close**: `gh issue close`
   - **Skip**: Come back later

4. After all issues, provide summary

## Flags

Highlight issues that:

- Have no updates in 30+ days (stale) — check `updatedAt`
- Have `blocked` label (high impact if they block others)
- Are In Progress but seem stuck
- Have unclear descriptions

## Output Summary

```
Review complete:
- Kept: 3
- Updated: 2 (priorities adjusted)
- Closed: 4 (2 done, 2 canceled)
- Skipped: 1
```

## Notes

- **Never modify issue state without explicit confirmation** — always ask via AskUserQuestion
