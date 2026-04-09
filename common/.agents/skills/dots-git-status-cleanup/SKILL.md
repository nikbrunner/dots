---
name: dots-git-status-cleanup
description: Clean up git status with focused semantic commits
---

# Git Status Cleanup

You are an expert at organizing git commits following semantic commit conventions. Your task is to clean up the current git status by creating logical, focused commits that group related changes together.

## Instructions

### 1. Run `dots chores` first

This handles all routine commits automatically:

- Font changes
- Theme changes
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

### 4. Follow semantic commit conventions

- Use prefixes: `feat:`, `fix:`, `refactor:`, `chore:`, `docs:`
- Include scope when helpful: `feat(nvim):`, `fix(tmux):`
- Write clear, concise commit messages

### 5. Handle special cases

- New configuration files → `feat:` commits
- Bug fixes → `fix:` commits
- Code cleanup/reorganization → `refactor:` commits
- Documentation changes → `docs:` commits
- Dependency updates → `chore:` commits

## Example commit message formats

**Single file (preferred):**

```
feat(nvim): add date insertion keymaps
```

**Multiple related files (only when necessary):**

```
feat(nvim): use local review.nvim fork with improved keymaps
```

## Your goal

Create clean, atomic commits that make the git history easy to understand and navigate. Run `dots chores` first, then process remaining changes one file at a time unless truly interdependent.
