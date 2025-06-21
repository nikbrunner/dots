# Dependency Management Implementation Plan

## Overview

Implementation plan for creating a unified dependency management system where `dots install` handles all essential dependencies, and individual scripts intelligently detect missing dependencies and guide users to the installation process.

## Current State Analysis

### Existing Dependency Handling

**Current `dots install`:**
- Only runs `install.sh` script
- Handles symlink creation and submodule setup
- No dependency installation or verification

**Current `repos install`:**
- Has comprehensive dependency checking (git, fzf, tmux, gum, gh)
- Provides OS-specific installation instructions
- Good UX with status reporting and guidance

**Other Scripts:**
- Mixed dependency handling across different scripts
- No unified approach or error messaging
- Users need to manually install dependencies

### Target Dependencies

- **Git** - Version control operations
- **Bash 4+** - Modern shell features (already handled)
- **fzf** - Fuzzy finding for repos, file selection
- **tmux** - Repository session management
- **Standard Unix tools** - ln, mkdir, find, etc.
- **ripgrep** - Fuzzy finding for files
- **neovim** - Text editor
- **gum** - Beautiful CLI prompts and confirmations
- **GitHub CLI (gh)** - Wildcard repository cloning
- **LazyGit** - Interactive git management
- **bat** - Syntax highlighting in file previews
- **delta** - Enhanced git diff output

### Target Platforms

**Primary:**
- **macOS** - Homebrew package manager
- **Arch Linux** - pacman package manager

**Future:**
- Other Linux distributions (apt, yum, etc.)

## Problem Statement

### Current Pain Points

1. **Fragmented Setup**: Users must manually install dependencies
2. **Inconsistent Experience**: Different scripts handle missing dependencies differently
3. **Platform Confusion**: Users unsure what to install on their specific OS
4. **No Guidance**: Scripts fail without helpful suggestions
5. **Redundant Code**: Dependency checking duplicated across scripts

### User Experience Goals

1. **One Command Setup**: `dots install` handles everything
2. **Intelligent Detection**: Scripts detect missing deps and provide guidance
3. **OS-Aware Installation**: Automatic platform detection and appropriate commands
4. **Graceful Degradation**: Scripts work with reduced functionality when optional deps missing
5. **Clear Feedback**: Users know exactly what's needed and how to get it

## Solution Design

### Architecture Overview

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   dots install  │────│  Dependency Core │────│ Individual Bins │
│                 │    │                  │    │                 │
│ • OS Detection  │    │ • Detection      │    │ • Check deps    │
│ • Package Mgmt  │    │ • Installation   │    │ • Show guidance │
│ • User Guidance │    │ • Validation     │    │ • Graceful fail │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │
                      ┌──────────────────┐
                      │   Shared Library │
                      │                  │
                      │ • OS detection   │
                      │ • Dep functions  │
                      │ • Error messages │
                      └──────────────────┘
