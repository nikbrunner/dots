# Submodules Removal Implementation Plan

## Overview

This document outlines the complete process for removing git submodules from the dots repository and archiving the separate repositories, transitioning to a simpler, unified dotfiles management approach.

## Current State Analysis

### What We Have Now

```
dots/
├── .gitmodules                    # Defines submodules
├── common/.config/nvim/           # Submodule → nikbrunner/nbr.nvim
└── [other files...]

Separate Repositories:
├── nikbrunner/nbr.nvim           # Standalone nvim config repo
└── [future submodules...]
```

### Current Workflow Complexity

1. **Development**: Work in `~/.config/nvim` (submodule)
2. **Commits**: `git add . && git commit && git push origin HEAD:main`
3. **Submodule Updates**: Need to manage detached HEAD states
4. **New Files**: Require `dots link` to create symlinks
5. **Syncing**: Complex submodule update procedures

## Migration Plan

### Phase 1: Backup and Preparation

1. **Create Backup**

   ```bash
   # Backup current state
   cd ~/repos/nikbrunner/dots
   git branch backup-before-submodule-removal
   git checkout -b remove-submodules

   # Backup submodule content
   cp -r common/.config/nvim /tmp/nvim-backup
   ```

2. **Archive the Separate Repository**

   ```bash
   # Archive the standalone nvim repo
   cd ~/repos/nikbrunner/nbr.nvim
   git tag archive/standalone-repo-$(date +%Y%m%d)
   git push origin archive/standalone-repo-$(date +%Y%m%d)

   # Add archive notice to README
   echo "# ARCHIVED: This repository has been merged into nikbrunner/dots" > ARCHIVE_NOTICE.md
   git add ARCHIVE_NOTICE.md
   git commit -m "archive: repository merged into dots monorepo"
   git push
   ```

### Phase 2: Remove Submodule

1. **Remove Submodule Configuration**

   ```bash
   cd ~/repos/nikbrunner/dots

   # Remove submodule from git
   git submodule deinit -f common/.config/nvim
   rm -rf .git/modules/common/.config/nvim
   git rm -f common/.config/nvim

   # Remove .gitmodules file (if no other submodules)
   rm .gitmodules
   git add .gitmodules
   ```

2. **Add Content Directly**

   ```bash
   # Copy the content back as regular files
   cp -r /tmp/nvim-backup/* common/.config/nvim/

   # Add to git as regular files
   git add common/.config/nvim/
   git commit -m "feat: convert nvim from submodule to direct files

   - Remove submodule reference to nikbrunner/nbr.nvim
   - Add nvim configuration files directly to dots repo
   - Simplifies workflow and removes submodule complexity
   - Archive tag created in original repo: archive/standalone-repo-$(date +%Y%m%d)"
   ```

### Phase 3: Update Documentation and Scripts

1. **Update README.md**

   ```bash
   # Remove submodules section
   # Update table of contents
   # Update installation instructions
   # Add note about archived repositories
   ```

2. **Update Scripts**

   ```bash
   # Remove submodule-related code from:
   # - install.sh
   # - dots command (sub-add, sub-update commands)
   # - Remove scripts/submodules.sh
   ```

3. **Update CLAUDE.md**
   ```bash
   # Remove submodule instructions
   # Update architecture description
   # Add note about archived approach
   ```

### Phase 4: Testing and Verification

1. **Test Installation on Clean System**

   ```bash
   # Test the simplified installation
   rm -rf /tmp/test-dots
   git clone [dots-repo] /tmp/test-dots
   cd /tmp/test-dots
   ./install.sh
   ```

2. **Verify Symlinks Work**

   ```bash
   dots link
   dots status
   dots test
   ```

3. **Test New File Addition**
   ```bash
   # Create new file in nvim config
   touch common/.config/nvim/test-new-file.lua
   dots link
   # Verify symlink created
   ls -la ~/.config/nvim/test-new-file.lua
   ```

## Archive Process

### Repository Archival Steps

1. **Tag Final State**

   ```bash
   cd ~/repos/nikbrunner/nbr.nvim
   git tag final-standalone-$(date +%Y%m%d)
   git push origin final-standalone-$(date +%Y%m%d)
   ```

2. **Archive on GitHub**

   - Go to repository settings
   - Archive the repository
   - Add archive reason: "Merged into nikbrunner/dots for simplified management"

3. **Update Repository Description**

   - "🔒 ARCHIVED: Neovim configuration - now managed in nikbrunner/dots"

