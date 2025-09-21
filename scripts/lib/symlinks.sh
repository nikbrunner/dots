#!/usr/bin/env bash
# Shared library for symlink operations
# Can be used as both a library (sourced) and standalone script

# Colors disabled for compatibility
RED=''
GREEN=''
YELLOW=''
NC='' # No Color

# Global manifest tracking
MANIFEST_DATA=""
MANIFEST_FILE=""

# Initialize manifest tracking
init_manifest() {
    local dots_dir="$1"
    local os="${2:-unknown}"
    MANIFEST_FILE="$dots_dir/.dots-manifest.$os.json"
    MANIFEST_DATA="{}"
}

# Add symlink to manifest
add_to_manifest() {
    local symlink="$1"
    local target="$2"

    # Convert absolute paths to ~/... format for cross-platform compatibility
    local tilde_symlink="${symlink/$HOME/\~}"
    local tilde_target="${target/$HOME/\~}"

    local escaped_symlink=$(printf '%s\n' "$tilde_symlink" | sed 's/[[\.*^$(){}?+|]/\\&/g')
    local escaped_target=$(printf '%s\n' "$tilde_target" | sed 's/[[\.*^$(){}?+|]/\\&/g')

    # Use jq if available, otherwise build JSON manually
    if command -v jq &> /dev/null; then
        MANIFEST_DATA=$(echo "$MANIFEST_DATA" | jq --arg link "$tilde_symlink" --arg target "$tilde_target" '. + {($link): $target}')
    else
        # Simple JSON building (not ideal for complex strings but should work for paths)
        if [[ "$MANIFEST_DATA" == "{}" ]]; then
            MANIFEST_DATA="{\"$tilde_symlink\":\"$tilde_target\"}"
        else
            MANIFEST_DATA="${MANIFEST_DATA%}},\"$tilde_symlink\":\"$tilde_target\"}"
        fi
    fi
}

# Save manifest to file
save_manifest() {
    if [[ -n "$MANIFEST_FILE" ]] && [[ -n "$MANIFEST_DATA" ]]; then
        # Sort keys to prevent unnecessary diffs
        if command -v jq &> /dev/null; then
            echo "$MANIFEST_DATA" | jq --sort-keys '.' > "$MANIFEST_FILE"
        else
            echo "$MANIFEST_DATA" > "$MANIFEST_FILE"
        fi
    fi
}

