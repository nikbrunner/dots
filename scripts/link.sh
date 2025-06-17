#!/bin/bash
# Creates symlinks for dotfiles based on JSON mappings
# Usage: ./scripts/link.sh [--dry-run]

set -e

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTS_DIR="$(dirname "$SCRIPT_DIR")"

# Source OS detection
# shellcheck disable=SC1091
source "$SCRIPT_DIR/detect-os.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Check for flags
DRY_RUN=false
for arg in "$@"; do
    case $arg in
        --dry-run)
            DRY_RUN=true
            ;;
    esac
done

if [[ "$DRY_RUN" == true ]]; then
    echo -e "${YELLOW}DRY RUN MODE - No changes will be made${NC}"
    echo ""
fi

# Function to create symlink
create_symlink() {
    local source="$1"
    local target="$2"

    if [[ "$DRY_RUN" == true ]]; then
        # Dry run mode - just show what would happen
        if [[ -L "$target" ]]; then
            local actual_target
            actual_target=$(readlink "$target")
            if [[ "$actual_target" == "$source" ]]; then
                echo -e "${GREEN}✓${NC} [DRY] Symlink OK: $target → $source"
            else
                echo -e "${YELLOW}⚠${NC} [DRY] Wrong target: $target → $actual_target (expected: $source)"
            fi
        elif [[ -e "$target" ]]; then
            echo -e "${YELLOW}⚠${NC} [DRY] File exists (not symlink): $target"
            echo -e "${YELLOW}⚠${NC} [DRY] Would backup and replace with symlink"
        else
            echo -e "${GREEN}+${NC} [DRY] Would create symlink: $target → $source"
        fi
        return
    fi

    # Create parent directory if it doesn't exist
    mkdir -p "$(dirname "$target")"

    if [[ -L "$target" ]]; then
        # Target is a symlink
        local actual_target
        actual_target=$(readlink "$target")
        if [[ "$actual_target" == "$source" ]]; then
            echo -e "${GREEN}✓${NC} Symlink OK: $target"
        else
            echo -e "${YELLOW}⚠${NC} Updating symlink: $target"
            rm "$target"
            ln -s "$source" "$target"
            echo -e "${GREEN}✓${NC} Updated symlink: $target"
        fi
    elif [[ -e "$target" ]]; then
        # Target exists but is not a symlink - backup and replace
        echo -e "${YELLOW}⚠${NC} Backing up existing file: $target"
        mv "$target" "$target.backup.$(date +%Y%m%d_%H%M%S)"
        ln -s "$source" "$target"
        echo -e "${GREEN}✓${NC} Created symlink: $target"
    else
        # Target doesn't exist
        ln -s "$source" "$target"
        echo -e "${GREEN}✓${NC} Created symlink: $target"
    fi
}

echo "Setting up dotfiles symlinks..."
echo "OS detected: $(get_os)"
echo ""

# Get current OS
CURRENT_OS=$(get_os)
MAPPING_FILE="$DOTS_DIR/.mappings/$CURRENT_OS.json"

# Generate mappings if they don't exist or are outdated
if [[ ! -f "$MAPPING_FILE" ]] || [[ "$DOTS_DIR/common" -nt "$MAPPING_FILE" ]] || [[ "$DOTS_DIR/$CURRENT_OS" -nt "$MAPPING_FILE" ]]; then
    echo -e "${YELLOW}→${NC} Generating fresh mappings..."
    "$SCRIPT_DIR/generate-mappings.sh" >/dev/null
fi

# Check if mapping file exists
if [[ ! -f "$MAPPING_FILE" ]]; then
    echo -e "${RED}✗${NC} Mapping file not found: $MAPPING_FILE"
    echo "Run: $SCRIPT_DIR/generate-mappings.sh"
    exit 1
fi

echo -e "${YELLOW}→${NC} Using mappings: $MAPPING_FILE"
echo ""

# Parse JSON and create symlinks
# Using a simple approach that works with basic JSON without requiring jq
while IFS=':' read -r source_part target_part; do
    # Skip lines that don't contain mappings (like opening/closing braces)
    [[ ! "$source_part" =~ \".*\" ]] && continue
    [[ ! "$target_part" =~ \".*\" ]] && continue

    # Clean up the strings (remove quotes, commas, spaces)
    source=$(echo "$source_part" | sed 's/^[[:space:]]*"//' | sed 's/"[[:space:]]*$//')
    target=$(echo "$target_part" | sed 's/^[[:space:]]*"//' | sed 's/"[[:space:]]*,*[[:space:]]*$//')

    # Skip empty lines
    [[ -z "$source" || -z "$target" ]] && continue

    create_symlink "$source" "$target"

done <"$MAPPING_FILE"

echo ""
echo "Symlink setup complete!"
