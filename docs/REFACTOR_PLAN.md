# Dotfiles Refactor Plan: Mirror Home Directory Structure

## Overview

This document outlines the plan to refactor the dotfiles repository to use a more intuitive structure where the repository layout exactly mirrors the home directory structure.

## Current vs New Structure

### Current Structure
```
dots/
├── config/
│   ├── zsh/.zshrc           # Maps to ~/.zshrc
│   ├── git/.gitconfig       # Maps to ~/.gitconfig
│   └── yazi/                # Maps to ~/.config/yazi/
├── os-specific/
│   └── macos/
└── scripts-custom/          # Maps to ~/.scripts/
```

### New Structure
```
dots/
├── common/                  # Cross-platform configs
│   ├── .zshrc              # → ~/.zshrc
│   ├── .gitconfig          # → ~/.gitconfig
│   ├── .config/
│   │   ├── yazi/           # → ~/.config/yazi/
│   │   ├── tmux/           # → ~/.config/tmux/
│   │   └── ...
│   └── .scripts/           # → ~/.scripts/
├── macos/                   # macOS-only configs
│   ├── .config/
│   │   └── karabiner/      # → ~/.config/karabiner/
│   ├── Library/
│   │   └── Application Support/Claude/  # → ~/Library/Application Support/Claude/
│   └── Brewfile            # → ~/Brewfile
└── linux/                   # Linux-only configs
    └── .config/
        └── ...

```

## Benefits

1. **Self-documenting**: The path in the repo IS the path in home
2. **Intuitive**: No mental mapping required
3. **Simpler scripts**: Recursive linking instead of hardcoded paths
4. **Clear OS separation**: OS-specific files are obviously separated

## Implementation Steps

### Phase 1: Create New Structure

1. Create new directories:
   ```bash
   mkdir -p common/.config
   mkdir -p macos/.config
   mkdir -p linux/.config
   ```

2. Move common configs:
   ```bash
   # Root dotfiles
   mv config/zsh/.zshrc common/
   mv config/git/.gitconfig common/
   mv config/git/.gitignore common/
   mv config/vim/.vimrc common/
   mv config/vim/.ideavimrc common/
   mv config/shell/.hushlogin common/
   
   # .config directories
   mv config/yazi common/.config/
   mv config/lazygit common/.config/
   mv config/bat common/.config/
   mv config/tmux common/.config/
   mv config/kitty common/.config/
   mv config/ghostty common/.config/
   mv config/oh-my-posh common/.config/
   mv config/gallery-dl common/.config/
   
   # Scripts
   mv scripts-custom common/.scripts
   ```

3. Move macOS-specific configs:
   ```bash
   mv config/karabiner macos/.config/
   mv os-specific/macos/Library macos/
   mv os-specific/macos/Brewfile macos/
   ```

4. Move git completion files:
   ```bash
   mkdir -p common/.config/.zsh
   mv config/zsh/_git common/.config/.zsh/
   mv config/zsh/git-completion.bash common/.config/.zsh/
   ```

### Phase 2: Rewrite link.sh

Create a new recursive linking function:

```bash
#!/bin/bash

# Recursive function to create symlinks
link_recursive() {
    local source_dir="$1"
    local target_dir="$2"
    
    # Create target directory if it doesn't exist
    mkdir -p "$target_dir"
    
    # Process each item in source directory
    for item in "$source_dir"/{.,}*; do
        # Skip . and ..
        [[ "$item" == "$source_dir/." ]] || [[ "$item" == "$source_dir/.." ]] && continue
        
        local basename=$(basename "$item")
        local target="$target_dir/$basename"
        
        if [[ -d "$item" ]] && [[ ! -L "$item" ]]; then
            # It's a directory, recurse
            link_recursive "$item" "$target"
        elif [[ -f "$item" ]] || [[ -L "$item" ]]; then
            # It's a file or symlink, create symlink
            create_symlink "$item" "$target"
        fi
    done
}

# Main linking logic
echo "Linking common files..."
link_recursive "$DOTS_DIR/common" "$HOME"

# OS-specific linking
if [[ "$(get_os)" == "macos" ]]; then
    echo "Linking macOS-specific files..."
    link_recursive "$DOTS_DIR/macos" "$HOME"
elif [[ "$(get_os)" == "linux" ]]; then
    echo "Linking Linux-specific files..."
    link_recursive "$DOTS_DIR/linux" "$HOME"
fi
```

### Phase 3: Update dots Command

The status command should dynamically discover symlinks:

```bash
# Find all symlinks pointing to our dots directory
find "$HOME" -type l -exec readlink {} \; 2>/dev/null | grep "$DOTS_DIR" | while read -r target; do
    # Check if symlink is valid
done
```

### Phase 4: Migration for Existing Users

For users who have already set up the dotfiles:

```bash
# 1. Remove all existing symlinks
dots clean

# 2. Pull the latest changes
git pull

# 3. Re-run the linking
dots link --force
```

### Phase 5: Update Documentation

1. Update README.md with new structure
2. Update CLAUDE.md with new paths
3. Add this refactor as a completed task in FILE_CHECKLIST.md

## Testing Plan

1. Test on a fresh macOS system
2. Test on a Linux system (when available)
3. Verify all symlinks are created correctly
4. Test dots commands work as expected
5. Ensure backups are created properly with --force

## Rollback Plan

If issues arise:
1. Keep the old structure in a branch
2. Can revert and re-link using old link.sh
3. All user configs are safe (either symlinked or backed up)

## Timeline

- Phase 1-2: Restructure and rewrite scripts
- Phase 3-4: Update commands and test
- Phase 5: Update documentation
- Total estimated time: 2-3 hours of focused work