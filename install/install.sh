#!/usr/bin/env bash
# Main installation script for dots
# Usage: ./install.sh [--dry-run] [--no-deps]

set -e

# Get the dots directory (this script lives in install/)
DOTS_DIR="${DOTS_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# Bootstrap: on macOS with bash 3.x, install Homebrew + modern bash first, then re-exec
if [[ "${BASH_VERSINFO[0]}" -lt 4 ]]; then
    echo "Detected bash ${BASH_VERSION} (need 4+). Bootstrapping..."

    # Source OS detection (bash 3 compatible)
    # shellcheck disable=SC1091
    source "$DOTS_DIR/scripts/dots/detect-os.sh"

    if [[ "$(get_os)" == "macos" ]]; then
        # Xcode CLT
        if ! xcode-select -p &>/dev/null; then
            echo "🔧 Installing Xcode CLI Tools..."
            xcode-select --install
            echo "⏳ Complete the dialog, then press Enter."
            read -r
        fi

        # Homebrew
        if ! command -v brew &>/dev/null; then
            echo "🍺 Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            if [[ -f "/opt/homebrew/bin/brew" ]]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            elif [[ -f "/usr/local/bin/brew" ]]; then
                eval "$(/usr/local/bin/brew shellenv)"
            fi
        fi

        # Modern bash
        if ! brew list bash &>/dev/null; then
            echo "🐚 Installing modern bash..."
            brew install bash
        fi

        # Re-exec with modern bash
        MODERN_BASH="$(brew --prefix)/bin/bash"
        if [[ -x "$MODERN_BASH" ]]; then
            echo "✅ Re-running with bash 5..."
            exec "$MODERN_BASH" "$0" "$@"
        else
            echo "❌ Failed to install modern bash" >&2
            exit 1
        fi
    else
        echo "❌ bash 4+ required. Install via your package manager." >&2
        exit 1
    fi
fi

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
source "$DOTS_DIR/scripts/dots/detect-os.sh"
# shellcheck disable=SC1091
source "$DOTS_DIR/install/deps/install.sh"

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

# ── Phase 1: Detect OS ──────────────────────────────────────────────────
OS=$(get_os)
echo -e "${GREEN}✓${NC} Detected OS: $OS"

# ── Phase 2: Install dependencies ───────────────────────────────────────
if [[ "$SKIP_DEPS" == false ]]; then
    echo ""
    echo -e "${BLUE}📋 Phase 2: Dependency Installation${NC}"
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}→${NC} [DRY] Would install all required dependencies"
        echo "  Brew: git, zsh, tmux, bob (neovim), fzf, ripgrep, fd, bat, delta, lazygit, eza, zoxide, gum, gh, pass-cli, proton-pass"
        echo "  Non-brew: nvm, bun, claude-code, qmk"
    else
        if ! install_all; then
            echo -e "${RED}❌ Failed to install dependencies${NC}"
            echo "You can skip dependency installation with: ./install.sh --no-deps"
            exit 1
        fi
    fi
else
    echo ""
    echo -e "${YELLOW}⚠️  Skipping dependency installation (--no-deps flag)${NC}"
fi

# ── Phase 3: System Configuration ───────────────────────────────────────
echo ""
echo -e "${BLUE}⚙️  Phase 3: System Configuration${NC}"
if [[ "$DRY_RUN" == true ]]; then
    echo -e "${YELLOW}→${NC} [DRY] Would configure system settings"
    echo "  • Set zsh as default shell"
    echo "  • Check ProtonPass authentication"
else
    if [[ "$SKIP_DEPS" == false ]]; then
        configure_system
    else
        echo -e "${YELLOW}→${NC} Skipping system configuration (dependencies skipped)"
    fi
fi

