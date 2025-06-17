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
- `submodules/` - Git submodules for larger configs (nvim, wezterm, zed)

## Common Commands

```bash
# Check status of git repo and all symlinks
dots status

# Create/update symlinks (automatically backs up existing files)
dots link [--dry-run]

# Interactive committing with LazyGit
dots commit

# Push commits to remote
dots push [--force]

# Pull latest changes and update submodules
dots sync

# Add a new submodule
dots sub-add <repo-url> submodules/<name>

# Clean broken symlinks
dots clean [--dry-run]

# Run comprehensive system tests
dots test

# Format files (markdown, shell scripts, etc.)
dots format

# Add a file or directory to dots management
dots add <path>

# Remove a file or directory from dots management
dots remove <path>

# Install/reinstall git hooks
dots hooks
```

## Adding New Configurations

1. Add config files to the appropriate directory structure:
   - For cross-platform configs: Place in `common/` following home directory structure
   - For OS-specific configs: Place in `macos/` or `linux/` following home directory structure
   - Example: For a new tool config, place it in `common/.config/toolname/`
2. Run `dots link` to create symlinks (mappings are auto-generated if outdated)
3. No manual script updates needed - new files are automatically detected and mapped
4. Verify with `dots test` to ensure everything is working correctly

## Symlink Mappings

The system uses JSON-based mapping files for precise file-level symlinks. The `scripts/generate-mappings.sh` script creates mapping files that define exactly which files should be symlinked where.

### Mapping System

- **File-level linking only**: Every file is individually symlinked (no directory symlinks)
- **JSON mappings**: `.mappings/macos.json` and `.mappings/linux.json` define source→target mappings
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

Use `dots test` for overall system health checks and `dots link --dry-run` for detailed symlink operation previews.

## Recent Enhancements

- **File Management**: Use `dots add <path>` and `dots remove <path>` for managing files in dots repository
- **Relative Path Support**: `dots add` now supports relative paths when run from any directory
- **Improved Commit Workflow**: `dots commit` opens LazyGit for interactive committing, `dots push` only pushes
- **Formatting**: `dots format` automatically formats markdown and shell scripts
- **Git Hooks**: Automatic broken symlink cleanup on commit via pre-commit hooks
- **Enhanced Testing**: `dots test` includes shellcheck linting for script quality
- **Gum Integration**: Beautiful CLI interface when gum is installed

## Memories

- Remember to run commands like `dots test` to check if everything is working
- Use `dots add` to easily add new configuration files to the repository
- The system automatically handles relative paths and directory structures
- All shell scripts pass shellcheck linting for quality assurance
- This repository is only for me and nobody else