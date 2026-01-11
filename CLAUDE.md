# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a symlink-based dotfiles management system designed to organize and deploy configuration files across multiple machines. The system uses symlinks to link configuration files from this repository to their expected locations in the home directory.

## Core Architecture

### Symlink System

- Configuration files live in `~/repos/nikbrunner/dots/` but are symlinked to their standard locations
- Symlinks are defined in a single `symlinks.yml` file with OS-specific sections
- The `scripts/symlinks.sh` script creates all symlinks from the configuration with backup functionality
- Running `dots link` automatically backs up existing files with timestamps before creating symlinks
- Supports wildcard patterns (e.g., `"common/.local/bin/*": "~/.local/bin"`) for flexible file management

### Directory Structure

- `symlinks.yml` - Symlinks configuration with OS-specific sections
- `common/` - Cross-platform configuration files that mirror home directory structure
  - Root dotfiles (.zshrc, .gitconfig, etc.)
  - `.config/` directory with tool configurations
  - `.local/bin/` directory with custom scripts
- `macos/` - macOS-specific configurations that mirror home directory structure
- `linux/` - Linux-specific configurations that mirror home directory structure
- `arch/` - Arch-specific configurations that mirror home directory structure
- `scripts/` - Core management scripts (symlinks.sh, detect-os.sh, submodules.sh)

## Common Commands

```bash
# Complete machine setup with dependency installation
dots install [--dry-run] [--no-deps]

# Check status of git repo and all symlinks
dots status

# Update all symlinks (removes broken + creates/updates new)
dots link [--dry-run] [--no-backup] [--verbose]

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

# Show status of all submodules
dots sub-status

# Run comprehensive system tests
dots test

# Configure Claude Code MCP servers
dots mcp [--dry-run] [--force]
```

## Claude Code MCP Setup

MCP (Model Context Protocol) servers extend Claude Code's capabilities. This dotfiles repo includes a managed MCP configuration system.

### Configuration Files

- `common/.claude/mcp-servers.json` - MCP server definitions (no secrets)
- `common/.claude/settings.json` - Claude Code settings (hooks, permissions)
- `scripts/claude-mcp.sh` - Setup script for configuring MCPs

### Available MCP Servers

| Server | Purpose | Requires |
|--------|---------|----------|
| exa | Web search via Exa AI | `EXA_API_KEY` |
| Ref | Documentation lookup | `REF_API_KEY` |
| chrome-devtools | Browser automation | None |

### Setup

1. Set your API keys as environment variables (add to `.zshrc`):
   ```bash
   export EXA_API_KEY='your-exa-api-key'
   export REF_API_KEY='your-ref-api-key'
   ```

2. Run the MCP setup:
   ```bash
   dots mcp
   ```

3. Verify with Claude Code:
   ```bash
   claude mcp list
   ```

### Options

- `dots mcp --dry-run` - Preview what would be configured
- `dots mcp --force` - Re-add servers even if they already exist

### Notes

- MCP servers are stored in `~/.claude.json` (user scope)
- The `~/.claude.json` file is NOT synced via dotfiles (contains machine-specific state)
- Only the MCP definitions are synced; setup is done fresh on each machine

## Managing Configurations

### Adding New Configurations

1. Add config files directly to the appropriate directory structure:
   - For cross-platform configs: Place in `common/` following home directory structure
   - For OS-specific configs: Place in `macos/` or `arch/` following home directory structure
   - Example: For a new tool config, create `common/.config/toolname/config`
2. Edit `symlinks.yml` to add the symlink entry in the appropriate OS section
3. Run `dots link` to update all symlinks (this also removes any broken symlinks)
4. Verify with `dots test` to ensure everything is working correctly

### Removing Configurations

1. Delete the file from the repository (`common/`, `macos/`, or `arch/`)
2. Remove the entry from `symlinks.yml`
3. Run `dots link` to update symlinks (broken symlinks are automatically removed)
4. The original symlink in your home directory will be cleaned up

### Renaming/Moving Configurations

1. Rename or move the file within the repository
   - Example: `mv common/.local/bin/ide common/.local/bin/tmux-layout-ide`
2. Run `dots link` to update everything:
   - The old symlink (`~/.local/bin/ide`) is automatically removed
   - A new symlink (`~/.local/bin/tmux-layout-ide`) is created
3. No manual cleanup needed - it just works!

## Symlink System

The system uses a unified YAML manifest where symlinks are explicitly defined with OS-specific sections. This provides precise control over what gets linked while eliminating duplication.

### YAML Configuration with OS Sections

- **Unified file**: Single `symlinks.yml` file with `common`, `macos`, and `arch` sections
- **Critical**: YAML section names must exactly match OS detection output (`macos`, `arch`, `common`)
- **Processing order**: Always loads `common` first, then the detected OS section if it exists
- **Shared common entries**: 85% of entries are identical and defined once
- **Mixed linking**: Supports both directory-level and file-level symlinks
- **Wildcard patterns**: Use patterns like `"common/.local/bin/*": "~/.local/bin"` to link individual files into existing directories
- **Automatic parent directory creation**: Parent directories are created as needed when symlinking files

### Example YAML Structure

```yaml
# macOS configuration
macos:
  # Common entries (34 shared)
  "common/.config/nvim": "~/.config/nvim"
  "common/.local/bin/*": "~/.local/bin"
  # macOS-specific entries (7 unique)
  "macos/Brewfile": "~/Brewfile"

# Arch configuration
arch:
  # Same 34 common entries
  "common/.config/nvim": "~/.config/nvim"
  "common/.local/bin/*": "~/.local/bin"
  # Arch-specific entries (5 unique)
  "arch/.bashrc": "~/.bashrc"
```

### Benefits

- **85% less duplication**: Common entries defined once instead of duplicated
- **Single source of truth**: One file for all symlink configuration
- **Easy to maintain**: Clear separation of common vs OS-specific entries
- **YAML readability**: More human-readable than JSON

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

- **Claude Code MCP Setup**: Added `dots mcp` command to configure MCP servers across machines
- **Manual Configuration System**: Replaced auto-discovery with explicit `symlinks.yml` configuration file
- **Wildcard Pattern Support**: Added support for patterns like `"common/.local/bin/*"` for selective file linking
- **Massive Code Reduction**: Removed ~810 lines of auto-discovery code
- **74% Fewer Configuration Entries**: From 353 auto-discovered to 42 manually defined symlinks
- **Complete Machine Setup**: `dots install` provides full machine setup with automatic dependency installation
- **Cross-Platform Support**: Full support for macOS, Linux, and Arch Linux
- **Enhanced Testing**: `dots test` includes shellcheck linting for script quality
- **Regular Files**: nvim and wezterm configurations are now regular files in the repository (no longer submodules)

## Configuration Files

All configuration files are now stored directly in the repository:

- `common/.config/nvim/` - Neovim configuration
- `common/.config/wezterm/` - WezTerm configuration  
- `common/.config/zed/` - Zed editor configuration

## Memories

- Remember to run commands like `dots test` to check if everything is working
- Use `dots install` for complete machine setup including all dependencies
- The system automatically handles relative paths and directory structures
- All shell scripts pass shellcheck linting for quality assurance
- This repository is only for me and nobody else
- Always update CHANGELOG.md when making significant changes to track development progress
