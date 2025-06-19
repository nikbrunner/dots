# Testing Implementation Plan

This document outlines a comprehensive testing strategy for the dots repository, focusing on symlink functionality, backup operations, and installation verification.

## Overview

**Recommended Approach**: BATS (Bash Automated Testing System) with temporary directory isolation for fast, reliable testing without external dependencies.

**Why This Approach**:

- ✅ No Docker required (simple setup)
- ✅ Fast execution (~1-3 seconds per test)
- ✅ Complete isolation using temp directories
- ✅ Tests actual scripts without modification
- ✅ Easy CI/CD integration
- ✅ Excellent debugging capabilities

## Architecture

### Directory Structure

```
tests/
├── test_helper.bash              # Shared utilities and setup
├── setup_bats.sh                 # BATS installation script
├── fixtures/                     # Test configuration files
│   ├── common/
│   │   ├── .gitconfig
│   │   ├── .zshrc
│   │   └── .config/
│   │       └── tool/config
│   └── macos/
│       └── .config/
│           └── karabiner/config.json
├── unit/                         # Unit tests for individual functions
│   ├── test_symlink_creation.bats
│   ├── test_symlink_removal.bats
│   ├── test_backup_functionality.bats
│   ├── test_broken_link_detection.bats
│   └── test_os_detection.bats
├── integration/                  # End-to-end tests
│   ├── test_full_installation.bats
│   ├── test_dots_link_workflow.bats
│   └── test_submodule_integration.bats
└── performance/                  # Performance benchmarks
    └── test_large_repo.bats
```

## Core Testing Strategy

### Environment Isolation

Tests run in completely isolated temporary environments:

```bash
# tests/test_helper.bash
setup_test_environment() {
    # Create isolated test environment
    export BATS_TEST_TMPDIR="${BATS_TEST_TMPDIR:-$(mktemp -d)}"
    export TEST_HOME="$BATS_TEST_TMPDIR/home"
    export TEST_DOTS_DIR="$BATS_TEST_TMPDIR/dots"

    # Override environment for isolation
    export HOME="$TEST_HOME"
    export DOTS_DIR="$TEST_DOTS_DIR"

    # Create directory structure
    mkdir -p "$TEST_HOME"/{.config,bin}
    mkdir -p "$TEST_DOTS_DIR"/{common,macos,linux,scripts}

    # Copy test fixtures
    cp -r "$(dirname "$BATS_TEST_FILENAME")/fixtures"/* "$TEST_DOTS_DIR/"

    # Copy actual scripts to test
    cp "$ORIGINAL_DOTS_DIR/scripts"/* "$TEST_DOTS_DIR/scripts/"
    cp "$ORIGINAL_DOTS_DIR/common/bin/dots" "$TEST_DOTS_DIR/common/bin/"
}

cleanup_test_environment() {
    rm -rf "$BATS_TEST_TMPDIR"
}

# Setup and teardown for every test
setup() {
    export ORIGINAL_DOTS_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
    setup_test_environment
}

teardown() {
    cleanup_test_environment
}
```

## Test Categories

### 1. Unit Tests - Symlink Operations

#### test_symlink_creation.bats

```bash
#!/usr/bin/env bats

load '../test_helper'

@test "creates symlink correctly" {
    echo "test content" > "$TEST_DOTS_DIR/common/.testfile"

    run "$TEST_DOTS_DIR/scripts/link.sh"
    [ "$status" -eq 0 ]

    # Verify symlink exists and points correctly
    [ -L "$TEST_HOME/.testfile" ]
    [ "$(readlink "$TEST_HOME/.testfile")" = "$TEST_DOTS_DIR/common/.testfile" ]
    [ "$(cat "$TEST_HOME/.testfile")" = "test content" ]
}

@test "handles nested directory creation" {
    mkdir -p "$TEST_DOTS_DIR/common/.config/tool"
    echo "config" > "$TEST_DOTS_DIR/common/.config/tool/config"

    run "$TEST_DOTS_DIR/scripts/link.sh"
    [ "$status" -eq 0 ]

    [ -L "$TEST_HOME/.config/tool/config" ]
    [ -d "$TEST_HOME/.config/tool" ]
}

@test "skips broken symlinks in source" {
    ln -s "/nonexistent" "$TEST_DOTS_DIR/common/.broken"
    echo "good" > "$TEST_DOTS_DIR/common/.good"

    run "$TEST_DOTS_DIR/scripts/link.sh"
    [ "$status" -eq 0 ]

    [ ! -L "$TEST_HOME/.broken" ]
    [ -L "$TEST_HOME/.good" ]
}

@test "OS-specific symlinks work" {
    echo "mac config" > "$TEST_DOTS_DIR/macos/.mac-only"

    # Mock macOS detection
    export FORCE_OS="macos"

    run "$TEST_DOTS_DIR/scripts/link.sh"
    [ "$status" -eq 0 ]

    [ -L "$TEST_HOME/.mac-only" ]
    [ "$(cat "$TEST_HOME/.mac-only")" = "mac config" ]
}
```

