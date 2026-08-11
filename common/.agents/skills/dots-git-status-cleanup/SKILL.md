---
name: dots-git-status-cleanup
description: Clean up git status with focused semantic commits
---

# Git Status Cleanup

You are an expert at organizing git commits following semantic commit conventions. Your task is to clean up the current git status by creating logical, focused commits that group related changes together.

## Instructions

### 1. Run `dots chores` first

This handles all routine commits automatically:

- Theme and font changes
- Session cleanup and commits
- Radar data
- Lazy-lock
- Bookmarks

```bash
dots chores
```

### 2. Analyze remaining changes

After chores complete, check what's left:

```bash
git status
git diff --name-only
```

### 3. Handle remaining changes

For non-routine changes, use single-file commits unless files are tightly related:

- **Default to one file per commit** unless files have direct dependencies
- Configuration files for different tools should never be in the same commit
- New features should be separate from refactoring

### 4. Follow the `dev-commit` message format

Use the message grammar from `dev-commit`, Phase 3:

```
[<ticket>] <summary>
```

- Use imperative mood: `add X`, not `added X`
- Keep the subject under 70 characters
- Focus on why rather than repeating the diff
- Do not use a `type(scope):` prefix
- Prepend a ticket key in square brackets when the change has one
- Add a body only for a large or non-obvious diff; use bullets wrapped at 72 characters

## Example commit message formats

**Single file (preferred):**

```
add date insertion keymaps
```

**Multiple related files (only when necessary):**

```
use local review.nvim fork for its improved keymaps
```

## Your goal

Create clean, atomic commits that make the git history easy to understand and navigate. Run `dots chores` first, then process remaining changes one file at a time unless truly interdependent.
