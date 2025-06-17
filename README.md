# Dots - Symlink-based Dotfiles Management

A clean, organized dotfiles repository using symlinks for easy management and deployment.

## 📁 Structure

```
dots/
├── README.md                # This file
├── install.sh              # Main installation script
├── scripts/               # Management scripts
│   ├── detect-os.sh       # OS detection utility
│   ├── link.sh           # Symlink creation
│   └── submodules.sh     # Git submodule management
├── config/               # All configuration files
│   ├── zsh/             # Zsh configuration
│   ├── git/             # Git configuration
│   ├── vim/             # Vim configuration
│   ├── tmux/            # Tmux configuration
│   ├── kitty/           # Kitty terminal
│   └── ...              # Other configs
├── os-specific/         # OS-specific configurations
│   └── macos/           # macOS specific files
├── scripts-custom/      # Custom user scripts
└── submodules/         # Git submodules (nvim, wezterm, zed)
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
dots log          # Show git log
```

### Common Workflows

#### Adding a New Configuration

1. Add your config file to the appropriate directory in `config/`
2. Update `scripts/link.sh` to create the symlink
3. Run `dots link` to create the symlink
4. Commit your changes: `dots push "Add new config"`

#### Updating Configurations

1. Edit files directly in your home directory (they're symlinked!)
2. Check what changed: `dots status`
3. Commit changes: `dots push "Update configs"`

#### Syncing Across Machines

```bash
dots sync  # Pull latest changes and update submodules
```

## 🔧 Configuration

### Adding New Dotfiles

1. Copy your config to the appropriate location in `config/`
2. Add the symlink creation to `scripts/link.sh`
3. Run `dots link` to create the symlink

### OS-Specific Configurations

Place OS-specific files in `os-specific/<os>/`. The `link.sh` script automatically detects your OS and creates appropriate symlinks.

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

