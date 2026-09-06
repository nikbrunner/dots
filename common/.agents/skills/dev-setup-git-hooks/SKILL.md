---
name: dev-setup-git-hooks
description: Set up, review, or migrate Git hooks, including pre-commit and pre-push. Establish project control, preserve existing checks and team conventions, and keep commits fast. Use for hook setup, hook maintenance, migration to Lefthook, or optional agent hook integration.
---

# Set up Git hooks

Keep commits fast and useful. Run broader checks before pushing. Reuse the project's existing checks and respect who controls its tooling.

## 1. Establish project control

Read project instructions and use explicit user context to determine whether the user has full control over tooling. Repository location and write access alone do not establish control. If unclear, ask before choosing or replacing a hook manager.

For projects under the user's full control, prefer Lefthook. For shared or externally governed projects, follow their conventions and maintain the existing tool. If those projects have no hooks, establish the preferred method first. Replace their tool only when the user explicitly requests migration and project policy permits it.

## 2. Inspect the setup

Check Git status and preserve unrelated changes. Identify the ecosystem, package manager, existing scripts, CI checks, and contributor setup instructions.

Inspect all hook stages, configuration, dependencies, installation commands, and referenced scripts. Resolve Git's effective hooks directory and configuration scope, including worktrees and inherited settings.

Record each check's purpose, stage, command, working directory, file selection, arguments/input, environment, ordering, failure behavior, and file modifications. This inventory is the migration checklist.

## 3. Plan the checks and choose a method

Use this default distribution when project policy allows it:

| Stage      | Checks                                                                  |
| ---------- | ----------------------------------------------------------------------- |
| Pre-commit | Fast formatting and lint checks, scoped to staged files where supported |
| Pre-push   | Project-wide typechecks, non-watch tests, and existing build checks     |

Prefer read-only checks. Keep formatting an explicit developer action. Preserve existing autofix or staging behavior unless a change is agreed. Local hooks complement CI, since they can be bypassed.

Reuse existing commands. Report missing checks; adding a formatter, linter, or test framework is a separate decision.

Show the check-to-stage mapping and any proposed behavior changes before applying them. An explicit setup or migration request authorizes the work; ask only about unresolved choices. During migration, preserve coverage and make stage moves explicit.

Read only the applicable method before implementation:

- [Lefthook](methods/lefthook.md): default for user-controlled projects; includes CLI discovery, official references, migration, and optional AI hooks.
- [Native shell hooks](methods/bash.md): fallback when the user chooses native hooks or project conventions require them.
- For another established tool, use its official documentation and preserve the project's approach.

A missing executable or failed installation is not a reason to silently switch methods. Report the issue and resolve the method choice with the user.

## 4. Apply and verify

Maintain a working setup without unnecessary rewrites. For a migration, keep recoverable copies of replaced untracked hooks and remove obsolete files or dependencies only after accounting for every check and other consumers. Preserve unrelated lifecycle commands and global configuration.

Verify configuration, actual Git wiring, and representative successful and failing checks. Use a disposable repository for commit/push failure tests; never create commits or push in the user's repository just to test hooks. For file-scoped checks, cover matching files, no matches, paths with spaces, deletions, and partial staging. An empty selection that skips every check is not a successful verification.

Confirm migrated coverage and that verification leaves the user's files and index intact. Repeat setup only to verify idempotence when needed. State which checks could not run and why.

Update contributor setup instructions. Leave changes unstaged and report the method, stages, verification results, and setup steps. Commit only when explicitly requested, using the commit skill.
