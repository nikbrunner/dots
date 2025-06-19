# Dots Command Refactor Plan

## Current State Analysis

The `common/bin/dots` file has grown to **645 lines** with **22 functions** handling multiple responsibilities:

- Command parsing and dispatch (44 lines)
- Git operations (status, commit, push, log) (~100 lines)
- Submodule management (add, update, commit, status) (~150 lines)
- Symlink operations (via scripts/link.sh) (~50 lines)
- System testing and validation (~160 lines)
- Output formatting and user interaction (~140 lines)

## Issues to Address

### 1. **Massive Functions with Multiple Responsibilities**

- `cmd_test()`: 157 lines doing 7 different unrelated tests
- `show_usage()`: 42 lines with duplicated gum vs non-gum logic
- `cmd_status()`: 94 lines including nested function definition
- `do_push()`: 46 lines handling multiple push scenarios with complex nested logic

### 2. **Duplicated Gum Integration Logic**

- Every `log_*` function (35 lines total) duplicates gum availability check
- `show_usage()` duplicates entire command list for gum vs non-gum
- `do_push()` has complex nested gum conditionals
- No centralized gum wrapper functions

### 3. **Repeated Submodule Logic**

- `cmd_sub_status()` and `cmd_sub_commit()` both implement identical submodule path detection
- Both use same `git submodule status | awk '{print $2}'` pattern
- Both implement same change detection logic with `git status --porcelain | grep`

### 4. **Inconsistent Error Handling & Output**

- Mixed usage of `echo -e "${YELLOW}→${NC}"` vs `log_info()`
- Some functions return 1 on error, others just return
- `cmd_sync()` uses direct echo, while others use log helpers
- No standardized exit codes or error reporting

### 5. **Complex Nested Logic**

- `cmd_test()` has 7 different test blocks with repeated pattern
- `do_push()` has 3 levels of nested if/else for gum handling
- `cmd_status()` defines a function inside a function
- Hard to follow control flow and test individual pieces

## Simplification Strategy

### Priority 1: Extract Gum Wrapper Functions

**Impact**: Eliminate 35+ lines of duplicated gum logic

```bash
# Single implementation instead of 5 duplicated functions
ui_style() { local color="$1"; shift; gum_or_echo "$color" "$@"; }
ui_spin() { local title="$1"; shift; gum_or_spin "$title" "$@"; }
ui_confirm() { gum_or_prompt "$1"; }
```

### Priority 2: Break Down Massive Functions

**Impact**: Reduce complexity, improve testability

#### `cmd_test()` → Multiple focused functions (157 → ~80 lines)

```bash
test_repository_structure() { ... }    # 10 lines
test_os_detection() { ... }           # 10 lines
test_symlink_creation() { ... }       # 10 lines
test_critical_symlinks() { ... }      # 15 lines
test_git_repository() { ... }         # 10 lines
test_shell_scripts() { ... }          # 25 lines
```

#### `show_usage()` → Single logic path (42 → ~15 lines)

```bash
show_usage() {
    ui_header "dots - Dotfiles management command"
    ui_text "Usage: dots <command> [options]"
    ui_section "Commands:"
    for cmd in "${COMMANDS[@]}"; do ui_command "$cmd"; done
}
```

### Priority 3: Extract Shared Submodule Logic

**Impact**: Eliminate duplicate code between sub-status and sub-commit

```bash
get_submodule_paths() { git submodule status 2>/dev/null | awk '{print $2}'; }
get_changed_submodules() { ... }      # Shared detection logic
```

### Priority 4: Standardize Output & Error Handling

**Impact**: Consistent behavior across all commands

```bash
# Single error handling pattern
handle_error() { ui_error "$1"; exit "${2:-1}"; }
# Single success pattern
handle_success() { ui_success "$1"; exit 0; }
```

## Recommended Approach: Incremental Simplification

**Keep single file** but apply focused refactoring:

1. ✅ Easier deployment and distribution
2. ✅ All functionality in one place
3. ✅ Dramatically reduced complexity
4. ✅ Improved maintainability without file management overhead

