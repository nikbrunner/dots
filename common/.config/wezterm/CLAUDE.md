# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

This is a WezTerm configuration written in Lua with a modular architecture. The main entry point is `wezterm.lua` which orchestrates loading of font, UI, and keymap modules.

### Configuration Flow
```
wezterm.lua (entry) → font.lua → ui.lua → keymaps.lua
                                    ↓
                               tabs.lua (from ui.lua)
```

### Module Pattern
Most configuration modules follow this pattern:
```lua
return function(wezterm, config)
    -- Configure the config object
    -- Set up event handlers
end
```

Utility modules use standard Lua module pattern with `local M = {}` and `return M`.

## Key Components

- **font-util.lua**: Font registry system with dynamic switching via fuzzy finder
- **sessionizer.lua**: Project discovery that scans for git repos with 1-hour caching
- **ui.lua**: Adaptive light/dark theming, reads color config from `.current_schemes.lua`
- **keymaps.lua**: Neovim integration for seamless pane navigation, leader key Ctrl+,
- **colors/**: TOML color scheme definitions
- **fonts/**: Individual font configuration modules

## Special Features

### Neovim Integration
Pane navigation detects Neovim processes and sends commands directly to Neovim before falling back to WezTerm navigation.

### Dynamic Theming  
- Automatic light/dark mode switching based on system appearance
- External color configuration in `.current_schemes.lua`
- Color schemes stored as TOML files in `colors/` directory

### Project Management
- Uses `fd` for fast project discovery
- Fuzzy project selection with workspace switching
- Cached results stored in `wezterm.GLOBAL`

## Development Commands

Since this is a configuration repository, changes take effect immediately when WezTerm reloads. Use:
- Ctrl+, Shift+R to reload configuration
- Check WezTerm debug console for Lua errors

## File Navigation

Configuration is organized by feature:
- Font selection: `font.lua`, `font-util.lua`, `fonts/`
- Visual appearance: `ui.lua`, `tabs.lua`, `colors/`
- Input handling: `keymaps.lua`
- Workspace management: `sessionizer.lua`, `workspace.lua`, `sessions.lua`