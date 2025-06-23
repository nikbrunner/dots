# Changelog

All notable changes to this dotfiles repository will be documented in this file.

## 2025-06-22

### 🐛 Critical Bug Fixes

- **Fixed Script Exit Issue on Linux**: Resolved scripts exiting immediately during symlink processing
  - Root cause: `((variable++))` arithmetic syntax incompatibility with certain bash environments when `set -e` is enabled
  - Solution: Replaced all `((variable++))` with `variable=$((variable + 1))` for better compatibility
  - Affected scripts: `install.sh`, `link.sh`, and `symlinks.sh` library
  - Impact: Full Linux compatibility restored

### 🔧 Shell Compatibility Improvements

- **Standardized Shell Usage**: Fixed mixed shell requirements across scripts
  - Standardized all scripts to use `#!/usr/bin/env bash` shebang
  - Removed zsh-specific syntax `${(%):-%x}` in favor of bash-only `${BASH_SOURCE[0]}`
  - Ensures consistent behavior across different systems

### 🛠 Enhanced Debugging

- **Added Debug Flag Support**: Implemented `--debug` flag for comprehensive diagnostics
  - Available in `install.sh` and `link.sh` for troubleshooting
  - Provides detailed execution tracing during symlink operations
  - Useful for cross-platform compatibility testing

### 📚 Documentation Updates

- **Updated Linux Compatibility Guide**: Added section on recently fixed issues
- **Enhanced README**: Removed obsolete known issues, added troubleshooting section
- **Improved Installation Instructions**: Added debug flag usage examples

## 2025-06-21

### 🐛 Bug Fixes

- **Fixed `dots status` Hanging**: Resolved hanging issue during symlink checking
  - Root cause: File descriptor conflicts in nested bash function contexts
  - Solution: Unified library that works both as standalone script and library
  - Eliminated code duplication and improved maintainability

### 🔧 Code Improvements

- **Unified Symlink Library**: Created `scripts/lib/symlinks.sh` as hybrid library/script
  - Single file handles both library (sourced) and standalone execution
  - Consolidated all symlink operations (check, create, update, cleanup)
  - Eliminated duplicate code between status and link commands
  - Simplified architecture with fewer files to maintain

### 🚀 Major Features

- **Complete Machine Setup**: Enhanced `dots install` with automatic dependency management
  - Unified dependency installation for macOS (Homebrew) and Linux (Arch/pacman)
  - Single command machine setup: `dots install` handles everything
  - Cross-platform package mapping with proper 1Password integration
  - System configuration (shell, Git signing, NVM installation)
- **Unified Repository Command**: Replaced `smart-commit` and `smart-branch` with new unified `repo` command
  - Manual operations: `repo commit` (opens lazygit), `repo branch "name"` (direct creation)
  - AI-powered operations: `repo commit -s`, `repo branch -s` with Claude Code/API support
  - Updated git aliases: `git sc` → `repo commit -s`, `git sb` → `repo branch -s`
- **Git Commit Signing**: Added SSH-based commit signing with 1Password integration
  - Configured GPG signing with SSH keys and 1Password's `op-ssh-sign`
  - Added `allowed_signers` file for signature verification
- **Cross-Platform Git Configuration**: OS-specific Git configs with conditional includes for 1Password paths

### 📚 Documentation

- **SSH Setup Guide**: Created comprehensive `docs/SSH_SETUP.md` for 1Password SSH integration
  - Personal reference for setting up SSH on new machines
  - 1Password SSH agent configuration instructions
  - Linux-specific considerations for different paths

### 🛠 Repository Management

- **Enhanced `repos` Tool**: Improved repository management script with cleanup workflow
  - Interactive cleanup with lazygit integration
  - Progress tracking for bulk operations
  - Better handling of non-git directories

### 🔧 Script Improvements

