#!/usr/bin/env bash
# Main installation script for dots
# Usage: ./install.sh [--dry-run] [--no-deps]

set -e

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Parse arguments
DRY_RUN=false
SKIP_DEPS=false
DEBUG=false
for arg in "$@"; do
	case "$arg" in
		--dry-run)
			DRY_RUN=true
			;;
		--no-deps)
			SKIP_DEPS=true
			;;
		--debug)
			DEBUG=true
			;;
	esac
done

# Source dependencies and OS detection
# shellcheck disable=SC1091
source "$SCRIPT_DIR/scripts/detect-os.sh"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/scripts/deps.sh"

echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║    Dots Complete Machine Setup       ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
echo ""

if [[ "$DRY_RUN" == true ]]; then
	echo -e "${YELLOW}DRY RUN MODE - No changes will be made${NC}"
	echo ""
fi

if [[ "$DEBUG" == true ]]; then
	echo -e "${YELLOW}DEBUG MODE - Extra diagnostics enabled${NC}"
	echo ""
fi

# 1. Detect OS
OS=$(get_os)
echo -e "${GREEN}✓${NC} Detected OS: $OS"

# 2. Install dependencies (unless skipped)
if [[ "$SKIP_DEPS" == false ]]; then
	echo ""
	echo -e "${BLUE}📋 Phase 1: Dependency Installation${NC}"
	if [[ "$DRY_RUN" == true ]]; then
		echo -e "${YELLOW}→${NC} [DRY] Would install all required dependencies"
		echo "  Required: git, zsh, tmux, neovim, fzf, ripgrep, fd, bat, delta, lazygit, eza, zoxide, gum, gh, 1password, 1password-cli"
	else
		if ! install_all_dependencies; then
			echo -e "${RED}❌ Failed to install dependencies${NC}"
			echo "You can skip dependency installation with: ./install.sh --no-deps"
			exit 1
		fi
	fi
else
	echo ""
	echo -e "${YELLOW}⚠️  Skipping dependency installation (--no-deps flag)${NC}"
fi

# 3. Configure system
echo ""
echo -e "${BLUE}⚙️  Phase 2: System Configuration${NC}"
if [[ "$DRY_RUN" == true ]]; then
	echo -e "${YELLOW}→${NC} [DRY] Would configure system settings"
	echo "  • Set zsh as default shell"
	echo "  • Configure Git SSH signing"
	echo "  • Install TPM (Tmux Plugin Manager)"
	echo "  • Install NVM (Linux only)"
else
	if [[ "$SKIP_DEPS" == false ]]; then
		configure_system
	else
		echo -e "${YELLOW}→${NC} Skipping system configuration (dependencies skipped)"
	fi
fi

# 4. Initialize git repository if needed
echo ""
echo -e "${BLUE}🔗 Phase 3: Dotfiles Setup${NC}"
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

# 5. Run submodule initialization (when we have submodules)
if [[ -f "$SCRIPT_DIR/.gitmodules" ]]; then
	if [[ "$DRY_RUN" == true ]]; then
		echo -e "${YELLOW}→${NC} [DRY] Would initialize submodules"
	else
		echo -e "${YELLOW}→${NC} Initializing submodules..."
		"$SCRIPT_DIR/scripts/submodules.sh" update
	fi
fi

# 6. Create symlinks
echo -e "${YELLOW}→${NC} Creating symlinks..."
SYMLINK_ARGS=()
[[ "$DRY_RUN" == true ]] && SYMLINK_ARGS+=("--dry-run")
"$SCRIPT_DIR/scripts/symlinks.sh" "${SYMLINK_ARGS[@]}"

# 7. Set up dots command
if [[ "$DRY_RUN" == true ]]; then
	echo -e "${YELLOW}→${NC} [DRY] Would set up dots command at ~/.local/bin/dots"
	if [[ ! -L "$HOME/.local/bin/dots" ]]; then
		echo -e "  Would create symlink: ~/.local/bin/dots → $SCRIPT_DIR/common/.local/bin/dots"
	fi
