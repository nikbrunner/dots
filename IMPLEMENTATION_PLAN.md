# Implementation Plan

This document outlines detailed implementation plans for roadmap items and system improvements.

## Roadmap Items

### 1. Modularize `dots` command

**Current State**: The `dots` command is a single monolithic script with ~925 lines in `common/bin/dots`.

**Goal**: Break down the dots command into modular components for better maintainability, testing, and development.

**Implementation Plan**:

#### Phase 1: Extract Core Functions (High Priority)

- **Target**: `common/bin/dots-core/`
- **Files to create**:
  - `common/bin/dots-core/lib/logging.sh` - Extract all logging functions (log_section, log_success, etc.)
  - `common/bin/dots-core/lib/utils.sh` - Extract utility functions (check_gum, do_push, etc.)
  - `common/bin/dots-core/lib/git-ops.sh` - Extract git operations (cmd_sync, cmd_push, cmd_commit)
  - `common/bin/dots-core/lib/symlink-ops.sh` - Extract symlink operations (cmd_link, cmd_clean, cmd_status)
  - `common/bin/dots-core/lib/file-ops.sh` - Extract file management (cmd_add, cmd_remove)
  - `common/bin/dots-core/lib/submodule-ops.sh` - Extract submodule operations (cmd_sub_update, cmd_sub_add)
  - `common/bin/dots-core/lib/system-ops.sh` - Extract system operations (cmd_test, cmd_format)

#### Phase 2: Create Command Modules (Medium Priority)

- **Target**: `common/bin/dots-core/commands/`
- **Files to create**:
  - `common/bin/dots-core/commands/install.sh` - Install command logic
  - `common/bin/dots-core/commands/link.sh` - Link command logic
  - `common/bin/dots-core/commands/sync.sh` - Sync command logic
  - `common/bin/dots-core/commands/status.sh` - Status command logic
  - `common/bin/dots-core/commands/test.sh` - Test command logic
  - `common/bin/dots-core/commands/format.sh` - Format command logic
  - `common/bin/dots-core/commands/add.sh` - Add command logic
  - `common/bin/dots-core/commands/remove.sh` - Remove command logic

#### Phase 3: Main Command Dispatcher (Low Priority)

- **Target**: Simplified `common/bin/dots`
- **Implementation**:
  - Reduce main script to ~100 lines
  - Simple command dispatcher that sources appropriate modules

**Benefits**:

- Easier to test individual components
- Better code organization and readability
- Enables parallel development of features
- Reduces cognitive load when working on specific functionality
- Enables selective loading for better performance

**Implementation Steps**:

1. Create directory structure
2. Extract logging and utility functions first (least risky)
3. Extract command functions one by one
4. Update main dispatcher
5. Add comprehensive tests for each module
6. Update documentation

---

### 2. Remove old commands

**Current State**: There may be deprecated or unused commands in the codebase.

**Goal**: Clean up obsolete commands and scripts to reduce maintenance burden.

**Implementation Plan**:

#### Phase 1: Audit Current Commands

- **Files to audit**:
  - All scripts in `common/bin/`
  - All scripts in `scripts/`
  - Command list in `dots` help output
  - Command usage in documentation

#### Phase 2: Identify Deprecated Commands

- **Commands to evaluate**:
  - Check if `claude-commit` is still used vs new `dots commit`
  - Verify if `smart-commit`, `smart-branch`, `smart-git-message` are still needed
  - Review `mac-setup` for relevance
  - Check `tmux_2x2_layout` usage
  - Evaluate `nsr` script necessity

#### Phase 3: Create Migration Plan

- **For each deprecated command**:
  - Document replacement functionality
  - Create migration notes
  - Add deprecation warnings before removal

#### Phase 4: Remove Deprecated Commands

- **Process**:
  1. Add deprecation warnings to old commands
  2. Update documentation to reference new commands
  3. Wait for one release cycle
  4. Remove deprecated commands
  5. Update symlink mappings
  6. Clean up references in scripts

**Benefits**:

- Reduced maintenance overhead
- Cleaner codebase
- Less confusion for users
- Improved system reliability

---

### 3. Add submodules for `nvim`, `wezterm`

