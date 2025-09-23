#!/usr/bin/env bash
# Creates and manages symlinks from symlinks configuration
# Usage: ./scripts/symlinks.sh [--dry-run] [--no-backup] [--verbose]
# Can also be sourced for access to symlink functions

set -e

# ============================================================================
# SYMLINKS CONFIGURATION FUNCTIONS
# ============================================================================

# Function to process symlinks configuration with common + OS-specific sections
# Usage: process_symlinks_entries <symlinks_file> <current_os>
# Returns: prints "source_path|target_path" pairs for all entries
process_symlinks_entries() {
    local symlinks_file="$1"
    local current_os="$2"

    if [[ ! -f "$symlinks_file" ]]; then
        echo "Error: Symlinks file not found: $symlinks_file" >&2
        return 1
    fi

    # Process common section first
    yq eval '.common | to_entries | .[] | .key + "|" + .value' "$symlinks_file" 2>/dev/null

    # Process OS-specific section
    yq eval ".$current_os | to_entries | .[] | .key + \"|\" + .value" "$symlinks_file" 2>/dev/null
}

# ============================================================================
# SYMLINK FUNCTIONS
# ============================================================================

# Function to expand wildcard patterns in symlinks entries
# Usage: expand_wildcard_entry <source_path> <target_path> <dots_dir>
# Returns: prints "source_file|target_file" pairs for each expanded entry
expand_wildcard_entry() {
    local source_path="$1"
    local target_path="$2"
    local dots_dir="$3"

    # Check if source path ends with /*
    if [[ "$source_path" == *"*" ]]; then
        # Remove the /* suffix to get the base directory
        local base_source="${source_path%/*}"
        local abs_base_source="$dots_dir/$base_source"

        # Check if the base directory exists
        if [[ ! -d "$abs_base_source" ]]; then
            echo "✗ Wildcard source directory not found: $abs_base_source" >&2
            return 1
        fi

        # List all files (not directories) in the source directory
        local file_count=0
        while IFS= read -r -d '' file; do
            if [[ -f "$file" ]]; then
                local filename
                filename=$(basename "$file")
                local file_source="$base_source/$filename"
                local file_target="$target_path/$filename"
                echo "$file_source|$file_target"
                file_count=$((file_count + 1))
            fi
        done < <(find "$abs_base_source" -maxdepth 1 -type f -print0 2>/dev/null)

        if [[ "$file_count" -eq 0 ]]; then
            echo "⚠ No files found in wildcard directory: $abs_base_source" >&2
        fi
    else
        # Not a wildcard, return as-is
        echo "$source_path|$target_path"
    fi
}