#### test_backup_functionality.bats

```bash
@test "creates backup with timestamp" {
    echo "original" > "$TEST_HOME/.testfile"
    echo "new" > "$TEST_DOTS_DIR/common/.testfile"

    run "$TEST_DOTS_DIR/scripts/link.sh"
    [ "$status" -eq 0 ]

    # Verify backup was created
    backup_files=("$TEST_HOME"/.testfile.backup.*)
    [ ${#backup_files[@]} -eq 1 ]
    [ "$(cat "${backup_files[0]}")" = "original" ]

    # Verify new symlink exists
    [ -L "$TEST_HOME/.testfile" ]
    [ "$(cat "$TEST_HOME/.testfile")" = "new" ]
}

@test "--no-backup flag works" {
    echo "original" > "$TEST_HOME/.testfile"
    echo "new" > "$TEST_DOTS_DIR/common/.testfile"

    run "$TEST_DOTS_DIR/scripts/link.sh" --no-backup
    [ "$status" -eq 0 ]

    # Verify no backup was created
    backup_files=("$TEST_HOME"/.testfile.backup.*)
    [ "${backup_files[0]}" = "$TEST_HOME/.testfile.backup.*" ]  # glob didn't expand

    # Verify new symlink exists
    [ -L "$TEST_HOME/.testfile" ]
}

@test "backup preserves permissions" {
    echo "original" > "$TEST_HOME/.testfile"
    chmod 600 "$TEST_HOME/.testfile"
    echo "new" > "$TEST_DOTS_DIR/common/.testfile"

    run "$TEST_DOTS_DIR/scripts/link.sh"
    [ "$status" -eq 0 ]

    backup_files=("$TEST_HOME"/.testfile.backup.*)
    [ "$(stat -f "%Lp" "${backup_files[0]}")" = "600" ]  # macOS stat
}
```

#### test_broken_link_detection.bats

```bash
@test "removes broken symlinks" {
    # Create broken symlink
    ln -s "/nonexistent/file" "$TEST_HOME/.broken"
    echo "good" > "$TEST_DOTS_DIR/common/.good"

    run "$TEST_DOTS_DIR/scripts/link.sh"
    [ "$status" -eq 0 ]

    # Broken link should be removed
    [ ! -L "$TEST_HOME/.broken" ]
    [ ! -e "$TEST_HOME/.broken" ]

    # Good link should exist
    [ -L "$TEST_HOME/.good" ]
}

@test "handles symlinks pointing to moved files" {
    echo "content" > "$TEST_HOME/.realfile"
    ln -s "$TEST_HOME/.realfile" "$TEST_HOME/.link"
    rm "$TEST_HOME/.realfile"

    # Now .link is broken
    echo "new content" > "$TEST_DOTS_DIR/common/.link"

    run "$TEST_DOTS_DIR/scripts/link.sh"
    [ "$status" -eq 0 ]

    [ -L "$TEST_HOME/.link" ]
    [ "$(cat "$TEST_HOME/.link")" = "new content" ]
}
```

### 2. Integration Tests

#### test_full_installation.bats

```bash
@test "full installation workflow succeeds" {
    # Create a minimal but complete dots structure
    create_test_repository

    run "$TEST_DOTS_DIR/install.sh"
    [ "$status" -eq 0 ]

    # Verify key symlinks were created
    [ -L "$TEST_HOME/.zshrc" ]
    [ -L "$TEST_HOME/.gitconfig" ]
    [ -L "$TEST_HOME/bin/dots" ]

    # Verify dots command works
    [ -x "$TEST_HOME/bin/dots" ]
    run "$TEST_HOME/bin/dots" status
    [ "$status" -eq 0 ]
}

@test "install script handles existing files" {
    echo "existing zshrc" > "$TEST_HOME/.zshrc"
    create_test_repository

    run "$TEST_DOTS_DIR/install.sh"
    [ "$status" -eq 0 ]

    # Verify backup was created
    backup_files=("$TEST_HOME"/.zshrc.backup.*)
    [ ${#backup_files[@]} -eq 1 ]
    [ "$(cat "${backup_files[0]}")" = "existing zshrc" ]
}

@test "submodules are initialized during install" {
    create_test_repository_with_submodules

    run "$TEST_DOTS_DIR/install.sh"
    [ "$status" -eq 0 ]

    # Verify submodule was initialized (mock)
    [ -d "$TEST_DOTS_DIR/.git/modules" ]
}
```

#### test_dots_link_workflow.bats

