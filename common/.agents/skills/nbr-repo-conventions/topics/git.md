# Git

The repo's tracked Git setup: the hook manager, the repository config, and the two verification scopes the hooks run.

## Control

- In a repo under the maintainer's full control, the hook manager is Lefthook. It passes staged file lists, hides unstaged
  changes during pre-commit, and can re-stage files, so a repo with Lefthook needs no lint-staged or nano-staged on top.
- A shared or externally governed repo keeps its existing tool. Without hooks, it gets Lefthook only when its policy allows.
  A migration happens only on explicit request, and only when project policy permits it.
- Repository location and write access alone do not establish control. When it is unclear, ask.

## Repository config

A fresh clone applies the repo's Git config once, through a `git:config` script or the contributor setup:

```sh
git config pull.rebase true
git config merge.ff only
```

Native hooks add `git config core.hooksPath .githooks`. Check both the setting and the directory: a missing hooks path
fails silently.

## Check, never write

Every tool has a **check** mode that reads and exits non-zero (`prettier --check`, `eslint`, `tsc --noEmit`) and a **write**
mode that changes files (`prettier --write`, `eslint --fix`). Hooks only check.

A commit takes the index, while a writer changes the working tree. With partially staged files, a fix made in a hook misses
the commit, and re-staging it (`git add`, `stage_fixed`) pulls in hunks that were left out on purpose. Writing is an explicit
action instead: the `format` and `lint` scripts, format-on-save, or an agent format-on-edit hook.

Script names say which mode they are. `verify:*` scripts only read; `format` and `lint` write. A hook calls `verify:*`
scripts only.

## Verify scopes

| Scope  | Script          | Runs on    | Contains                                                         |
| ------ | --------------- | ---------- | ---------------------------------------------------------------- |
| commit | `verify:staged` | pre-commit | Whole-repo format and lint checks, while they stay fast           |
| full   | `verify:full`   | pre-push   | The CI-parity pass: format, lint, typecheck, non-watch tests, build |

- CI runs `verify:full`, so pre-push and CI cannot disagree.
- A repo whose whole-repo checks get slow scopes pre-commit to `{staged_files}` with globs, as a stated deviation.
- Correctness checks block the commit. Advisory checks, such as stale docs or an outdated vendored skill, warn and let it
  through.
- Hooks call the project's scripts instead of reimplementing them in shell. One runner per check.

## Installation

- A fresh clone installs hooks through the project's setup: the Node `prepare` script, or an explicit task such as
  `lefthook install` or `install-hooks`. The contributor setup instructions name it.
- Hook verification happens in a disposable repository, never by committing or pushing in the real one.