```

### Core Components

#### 1. Shared Dependency Library (`scripts/deps.sh`)

**Functions:**
- `detect_os()` - Detect macOS vs Arch vs other
- `check_dependency()` - Test if command exists
- `install_dependency()` - Install via appropriate package manager
- `check_all_dependencies()` - Comprehensive dependency check
- `show_missing_deps_guidance()` - User-friendly error messages

#### 2. Enhanced `dots install` Command

**Responsibilities:**
- Detect operating system
- Check all essential dependencies
- Install missing dependencies with user confirmation
- Verify installations
- Set up symlinks and submodules (existing functionality)
- Provide summary and next steps

#### 3. Dependency Integration in Bins

**Each script:**
- Sources shared dependency library
- Checks required dependencies on startup
- Shows helpful error messages with `dots install` suggestion
- Gracefully handles optional dependencies

## Implementation Plan

### Phase 1: Core Infrastructure

#### 1.1 Create Shared Dependency Library
- [ ] Create `scripts/deps.sh` with core functions
- [ ] Implement OS detection (macOS, Arch, other)
- [ ] Add dependency checking functions
- [ ] Create user-friendly error messaging

#### 1.2 Dependency Definition
- [ ] Define essential vs optional dependencies
- [ ] Map dependencies to package names per OS
- [ ] Create validation functions for each dependency

#### 1.3 Package Manager Integration
- [ ] Implement Homebrew integration for macOS
- [ ] Implement pacman integration for Arch Linux
- [ ] Add user confirmation prompts for installations

### Phase 2: Enhanced `dots install`

#### 2.1 Integrate Dependency Management
- [ ] Source dependency library in `dots install`
- [ ] Add dependency checking phase
- [ ] Implement interactive installation prompts
- [ ] Add installation progress feedback

#### 2.2 Preserve Existing Functionality
- [ ] Maintain symlink creation
- [ ] Maintain submodule setup
- [ ] Add dependency verification to final summary

#### 2.3 Enhanced User Experience
- [ ] Add installation progress indicators
- [ ] Provide clear success/failure feedback
- [ ] Show post-installation verification

### Phase 3: Script Integration

#### 3.1 High-Priority Scripts
- [ ] Integrate into `repos` script
- [ ] Integrate into `dots` core commands
- [ ] Add graceful degradation for optional dependencies

#### 3.2 Lower-Priority Scripts
- [ ] Integrate into utility scripts (smart-commit, etc.)
- [ ] Ensure consistent error messaging
- [ ] Add helpful guidance messages

#### 3.3 Testing and Validation
- [ ] Test on macOS with missing dependencies
- [ ] Test on Arch Linux with missing dependencies
- [ ] Verify graceful degradation scenarios

### Phase 4: Documentation and Polish

#### 4.1 User Documentation
- [ ] Update README with dependency information
- [ ] Add troubleshooting guide
- [ ] Document manual installation procedures

#### 4.2 Developer Documentation
- [ ] Document dependency library usage
- [ ] Add guidelines for script integration
- [ ] Create contribution guidelines for new dependencies

## Technical Implementation Details

### Dependency Categories

```bash
DEPS=(
    "git:Git version control"
    "fzf:Fuzzy finder for interactive selection"
    "tmux:Terminal multiplexer for session management"
    "ripgrep:Fuzzy finder for file selection",
    "neovim:Text editor",
    "gum:Enhanced CLI prompts and styling"
    "gh:GitHub CLI for repository operations"
    "lazygit:Interactive git interface"
    "bat:Syntax highlighting for file previews"
    "delta:Enhanced git diff output"
)
```

### OS-Specific Package Mapping

```bash
# Package name mapping per OS
declare -A MACOS_PACKAGES=(
    ["fzf"]="fzf"
    ["tmux"]="tmux"
    ["gum"]="gum"
    ["gh"]="gh"
    ["lazygit"]="lazygit"
    ["bat"]="bat"
    ["delta"]="git-delta"
)

declare -A ARCH_PACKAGES=(
    ["fzf"]="fzf"
    ["tmux"]="tmux"
    ["gum"]="gum"
    ["gh"]="github-cli"
    ["lazygit"]="lazygit"
    ["bat"]="bat"
    ["delta"]="git-delta"
)
```

### Error Message Templates

```bash
show_dependency_error() {
    local missing_dep="$1"
    local script_name="$2"
    
    echo "❌ Missing required dependency: $missing_dep"
    echo "📋 The '$script_name' script requires $missing_dep to function properly."
    echo ""
    echo "🚀 Quick fix: Run 'dots install' to install all dependencies automatically"
    echo "📚 Or install manually:"
    show_manual_install_instructions "$missing_dep"
}
```

### Integration Pattern for Scripts

```bash
#!/usr/bin/env bash

# Source dependency functions
source "$(dirname "${BASH_SOURCE[0]}")/../scripts/deps.sh" 2>/dev/null || {
    echo "Error: Could not load dependency functions"
    exit 1
}

# Check essential dependencies
check_essential_dependencies "fzf" "tmux" || {
    echo ""
    echo "💡 Run 'dots install' to install missing dependencies"
    exit 1
}

