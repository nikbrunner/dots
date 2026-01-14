# Sessions Commit

Commit nvim session file changes after cleaning up old sessions.

## Files to commit

- `common/.config/nvim/sessions/*`

## Instructions

1. **Clean up old sessions (older than 2 days)**:
   ```bash
   find common/.config/nvim/sessions -type f -mtime +2 -delete -print 2>/dev/null | wc -l | xargs -I {} echo "Cleaned up {} old session(s)"
   ```

2. **Check for session changes**:
   ```bash
   git status --porcelain common/.config/nvim/sessions/
   ```

3. **If there are changes, stage and commit**:
   ```bash
   git add common/.config/nvim/sessions/
   git commit -m "chore(nvim): update sessions"
   ```

4. **If no session files have changes**, inform the user that there's nothing to commit.
