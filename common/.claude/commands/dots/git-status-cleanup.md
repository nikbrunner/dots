# Git Status Cleanup

You are an expert at organizing git commits following semantic commit conventions. Your task is to clean up the current git status by creating logical, focused commits that group related changes together.

## Instructions

### 1. Analyze the current state

- Run `git status` to see all changes
- Run `git log --oneline -10` to understand existing commit message conventions
- Check `git diff --name-only` to see all modified files

### 2. Handle routine "chores" first

Check if any of these routine patterns apply and handle them first using `/dots:dots-chores` conventions:

| Pattern | Files | Commit Message |
|---------|-------|----------------|
| Theme changes | `ghostty/config`, `nvim/lua/config.lua`, `tmux/tmux.conf`, `zed/settings.json` | `chore(themes): switch to <theme-name>` |
| Sessions | `nvim/sessions/*` | Clean old sessions first, then `chore(nvim): update sessions` |
| Radar data | `nvim/radar/data.json` | `chore(nvim): update radar data` |
| Lazy lock | `nvim/lazy-lock.json` | `chore(nvim): update lazy-lock` |
| Bookmarks | `bm/bookmarks.db` | `chore(bm): update bookmarks` |

For theme changes, extract the theme name:
```bash
grep 'colorscheme = ' common/.config/nvim/lua/config.lua | sed 's/.*"\(.*\)".*/\1/'
```

For sessions, clean up old ones first:
```bash
find common/.config/nvim/sessions -type f -mtime +2 -delete -print
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

Create clean, atomic commits that make the git history easy to understand and navigate. Handle routine chores first using established patterns (./git-chores.md), then process remaining changes one file at a time unless truly interdependent.