# Check optional dependencies with graceful degradation
if ! check_dependency "gum"; then
    log_warning "gum not available - using basic prompts"
    HAS_GUM=false
else
    HAS_GUM=true
fi

# Rest of script...
```

## User Experience Flow

### Initial Setup Experience

```bash
$ dots install
🔍 Detecting operating system... macOS (Homebrew)
📋 Checking dependencies...

Essential Dependencies:
  ✅ git - already installed
  ❌ fzf - missing
  ❌ tmux - missing

Optional Dependencies:
  ❌ gum - missing (enhanced CLI experience)
  ❌ gh - missing (GitHub repository operations)
  ✅ lazygit - already installed

🚀 Install missing dependencies? (y/N) y

📦 Installing fzf...
📦 Installing tmux...
📦 Installing gum...
📦 Installing gh...

✅ All dependencies installed successfully!

🔗 Creating symlinks...
📁 Setting up submodules...

🎉 Setup complete! Your dotfiles are ready to use.

Next steps:
  • Try 'repos status' to see your repositories
  • Run 'dots status' to verify your configuration
  • Use 'dots --help' for available commands
```

### Script-Level Dependency Detection

```bash
$ repos status
❌ Missing required dependency: fzf
📋 The 'repos' script requires fzf to function properly.

🚀 Quick fix: Run 'dots install' to install all dependencies automatically
📚 Or install manually:
  macOS: brew install fzf
  Arch:  sudo pacman -S fzf

💡 Run 'dots install' to install missing dependencies
```

## Benefits

### For Users
1. **Simplified Setup**: One command installs everything needed
2. **Clear Guidance**: Always know what's missing and how to fix it
3. **Platform Awareness**: Automatic detection and appropriate commands
4. **Reduced Friction**: Scripts work immediately after dependency installation

### For Developers
1. **Consistent Patterns**: Standardized dependency handling across scripts
2. **Shared Code**: Reusable dependency functions reduce duplication
3. **Better Error Messages**: Users get helpful feedback instead of cryptic failures
4. **Easier Maintenance**: Centralized dependency management

### For System
1. **Robust Operation**: Scripts fail gracefully with helpful messages
2. **Optional Enhancement**: Optional dependencies provide better UX without breaking core functionality
3. **Cross-Platform**: Works consistently across target operating systems

## Testing Strategy

### Automated Testing
- Test dependency detection on clean systems
- Verify installation commands for each package manager
- Test graceful degradation with missing optional dependencies

### Manual Testing Scenarios
1. **Fresh macOS**: Test complete dependency installation flow
2. **Fresh Arch Linux**: Test complete dependency installation flow
3. **Partial Dependencies**: Test with some dependencies already installed
4. **Network Issues**: Test behavior when package installation fails
5. **Permission Issues**: Test with insufficient privileges

## Future Enhancements

### Advanced Features
- **Dependency Version Checking**: Ensure minimum required versions
- **Automatic Updates**: Keep dependencies current
- **Custom Package Sources**: Support for alternative package managers
- **Offline Mode**: Graceful handling when network unavailable

### Extended Platform Support
- **Ubuntu/Debian**: apt package manager support
- **CentOS/RHEL**: yum/dnf package manager support
- **Windows**: WSL and package manager support

## Success Metrics

### User Experience Metrics
- **Setup Time**: Reduce time from clone to functional dotfiles
- **Error Rate**: Minimize dependency-related script failures
- **User Feedback**: Collect feedback on installation experience

### Technical Metrics
- **Code Duplication**: Reduce dependency checking code across scripts
- **Error Clarity**: Improve error message helpfulness
- **Platform Coverage**: Ensure consistent experience across target platforms

## Related Documentation

- [BASH_STANDARDIZATION.md](BASH_STANDARDIZATION.md) - Foundation for dependency management
- [REPOS_CLEANUP_WORKFLOW.md](REPOS_CLEANUP_WORKFLOW.md) - Will benefit from dependency management
- [README.md](../README.md) - User-facing documentation updates needed
