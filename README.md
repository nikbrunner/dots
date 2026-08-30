# dots

A clean, organized dotfiles repository using symlinks for easy management and deployment.

## 📚 Table of Contents

- [Overview](#overview)
- [Installation](#installation)
  - [Prerequisites](#prerequisites)
  - [Complete Machine Setup](#complete-machine-setup)
- [Usage](#usage)
  - [Core Commands](#core-commands)
  - [Managing Configurations](#managing-configurations)
- [How It Works](#how-it-works)
  - [OS-Specific Configurations](#os-specific-configurations)
- [Black Atom Theme Integration](#black-atom-theme-integration)

## Overview

This dotfiles system uses a unified YAML configuration for symlink management:

- Configuration files live in this repository organized by platform
- Symlinks are defined in a single `symlinks.yml` file with OS-specific sections
- Running `dots link` updates everything automatically (removes broken symlinks + creates new ones)
- Supports wildcard patterns for flexible file management (e.g., `"common/.local/bin/*": "~/.local/bin"`)
- Eliminates duplication with shared common entries across platforms

## Installation

### Prerequisites

SSH access to GitHub via [ProtonPass](https://protonpass.github.io/pass-cli/) is required before cloning.

### Complete Machine Setup

See **[install/README.md](install/README.md)** for the full bootstrap guide.

Quick version:

```bash
git clone git@github.com:nikbrunner/dots.git ~/repos/nikbrunner/dots
cd ~/repos/nikbrunner/dots
./install/install.sh
```

**Flags**: `--dry-run` (preview), `--debug` (diagnostics)

## Usage

### Core Commands

- **`dots`** — Dotfiles management (pull, push, link, chores, purge). Run `dots` with no args for usage.
- **`dots pull`** — Installs missing mise and platform-native packages without upgrading existing packages. Add `--upgrade` to upgrade declared packages.
- **`dots chores`** — Refreshes the mise lock metadata and stages `config.toml` with `mise.lock` alongside routine changes. It does not bump fuzzy version selectors.
- **`dots purge`** — Reviews undeclared Homebrew, mise, and Arch entries. Nothing is selected by default; removal requires explicit selection and confirmation. Use `--dry-run` to inspect candidates without changes.
- **`mole uninstall`** — Separate macOS application cleanup. It does not replace `dots purge` for package-manager entries.
- **`shiplog`** — AI-powered git operations (commit, branch). Run `shiplog --help` for usage.
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

[Black Atom Livery](https://github.com/black-atom-industries/black-atom) owns theme provisioning. The tracked configuration at `common/.config/black-atom/livery/config.json` records the active theme and enabled app integrations.

`dots pull` runs `livery reapply` after linking files and refreshing repositories when the configuration contains setup data and an active theme. Run `livery apply` to choose a different theme interactively.
