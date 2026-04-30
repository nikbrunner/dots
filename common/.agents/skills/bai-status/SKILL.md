---
name: bai-status
description: Show my Black Atom Industries issues
metadata:
  user-invocable: false
allowed-tools: ["Bash"]
---

# Black Atom Status

Show issues assigned to me across the Black Atom Industries GitHub org.

## Arguments

Optional repo name filter (`$ARGUMENTS` in Claude Code, or `/skill:bai-status` args in Pi).

Examples:

- `` (no args) - All my issues
- `core` - Only core repo issues
- `livery` - Only livery repo issues

## Context

**Repos**: .github, core, livery, helm, nvim, ghostty, tmux, zed, wezterm, obsidian, radar.nvim, ui, website
**Project**: Black Atom V1 (#7)

Load `about:bai` for GitHub project constants (IDs, field values).

## Process

1. Query issues via one of:

   ```bash
   # All project issues with status/priority
   gh project item-list 7 --owner black-atom-industries --format json

   # Or cross-repo search for assigned issues
   gh search issues --assignee=@me --owner=black-atom-industries --state=open --json repository,number,title,state,labels,url
   ```

2. Apply repo filter if argument provided

3. Group by status (In Progress → In Review → Todo)

4. For each issue show:
   - Repo and number (e.g., `core#50`)
   - Title
   - Priority (Urgent/High/Medium/Low)
   - Labels if any
   - Whether it has `state:blocked` label

## Output Format

```
### In Progress

[core#52] Add label/displayName as a property on ThemeMeta
  Repo: core | Priority: Medium
  https://github.com/black-atom-industries/core/issues/52

### Todo

[livery#29] Set up frontend architecture
  Repo: livery | Priority: High | Milestone: v1.0.0
  https://github.com/black-atom-industries/livery/issues/29

[core#50] Finalize naming conventions
  Repo: core | Priority: Urgent | state:blocked
  https://github.com/black-atom-industries/core/issues/50
```

## Notes

- Use `gh project item-list 7` for the richest data (includes status and priority fields)
- Highlight blocked issues (those with `state:blocked` label) clearly
- **URL format**: `https://github.com/black-atom-industries/<repo>/issues/<number>`
