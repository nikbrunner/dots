# dots

A clean, organized dotfiles repository using symlinks for easy management and deployment.

## Roadmap

- [ ] Modularize `dots` command
- [ ] Remove old commands
- [ ] Add submodules for `nvim`, `wezterm`

## 📁 Structure

```
dots/
├── README.md                # This file
├── CLAUDE.md               # Claude Code instructions
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
dots install      # Initial setup with symlinks and submodules
dots link         # Re-run symlink creation
dots sync         # Git pull + submodule updates
dots push         # Git add, commit, push
dots clean        # Remove broken symlinks
dots sub-update   # Update all submodules
dots sub-add      # Add new submodule
dots status       # Show git and symlink status
dots test         # Run comprehensive system tests
dots log          # Show git log
```

### Common Workflows

#### Adding a New Configuration

1. Add your config file to the appropriate directory structure:
   - Cross-platform: `common/` (mirrors home directory structure)
   - OS-specific: `macos/` or `linux/` (mirrors home directory structure)
2. Run `dots link` to create symlinks (mappings auto-generated)
3. Commit your changes: `dots push "Add new config"`

#### Updating Configurations

1. Edit files directly in your home directory (they're symlinked!)
2. Check what changed: `dots status`
3. Commit changes: `dots push "Update configs"`

#### Syncing Across Machines

```bash
dots sync  # Pull latest changes and update submodules
```

#### Testing the System

```bash
# Run comprehensive system tests (good before making changes)
dots test

# Preview what symlinks would be created (detailed output)
dots link --dry-run
```

The `dots test` command validates the entire system (repository structure, OS detection, mapping generation, symlinks, etc.) and reports pass/fail status. Use `dots link --dry-run` when you want detailed output showing exactly what symlink operations would be performed.

## 🔧 Configuration

### Adding New Dotfiles

1. Add it to the appropriate location:
   - Cross-platform: `common/` following home directory structure
   - OS-specific: `macos/` or `linux/` following home directory structure
2. Run `dots link` to create symlinks (mappings are auto-generated)
3. No manual script updates needed - files are automatically detected

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
