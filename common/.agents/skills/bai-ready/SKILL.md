---
name: bai-ready
description: Show Black Atom issues ready to work (no blockers)
metadata:
  user-invocable: false
allowed-tools: ["Bash"]
---

# Black Atom Ready

Show issues that are ready to pick up — not blocked by other issues.

## Arguments

Optional repo name filter (`$ARGUMENTS` in Claude Code, or `/skill:bai-ready` args in Pi).

## Context

**Repos**: Discover dynamically via `gh repo list black-atom-industries --json name --jq '.[].name' --limit 100`
**Project**: Black Atom V1 (#7)

Load `about:bai` for GitHub project constants.

## Process

1. Get all assigned open issues:

   ```bash
   gh search issues --assignee=@me --owner=black-atom-industries --state=open --json repository,number,title,labels,url
   ```

2. Filter out issues that have the `state:blocked` label

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

- An issue is "ready" if it does NOT have the `state:blocked` label
- Show blocked issues separately so you know what's waiting
- Prioritize by priority level (Urgent → High → Medium → Low)
