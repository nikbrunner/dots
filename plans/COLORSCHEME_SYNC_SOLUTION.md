# Colorscheme Synchronization Solution Plans

## Problem Statement

The current colorscheme synchronization between Neovim and WezTerm is broken due to:
- Reliance on `$XDG_CONFIG_HOME` which may be unset
- File path resolution issues when environment variables are empty
- The `.current_schemes.lua` file living outside the dotfiles repository
- No integration with other tools like Zed

## Option 1: Centralized Theme State File

### Overview
Create a centralized theme state file in the home directory that all applications can read/write.

### Implementation
1. **Location**: `~/.theme_state.json` (or `~/.local/share/theme/current.json`)
2. **Structure**:
   ```json
   {
     "background": "dark",
     "nvim": {
       "colorscheme": "black-atom-jpn-koyo-yoru"
     },
     "wezterm": {
       "colorscheme": "Black Atom — JPN ∷ Koyo Yoru"
     },
     "zed": {
       "theme": "Black Atom — NORTH ∷ Dark Night"
     },
     "mappings": {
       "black-atom-jpn-koyo-yoru": {
         "wezterm": "Black Atom — JPN ∷ Koyo Yoru",
         "zed": "Black Atom — NORTH ∷ Dark Night"
       }
     }
   }
   ```

### Changes Required
- **Neovim**: Update `sync_wezterm_colorscheme()` to write to JSON file
- **WezTerm**: Update `load_current_schemes()` to read from JSON file
- **Zed**: Would need a custom extension or script to read theme state
- **Dots**: Add the theme state file to symlink management

### Pros
- Single source of truth for all applications
- Easy to extend to new applications
- JSON format is universal and easy to parse
- Can store mappings alongside current state

### Cons
- Requires JSON parsing in Lua (WezTerm/Neovim)
- Zed integration might be limited without custom tooling

## Option 2: Symlinked Lua Module

### Overview
Keep the current Lua-based approach but properly manage the file through the dots system.

### Implementation
1. **Location**: `~/repos/nikbrunner/dots/common/.theme_state.lua`
2. **Symlinked to**: `~/.config/wezterm/.current_schemes.lua` (and other locations)
3. **Structure**: Keep current Lua table format
4. **Fix path resolution**: Use absolute paths instead of `$XDG_CONFIG_HOME`

### Changes Required
- **Neovim**: Update path to use `vim.fn.expand("~/.config/wezterm/.current_schemes.lua")`
- **WezTerm**: No changes needed (already works)
- **Dots**: Add `.theme_state.lua` to common files
- **Link script**: Ensure proper symlink creation

### Pros
- Minimal changes to existing code
- Lua format works well for Neovim/WezTerm
- Managed by dots repository
- No new dependencies

### Cons
- Zed can't easily read Lua files
- Limited to Lua-compatible applications

## Option 3: Event-Based System with Script

### Overview
Create a theme manager script that handles synchronization between all applications.

### Implementation
1. **Script**: `~/bin/theme-sync` (managed by dots)
2. **State file**: `~/.config/theme/state.toml` (or JSON)
3. **Architecture**:
   - Neovim calls `theme-sync set nvim <colorscheme>`
   - Script updates state file and notifies other apps
   - WezTerm watches state file or uses reload signal
   - Script can update Zed's settings.json directly

### Example Script Interface
```bash
theme-sync set nvim "black-atom-jpn-koyo-yoru"
theme-sync get wezterm
theme-sync sync  # Force sync all applications
theme-sync status  # Show current theme state
```

### Changes Required
- **New script**: Create `theme-sync` command
- **Neovim**: Call script instead of direct file write
- **WezTerm**: Watch state file or handle reload signals
- **Zed**: Script updates settings.json directly

### Pros
- Most flexible and extensible solution
- Can handle complex mappings and transformations
- Easy to debug and test
- Can integrate with system theme changes
- Could trigger other actions (wallpaper, terminal colors, etc.)

### Cons
- More complex initial implementation
- Requires external process calls
- Potential performance overhead

## Recommendation

**Option 3 (Event-Based System)** is recommended for the long term because:
1. It provides the most flexibility for future extensions
2. It can handle all current and future applications
3. It's easier to debug and maintain
4. It can be extended to handle system-wide theme changes
5. The script can handle complex mapping logic

**Option 1 (Centralized JSON)** is a good simpler alternative if you want something that works quickly.

**Option 2 (Symlinked Lua)** is the quickest fix but limits future extensibility.