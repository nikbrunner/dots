# Claude Code Handover - Dots Migration

## Mission Brief
Create a new dotfiles repository (`nikbrunner/dots`) with proper structure and migrate existing configs from the current bare repo setup to the new symlink-based system.

## Background Context
- **Current setup**: Bare git repo at `~/.dotfiles` with `df` alias commands
- **Target**: New `~/repos/nikbrunner/dots` repo with symlink-based architecture
- **Goal**: Migrate configs into organized structure + create management scripts

## Repository Structure to Create

```
~/repos/nikbrunner/dots/
├── README.md
├── install.sh           # Main setup script
├── scripts/
│   ├── link.sh          # Symlink management
│   ├── detect-os.sh     # OS detection utilities
│   └── submodules.sh    # Git submodule management
├── config/              # Shared configs (gets symlinked)
│   ├── zsh/
│   │   └── .zshrc
│   ├── git/
│   │   ├── .gitconfig
│   │   └── .gitignore
│   ├── yazi/
│   ├── lazygit/
│   ├── bat/
│   ├── tmux/
│   ├── gallery-dl/
│   ├── oh-my-posh/
│   └── ...
├── os-specific/         # OS-specific configs
│   ├── macos/
│   │   └── Library/Application Support/Claude/claude_desktop_config.json
│   └── linux/
│       └── .config/Claude/claude_desktop_config.json
├── scripts-custom/      # User's custom scripts from ~/.scripts/
└── submodules/          # Git submodules (to be added later)
    ├── nvim/            # → ~/.config/nvim
    ├── wezterm/         # → ~/.config/wezterm  
    └── zed/             # → ~/.config/zed (private)
```

## Files to Migrate

**From current bare repo to new structure:**

### Core Configs → `config/`
- `.zshrc` → `config/zsh/.zshrc`
- `.gitconfig` → `config/git/.gitconfig`
- `.gitignore` → `config/git/.gitignore`
- `.vimrc` → `config/vim/.vimrc`
- `.ideavimrc` → `config/vim/.ideavimrc`
- `.config/yazi/` → `config/yazi/`
- `.config/lazygit/` → `config/lazygit/`
- `.config/bat/` → `config/bat/`
- `.config/tmux/` → `config/tmux/`
- `.config/gallery-dl/` → `config/gallery-dl/`
- `.config/oh-my-posh/` → `config/oh-my-posh/`
- `.config/karabiner/` → `config/karabiner/`
- `.config/kitty/` → `config/kitty/`
- `.config/ghostty/` → `config/ghostty/`
- `.hushlogin` → `config/shell/.hushlogin`

### Scripts → `scripts-custom/`
- `.scripts/` → `scripts-custom/`

### OS-Specific → `os-specific/macos/`
- `Library/Application Support/Claude/claude_desktop_config.json` → `os-specific/macos/Library/Application Support/Claude/claude_desktop_config.json`
- `Brewfile` → `os-specific/macos/Brewfile`

### Skip These (will be submodules)
- `.config/wezterm/` (will be submodule)
- `.config/zed/` (will be private submodule)
- `.config/nvim/` (already separate repo)

## Scripts to Create

### 1. `scripts/detect-os.sh`
```bash
#!/bin/bash
# Detect operating system
# Returns: "macos", "linux", "windows"

get_os() {
    case "$OSTYPE" in
        darwin*)  echo "macos" ;;
        linux*)   echo "linux" ;;
        msys*)    echo "windows" ;;
        *)        echo "unknown" ;;
    esac
}
```

### 2. `scripts/link.sh`
```bash
#!/bin/bash
# Creates symlinks for dotfiles based on OS
# Usage: ./scripts/link.sh [--force]

# Should handle:
# - OS detection
# - Creating necessary directories
# - Symlinking configs to proper locations
# - Backing up existing files (optional)
# - Handling OS-specific configs
```

### 3. `install.sh`
```bash
#!/bin/bash
# Main installation script
# Usage: ./install.sh

# Should:
# 1. Detect OS
# 2. Run submodule initialization
# 3. Run link.sh
# 4. Set up dots command
# 5. Print success message with next steps
```

### 4. `scripts/submodules.sh`
```bash
#!/bin/bash
# Git submodule management
# Functions for adding, updating, removing submodules
```

## Command System to Implement

Create a `dots` command (symlinked to `~/.local/bin/dots`) with these functions:
```bash
dots install    # Initial setup with symlinks and submodules
dots link       # Re-run symlink creation  
dots sync       # Git pull + submodule updates
dots push       # Git add, commit, push
dots clean      # Remove broken symlinks
dots sub-update # Update all submodules
dots sub-add    # Add new submodule
```

## Symlink Mapping Reference

**Target symlinks to create:**
```bash
# Core configs
~/.zshrc → ~/repos/nikbrunner/dots/config/zsh/.zshrc
~/.gitconfig → ~/repos/nikbrunner/dots/config/git/.gitconfig
~/.gitignore → ~/repos/nikbrunner/dots/config/git/.gitignore
~/.vimrc → ~/repos/nikbrunner/dots/config/vim/.vimrc
~/.ideavimrc → ~/repos/nikbrunner/dots/config/vim/.ideavimrc

# Config directories
~/.config/yazi → ~/repos/nikbrunner/dots/config/yazi
~/.config/lazygit → ~/repos/nikbrunner/dots/config/lazygit
~/.config/bat → ~/repos/nikbrunner/dots/config/bat
~/.config/tmux → ~/repos/nikbrunner/dots/config/tmux
~/.config/gallery-dl → ~/repos/nikbrunner/dots/config/gallery-dl
~/.config/oh-my-posh → ~/repos/nikbrunner/dots/config/oh-my-posh
~/.config/karabiner → ~/repos/nikbrunner/dots/config/karabiner
~/.config/kitty → ~/repos/nikbrunner/dots/config/kitty
~/.config/ghostty → ~/repos/nikbrunner/dots/config/ghostty

# Scripts
~/.scripts → ~/repos/nikbrunner/dots/scripts-custom

# OS-specific (macOS)
~/Library/Application Support/Claude/claude_desktop_config.json → ~/repos/nikbrunner/dots/os-specific/macos/Library/Application Support/Claude/claude_desktop_config.json

# Submodules (for later)
~/.config/nvim → ~/repos/nikbrunner/dots/submodules/nvim
~/.config/wezterm → ~/repos/nikbrunner/dots/submodules/wezterm
~/.config/zed → ~/repos/nikbrunner/dots/submodules/zed
```

## Success Criteria

1. **Repo created** with proper structure
2. **All configs migrated** to appropriate folders
3. **Scripts created** and functional
4. **Symlinks work** when tested
5. **dots command** operational
6. **README.md** documents the system
7. **Ready for submodule addition**

## Deliverable

Please create a detailed report covering:
- What was created/migrated
- Any issues encountered
- Test results (did symlinks work?)
- Next steps needed
- File tree of final structure

## Notes

- Don't worry about git submodules yet - focus on structure + scripts
- Test the symlink system before finalizing
- Use `ln -sf` for force overwriting during development
- Make scripts executable (`chmod +x`)

Good luck! 🚀
