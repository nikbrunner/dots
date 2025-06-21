# dots

A clean, organized dotfiles repository using symlinks for easy management and deployment.

## 📚 Table of Contents

- [Overview](#overview)
- [Structure](#structure)
- [Installation](#installation)
- [Usage](#usage)
  - [Core Commands](#core-commands)
  - [Git Operations](#git-operations)
  - [Submodules](#submodules-1)
  - [Maintenance](#maintenance)
  - [Common Workflows](#common-workflows)
- [How It Works](#how-it-works)
- [Submodules](#submodules)
- [Roadmap](#roadmap)
- [Dependencies](#dependencies)
- [Platform Support](#platform-support)

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

1. Clone and install:

   ```bash
   git clone https://github.com/nikbrunner/dots.git ~/repos/nikbrunner/dots
   cd ~/repos/nikbrunner/dots
   ./install.sh
   ```

2. Add to PATH (if needed):
   ```bash
   echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```

## Usage

The `dots` command provides a unified interface for managing your dotfiles:

### Core Commands

#### Dotfiles Management (`dots`)

| Command        | Description                                        | Options                                 |
| -------------- | -------------------------------------------------- | --------------------------------------- |
| `dots install` | Initial setup with symlinks and submodules         | `--dry-run`                             |
| `dots link`    | Update all symlinks (removes broken + creates new) | `--dry-run`, `--no-backup`, `--verbose` |
| `dots sync`    | Git pull + submodule updates                       | -                                       |
| `dots status`  | Show git and symlink status                        | -                                       |
| `dots open`    | Open dots directory with `$EDITOR`                 | -                                       |
| `dots test`    | Run comprehensive system tests                     | -                                       |
| `dots format`  | Format repository files with prettier and shfmt    | `--check`                               |

#### Repository Manager (`repos`)

A minimal but powerful repository manager for organizing all your git repositories under `~/repos/username/repo-name/`:

| Command           | Description                                         | Options |
| ----------------- | --------------------------------------------------- | ------- |
| `repos find`      | Search and open files across all repositories      | -       |
| `repos open`      | Open a repository in tmux                          | -       |
| `repos status`    | Show git status for all repositories               | -       |
| `repos add <url>` | Clone a repository to organized location           | -       |
| `repos config`    | Edit repos configuration (ENSURE_CLONED list)      | -       |
| `repos setup`     | Clone all repositories from ENSURE_CLONED list     | -       |

#### Smart Commit (`git sc`)

An intelligent git commit helper (alias for `smart-commit`):
- Automatically generates meaningful commit messages using AI
- Analyzes your staged changes and creates conventional commits
- Follows best practices for commit message formatting
- Usage: Stage your changes with `git add`, then run `git sc`

### Git Operations

| Command       | Description                             | Options   |
| ------------- | --------------------------------------- | --------- |
| `dots commit` | Open LazyGit for interactive committing | -         |
| `dots push`   | Push commits to remote                  | `--force` |
| `dots log`    | Show recent commits                     | -         |

### Submodules

| Command           | Description                   | Options        |
| ----------------- | ----------------------------- | -------------- |
| `dots sub-update` | Update all submodules         | -              |
| `dots sub-add`    | Add new submodule             | `<url> <path>` |
| `dots sub-commit` | Commit submodule hash updates | -              |
| `dots sub-status` | Show status of all submodules | -              |

### Maintenance

| Command     | Description                                                                        | Options |
| ----------- | ---------------------------------------------------------------------------------- | ------- |
| `dots test` | Run comprehensive system tests (repository structure, OS detection, symlinks, etc) | -       |

### Common Workflows

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

## Roadmap

- [x] Migrate wezterm
- [x] Remove `*backup` files
- [x] Archive old dotfiles
- [x] Make this repo public
- [x] Remove hooks
- [x] Add `sub-commit` command
- [x] Add `sub-status` command
- [x] Add `format` command
- [x] Standardize bash across all scripts
- [ ] Refactor `dots` command (see [docs/DOTS_COMMAND_REFACTOR.md](./docs/DOTS_COMMAND_REFACTOR.md))
- [ ] Implement unified dependency management (see [docs/DEPENDENCY_MANAGEMENT.md](./docs/DEPENDENCY_MANAGEMENT.md))
- [ ] Implement repos cleanup workflow (see [docs/REPOS_CLEANUP_WORKFLOW.md](./docs/REPOS_CLEANUP_WORKFLOW.md))
- [ ] Add test script
- [ ] Verify that install script is working
- [ ] Document `~/.ssh` setup

## Dependencies

- **Git** - Version control operations
- **Bash 4+** - Modern shell features (associative arrays, etc.)
  - macOS: `brew install bash` (system bash 3.2 is too old)
  - Arch Linux: Modern bash included by default
  - Other Linux: Install via package manager
- **Standard Unix tools** - ln, mkdir, find, etc.

## Platform Support

- ✅ macOS (primary development)
- ✅ Linux (EndeavourOS/Arch)
- ❌ Windows (not supported)