**Current State**: Configuration for nvim and wezterm likely exists as separate repositories but are not integrated as submodules.

**Goal**: Integrate nvim and wezterm configurations as git submodules for centralized management.

**Implementation Plan**:

#### Phase 1: Prepare Submodule Structure

- **Directory**: `submodules/`
- **Expected submodules**:
  - `submodules/nvim` - Neovim configuration
  - `submodules/wezterm` - WezTerm configuration
  - `submodules/zed` - Zed configuration (private repo)

#### Phase 2: Add Neovim Submodule

- **Repository**: Likely `https://github.com/nikbrunner/nvim` or similar
- **Implementation**:
  ```bash
  dots sub-add https://github.com/nikbrunner/nvim submodules/nvim
  ```
- **Symlink setup**:
  - Create symlink from `~/.config/nvim` to `submodules/nvim`
  - Update mapping generation to handle submodule symlinks

#### Phase 3: Add WezTerm Submodule

- **Repository**: Likely `https://github.com/nikbrunner/wezterm` or similar
- **Implementation**:
  ```bash
  dots sub-add https://github.com/nikbrunner/wezterm submodules/wezterm
  ```
- **Symlink setup**:
  - Create symlink from `~/.config/wezterm` to `submodules/wezterm`
  - Update mapping generation to handle submodule symlinks

#### Phase 4: Enhance Submodule Management

- **Features to add**:
  - `dots sub-status` - Show status of all submodules
  - `dots sub-update` enhancement - Better progress reporting
  - `dots sub-remove` - Remove submodules cleanly
  - `dots sub-sync` - Sync all submodules to latest

#### Phase 5: Update Documentation

- **Files to update**:
  - README.md - Update submodule section
  - CLAUDE.md - Add submodule management guidance
  - Installation instructions

**Benefits**:

- Centralized configuration management
- Version control for editor configurations
- Easy synchronization across machines
- Ability to rollback configuration changes
- Shared configuration development

**Prerequisites**:

- Ensure nvim and wezterm repos exist and are properly structured
- Verify that submodule approach works better than current setup
- Test submodule workflow thoroughly

---

## Additional System Improvements

### 1. Enhanced Testing Framework

**Current State**: Basic testing in `dots test` command.

**Proposed Improvements**:

- Unit tests for individual functions
- Integration tests for command workflows
- Performance benchmarks for large configurations
- Cross-platform testing automation

### 2. Configuration Validation

**Current State**: Minimal validation of configuration files.

**Proposed Features**:

- JSON schema validation for mapping files
- Configuration file syntax checking
- Broken symlink detection and repair
- Duplicate file detection

### 3. Enhanced Backup System

**Current State**: Basic backup on symlink creation.

**Proposed Enhancements**:

- Better backup naming and organization
- Cleanup of old backup files
- Backup summary reporting

### 4. Performance Optimizations

**Current Areas for Improvement**:

- Parallel symlink creation for large configurations
- Cached mapping generation
- Incremental updates instead of full regeneration
- Lazy loading of command modules

### 5. User Experience Enhancements

**Proposed Features**:

- Interactive setup wizard
- Configuration conflict resolution
- Better error messages and recovery suggestions
- Shell completion for dots commands

---

## Implementation Priority

**High Priority** (Next 1-2 months):

1. Add nvim and wezterm submodules
2. Begin dots command modularization (Phase 1)
3. Audit and remove old commands

**Medium Priority** (Next 3-6 months):

1. Complete dots command modularization
2. Enhanced testing framework
3. Configuration validation system

**Low Priority** (Future):

1. Enhanced backup system
2. Performance optimizations
3. User experience enhancements

---

## Migration Strategy

For each major change:

1. **Clean Implementation**: Focus on clean, simple implementations without legacy support
2. **Incremental Changes**: Implement changes one module at a time
3. **Testing**: Comprehensive testing before deployment
4. **Documentation**: Update docs with each change

## Success Metrics

- **Code Quality**: Reduced complexity in main dots script
- **Maintainability**: Easier to add new features and fix bugs
- **User Experience**: Faster command execution and better error handling
- **Reliability**: Fewer edge cases and error scenarios
- **Coverage**: More comprehensive testing and validation
