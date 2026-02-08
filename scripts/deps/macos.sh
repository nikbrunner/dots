#!/usr/bin/env bash
# macOS dependencies

DEPS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install nvm via curl script
install_nvm() {
    echo "Installing nvm..."
    if command -v curl &>/dev/null; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

        # Source nvm
        export NVM_DIR="${XDG_CONFIG_HOME:-$HOME}/.nvm"
        [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
        [[ -s "$HOME/.nvm/nvm.sh" ]] && \. "$HOME/.nvm/nvm.sh"

        # Install Node LTS
        if command -v nvm &>/dev/null; then
            echo "Installing Node.js LTS..."
            nvm install --lts
            nvm use --lts
            nvm alias default lts/*
        fi
    else
        echo "curl not available"
        return 1
    fi
}

# Install Claude Code via native installer (auto-updates)
install_claude_code() {
    echo "Installing Claude Code..."
    if command -v curl &>/dev/null; then
        curl -fsSL https://claude.ai/install.sh | bash
    else
        echo "curl not available"
        return 1
    fi
}

# Install QMK via official installer
install_qmk() {
    echo "Installing QMK..."
    if command -v curl &>/dev/null; then
        curl -fsSL https://install.qmk.fm | sh
    else
        echo "curl not available"
        return 1
    fi
}

# Check all dependencies
check_all() {
    echo "Checking dependencies..."
    echo ""

    # Check nvm
    if [[ -d "$HOME/.nvm" ]] || [[ -d "${XDG_CONFIG_HOME:-$HOME/.config}/nvm" ]]; then
        echo "  nvm: installed"
    else
        echo "  nvm: missing"
    fi

    # Check qmk
    if command -v qmk &>/dev/null; then
        echo "  qmk: installed"
    else
        echo "  qmk: missing"
    fi

    echo ""
    echo "Brew packages:"
    brew bundle check --file="$DEPS_DIR/Brewfile" --verbose
}

# Install all missing dependencies
install_all() {
    # Check brew is available
    if ! command -v brew &>/dev/null; then
        echo "Homebrew not found. Install from https://brew.sh"
        exit 1
    fi

    # Non-brew dependencies first
    echo "Checking non-brew dependencies..."
    if [[ -d "$HOME/.nvm" ]] || [[ -d "${XDG_CONFIG_HOME:-$HOME/.config}/nvm" ]]; then
        echo "  nvm: installed"
    else
        echo "  nvm: missing"
        install_nvm
    fi

    if command -v claude &>/dev/null; then
        echo "  claude-code: installed"
    else
        echo "  claude-code: missing"
        install_claude_code
    fi

    if command -v qmk &>/dev/null; then
        echo "  qmk: installed"
    else
        echo "  qmk: missing"
        install_qmk
    fi

    echo ""
    echo "Installing brew packages..."
    brew bundle install --file="$DEPS_DIR/Brewfile"

    echo ""
    echo "Done!"
}
