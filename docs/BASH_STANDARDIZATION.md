# Bash Standardization Implementation Plan

## Overview

Implementation plan for standardizing bash usage across all scripts in the dotfiles repository to enable modern bash features while maintaining cross-platform compatibility.

## Current State Analysis

### Bash Version Issues

**macOS Default (Current Problem):**
- System bash: 3.2.57 (from 2007)
- Limitations: No associative arrays, limited features
- Location: `/bin/bash`

**Modern Bash (Solution):**
- Homebrew bash: 5.2.37 (installed)
- Features: Associative arrays, modern syntax, better error handling
- Location: `/opt/homebrew/bin/bash`
- PATH: Available via `which bash` → `/opt/homebrew/bin/bash`

### Current Shebang Patterns

**Analysis of `common/bin/` files:**

| File | Current Shebang | Status |
|------|----------------|---------|
| `dots` | `#!/usr/bin/env bash` | ✅ Correct |
| `repos` | `#!/usr/bin/env bash` | ✅ Correct |
| `nsr` | `#!/usr/bin/env bash` | ✅ Correct |
| `mac-setup` | `#!/opt/homebrew/bin/bash` | ❌ Hardcoded path |
| `tl-ide` | `#!/opt/homebrew/bin/bash` | ❌ Hardcoded path |
| `tl-2x2` | `#!/opt/homebrew/bin/bash` | ❌ Hardcoded path |
| `smart-clone` | `#!/bin/bash` | ❌ Old bash |
| `smart-commit` | `#!/bin/bash` | ❌ Old bash |
| `smart-branch` | `#!/bin/bash` | ❌ Old bash |

**Summary:**
- ✅ **3 files** already use portable shebang
- ❌ **6 files** need standardization

## Problem Statement

### Current Limitations
1. **Feature Restrictions**: Cannot use associative arrays (bash 4+ feature)
2. **Code Complexity**: Workarounds for bash 3.2 limitations make code harder to maintain
3. **Inconsistent Shebangs**: Mixed approaches across bin files
4. **Platform-Specific Paths**: Hardcoded Homebrew paths won't work on other systems

### Cross-Platform Requirements
- **macOS**: Homebrew bash available, needs to be in PATH
- **Arch Linux**: Modern bash (5.x) is system default at `/usr/bin/bash`
- **Other Linux**: Usually bash 4+ available
- **Compatibility**: Need one approach that works everywhere

## Solution Design

### Recommended Approach: `#!/usr/bin/env bash`

**Rationale:**
1. **PATH-aware**: Uses first bash found in PATH
2. **Cross-platform**: Works on macOS (Homebrew) and Linux (system)
3. **Future-proof**: Doesn't hardcode installation paths
4. **Industry standard**: Widely adopted best practice

**How it Works:**
- **macOS**: `env bash` finds `/opt/homebrew/bin/bash` (via PATH)
- **Arch**: `env bash` finds `/usr/bin/bash` (system default)
- **Other**: `env bash` finds first bash in PATH

### PATH Configuration

**macOS (Homebrew):**
```bash
# Usually auto-configured by Homebrew in ~/.zshrc
export PATH="/opt/homebrew/bin:$PATH"
```

**Verification:**
```bash
$ which bash
/opt/homebrew/bin/bash
$ bash --version
GNU bash, version 5.2.37
```

**Arch Linux:**
```bash
$ which bash  
/usr/bin/bash
$ bash --version
GNU bash, version 5.2.x
```

## Implementation Steps

### Phase 1: Shebang Standardization
- [ ] Update 6 files to use `#!/usr/bin/env bash`
- [ ] Verify all scripts work with modern bash
- [ ] Test cross-platform compatibility

### Phase 2: Modern Bash Features
- [ ] Revert `repos` script to use associative arrays
- [ ] Clean up bash 3.2 workarounds
- [ ] Implement cleaner, more maintainable code

### Phase 3: Documentation
- [ ] Update dependency requirements
- [ ] Add installation instructions per platform
- [ ] Document bash version requirements

### Phase 4: Testing
- [ ] Test all scripts on macOS with Homebrew bash
- [ ] Verify PATH configuration
- [ ] Document troubleshooting steps

## Detailed File Changes

### Files Requiring Shebang Updates

**1. `/common/bin/mac-setup`**
```diff
- #!/opt/homebrew/bin/bash
+ #!/usr/bin/env bash
```

