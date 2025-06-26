# Delta Auto Theme Switching Plan

## Overview

Create a system to automatically switch delta themes based on macOS system appearance while keeping delta as the git pager. This builds on the existing WezTerm and Ghostty colorscheme syncing system.

## Problem Statement

Currently, the `.gitconfig` has manual delta theme settings:
```
[delta]
  dark = true
  ; light = true
```

These need to be manually switched when changing system appearance, which is tedious and inconsistent with the automated colorscheme syncing for other tools.

## Solution Approach

Extend the existing Neovim colorscheme sync system to also update delta theme settings in `.gitconfig` based on macOS system appearance detection.

## Implementation Strategy

### 1. Create Delta Sync Function

**File**: `common/.config/nvim/lua/lib/files.lua`

Add `sync_delta_theme()` function that:
- Detects macOS system appearance using `defaults read -g AppleInterfaceStyle`
- Reads current `.gitconfig` content
- Locates the `[delta]` section
- Updates `dark = true` and `light = true` lines based on system appearance:
  - Dark mode: Enable `dark = true`, comment out `light = true`
  - Light mode: Enable `light = true`, comment out `dark = true`
- Writes updated content back to `.gitconfig`

### 2. Integration with Existing Sync System

**File**: `common/.config/nvim/lua/lib/ui.lua`

Add call to `sync_delta_theme()` in the `handle_colors()` function alongside existing WezTerm and Ghostty syncing:
```lua
vim.defer_fn(function()
    Files.sync_wezterm_colorscheme(config, colorscheme)
    Files.sync_ghostty_colorscheme(config, colorscheme)
    Files.sync_delta_theme()
end, 25)
```

### 3. Configuration Pattern

The function will toggle between these states:

**Dark Mode**:
```
[delta]
  dark = true
  ; light = true
```

**Light Mode**:
```
[delta]
  ; dark = true
  light = true
```

## Technical Details

### System Appearance Detection

Use macOS-specific command:
```bash
defaults read -g AppleInterfaceStyle 2>/dev/null
```
- Returns "Dark" if dark mode is enabled
- Returns empty/error if light mode is enabled

### File Parsing Strategy

1. Read `.gitconfig` line by line
2. Track when entering/exiting `[delta]` section
3. Pattern match for `dark =` and `light =` lines (with optional comment prefix)
4. Update lines based on detected system appearance
5. Preserve existing indentation and formatting

### Error Handling

- Check if `.gitconfig` exists before processing
- Use `pcall` for file operations to catch errors gracefully
- Provide user notifications for success/failure states
- Gracefully handle missing `[delta]` section

## Benefits

1. **Consistency**: Aligns with existing WezTerm/Ghostty sync behavior
2. **Automation**: Eliminates manual delta theme switching
3. **Integration**: Works seamlessly with existing colorscheme workflow
4. **Reliability**: Uses the same file modification patterns as other sync functions

## Trigger Conditions

The delta sync will run when:
- Changing colorschemes in Neovim (existing trigger)
- System appearance changes (detected on next colorscheme change)
- Manual colorscheme refresh commands

## Testing Strategy

1. Test with system in dark mode - verify delta uses dark theme
2. Test with system in light mode - verify delta uses light theme
3. Test edge cases:
   - Missing `.gitconfig` file
   - Missing `[delta]` section
   - Malformed delta configuration
4. Verify git commands (`git diff`, `git log`, `git show`) use correct themes
5. Test integration with lazygit to ensure consistency

## Future Enhancements

- Consider adding standalone command to sync delta theme without colorscheme change
- Potential extension to other git diff tools if needed
- Integration with other macOS appearance-aware tools

## Implementation Notes

- Reuses existing file modification patterns from `sync_ghostty_colorscheme()`
- Maintains compatibility with existing delta configuration
- Preserves user's other delta settings (navigate, side-by-side, etc.)
- Uses same notification system as other sync functions