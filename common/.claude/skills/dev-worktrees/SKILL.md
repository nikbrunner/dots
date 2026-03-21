---
name: dev:worktrees
description: "Create and manage git worktrees for feature branches -- directory setup, safety checks, project bootstrap."
user-invocable: true
---

# Worktrees

## Directory Selection

Priority order:

1. Existing `.worktrees/` directory in the repo
2. CLAUDE.md or project config preference
3. Ask the user (offer `.worktrees/` as default)

## Safety Check

Before creating anything:

```bash
git check-ignore <worktree-dir>
```

If **not** ignored, add it to `.gitignore` and commit immediately. Never leave worktree directories tracked.

## Create

```bash
git worktree add <path> -b <branch-name>
```

## Project Setup

Auto-detect and run the appropriate install:

| Detected file | Command |
|-|-|
| `package.json` + `pnpm-lock.yaml` | `pnpm install` |
| `package.json` + `package-lock.json` | `npm install` |
| `package.json` (other) | `npm install` |
| `Cargo.toml` | `cargo build` |
| `deno.json` | `deno install` |
| `requirements.txt` | `pip install -r requirements.txt` |
| `go.mod` | `go mod download` |

## Baseline Test

Run the project's test suite in the new worktree. This establishes a clean starting point.

- **Tests pass**: Report ready.
- **Tests fail**: Report failures and ask whether to proceed anyway.

## Report

After setup, report:
- Worktree path
- Test status (pass/fail/skipped)
- Ready state

## Cleanup

Pairs with `dev:finishing-branch` for end-of-life. Manual cleanup:

```bash
git worktree remove <path>
git branch -d <branch>
```
