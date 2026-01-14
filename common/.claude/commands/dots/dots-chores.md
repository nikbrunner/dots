# Dots Chores

Commit routine dots repo changes: themes, sessions, and radar data.

## Instructions

Run these in sequence, skipping any that have no changes:

### 1. Theme Changes

Files: `common/.config/ghostty/config`, `common/.config/nvim/lua/config.lua`, `common/.config/tmux/tmux.conf`, `common/.config/zed/settings.json`

```bash
# Extract theme name from nvim config
git diff common/.config/nvim/lua/config.lua | grep '+.*colorscheme' | sed 's/.*"\(.*\)".*/\1/'
# Or from current value if no diff
grep 'colorscheme = ' common/.config/nvim/lua/config.lua | sed 's/.*"\(.*\)".*/\1/'
```

Commit: `chore(themes): switch to <theme-name>`

### 2. Session Changes

First clean up sessions older than 2 days:
```bash
find common/.config/nvim/sessions -type f -mtime +2 -delete -print
```

Then commit remaining session changes: `chore(nvim): update sessions`

### 3. Radar Changes

File: `common/.local/share/nvim/radar/data.json`

Commit: `chore(nvim): update radar data`

## After Completion

1. Report how many commits were created and if any uncommitted changes remain.
2. If commits were created, offer to push to remote.