# Function to process files and check/create symlinks
# Usage: process_symlinks <source_dir> <target_base> <mode> [options...]
# Modes: "check" (status only), "create" (create/update symlinks)
# Options: --dry-run, --no-backup, --verbose
process_symlinks() {
    local source_dir="$1"
    local target_base="$2"
    local mode="$3"
    shift 3
    
    # Parse options
    local dry_run=false
    local no_backup=false
    local verbose=false
    local debug=false
    
    for arg in "$@"; do
        case $arg in
        --dry-run)
            dry_run=true
            ;;
        --no-backup)
            no_backup=true
            ;;
        --verbose)
            verbose=true
            ;;
        --debug)
            debug=true
            verbose=true
            ;;
        esac
    done
    
    # Initialize counters
    local total_links=0
    local valid_links=0
    local broken_links=0
    local missing_links=0
    local wrong_target_links=0
    local created_links=0
    local updated_links=0
    local replaced_links=0
    
    [[ ! -d "$source_dir" ]] && return
    
    # Find all files and symlinks recursively
    [[ "$debug" == true ]] && echo "[DEBUG] Processing directory: $source_dir"
    [[ "$debug" == true ]] && echo "[DEBUG] Starting file processing loop..."
    
    # Simple approach: use find with proper quoting
    local temp_file
    temp_file=$(mktemp)
    [[ "$debug" == true ]] && echo "[DEBUG] About to run find command"
    if ! find "$source_dir" \( -type f -o -type l \) -print0 2>/dev/null > "$temp_file"; then
        echo "ERROR: Find command failed"
        rm -f "$temp_file"
        return 1
    fi
    [[ "$debug" == true ]] && echo "[DEBUG] Find command completed"
    
    # Count files for debugging
    [[ "$debug" == true ]] && echo "[DEBUG] About to count files"
    local total_count
    total_count=$(tr '\0' '\n' < "$temp_file" | wc -l)
    [[ "$debug" == true ]] && echo "[DEBUG] Found $total_count files to process"
    
    # Read null-terminated entries one by one
    [[ "$debug" == true ]] && echo "[DEBUG] Starting while loop"
    # Keep set -e but add proper error handling for individual commands
    while IFS= read -r -d '' file; do
        [[ "$debug" == true ]] && echo "[DEBUG] Processing file: $file"
        
        # Skip if file doesn't exist (this might be failing)
        if [[ ! -e "$file" ]]; then
            [[ "$debug" == true ]] && echo "[DEBUG] File doesn't exist, skipping: $file"
            continue
        fi
        
        # Calculate relative path and target
        local rel_path="${file#"$source_dir"/}"
        local target="$target_base/$rel_path"
        [[ "$debug" == true ]] && echo "[DEBUG] Target would be: $target"
        
        [[ "$debug" == true ]] && echo "[DEBUG] About to increment total_links (currently: $total_links)"
        total_links=$((total_links + 1))
        [[ "$debug" == true ]] && echo "[DEBUG] total_links now: $total_links"
        
        [[ "$debug" == true ]] && echo "[DEBUG] Mode is: '$mode'"
        if [[ "$mode" == "check" ]]; then
            [[ "$debug" == true ]] && echo "[DEBUG] In check mode"
            # Check mode - only report status
            if [[ -L "$target" ]]; then
                # It's a symlink, check if it's valid
                local actual_target
                actual_target=$(readlink "$target" 2>/dev/null)
                if [[ "$actual_target" == "$file" ]]; then
                    valid_links=$((valid_links + 1))
                else
                    wrong_target_links=$((wrong_target_links + 1))
                    echo "⚠ Wrong target: $target → $actual_target"
                    echo "    Expected: $file"
                fi
                
                # Check if target exists
                if [[ ! -e "$target" ]]; then
                    broken_links=$((broken_links + 1))
                    echo "✗ Broken link: $target"
                fi
            elif [[ -e "$target" ]]; then
                # File/directory exists but is not a symlink
                echo "✗ Not a symlink: $target"
                echo "    Run 'dots link' to fix"
            else
                # Neither symlink nor file exists
                missing_links=$((missing_links + 1))
                if [[ "$verbose" == true ]]; then
                    echo "⚠ Missing link: $target"
                fi
            fi
        elif [[ "$mode" == "create" ]]; then
            [[ "$debug" == true ]] && echo "[DEBUG] In create mode"
            # Create mode - create/update symlinks
            if [[ "$dry_run" == true ]]; then
                [[ "$debug" == true ]] && echo "[DEBUG] In dry run mode"
                # Dry run mode - just show what would happen
                [[ "$debug" == true ]] && echo "[DEBUG] Checking if target is symlink: $target"
                if [[ -L "$target" ]]; then
                    [[ "$debug" == true ]] && echo "[DEBUG] Target is a symlink, reading link"
                    local actual_target
                    if ! actual_target=$(readlink "$target"); then
                        [[ "$debug" == true ]] && echo "[DEBUG] readlink failed for $target"
                        continue
                    fi
                    [[ "$debug" == true ]] && echo "[DEBUG] actual_target=$actual_target"
                    [[ "$debug" == true ]] && echo "[DEBUG] Comparing '$actual_target' == '$file'"
                    if [[ "$actual_target" == "$file" ]]; then
                        [[ "$debug" == true ]] && echo "[DEBUG] Match! Incrementing valid_links"
                        valid_links=$((valid_links + 1))
                        [[ "$verbose" == true ]] && echo "✓ [DRY] Symlink OK: $target → $file"
                        # Add to manifest (even in dry-run, to show what would be tracked)
                        add_to_manifest "$target" "$file"
                    else
                        [[ "$debug" == true ]] && echo "[DEBUG] No match. Incrementing wrong_target_links"
                        wrong_target_links=$((wrong_target_links + 1))
                        [[ "$verbose" == true ]] && echo "⚠ [DRY] Wrong target: $target → $actual_target (expected: $file)"
                    fi
                elif [[ -e "$target" ]]; then
                    if [[ "$verbose" == true ]]; then
                        echo "⚠ [DRY] File exists (not symlink): $target"
                        if [[ "$no_backup" == true ]]; then
                            echo "⚠ [DRY] Would replace file with symlink"
                        else
                            echo "⚠ [DRY] Would backup and replace with symlink"
                        fi
                    fi
                    replaced_links=$((replaced_links + 1))
                else
                    created_links=$((created_links + 1))
                    [[ "$verbose" == true ]] && echo "+ [DRY] Would create symlink: $target → $file"
                    # Add to manifest (even in dry-run, to show what would be tracked)
                    add_to_manifest "$target" "$file"
                fi
            else
                # Create parent directory if it doesn't exist
                mkdir -p "$(dirname "$target")"
                
                if [[ -L "$target" ]]; then
                    # Target is a symlink
                    local actual_target
                    actual_target=$(readlink "$target" 2>/dev/null)
                    if [[ "$actual_target" == "$file" ]]; then
                        valid_links=$((valid_links + 1))
                        [[ "$verbose" == true ]] && echo "✓ Symlink OK: $target"
                        # Add to manifest
                        add_to_manifest "$target" "$file"
                    else
                        updated_links=$((updated_links + 1))
                        [[ "$verbose" == true ]] && echo "⚠ Updating symlink: $target"
                        rm "$target"
                        ln -s "$file" "$target"
                        [[ "$verbose" == true ]] && echo "✓ Updated symlink: $target"
                        # Add to manifest
                        add_to_manifest "$target" "$file"
                    fi
                elif [[ -e "$target" ]]; then
                    # Target exists but is not a symlink
                    replaced_links=$((replaced_links + 1))
                    if [[ "$no_backup" == true ]]; then
                        [[ "$verbose" == true ]] && echo "⚠ Replacing file with symlink: $target"
                        rm -f "$target"
                    else
                        [[ "$verbose" == true ]] && echo "⚠ Backing up existing file: $target"
                        mv "$target" "$target.backup.$(date +%Y%m%d_%H%M%S)"
                    fi
                    ln -s "$file" "$target"
                    [[ "$verbose" == true ]] && echo "✓ Created symlink: $target"
                    # Add to manifest
                    add_to_manifest "$target" "$file"
                else
                    # Target doesn't exist
                    created_links=$((created_links + 1))
                    ln -s "$file" "$target"
                    [[ "$verbose" == true ]] && echo "✓ Created symlink: $target"
                    # Add to manifest
                    add_to_manifest "$target" "$file"
                fi
            fi
        fi
    done < "$temp_file"
    
    rm -f "$temp_file"
    
    # Return stats via global variables
    STATS_TOTAL=$total_links
    STATS_VALID=$valid_links
    STATS_BROKEN=$broken_links
    STATS_MISSING=$missing_links
    STATS_WRONG_TARGET=$wrong_target_links
    STATS_CREATED=$created_links
    STATS_UPDATED=$updated_links
    STATS_REPLACED=$replaced_links
}

