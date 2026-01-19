#!/usr/bin/env bash
# macOS dependencies - Homebrew packages

# Package list - actual brew package names
# Format: "package" or "--cask package" for casks
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
    gh
    luarocks

    # Shell enhancements
    zsh-autosuggestions
    zsh-syntax-highlighting
    atuin

    # Media tools
    gallery-dl
    yt-dlp
    ffmpeg
    eyed3
    mpd
    mpc

    # Data processing
    yq
    jq

    # Languages & runtimes
    rust
    go
    deno

    # AI & dev tools
    claude-code
    "aviator-co/tap/av"

    # Cask apps
    "--cask 1password"
    "--cask claude"
    "--cask signal"
    "--cask slack"
    "--cask whatsapp"
    "--cask docker"
    "--cask zed@preview"
    "--cask obsidian"
    "--cask helium-browser"
)

# Check if a dependency is installed
check_dep() {
    local dep="$1"
    case "$dep" in
    # Command differs from package name
    neovim) command -v nvim &>/dev/null ;;
    ripgrep) command -v rg &>/dev/null ;;
    git-delta) command -v delta &>/dev/null ;;
    rust) command -v cargo &>/dev/null ;;
    claude-code) command -v claude &>/dev/null ;;
    eyed3) command -v eyeD3 &>/dev/null ;;

    # Tap packages
    "steveyegge/beads/bd") command -v bd &>/dev/null ;;
    "aviator-co/tap/av") command -v av &>/dev/null ;;

    # Cask apps - check Applications folder
    "--cask 1password") [[ -d "/Applications/1Password.app" ]] ;;
    "--cask claude") [[ -d "/Applications/Claude.app" ]] ;;
    "--cask signal") [[ -d "/Applications/Signal.app" ]] ;;
    "--cask slack") [[ -d "/Applications/Slack.app" ]] ;;
    "--cask whatsapp") [[ -d "/Applications/WhatsApp.app" ]] ;;
    "--cask docker") [[ -d "/Applications/Docker.app" ]] ;;
    "--cask zed@preview") command -v zed &>/dev/null ;;
    "--cask obsidian") [[ -d "/Applications/Obsidian.app" ]] ;;
    "--cask helium-browser") [[ -d "/Applications/Helium.app" ]] ;;

    # Shell plugins - check via brew
    zsh-autosuggestions | zsh-syntax-highlighting)
        brew list "$dep" &>/dev/null
        ;;

    # Default: command name matches package name
    *) command -v "$dep" &>/dev/null ;;
    esac
}

# Get display name for a package
get_display_name() {
    local dep="$1"
    # Strip --cask prefix for display
    echo "${dep#--cask }"
}

# Install a single dependency
install_dep() {
    local dep="$1"
    echo "📦 Installing $(get_display_name "$dep")..."

    if [[ "$dep" == --cask* ]]; then
        brew install $dep
    else
        brew install "$dep"
    fi
}

# Check all dependencies and show status
check_all() {
    echo "📋 Checking dependencies..."
    echo ""

    local missing=()
    for dep in "${DEPS[@]}"; do
        if check_dep "$dep"; then
            echo "  ✅ $(get_display_name "$dep")"
        else
            echo "  ❌ $(get_display_name "$dep")"
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

    echo ""
    if [[ ${#missing[@]} -eq 0 ]]; then
        echo "✅ All dependencies installed!"
    else
        echo "❌ Missing: ${#missing[@]} dependencies"
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

# Install all missing dependencies
install_all() {
    echo "🔍 Checking dependencies..."
    echo "📦 Package manager: brew"
    echo ""

    # Check brew is available
    if ! command -v brew &>/dev/null; then
        echo "❌ Homebrew not found. Install from https://brew.sh"
        exit 1
    fi

    # Collect missing deps
    local missing=()
    for dep in "${DEPS[@]}"; do
        if check_dep "$dep"; then
            echo "  ✅ $(get_display_name "$dep")"
        else
            echo "  ❌ $(get_display_name "$dep")"
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

    # Install missing
    if [[ ${#missing[@]} -gt 0 ]] || [[ "$nvm_missing" == true ]]; then
        echo ""
        echo "🚀 Installing missing dependencies..."

        for dep in "${missing[@]}"; do
            install_dep "$dep"
        done

        if [[ "$nvm_missing" == true ]]; then
            install_nvm
        fi

        echo ""
        echo "✅ Installation complete!"
    else
        echo ""
        echo "✅ All dependencies already installed!"
    fi
}