- **Fixed Link Script Hanging**: Resolved process substitution issues causing symlink operations to hang
- **Simplified Dependencies**: Removed essential/optional distinction - all tools are now required
- **Linux Compatibility**: Enhanced cross-platform support with OS detection and package manager abstraction
- **Claude API Migration**: Migrated `smart-branch` from OpenAI to Claude API for consistency
- **Claude Code Integration**: Added support for Claude Code CLI across smart scripts
- **Bash Standardization**: Standardized bash usage across all scripts for better compatibility

## 2025-06-20

### 🚀 Major Features

- **Repository Manager**: Created comprehensive `repos` command for managing multiple repositories
  - `repos find` - Search and open files across all repositories with fzf
  - `repos open` - Open repositories in tmux with fuzzy selection
  - `repos status` - Show git status for all repositories
  - `repos config` - Edit configuration with repository lists
  - Parallel cloning and enhanced UX with gum integration

### 🎨 User Experience

- **Enhanced File Search**: Added syntax highlighting and improved fzf layout for file previews
- **Better Error Handling**: Improved error messages and spinner execution issues

## 2025-06-19

### 🚀 Major Features

- **Submodule Integration**: Implemented direct submodule support
  - Added `dots sub-commit` command for managing submodule hash updates
  - Added `dots sub-status` command for submodule status overview
  - Integrated WezTerm configuration as submodule
- **Configuration Additions**: Added multiple new tool configurations
  - GitHub CLI configuration files
  - Yazi file manager with dots repository shortcut
  - Zed editor theme files

### 🔧 System Improvements

- **Enhanced Link Command**: Added concise output with optional verbose mode
- **Format Command**: Added repository file formatting with Prettier and shfmt
- **Submodule Documentation**: Created comprehensive `docs/SUBMODULES.md` guide

### 🧹 Cleanup

- **Documentation Restructure**: Streamlined README and moved submodule docs to separate file
- **Git Hooks Removal**: Removed git hooks from dots management system
- **Old File Archival**: Archived old dotfiles for clean migration

## 2025-06-18

### 🔄 Major Refactoring

- **Simplified Architecture**: Removed JSON mapping system in favor of direct file traversal
  - ~60% reduction in code complexity
  - Direct mirror-home-directory structure
  - Merged simplification PR (#1)
- **Script Cleanup**: Removed deprecated scripts and optimized existing ones
  - Removed `claude-commit` and `smart-git-message` scripts
  - Renamed tmux layout scripts with shorter aliases
  - Optimized symlink cleanup and file processing

### 🛠 Build System

- **Enhanced Testing**: Added shellcheck linting to test command
- **Improved UX**: Removed `add` and `remove` commands, simplified workflow
- **Submodule Management**: Removed unused tmux plugins submodules

## 2025-06-17

### 🎉 Initial Setup

- **Project Migration**: Initial migration from old dotfiles system
- **Core Architecture**: Implemented symlink-based dotfiles management
  - File-level symlink mapping system
  - Mirror home directory structure
  - Comprehensive test command with UX improvements

### 🛠 Core Commands

- **Dots CLI**: Created unified `dots` command interface
  - `dots link` - Symlink management with auto-backup
  - `dots status` - Enhanced status with symlink checking
  - `dots clean` and `dots install` with dry-run support
  - `dots test` - Comprehensive system validation
  - `dots format` - Code quality formatting

### 🎨 User Experience

- **Beautiful Interface**: Added gum integration for enhanced CLI experience
- **Interactive Features**: Added interactive commit command and improved push workflow
- **Comprehensive Documentation**: Created CLAUDE.md and enhanced README

### ⚙️ Configuration

- **Git Integration**: Enhanced git push error handling
- **Theme Management**: Added delta git diff theme configuration
- **Development Tools**: Added file management commands and git hooks

---

_This changelog covers the initial development period of the modernized dotfiles system, focusing on creating a robust, user-friendly, and well-documented configuration management solution._