## Implementation Plan

### Phase 1: Extract Gum Wrapper Functions (1-2 hours)

**Target**: Reduce from 645 → ~580 lines

```bash
# Replace 5 log_* functions with single gum wrapper system
gum_or_echo() { ... }     # Centralized gum vs echo logic
ui_section() { ... }      # Replaces log_section
ui_success() { ... }      # Replaces log_success
ui_info() { ... }         # Replaces log_info
ui_warning() { ... }      # Replaces log_warning
ui_error() { ... }        # Replaces log_error
```

### Phase 2: Break Down Massive Functions (2-3 hours)

**Target**: Reduce from ~580 → ~450 lines

#### 2a. Simplify `cmd_test()` (157 → ~80 lines)

- Extract each test into focused function
- Create shared test runner pattern
- Standardize test output format

#### 2b. Simplify `show_usage()` (42 → ~15 lines)

- Use single logic path with gum wrappers
- Define commands array for easier maintenance

#### 2c. Simplify `do_push()` (46 → ~25 lines)

- Extract force push logic
- Use gum wrappers to reduce nesting

### Phase 3: Extract Shared Logic (1-2 hours)

**Target**: Reduce from ~450 → ~380 lines

#### 3a. Shared Submodule Functions

```bash
get_submodule_paths() { ... }      # Used by both sub-status and sub-commit
get_changed_submodules() { ... }   # Shared change detection
commit_submodules() { ... }        # Shared commit logic
```

#### 3b. Shared Git Utilities

```bash
ensure_git_repo() { ... }          # Used by multiple commands
get_git_status() { ... }           # Standardized status checking
```

### Phase 4: Standardize Error Handling (30 minutes)

**Target**: Improve consistency without significant line reduction

- Convert all functions to use consistent return codes
- Standardize error message format
- Add exit code constants

## Expected Results

### Line Count Reduction

- **Before**: 645 lines, 22 functions
- **After**: ~380 lines, ~25 focused functions
- **Reduction**: ~40% fewer lines, dramatically reduced complexity

### Specific Improvements

#### Functions Simplified

- `cmd_test()`: 157 → ~80 lines (50% reduction)
- `show_usage()`: 42 → ~15 lines (65% reduction)
- `do_push()`: 46 → ~25 lines (45% reduction)
- `log_*` functions: 35 → ~15 lines (60% reduction)

#### Code Quality Improvements

- ✅ **Zero duplication** of gum integration logic
- ✅ **Shared submodule utilities** eliminate repeated code
- ✅ **Consistent error handling** across all commands
- ✅ **Single responsibility** per function
- ✅ **Testable components** with clear inputs/outputs

### Benefits of Simplified Approach

1. **Maintainability**: Much easier to find and modify specific functionality
2. **Readability**: Functions have single clear purpose, easier to understand
3. **Consistency**: Standardized output and error handling patterns
4. **Extensibility**: Easy to add new commands using established patterns
5. **Debugging**: Smaller functions easier to debug and test
6. **Performance**: Reduced complexity means faster execution

## Success Criteria

- [ ] **40% line reduction** (645 → ~380 lines)
- [ ] **Zero gum logic duplication** (single wrapper system)
- [ ] **All functions under 50 lines** (current max: 157 lines)
- [ ] **Consistent error handling** (standardized exit codes)
- [ ] **All existing functionality preserved** (backward compatibility)
- [ ] **No performance regression** (same or better execution time)

## Timeline Estimate

- **Phase 1**: 1-2 hours (gum wrapper functions)
- **Phase 2**: 2-3 hours (break down massive functions)
- **Phase 3**: 1-2 hours (extract shared logic)
- **Phase 4**: 30 minutes (standardize error handling)
- **Testing & Validation**: 1 hour

**Total**: ~5-8 hours of focused development time

## Migration Strategy

1. **Incremental refactoring**: One function at a time
2. **Backward compatibility**: All existing commands work unchanged
3. **Immediate testing**: Validate each change before proceeding
4. **No functionality changes**: Pure simplification without feature changes
