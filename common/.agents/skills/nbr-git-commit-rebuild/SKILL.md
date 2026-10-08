---
name: nbr-git-commit-rebuild
description: Rewrite a run of commits into clean atomic ones by resetting to a target and rebuilding through nbr-git-commit-buckets.
argument-hint: "[optional target ref]"
disable-model-invocation: true
---

# nbr-git-commit-rebuild

After a long iteration, a branch carries save points, fixups and filler commits. This skill turns that run into clean history: pick a **target**, save a **backup** ref, `git reset --mixed` to the target, and rebuild the commits from the resulting working tree with `nbr-git-commit-buckets`. The final tree matches the one you started from, apart from the findings you accept along the way.

## 1. Preflight

```sh
git status --short
git branch --show-current
git fetch --quiet
```

Stop and ask when:

- The working tree is dirty. Uncommitted work would blend into the rebuilt commits. Offer to commit it first or stash it.
- HEAD is detached, or the branch is the default branch. Rewriting shared history needs an explicit yes.

Done when the tree is clean and the branch is known.

## 2. Choose the target

The target is the commit the rebuilt history starts _after_: it stays, everything above it is rewritten. Gather the candidates:

| Candidate     | How to find it                                                                                                                |
| ------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| PR            | `gh pr view --json number,title,baseRefName,commits`; target is `git merge-base HEAD origin/<baseRefName>`                     |
| Branch        | `git merge-base HEAD origin/<default>`, default from `git symbolic-ref --short refs/remotes/origin/HEAD`                       |
| Worktree      | when `git rev-parse --git-dir` differs from `--git-common-dir`: the branch candidate, named as the worktree's starting point |
| Explicit      | the skill argument, resolved with `git rev-parse --verify`                                                                    |

The default is the PR when one exists, otherwise the branch (or worktree) fork point. When the PR base and the branch fork point resolve to the same commit, show one option.

Ask with the question tool: each candidate as an option with its short SHA, subject, and the number of commits it would rewrite, the default first and marked recommended. "Other" takes a ref or "last N".

Then check the range and report before going on:

```sh
git log --oneline --graph <target>..HEAD
git rev-list --merges <target>..HEAD
```

Merge commits in the range get flattened, so name them and ask whether to continue. When the range contains commits from other authors (`git log --format='%an' <target>..HEAD | sort -u`), name them as well: rebuilt commits carry your authorship.

Done when the user has confirmed one target and the range it rewrites.

## 3. Back up and reset

```sh
git log --reverse --format='%h %s%n%b' <target>..HEAD > <scratchpad>/rebuild-old-log.txt
git branch rebuild-backup/<branch>-<YYYYMMDD-HHMM>
git reset --mixed <target>
```

Done when the backup branch exists and `git status --short` shows the rewritten range as unstaged changes.

## 4. Rebuild

Invoke `nbr-git-commit-buckets`. Hand it the old log as input: the old subjects show what the work was meant to be, so use them to name and order buckets, and drop the ones that only describe save points ("wip", "fix", "more"). The buckets follow the final diff, never the old commit boundaries.

Ask it for per-commit checks, so every rebuilt commit builds on its own. nbr-git-commit-buckets runs its own report and approval gate. Its routine-commit handling (a chores command) applies unchanged.

## 5. Verify

```sh
git diff rebuild-backup/<branch>-<stamp> --stat
```

This compares the backup with the working tree, so held-back paths drop out. The only differences allowed are the edits of findings accepted in the buckets report. Anything else means work went missing: stop and report it, with `git reset --hard rebuild-backup/<branch>-<stamp>` as the way back.

Done when the diff is accounted for path by path.

## 6. Finish

Print `git log --oneline <target>..HEAD` beside the old log's subjects (old count → new count).

When the branch has an upstream, the rewrite needs `git push --force-with-lease`. Name it and wait: push only on an explicit yes.

When the preflight stashed work, `git stash pop` it now.

Keep the backup branch. Mention it and the delete command (`git branch -D rebuild-backup/<branch>-<stamp>`) for when the user is satisfied.
