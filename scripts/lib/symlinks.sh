#!/usr/bin/env bash
# Shared library for symlink operations
# Can be used as both a library (sourced) and standalone script

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

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
                    echo -e "${YELLOW}⚠${NC} Wrong target: $target → $actual_target"
                    echo "    Expected: $file"
                fi
                
                # Check if target exists
                if [[ ! -e "$target" ]]; then
                    broken_links=$((broken_links + 1))
                    echo -e "${RED}✗${NC} Broken link: $target"
                fi
            elif [[ -e "$target" ]]; then
                # File/directory exists but is not a symlink
                echo -e "${RED}✗${NC} Not a symlink: $target"
                echo "    Run 'dots link' to fix"
            else
                # Neither symlink nor file exists
                missing_links=$((missing_links + 1))
                if [[ "$verbose" == true ]]; then
                    echo -e "${YELLOW}⚠${NC} Missing link: $target"
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
                        [[ "$verbose" == true ]] && echo -e "${GREEN}✓${NC} [DRY] Symlink OK: $target → $file"
                    else
                        [[ "$debug" == true ]] && echo "[DEBUG] No match. Incrementing wrong_target_links"
                        wrong_target_links=$((wrong_target_links + 1))
                        [[ "$verbose" == true ]] && echo -e "${YELLOW}⚠${NC} [DRY] Wrong target: $target → $actual_target (expected: $file)"
                    fi
                elif [[ -e "$target" ]]; then
                    if [[ "$verbose" == true ]]; then
                        echo -e "${YELLOW}⚠${NC} [DRY] File exists (not symlink): $target"
                        if [[ "$no_backup" == true ]]; then
                            echo -e "${YELLOW}⚠${NC} [DRY] Would replace file with symlink"
                        else
                            echo -e "${YELLOW}⚠${NC} [DRY] Would backup and replace with symlink"
                        fi
                    fi
                    replaced_links=$((replaced_links + 1))
                else
                    created_links=$((created_links + 1))
                    [[ "$verbose" == true ]] && echo -e "${GREEN}+${NC} [DRY] Would create symlink: $target → $file"
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
                        [[ "$verbose" == true ]] && echo -e "${GREEN}✓${NC} Symlink OK: $target"
                    else
                        updated_links=$((updated_links + 1))
                        [[ "$verbose" == true ]] && echo -e "${YELLOW}⚠${NC} Updating symlink: $target"
                        rm "$target"
                        ln -s "$file" "$target"
                        [[ "$verbose" == true ]] && echo -e "${GREEN}✓${NC} Updated symlink: $target"
                    fi
                elif [[ -e "$target" ]]; then
                    # Target exists but is not a symlink
                    replaced_links=$((replaced_links + 1))
                    if [[ "$no_backup" == true ]]; then
                        [[ "$verbose" == true ]] && echo -e "${YELLOW}⚠${NC} Replacing file with symlink: $target"
                        rm -f "$target"
                    else
                        [[ "$verbose" == true ]] && echo -e "${YELLOW}⚠${NC} Backing up existing file: $target"
                        mv "$target" "$target.backup.$(date +%Y%m%d_%H%M%S)"
                    fi
                    ln -s "$file" "$target"
                    [[ "$verbose" == true ]] && echo -e "${GREEN}✓${NC} Created symlink: $target"
                else
                    # Target doesn't exist
                    created_links=$((created_links + 1))
                    ln -s "$file" "$target"
                    [[ "$verbose" == true ]] && echo -e "${GREEN}✓${NC} Created symlink: $target"
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

# Function to clean up broken symlinks
# Usage: cleanup_broken_symlinks <dots_dir> <dry_run> <verbose>
cleanup_broken_symlinks() {
    local dots_dir="$1"
    local dry_run="${2:-false}"
    local verbose="${3:-false}"
    
    local broken_count=0
    local temp_broken_links="/tmp/dots_broken_links_$$"
    true > "$temp_broken_links"
    
    # Search in common directories for symlinks pointing to dots directory
    for search_dir in "$HOME/.config" "$HOME/bin" "$HOME/Library" "$HOME"; do
        [[ ! -d "$search_dir" ]] && continue
        
        find "$search_dir" -maxdepth 2 -type l 2>/dev/null | while read -r symlink; do
            if [[ -L "$symlink" ]]; then
                target_path=$(readlink "$symlink")
                # Check if it points to our dots directory and is broken
                if [[ "$target_path" == "$dots_dir"* ]] && [[ ! -e "$target_path" ]]; then
                    echo "$symlink" >> "$temp_broken_links"
                fi
            fi
        done
    done
    
    # Process the broken symlinks (remove duplicates)
    if [[ -s "$temp_broken_links" ]]; then
        while IFS= read -r symlink; do
            if [[ -L "$symlink" ]]; then # Double-check it's still a symlink
                if [[ "$dry_run" == true ]]; then
                    [[ "$verbose" == true ]] && echo -e "${RED}✗${NC} [DRY] Would remove broken symlink: $symlink"
                else
                    [[ "$verbose" == true ]] && echo -e "${RED}✗${NC} Removing broken symlink: $symlink"
                    rm "$symlink"
                fi
                broken_count=$((broken_count + 1))
            fi
        done < <(sort -u "$temp_broken_links")
    fi
    
    rm -f "$temp_broken_links"
    
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
    fi

    # Output stats in a parseable format
    echo "STATS:$total_links:$valid_links:$broken_links:$missing_links:$wrong_target_links"
fi