**2. `/common/bin/tl-ide`**
```diff
- #!/opt/homebrew/bin/bash
+ #!/usr/bin/env bash
```

**3. `/common/bin/tl-2x2`**
```diff
- #!/opt/homebrew/bin/bash
+ #!/usr/bin/env bash
```

**4. `/common/bin/smart-clone`**
```diff
- #!/bin/bash
+ #!/usr/bin/env bash
```

**5. `/common/bin/smart-commit`**
```diff
- #!/bin/bash
+ #!/usr/bin/env bash
```

**6. `/common/bin/smart-branch`**
```diff
- #!/bin/bash
+ #!/usr/bin/env bash
```

### Modern Bash Feature Implementation

**Example: Repos Script Cleanup**
```bash
# Instead of complex temp file workarounds for bash 3.2:
declare -A owner_dirty_repos
declare -A owner_non_git_repos

# Clean, readable associative array usage
owner_dirty_repos["$owner"]+="$repo "
```

## Cross-Platform Compatibility

### macOS Setup
```bash
# Install modern bash (if not already done)
brew install bash

# Verify PATH includes Homebrew
echo $PATH | grep homebrew

# Verify bash version
bash --version  # Should show 5.2.x
```

### Arch Linux Setup
```bash
# Bash is already modern (5.x) by default
bash --version  # Should show 5.x

# No additional setup needed
which bash  # Shows /usr/bin/bash
```

### Other Linux Distributions
```bash
# Ubuntu/Debian
sudo apt update && sudo apt install bash

# CentOS/RHEL
sudo yum update bash

# Verify version (should be 4.0+)
bash --version
```

## Benefits

### Code Quality
- **Cleaner syntax**: Use modern bash features
- **Better maintainability**: Remove bash 3.2 workarounds
- **Enhanced readability**: Associative arrays vs temp files

### Compatibility
- **Cross-platform**: Single approach works everywhere
- **Future-proof**: Not tied to specific installation paths
- **Consistent**: All scripts use same shebang pattern

### Development Experience
- **Modern features**: Arrays, better error handling, etc.
- **Debugging**: Better error messages and stack traces
- **IDE support**: Better syntax highlighting and completion

## Risk Mitigation

### Potential Issues
1. **Missing modern bash**: User doesn't have bash 4+
2. **PATH misconfiguration**: Modern bash not in PATH
3. **Script compatibility**: Existing scripts break with new bash

### Solutions
1. **Clear documentation**: Installation instructions per platform
2. **Graceful error handling**: Check bash version in critical scripts
3. **Testing**: Comprehensive testing on both old and new bash

### Validation Script
```bash
#!/usr/bin/env bash
# Check bash version compatibility
if ((BASH_VERSINFO[0] < 4)); then
    echo "Error: Bash 4.0+ required. Current: $BASH_VERSION"
    echo "macOS: brew install bash"
    echo "Linux: Install bash via package manager"
    exit 1
fi
```

## Documentation Updates

### README.md Dependencies Section
```markdown
## Dependencies

- **Git** - Version control
- **Bash 4+** - Shell scripting
  - macOS: `brew install bash` 
  - Arch: Already installed (5.x)
  - Ubuntu: `sudo apt install bash`
- **Standard Unix tools** - ln, mkdir, etc.
```

### Installation Instructions
- Add bash requirement to setup steps
- Include verification commands
- Provide troubleshooting guide

## Testing Plan

### Verification Steps
1. **Shebang validation**: All files use `#!/usr/bin/env bash`
2. **Version check**: `bash --version` shows 4.0+
3. **PATH verification**: `which bash` points to modern bash
4. **Script execution**: All bin scripts work correctly
5. **Feature testing**: Associative arrays work in repos script

### Test Environments
- **macOS**: With Homebrew bash
- **Arch Linux**: With system bash
- **Ubuntu/Debian**: With updated bash

## Timeline

### Immediate (Phase 1)
- Standardize shebangs across all bin files
- Verify basic functionality

### Short-term (Phase 2)
- Implement modern bash features in repos script
- Clean up bash 3.2 workarounds

### Medium-term (Phase 3)
- Update documentation
- Add installation guides

## Related Documentation

- [REPOS_CLEANUP_WORKFLOW.md](REPOS_CLEANUP_WORKFLOW.md) - Depends on modern bash features
- [README.md](../README.md) - Main documentation requiring updates
- [TESTING.md](../TESTING.md) - Testing procedures for bash compatibility