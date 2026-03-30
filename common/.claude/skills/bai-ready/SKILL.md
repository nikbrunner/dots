---
name: bai:ready
user-invocable: false
description: Show Black Atom issues ready to work (no blockers)
allowed-tools: ["Bash"]
---

# Black Atom Ready

Show issues that are ready to pick up — not blocked by other issues.

## Arguments

`$ARGUMENTS` - Optional filter (repo name)

## Context

**Repos**: .github, core, livery, helm, nvim, ghostty, tmux, zed, wezterm, obsidian, radar.nvim, ui, website
**Project**: Black Atom V1 (#7)

Load `about:bai` for GitHub project constants.

## Process

1. Get all assigned open issues:

   ```bash
   gh search issues --assignee=@me --owner=black-atom-industries --state=open --json repository,number,title,labels,url
   ```

2. Filter out issues that have the `blocked` label

3. Get priority from project data:

   ```bash
   gh project item-list 7 --owner black-atom-industries --format json
   ```

4. Sort by priority (Urgent first)

5. For blocked issues, scan comments for "Blocked by" to show what they're waiting on:
   ```bash
   gh issue view <number> --repo black-atom-industries/<repo> --json comments --jq '.comments[].body'
   ```

## Output Format

```
### Ready to Work

1. [core#50] Finalize naming conventions (Urgent)
   Repo: core
   https://github.com/black-atom-industries/core/issues/50

2. [livery#29] Set up frontend architecture (High)
   Repo: livery | Milestone: v1.0.0
   https://github.com/black-atom-industries/livery/issues/29

### Blocked (for reference)

- [core#53] Fine-tune all themes for V1
  Blocked by: core#50, core#51
  https://github.com/black-atom-industries/core/issues/53
```

## Notes

- An issue is "ready" if it does NOT have the `blocked` label
- Show blocked issues separately so you know what's waiting
- Prioritize by priority level (Urgent → High → Medium → Low)