# Function to create symlinks from symlinks configuration
# Usage: create_symlinks_from_config <symlinks_file> <current_os> [options...]
# Options: --dry-run, --no-backup, --verbose
create_symlinks_from_config() {
    local symlinks_file="$1"
    local current_os="$2"
    shift 2

    # Parse options
    local dry_run=false
    local no_backup=false
    local verbose=false

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
        esac
    done

    if [[ ! -f "$symlinks_file" ]]; then
        echo "Error: Symlinks file not found: $symlinks_file"
        return 1
    fi

    # Validate YAML
    if ! yq eval '.' "$symlinks_file" >/dev/null 2>&1; then
        echo "Error: Invalid YAML in symlinks file: $symlinks_file"
        return 1
    fi

    local dots_dir
    dots_dir="$(dirname "$symlinks_file")"

    # Initialize counters
    local total_links=0
    local created_links=0
    local updated_links=0
    local valid_links=0
    local errors=0

    # First, expand wildcards and collect all entries to process
    local temp_expanded
    temp_expanded=$(mktemp)

    # Process each entry in the configuration and expand wildcards
    while IFS='|' read -r source_path target_path; do
        [[ -z "$source_path" || -z "$target_path" ]] && continue

        # Expand wildcards if present, otherwise pass through as-is
        expand_wildcard_entry "$source_path" "$target_path" "$dots_dir" >>"$temp_expanded"
    done < <(process_symlinks_entries "$symlinks_file" "$current_os")

    # Now process all expanded entries (including non-wildcards)
    while IFS='|' read -r source_path target_path; do
        [[ -z "$source_path" || -z "$target_path" ]] && continue

        total_links=$((total_links + 1))

        # Convert tilde paths to absolute paths
        local abs_target="${target_path/\~/$HOME}"
        local abs_source="$dots_dir/$source_path"

        [[ "$verbose" == true ]] && echo "Processing: $source_path -> $target_path"

        # Verify source exists
        if [[ ! -e "$abs_source" ]]; then
            echo "✗ Source not found: $abs_source"
            errors=$((errors + 1))
            continue
        fi

        if [[ "$dry_run" == true ]]; then
            # Dry run mode - just show what would happen
            if [[ -L "$abs_target" ]]; then
                local current_target
                current_target=$(readlink "$abs_target" 2>/dev/null)
                if [[ "$current_target" == "$abs_source" ]]; then
                    valid_links=$((valid_links + 1))
                    [[ "$verbose" == true ]] && echo "✓ [DRY] Symlink OK: $target_path"
                else
                    [[ "$verbose" == true ]] && echo "⚠ [DRY] Would update symlink: $target_path"
                    updated_links=$((updated_links + 1))
                fi
            elif [[ -e "$abs_target" ]]; then
                [[ "$verbose" == true ]] && echo "⚠ [DRY] Would backup and replace: $target_path"
                created_links=$((created_links + 1))
            else
                [[ "$verbose" == true ]] && echo "+ [DRY] Would create symlink: $target_path"
                created_links=$((created_links + 1))
            fi
        else
            # Create parent directories if needed
            mkdir -p "$(dirname "$abs_target")"

            if [[ -L "$abs_target" ]]; then
                # Target is already a symlink
                local current_target
                current_target=$(readlink "$abs_target" 2>/dev/null)
                if [[ "$current_target" == "$abs_source" ]]; then
                    valid_links=$((valid_links + 1))
                    [[ "$verbose" == true ]] && echo "✓ Symlink OK: $target_path"
                else
                    # Update symlink
                    rm "$abs_target"
                    ln -s "$abs_source" "$abs_target"
                    updated_links=$((updated_links + 1))
                    [[ "$verbose" == true ]] && echo "⚠ Updated symlink: $target_path"
                fi
            elif [[ -e "$abs_target" ]]; then
                # Target exists but is not a symlink
                if [[ "$no_backup" == true ]]; then
                    [[ "$verbose" == true ]] && echo "⚠ Replacing: $target_path"
                    rm -rf "$abs_target"
                else
                    local backup_name
                    backup_name="$abs_target.backup.$(date +%Y%m%d_%H%M%S)"
                    [[ "$verbose" == true ]] && echo "⚠ Backing up: $target_path -> $(basename "$backup_name")"
                    mv "$abs_target" "$backup_name"
                fi
                ln -s "$abs_source" "$abs_target"
                created_links=$((created_links + 1))
                [[ "$verbose" == true ]] && echo "✓ Created symlink: $target_path"
            else
                # Target doesn't exist
                ln -s "$abs_source" "$abs_target"
                created_links=$((created_links + 1))
                [[ "$verbose" == true ]] && echo "✓ Created symlink: $target_path"
            fi
        fi
    done <"$temp_expanded"

    # Clean up temp file
    rm -f "$temp_expanded"

    # Print summary
    if [[ "$dry_run" == true ]]; then
        echo "Dry run complete:"
    else
        echo "Symlink operation complete:"
    fi
    echo "  Total entries: $total_links"
    echo "  Valid symlinks: $valid_links"
    echo "  Created: $created_links"
    echo "  Updated: $updated_links"
    [[ "$errors" -gt 0 ]] && echo "  Errors: $errors"

    return $errors
}

