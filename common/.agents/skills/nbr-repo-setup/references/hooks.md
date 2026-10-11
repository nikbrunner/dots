# Hooks setup

Builds the hooks the `hooks` topic of `nbr-repo-conventions` describes: who controls the repo decides the manager, and the
stage table decides where each check runs.

## Inspect

Check Git status and preserve unrelated changes. Identify the ecosystem, package manager, existing scripts, CI checks, and
contributor setup instructions.

Inspect all hook stages, configuration, dependencies, installation commands, and referenced scripts. Resolve Git's
effective hooks directory and configuration scope, including worktrees and inherited settings.

Record each check's purpose, stage, command, working directory, file selection, arguments and input, environment, ordering,
failure behavior, and file modifications. This inventory is the migration checklist.

## Plan

Map each check to a stage and show the mapping with any behavior change. During a migration, preserve coverage and make
stage moves explicit. Report missing checks; adding a formatter, linter, or test framework is a separate decision.

Read only the applicable method before implementation:

- [Lefthook](hooks/lefthook.md): the default; includes CLI discovery, official references, migration, and optional AI hooks.
- [Native shell hooks](hooks/bash.md): when the maintainer chooses native hooks or project conventions require them.
- For another established tool, use its official documentation and preserve the project's approach.

## Apply and verify

Maintain a working setup without unnecessary rewrites. For a migration, keep recoverable copies of replaced untracked hooks
and remove obsolete files or dependencies only after accounting for every check and other consumers. Preserve unrelated
lifecycle commands and global configuration.

Verify configuration, actual Git wiring, and representative successful and failing checks in a disposable repository. For
file-scoped checks, cover matching files, no matches, paths with spaces, deletions, and partial staging. An empty
selection that skips every check is not a successful verification.

Confirm migrated coverage and that verification leaves the maintainer's files and index intact. State which checks could
not run and why. Update the contributor setup instructions, and report the method, stages, verification results, and
setup steps.