# ── Phase 4: Dotfiles Setup ─────────────────────────────────────────────
echo ""
echo -e "${BLUE}🔗 Phase 4: Dotfiles Setup${NC}"
if [[ ! -d "$DOTS_DIR/.git" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}→${NC} [DRY] Would initialize git repository"
    else
        echo -e "${YELLOW}→${NC} Initializing git repository..."
        cd "$DOTS_DIR"
        git init
        echo -e "${GREEN}✓${NC} Git repository initialized"
    fi
fi

# Create symlinks
echo -e "${YELLOW}→${NC} Creating symlinks..."
SYMLINK_ARGS=()
[[ "$DRY_RUN" == true ]] && SYMLINK_ARGS+=("--dry-run")
"$DOTS_DIR/scripts/dots/symlinks.sh" "${SYMLINK_ARGS[@]}"

# ── Phase 5: dots Command Setup ─────────────────────────────────────────
if [[ "$DRY_RUN" == true ]]; then
    echo -e "${YELLOW}→${NC} [DRY] Would set up dots command at ~/.local/bin/dots"
    if [[ ! -L "$HOME/.local/bin/dots" ]]; then
        echo -e "  Would create symlink: ~/.local/bin/dots → $DOTS_DIR/common/.local/bin/dots"
    fi
else
    echo -e "${YELLOW}→${NC} Setting up dots command..."
    mkdir -p "$HOME/.local/bin"

    if [[ -L "$HOME/.local/bin/dots" ]]; then
        rm "$HOME/.local/bin/dots"
    fi
    ln -s "$DOTS_DIR/common/.local/bin/dots" "$HOME/.local/bin/dots"
    echo -e "${GREEN}✓${NC} Created dots command at ~/.local/bin/dots"
fi

# ── Phase 6: Make Scripts Executable ─────────────────────────────────────
if [[ "$DRY_RUN" == true ]]; then
    echo -e "${YELLOW}→${NC} [DRY] Would make scripts executable"
    echo "  Would chmod +x: install/*.sh, install/deps/*.sh"
    echo "  Would chmod +x: scripts/*.sh"
    echo "  Would chmod +x: common/.local/bin/*"
else
    echo -e "${YELLOW}→${NC} Making scripts executable..."
    chmod +x "$DOTS_DIR/install/install.sh"
    chmod +x "$DOTS_DIR/install/deps/"*.sh
    chmod +x "$DOTS_DIR/scripts/"*.sh
    find "$DOTS_DIR/common/.local/bin" -type f -exec chmod +x {} \;
    echo -e "${GREEN}✓${NC} All scripts are now executable"
fi

# ── Phase 7: Environment Sync ───────────────────────────────────────────
if [[ "$SKIP_DEPS" == false ]]; then
    echo ""
    echo -e "${BLUE}🔑 Phase 7: Environment Sync${NC}"
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}→${NC} [DRY] Would sync environment variables from ProtonPass"
        echo "  Would run: pp-env-sync"
    else
        if command -v pass-cli &>/dev/null; then
            if pass-cli test &>/dev/null; then
                echo -e "${YELLOW}→${NC} Syncing environment variables from ProtonPass..."
                if "$DOTS_DIR/common/.local/bin/pp-env-sync"; then
                    echo -e "${GREEN}✓${NC} Environment variables synced"
                    # Source the env file for remaining install phases
                    for f in ~/.env ~/.env.*; do [[ -r "$f" ]] && { set -a; source "$f"; set +a; }; done
                else
                    echo -e "${YELLOW}⚠️${NC} Environment sync failed (optional)"
                fi
            else
                echo -e "${YELLOW}⚠️${NC} ProtonPass not authenticated — skipping env sync"
                echo "  Run 'pass-cli login' then 'pp-env-sync' later"
            fi
        else
            echo -e "${YELLOW}⚠️${NC} pass-cli not installed — skipping env sync"
        fi
    fi
fi

# ── Phase 8: Claude Code MCP Setup ──────────────────────────────────────
if [[ "$SKIP_DEPS" == false ]] && command -v claude &>/dev/null; then
    echo ""
    echo -e "${BLUE}🔌 Phase 8: Claude Code MCP Setup${NC}"
    if [[ "$DRY_RUN" == true ]]; then
        "$DOTS_DIR/scripts/claude-mcp.sh" --dry-run
    else
        if [[ -n "${EXA_API_KEY:-}" ]] || [[ -n "${REF_API_KEY:-}" ]]; then
            "$DOTS_DIR/scripts/claude-mcp.sh"
        else
            echo -e "${YELLOW}⚠️${NC} MCP API keys not set in environment"
            echo "  Run 'pp-env-sync' first, then: dots mcp"
        fi
    fi
fi

