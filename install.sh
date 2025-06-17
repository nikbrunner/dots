#!/bin/bash
# Main installation script for dots
# Usage: ./install.sh

set -e

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check for dry run flag
DRY_RUN=false
for arg in "$@"; do
    if [[ "$arg" == "--dry-run" ]]; then
        DRY_RUN=true
        break
    fi
done

# Source OS detection
# shellcheck disable=SC1091
source "$SCRIPT_DIR/scripts/detect-os.sh"

echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      Dots Installation Script        ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
echo ""

if [[ "$DRY_RUN" == true ]]; then
    echo -e "${YELLOW}DRY RUN MODE - No changes will be made${NC}"
    echo ""
fi

# 1. Detect OS
OS=$(get_os)
echo -e "${GREEN}✓${NC} Detected OS: $OS"

# 2. Initialize git repository if needed
if [[ ! -d "$SCRIPT_DIR/.git" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}→${NC} [DRY] Would initialize git repository"
    else
        echo -e "${YELLOW}→${NC} Initializing git repository..."
        cd "$SCRIPT_DIR"
        git init
        echo -e "${GREEN}✓${NC} Git repository initialized"
    fi
fi

# 3. Install git hooks
if [[ "$DRY_RUN" == true ]]; then
    echo -e "${YELLOW}→${NC} [DRY] Would install git hooks"
else
    echo -e "${YELLOW}→${NC} Installing git hooks..."
    "$SCRIPT_DIR/scripts/install-hooks.sh"
fi

# 4. Run submodule initialization (when we have submodules)
if [[ -f "$SCRIPT_DIR/.gitmodules" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}→${NC} [DRY] Would initialize submodules"
    else
        echo -e "${YELLOW}→${NC} Initializing submodules..."
        "$SCRIPT_DIR/scripts/submodules.sh" update
    fi
fi

# 5. Create symlinks
echo ""
echo -e "${YELLOW}→${NC} Creating symlinks..."
"$SCRIPT_DIR/scripts/link.sh" "$@"

# 6. Set up dots command
echo ""
if [[ "$DRY_RUN" == true ]]; then
    echo -e "${YELLOW}→${NC} [DRY] Would set up dots command at ~/.local/bin/dots"
    if [[ ! -L "$HOME/.local/bin/dots" ]]; then
        echo -e "  Would create symlink: ~/.local/bin/dots → $SCRIPT_DIR/common/bin/dots"
    fi
else
    echo -e "${YELLOW}→${NC} Setting up dots command..."

    # Create ~/.local/bin if it doesn't exist
    mkdir -p "$HOME/.local/bin"

    # Create dots command symlink
    if [[ -L "$HOME/.local/bin/dots" ]]; then
        rm "$HOME/.local/bin/dots"
    fi
    ln -s "$SCRIPT_DIR/common/bin/dots" "$HOME/.local/bin/dots"
    echo -e "${GREEN}✓${NC} Created dots command at ~/.local/bin/dots"
fi

# Make all scripts executable
echo ""
if [[ "$DRY_RUN" == true ]]; then
    echo -e "${YELLOW}→${NC} [DRY] Would make scripts executable"
    echo "  Would chmod +x: install.sh"
    echo "  Would chmod +x: scripts/*.sh"
    echo "  Would chmod +x: common/bin/*"
else
    echo -e "${YELLOW}→${NC} Making scripts executable..."
    chmod +x "$SCRIPT_DIR/install.sh"
    chmod +x "$SCRIPT_DIR/scripts/"*.sh
    find "$SCRIPT_DIR/common/bin" -type f -exec chmod +x {} \;
    echo -e "${GREEN}✓${NC} All scripts are now executable"
fi

# Success message
echo ""
if [[ "$DRY_RUN" == true ]]; then
    echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║    Dry Run Complete! 🔍              ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
    echo ""
    echo "This was a dry run. No changes were made."
    echo "Run without --dry-run to perform the actual installation."
else
    echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║    Installation Complete! 🎉         ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
fi
echo ""
echo "Next steps:"
echo "1. Ensure ~/.local/bin is in your PATH"
echo "2. Reload your shell configuration: source ~/.zshrc"
echo "3. Run 'dots' to see available commands"
echo ""
echo "OS-specific notes:"
if [[ "$OS" == "macos" ]]; then
    echo "• Run 'brew bundle' in $SCRIPT_DIR/macos to install Homebrew packages"
fi
echo ""
echo "To add submodules later:"
echo "• nvim: ./scripts/submodules.sh add https://github.com/nikbrunner/nvim submodules/nvim"
echo "• wezterm: ./scripts/submodules.sh add https://github.com/nikbrunner/wezterm submodules/wezterm"
echo ""
