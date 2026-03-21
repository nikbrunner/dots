---
name: dev:finishing-branch
description: "Finish a feature branch -- verify, then choose: merge, PR, keep, or discard."
user-invocable: true
---

# Finishing a Branch

## Step 1: Verify

Run the test suite. If tests fail, **stop here** -- fix first, don't proceed.

## Step 2: Detect Base Branch

Determine `main` or `master` (whichever exists on the remote).

## Step 3: Present Options

Offer exactly these four:

1. **Merge** back to base branch locally
2. **Push & PR** -- push and create a Pull Request
3. **Keep** the branch as-is
4. **Discard** this work

## Step 4: Execute

### Option 1: Merge

```
git checkout <base> → git pull → git merge <branch> → run tests → git branch -d <branch>
```

If worktree exists, clean it up with `git worktree remove`.

### Option 2: Push & PR

```
git push -u origin <branch> → gh pr create --title "..." --body "..."
```

PR body includes a summary and test plan. Report the PR URL.

### Option 3: Keep

Report the branch name and worktree path (if any). Done.

### Option 4: Discard

Require the user to type "discard" to confirm. Then:

```
git checkout <base> → git branch -D <branch>
```

If worktree exists, `git worktree remove --force`.

## Quick Reference

| Option    | Merges | Pushes | Keeps worktree | Cleanup                         |
| --------- | ------ | ------ | -------------- | ------------------------------- |
| Merge     | Yes    | No     | No             | Branch + worktree deleted       |
| Push & PR | No     | Yes    | Yes            | None                            |
| Keep      | No     | No     | Yes            | None                            |
| Discard   | No     | No     | No             | Branch + worktree force-deleted |