# ── Phase 9: Music Client ───────────────────────────────────────────────
if [[ "$SKIP_DEPS" == false ]]; then
    echo ""
    echo -e "${BLUE}🎵 Phase 9: Music Client Setup${NC}"
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}→${NC} [DRY] Would install rmpc music client"
        echo "  Would run: cargo install rmpc"
    else
        if command -v cargo &>/dev/null; then
            if ! command -v rmpc &>/dev/null; then
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

# ── Phase 10: Bluetooth Setup (Arch only) ────────────────────────────────
if [[ "$SKIP_DEPS" == false ]] && [[ "$OS" == "arch" ]]; then
    echo ""
    echo -e "${BLUE}🔵 Phase 10: Bluetooth Setup${NC}"
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}→${NC} [DRY] Would enable bluetooth.service"
        echo -e "${YELLOW}→${NC} [DRY] Would start blueman-applet"
    else
        if ! systemctl is-enabled bluetooth &>/dev/null; then
            echo -e "${YELLOW}→${NC} Enabling bluetooth service..."
            sudo systemctl enable --now bluetooth
            echo -e "${GREEN}✓${NC} Bluetooth service enabled"
        else
            echo -e "${GREEN}✓${NC} Bluetooth service already enabled"
        fi

        if command -v blueman-applet &>/dev/null; then
            if ! pgrep -x blueman-applet &>/dev/null; then
                echo -e "${YELLOW}→${NC} Starting blueman-applet..."
                blueman-applet &
                disown
                echo -e "${GREEN}✓${NC} blueman-applet started"
            else
                echo -e "${GREEN}✓${NC} blueman-applet already running"
            fi
        fi
    fi
fi

# ── Phase 11: GitHub Authentication ──────────────────────────────────────
if command -v gh &>/dev/null; then
    echo ""
    echo -e "${BLUE}🔐 Phase 11: GitHub Authentication${NC}"
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}→${NC} [DRY] Would check GitHub authentication status"
    else
        if gh auth status &>/dev/null; then
            echo -e "${GREEN}✓${NC} Already authenticated with GitHub"
        else
            echo "GitHub CLI is not authenticated."
            if command -v gum &>/dev/null; then
                if gum confirm "Run 'gh auth login' to authenticate?"; then
                    gh auth login
                else
                    echo -e "${YELLOW}→${NC} Skipped. Run 'gh auth login' later."
                fi
            else
                echo -n "Run 'gh auth login' to authenticate? (y/N) "
                read -r run_gh_auth
                if [[ "$run_gh_auth" == "y" || "$run_gh_auth" == "Y" ]]; then
                    gh auth login
                else
                    echo -e "${YELLOW}→${NC} Skipped. Run 'gh auth login' later."
                fi
            fi
        fi
    fi
fi

# ── Phase 12: Helm Bootstrap ────────────────────────────────────────────
if [[ "$SKIP_DEPS" == false ]]; then
    HELM_REPO="$HOME/repos/black-atom-industries/helm"
    echo ""
    echo -e "${BLUE}⚓ Phase 12: Helm Bootstrap${NC}"
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}→${NC} [DRY] Would clone and build helm (tmux session manager)"
        echo -e "${YELLOW}→${NC} [DRY] Would offer to run 'helm setup' for repo cloning"
    else
        if command -v helm &>/dev/null; then
            echo -e "${GREEN}✓${NC} helm already installed"
        elif command -v go &>/dev/null; then
            if [[ ! -d "$HELM_REPO" ]]; then
                echo -e "${YELLOW}→${NC} Cloning helm..."
                mkdir -p "$(dirname "$HELM_REPO")"
                git clone git@github.com:black-atom-industries/helm.git "$HELM_REPO"
            fi
            echo -e "${YELLOW}→${NC} Building helm..."
            if (cd "$HELM_REPO" && make install); then
                echo -e "${GREEN}✓${NC} helm installed to ~/.local/bin"
            else
                echo -e "${YELLOW}⚠️${NC} helm build failed (optional)"
            fi
        else
            echo -e "${YELLOW}⚠️${NC} Go not available, skipping helm build"
        fi

        # Offer helm setup for repo cloning
        if command -v helm &>/dev/null; then
            echo ""
            if command -v gum &>/dev/null; then
                if gum confirm "Run 'helm setup' to clone your repositories?"; then
                    helm setup
                else
                    echo -e "${YELLOW}→${NC} Skipped. Run 'helm setup' later."
                fi
            else
                echo -n "Run 'helm setup' to clone your repositories? (y/N) "
                read -r run_helm_setup
                if [[ "$run_helm_setup" == "y" || "$run_helm_setup" == "Y" ]]; then
                    helm setup
                else
                    echo -e "${YELLOW}→${NC} Skipped. Run 'helm setup' later."
                fi
            fi
        fi
    fi
