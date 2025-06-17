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
- `common/` - Cross-platform configuration files that mirror home directory structure
  - Root dotfiles (.zshrc, .gitconfig, etc.)
  - `.config/` directory with tool configurations
  - `bin/` directory with custom scripts
- `macos/` - macOS-specific configurations that mirror home directory structure
- `linux/` - Linux-specific configurations that mirror home directory structure
- `scripts/` - Core management scripts (link.sh, detect-os.sh, submodules.sh)
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

1. Add config files to the appropriate directory structure:
   - For cross-platform configs: Place in `common/` following home directory structure
   - For OS-specific configs: Place in `macos/` or `linux/` following home directory structure
   - Example: For a new tool config, place it in `common/.config/toolname/`
2. Run `dots link` to create symlinks (the recursive linking will handle new files automatically)
3. No manual script updates needed - the structure is self-documenting

## Symlink Mappings

The system now uses recursive linking where the repository structure exactly mirrors the home directory:

### Common (Cross-platform) Files
- `common/.zshrc` → `~/.zshrc`
- `common/.gitconfig` → `~/.gitconfig`
- `common/.config/yazi/` → `~/.config/yazi/`
- `common/bin/` → `~/bin/`
- All files in `common/` are recursively symlinked to `~/`

### macOS-specific Files
- `macos/Library/Application Support/Claude/` → `~/Library/Application Support/Claude/`
- `macos/Brewfile` → `~/Brewfile`
- All files in `macos/` are recursively symlinked to `~/`

### Linux-specific Files
- All files in `linux/` are recursively symlinked to `~/` (when on Linux systems)

## Backup Files

When using `dots link --force`, backups are created with timestamp format: `.<name>.backup.YYYYMMDD_HHMMSS`

## Environment Variables

- `DOTS_DIR` - Override default dots directory location (default: `~/repos/nikbrunner/dots`)

## OS Detection

The system uses `scripts/detect-os.sh` to detect the operating system and conditionally create OS-specific symlinks. Currently supports macOS and Linux detection.