# Function to clean up broken symlinks from symlinks configuration
# Usage: cleanup_broken_symlinks_from_config <symlinks_file> <current_os> [--dry-run] [--verbose]
cleanup_broken_symlinks_from_config() {
    local symlinks_file="$1"
    local current_os="$2"
    shift 2

    # Parse options
    local dry_run=false
    local verbose=false

    for arg in "$@"; do
        case $arg in
        --dry-run)
            dry_run=true
            ;;
        --verbose)
            verbose=true
            ;;
        esac
    done

    if [[ ! -f "$symlinks_file" ]]; then
        echo "Error: Symlinks file not found: $symlinks_file"
        return 1
    fi

    local dots_dir
    dots_dir="$(dirname "$symlinks_file")"

    local broken_count=0

    # First, expand wildcards and collect all entries to process
    local temp_expanded
    temp_expanded=$(mktemp)

    # Process each entry in the configuration and expand wildcards
    while IFS='|' read -r source_path target_path; do
        [[ -z "$source_path" || -z "$target_path" ]] && continue

        # Expand wildcards if present, otherwise pass through as-is
        expand_wildcard_entry "$source_path" "$target_path" "$dots_dir" >>"$temp_expanded"
    done < <(process_symlinks_entries "$symlinks_file" "$current_os")

    # Check each expanded symlink entry
    while IFS='|' read -r source_path target_path; do
        [[ -z "$source_path" || -z "$target_path" ]] && continue

        local abs_target="${target_path/\~/$HOME}"
        local abs_source="$dots_dir/$source_path"

        if [[ -L "$abs_target" ]]; then
            local current_target
            current_target=$(readlink "$abs_target" 2>/dev/null)

            # Check if symlink is broken or points to wrong target
            if [[ "$current_target" != "$abs_source" ]] || [[ ! -e "$abs_source" ]]; then
                if [[ "$dry_run" == true ]]; then
                    [[ "$verbose" == true ]] && echo "✗ [DRY] Would remove broken symlink: $abs_target"
                else
                    [[ "$verbose" == true ]] && echo "✗ Removing broken symlink: $abs_target"
                    rm "$abs_target"
                fi
                broken_count=$((broken_count + 1))
            fi
        fi
    done <"$temp_expanded"

    # Clean up temp file
    rm -f "$temp_expanded"

    if [[ "$broken_count" -eq 0 ]]; then
        [[ "$verbose" == true ]] && echo "✓ No broken symlinks found"
    else
        if [[ "$dry_run" == true ]]; then
            echo "Found $broken_count broken symlinks (dry run)"
        else
            echo "Cleaned up $broken_count broken symlinks"
        fi
    fi

    return 0
}

# Function to check status of symlinks from symlinks configuration
# Usage: check_symlinks_from_config <symlinks_file> <current_os> [--verbose]
check_symlinks_from_config() {
    local symlinks_file="$1"
    local current_os="$2"
    local verbose=false

    [[ "$3" == "--verbose" ]] && verbose=true

    if [[ ! -f "$symlinks_file" ]]; then
        echo "Error: Symlinks file not found: $symlinks_file"
        return 1
    fi

    local dots_dir
    dots_dir="$(dirname "$symlinks_file")"

    local total_links=0
    local valid_links=0
    local broken_links=0
    local missing_links=0
    local wrong_target_links=0

    # First, expand wildcards and collect all entries to process
    local temp_expanded
    temp_expanded=$(mktemp)

    # Process each entry in the configuration and expand wildcards
    while IFS='|' read -r source_path target_path; do
        [[ -z "$source_path" || -z "$target_path" ]] && continue

        # Expand wildcards if present, otherwise pass through as-is
        expand_wildcard_entry "$source_path" "$target_path" "$dots_dir" >>"$temp_expanded"
    done < <(process_symlinks_entries "$symlinks_file" "$current_os")

    # Check each expanded symlink entry
    while IFS='|' read -r source_path target_path; do
        [[ -z "$source_path" || -z "$target_path" ]] && continue

        total_links=$((total_links + 1))
        local abs_target="${target_path/\~/$HOME}"
        local abs_source="$dots_dir/$source_path"

        if [[ -L "$abs_target" ]]; then
            local current_target
            current_target=$(readlink "$abs_target" 2>/dev/null)
            if [[ "$current_target" == "$abs_source" ]]; then
                valid_links=$((valid_links + 1))
                [[ "$verbose" == true ]] && echo "✓ $target_path"
            else
                wrong_target_links=$((wrong_target_links + 1))
                [[ "$verbose" == true ]] && echo "⚠ Wrong target: $target_path -> $current_target (expected: $abs_source)"
            fi

            if [[ ! -e "$abs_target" ]]; then
                broken_links=$((broken_links + 1))
                [[ "$verbose" == true ]] && echo "✗ Broken link: $target_path"
            fi
        elif [[ -e "$abs_target" ]]; then
            [[ "$verbose" == true ]] && echo "✗ Not a symlink: $target_path"
        else
            missing_links=$((missing_links + 1))
            [[ "$verbose" == true ]] && echo "⚠ Missing: $target_path"
        fi
    done <"$temp_expanded"

    # Clean up temp file
    rm -f "$temp_expanded"

    echo "Symlink status summary:"
    echo "  Total entries: $total_links"
    echo "  Valid symlinks: $valid_links"
    echo "  Missing: $missing_links"
    echo "  Wrong target: $wrong_target_links"
    echo "  Broken: $broken_links"

    return 0
}

