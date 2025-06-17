# File Migration Checklist for Claude Code

## 📋 Current Files to Migrate

### ✅ Core Configs → `config/`
- [x] `.zshrc` → `config/zsh/.zshrc`
- [x] `.gitconfig` → `config/git/.gitconfig`
- [x] `.gitignore` → `config/git/.gitignore`
- [x] `.vimrc` → `config/vim/.vimrc`
- [x] `.ideavimrc` → `config/vim/.ideavimrc`
- [x] `.hushlogin` → `config/shell/.hushlogin` (created new)

### ✅ Config Directories → `config/`
- [x] `.config/bat/config` → `config/bat/config`
- [x] `.config/gallery-dl/config.json` → `config/gallery-dl/config.json`
- [x] `.config/ghostty/config` → `config/ghostty/config`
- [x] `.config/lazygit/config.yml` → `config/lazygit/config.yml`
- [x] `.config/oh-my-posh/nbr.omp.json` → `config/oh-my-posh/nbr.omp.json`
- [x] `.config/yazi/keymap.toml` → `config/yazi/keymap.toml`
- [x] `.config/yazi/yazi.toml` → `config/yazi/yazi.toml`

### ✅ Complex Config Directories → `config/`
- [x] `.config/karabiner/` (entire folder) → `config/karabiner/`
  - [x] `assets/complex_modifications/1613599486.json`
  - [x] `assets/complex_modifications/1654716773.json`
  - [x] `karabiner.json`
- [x] `.config/kitty/` (entire folder) → `config/kitty/`
  - [x] All theme files and configs
- [x] `.config/tmux/` (entire folder) → `config/tmux/`
  - [x] `keymaps.conf`
  - [x] `tmux.conf`
  - [x] `plugins/` (including tpm, tmux-yank, tmux-fzf)

### ✅ Git Completion → `config/zsh/`
- [x] `.config/.zsh/_git` → `config/zsh/_git`
- [x] `.config/.zsh/git-completion.bash` → `config/zsh/git-completion.bash`

### ✅ Custom Scripts → `scripts-custom/`
- [x] `.scripts/.editorconfig` → `scripts-custom/.editorconfig`
- [x] `.scripts/claude-commit` → `scripts-custom/claude-commit`
- [x] `.scripts/dots` → `scripts-custom/dots` (replaced with new version)
- [x] `.scripts/ide` → `scripts-custom/ide`
- [x] `.scripts/mac-setup` → `scripts-custom/mac-setup`
- [x] `.scripts/nsr` → `scripts-custom/nsr`
- [x] `.scripts/smart-branch` → `scripts-custom/smart-branch`
- [x] `.scripts/smart-clone` → `scripts-custom/smart-clone`
- [x] `.scripts/smart-commit` → `scripts-custom/smart-commit`
- [x] `.scripts/smart-git-message` → `scripts-custom/smart-git-message`
- [x] `.scripts/tmux_2x2_layout` → `scripts-custom/tmux_2x2_layout`

### ✅ OS-Specific → `os-specific/macos/`
- [x] `Brewfile` → `os-specific/macos/Brewfile`
- [x] `Library/Application Support/Claude/claude_desktop_config.json` → `os-specific/macos/Library/Application Support/Claude/claude_desktop_config.json`

### ✅ Documentation → Root
- [x] `README.md` → Update with new dotfiles system documentation
- [x] `.claude/CLAUDE.md` → `docs/CLAUDE.md` (for reference)

### ❌ SKIP - Will be Submodules
- [x] ~~`.config/wezterm/` (all files)~~ → Will be submodule
- [x] ~~`.config/zed/` (all files)~~ → Will be private submodule

## 🛠 Scripts to Create

### Main Scripts
- [x] `install.sh` - Main installation script
- [x] `scripts/link.sh` - Symlink management
- [x] `scripts/detect-os.sh` - OS detection
- [x] `scripts/submodules.sh` - Git submodule management

### Dots Command System
- [x] Create `dots` command wrapper
- [x] Implement subcommands: install, link, sync, push, clean, sub-update, sub-add

## 📁 Final Structure Verification

```
~/repos/nikbrunner/dots/
├── README.md                    ✅
├── install.sh                   ✅
├── scripts/
│   ├── link.sh                  ✅
│   ├── detect-os.sh             ✅
│   └── submodules.sh            ✅
├── config/
│   ├── zsh/
│   │   ├── .zshrc               ✅
│   │   ├── _git                 ✅
│   │   └── git-completion.bash  ✅
│   ├── git/
│   │   ├── .gitconfig           ✅
│   │   └── .gitignore           ✅
│   ├── vim/
│   │   ├── .vimrc               ✅
│   │   └── .ideavimrc           ✅
│   ├── yazi/                    ✅
│   ├── lazygit/                 ✅
│   ├── bat/                     ✅
│   ├── tmux/                    ✅
│   ├── gallery-dl/              ✅
│   ├── oh-my-posh/              ✅
│   ├── karabiner/               ✅
│   ├── kitty/                   ✅
│   └── ghostty/                 ✅
├── os-specific/
│   └── macos/
│       ├── Brewfile             ✅
│       └── Library/Application Support/Claude/
│           └── claude_desktop_config.json  ✅
├── scripts-custom/              ✅ (all scripts)
├── docs/
│   └── CLAUDE.md                ✅
└── submodules/                  📁 (empty for now)
```

## ✅ Testing Checklist

- [x] All scripts are executable (`chmod +x`)
- [x] OS detection works
- [x] Symlinks can be created without errors
- [x] `dots` command is functional
- [x] No broken file paths

## 📝 README.md Content to Include

- [x] Overview of the dotfiles system
- [x] Installation instructions
- [x] Usage of `dots` command
- [x] How to add new configs
- [x] Submodule workflow (for later)
- [x] OS-specific setup notes

## 🔄 Post-Migration Tasks

### Git Repository Setup
- [x] Initialize git repository: `cd ~/repos/nikbrunner/dots && git init`
- [x] Add remote: `git remote add origin https://github.com/nikbrunner/dots.git`
- [x] Initial commit: `dots push "Initial migration to symlink-based dotfiles"`

### Submodule Addition
- [ ] Add nvim submodule: `dots sub-add https://github.com/nikbrunner/nvim submodules/nvim`
- [ ] Add wezterm submodule: `dots sub-add https://github.com/nikbrunner/wezterm submodules/wezterm`
- [ ] Add zed submodule (private): `dots sub-add <private-repo-url> submodules/zed`

### Cleanup Tasks
- [ ] Remove backup files after verifying everything works:
  - [ ] Remove `.zshrc.backup.*`
  - [ ] Remove `.gitconfig.backup.*`
  - [ ] Remove `.gitignore.backup.*`
  - [ ] Remove `.vimrc.backup.*`
  - [ ] Remove `.ideavimrc.backup.*`
  - [ ] Remove `.config/*.backup.*` directories
  - [ ] Remove `.scripts.backup.*`
  - [ ] Remove `claude_desktop_config.json.backup.*`
- [ ] Archive old bare repository: `rm -rf ~/.dotfiles`
- [ ] Update shell aliases/functions if needed
