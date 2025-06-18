#!/bin/bash
# Creates symlinks for dotfiles using direct directory traversal
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

# Function to process directory and create symlinks
process_directory() {
    local source_dir="$1"
    local target_base="$2"
    local dir_name="$3"
    
    [[ ! -d "$source_dir" ]] && return
    
    echo -e "${YELLOW}→${NC} Processing $dir_name files..."
    
    local file_count=0
    
    # Find all files and symlinks recursively
    while IFS= read -r -d '' file; do
        # Calculate relative path from source directory
        local rel_path="${file#"$source_dir"/}"
        local target="$target_base/$rel_path"
        
        # Skip if source file doesn't exist (shouldn't happen, but be safe)
        [[ ! -e "$file" ]] && continue
        
        create_symlink "$file" "$target"
        ((file_count++))
    done < <(find "$source_dir" \( -type f -o -type l \) -print0 2>/dev/null)
    
    if [[ $file_count -eq 0 ]]; then
        echo -e "${YELLOW}→${NC} No files found in $dir_name"
    else
        echo -e "${GREEN}✓${NC} Processed $file_count files from $dir_name"
    fi
}

echo "Setting up dotfiles symlinks..."
echo "OS detected: $(get_os)"
echo ""

# Get current OS
CURRENT_OS=$(get_os)

# Clean up broken symlinks BEFORE creating new ones
echo -e "${YELLOW}→${NC} Cleaning broken symlinks..."

broken_count=0
temp_broken_links="/tmp/dots_broken_links_$$"
true > "$temp_broken_links"

# Search in common directories for symlinks pointing to dots directory
for search_dir in "$HOME/.config" "$HOME/bin" "$HOME/Library" "$HOME"; do
    [[ ! -d "$search_dir" ]] && continue
    
    find "$search_dir" -maxdepth 2 -type l 2>/dev/null | while read -r symlink; do
        if [[ -L "$symlink" ]]; then
            target_path=$(readlink "$symlink")
            # Check if it points to our dots directory and is broken
            if [[ "$target_path" == "$DOTS_DIR"* ]] && [[ ! -e "$target_path" ]]; then
                echo "$symlink" >> "$temp_broken_links"
            fi
        fi
    done
done

# Process the broken symlinks (remove duplicates)
if [[ -s "$temp_broken_links" ]]; then
    while IFS= read -r symlink; do
        if [[ -L "$symlink" ]]; then  # Double-check it's still a symlink
            if [[ "$DRY_RUN" == true ]]; then
                echo -e "${RED}✗${NC} [DRY] Would remove broken symlink: $symlink"
            else
                echo -e "${RED}✗${NC} Removing broken symlink: $symlink"
                rm "$symlink"
            fi
            ((broken_count++))
        fi
    done < <(sort -u "$temp_broken_links")
fi

rm -f "$temp_broken_links"

if [[ $broken_count -eq 0 ]]; then
    echo -e "${GREEN}✓${NC} No broken symlinks found"
else
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${GREEN}✓${NC} Would remove $broken_count broken symlinks"
    else
        echo -e "${GREEN}✓${NC} Removed $broken_count broken symlinks"
    fi
fi
echo ""

# Process common files first
process_directory "$DOTS_DIR/common" "$HOME" "common"

# Process OS-specific files
if [[ "$CURRENT_OS" == "macos" && -d "$DOTS_DIR/macos" ]]; then
    process_directory "$DOTS_DIR/macos" "$HOME" "macOS-specific"
elif [[ "$CURRENT_OS" == "linux" && -d "$DOTS_DIR/linux" ]]; then
    process_directory "$DOTS_DIR/linux" "$HOME" "Linux-specific"
fi

echo ""
echo "Symlink setup complete!"