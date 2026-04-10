#!/usr/bin/env bash
# Creates relative symlinks from dots theme directories to Black Atom adapter repos
# Usage: ./scripts/theme-link.sh [--dry-run]

set -e

# Get dots directory
DOTS_DIR="${DOTS_DIR:-$HOME/repos/nikbrunner/dots}"
BLACK_ATOM_DIR="${BLACK_ATOM_DIR:-$HOME/repos/black-atom-industries}"

# Parse arguments
DRY_RUN=false
QUIET=false
VERBOSE=false
for arg in "$@"; do
    case $arg in
    --dry-run)
        DRY_RUN=true
        ;;
    --quiet)
        QUIET=true
        ;;
    --verbose)
        VERBOSE=true
        ;;
    *)
        echo "Unknown option: $arg"
        echo "Usage: $0 [--dry-run] [--quiet] [--verbose]"
        exit 1
        ;;
    esac
done

# Logging functions
log_info() {
    echo "→ $1"
}

log_success() {
    echo "✓ $1"
}

log_warning() {
    echo "⚠ $1"
}

log_error() {
    echo "✗ $1"
}

# Create a relative symlink
# Usage: create_relative_symlink <source_file> <target_symlink> <dry_run>
# Returns: "created", "updated", or "existing" via echo
create_relative_symlink() {
    local source="$1"
    local target="$2"
    local dry_run="$3"

    # Check current state
    local status="existing"
    if [[ -L "$target" ]]; then
        local current_target
        current_target=$(readlink "$target" 2>/dev/null)

        # Calculate expected relative path
        local target_dir
        target_dir=$(dirname "$target")
        local expected_rel
        expected_rel=$(python3 -c "import os.path; print(os.path.relpath('$source', '$target_dir'))")

        if [[ "$current_target" == "$expected_rel" ]]; then
            status="existing"
        else
            status="updated"
        fi
    elif [[ -e "$target" ]]; then
        status="updated"
    else
        status="created"
    fi

    if [[ "$dry_run" == "true" ]]; then
        echo "  [DRY] $target"
    else
        rm -f "$target"
        ln -s "$(python3 -c "import os.path; print(os.path.relpath('$source', '$(dirname "$target")'))")" "$target"
        [[ "$QUIET" != true ]] && echo "  $status: $(basename "$target")"
    fi

    echo "$status"
}

# Process an adapter
# Usage: process_adapter <adapter_name> <file_extension> <dots_target_dir>
process_adapter() {
    local adapter="$1"
    local extension="$2"
    local dots_target_dir="$3"

    local adapter_dir="$BLACK_ATOM_DIR/$adapter"
    local target_dir="$DOTS_DIR/$dots_target_dir"

    if [[ ! -d "$adapter_dir" ]]; then
        log_warning "Adapter not found: $adapter_dir"
        return 0
    fi

    log_info "Processing $adapter adapter..."

    # Ensure target directory exists
    if [[ "$DRY_RUN" != "true" ]]; then
        mkdir -p "$target_dir"
    fi

    local count=0
    local created=0
    local updated=0

    # Find all theme files matching the extension
    while IFS= read -r -d '' source_file; do
        local filename
        filename=$(basename "$source_file")

        # Skip template files
        if [[ "$filename" == *.template.* ]]; then
            continue
        fi

        local target_file="$target_dir/$filename"
        local status
        status=$(create_relative_symlink "$source_file" "$target_file" "$DRY_RUN")
        count=$((count + 1))

        [[ "$status" == "created" ]] && created=$((created + 1))
        [[ "$status" == "updated" ]] && updated=$((updated + 1))
    done < <(find "$adapter_dir/themes" -type f -name "*.$extension" -not -name "*.template.*" -print0 2>/dev/null)

    if [[ $count -eq 0 ]]; then
        log_warning "No theme files found for $adapter"
    elif [[ "$VERBOSE" == true ]]; then
        log_success "Processed $count theme files for $adapter"
    else
        log_success "Processed $count theme files for $adapter (created: $created, updated: $updated)"
    fi
}

# Main
echo "Black Atom Theme Linker"
echo "======================="
echo ""

if [[ "$DRY_RUN" == "true" ]]; then
    echo "DRY RUN MODE - No changes will be made"
    echo ""
fi

if [[ ! -d "$BLACK_ATOM_DIR" ]]; then
    log_error "Black Atom directory not found: $BLACK_ATOM_DIR"
    echo "Set BLACK_ATOM_DIR environment variable to override."
    exit 1
fi

# Process each adapter
process_adapter "ghostty" "conf" "common/.config/ghostty/themes"
echo ""
process_adapter "wezterm" "toml" "common/.config/wezterm/colors"
echo ""
process_adapter "zed" "json" "common/.config/zed/themes"
echo ""
process_adapter "niri" "kdl" "arch/.config/niri/themes"
echo ""
process_adapter "waybar" "css" "arch/.config/waybar/themes"
echo ""
process_adapter "lazygit" "yml" "common/.config/lazygit/themes"

echo ""
if [[ "$DRY_RUN" == "true" ]]; then
    log_info "Dry run complete. Run without --dry-run to apply changes."
else
    log_success "Theme linking complete!"
fi
