# Git Submodules Guide

This document provides comprehensive guidance for working with Git submodules in the dots repository.

## Quick Reference

| Task                     | Command                                                         |
| ------------------------ | --------------------------------------------------------------- |
| Add submodule            | `dots sub-add git@github.com:user/repo.git common/.config/tool` |
| Update all submodules    | `dots sub-update`                                               |
| Commit submodule updates | `dots sub-commit`                                               |
| Check submodule status   | `dots sub-status`                                               |
| Sync repo + submodules   | `dots sync`                                                     |
| Fix broken symlinks      | `dots link`                                                     |

## Understanding Submodules

Git submodules allow you to include other Git repositories within your repository. In this dotfiles setup, we use submodules for larger configurations (like Neovim) that are maintained as separate repositories. Submodules are added directly to their target configuration locations, so they work seamlessly with the symlink system.

## Current Submodules

- `common/.config/nvim` - Neovim configuration ([nikbrunner/nbr.nvim](https://github.com/nikbrunner/nbr.nvim))

## Managing Submodules

### Adding a New Submodule

```bash
# Using dots command (recommended)
dots sub-add git@github.com:username/repo.git common/.config/toolname

# What this does behind the scenes:
# 1. git submodule add git@github.com:username/repo.git common/.config/toolname
# 2. git submodule update --init --recursive common/.config/toolname
# 3. You still need to commit the changes
```

### Cloning with Submodules

When cloning this repository on a new machine:

```bash
# Option 1: Clone with submodules included
git clone --recurse-submodules git@github.com:nikbrunner/dots.git ~/repos/nikbrunner/dots

# Option 2: Clone first, then initialize submodules
git clone git@github.com:nikbrunner/dots.git ~/repos/nikbrunner/dots
cd ~/repos/nikbrunner/dots
git submodule update --init --recursive

# Option 3: Just run install.sh (recommended - it handles everything)
./install.sh
# What install.sh does:
# - Detects .gitmodules file
# - Runs: scripts/submodules.sh update
# - Which runs: git submodule update --init --recursive
# - Then creates all symlinks with dots link
```

### Updating Submodules

```bash
# Update all submodules to their latest commits (recommended)
dots sub-update
# What this does:
# 1. git submodule update --init --recursive
# 2. git submodule foreach 'git pull origin main || git pull origin master'

# Or using git directly
git submodule update --remote --merge

# Update a specific submodule manually
cd common/.config/nvim
git pull origin main
cd ../../..
git add common/.config/nvim
git commit -m "Update nvim submodule"
```

### Syncing Repository (Pull + Update Submodules)

```bash
# Pull latest changes and update all submodules
dots sync
# What this does:
# 1. git pull origin main (or master)
# 2. If .gitmodules exists: scripts/submodules.sh update
# 3. Which runs: git submodule update --init --recursive
# 4. Then: git submodule foreach 'git pull origin main || git pull origin master'
```

### Removing a Submodule

```bash
# Note: There's no dots command for this yet, use git directly:
git submodule deinit -f common/.config/toolname
rm -rf .git/modules/common/.config/toolname
git rm -f common/.config/toolname
git commit -m "Remove toolname submodule"
```

## Troubleshooting Submodules

### Problem: Submodule directory is empty

```bash
# Initialize and update the submodule
git submodule update --init --recursive
```

### Problem: Submodule is in detached HEAD state

```bash
cd common/.config/nvim
git checkout main
git pull origin main
```

### Problem: Can't clone due to authentication

```bash
# Check your submodule URLs (should use SSH not HTTPS)
cat .gitmodules

# Update submodule URL if needed
git config submodule.common/.config/nvim.url git@github.com:nikbrunner/nbr.nvim.git
git submodule sync
```

### Problem: Symlinks are broken after adding submodule

```bash
# Re-run the link command to fix all symlinks
dots link
```

## Common Submodule Commands

| Dots Command                | Git Command                                                                   | Description                          |
| --------------------------- | ----------------------------------------------------------------------------- | ------------------------------------ |
| `dots sub-add <url> <path>` | `git submodule add <url> <path>`                                              | Add a new submodule                  |
| `dots sub-update`           | `git submodule update --init --recursive`<br>`git submodule foreach git pull` | Update all submodules                |
| `dots sub-commit`           | `git add <submodules>`<br>`git commit -m "chore: update submodule hashes"`    | Commit submodule hash updates        |
| `dots sub-status`           | `git submodule status`<br>Show uncommitted changes                            | Show status of all submodules        |
| `dots sync`                 | `git pull` + submodule update                                                 | Pull changes & update submodules     |
| -                           | `git submodule sync`                                                          | Sync submodule URLs with .gitmodules |
| -                           | `git config status.submodulesummary 1`                                        | Show submodule summary in git status |
| -                           | `git diff --submodule`                                                        | Show submodule changes in diff       |

## Best Practices

1. **Use SSH URLs** for submodules (git@github.com:user/repo.git)
2. **Commit submodule changes** when you update them
3. **Keep submodules on a branch** (not detached HEAD)
4. **Document your submodules** in this guide
5. **Test after adding** with `dots test` and `dots link`

## Removal Plan

If you're considering simplifying your workflow by removing submodules entirely, see the comprehensive [Submodules Removal Implementation Plan](./SUBMODULES_REMOVAL_PLAN.md) which includes:

- Step-by-step migration process
- Repository archival procedures
- Detailed pros/cons analysis
- Risk assessment and rollback plans
- Post-migration workflow examples