# Function to clean up broken symlinks using manifest
# Usage: cleanup_broken_symlinks <dots_dir> <dry_run> <verbose> <os>
cleanup_broken_symlinks() {
    local dots_dir="$1"
    local dry_run="${2:-false}"
    local verbose="${3:-false}"
    local os="${4:-unknown}"

    local broken_count=0
    local manifest_file="$dots_dir/.dots-manifest.$os.json"
    
    # Check if manifest exists
    if [[ ! -f "$manifest_file" ]]; then
        [[ "$verbose" == true ]] && echo "  No manifest file found, skipping cleanup"
        CLEANUP_BROKEN_COUNT=0
        return
    fi
    
    # Read manifest and check each symlink
    local temp_manifest
    temp_manifest=$(mktemp)
    
    # Use jq if available, otherwise use python
    if command -v jq &> /dev/null; then
        jq -r 'to_entries | .[] | "\(.key)|\(.value)"' "$manifest_file" > "$temp_manifest"
    elif command -v python3 &> /dev/null; then
        python3 -c "
import json
with open('$manifest_file') as f:
    data = json.load(f)
    for link, target in data.items():
        print(f'{link}|{target}')
" > "$temp_manifest"
    else
        echo "Warning: Neither jq nor python3 found. Cannot read manifest."
        CLEANUP_BROKEN_COUNT=0
        return
    fi
    
    # Check each symlink in manifest
    while IFS='|' read -r symlink target; do
        # Convert tilde paths back to absolute paths
        local abs_symlink="${symlink/\~/$HOME}"
        local abs_target="${target/\~/$HOME}"

        if [[ -L "$abs_symlink" ]]; then
            # Check if symlink points to expected target and target exists
            local actual_target
            actual_target=$(readlink "$abs_symlink" 2>/dev/null)

            if [[ "$actual_target" != "$abs_target" ]] || [[ ! -e "$abs_target" ]]; then
                # Symlink is broken or points to wrong target
                if [[ "$dry_run" == true ]]; then
                    if [[ ! -e "$abs_target" ]]; then
                        [[ "$verbose" == true ]] && echo "✗ [DRY] Would remove orphaned symlink: $abs_symlink"
                    else
                        [[ "$verbose" == true ]] && echo "✗ [DRY] Would remove wrong symlink: $abs_symlink"
                    fi
                else
                    if [[ ! -e "$abs_target" ]]; then
                        [[ "$verbose" == true ]] && echo "✗ Removing orphaned symlink: $abs_symlink"
                    else
                        [[ "$verbose" == true ]] && echo "✗ Removing wrong symlink: $abs_symlink"
                    fi
                    rm "$abs_symlink"
                fi
                broken_count=$((broken_count + 1))
            fi
        elif [[ -e "$abs_symlink" ]]; then
            # File exists but is not a symlink (user might have replaced it)
            [[ "$verbose" == true ]] && echo "⚠ Not a symlink (in manifest): $abs_symlink"
        fi
    done < "$temp_manifest"
    
    rm -f "$temp_manifest"
    
    # Return count via global variable
    CLEANUP_BROKEN_COUNT=$broken_count
}