fi

# ── Phase 13: Fonts Setup ───────────────────────────────────────────────
FONTS_REPO="$HOME/repos/nikbrunner/fonts"
if [[ -d "$FONTS_REPO" ]]; then
    echo ""
    echo -e "${BLUE}🔤 Phase 13: Fonts Setup${NC}"
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}→${NC} [DRY] Would install fonts from $FONTS_REPO"
        echo -e "${YELLOW}→${NC} [DRY] Would symlink pick-font to ~/.local/bin"
    else
        if [[ -x "$FONTS_REPO/install.sh" ]]; then
            "$FONTS_REPO/install.sh"
        fi
        if [[ -x "$FONTS_REPO/pick-font" ]]; then
            mkdir -p "$HOME/.local/bin"
            ln -sf "$FONTS_REPO/pick-font" "$HOME/.local/bin/pick-font"
            echo -e "${GREEN}✓${NC} pick-font symlinked to ~/.local/bin"
        fi
    fi
fi

# ── Phase 14: Zoxide Seed ───────────────────────────────────────────────
if command -v zoxide &>/dev/null; then
    ZOXIDE_SEED="$DOTS_DIR/common/.config/zoxide/seed.txt"
    if [[ -f "$ZOXIDE_SEED" ]]; then
        echo ""
        echo -e "${BLUE}📂 Phase 14: Zoxide Seed${NC}"
        if [[ "$DRY_RUN" == true ]]; then
            echo -e "${YELLOW}→${NC} [DRY] Would seed zoxide with base paths from seed.txt"
        else
            count=0
            while IFS= read -r line; do
                [[ -z "$line" || "$line" == \#* ]] && continue
                expanded="${line/#\~/$HOME}"
                # shellcheck disable=SC2086
                for path in $expanded; do
                    [[ -d "$path" ]] && zoxide add "$path" 2>/dev/null && ((count++)) || true
                done
            done <"$ZOXIDE_SEED"
            echo -e "${GREEN}✓${NC} Seeded zoxide with $count paths"
        fi
    fi
fi

# ── Phase 15: Validation ────────────────────────────────────────────────
if [[ "$SKIP_DEPS" == false ]] && [[ "$DRY_RUN" == false ]]; then
    echo ""
    echo -e "${BLUE}🧪 Phase 15: Validation${NC}"
    if validate_dependencies; then
        echo -e "${GREEN}✓${NC} Testing dots command..."
        if command -v dots &>/dev/null; then
            echo -e "${GREEN}✓${NC} dots command functional"
        else
            echo -e "${YELLOW}⚠️${NC} dots command not in PATH — reload shell"
        fi
    fi
fi

# ── Complete ─────────────────────────────────────────────────────────────
echo ""
if [[ "$DRY_RUN" == true ]]; then
    echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║    Dry Run Complete!                 ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
    echo ""
    echo "This was a dry run. No changes were made."
    echo "Run without --dry-run to perform the actual installation."
else
    echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   Machine Setup Complete!            ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
    echo ""
    if [[ "$SKIP_DEPS" == false ]]; then
        echo "Your development environment is ready:"
        echo "  • Shell: zsh with custom configuration"
        echo "  • Editor: neovim (via bob)"
        echo "  • Tools: fzf, ripgrep, tmux, lazygit, gh, helm"
        echo "  • Dotfiles: managed via 'dots' command"
        echo ""
    fi
fi

echo "Next steps:"
if [[ "$SKIP_DEPS" == false ]]; then
    echo "1. Reload your shell: source ~/.zshrc"
    echo "2. Test with: dots status"
    echo "3. Verify SSH: ssh -T git@github.com"
else
    echo "1. Install dependencies manually or run: ./install.sh (without --no-deps)"
    echo "2. Ensure ~/.local/bin is in your PATH"
    echo "3. Reload your shell: source ~/.zshrc"
fi
echo ""
