# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a symlink-based dotfiles management system designed to organize and deploy configuration files across multiple machines. The system uses symlinks to link configuration files from this repository to their expected locations in the home directory.

## Core Architecture

### Symlink System

- Configuration files live in `~/repos/nikbrunner/dots/` but are symlinked to their standard locations
- The `scripts/link.sh` script creates all symlinks with backup functionality
- Running `dots link` automatically backs up existing files with timestamps before creating symlinks

### Directory Structure

- `common/` - Cross-platform configuration files that mirror home directory structure
  - Root dotfiles (.zshrc, .gitconfig, etc.)
  - `.config/` directory with tool configurations
  - `bin/` directory with custom scripts
- `macos/` - macOS-specific configurations that mirror home directory structure
- `linux/` - Linux-specific configurations that mirror home directory structure
- `scripts/` - Core management scripts (link.sh, detect-os.sh, submodules.sh)

## Common Commands

```bash
# Check status of git repo and all symlinks
dots status

# Update all symlinks (removes broken + creates/updates new)
dots link [--dry-run]

# Interactive committing with LazyGit
dots commit

# Push commits to remote
dots push [--force]

# Pull latest changes and update submodules
dots sync

# Add a new submodule
dots sub-add <repo-url> <target-path>

# Commit submodule hash updates
dots sub-commit

# Run comprehensive system tests
dots test
```

## Managing Configurations

### Adding New Configurations

1. Add config files directly to the appropriate directory structure:
   - For cross-platform configs: Place in `common/` following home directory structure
   - For OS-specific configs: Place in `macos/` or `linux/` following home directory structure
   - Example: For a new tool config, create `common/.config/toolname/config`
2. Run `dots link` to update all symlinks (this also removes any broken symlinks)
3. Mappings are auto-generated when outdated - no manual updates needed
4. Verify with `dots test` to ensure everything is working correctly

### Removing Configurations

1. Delete the file from the repository (`common/`, `macos/`, or `linux/`)
2. Run `dots link` to update symlinks (broken symlinks are automatically removed)
3. The original symlink in your home directory will be cleaned up

### Renaming/Moving Configurations

1. Rename or move the file within the repository
   - Example: `mv common/bin/ide common/bin/tmux-layout-ide`
2. Run `dots link` to update everything:
   - The old symlink (`~/bin/ide`) is automatically removed
   - A new symlink (`~/bin/tmux-layout-ide`) is created
3. No manual cleanup needed - it just works!

## Symlink System

The system uses direct directory traversal for precise file-level symlinks. All files in `common/`, `macos/`, and `linux/` directories are automatically discovered and symlinked.

### Symlink System

- **File-level linking only**: Every file is individually symlinked (no directory symlinks)
- **Direct traversal**: Files are discovered by scanning the source directories directly
- **Automatic parent directory creation**: Parent directories are created as needed when symlinking files

### Common (Cross-platform) Files

- `common/.zshrc` → `~/.zshrc`
- `common/.gitconfig` → `~/.gitconfig`
- `common/.config/yazi/yazi.toml` → `~/.config/yazi/yazi.toml`
- `common/.config/oh-my-posh/nbr.omp.json` → `~/.config/oh-my-posh/nbr.omp.json`
- `common/bin/dots` → `~/bin/dots`
- All files in `common/` are individually mapped and symlinked

### macOS-specific Files

- `macos/.config/karabiner/karabiner.json` → `~/.config/karabiner/karabiner.json`
- `macos/Library/Application Support/Claude/claude_desktop_config.json` → `~/Library/Application Support/Claude/claude_desktop_config.json`
- `macos/Brewfile` → `~/Brewfile`
- All files in `macos/` are individually mapped and symlinked

### Linux-specific Files

- All files in `linux/` are individually mapped and symlinked (when on Linux systems)

## Backup Files

When using `dots link`, backups are created with timestamp format: `.<name>.backup.YYYYMMDD_HHMMSS`

## Environment Variables

- `DOTS_DIR` - Override default dots directory location (default: `~/repos/nikbrunner/dots`)

## OS Detection

The system uses `scripts/detect-os.sh` to detect the operating system and conditionally create OS-specific symlinks. Currently supports macOS and Linux detection.

## Testing and Validation

The `dots test` command provides comprehensive system validation:

- Repository structure checks
- OS detection verification
- Mapping generation testing
- JSON mapping file validation
- Symlink creation testing (dry-run)
- Critical symlink verification
- Git repository status
- Shell script linting with shellcheck

Use `dots test` for overall system health checks and `dots link --dry-run` for detailed symlink operation previews.

## Recent Changes

- **Simplified Architecture**: Removed JSON mapping system in favor of direct directory traversal (~60% code reduction)
- **Simplified Workflow**: `dots link` now handles both creating/updating symlinks AND removing broken ones
- **Manual File Management**: Add files directly to `common/`, `macos/`, or `linux/` directories instead of using commands
- **Improved Commit Workflow**: `dots commit` opens LazyGit for interactive committing, `dots push` only pushes
- **Enhanced Testing**: `dots test` includes shellcheck linting for script quality
- **Gum Integration**: Beautiful CLI interface when gum is installed
- **Submodule Integration**: Submodules are now added directly to their target locations (e.g., `common/.config/nvim`)

## Submodules

Submodules are added directly to their target configuration locations. To add a submodule:

```bash
dots sub-add https://github.com/nikbrunner/nbr.nvim common/.config/nvim
```

Current submodules:

- `common/.config/nvim` - Neovim configuration (https://github.com/nikbrunner/nbr.nvim)

Future submodules:

- `common/.config/wezterm` - WezTerm configuration

Regular configuration files (NOT submodules):

- `common/.config/zed/` - Zed editor configuration

## Memories

- Remember to run commands like `dots test` to check if everything is working
- Use `dots add` to easily add new configuration files to the repository
- The system automatically handles relative paths and directory structures
- All shell scripts pass shellcheck linting for quality assurance
- This repository is only for me and nobody else
