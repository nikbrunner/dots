# Phase 4: Close

## When to use

Work is done and Nik invokes `/dev:flow close`. Claude never auto-triggers this phase.

## BAI Auto-Detection

If repo path contains `black-atom-industries`, Linear context is loaded. Close Linear issues instead of GitHub issues when applicable.

## Steps

### 1. Verify

Run the project's test suite, build, and lint. Read the full output — not just exit codes.

| Claim          | Requires                         | Not sufficient                |
| -------------- | -------------------------------- | ----------------------------- |
| Tests pass     | Test output showing 0 failures   | Previous run, "should pass"   |
| Build succeeds | Build exit 0 + clean output      | Linter passing                |
| Bug fixed      | Original symptom verified absent | "Code changed, assumed fixed" |

For UI changes: build, launch, screenshot, inspect visually.

If verification fails, stop. Fix first, re-run.

### 2. Final review

Dispatch **structural-completeness-reviewer** agent across the full branch diff (diff against base branch). This catches what per-task reviews miss at the integration level:

- Dead code, incomplete removals, orphaned imports
- Dev artifacts left behind
- Dependency hygiene issues

If issues found: fix, re-verify, re-dispatch reviewer. Only proceed once clean.

### 3. Ship

Detect base branch (`main` or `master`), then present exactly four options:

| Option            | Merges | Pushes | Cleanup                                      |
| ----------------- | ------ | ------ | -------------------------------------------- |
| **Merge** locally | Yes    | No     | Branch + worktree deleted                    |
| **Push & PR**     | No     | Yes    | `gh pr create` with summary + test plan      |
| **Keep** branch   | No     | No     | Report branch name                           |
| **Discard**       | No     | No     | Require "discard" confirmation, force-delete |

For worktree branches, clean up with `git worktree remove` on merge/discard.

### 4. Archive OpenSpec change (if applicable)

If an active OpenSpec change exists with all tasks complete:

1. Run `openspec archive <change-name>`
2. Delta specs are promoted into `openspec/specs/<domain>/`
3. Change directory moves to `openspec/changes/archive/`
4. Commit the archive

If no OpenSpec change, skip.

### 5. Close tracked issue (optional)

If work is linked to an issue:

- GitHub: `gh issue close <number>`
- Linear (BAI): close via Linear API

If no issue is tracked, skip.

### 6. Knowledge sync (optional)

For medium/large work, check if project knowledge needs updating:

- CLAUDE.md changes
- New skills or skill updates
- Documentation updates

## Transition

Done. Back to Phase 1 on the next task.
