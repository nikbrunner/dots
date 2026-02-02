#!/usr/bin/env bash
# Dependency installation dispatcher
# Detects OS and delegates to the appropriate OS-specific script

set -eo pipefail

DEPS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DEPS_DIR/../detect-os.sh"

OS=$(get_os)

case "$OS" in
macos) source "$DEPS_DIR/macos.sh" ;;
arch) source "$DEPS_DIR/arch.sh" ;;
*)
    echo "❌ Unsupported OS: $OS"
    exit 1
    ;;
esac

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

    if [[ "$current_shell" != "$zsh_path" ]]; then
        echo "🐚 Setting zsh as default shell..."
        if [[ "$OS" == "macos" ]]; then
            chsh -s "$zsh_path" && echo "✅ Shell changed to zsh" || echo "❌ Failed - run: chsh -s $zsh_path"
        else
            sudo usermod -s "$zsh_path" "$USER" && echo "✅ Shell changed to zsh" || echo "❌ Failed - run: sudo usermod -s $zsh_path $USER"
        fi
    else
        echo "✅ zsh already default shell"
    fi

    # Configure Git signing with 1Password
    local op_ssh_sign_path=""
    if command -v op-ssh-sign &>/dev/null; then
        op_ssh_sign_path=$(which op-ssh-sign)
    elif [[ -x "/opt/1Password/op-ssh-sign" ]]; then
        op_ssh_sign_path="/opt/1Password/op-ssh-sign"
    elif [[ -x "/Applications/1Password.app/Contents/MacOS/op-ssh-sign" ]]; then
        op_ssh_sign_path="/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
    fi

    if [[ -n "$op_ssh_sign_path" ]]; then
        echo "🔑 Configuring Git SSH signing..."
        git config --global gpg.ssh.program "$op_ssh_sign_path"
        echo "✅ Git signing configured"
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

    # Check brew bundle
    if brew bundle check --file="$DEPS_DIR/Brewfile" &>/dev/null; then
        echo "All brew packages installed!"
        return 0
    else
        echo "Some brew packages missing"
        brew bundle check --file="$DEPS_DIR/Brewfile"
        return 1
    fi
}

# Run subcommand if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-install}" in
    check) check_all ;;
    install) install_all ;;
    list)
        echo "nvm"
        grep -E '^(brew|cask)' "$DEPS_DIR/Brewfile" | sed 's/.*"\(.*\)".*/\1/'
        ;;
    configure) configure_system ;;
    validate) validate_dependencies ;;
    *)
        echo "Usage: $0 [check|install|list|configure|validate]"
        exit 1
        ;;
    esac
fi
