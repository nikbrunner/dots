# Git Status Cleanup

You are an expert at organizing git commits following semantic commit conventions. Your task is to clean up the current git status by creating logical, focused commits that group related changes together.

## Instructions

1. **Analyze the current state**:
   - Run `git status` to see all changes
   - Run `git log --oneline -10` to understand existing commit message conventions
   - Check `git diff --name-only` to see all modified files

2. **Commit strategy - prefer single-file commits**:
   - **Default to one file per commit** unless files are tightly related
   - Only group files together when they have direct dependencies or are part of the same feature
   - Single-file changes should always be their own commits (even small ones)
   - New features should be separate from refactoring
   - Configuration files for different tools should never be in the same commit

3. **Follow semantic commit conventions**:
   - Use prefixes like `feat:`, `fix:`, `refactor:`, `chore:`, `docs:`
   - Include scope in parentheses when helpful: `feat(nvim):`, `fix(tmux):`
   - Write clear, concise commit messages
   - Avoid bullet points unless absolutely necessary (prefer single-purpose commits)

4. **Process systematically**:
   - Stage and commit one logical group at a time
   - Use `git add <specific-files>` to stage only related changes
   - Write meaningful commit messages that explain what and why
   - Verify with `git status` after each commit

5. **Handle special cases**:
   - New configuration files should be `feat:` commits
   - Bug fixes should be `fix:` commits  
   - Code cleanup/reorganization should be `refactor:` commits
   - Documentation changes should be `docs:` commits
   - Dependency updates should be `chore:` commits

## Example commit message formats:

**Single file (preferred):**
```
feat(nvim): add date insertion keymaps
```

**Multiple related files (only when necessary):**
```
feat(themes): add black-atom-mnml-mikado colorscheme

- Add dark and light variants for multiple terminals
- Consistent color palette across applications
```

## Your goal
Create clean, atomic commits that make the git history easy to understand and navigate. Prioritize single-file commits for maximum granularity and easier review/reversion. Only group files when they are truly interdependent.

Begin by analyzing the current git status and then systematically create commits for all staged and unstaged changes, one file at a time unless files are directly related.