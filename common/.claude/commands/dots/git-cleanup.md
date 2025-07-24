# Git Status Cleanup

You are an expert at organizing git commits following semantic commit conventions. Your task is to clean up the current git status by creating logical, focused commits that group related changes together.

## Instructions

1. **Analyze the current state**:
   - Run `git status` to see all changes
   - Run `git log --oneline -10` to understand existing commit message conventions
   - Check `git diff --name-only` to see all modified files

2. **Group changes logically**:
   - Related functionality should be in the same commit
   - Single-file changes can be their own commits if they're substantial
   - New features should be separate from refactoring
   - Configuration changes should be grouped by application/tool when possible

3. **Follow semantic commit conventions**:
   - Use prefixes like `feat:`, `fix:`, `refactor:`, `chore:`, `docs:`
   - Include scope in parentheses when helpful: `feat(nvim):`, `fix(tmux):`
   - Write clear, descriptive commit messages
   - Use bullet points for multiple changes in one commit

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

## Example commit message format:
```
feat(tool): brief description of what was added/changed

- Specific change 1
- Specific change 2
- Reason for change if not obvious
```

## Your goal
Create clean, logical commits that make the git history easy to understand and navigate. Each commit should represent a single, cohesive change that could theoretically be reverted independently if needed.

Begin by analyzing the current git status and then systematically create commits for all staged and unstaged changes.