# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

A symlink-based dotfiles management system for deploying configuration files across macOS and Arch Linux machines. Configuration files live in this repository and are symlinked to their expected home directory locations.

## Directory Structure

```
dots/
├── symlinks.yml          # Symlink definitions with OS-specific sections
├── common/               # Cross-platform configs (mirrors ~/)
│   ├── .config/          # Tool configurations
│   ├── .local/bin/       # Custom scripts (wildcard-linked)
│   └── .zshrc, etc.      # Root dotfiles
├── macos/                # macOS-specific configs
├── arch/                 # Arch Linux-specific configs
└── scripts/              # Core management scripts
```

## Commands

### Dotfiles Management (`dots`)

```bash
dots install [--dry-run] [--no-deps]  # Complete machine setup
dots link [--dry-run] [--verbose]     # Update all symlinks
dots sync                              # Git pull + submodule updates
dots status                            # Git and symlink status
dots test                              # Comprehensive system tests
dots deps [check|install|validate]    # Dependency management
dots commit                            # Open LazyGit
dots push [--force]                    # Push to remote

# Submodules
dots sub-add <url> <path>             # Add submodule
dots sub-update                        # Update all submodules
dots sub-commit                        # Commit submodule hash changes
dots sub-status                        # Show submodule status

# Utilities
dots theme [--debug]                   # Interactive theme selector
dots font                              # Interactive font selector
dots mcp [--dry-run] [--force]        # Configure Claude Code MCPs
dots open                              # Open dots in $EDITOR
dots remove <path>                     # Untrack path from git
```

### Repository Management (`repos`)

```bash
repos open                # Open a repository in tmux (with fzf)
repos find                # Search files across all repos
repos status              # Git status for all repositories
repos add <url>           # Clone repo to organized location
repos setup               # Clone all repos from ENSURE_CLONED list
```

### Git Operations (`repo`)

```bash
repo commit               # Open lazygit
repo commit -s [-y] [-p]  # AI-generated commit message
repo branch "name"        # Create branch with exact name
repo branch -s "desc"     # AI-generated branch name
```

Git aliases: `git sc` → `repo commit -s`, `git sb` → `repo branch -s`

## Symlink Configuration

The `symlinks.yml` file defines all symlinks with OS-specific sections:

- **Section names** must match OS detection output: `common`, `macos`, `arch`
- **Processing order**: `common` section loads first, then platform-specific section
- **Wildcard patterns**: `"common/.local/bin/*": "~/.local/bin"` links individual files
- **Backups**: Existing files are backed up as `.<name>.backup.YYYYMMDD_HHMMSS`

### Managing Configurations

**Add**: Place file in `common/` or `<os>/` → add entry to `symlinks.yml` → `dots link`

**Remove**: Delete file → remove from `symlinks.yml` → `dots link` (cleans broken links)

**Move/Rename**: Move file in repo → `dots link` (auto-removes old, creates new)

## Claude Code MCP Setup

MCP servers are defined in `common/.claude/mcp-servers.json` and configured per-machine:

```bash
# Set API keys in .zshrc
export EXA_API_KEY='...'
export REF_API_KEY='...'

# Configure MCPs
dots mcp
```

Available servers: `exa` (web search), `Ref` (docs lookup), `chrome-devtools` (browser automation)

## Black Atom Theme Integration

Theme files in this repo are symlinks to Black Atom adapter repos:

```
~/.config/ghostty/themes/  →  dots/common/.config/ghostty/themes/  →  black-atom-industries/ghostty/
```

Run `dots theme-link` to create/update relative symlinks to Black Atom repos.

## Key Files

- `common/.local/bin/dots` - Main CLI implementation
- `scripts/symlinks.sh` - Symlink creation logic
- `scripts/detect-os.sh` - OS detection (`macos`, `arch`, `linux`)
- `scripts/deps/` - Dependency management (install.sh dispatcher, macos.sh, arch.sh)

## Environment Variables

- `DOTS_DIR` - Override dots directory (default: `~/repos/nikbrunner/dots`)

## Notes

- Run `dots test` to validate the system (includes shellcheck linting)
- Use `dots link --dry-run` to preview symlink operations
- This repository is personal and not intended for public use