# If script is executed directly (not sourced), run as standalone status checker
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Get the script directory
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    DOTS_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

    # Source OS detection
    # shellcheck disable=SC1091
    source "$(dirname "$SCRIPT_DIR")/detect-os.sh"

    # Get current OS
    CURRENT_OS=$(get_os)

    # Parse options
    VERBOSE=false
    for arg in "$@"; do
        case $arg in
        --verbose)
            VERBOSE=true
            ;;
        esac
    done

    # Variables to accumulate totals
    total_links=0
    valid_links=0
    broken_links=0
    missing_links=0
    wrong_target_links=0

    # Check common files
    if [[ "$VERBOSE" = true ]]; then
        process_symlinks "$DOTS_DIR/common" "$HOME" "check" --verbose
    else
        process_symlinks "$DOTS_DIR/common" "$HOME" "check"
    fi
    ((total_links += STATS_TOTAL))
    ((valid_links += STATS_VALID))
    ((broken_links += STATS_BROKEN))
    ((missing_links += STATS_MISSING))
    ((wrong_target_links += STATS_WRONG_TARGET))

    # Check OS-specific files
    if [[ "$CURRENT_OS" == "macos" && -d "$DOTS_DIR/macos" ]]; then
        if [[ "$VERBOSE" = true ]]; then
            process_symlinks "$DOTS_DIR/macos" "$HOME" "check" --verbose
        else
            process_symlinks "$DOTS_DIR/macos" "$HOME" "check"
        fi
        ((total_links += STATS_TOTAL))
        ((valid_links += STATS_VALID))
        ((broken_links += STATS_BROKEN))
        ((missing_links += STATS_MISSING))
        ((wrong_target_links += STATS_WRONG_TARGET))
    elif [[ "$CURRENT_OS" == "linux" && -d "$DOTS_DIR/linux" ]]; then
        if [[ "$VERBOSE" = true ]]; then
            process_symlinks "$DOTS_DIR/linux" "$HOME" "check" --verbose
        else
            process_symlinks "$DOTS_DIR/linux" "$HOME" "check"
        fi
        ((total_links += STATS_TOTAL))
        ((valid_links += STATS_VALID))
        ((broken_links += STATS_BROKEN))
        ((missing_links += STATS_MISSING))
        ((wrong_target_links += STATS_WRONG_TARGET))
    elif [[ "$CURRENT_OS" == "arch" && -d "$DOTS_DIR/arch" ]]; then
        if [[ "$VERBOSE" = true ]]; then
            process_symlinks "$DOTS_DIR/arch" "$HOME" "check" --verbose
        else
            process_symlinks "$DOTS_DIR/arch" "$HOME" "check"
        fi
        ((total_links += STATS_TOTAL))
        ((valid_links += STATS_VALID))
        ((broken_links += STATS_BROKEN))
        ((missing_links += STATS_MISSING))
        ((wrong_target_links += STATS_WRONG_TARGET))
    fi

    # Output stats in a parseable format
    echo "STATS:$total_links:$valid_links:$broken_links:$missing_links:$wrong_target_links"
fi