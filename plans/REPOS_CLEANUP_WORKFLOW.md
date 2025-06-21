# Repository Cleanup Workflow Implementation Plan

## Overview

Implementation plan for adding an interactive cleanup workflow to the `repos` command to efficiently manage repositories with pending changes, grouped by owner for logical organization.

## Current Problem

Running `repos status` reveals **21+ repositories** with various types of changes:
- **Modified files** (M) - Need commits or stashing
- **Untracked files** (??) - Need adding or ignoring  
- **Deleted files** (D) - Need committing removals
- **Non-git directories** - Need conversion or removal
- **Mixed owners** - Changes across black-atom-industries, nikbrunner, dealercenter-digital, etc.

**Pain Points:**
- Overwhelming list to process manually
- Related repositories (same owner) often need similar actions
- No efficient bulk operations
- Difficulty tracking progress through cleanup

## Solution Design

### 1. Enhanced `repos status` Command

**Owner-Grouped Display:**
```bash
=== black-atom-industries ===
⚠ .claude is not a git repository
adapter-template (1 change)
 M README.md
ghostty (1 change) 
 M themes/north/black-atom-north-day.conf
# ... more repos

=== nikbrunner ===
dots (1 change)
 M common/bin/repos
# ... more repos

=== Clean Repositories ===
black-atom-industries: 3 repositories
nikbrunner: 12 repositories

=== Summary ===
Total repositories: 37
Repositories with changes: 21
Non-git directories: 1
💡 Run 'repos cleanup' to interactively clean up repositories
```

**New Features:**
- `repos status --clean` - Show only repositories that need attention
- Owner-based grouping for logical organization
- Summary statistics and cleanup suggestion

### 2. Interactive `repos cleanup` Command

**Owner-by-Owner Workflow:**

1. **Analyze Phase:**
   - Scan all repositories
   - Group by owner (black-atom-industries, nikbrunner, etc.)
   - Identify dirty repos and non-git directories

2. **Processing Phase:**
   - Process one owner group at a time
   - Show progress: "Owner 2/5: nikbrunner (8 repos)"
   - Present owner-level actions via fzf

3. **Action Options:**

   **Owner-Level Actions:**
   - **Commit All** - Commit all changes across owner's repositories
   - **Stash All** - Stash all changes for later review
   - **Review Individual** - Go through each repository one by one
   - **Reset All** - Discard all changes (dangerous, with confirmation)
   - **Skip Owner** - Move to next owner group

   **Individual Repository Actions:**
   - **Commit** - Commit changes with auto-generated message
   - **Stash** - Stash changes with timestamp
   - **Reset** - Discard changes (with confirmation)
   - **View in Editor** - Open repository in $EDITOR for manual review
   - **Skip** - Move to next repository

4. **Special Handling:**
   - **Non-git directories**: Convert to git, remove, or skip
   - **Progress tracking**: Show completed vs remaining
   - **Final summary**: Actions taken across all owners

## Implementation Steps

### Phase 1: Enhanced Status Command
- [ ] Rewrite `status_repos()` function with owner grouping
- [ ] Add `--clean` flag support
- [ ] Implement summary statistics
- [ ] Add cleanup suggestion message

### Phase 2: Core Cleanup Command
- [ ] Add `cleanup_repos()` main function
- [ ] Implement owner analysis and grouping
- [ ] Add fzf-based action selection
- [ ] Create progress tracking system

### Phase 3: Helper Functions
- [ ] `cleanup_commit_all_for_owner()` - Bulk commit functionality
- [ ] `cleanup_stash_all_for_owner()` - Bulk stash functionality  
- [ ] `cleanup_reset_all_for_owner()` - Bulk reset with confirmation
- [ ] `cleanup_review_individual()` - Individual repository handler

### Phase 4: Integration
- [ ] Add `cleanup` command to main command handler
- [ ] Update `show_help()` with new commands
- [ ] Add examples to help text
- [ ] Update status command to accept parameters

### Phase 5: Testing & Refinement
- [ ] Test with current dirty repository state
- [ ] Verify cross-platform compatibility
- [ ] Test all action combinations
- [ ] Validate error handling and edge cases

## Technical Implementation Details

### Data Structures (Bash 5.2+)
```bash
# Using associative arrays for efficient grouping
declare -A owner_dirty_repos
declare -A owner_non_git_repos
declare -A owner_clean_repos
```

### fzf Integration
- Consistent styling with existing `styled_fzf()` wrapper
- Owner selection and repository selection interfaces
- Action selection with descriptive prompts

### Error Handling
- Graceful fallback for missing dependencies
- Confirmation prompts for destructive actions
- Clear error messages and recovery suggestions

### Progress Tracking
- Owner progress: "Processing 2/5: nikbrunner"
- Repository progress within owner groups
- Final summary of all actions taken

## Expected User Experience

```bash
$ repos cleanup
Analyzing repositories for cleanup...

Found 21 repositories with changes
Found 1 non-git directories

=== [1/5] Processing: black-atom-industries ===
Repositories with changes: 5
Non-git directories: 1

Non-git directories:
  • .claude

Repositories with changes:
  • adapter-template (1 changes)
  • ghostty (1 changes)  
  • nvim (4 changes)
  • obsidian (1 changes)
  • zed (3 changes)

Choose action for black-atom-industries:
> Commit All
  Stash All
  Review Individual
  Reset All  
  Skip Owner
```

## Benefits

1. **Efficient Workflow**: Process 21+ repositories systematically instead of manually
2. **Logical Grouping**: Handle related repositories (same owner) together
3. **Flexible Actions**: Choose between bulk operations and individual review
4. **Progress Tracking**: Clear visibility into cleanup progress
5. **Safety Features**: Confirmations for destructive actions
6. **Consistent UX**: Integrates seamlessly with existing repos command patterns

## Dependencies

- **Bash 5.2+**: For associative arrays (requires bash standardization)
- **fzf**: For interactive selection (already required)
- **git**: For repository operations (already required)
- **gum** (optional): Enhanced confirmations and spinners

## Future Enhancements

1. **Smart Commit Messages**: Use AI to generate contextual commit messages
2. **Owner-Specific Rules**: Configure default actions per owner pattern
3. **Batch Processing**: Process multiple owners with same action
4. **Cleanup Profiles**: Save and reuse cleanup preferences
5. **Integration**: Connect with external tools (smart-commit, etc.)

## Related Documentation

- [BASH_STANDARDIZATION.md](BASH_STANDARDIZATION.md) - Required for associative arrays
- [TESTING.md](../TESTING.md) - Testing procedures for cleanup workflow
- [README.md](../README.md) - Main documentation with usage examples