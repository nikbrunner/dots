# dots

A clean, organized dotfiles repository using symlinks for easy management and deployment.

## 📚 Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Usage](#usage)
  - [Core Commands](#core-commands)
  - [Managing Configurations](#managing-configurations)
- [How It Works](#how-it-works)
- [Black Atom Theme Integration](#black-atom-theme-integration)
- [Platform Support](#platform-support)
- [Useful Links](#useful-links)

## Overview

This dotfiles system uses a unified YAML configuration for symlink management:

- Configuration files live in this repository organized by platform
- Symlinks are defined in a single `symlinks.yml` file with OS-specific sections
- Running `dots link` updates everything automatically (removes broken symlinks + creates new ones)
- Supports wildcard patterns for flexible file management (e.g., `"common/.local/bin/*": "~/.local/bin"`)
- Eliminates duplication with shared common entries across platforms

## Installation

### Prerequisites

Before cloning, set up SSH access to GitHub via 1Password:

**macOS:**

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install 1Password
brew install --cask 1password
```

**Arch Linux (EndeavourOS):**

```bash
# yay is pre-installed on EndeavourOS
yay -S 1password
```

**Then configure 1Password SSH:**

1. Open 1Password and sign in
2. Add your SSH key (or create one: **+ New Item → SSH Key**)
3. Enable the SSH agent: **Settings → Developer → SSH Agent**
4. Verify: `ssh -T git@github.com` should show "Hi username!"

### Complete Machine Setup

```bash
git clone git@github.com:nikbrunner/dots.git ~/repos/nikbrunner/dots
cd ~/repos/nikbrunner/dots
./scripts/install.sh
```

This will:

- Install all required dependencies (git, zsh, tmux, neovim, fzf, ripgrep, etc.)
- Configure system settings (default shell, Git signing)
- Create all symlinks
- Set up the `dots` command

**Manual Installation** (skip dependencies):

```bash
./scripts/install.sh --no-deps
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

**Troubleshooting**:

```bash
# Preview installation without making changes
./scripts/install.sh --dry-run

# Preview symlink operations
dots link --dry-run --verbose
```

## Usage

### Core Commands

- **`dots`** — Dotfiles management (pull, push, link, chores, deps). Run `dots` with no args for usage.
- **`brick`** — AI-powered git operations (commit, branch). Run `brick --help` for usage.
- **`helm`** — External tool for multi-repo management. Invoked by `dots pull` and `dots push`.

### Managing Configurations

#### Adding a Configuration

1. Place file in `common/` (cross-platform) or `macos/`/`arch/` (OS-specific), mirroring home directory structure
2. Add entry to `symlinks.yml` in the appropriate section
3. Run `dots link`

#### Removing a Configuration

1. Delete the file from the repository
2. Remove the entry from `symlinks.yml`
3. Run `dots link` (broken symlinks are automatically cleaned up)

#### Renaming/Moving a Configuration

1. Move the file in the repository
2. Run `dots link` (old symlink removed, new one created)

#### Preview Changes

```bash
dots link --dry-run --verbose
```

## How It Works

When you run `dots link`:

1. **Loads configuration**: Reads the `symlinks.yml` file for your platform
2. **Cleans up**: Removes any broken symlinks from previous configurations
3. **Processes entries**: Creates symlinks as defined in the configuration:
   - Directory symlinks for entire directories
   - File symlinks for individual files
   - Wildcard expansion for patterns like `"common/.local/bin/*": "~/.local/bin"`
4. **Backs up conflicts**: If a real file exists where a symlink should go, it's backed up with a timestamp (unless `--no-backup` is used)

**Options:**

- `--dry-run`: Preview what would happen without making changes
- `--no-backup`: Overwrite existing files instead of backing them up
- `--verbose`: Show detailed output for each symlink operation

### OS-Specific Configurations

Place OS-specific files in `macos/`, `linux/`, or `arch/` following the home directory structure. The system uses the `symlinks.yml` configuration file with OS-specific sections to define which files get symlinked.

**Important**: The YAML section names must match the OS detection output:

| Detected OS | YAML Section | Description                       |
| ----------- | ------------ | --------------------------------- |
| `common`    | `common:`    | Always processed on all platforms |
| `macos`     | `macos:`     | macOS systems                     |
| `arch`      | `arch:`      | Arch Linux systems                |

The system always processes the `common` section first, then adds the platform-specific section if it exists. OS detection is handled by `scripts/dots/detect-os.sh`.

## Black Atom Theme Integration

This dotfiles system integrates with [Black Atom Industries](https://github.com/black-atom-industries) theme adapters. The theme files in this repository are **symlinks** pointing to the Black Atom adapter repos, not copies of the actual theme files.

**Architecture:**

```
~/.config/ghostty/themes/black-atom-*.conf
        ↓ (symlink via dots link)
~/repos/nikbrunner/dots/common/.config/ghostty/themes/black-atom-*.conf
        ↓ (relative symlink via dots theme-link)
~/repos/black-atom-industries/ghostty/themes/**/*.conf
```

This two-layer approach means:

1. Your home directory links to dots (managed by `dots link`)
2. Dots links to Black Atom repos (managed by `scripts/dots/theme-link.sh`, run automatically by `dots link`)

**Why relative symlinks?**

The symlinks inside dots use **relative paths** (e.g., `../../../../../../black-atom-industries/ghostty/...`) so they work on any machine as long as both repos are cloned to the same relative locations.

Theme linking runs automatically as part of `dots link`. It can also be run directly:

```bash
scripts/dots/theme-link.sh [--dry-run]
```
