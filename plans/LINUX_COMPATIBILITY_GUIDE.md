# Linux Compatibility Guide for EndeavorOS

This document serves as a comprehensive troubleshooting and setup guide for deploying the dotfiles on EndeavorOS (Arch-based Linux distribution).

## 🎯 Quick Setup Checklist

### Pre-Installation Dependencies
- [ ] **Essential packages**: `git`, `zsh`, `tmux`, `nvim`
- [ ] **1Password**: Install 1Password for Linux and enable SSH agent
- [ ] **Terminal**: Kitty (instead of WezTerm)
- [ ] **Package manager**: `paru` or `yay` for AUR packages
- [ ] **Shell**: Ensure zsh is default shell (`chsh -s $(which zsh)`)

### Post-Installation Verification
- [ ] SSH agent working (`ssh-add -l`)
- [ ] Git signing working (`git log --show-signature -1`)
- [ ] Tmux keybindings responding (especially `Ctrl+a`)
- [ ] All symlinks created (`dots status`)
- [ ] Submodules updated (`dots sub-status`)

## 🔴 High-Priority Compatibility Issues

### 1. **1Password SSH Integration** ⚠️
**Issue**: macOS-specific paths in Git configuration
**Location**: `common/.gitconfig:79`
```
program = /Applications/1Password.app/Contents/MacOS/op-ssh-sign
```

**Linux Fix**:
```bash
# Find correct path after 1Password installation
which op-ssh-sign

# Update locally (don't commit to dotfiles)
git config --global gpg.ssh.program "$(which op-ssh-sign)"
```

**Expected Linux path**: `/usr/bin/op-ssh-sign` or `/opt/1Password/op-ssh-sign`

### 2. **Homebrew Dependencies** ⚠️
**Issue**: macOS Homebrew paths hardcoded in shell configuration
**Location**: `common/.zshrc:4-8, 21`

**Problematic lines**:
```bash
brew_path="/opt/homebrew/bin"
brew_opt_path="/opt/homebrew/opt"
export PATH=${brew_path}:${PATH}
[ -s "${brew_opt_path}/nvm/nvm.sh" ] && . "${brew_opt_path}/nvm/nvm.sh"
```

**Linux alternatives**:
- Replace Homebrew with `paru`/`yay` and system packages
- Use system package manager for Python, NVM, etc.
- Install NVM via official script or AUR

### 3. **Terminal-Specific Issues** ⚠️
**Issue**: Tmux keybindings not working in Kitty
**Location**: `common/.config/tmux/keymaps.conf:3`

```
set -g prefix C-,
bind C-, send-prefix
```

**Potential Kitty conflicts**:
- Check Kitty's `kitty.conf` for conflicting keybindings
- Verify terminal sends correct key sequences
- Test with: `tmux list-keys | grep prefix`

## 🟡 Medium-Priority Issues

### 4. **NVM Installation**
**Current**: Uses Homebrew NVM
**Linux alternative**: 
```bash
# Via curl (official method)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Or via AUR
paru -S nvm
```

### 5. **Python Path Configuration**
**Current**: Uses Homebrew Python paths
**Linux fix**: Remove Homebrew-specific Python paths, use system Python

### 6. **Font Dependencies**
**Check**: Ensure fonts used in terminal configs are available
- Install `nerd-fonts` from AUR
- Verify font names in Kitty config match installed fonts

## 🟢 Low-Priority Issues

