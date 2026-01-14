# Theme Commit

Commit theme configuration changes across all apps with auto-detected theme name.

## Files to commit

- `common/.config/ghostty/config`
- `common/.config/nvim/lua/config.lua`
- `common/.config/tmux/tmux.conf`
- `common/.config/zed/settings.json`

## Instructions

1. **Check for theme changes**:
   ```bash
   git diff --name-only common/.config/ghostty/config common/.config/nvim/lua/config.lua common/.config/tmux/tmux.conf common/.config/zed/settings.json
   ```

2. **Extract theme name from nvim config diff**:
   ```bash
   git diff common/.config/nvim/lua/config.lua | grep '+.*colorscheme' | sed 's/.*"\(.*\)".*/\1/'
   ```

   If no diff exists in nvim config, check the current value:
   ```bash
   grep 'colorscheme = ' common/.config/nvim/lua/config.lua | sed 's/.*"\(.*\)".*/\1/'
   ```

3. **Stage only the theme files that have changes**:
   ```bash
   git add common/.config/ghostty/config common/.config/nvim/lua/config.lua common/.config/tmux/tmux.conf common/.config/zed/settings.json
   ```

4. **Commit with extracted theme name**:
   ```bash
   git commit -m "chore(themes): switch to <theme-name>"
   ```

   Replace `<theme-name>` with the extracted theme name (e.g., `black-atom-mnml-mikado-dark`).

5. **If no theme files have changes**, inform the user that there's nothing to commit.
