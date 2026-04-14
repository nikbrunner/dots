#!/usr/bin/env bash
# macOS dependencies

: "${DOTS_DIR:?DOTS_DIR must be set before sourcing macos.sh}"

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

# Install Bun via official installer
install_bun() {
    echo "Installing bun..."
    if command -v curl &>/dev/null; then
        curl -fsSL https://bun.sh/install | bash
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

# Install Readwise CLI via npm
install_readwise_cli() {
    echo "Installing Readwise CLI..."
    if command -v npm &>/dev/null; then
        npm install -g @readwise/cli
    else
        echo "npm not available — install Node.js first"
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

    # Check bun
    if command -v bun &>/dev/null; then
        echo "  bun: installed"
    else
        echo "  bun: missing"
    fi

    # Check qmk
    if command -v qmk &>/dev/null; then
        echo "  qmk: installed"
    else
        echo "  qmk: missing"
    fi

    # Check readwise-cli
    if command -v readwise &>/dev/null; then
        echo "  readwise-cli: installed"
    else
        echo "  readwise-cli: missing"
    fi

    echo ""
    echo "Brew packages:"
    brew bundle check --file="$DOTS_DIR/install/deps/Brewfile" --verbose
}

# Ensure Xcode CLI Tools are installed
ensure_xcode_clt() {
    if xcode-select -p &>/dev/null; then
        echo "✅ Xcode CLI Tools already installed"
    else
        echo "🔧 Installing Xcode CLI Tools..."
        xcode-select --install
        echo "⏳ Waiting for Xcode CLI Tools installation..."
        echo "   Complete the installation dialog, then press Enter."
        read -r
    fi
}

# Ensure Homebrew is installed
ensure_homebrew() {
    if command -v brew &>/dev/null; then
        echo "✅ Homebrew already installed"
    else
        echo "🍺 Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add brew to PATH for this session (Apple Silicon vs Intel)
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi

        if ! command -v brew &>/dev/null; then
            echo "❌ Homebrew installation failed"
            exit 1
        fi
        echo "✅ Homebrew installed"
    fi
}

# Install all missing dependencies
install_all() {
    # Bootstrap: Xcode CLT + Homebrew
    ensure_xcode_clt
    ensure_homebrew

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

    if command -v bun &>/dev/null; then
        echo "  bun: installed"
    else
        echo "  bun: missing"
        install_bun
    fi

    if command -v qmk &>/dev/null; then
        echo "  qmk: installed"
    else
        echo "  qmk: missing"
        install_qmk
    fi

    if command -v readwise &>/dev/null; then
        echo "  readwise-cli: installed"
    else
        echo "  readwise-cli: missing"
        install_readwise_cli
    fi

    echo ""
    echo "Installing brew packages..."
    brew bundle install --no-upgrade --file="$DOTS_DIR/install/deps/Brewfile"

    echo ""
    echo "Done!"
}

# Upgrade all brew packages
upgrade_all() {
    if ! command -v brew &>/dev/null; then
        echo "Homebrew not found. Install from https://brew.sh"
        exit 1
    fi

    echo "Upgrading brew packages..."
    brew bundle install --file="$DOTS_DIR/install/deps/Brewfile"

    echo ""
    echo "Done!"
}
