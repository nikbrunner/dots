#!/usr/bin/env bash
# Arch Linux dependencies - pacman/paru packages

# Package list - actual pacman/AUR package names
DEPS=(
    # Core tools
    git
    zsh
    tmux
    neovim
    fzf
    ripgrep
    fd
    bat
    git-delta
    lazygit
    eza
    yazi
    zoxide
    gum
    github-cli
    luarocks
    paru

    # Shell enhancements
    zsh-autosuggestions
    zsh-syntax-highlighting
    atuin

    # Media tools
    gallery-dl
    yt-dlp
    ffmpeg
    python-eyed3
    mpd
    mpc

    # Data processing
    go-yq
    jq

    # Languages & runtimes
    rust
    go
    golangci-lint-bin
    deno
    uv

    # AI & dev tools
    av-cli-bin

    # Desktop apps
    1password
    claude-desktop-native
    signal-desktop
    slack-desktop
    zapzap
    docker
    zed-preview-bin
    obsidian
    helium-browser-bin

    # Bluetooth
    bluez
    bluez-utils
    bluetui

    # Wayland/Niri desktop
    swww
    chafa
    niri
    waybar
    fuzzel
    satty
    clipse
    wtype

    # Gaming
    gamemode
    lib32-gamemode
)

# Check if a dependency is installed
check_dep() {
    local dep="$1"
    case "$dep" in
    # Command differs from package name
    neovim) command -v nvim &>/dev/null ;;
    ripgrep) command -v rg &>/dev/null ;;
    git-delta) command -v delta &>/dev/null ;;
    github-cli) command -v gh &>/dev/null ;;
    rust) command -v cargo &>/dev/null ;;
    python-eyed3) command -v eyeD3 &>/dev/null ;;
    go-yq) command -v yq &>/dev/null ;;
    golangci-lint-bin) command -v golangci-lint &>/dev/null ;;
    beads-bin) command -v bd &>/dev/null ;;
    av-cli-bin) command -v av &>/dev/null ;;
    zed-preview-bin) command -v zeditor &>/dev/null ;;
    helium-browser-bin) command -v helium-browser &>/dev/null ;;
    gamemode) command -v gamemoded &>/dev/null ;;
    zapzap) command -v zapzap &>/dev/null ;;

    # Desktop apps - check via pacman
    1password | claude-desktop-native | signal-desktop | slack-desktop | obsidian)
        pacman -Qi "$dep" &>/dev/null
        ;;

    # Packages without commands - check via pacman
    bluez | bluez-utils | lib32-gamemode | zsh-autosuggestions | zsh-syntax-highlighting)
        pacman -Qi "$dep" &>/dev/null
        ;;

    # Default: command name matches package name
    *) command -v "$dep" &>/dev/null ;;
    esac
}

# Get the package manager (paru > yay > pacman)
get_pkg_manager() {
    if command -v paru &>/dev/null; then
        echo "paru"
    elif command -v yay &>/dev/null; then
        echo "yay"
    else
        echo "pacman"
    fi
}

# Install a single dependency
install_dep() {
    local dep="$1"
    local pkg_manager
    pkg_manager=$(get_pkg_manager)

    echo "📦 Installing $dep..."

    if [[ "$pkg_manager" == "pacman" ]]; then
        sudo pacman -S --needed --noconfirm "$dep"
    else
        "$pkg_manager" -S --needed --noconfirm "$dep"
    fi

    # Post-install hooks
    case "$dep" in
    bluez)
        # Enable bluetooth service
        if ! systemctl is-enabled bluetooth &>/dev/null; then
            echo "🔵 Enabling bluetooth service..."
            sudo systemctl enable --now bluetooth
            echo "✅ Bluetooth service enabled"
        fi
        ;;
    docker)
        # Add user to docker group
        if ! groups "$USER" | grep -q '\bdocker\b'; then
            echo "🐳 Adding $USER to docker group..."
            sudo usermod -aG docker "$USER"
            echo "✅ Added to docker group (logout required)"
        fi
        # Enable docker service
        if ! systemctl is-enabled docker &>/dev/null; then
            echo "🐳 Enabling docker service..."
            sudo systemctl enable --now docker
            echo "✅ Docker service enabled"
        elif ! systemctl is-active docker &>/dev/null; then
            sudo systemctl start docker
        fi
        ;;
    esac
}