4. **Create Archive Documentation**

   ````markdown
   # Archive Notice

   This repository has been archived and merged into [nikbrunner/dots](https://github.com/nikbrunner/dots).

   ## Why Archived?

   - Simplified dotfiles management
   - Reduced complexity of submodule workflows
   - Unified repository approach

   ## Migration

   The content now lives at: `common/.config/nvim/` in the dots repository.

   ## Accessing This Configuration

   ```bash
   git clone https://github.com/nikbrunner/dots.git
   # Configuration is at: dots/common/.config/nvim/
   ```
   ````

   ```

   ```

## Pros and Cons Analysis

### Pros of Removing Submodules

| Benefit                       | Impact                                                                  |
| ----------------------------- | ----------------------------------------------------------------------- |
| **Simplified Workflow**       | No more submodule complexity, detached HEAD states, or HEAD:main pushes |
| **Unified Repository**        | Single repository to manage, like traditional bare repo approach        |
| **Immediate File Reflection** | New files don't require `dots link` (file-level symlinks)               |
| **Easier Collaboration**      | Contributors don't need to understand submodule workflows               |
| **Reduced Cognitive Load**    | One mental model instead of submodule + main repo                       |
| **Faster Cloning**            | No submodule initialization steps                                       |
| **Simplified CI/CD**          | No submodule update complexity in automation                            |

### Cons of Removing Submodules

| Limitation                    | Impact                                                                                  |
| ----------------------------- | --------------------------------------------------------------------------------------- |
| **Less Clean Sharing**        | Can't share just nvim config with `git clone` - need sparse checkout or manual download |
| **Larger Repository**         | All configs in one repo (though minimal impact for dotfiles)                            |
| **No Independent Versioning** | Can't version nvim config separately from other dotfiles                                |
| **Mixed Concerns**            | Nvim development mixed with general dotfiles management                                 |
| **Archive Overhead**          | Need to properly archive and document the transition                                    |

### Sharing Alternatives After Removal

| Method              | Command                                                                                       | Cleanliness |
| ------------------- | --------------------------------------------------------------------------------------------- | ----------- |
| **Sparse Checkout** | `git clone --filter=blob:none --sparse [repo] && git sparse-checkout set common/.config/nvim` | Good        |
| **GitHub URL**      | Share `https://github.com/nikbrunner/dots/tree/main/common/.config/nvim`                      | Okay        |
| **Manual Download** | Download folder from GitHub web interface                                                     | Okay        |
| **Git Subtree**     | Periodic `git subtree push` to separate repo                                                  | Complex     |

## Risk Assessment

### High Risk

- **Data Loss**: Incorrect submodule removal could lose configuration history
  - **Mitigation**: Create multiple backups, use branches, tag important states

### Medium Risk

- **Workflow Disruption**: Change in development habits
  - **Mitigation**: Clear documentation, gradual transition

### Low Risk

- **Sharing Inconvenience**: Less clean sharing of nvim config
  - **Mitigation**: Document alternative sharing methods

## Rollback Plan

If the migration needs to be reversed:

```bash
# Restore from backup branch
git checkout backup-before-submodule-removal
git checkout -b restore-submodules

# Re-add submodule
git submodule add git@github.com:nikbrunner/nbr.nvim.git common/.config/nvim
git submodule update --init --recursive

# Remove direct files
git rm -r common/.config/nvim/
git commit -m "restore: revert to submodule approach"
```

## Decision Matrix

| Factor                     | Submodules | Direct Files | Weight | Winner     |
| -------------------------- | ---------- | ------------ | ------ | ---------- |
| **Development Simplicity** | 3/10       | 9/10         | High   | Direct     |
| **Sharing Cleanliness**    | 10/10      | 6/10         | Medium | Submodules |
| **Maintenance Overhead**   | 4/10       | 9/10         | High   | Direct     |
| **Learning Curve**         | 3/10       | 9/10         | Medium | Direct     |
| **Flexibility**            | 8/10       | 7/10         | Low    | Submodules |

**Recommendation**: Direct files approach wins on the most important factors for daily development workflow.

## Implementation Timeline

- **Phase 1**: 30 minutes (backup and archive)
- **Phase 2**: 15 minutes (remove submodule, add files)
- **Phase 3**: 45 minutes (update documentation and scripts)
- **Phase 4**: 30 minutes (testing and verification)

**Total**: ~2 hours for complete migration

## Post-Migration Workflow

```bash
# New simplified workflow:
cd ~/.config/nvim           # or ~/repos/nikbrunner/dots/common/.config/nvim
# Edit files
git add .
git commit -m "feat: new nvim feature"
git push

# No submodule updates needed!
# No detached HEAD states!
# No HEAD:main pushes!
```

## Conclusion

The submodule approach adds significant complexity for minimal benefit in a personal dotfiles repository. The direct files approach aligns better with the simplicity goals and provides a more intuitive workflow similar to traditional bare repository setups.

The migration is low-risk with proper backups and can be completed in about 2 hours with full testing and documentation updates.
