# Phase 5: Close

## When to use

Review phase is complete and I invoke `/dev:flow close`. Claude never auto-triggers this phase.

## Steps

### 1. Ship

Detect base branch (`main` or `master`), then present exactly four options:

| Option            | Merges | Pushes | Cleanup                                      |
| ----------------- | ------ | ------ | -------------------------------------------- |
| **Merge** locally | Yes    | No     | Branch + worktree deleted                    |
| **Push & PR**     | No     | Yes    | `gh pr create` with summary + test plan      |
| **Keep** branch   | No     | No     | Report branch name                           |
| **Discard**       | No     | No     | Require "discard" confirmation, force-delete |

For worktree branches, clean up with `git worktree remove` on merge/discard.

### 2. Close tracked issue

If work is linked to an issue, close it.
If no issue is tracked, skip.

### 3. Knowledge sync

Use `/dev:audit docs` to sync the project's documentation with the latest changes.

## Transition

Done. Back to Phase 1 on the next task.
