#!/bin/bash
# Creates symlinks for dotfiles based on OS
# Usage: ./scripts/link.sh [--force]

set -e

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTS_DIR="$(dirname "$SCRIPT_DIR")"

# Source OS detection
source "$SCRIPT_DIR/detect-os.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Check for flags
FORCE=false
DRY_RUN=false
for arg in "$@"; do
    case $arg in
        --force)
            FORCE=true
            ;;
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

    # Create parent directory if it doesn't exist
    mkdir -p "$(dirname "$target")"

    if [[ "$DRY_RUN" == true ]]; then
        # Dry run mode - just show what would happen
        if [[ -L "$target" ]]; then
            local actual_target=$(readlink "$target")
            if [[ "$actual_target" == "$source" ]]; then
                echo -e "${GREEN}✓${NC} [DRY] Symlink OK: $target → $source"
            else
                echo -e "${YELLOW}⚠${NC} [DRY] Wrong target: $target → $actual_target (expected: $source)"
            fi
        elif [[ -e "$target" ]]; then
            echo -e "${RED}✗${NC} [DRY] File exists (not symlink): $target"
            if [[ "$FORCE" == true ]]; then
                echo -e "${YELLOW}⚠${NC} [DRY] Would backup and replace with symlink"
            fi
        else
            echo -e "${GREEN}+${NC} [DRY] Would create symlink: $target → $source"
        fi
        return
    fi
    
    # Create parent directory if it doesn't exist
    mkdir -p "$(dirname "$target")"

    if [[ -L "$target" ]]; then
        # Target is a symlink
        if [[ "$FORCE" == true ]]; then
            rm "$target"
            ln -s "$source" "$target"
            echo -e "${GREEN}✓${NC} Updated symlink: $target"
        else
            echo -e "${YELLOW}→${NC} Symlink exists: $target"
        fi
    elif [[ -e "$target" ]]; then
        # Target exists but is not a symlink
        if [[ "$FORCE" == true ]]; then
            echo -e "${YELLOW}⚠${NC} Backing up existing file: $target"
            mv "$target" "$target.backup.$(date +%Y%m%d_%H%M%S)"
            ln -s "$source" "$target"
            echo -e "${GREEN}✓${NC} Created symlink: $target"
        else
            echo -e "${RED}✗${NC} File exists (not a symlink): $target"
            echo "  Use --force to backup and replace"
        fi
    else
        # Target doesn't exist
        ln -s "$source" "$target"
        echo -e "${GREEN}✓${NC} Created symlink: $target"
    fi
}

echo "Setting up dotfiles symlinks..."
echo "OS detected: $(get_os)"
echo ""

# Recursive function to create symlinks
link_recursive() {
    local source_dir="$1"
    local target_dir="$2"
    
    # Skip if source directory doesn't exist
    [[ ! -d "$source_dir" ]] && return
    
    # Process each item in source directory
    for item in "$source_dir"/*; do
        # Skip if glob didn't match anything
        [[ ! -e "$item" ]] && continue
        
        local basename=$(basename "$item")
        local target="$target_dir/$basename"
        
        if [[ -d "$item" ]] && [[ ! -L "$item" ]]; then
            # For config directories, symlink the entire directory
            if [[ "$basename" != ".config" ]] && [[ "$(dirname "$target")" == *"/.config" ]]; then
                # This is a tool config directory inside .config, symlink it entirely
                create_symlink "$item" "$target"
            else
                # It's a regular directory, recurse
                link_recursive "$item" "$target"
            fi
        elif [[ -f "$item" ]] || [[ -L "$item" ]]; then
            # It's a file or symlink, create symlink
            create_symlink "$item" "$target"
        fi
    done
}

# Process dotfiles (files starting with .)
link_dotfiles() {
    local source_dir="$1"
    local target_dir="$2"
    
    # Skip if source directory doesn't exist
    [[ ! -d "$source_dir" ]] && return
    
    # Process dotfiles in source directory
    for item in "$source_dir"/.*; do
        # Skip . and ..
        [[ "$item" == "$source_dir/." ]] || [[ "$item" == "$source_dir/.." ]] && continue
        [[ ! -e "$item" ]] && continue
        
        local basename=$(basename "$item")
        local target="$target_dir/$basename"
        
        if [[ -d "$item" ]] && [[ ! -L "$item" ]]; then
            # For config directories, symlink the entire directory
            if [[ "$basename" != ".config" ]] && [[ "$(dirname "$target")" == *"/.config" ]]; then
                # This is a tool config directory inside .config, symlink it entirely
                create_symlink "$item" "$target"
            else
                # It's a regular directory, recurse
                link_recursive "$item" "$target"
            fi
        elif [[ -f "$item" ]] || [[ -L "$item" ]]; then
            # It's a file or symlink, create symlink
            create_symlink "$item" "$target"
        fi
    done
}

# Main linking logic
echo "Linking common files..."
link_recursive "$DOTS_DIR/common" "$HOME"
link_dotfiles "$DOTS_DIR/common" "$HOME"

# OS-specific linking
if [[ "$(get_os)" == "macos" ]]; then
    echo ""
    echo "Linking macOS-specific files..."
    link_recursive "$DOTS_DIR/macos" "$HOME"
    link_dotfiles "$DOTS_DIR/macos" "$HOME"
elif [[ "$(get_os)" == "linux" ]]; then
    echo ""
    echo "Linking Linux-specific files..."
    link_recursive "$DOTS_DIR/linux" "$HOME"
    link_dotfiles "$DOTS_DIR/linux" "$HOME"
fi

# Future submodules (commented out for now)
# create_symlink "$DOTS_DIR/submodules/nvim" "$HOME/.config/nvim"
# create_symlink "$DOTS_DIR/submodules/wezterm" "$HOME/.config/wezterm"
# create_symlink "$DOTS_DIR/submodules/zed" "$HOME/.config/zed"

echo ""
echo "Symlink setup complete!"

