#!/bin/bash
# Main installation script for dots
# Usage: ./install.sh

set -e

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Source OS detection
source "$SCRIPT_DIR/scripts/detect-os.sh"

echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      Dots Installation Script        ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
echo ""

# 1. Detect OS
OS=$(get_os)
echo -e "${GREEN}✓${NC} Detected OS: $OS"

# 2. Initialize git repository if needed
if [[ ! -d "$SCRIPT_DIR/.git" ]]; then
    echo -e "${YELLOW}→${NC} Initializing git repository..."
    cd "$SCRIPT_DIR"
    git init
    echo -e "${GREEN}✓${NC} Git repository initialized"
fi

# 3. Run submodule initialization (when we have submodules)
if [[ -f "$SCRIPT_DIR/.gitmodules" ]]; then
    echo -e "${YELLOW}→${NC} Initializing submodules..."
    "$SCRIPT_DIR/scripts/submodules.sh" update
fi

# 4. Create symlinks
echo ""
echo -e "${YELLOW}→${NC} Creating symlinks..."
"$SCRIPT_DIR/scripts/link.sh" "$@"

# 5. Set up dots command
echo ""
echo -e "${YELLOW}→${NC} Setting up dots command..."

# Create ~/.local/bin if it doesn't exist
mkdir -p "$HOME/.local/bin"

# Create dots command symlink
if [[ -L "$HOME/.local/bin/dots" ]]; then
    rm "$HOME/.local/bin/dots"
fi
ln -s "$SCRIPT_DIR/scripts-custom/dots" "$HOME/.local/bin/dots"
echo -e "${GREEN}✓${NC} Created dots command at ~/.local/bin/dots"

# Make all scripts executable
echo ""
echo -e "${YELLOW}→${NC} Making scripts executable..."
chmod +x "$SCRIPT_DIR/install.sh"
chmod +x "$SCRIPT_DIR/scripts/"*.sh
find "$SCRIPT_DIR/scripts-custom" -type f -exec chmod +x {} \;
echo -e "${GREEN}✓${NC} All scripts are now executable"

# Success message
echo ""
echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║    Installation Complete! 🎉         ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
echo ""
echo "Next steps:"
echo "1. Ensure ~/.local/bin is in your PATH"
echo "2. Reload your shell configuration: source ~/.zshrc"
echo "3. Run 'dots' to see available commands"
echo ""
echo "OS-specific notes:"
if [[ "$OS" == "macos" ]]; then
    echo "• Run 'brew bundle' in $SCRIPT_DIR/os-specific/macos to install Homebrew packages"
fi
echo ""
echo "To add submodules later:"
echo "• nvim: ./scripts/submodules.sh add https://github.com/nikbrunner/nvim submodules/nvim"
echo "• wezterm: ./scripts/submodules.sh add https://github.com/nikbrunner/wezterm submodules/wezterm"
echo ""