# Check all dependencies and show status
check_all() {
    echo "📋 Checking dependencies..."
    echo ""

    local missing=()
    for dep in "${DEPS[@]}"; do
        if check_dep "$dep"; then
            echo "  ✅ $dep"
        else
            echo "  ❌ $dep"
            missing+=("$dep")
        fi
    done

    # Check nvm separately (special install)
    if [[ -d "$HOME/.nvm" ]] || [[ -d "${XDG_CONFIG_HOME:-$HOME/.config}/nvm" ]]; then
        echo "  ✅ nvm"
    else
        echo "  ❌ nvm"
        missing+=("nvm")
    fi

    # Check claude-code separately (native install)
    if command -v claude &>/dev/null; then
        echo "  ✅ claude-code"
    else
        echo "  ❌ claude-code"
        missing+=("claude-code")
    fi

    # Check peon-ping separately (curl install)
    if command -v peon-ping &>/dev/null; then
        echo "  ✅ peon-ping"
    else
        echo "  ❌ peon-ping"
        missing+=("peon-ping")
    fi

    echo ""
    if [[ ${#missing[@]} -eq 0 ]]; then
        echo "✅ All dependencies installed!"
        return 0
    else
        echo "❌ Missing: ${#missing[@]} dependencies"
        return 1
    fi
}

# Install nvm via curl script
install_nvm() {
    echo "📦 Installing nvm..."
    if command -v curl &>/dev/null; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

        # Source nvm
        export NVM_DIR="${XDG_CONFIG_HOME:-$HOME}/.nvm"
        [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
        [[ -s "$HOME/.nvm/nvm.sh" ]] && \. "$HOME/.nvm/nvm.sh"

        # Install Node LTS
        if command -v nvm &>/dev/null; then
            echo "📦 Installing Node.js LTS..."
            nvm install --lts
            nvm use --lts
            nvm alias default lts/*
        fi
        echo "✅ nvm installed"
    else
        echo "❌ curl not available"
        return 1
    fi
}

# Install Claude Code via native installer (auto-updates)
install_claude_code() {
    echo "📦 Installing Claude Code..."
    if command -v curl &>/dev/null; then
        curl -fsSL https://claude.ai/install.sh | bash
        echo "✅ Claude Code installed"
    else
        echo "❌ curl not available"
        return 1
    fi
}

# Install peon-ping via curl script
install_peon_ping() {
    echo "📦 Installing peon-ping..."
    if command -v curl &>/dev/null; then
        curl -fsSL https://raw.githubusercontent.com/PeonPing/peon-ping/main/install.sh | bash
        echo "✅ peon-ping installed"
    else
        echo "❌ curl not available"
        return 1
    fi
}

# Install all missing dependencies
install_all() {
    local pkg_manager
    pkg_manager=$(get_pkg_manager)

    echo "🔍 Checking dependencies..."
    echo "📦 Package manager: $pkg_manager"
    echo ""

    # Collect missing deps
    local missing=()
    for dep in "${DEPS[@]}"; do
        if check_dep "$dep"; then
            echo "  ✅ $dep"
        else
            echo "  ❌ $dep"
            missing+=("$dep")
        fi
    done

    # Check nvm
    local nvm_missing=false
    if [[ -d "$HOME/.nvm" ]] || [[ -d "${XDG_CONFIG_HOME:-$HOME/.config}/nvm" ]]; then
        echo "  ✅ nvm"
    else
        echo "  ❌ nvm"
        nvm_missing=true
    fi

    # Check claude-code (native install, not pacman)
    local claude_missing=false
    if command -v claude &>/dev/null; then
        echo "  ✅ claude-code"
    else
        echo "  ❌ claude-code"
        claude_missing=true
    fi

    # Check peon-ping (curl install, not pacman)
    local peon_ping_missing=false
    if command -v peon-ping &>/dev/null; then
        echo "  ✅ peon-ping"
    else
        echo "  ❌ peon-ping"
        peon_ping_missing=true
    fi

    # Install missing
    if [[ ${#missing[@]} -gt 0 ]] || [[ "$nvm_missing" == true ]] || [[ "$claude_missing" == true ]] || [[ "$peon_ping_missing" == true ]]; then
        echo ""
        echo "🚀 Installing missing dependencies..."

        for dep in "${missing[@]}"; do
            install_dep "$dep"
        done

        if [[ "$nvm_missing" == true ]]; then
            install_nvm
        fi

        if [[ "$claude_missing" == true ]]; then
            install_claude_code
        fi

        if [[ "$peon_ping_missing" == true ]]; then
            install_peon_ping
        fi

        echo ""
        echo "✅ Installation complete!"
    else
        echo ""
        echo "✅ All dependencies already installed!"
    fi
}
