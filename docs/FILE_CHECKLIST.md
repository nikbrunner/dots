# File Migration Checklist for Claude Code

## 📋 Current Files to Migrate

### ✅ Core Configs → `config/`
- [ ] `.zshrc` → `config/zsh/.zshrc`
- [ ] `.gitconfig` → `config/git/.gitconfig`
- [ ] `.gitignore` → `config/git/.gitignore`
- [ ] `.vimrc` → `config/vim/.vimrc`
- [ ] `.ideavimrc` → `config/vim/.ideavimrc`

### ✅ Config Directories → `config/`
- [ ] `.config/bat/config` → `config/bat/config`
- [ ] `.config/gallery-dl/config.json` → `config/gallery-dl/config.json`
- [ ] `.config/ghostty/config` → `config/ghostty/config`
- [ ] `.config/lazygit/config.yml` → `config/lazygit/config.yml`
- [ ] `.config/oh-my-posh/nbr.omp.json` → `config/oh-my-posh/nbr.omp.json`
- [ ] `.config/yazi/keymap.toml` → `config/yazi/keymap.toml`
- [ ] `.config/yazi/yazi.toml` → `config/yazi/yazi.toml`

### ✅ Complex Config Directories → `config/`
- [ ] `.config/karabiner/` (entire folder) → `config/karabiner/`
  - [ ] `assets/complex_modifications/1613599486.json`
  - [ ] `assets/complex_modifications/1654716773.json`
  - [ ] `karabiner.json`
- [ ] `.config/kitty/` (entire folder) → `config/kitty/`
  - [ ] All theme files and configs
- [ ] `.config/tmux/` (entire folder) → `config/tmux/`
  - [ ] `keymaps.conf`
  - [ ] `tmux.conf`

### ✅ Git Completion → `config/zsh/`
- [ ] `.config/.zsh/_git` → `config/zsh/_git`
- [ ] `.config/.zsh/git-completion.bash` → `config/zsh/git-completion.bash`

### ✅ Custom Scripts → `scripts-custom/`
- [ ] `.scripts/.editorconfig` → `scripts-custom/.editorconfig`
- [ ] `.scripts/claude-commit` → `scripts-custom/claude-commit`
- [ ] `.scripts/dots` → `scripts-custom/dots`
- [ ] `.scripts/ide` → `scripts-custom/ide`
- [ ] `.scripts/mac-setup` → `scripts-custom/mac-setup`
- [ ] `.scripts/nsr` → `scripts-custom/nsr`
- [ ] `.scripts/smart-branch` → `scripts-custom/smart-branch`
- [ ] `.scripts/smart-clone` → `scripts-custom/smart-clone`
- [ ] `.scripts/smart-commit` → `scripts-custom/smart-commit`
- [ ] `.scripts/smart-git-message` → `scripts-custom/smart-git-message`
- [ ] `.scripts/tmux_2x2_layout` → `scripts-custom/tmux_2x2_layout`

### ✅ OS-Specific → `os-specific/macos/`
- [ ] `Brewfile` → `os-specific/macos/Brewfile`
- [ ] `Library/Application Support/Claude/claude_desktop_config.json` → `os-specific/macos/Library/Application Support/Claude/claude_desktop_config.json`

### ✅ Documentation → Root
- [ ] `README.md` → Update with new dotfiles system documentation
- [ ] `.claude/CLAUDE.md` → `docs/CLAUDE.md` (for reference)

### ❌ SKIP - Will be Submodules
- [ ] ~~`.config/wezterm/` (all files)~~ → Will be submodule
- [ ] ~~`.config/zed/` (all files)~~ → Will be private submodule

## 🛠 Scripts to Create

### Main Scripts
- [ ] `install.sh` - Main installation script
- [ ] `scripts/link.sh` - Symlink management
- [ ] `scripts/detect-os.sh` - OS detection
- [ ] `scripts/submodules.sh` - Git submodule management

### Dots Command System
- [ ] Create `dots` command wrapper
- [ ] Implement subcommands: install, link, sync, push, clean, sub-update, sub-add

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

- [ ] All scripts are executable (`chmod +x`)
- [ ] OS detection works
- [ ] Symlinks can be created without errors
- [ ] `dots` command is functional
- [ ] No broken file paths

## 📝 README.md Content to Include

- [ ] Overview of the dotfiles system
- [ ] Installation instructions
- [ ] Usage of `dots` command
- [ ] How to add new configs
- [ ] Submodule workflow (for later)
- [ ] OS-specific setup notes
