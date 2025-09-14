# dots

A clean, organized dotfiles repository using symlinks for easy management and deployment.

## 📚 Table of Contents

- [Overview](#overview)
- [Structure](#structure)
- [Installation](#installation)
- [Usage](#usage)
  - [Core Commands](#core-commands)
    - [`dots` - Dotfiles Management](#dots---dotfiles-management)
    - [`repos` - Repository Manager](#repos---repository-manager)
    - [`repo` - Repository Operations](#repo---repository-operations)
- [`dots` Usage Examples](#dots-usage-examples)
  - [Adding a New Configuration](#adding-a-new-configuration)
  - [Removing a Configuration](#removing-a-configuration)
  - [Renaming/Moving a Configuration](#renamingmoving-a-configuration)
  - [Editing Configurations](#editing-configurations)
  - [Syncing Across Machines](#syncing-across-machines)
  - [Testing the System](#testing-the-system)
  - [Other Notable Commands](#other-notable-commands)
- [How It Works](#how-it-works)
  - [OS-Specific Configurations](#os-specific-configurations)
  - [Multiplexer Configuration](#multiplexer-configuration)
- [Submodules](#submodules)
- [Development](#development)
- [Dependencies](#dependencies)
- [Platform Support](#platform-support)
- [Useful Links](#useful-links)

## Overview

This dotfiles system uses a simple symlink-based approach:

- Configuration files live in this repository organized by platform
- Files are symlinked to their expected locations in your home directory
- Running `dots link` updates everything automatically (removes broken symlinks + creates new ones)

## Structure

```
dots/
├── README.md                # This file
├── CLAUDE.md                # Claude Code instructions
├── scripts/                 # Management scripts
│   ├── detect-os.sh         # OS detection utility
│   └── link.sh              # Symlink creation using direct traversal
├── common/                  # Cross-platform configurations
│   ├── .config/             # Config files (.zshrc, .gitconfig, etc.)
│   ├── bin/                 # Custom scripts
│   └── .zshrc, etc.         # Root dotfiles
├── macos/                   # macOS-specific configurations
│   ├── .config/karabiner/   # Karabiner configuration
│   ├── Library/             # Application Support files
│   └── Brewfile             # Homebrew dependencies
└── linux/                   # Linux-specific configurations
```

## Installation

**Complete Machine Setup** (recommended):

```bash
git clone https://github.com/nikbrunner/dots.git ~/repos/nikbrunner/dots
cd ~/repos/nikbrunner/dots
./install.sh
```

This will:
- Install all required dependencies (git, zsh, tmux, neovim, fzf, ripgrep, etc.)
- Configure system settings (default shell, Git signing)
- Create all symlinks
- Set up the `dots` command

**Manual Installation** (skip dependencies):

```bash
./install.sh --no-deps
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

**Troubleshooting**:

```bash
# For detailed diagnostics during installation
./install.sh --debug --dry-run

# For testing symlink operations
dots link --debug --dry-run
```

## Usage

The `dots` command provides a unified interface for managing your dotfiles:

### Core Commands

#### `dots` - Dotfiles Management

| Command           | Description                                                                        | Options                                 |
| ----------------- | ---------------------------------------------------------------------------------- | --------------------------------------- |
| `dots install`    | Complete machine setup with dependencies, symlinks and submodules                  | `--dry-run`, `--no-deps`                |
| `dots link`       | Update all symlinks (removes broken + creates new)                                 | `--dry-run`, `--no-backup`, `--verbose` |
| `dots sync`       | Git pull + submodule updates                                                       | -                                       |
| `dots status`     | Show git and symlink status                                                        | -                                       |
| `dots open`       | Open dots directory with `$EDITOR`                                                 | -                                       |
| `dots test`       | Run comprehensive system tests                                                     | -                                       |
| `dots format`     | Format repository files with prettier and shfmt                                    | `--check`                               |
| `dots commit`     | Open LazyGit for interactive committing                                            | -                                       |
| `dots push`       | Push commits to remote                                                             | `--force`                               |
| `dots log`        | Show recent commits                                                                | -                                       |
| `dots sub-update` | Update all submodules                                                              | -                                       |
| `dots sub-add`    | Add new submodule                                                                  | `<url> <path>`                          |
| `dots sub-commit` | Commit submodule hash updates                                                      | -                                       |
| `dots sub-status` | Show status of all submodules                                                      | -                                       |
| `dots test`       | Run comprehensive system tests (repository structure, OS detection, symlinks, etc) | -                                       |

#### `repos` - Repository Manager

A minimal but powerful repository manager for organizing all your git repositories under `~/repos/username/repo-name/`:

| Command           | Description                                    | Options |
| ----------------- | ---------------------------------------------- | ------- |
| `repos find`      | Search and open files across all repositories  | -       |
| `repos open`      | Open a repository in tmux                      | -       |
| `repos status`    | Show git status for all repositories           | -       |
| `repos add <url>` | Clone a repository to organized location       | -       |
| `repos config`    | Edit repos configuration (ENSURE_CLONED list)  | -       |
| `repos setup`     | Clone all repositories from ENSURE_CLONED list | -       |

#### `repo` - Repository Operations

Unified repository operations with optional AI assistance:

| Command                 | Description                             | Options                                             |
| ----------------------- | --------------------------------------- | --------------------------------------------------- |
| `repo commit`           | Open lazygit for interactive committing | -                                                   |
| `repo commit -s`        | Generate commit message with AI         | `-y` (auto-confirm), `-p` (push), `-f` (force push) |
| `repo branch "name"`    | Create branch with exact name           | -                                                   |
| `repo branch -s "desc"` | Generate branch name with AI            | `-y` (auto-create)                                  |

**Git Aliases:**

- `git sc` → `repo commit -s` (smart commit)
- `git sb` → `repo branch -s` (smart branch)

**Examples:**

- `repo commit -s -yp` - AI commit with auto-confirm and push
- `repo branch -s -y "BCD-123 fix login"` - AI branch name with auto-create

## `dots` Usage Examples

#### Adding a New Configuration

1. **Add the file** to the appropriate directory:
   - Cross-platform: `common/` (mirrors home directory structure)
   - OS-specific: `macos/` or `linux/` (mirrors home directory structure)
2. **Update symlinks**: `dots link`
3. **Commit changes**: `dots commit` (opens LazyGit)

#### Removing a Configuration

1. **Delete the file** from the repository
2. **Update symlinks**: `dots link` (broken symlinks are automatically removed)
3. **Commit changes**: `dots commit`

#### Renaming/Moving a Configuration

1. **Rename the file** in the repository:
   ```bash
   # Example: Rename a script
   mv common/bin/old-name common/bin/new-name
   ```
2. **Update symlinks**: `dots link`
   - Old symlink (`~/bin/old-name`) is automatically removed
   - New symlink (`~/bin/new-name`) is created
3. **Commit changes**: `dots commit`

#### Editing Configurations

1. **Edit files directly** in your home directory (they're symlinked!)
2. **Check changes**: `dots status`
3. **Commit changes**: `dots commit`

#### Syncing Across Machines

```bash
# On other machines
dots sync  # Pull latest changes and update submodules
dots link  # Update symlinks if needed
```

#### Testing the System

```bash
# Run comprehensive system tests (good before making changes)
dots test

# Preview what symlinks would be created (detailed output)
dots link --dry-run
```

The `dots test` command validates the entire system (repository structure, OS detection, symlink creation, etc.) and reports pass/fail status. Use `dots link --dry-run` when you want detailed output showing exactly what symlink operations would be performed.

#### Other Notable Commands

- Various helper scripts in `~/bin/` for development workflows
- Platform-specific utilities and configurations

## How It Works

When you run `dots link`:

1. **Cleans up**: Removes any broken symlinks from previous configurations
2. **Discovers files**: Scans `common/`, `macos/`, and `linux/` directories directly
3. **Creates/Updates**: Makes symlinks for all discovered files to their home directory locations
4. **Backs up conflicts**: If a real file exists where a symlink should go, it's backed up with a timestamp (unless `--no-backup` is used)

This single command handles all scenarios: adding, removing, renaming, or moving files.

**Options:**

- `--dry-run`: Preview what would happen without making changes
- `--no-backup`: Overwrite existing files instead of backing them up
- `--verbose`: Show detailed output for each symlink operation

### OS-Specific Configurations

Place OS-specific files in `macos/` or `linux/` following the home directory structure. The system automatically detects your OS and creates appropriate symlinks using direct directory traversal.

### Multiplexer Configuration

The terminal configuration supports switching between WezTerm and tmux as multiplexers while maintaining consistent keybindings. This allows you to use the same muscle memory regardless of which tool handles session/window/pane management.

**Switching multiplexers:**

To use **tmux as multiplexer**:
1. In `~/.config/wezterm/keymaps.lua`: Comment out the multiplexer bindings (lines 48-51)
2. In `~/.config/tmux/keymaps.conf`: Uncomment the source line (line 27)

To use **WezTerm as multiplexer** (default):
1. In `~/.config/wezterm/keymaps.lua`: Ensure multiplexer bindings are uncommented 
2. In `~/.config/tmux/keymaps.conf`: Ensure the source line is commented out

**How it works:**
- WezTerm loads multiplexer keybindings when uncommented, providing full session/window/pane management
- tmux loads multiplexer keybindings when uncommented, handling session/window/pane management
- Both configurations provide the same keybinding experience for navigation and management
- Simple comment/uncomment approach works reliably across all platforms and desktop environments

## Submodules

Current submodules:

- `common/.config/nvim` - Neovim configuration ([nikbrunner/nbr.nvim](https://github.com/nikbrunner/nbr.nvim))
- `common/.config/wezterm` - Wezterm configuration ([nikbrunner/wezterm](https://github.com/nikbrunner/wezterm))

Common commands:

- `dots sub-add <url> <path>` - Add new submodule
- `dots sub-update` - Update all submodules
- `dots sub-status` - Show submodule status
- `dots sub-commit` - Commit submodule hash updates

> **📖 Detailed Documentation**: See [docs/SUBMODULES.md](./docs/SUBMODULES.md) for comprehensive submodule management guide including troubleshooting, best practices, and removal planning.

## Development

**Current Status:**
- ✅ Complete machine setup with automatic dependency management
- ✅ Cross-platform support (macOS/Linux) with full Linux compatibility
- ✅ Comprehensive testing and validation
- ✅ Robust script compatibility across different bash environments

**Development Tasks:**
- See [TODO.md](./TODO.md) for current development priorities and planned features

## Dependencies

**Automatically installed by `dots install`:**
- **Git** - Version control operations
- **Zsh** - Modern shell with configuration
- **Tmux** - Terminal multiplexer for session management
- **Neovim** - Text editor with custom configuration
- **Fzf** - Fuzzy finder for interactive selection
- **Ripgrep** - Fast text search
- **Fd** - Fast file finder
- **Bat** - Syntax highlighting for file previews
- **Delta** - Enhanced git diff output
- **Lazygit** - Interactive git interface
- **Eza** - Modern ls replacement
- **Zoxide** - Smart directory jumper
- **Gum** - Enhanced CLI prompts and styling
- **GitHub CLI** - GitHub repository operations
- **1Password** - Password manager with SSH agent

**System requirements:**
- **Bash 4+** - Modern shell features
  - macOS: Installed automatically via Homebrew
  - Linux: Usually included by default
- **Standard Unix tools** - ln, mkdir, find, etc.

**Package Managers:**
- **macOS**: Homebrew (installed automatically if missing)
- **Arch Linux**: pacman, yay, or paru

## Platform Support

- ✅ macOS (primary development)
- ✅ Linux (EndeavourOS/Arch)
- ❌ Windows (not supported)

## Useful Links

- [Omarchy: Opinionated Arch/Hyprland Setup By DHH](https://omarchy.org/)
