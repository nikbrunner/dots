# Dotfiles Migration Plan

## Phase 1: Audit & Cleanup

**Goal**: Clean up your existing dotfiles before migrating

### Step 1: Inventory Current Setup

- [x] List all files currently tracked in your bare repo
- [x] Identify which configs you actually use vs. legacy stuff
- [ ] Document your current workflow and pain points

### Step 2: Clean Up Existing Dotfiles

- [ ] Remove unused/legacy config files
- [ ] Clean up `.zshrc` - remove dead paths and unused exports
- [ ] Identify macOS-specific vs universal configs
- [ ] Document dependencies (what needs Homebrew, what needs specific packages)

### Step 3: Prepare for Migration

- [ ] Backup current dotfiles state
- [ ] Test that everything still works after cleanup

## Phase 2: New Repo Structure

**Goal**: Set up the new dotfiles architecture

### Step 1: Create New Repo Structure

```
~/repos/nikbrunner/dotfiles/
├── README.md
├── install.sh           # Main setup script
├── scripts/
│   ├── link.sh          # Symlink management
│   ├── detect-os.sh     # OS detection utilities
│   └── submodules.sh    # Git submodule management
├── config/              # Shared configs (gets symlinked)
│   ├── zsh/
│   ├── git/
│   ├── yazi/
│   └── ...
├── os-specific/         # OS-specific configs (gets symlinked)
│   ├── macos/
│   └── linux/
└── submodules/          # Git submodules (gets symlinked)
    ├── nvim/            # → ~/.config/nvim
    ├── wezterm/         # → ~/.config/wezterm
    └── ...
```

**How symlinking works:**
- `~/repos/nikbrunner/dotfiles/submodules/nvim/` → `~/.config/nvim`
- `~/repos/nikbrunner/dotfiles/config/yazi/` → `~/.config/yazi`
- `~/repos/nikbrunner/dotfiles/config/zsh/.zshrc` → `~/.zshrc`

### Step 2: Set Up Git Submodules

- [ ] Convert nvim and wezterm repos to submodules
- [ ] Create submodule management scripts
- [ ] Test submodule workflows

### Step 3: Create Symlink Scripts

- [ ] Write `link.sh` script for creating symlinks
- [ ] Add OS detection logic
- [ ] Create `dots` command wrapper

## Phase 3: Migration

**Goal**: Move from bare repo to new system

### Step 1: Migrate on Mac First

- [ ] Clone new dotfiles repo to `~/repos/nikbrunner/dotfiles`
- [ ] Copy cleaned configs from bare repo to new structure
- [ ] Test symlink script
- [ ] Gradually switch from bare repo to new system

### Step 2: Set Up Linux

- [ ] Clone dotfiles repo on Linux machine
- [ ] Run install script
- [ ] Add Linux-specific configs as needed
- [ ] Test everything works

### Step 3: Finalize

- [ ] Remove old bare repo setup
- [ ] Update workflows and aliases
- [ ] Document the new system

## Commands We'll Create

```bash
# Main commands
dots install    # Initial setup with symlinks and submodules
dots link       # Re-run symlink creation
dots sync       # Git pull + submodule updates
dots push       # Git add, commit, push
dots clean      # Remove broken symlinks

# Submodule helpers
dots sub-update # Update all submodules
dots sub-add    # Add new submodule
```

## Questions to Answer

1. **Which configs do you want as submodules?** (nvim, wezterm for sure - any others?)
2. **How much OS-specific stuff do you actually have?**
3. **What's your backup strategy during migration?**
4. **Any configs that are machine-specific** (not just OS-specific)?
