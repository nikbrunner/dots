---
name: dev-util-commit
description: Create a git commit with conventional commit format, scope detection, and clean history strategies. Load when committing code changes.
argument-hint: "[optional commit message override]"
user-invocable: true
metadata:
  argument-hint: "[optional commit message override]"
  user-invocable: true
---

# Commit

Create a commit following conventional commit conventions.

## Format

```
<type>(<scope>): <description>
```

### Types

`feat`, `fix`, `refactor`, `chore`, `docs`, `perf`, `ci`, `test`

### Scope

Determined by which files changed. Project-specific scope rules override these defaults:

- If changes are isolated to one module/directory, use that as scope
- If changes span multiple areas, omit scope
- Config-only or docs-only changes: omit scope

### Description

- 1 sentence, imperative mood ("add X" not "added X")
- Focus on the _why_, not the _what_
- Keep under 70 characters

## Rules

- **Every commit must be green** — tests pass, lint clean.
- Each commit should represent a distinct, working change.
- Stage specific files (`git add <file>`) — avoid `git add -A` which can catch secrets or unrelated changes.
- Always use heredoc for commit messages to preserve formatting.

## Strategies

Choose based on what you're fixing:

| Situation                                 | Strategy           | Command                        |
| ----------------------------------------- | ------------------ | ------------------------------ |
| Fix belongs to the **previous** commit    | Amend              | `git commit --amend --no-edit` |
| Fix belongs to an **older** commit        | Fixup + autosquash | See below                      |
| Change is a **new distinct unit** of work | New commit         | Normal commit                  |

**Always ask before amending or fixup.** These rewrite history and can go wrong.

### Fixup workflow

```bash
# 1. Find the target commit
git log --oneline -10

# 2. Create a fixup commit pointing to the target
git commit --fixup=<sha>

# 3. Autosquash to merge the fixup into the target commit
git rebase -i --autosquash <sha>~1
```

## Process

1. Check `git status` and `git diff --staged` to understand what's being committed
2. Determine scope from changed file paths
3. Decide strategy: amend, fixup, or new commit
4. Draft a concise message focusing on the _why_
5. Stage specific files
6. Commit via heredoc for proper formatting
