# Hooks

Git hooks keep commits fast and catch the broad failures before a push. They complement CI, since anyone can bypass them.

## Control

- In a repo under the maintainer's full control, the hook manager is Lefthook.
- A shared or externally governed repo keeps its existing tool. Without hooks, it gets Lefthook only when its policy allows.
  A migration happens only on explicit request, and only when project policy permits it.
- Repository location and write access alone do not establish control. When it is unclear, ask.

## Stages

| Stage      | Checks                                                                  |
| ---------- | ----------------------------------------------------------------------- |
| Pre-commit | Fast formatting and lint checks, scoped to staged files where supported |
| Pre-push   | The CI-parity pass: project-wide typechecks, non-watch tests, builds    |

- New checks are read-only (`--check`), and formatting is an explicit developer action. An existing autofix or staging
  hook stays unless a change is agreed.
- Hooks call the project's existing scripts and tasks instead of reimplementing them in shell.
- File-scoped checks use staged files (`{staged_files}`); project-wide checks stay project-wide.
- One runner per check. Two active hook managers for the same checks is a defect.

## Installation

- A fresh clone installs hooks through the project's setup: the Node `prepare` script, or an explicit task such as
  `lefthook install` or `install-hooks`. The contributor setup instructions name it.
- Native hooks live in tracked `.githooks/`, enabled with `git config --local core.hooksPath .githooks`.
- Hook verification happens in a disposable repository, never by committing or pushing in the real one.