else
	echo -e "${YELLOW}→${NC} Setting up dots command..."

	# Create ~/.local/bin if it doesn't exist
	mkdir -p "$HOME/.local/bin"

	# Create dots command symlink
	if [[ -L "$HOME/.local/bin/dots" ]]; then
		rm "$HOME/.local/bin/dots"
	fi
	ln -s "$SCRIPT_DIR/common/.local/bin/dots" "$HOME/.local/bin/dots"
	echo -e "${GREEN}✓${NC} Created dots command at ~/.local/bin/dots"
fi

# 8. Make all scripts executable
if [[ "$DRY_RUN" == true ]]; then
	echo -e "${YELLOW}→${NC} [DRY] Would make scripts executable"
	echo "  Would chmod +x: install.sh"
	echo "  Would chmod +x: scripts/*.sh"
	echo "  Would chmod +x: common/.local/bin/*"
else
	echo -e "${YELLOW}→${NC} Making scripts executable..."
	chmod +x "$SCRIPT_DIR/install.sh"
	chmod +x "$SCRIPT_DIR/scripts/"*.sh
	find "$SCRIPT_DIR/common/.local/bin" -type f -exec chmod +x {} \;
	echo -e "${GREEN}✓${NC} All scripts are now executable"
fi

# 8.5. Install rmpc music client
if [[ "$SKIP_DEPS" == false ]]; then
	echo ""
	echo -e "${BLUE}🎵 Phase 5: Music Client Setup${NC}"
	if [[ "$DRY_RUN" == true ]]; then
		echo -e "${YELLOW}→${NC} [DRY] Would install rmpc music client"
		echo "  Would run: cargo install rmpc"
	else
		if command -v cargo &> /dev/null; then
			if ! command -v rmpc &> /dev/null; then
				echo -e "${YELLOW}→${NC} Installing rmpc music client..."
				echo -e "${YELLOW}   This may take several minutes to compile...${NC}"
				if cargo install rmpc; then
					echo -e "${GREEN}✓${NC} rmpc installed successfully"
				else
					echo -e "${YELLOW}⚠️${NC} rmpc installation failed (this is optional)"
				fi
			else
				echo -e "${GREEN}✓${NC} rmpc already installed"
			fi
		else
			echo -e "${YELLOW}⚠️${NC} Cargo not available, skipping rmpc installation"
		fi
	fi
fi

# 9. Validate installation
if [[ "$SKIP_DEPS" == false ]] && [[ "$DRY_RUN" == false ]]; then
	echo ""
	echo -e "${BLUE}🧪 Phase 4: Validation${NC}"
	if validate_dependencies; then
		echo -e "${GREEN}✓${NC} Testing dots command..."
		if command -v dots &> /dev/null; then
			echo -e "${GREEN}✓${NC} dots command functional"
		else
			echo -e "${YELLOW}⚠️${NC} dots command not in PATH - reload shell"
		fi
	fi
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
	echo -e "${GREEN}║   Machine Setup Complete! 🎉         ║${NC}"
	echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
	echo ""
	if [[ "$SKIP_DEPS" == false ]]; then
		echo "🎯 Your development environment is ready:"
		echo "  • Modern shell: zsh with custom configuration"
		echo "  • Editor: neovim with custom configuration"
		echo "  • Tools: fzf, ripgrep, tmux, lazygit, gh"
		echo "  • Configuration: Use 'dots' for dotfiles management"
		echo ""
	fi
fi

echo "📋 Next steps:"
if [[ "$SKIP_DEPS" == false ]]; then
	echo "1. Logout and login (for shell change to take effect)"
	echo "2. Reload your shell: source ~/.zshrc"
	echo "3. Test with: dots status"
	echo "4. Verify SSH: ssh -T git@github.com"
else
	echo "1. Install dependencies manually or run: ./install.sh (without --no-deps)"
	echo "2. Ensure ~/.local/bin is in your PATH"
	echo "3. Reload your shell: source ~/.zshrc"
fi
echo ""

if [[ "$SKIP_DEPS" == false ]]; then
	echo "🛠️  Available commands:"
	echo "  • 'dots' - dotfiles management (status, sync, link)"
	echo "  • 'repos' - repository management (find, open, status)"
	echo "  • 'repo' - individual repository operations"
	echo "  • 'ytdl' - download music from YouTube with metadata"
	echo "  • 'music' - control MPD music daemon"
	echo "  • 'rmpc' - terminal music player"
fi
echo ""
