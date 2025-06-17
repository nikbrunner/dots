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

# Check for force flag
FORCE=false
if [[ "$1" == "--force" ]]; then
    FORCE=true
fi

# Function to create symlink
create_symlink() {
    local source="$1"
    local target="$2"

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

# Root configs
create_symlink "$DOTS_DIR/config/zsh/.zshrc" "$HOME/.zshrc"
create_symlink "$DOTS_DIR/config/git/.gitconfig" "$HOME/.gitconfig"
create_symlink "$DOTS_DIR/config/git/.gitignore" "$HOME/.gitignore"
create_symlink "$DOTS_DIR/config/vim/.vimrc" "$HOME/.vimrc"
create_symlink "$DOTS_DIR/config/vim/.ideavimrc" "$HOME/.ideavimrc"
create_symlink "$DOTS_DIR/config/shell/.hushlogin" "$HOME/.hushlogin"

# Config directories
create_symlink "$DOTS_DIR/config/yazi" "$HOME/.config/yazi"
create_symlink "$DOTS_DIR/config/lazygit" "$HOME/.config/lazygit"
create_symlink "$DOTS_DIR/config/bat" "$HOME/.config/bat"
create_symlink "$DOTS_DIR/config/tmux" "$HOME/.config/tmux"
create_symlink "$DOTS_DIR/config/gallery-dl" "$HOME/.config/gallery-dl"
create_symlink "$DOTS_DIR/config/oh-my-posh" "$HOME/.config/oh-my-posh"
create_symlink "$DOTS_DIR/config/karabiner" "$HOME/.config/karabiner"
create_symlink "$DOTS_DIR/config/kitty" "$HOME/.config/kitty"
create_symlink "$DOTS_DIR/config/ghostty" "$HOME/.config/ghostty"

# Scripts
create_symlink "$DOTS_DIR/scripts-custom" "$HOME/.scripts"

# OS-specific configs
if [[ "$(get_os)" == "macos" ]]; then
    echo ""
    echo "Setting up macOS-specific configs..."
    create_symlink "$DOTS_DIR/os-specific/macos/Library/Application Support/Claude/claude_desktop_config.json" \
        "$HOME/Library/Application Support/Claude/claude_desktop_config.json"
fi

# Future submodules (commented out for now)
# create_symlink "$DOTS_DIR/submodules/nvim" "$HOME/.config/nvim"
# create_symlink "$DOTS_DIR/submodules/wezterm" "$HOME/.config/wezterm"
# create_symlink "$DOTS_DIR/submodules/zed" "$HOME/.config/zed"

echo ""
echo "Symlink setup complete!"

