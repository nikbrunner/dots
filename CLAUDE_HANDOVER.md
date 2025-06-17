# Claude Code Handover: Dotfiles Refactor Issues

## Current Status - CRITICAL ISSUES

The dotfiles repository has been refactored from old structure to new mirror-home-directory structure with mapping-based symlinking, but there are problems with the file-level symlink approach.

### Critical Problems

1. **Config applications breaking**: oh-my-posh shows "CONFIG ERROR" - applications may expect entire config directories, not individual file symlinks
2. **Mixed symlink state**: Some files are individual symlinks, some are directory symlinks
3. **Git tracking confusion**: Mix of typechanges and deletions in git status

### Current Structure

```
dots/
├── common/                    # Cross-platform files
│   ├── .config/              # Config files
│   ├── bin/                  # Scripts (was .scripts)
│   ├── .zshrc, .gitconfig, etc.
├── macos/                    # macOS-specific files
│   ├── .config/karabiner/
│   ├── Library/Application Support/Claude/
│   └── Brewfile
├── linux/                   # Linux-specific (empty)
├── .mappings/               # JSON mapping files
│   ├── macos.json
│   └── linux.json
└── scripts/
    ├── generate-mappings.sh  # Creates JSON mappings
    └── link.sh              # Uses JSON mappings
```

### What Was Done

1. ✅ **Restructured** from `config/` to mirror home layout (`common/`, `macos/`, `linux/`)
2. ✅ **Removed tmux plugins** (should be managed by TPM)
3. ✅ **Created mapping system** with JSON files showing source→target
4. ✅ **Updated link.sh** to use mappings instead of recursive logic
5. ✅ **Renamed .scripts to bin** (standard convention)
6. ❌ **File-level linking causing issues**

### Immediate Problem to Solve

**DECISION NEEDED**: Choose between two approaches:

#### Option A: Directory-Level Linking (RECOMMENDED)
- Link entire config directories: `~/.config/kitty` → `dots/common/.config/kitty`
- Safer for applications that expect directory structures
- Exception: Individual files in sensitive directories like `Library/`

#### Option B: File-Level Linking (CURRENT - BROKEN)
- Link individual files: `~/.config/kitty/kitty.conf` → `dots/common/.config/kitty/kitty.conf`
- More granular but breaks some applications
- Current approach causing oh-my-posh errors

### Recommended Fix

1. **Revert to directory-level linking** for config directories
2. **Keep file-level linking** only for sensitive paths like `Library/`
3. **Update generate-mappings.sh** to distinguish between these cases

### Files Modified

- `scripts/generate-mappings.sh` - Creates JSON mappings (file-level currently)
- `scripts/link.sh` - Uses JSON mappings for linking
- `common/bin/dots` - Updated clean command to use mappings
- Directory structure completely reorganized

### Commands to Check Current State

```bash
# Check symlink status
dots status

# Check what's mapped
cat .mappings/macos.json | head -10

# See oh-my-posh error
# Open new terminal - should show CONFIG ERROR

# Check git status of dotfiles
cd ~/repos/nikbrunner/dots && git status
```

### Key Files for Next Claude

1. **`scripts/generate-mappings.sh`** - Core mapping generation logic
2. **`scripts/link.sh`** - Core linking script using mappings  
3. **`.mappings/macos.json`** - Current file-level mappings
4. **`common/bin/dots`** - Updated status/clean commands

### User Preference

- User prefers **mapping-based approach** (fast, precise)
- User wants **two JSON files only**: `macos.json` and `linux.json`
- User concerned about **Library directory safety** (don't symlink entire Library)
- User wants **file-level for sensitive directories**, **directory-level for config tools**

### Next Steps

1. **Fix generate-mappings.sh** to create hybrid approach:
   - Directory-level for config tools (kitty, tmux, etc.)
   - File-level for sensitive paths (Library/, specific files)
2. **Test oh-my-posh** works after fix
3. **Clean up backup files** once working
4. **Commit the new structure**

### Context Notes

- User has been very happy with progress
- User understands the technical details
- User prefers concise communication
- This refactor represents major improvement in dotfiles organization
- The mapping approach is innovative and user loves the concept

## Error Details

Oh-my-posh config error suggests `/Users/nbr/.config/oh-my-posh/nbr.omp.json` symlink not working correctly for the application. Directory structure may be expected by oh-my-posh rather than individual file symlinks.

The `dfs` command shows mixed typechanges and deletions, indicating git is tracking the transition from directory symlinks to file symlinks inconsistently.