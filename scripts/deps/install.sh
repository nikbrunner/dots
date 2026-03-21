#!/usr/bin/env bash
# Dependency installation dispatcher
# Detects OS and delegates to the appropriate OS-specific script

set -eo pipefail

DOTS_DIR="${DOTS_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
source "$DOTS_DIR/scripts/dots/detect-os.sh"

OS=$(get_os)

case "$OS" in
macos) source "$DOTS_DIR/scripts/deps/macos.sh" ;;
arch) source "$DOTS_DIR/scripts/deps/arch.sh" ;;
*)
    echo "❌ Unsupported OS: $OS"
    exit 1
    ;;
esac

NPM_GLOBALS_FILE="$DOTS_DIR/scripts/deps/npm-globals.txt"

# Read npm global packages from file (skips empty lines and comments)
_read_npm_globals() {
    [[ -f "$NPM_GLOBALS_FILE" ]] || return
    grep -v '^\s*#' "$NPM_GLOBALS_FILE" | grep -v '^\s*$'
}

# Parse a line from npm-globals.txt into pkg and cmd
# Format: "package-name" or "package-name:command-name"
_parse_npm_entry() {
    local entry="$1"
    NPM_PKG="${entry%%:*}"
    if [[ "$entry" == *:* ]]; then
        NPM_CMD="${entry#*:}"
    else
        NPM_CMD="${entry##*/}"
    fi
}

# Check which npm globals are installed
check_npm_globals() {
    local entry
    while IFS= read -r entry; do
        _parse_npm_entry "$entry"
        if command -v "$NPM_CMD" &>/dev/null; then
            echo "  $NPM_PKG: installed"
        else
            echo "  $NPM_PKG: missing"
        fi
    done < <(_read_npm_globals)
}

# Install missing npm globals
install_npm_globals() {
    if ! command -v npm &>/dev/null; then
        echo "npm not available — skipping npm globals"
        return
    fi

    local entry missing=()
    while IFS= read -r entry; do
        _parse_npm_entry "$entry"
        if ! command -v "$NPM_CMD" &>/dev/null; then
            missing+=("$NPM_PKG")
        fi
    done < <(_read_npm_globals)

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "Installing npm globals: ${missing[*]}"
        npm install -g "${missing[@]}"
    fi
}

# Upgrade all npm globals from the list
upgrade_npm_globals() {
    if ! command -v npm &>/dev/null; then
        echo "npm not available — skipping npm globals"
        return
    fi

    local entry pkgs=()
    while IFS= read -r entry; do
        _parse_npm_entry "$entry"
        pkgs+=("$NPM_PKG")
    done < <(_read_npm_globals)

    if [[ ${#pkgs[@]} -gt 0 ]]; then
        echo "Upgrading npm globals: ${pkgs[*]}"
        npm install -g "${pkgs[@]}"
    fi
}

# Configure system settings (shared across OSes)
configure_system() {
    echo ""
    echo "⚙️  Configuring system settings..."

    # Set zsh as default shell
    local current_shell zsh_path
    if command -v getent &>/dev/null; then
        current_shell=$(getent passwd "$USER" | cut -d: -f7)
    else
        # macOS doesn't have getent
        current_shell=$(dscl . -read "/Users/$USER" UserShell | awk '{print $2}')
    fi
    zsh_path=$(which zsh)

    if [[ "$(basename "$current_shell")" == "zsh" ]]; then
        echo "✅ zsh already default shell ($current_shell)"
    else
        echo "🐚 Setting zsh as default shell..."
        if [[ "$OS" == "macos" ]]; then
            chsh -s "$zsh_path" && echo "✅ Shell changed to zsh" || echo "❌ Failed - run: chsh -s $zsh_path"
        else
            sudo usermod -s "$zsh_path" "$USER" && echo "✅ Shell changed to zsh" || echo "❌ Failed - run: sudo usermod -s $zsh_path $USER"
        fi
    fi

    # Git SSH signing is configured via platform-specific .gitconfig.local files
    # (macos/.gitconfig.local and arch/.gitconfig.local), not at install time.
    # Verify the signing binary exists:
    local op_ssh_sign_path=""
    if command -v op-ssh-sign &>/dev/null; then
        op_ssh_sign_path=$(which op-ssh-sign)
    elif [[ -x "/opt/1Password/op-ssh-sign" ]]; then
        op_ssh_sign_path="/opt/1Password/op-ssh-sign"
    elif [[ -x "/Applications/1Password.app/Contents/MacOS/op-ssh-sign" ]]; then
        op_ssh_sign_path="/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
    fi

    if [[ -n "$op_ssh_sign_path" ]]; then
        echo "✅ 1Password SSH signing available ($op_ssh_sign_path)"
    else
        echo "⚠️  1Password SSH signing not found"
    fi

    # Install TPM (Tmux Plugin Manager)
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        echo "🔌 Installing TPM..."
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm" 2>/dev/null &&
            echo "✅ TPM installed" || echo "⚠️  TPM install failed"
    else
        echo "✅ TPM already installed"
    fi

    # Configure Docker (Linux only - macOS uses Docker Desktop)
    if [[ "$OS" != "macos" ]] && command -v docker &>/dev/null; then
        if ! groups "$USER" | grep -q '\bdocker\b'; then
            echo "🐳 Adding $USER to docker group..."
            sudo usermod -aG docker "$USER"
            echo "✅ Added to docker group (logout required)"
        fi
        if command -v systemctl &>/dev/null; then
            if ! systemctl is-enabled docker &>/dev/null; then
                sudo systemctl enable --now docker
                echo "✅ Docker service enabled"
            fi
        fi
    fi

    echo "✅ System configuration complete!"
}

# Validate all dependencies (returns exit code)
validate_dependencies() {
    echo "Validating installation..."

    # Check nvm
    if ! [[ -d "$HOME/.nvm" ]] && ! [[ -d "${XDG_CONFIG_HOME:-$HOME/.config}/nvm" ]]; then
        echo "nvm: missing"
    else
        echo "nvm: installed"
    fi

    # Check qmk
    if command -v qmk &>/dev/null; then
        echo "qmk: installed"
    else
        echo "qmk: missing"
    fi

    # Check brew bundle
    if brew bundle check --file="$DOTS_DIR/scripts/deps/Brewfile" &>/dev/null; then
        echo "All brew packages installed!"
        return 0
    else
        echo "Some brew packages missing"
        brew bundle check --file="$DOTS_DIR/scripts/deps/Brewfile"
        return 1
    fi
}

# Run subcommand if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-install}" in
    check)
        check_all || true
        echo ""
        echo "npm globals:"
        check_npm_globals
        ;;
    install) install_all && install_npm_globals ;;
    upgrade) upgrade_all && upgrade_npm_globals ;;
    list)
        echo "nvm"
        echo "qmk"
        grep -E '^(brew|cask)' "$DOTS_DIR/scripts/deps/Brewfile" | sed 's/.*"\(.*\)".*/\1/'
        echo ""
        echo "npm globals:"
        while IFS= read -r entry; do
            _parse_npm_entry "$entry"
            echo "$NPM_PKG"
        done < <(_read_npm_globals)
        ;;
    configure) configure_system ;;
    validate) validate_dependencies ;;
    *)
        echo "Usage: $0 [check|install|upgrade|list|configure|validate]"
        exit 1
        ;;
    esac
fi