# ============================================================================
# MAIN SCRIPT EXECUTION
# ============================================================================

# If script is sourced, don't execute main logic
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    return 0
fi

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTS_DIR="$(dirname "$SCRIPT_DIR")"

# Source detect-os library
# shellcheck disable=SC1091
source "$SCRIPT_DIR/detect-os.sh"

# Get current OS
CURRENT_OS=$(get_os)
SYMLINKS_FILE="$DOTS_DIR/symlinks.yml"

# Check for flags
DRY_RUN=false
NO_BACKUP=false
VERBOSE=false
for arg in "$@"; do
    case $arg in
    --dry-run)
        DRY_RUN=true
        ;;
    --no-backup)
        NO_BACKUP=true
        ;;
    --verbose)
        VERBOSE=true
        ;;
    *)
        echo "Unknown option: $arg"
        echo "Usage: $0 [--dry-run] [--no-backup] [--verbose]"
        exit 1
        ;;
    esac
done

# Check if symlinks file exists
if [[ ! -f "$SYMLINKS_FILE" ]]; then
    echo "Error: Symlinks file not found: $SYMLINKS_FILE"
    echo "Please ensure symlinks.yml exists in the repository root."
    exit 1
fi

if [[ "$DRY_RUN" == true ]]; then
    echo "DRY RUN MODE - No changes will be made"
    echo ""
fi

if [[ "$NO_BACKUP" == true ]]; then
    echo "NO BACKUP MODE - Existing files will be overwritten"
    echo ""
fi

echo "Setting up dotfiles symlinks from configuration..."
echo "OS detected: $CURRENT_OS"
echo "Configuration: $SYMLINKS_FILE"
echo ""

# Clean up broken symlinks first
echo "→ Cleaning broken symlinks..."
if [[ "$DRY_RUN" == true ]]; then
    cleanup_broken_symlinks_from_config "$SYMLINKS_FILE" "$CURRENT_OS" --dry-run --verbose
else
    cleanup_broken_symlinks_from_config "$SYMLINKS_FILE" "$CURRENT_OS" --verbose
fi
echo ""

# Create/update symlinks
echo "→ Processing configuration entries..."
options=()
[[ "$DRY_RUN" == true ]] && options+=(--dry-run)
[[ "$NO_BACKUP" == true ]] && options+=(--no-backup)
[[ "$VERBOSE" == true ]] && options+=(--verbose)

if create_symlinks_from_config "$SYMLINKS_FILE" "$CURRENT_OS" "${options[@]}"; then
    echo ""
    if [[ "$DRY_RUN" == true ]]; then
        echo "Dry run complete! No changes were made."
    else
        echo "Symlink setup complete!"
    fi
else
    echo ""
    echo "Some errors occurred during symlink creation."
    exit 1
fi