```bash
@test "dots link --dry-run shows planned operations" {
    create_test_repository

    run "$TEST_HOME/bin/dots" link --dry-run
    [ "$status" -eq 0 ]

    # Should mention files that would be linked
    [[ "$output" =~ ".zshrc" ]]
    [[ "$output" =~ ".gitconfig" ]]
    [[ "$output" =~ "would create" ]]
}

@test "dots link --verbose shows detailed output" {
    create_test_repository

    run "$TEST_HOME/bin/dots" link --verbose
    [ "$status" -eq 0 ]

    # Should show detailed operations
    [[ "$output" =~ "Creating symlink" ]]
    [[ "$output" =~ ".zshrc" ]]
}

@test "dots status shows symlink health" {
    create_test_repository
    "$TEST_HOME/bin/dots" link

    run "$TEST_HOME/bin/dots" status
    [ "$status" -eq 0 ]

    [[ "$output" =~ "Valid links" ]]
    [[ "$output" =~ "Summary" ]]
}
```

### 3. Performance Tests

#### test_large_repo.bats

```bash
@test "handles large number of files efficiently" {
    # Create 1000 test files
    for i in {1..1000}; do
        mkdir -p "$TEST_DOTS_DIR/common/.config/tool$i"
        echo "config $i" > "$TEST_DOTS_DIR/common/.config/tool$i/config"
    done

    # Time the operation
    start_time=$(date +%s)
    run "$TEST_DOTS_DIR/scripts/link.sh"
    end_time=$(date +%s)

    [ "$status" -eq 0 ]

    # Should complete within reasonable time (< 10 seconds)
    duration=$((end_time - start_time))
    [ "$duration" -lt 10 ]

    # Verify all links were created
    link_count=$(find "$TEST_HOME/.config" -type l | wc -l)
    [ "$link_count" -eq 1000 ]
}
```

## Implementation Steps

### Phase 1: Setup and Basic Tests (2-3 hours)

1. **Install BATS framework**:

   ```bash
   # tests/setup_bats.sh
   #!/bin/bash
   set -e

   if ! command -v bats >/dev/null 2>&1; then
       if [[ "$OSTYPE" == "darwin"* ]]; then
           brew install bats-core
       else
           git clone https://github.com/bats-core/bats-core.git /tmp/bats
           cd /tmp/bats && sudo ./install.sh /usr/local
       fi
   fi

   echo "BATS installed successfully"
   bats --version
   ```

2. **Create test helper and fixtures**
3. **Implement basic symlink creation tests**
4. **Add backup functionality tests**

### Phase 2: Comprehensive Testing (3-4 hours)

1. **Add broken link detection tests**
2. **Implement OS-specific symlink tests**
3. **Create integration tests for full workflow**
4. **Add performance benchmarks**

### Phase 3: CI/CD Integration (1-2 hours)

1. **GitHub Actions workflow**:

   ```yaml
   # .github/workflows/test.yml
   name: Test Dotfiles
   on: [push, pull_request]

   jobs:
     test:
       runs-on: ${{ matrix.os }}
       strategy:
         matrix:
           os: [ubuntu-latest, macos-latest]

       steps:
         - uses: actions/checkout@v3
         - name: Setup BATS
           run: ./tests/setup_bats.sh
         - name: Run tests
           run: bats tests/ --tap
         - name: Performance tests
           run: bats tests/performance/ --tap
   ```

2. **Add test coverage reporting**
3. **Test failure notifications**

### Phase 4: Advanced Testing (Optional)

1. **Docker integration tests** for cross-platform verification
2. **Stress testing** with very large repositories
3. **Security testing** for permission handling
4. **Regression testing** suite

## Running Tests

### Local Development

```bash
# Install BATS
./tests/setup_bats.sh

# Run all tests
bats tests/

# Run specific test file
bats tests/unit/test_symlink_creation.bats

# Run with TAP output for CI
bats tests/ --tap

# Run with detailed output
bats tests/ --verbose-run
```

### Expected Output

```
✓ creates symlink correctly
✓ handles nested directory creation
✓ skips broken symlinks in source
✓ OS-specific symlinks work
✓ creates backup with timestamp
✓ --no-backup flag works
✓ removes broken symlinks
✓ full installation workflow succeeds

8 tests, 0 failures
```

## Benefits of This Approach

1. **Fast Execution**: Tests run in 1-3 seconds total
2. **Complete Isolation**: No risk to actual dotfiles
3. **Comprehensive Coverage**: Tests all major functionality
4. **Easy Debugging**: Can inspect temp directories when tests fail
5. **CI/CD Ready**: TAP output works with all major CI systems
6. **No Dependencies**: Works on any system with bash
7. **Maintainable**: Clear test structure and helpers
8. **Extensible**: Easy to add new test cases

## Success Metrics

- ✅ **95%+ test coverage** of symlink operations
- ✅ **Sub-10 second** total test execution time
- ✅ **Zero false positives** in CI/CD pipeline
- ✅ **Cross-platform compatibility** (macOS + Linux)
- ✅ **Comprehensive error handling** validation
- ✅ **Performance regression detection**

This testing implementation provides robust validation of your dotfiles system without requiring Docker or complex infrastructure, while maintaining fast execution and comprehensive coverage.
