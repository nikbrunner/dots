# dots

A clean, organized dotfiles repository using symlinks for easy management and deployment.

## 📚 Table of Contents

- [Overview](#overview)
- [Structure](#-structure)
- [Installation](#-installation)
- [Usage](#-usage)
  - [Common Workflows](#common-workflows)
- [How It Works](#-how-it-works)
- [Submodules](#-submodules)
  - [Understanding Submodules](#understanding-submodules)
  - [Current Submodules](#current-submodules)
  - [Managing Submodules](#managing-submodules)
  - [Troubleshooting Submodules](#troubleshooting-submodules)
  - [Common Submodule Commands](#common-submodule-commands)
  - [Removal Plan](#removal-plan)
- [Dependencies](#-dependencies)
- [Platform Support](#-platform-support)

## Overview

This dotfiles system uses a simple symlink-based approach:

- Configuration files live in this repository organized by platform
- Files are symlinked to their expected locations in your home directory
- Running `dots link` updates everything automatically (removes broken symlinks + creates new ones)

## 📁 Structure

```
dots/
├── README.md                # This file
├── CLAUDE.md                # Claude Code instructions
├── IMPLEMENTATION_PLAN.md   # Detailed roadmap implementation plans
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

## 🚀 Installation

### Quick Install

```bash
git clone https://github.com/nikbrunner/dots.git ~/repos/nikbrunner/dots
cd ~/repos/nikbrunner/dots
./install.sh
```

### Manual Steps

1. Clone the repository:

   ```bash
   git clone https://github.com/nikbrunner/dots.git ~/repos/nikbrunner/dots
   ```

2. Run the installation script:

   ```bash
   cd ~/repos/nikbrunner/dots
   ./install.sh
   ```

3. Add `~/.local/bin` to your PATH if not already present:
   ```bash
   echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```

## 📝 Usage

The `dots` command provides a unified interface for managing your dotfiles:

### Core Commands

| Command        | Description                                        | Options                                 |
| -------------- | -------------------------------------------------- | --------------------------------------- |
| `dots install` | Initial setup with symlinks and submodules         | `--dry-run`                             |
| `dots link`    | Update all symlinks (removes broken + creates new) | `--dry-run`, `--no-backup`, `--verbose` |
| `dots sync`    | Git pull + submodule updates                       | -                                       |
| `dots status`  | Show git and symlink status                        | -                                       |

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

| Command     | Description                    | Options |
| ----------- | ------------------------------ | ------- |
| `dots test` | Run comprehensive system tests | -       |

### Common Workflows

#### Adding a New Configuration

1. **Add the file** to the appropriate directory:
   - Cross-platform: `common/` (mirrors home directory structure)
   - OS-specific: `macos/` or `linux/` (mirrors home directory structure)
   - Example: `cp ~/.config/newtool/config common/.config/newtool/config`
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

#### Removing Backup Files

When `dots link` encounters existing files, it creates backups with timestamps (`.backup.YYYYMMDD_HHMMSS`). To clean these up:

```bash
# Preview what backup files would be deleted (dry run)
find /path/to/folder -name "*.backup.*" -type f -print

# Remove all backup files from the dots directory
find /path/to/folder -name "*.backup.*" -type f -delete
```

## 🔧 How It Works

### File Organization

- **`common/`**: Cross-platform configurations (used on all systems)
- **`macos/`**: macOS-specific configurations
- **`linux/`**: Linux-specific configurations

Each directory mirrors your home directory structure. For example:

- `common/.zshrc` → `~/.zshrc`
- `common/.config/git/config` → `~/.config/git/config`
- `macos/.config/karabiner/karabiner.json` → `~/.config/karabiner/karabiner.json`

### The Magic of `dots link`

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

## 🔗 Submodules

> **💡 Considering Simplification?** See [SUBMODULES_REMOVAL_PLAN.md](./SUBMODULES_REMOVAL_PLAN.md) for a detailed plan to remove submodules and simplify the workflow.

### Quick Reference

| Task                     | Command                                                         |
| ------------------------ | --------------------------------------------------------------- |
| Add submodule            | `dots sub-add git@github.com:user/repo.git common/.config/tool` |
| Update all submodules    | `dots sub-update`                                               |
| Commit submodule updates | `dots sub-commit`                                               |
| Check submodule status   | `dots sub-status`                                               |
| Sync repo + submodules   | `dots sync`                                                     |
| Fix broken symlinks      | `dots link`                                                     |

### Understanding Submodules

Git submodules allow you to include other Git repositories within your repository. In this dotfiles setup, we use submodules for larger configurations (like Neovim) that are maintained as separate repositories. Submodules are added directly to their target configuration locations, so they work seamlessly with the symlink system.

### Current Submodules

- `common/.config/nvim` - Neovim configuration ([nikbrunner/nbr.nvim](https://github.com/nikbrunner/nbr.nvim))

### Managing Submodules

#### Adding a New Submodule

```bash
# Using dots command (recommended)
dots sub-add git@github.com:username/repo.git common/.config/toolname

# What this does behind the scenes:
# 1. git submodule add git@github.com:username/repo.git common/.config/toolname
# 2. git submodule update --init --recursive common/.config/toolname
# 3. You still need to commit the changes
```

#### Cloning with Submodules

When cloning this repository on a new machine:

```bash
# Option 1: Clone with submodules included
git clone --recurse-submodules git@github.com:nikbrunner/dots.git ~/repos/nikbrunner/dots

# Option 2: Clone first, then initialize submodules
git clone git@github.com:nikbrunner/dots.git ~/repos/nikbrunner/dots
cd ~/repos/nikbrunner/dots
git submodule update --init --recursive

# Option 3: Just run install.sh (recommended - it handles everything)
./install.sh
# What install.sh does:
# - Detects .gitmodules file
# - Runs: scripts/submodules.sh update
# - Which runs: git submodule update --init --recursive
# - Then creates all symlinks with dots link
```

#### Updating Submodules

```bash
# Update all submodules to their latest commits (recommended)
dots sub-update
# What this does:
# 1. git submodule update --init --recursive
# 2. git submodule foreach 'git pull origin main || git pull origin master'

# Or using git directly
git submodule update --remote --merge

# Update a specific submodule manually
cd common/.config/nvim
git pull origin main
cd ../../..
git add common/.config/nvim
git commit -m "Update nvim submodule"
```

#### Syncing Repository (Pull + Update Submodules)

```bash
# Pull latest changes and update all submodules
dots sync
# What this does:
# 1. git pull origin main (or master)
# 2. If .gitmodules exists: scripts/submodules.sh update
# 3. Which runs: git submodule update --init --recursive
# 4. Then: git submodule foreach 'git pull origin main || git pull origin master'
```

#### Removing a Submodule

```bash
# Note: There's no dots command for this yet, use git directly:
git submodule deinit -f common/.config/toolname
rm -rf .git/modules/common/.config/toolname
git rm -f common/.config/toolname
git commit -m "Remove toolname submodule"
```

### Troubleshooting Submodules

#### Problem: Submodule directory is empty

```bash
# Initialize and update the submodule
git submodule update --init --recursive
```

#### Problem: Submodule is in detached HEAD state

```bash
cd common/.config/nvim
git checkout main
git pull origin main
```

#### Problem: Can't clone due to authentication

```bash
# Check your submodule URLs (should use SSH not HTTPS)
cat .gitmodules

# Update submodule URL if needed
git config submodule.common/.config/nvim.url git@github.com:nikbrunner/nbr.nvim.git
git submodule sync
```

#### Problem: Symlinks are broken after adding submodule

```bash
# Re-run the link command to fix all symlinks
dots link
```

### Common Submodule Commands

| Dots Command                | Git Command                                                                   | Description                          |
| --------------------------- | ----------------------------------------------------------------------------- | ------------------------------------ |
| `dots sub-add <url> <path>` | `git submodule add <url> <path>`                                              | Add a new submodule                  |
| `dots sub-update`           | `git submodule update --init --recursive`<br>`git submodule foreach git pull` | Update all submodules                |
| `dots sub-commit`           | `git add <submodules>`<br>`git commit -m "chore: update submodule hashes"`    | Commit submodule hash updates        |
| `dots sub-status`           | `git submodule status`<br>Show uncommitted changes                            | Show status of all submodules        |
| `dots sync`                 | `git pull` + submodule update                                                 | Pull changes & update submodules     |
| -                           | `git submodule sync`                                                          | Sync submodule URLs with .gitmodules |
| -                           | `git config status.submodulesummary 1`                                        | Show submodule summary in git status |
| -                           | `git diff --submodule`                                                        | Show submodule changes in diff       |

### Best Practices

1. **Use SSH URLs** for submodules (git@github.com:user/repo.git)
2. **Commit submodule changes** when you update them
3. **Keep submodules on a branch** (not detached HEAD)
4. **Document your submodules** in this README
5. **Test after adding** with `dots test` and `dots link`

### Removal Plan

If you're considering simplifying your workflow by removing submodules entirely, see the comprehensive [Submodules Removal Implementation Plan](./SUBMODULES_REMOVAL_PLAN.md) which includes:

- Step-by-step migration process
- Repository archival procedures
- Detailed pros/cons analysis
- Risk assessment and rollback plans
- Post-migration workflow examples

## 🛣️ Roadmap

- [x] Migrate wezterm
- [x] Remove `*backup` files
- [x] Archive old dotfiles
- [x] Make this repo public
- [x] Remove hooks
- [x] Add `sub-commit` command
- [x] Add `sub-status` command
- [ ] Refactor `dots` command (see [docs/DOTS_COMMAND_REFACTOR.md](./docs/DOTS_COMMAND_REFACTOR.md))
- [ ] Add test script
- [ ] Verify that install script is working
- [ ] Document `~/.ssh` setup

## 📦 Dependencies

- Git
- Bash 4+ (macOS users: `brew install bash`)
- Standard Unix tools (ln, mkdir, etc.)

## 🤝 Platform Support

- ✅ macOS (primary development)
- ✅ Linux (EndeavourOS/Arch)
- ❌ Windows (not supported)
