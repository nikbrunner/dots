# Radar Commit

Commit radar.nvim data file changes.

## Files to commit

- `common/.local/share/nvim/radar/data.json`

## Instructions

1. **Check for radar data changes**:
   ```bash
   git status --porcelain common/.local/share/nvim/radar/data.json
   ```

2. **If there are changes, stage and commit**:
   ```bash
   git add common/.local/share/nvim/radar/data.json
   git commit -m "chore(nvim): update radar data"
   ```

3. **If no changes**, inform the user that there's nothing to commit.
