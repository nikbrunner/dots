# Simple Multiplexer Bindings Strategy

## Structure
```
common/.config/
├── wezterm/
│   ├── keymaps.lua                # Non-multiplexer bindings, conditionally sources multiplexer bindings
│   └── keymaps.multiplexer.lua    # Multiplexer bindings (only when MULTIPLEXER=wezterm)
├── tmux/
│   ├── keymaps.conf               # Non-multiplexer bindings, conditionally sources multiplexer bindings
│   └── keymaps.multiplexer.conf   # Multiplexer bindings (only when MULTIPLEXER=tmux)
└── kitty/
    ├── keymaps.conf               # Non-multiplexer bindings, conditionally sources multiplexer bindings
    └── keymaps.multiplexer.conf   # Multiplexer bindings (only when MULTIPLEXER=kitty)
```

## Implementation

### WezTerm
```lua
-- keymaps.lua
local multiplexer = os.getenv("MULTIPLEXER") or "wezterm"

-- Always load non-multiplexer bindings
config.keys = {
    -- Font selection, color schemes, etc
    { key = "f", mods = "LEADER", action = FontUtil.selector_action() },
    { key = "t", mods = "LEADER", action = ColorSchemeUtil.selector_action() },
    -- Other non-multiplexer bindings...
}

-- Conditionally load multiplexer bindings
if multiplexer == "wezterm" then
    local multiplexer_keys = require("keymaps.multiplexer")
    for _, key in ipairs(multiplexer_keys) do
        table.insert(config.keys, key)
    end
end
```

```lua
-- keymaps.multiplexer.lua
return {
    -- Session/Workspace management
    { key = "s", mods = "ALT", action = action.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
    { key = "j", mods = "ALT", action = action.SwitchWorkspaceRelative(-1) },
    { key = "k", mods = "ALT", action = action.SwitchWorkspaceRelative(1) },
    
    -- Tab management
    { key = "c", mods = "ALT", action = action.SpawnTab("CurrentPaneDomain") },
    { key = "1", mods = "ALT", action = action.ActivateTab(0) },
    -- ... rest of tab numbers
    
    -- Pane navigation
    { key = "h", mods = "CTRL", action = action.EmitEvent("ActivatePaneDirection-left") },
    { key = "j", mods = "CTRL", action = action.EmitEvent("ActivatePaneDirection-down") },
    -- ... etc
}
```

### tmux
```bash
# keymaps.conf
# Non-multiplexer bindings always loaded
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# Conditionally source multiplexer bindings
if-shell '[ "$MULTIPLEXER" = "tmux" ]' \
    'source-file ~/.config/tmux/keymaps.multiplexer.conf'
```

```bash
# keymaps.multiplexer.conf
# Session management
bind -n M-s choose-tree -s
bind -n M-j switch-client -n
bind -n M-k switch-client -p

# Window management  
bind -n M-c new-window -c '#{pane_current_path}'
bind -n M-1 select-window -t 1
# ... rest of window numbers

# Pane navigation
bind-key -n C-h if-shell "$IS_VIM" "send-keys C-h"  "select-pane -L"
bind-key -n C-j if-shell "$IS_VIM" "send-keys C-j"  "select-pane -D"
# ... etc
```

## Usage

```bash
# .zshrc
export MULTIPLEXER="tmux"  # or "wezterm" or "kitty"

# Auto-detection (optional)
if [[ -n "$TMUX" ]]; then
    export MULTIPLEXER="tmux"
elif [[ "$TERM_PROGRAM" == "WezTerm" ]]; then
    export MULTIPLEXER="wezterm"  
fi
```

## Benefits

1. **Simple and clear** - Each tool owns its multiplexer bindings
2. **No abstraction layer** - Direct implementation in each tool's native format
3. **Easy to understand** - Just check if env var matches, then load extra file
4. **No translation needed** - Each tool uses its native configuration format

## What Goes Where

### Multiplexer Bindings (`keymaps.multiplexer.*`)
- Session/workspace management
- Window/tab creation and navigation
- Pane splitting and navigation
- Pane resizing
- Session switching tools (sessionizer, workspace picker)
- Anything that manages the terminal multiplexing

### Non-Multiplexer Bindings (`keymaps.*`)
- Font selection
- Color scheme switching
- Copy mode (if not multiplexer-specific)
- Application launches (that aren't session-based)
- Tool-specific features (WezTerm's debug overlay, etc.)
- Leader key definition