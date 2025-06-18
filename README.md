# dots

A clean, organized dotfiles repository using symlinks for easy management and deployment.

## Overview

This dotfiles system uses a simple symlink-based approach:

- Configuration files live in this repository organized by platform
- Files are symlinked to their expected locations in your home directory
- Running `dots link` updates everything automatically (removes broken symlinks + creates new ones)

## 📁 Structure

```
dots/
├── README.md                # This file
├── CLAUDE.md               # Claude Code instructions
├── IMPLEMENTATION_PLAN.md  # Detailed roadmap implementation plans
├── .mappings/              # JSON mapping files
│   ├── macos.json         # macOS file mappings
│   └── linux.json         # Linux file mappings
├── scripts/               # Management scripts
│   ├── detect-os.sh       # OS detection utility
│   ├── link.sh           # Symlink creation using mappings
│   └── generate-mappings.sh # Creates JSON mappings
├── common/               # Cross-platform configurations
│   ├── .config/          # Config files (.zshrc, .gitconfig, etc.)
│   ├── bin/              # Custom scripts
│   └── .zshrc, .gitconfig, etc. # Root dotfiles
├── macos/                # macOS-specific configurations
│   ├── .config/karabiner/ # Karabiner configuration
│   ├── Library/          # Application Support files
│   └── Brewfile          # Homebrew dependencies
├── linux/                # Linux-specific configurations
└── submodules/           # Git submodules (nvim, wezterm, zed)
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

```bash
# Core Commands
dots install      # Initial setup with symlinks and submodules
dots link         # Update all symlinks (removes broken + creates new) [--dry-run]
dots sync         # Git pull + submodule updates
dots status       # Show git and symlink status

# Git Operations
dots commit       # Open LazyGit for interactive committing
dots push         # Push commits to remote [--force]
dots log          # Show recent commits

# Maintenance
dots test         # Run comprehensive system tests
dots format       # Format files (markdown, shell scripts, etc.)
dots hooks        # Install/reinstall git hooks

# Submodules
dots sub-update   # Update all submodules
dots sub-add      # Add new submodule
```

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

The `dots test` command validates the entire system (repository structure, OS detection, mapping generation, symlinks, etc.) and reports pass/fail status. Use `dots link --dry-run` when you want detailed output showing exactly what symlink operations would be performed.

## 🔧 How It Works

### File Organization

- **`common/`**: Cross-platform configurations (used on all systems)
- **`macos/`**: macOS-specific configurations
- **`linux/`**: Linux-specific configurations
- **`submodules/`**: Larger configurations managed as git submodules

Each directory mirrors your home directory structure. For example:

- `common/.zshrc` → `~/.zshrc`
- `common/.config/git/config` → `~/.config/git/config`
- `macos/.config/karabiner/karabiner.json` → `~/.config/karabiner/karabiner.json`

### The Magic of `dots link`

When you run `dots link`:

1. **Cleans up**: Removes any broken symlinks from previous configurations
2. **Creates/Updates**: Makes symlinks for all files in your platform directories
3. **Auto-generates mappings**: Creates JSON files tracking all symlinks
4. **Backs up conflicts**: If a real file exists where a symlink should go, it's backed up with a timestamp

This single command handles all scenarios: adding, removing, renaming, or moving files.

### OS-Specific Configurations

Place OS-specific files in `macos/` or `linux/` following the home directory structure. The system automatically detects your OS and creates appropriate symlinks using JSON mappings.

### Submodules

To add a submodule:

```bash
dots sub-add https://github.com/nikbrunner/nvim submodules/nvim
```

Current submodules (to be added):

- `nvim` - Neovim configuration
- `wezterm` - WezTerm configuration
- `zed` - Zed editor configuration (private)

## 📦 Dependencies

- Git
- Bash 4+ (macOS users: `brew install bash`)
- Standard Unix tools (ln, mkdir, etc.)

## 🤝 Platform Support

- ✅ macOS (primary development)
- ✅ Linux (EndeavourOS/Arch)
- ❌ Windows (not supported)
