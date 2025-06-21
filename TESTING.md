# Testing Guide for Dots Repository

This document provides comprehensive testing procedures for the dots repository functionality.

## Testing the `repos` Command

### Prerequisites

Before testing, ensure you have the required dependencies installed:

```bash
repos install  # Guides you through dependency installation
```

### Basic Functionality Tests

#### 1. Help and Information

```bash
# Test help command
repos help
repos --help
repos -h

# Test with no arguments
repos

# Test with invalid command
repos invalid-command
```

#### 2. Repository Addition

```bash
# Test valid repository URLs
repos add https://github.com/charmbracelet/gum.git
repos add git@github.com:username/repo.git

# Test invalid inputs
repos add                    # No URL provided
repos add "not-a-url"       # Invalid URL format
repos add ""                # Empty string
```

#### 3. Repository Management

```bash
# Test repository listing and status
repos status                # Should show git status for all repos

# Test interactive commands (requires existing repos)
repos remove               # Interactive repo selection for removal
repos open                 # Interactive repo selection for tmux
```

#### 4. Bulk Setup

```bash
# Test setup command (uses ENSURE_CLONED array)
repos setup

# Test with custom parallel jobs
PARALLEL_JOBS=2 repos setup
PARALLEL_JOBS=8 repos setup
```

### Environment Variable Tests

#### Base Path Override

```bash
# Test custom repository base path
REPOS_BASE_PATH=/tmp/test-repos repos add https://github.com/charmbracelet/gum.git
REPOS_BASE_PATH=/tmp/test-repos repos status
REPOS_BASE_PATH=/tmp/test-repos repos remove
```

#### Parallel Jobs Configuration

```bash
# Test different parallelism levels
PARALLEL_JOBS=1 repos setup   # Sequential
PARALLEL_JOBS=4 repos setup   # Default
PARALLEL_JOBS=10 repos setup  # High parallelism
```

### Error Condition Tests

#### Missing Dependencies

Test behavior when dependencies are missing:

1. Temporarily rename/remove `git`, `fzf`, or `tmux`
2. Run `repos` commands
3. Verify proper error messages and graceful failure

#### Permission Errors

```bash
# Test with read-only directory
sudo mkdir /root/test-repos
sudo chmod 000 /root/test-repos
REPOS_BASE_PATH=/root/test-repos repos add https://github.com/user/repo.git
```

#### Network Issues

```bash
# Test with invalid repository URLs
repos add https://github.com/nonexistent/repo.git
repos add git@github.com:invalid/repository.git

# Test GitHub CLI integration (requires gh auth)
# Edit ENSURE_CLONED to include: "git@github.com:nonexistent-org/*"
repos setup
```

### User Experience Tests

#### With Gum (Enhanced UX)

If `gum` is installed, verify:

- Spinner animations during long operations
- Interactive confirmations for deletions
- Fuzzy filtering for repository selection

#### Without Gum (Fallback)

Temporarily remove/rename `gum` and verify:

- Plain text prompts work correctly
- fzf is used for selections
- No broken functionality

### GitHub CLI Integration Tests

#### Setup

```bash
# Ensure GitHub CLI is installed and authenticated
gh auth status
gh auth login  # If not authenticated
```

#### Wildcard Pattern Tests

Edit the `ENSURE_CLONED` array in the script to test:

```bash
# Individual repositories
"git@github.com:charmbracelet/gum.git"

# Organization wildcards (be careful - this clones ALL repos!)
"git@github.com:charmbracelet/*"  # Small org for testing

# Mixed patterns
"git@github.com:user/specific-repo.git"
"git@github.com:small-org/*"
```

Then run:

```bash
repos setup
```

### Performance Tests

#### Large Repository Sets

1. Configure `ENSURE_CLONED` with multiple repositories
2. Test different `PARALLEL_JOBS` values
3. Monitor system resources during `repos setup`

#### Repository Status Checking

```bash
# Test with many repositories
repos status

# Measure performance with large repo sets
time repos status
```

### Integration Tests

#### Tmux Integration

```bash
# Test tmux session management
repos open  # Select a repository
# Verify tmux session is created/switched correctly
tmux list-sessions  # Should show repo-based session names

# Test session cleanup during removal
repos remove  # Remove a repo with active tmux session
tmux list-sessions  # Verify session was killed
```

#### Git Repository Detection

Create test scenarios:

```bash
# Create non-git directory in repos path
mkdir -p ~/repos/test-user/not-a-repo
echo "test" > ~/repos/test-user/not-a-repo/file.txt

# Run status command
repos status  # Should warn about non-git repository
```

### Edge Case Tests

#### Special Characters in Repository Names

```bash
# Test repositories with special characters (if they exist)
repos add "git@github.com:user/repo-with-dashes.git"
repos add "https://github.com/user/repo_with_underscores.git"
```

#### Concurrent Operations

```bash
# Run multiple repos commands simultaneously
repos setup &
repos status &
wait
```

#### Interrupted Operations

1. Start a long-running operation (`repos setup` with many repos)
2. Interrupt with Ctrl+C
3. Verify system is left in a clean state
4. Verify partial operations can be resumed

### Cleanup

After testing, clean up test repositories:

```bash
# Remove test repositories
rm -rf /tmp/test-repos
rm -rf ~/repos/test-*  # Remove any test repos created
```

## Testing Other Dots Commands

### Core Commands

```bash
# Test status and linking
dots status
dots link --dry-run
dots link --verbose

# Test git operations
dots commit  # Opens LazyGit
dots push
dots sync
```

### Submodule Commands

```bash
dots sub-status
dots sub-commit
```

### System Testing

```bash
# Run comprehensive system tests
dots test
```

### Format Command

```bash
# Test file formatting
dots format --check
dots format
```

## Continuous Testing

### Pre-commit Testing

Before committing changes to the dots repository:

1. Run `dots test` to ensure system integrity
2. Test any modified commands
3. Verify shellcheck passes for all scripts

### Regular Maintenance Testing

Periodically test:

1. All repository links are valid (`dots status`)
2. All dependencies are still available
3. GitHub CLI authentication is current
4. All scripts pass shellcheck

## Reporting Issues

When reporting issues:

1. Include the full command that failed
2. Include error messages and output
3. Specify your environment (OS, shell, dependency versions)
4. Include relevant sections from `dots test` output

## Test Environment Setup

For isolated testing, consider:

```bash
# Create test environment
export DOTS_DIR=/tmp/dots-test
export REPOS_BASE_PATH=/tmp/repos-test
git clone /path/to/your/dots /tmp/dots-test
cd /tmp/dots-test
```

This allows testing without affecting your main dots configuration.
