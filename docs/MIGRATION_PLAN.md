# Dotfiles Migration Plan

## Phase 1: Audit & Cleanup ✅

**Goal**: Clean up your existing dotfiles before migrating

### Step 1: Inventory Current Setup

- [x] List all files currently tracked in your bare repo
- [x] Identify which configs you actually use vs. legacy stuff
- [x] Document your current workflow and pain points

### Step 2: Clean Up Existing Dotfiles

- [x] Remove unused/legacy config files (skipped wezterm and zed for submodules)
- [x] Clean up `.zshrc` - remove dead paths and unused exports
- [x] Identify macOS-specific vs universal configs
- [x] Document dependencies (what needs Homebrew, what needs specific packages)

### Step 3: Prepare for Migration

- [x] Backup current dotfiles state (automatic with --force flag)
- [x] Test that everything still works after cleanup

## Phase 2: New Repo Structure ✅

**Goal**: Set up the new dotfiles architecture

### Step 1: Create New Repo Structure

```
~/repos/nikbrunner/dots/
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
- `~/repos/nikbrunner/dots/submodules/nvim/` → `~/.config/nvim`
- `~/repos/nikbrunner/dots/config/yazi/` → `~/.config/yazi`
- `~/repos/nikbrunner/dots/config/zsh/.zshrc` → `~/.zshrc`

### Step 2: Set Up Git Submodules

- [x] Convert nvim and wezterm repos to submodules (ready, pending addition)
- [x] Create submodule management scripts
- [x] Test submodule workflows

### Step 3: Create Symlink Scripts

- [x] Write `link.sh` script for creating symlinks
- [x] Add OS detection logic
- [x] Create `dots` command wrapper

## Phase 3: Migration ✅

**Goal**: Move from bare repo to new system

### Step 1: Migrate on Mac First

- [x] Clone new dotfiles repo to `~/repos/nikbrunner/dots`
- [x] Copy cleaned configs from bare repo to new structure
- [x] Test symlink script
- [x] Gradually switch from bare repo to new system

### Step 2: Set Up Linux

- [ ] Clone dotfiles repo on Linux machine
- [ ] Run install script
- [ ] Add Linux-specific configs as needed
- [ ] Test everything works

### Step 3: Finalize

- [ ] Remove old bare repo setup
- [ ] Update workflows and aliases
- [x] Document the new system

## Commands Created ✅

```bash
# Main commands
dots install    # Initial setup with symlinks and submodules
dots link       # Re-run symlink creation
dots sync       # Git pull + submodule updates
dots push       # Git add, commit, push
dots clean      # Remove broken symlinks
dots status     # Show git status
dots log        # Show git log

# Submodule helpers
dots sub-update # Update all submodules
dots sub-add    # Add new submodule
```

## Questions Answered

1. **Which configs do you want as submodules?** → nvim, wezterm, zed (private)
2. **How much OS-specific stuff do you actually have?** → Mainly Brewfile and Claude config for macOS
3. **What's your backup strategy during migration?** → Automatic timestamped backups with --force flag
4. **Any configs that are machine-specific** → Not identified yet, can be added later

## Next Steps

1. Initialize git repository and push to GitHub
2. Add submodules for nvim, wezterm, and zed
3. Test on Linux machine when available
4. Clean up backup files after verification period
