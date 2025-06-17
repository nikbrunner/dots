# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a symlink-based dotfiles management system designed to organize and deploy configuration files across multiple machines. The system uses symlinks to link configuration files from this repository to their expected locations in the home directory.

## Core Architecture

### Symlink System
- Configuration files live in `~/repos/nikbrunner/dots/` but are symlinked to their standard locations
- The `scripts/link.sh` script creates all symlinks with backup functionality
- Running `dots link --force` backs up existing files with timestamps before creating symlinks

### Directory Structure
- `config/` - Contains all configuration files organized by tool
- `os-specific/` - OS-specific configurations (currently macOS only)
- `scripts/` - Core management scripts (link.sh, detect-os.sh, submodules.sh)
- `scripts-custom/` - User's custom scripts (symlinked to ~/.scripts)
- `submodules/` - Git submodules for larger configs (nvim, wezterm, zed)

## Common Commands

```bash
# Check status of git repo and all symlinks
dots status

# Create/update symlinks (use --force to backup existing files)
dots link [--force]

# Commit and push changes
dots push "commit message"

# Pull latest changes and update submodules
dots sync

# Add a new submodule
dots sub-add <repo-url> submodules/<name>

# Clean broken symlinks
dots clean
```

## Adding New Configurations

1. Add config files to appropriate directory in `config/`
2. Update `scripts/link.sh` to add the new symlink mapping:
   ```bash
   create_symlink "$DOTS_DIR/config/toolname/config" "$HOME/.config/toolname/config"
   ```
3. Update the symlink checking in `scripts-custom/dots` cmd_status function
4. Run `dots link` to create the symlink

## Symlink Mappings

Key symlinks created by the system:
- Individual files: `.zshrc`, `.gitconfig`, `.gitignore`, `.vimrc`, `.ideavimrc`, `.hushlogin`
- Config directories: `.config/yazi`, `.config/lazygit`, `.config/bat`, `.config/tmux`, `.config/karabiner`, `.config/kitty`, `.config/ghostty`, `.config/oh-my-posh`, `.config/gallery-dl`
- Scripts: `.scripts` → `scripts-custom/`
- macOS: `Library/Application Support/Claude/claude_desktop_config.json`

## Backup Files

When using `dots link --force`, backups are created with timestamp format: `.<name>.backup.YYYYMMDD_HHMMSS`

## Environment Variables

- `DOTS_DIR` - Override default dots directory location (default: `~/repos/nikbrunner/dots`)

## OS Detection

The system uses `scripts/detect-os.sh` to detect the operating system and conditionally create OS-specific symlinks. Currently supports macOS and Linux detection.