### 7. **Mac-Setup Script**
**Issue**: Contains macOS-specific setup
**Location**: `common/bin/mac-setup`
**Action**: Ignore this script on Linux (won't be executed)

### 8. **VSCode Integration**
**Current**: Git merge/diff tools set to VSCode
**Alternative**: Consider using `nvim` or install `code` from AUR

## 🔧 Troubleshooting Commands

### SSH Debugging
```bash
# Check SSH agent
ssh-add -l

# Check 1Password SSH agent socket
ls -la ~/.1password/agent.sock  # Or check 1Password settings

# Test GitHub connection
ssh -vT git@github.com

# Check Git signing
git log --show-signature -1
```

### Tmux Debugging
```bash
# List all key bindings
tmux list-keys

# Check prefix key
tmux show-options -g prefix

# Test prefix manually
tmux send-keys C-a  # Should show in tmux status

# Debug in new session
tmux new-session -s test
```

### Terminal Debugging
```bash
# Check if Kitty sends correct key sequences
# In Kitty, press Ctrl+Shift+F4 to open debug mode

# Test key detection
cat -v
# Then press your keys to see what terminal sends
```

### Path and Environment
```bash
# Check PATH
echo $PATH

# Check NVM
which node npm nvm

# Check Python
which python python3 pip

# Check shell
echo $SHELL
which zsh
```

## 🐧 EndeavorOS/Arch-Specific Package Installation

### Essential packages
```bash
# Core development tools
sudo pacman -S git zsh tmux neovim base-devel

# Terminal and fonts
sudo pacman -S kitty
paru -S nerd-fonts-complete

# 1Password
paru -S 1password

# Development tools
sudo pacman -S fzf ripgrep fd bat delta lazygit
paru -S yazi-git

# Node/npm alternatives
sudo pacman -S nodejs npm
# or use NVM
```

### AUR packages to consider
```bash
paru -S \
  oh-my-zsh-git \
  1password \
  1password-cli \
  zsh-autosuggestions \
  zsh-syntax-highlighting
```

## 📝 Linux-Specific Configuration Changes

Create these local overrides (don't commit to dotfiles):

### ~/.zshrc.local (source at end of .zshrc)
```bash
# Linux-specific overrides
unset brew_path brew_opt_path

# Arch Linux paths
export PATH=/usr/bin:/usr/local/bin:$PATH

# NVM for Linux (if installed via script)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
```

### ~/.gitconfig.local (include in main .gitconfig)
```bash
[gpg "ssh"]
    program = /usr/bin/op-ssh-sign  # Adjust path as needed
```

## 🚨 Emergency Fallbacks

### If 1Password SSH doesn't work
1. **Fallback to system SSH agent**:
   ```bash
   git config --global --unset gpg.ssh.program
   git config --global gpg.format ssh
   ssh-add ~/.ssh/id_ed25519  # Add your key manually
   ```

### If tmux keybindings don't work
1. **Test with default prefix**:
   ```bash
   tmux set-option -g prefix C-b
   tmux bind-key C-b send-prefix
   ```

### If symlinks fail
1. **Manual linking for critical files**:
   ```bash
   ln -sf ~/repos/nikbrunner/dots/common/.zshrc ~/.zshrc
   ln -sf ~/repos/nikbrunner/dots/common/.gitconfig ~/.gitconfig
   ```

## ✅ Success Validation

After setup, verify these work:
```bash
# Core functionality
dots status          # Should show all symlinks OK
dots test           # Should pass all tests

# SSH and Git
ssh -T git@github.com                    # Should authenticate
git log --show-signature -1              # Should show "Good signature"

# Terminal and tmux
tmux new-session -s test                 # Should start tmux
# Press Ctrl+a, then ?                   # Should show help

# Development tools
nvim --version       # Should be recent version
lazygit --version    # Should work
yazi --version       # Should work
```

## 📚 Additional Resources

- [1Password SSH Agent for Linux](https://developer.1password.com/docs/ssh/get-started/)
- [Arch Linux NVM Installation](https://wiki.archlinux.org/title/Node.js)
- [Kitty Terminal Configuration](https://sw.kovidgoyal.net/kitty/conf/)
- [Tmux Key Binding Debugging](https://github.com/tmux/tmux/wiki)

---

*This document should be consulted before and during Linux setup. Update it based on actual issues encountered during deployment.*
