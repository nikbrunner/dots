#!/usr/bin/env bash
# Shared dependency management library

set -eo pipefail

# All required dependencies
declare -a REQUIRED_DEPS=(
    "git:Git version control"
    "zsh:Z shell"
    "tmux:Terminal multiplexer"
    "neovim:Text editor"
    "fzf:Fuzzy finder"
    "ripgrep:Fast text search"
    "fd:Fast file finder"
    "bat:Syntax highlighting for files"
    "delta:Enhanced git diff"
    "lazygit:Interactive git interface"
    "eza:Modern ls replacement"
    "zoxide:Smart directory jumper"
    "gum:Enhanced CLI prompts"
    "gh:GitHub CLI"
    "1password:Password manager"
    "zsh-autosuggestions:Fish-like autosuggestions for zsh"
    "zsh-syntax-highlighting:Syntax highlighting for zsh"
    "oh-my-posh:Cross-platform prompt theme engine"
    "gallery-dl:Command-line program to download image galleries"
    "yt-dlp:YouTube downloader with extended features"
    "ffmpeg:Media conversion and processing"
    "eyeD3:MP3 ID3 tag editor"
    "mpd:Music Player Daemon"
    "mpc:Music Player Daemon client"
    "atuin:Magical shell history"
    "yq:YAML processor"
    "rust:Rust programming language and Cargo"
    "go:Go programming language"
    "claude-code:AI coding assistant CLI"
    "claude-desktop:Claude desktop application"
    "signal:Signal private messenger"
    "slack:Slack messaging"
    "whatsapp:WhatsApp messaging"
    "nvm:Node Version Manager"
    "docker:Container platform"
    "av:Aviator CLI for stacked PRs"
    "paru:AUR helper (Arch only)"
    "zed-preview:Zed editor preview build"
)

# Detect operating system
detect_os() {
    case "$(uname -s)" in
    Darwin)
        echo "macos"
        ;;
    Linux)
        if [[ -f /etc/arch-release ]] || command -v pacman &>/dev/null; then
            echo "arch"
        else
            echo "linux"
        fi
        ;;
    *)
        echo "unknown"
        ;;
    esac
}

# Check if a package is installed using package manager
check_package_installed() {
    local package="$1"
    local os
    local pkg_manager

    os=$(detect_os)
    pkg_manager=$(get_package_manager)

    case "$os" in
    macos)
        if [[ "$pkg_manager" == "brew" ]]; then
            # For cask packages, check differently
            local package_name
            package_name=$(get_package_name "$package")
            if [[ "$package_name" == --cask* ]]; then
                # Extract package name from --cask flag
                local cask_name="${package_name#--cask }"
                brew list --cask "$cask_name" &>/dev/null
            else
                brew list "$package_name" &>/dev/null
            fi
        else
            return 1
        fi
        ;;
    arch)
        # pacman tracks all installed packages regardless of installation method
        local package_name
        package_name=$(get_package_name "$package")
        pacman -Qi "$package_name" &>/dev/null
        ;;
    *)
        return 1
        ;;
    esac
}

# Check if a dependency exists
check_dependency() {
    local dep="$1"
    case "$dep" in
    neovim)
        command -v nvim &>/dev/null
        ;;
    ripgrep)
        command -v rg &>/dev/null
        ;;
    zsh-autosuggestions)
        # Use package manager to check if installed
        check_package_installed "zsh-autosuggestions"
        ;;
    zsh-syntax-highlighting)
        # Use package manager to check if installed
        check_package_installed "zsh-syntax-highlighting"
        ;;
    1password)
        # Use package manager to check if installed
        check_package_installed "1password"
        ;;
    paru)
        command -v paru &>/dev/null
        ;;
    zed-preview)
        command -v zed &>/dev/null
        ;;
    gallery-dl)
        command -v gallery-dl &>/dev/null
        ;;
    rust)
        command -v cargo &>/dev/null
        ;;
    claude-code)
        command -v claude &>/dev/null
        ;;
    claude-desktop)
        # Check for app on macOS or package on Linux
        if [[ "$(uname)" == "Darwin" ]]; then
            [[ -d "/Applications/Claude.app" ]]
        else
            check_package_installed "claude-desktop-native"
        fi
        ;;
    signal)
        # Check for app on macOS or package on Linux
        if [[ "$(uname)" == "Darwin" ]]; then
            [[ -d "/Applications/Signal.app" ]]
        else
            check_package_installed "signal-desktop"
        fi
        ;;
    slack)
        # Check for app on macOS or package on Linux
        if [[ "$(uname)" == "Darwin" ]]; then
            [[ -d "/Applications/Slack.app" ]]
        else
            check_package_installed "slack-desktop"
        fi
        ;;
    whatsapp)
        # Check for app on macOS or package on Linux
        if [[ "$(uname)" == "Darwin" ]]; then
            [[ -d "/Applications/WhatsApp.app" ]]
        else
            check_package_installed "zapzap"
        fi
        ;;
    nvm)
        # NVM is installed to ~/.nvm
        [[ -d "$HOME/.nvm" ]] || [[ -d "${XDG_CONFIG_HOME:-$HOME/.config}/nvm" ]]
        ;;
    *)
        command -v "$dep" &>/dev/null
        ;;
    esac
}

# Get package manager for current OS
get_package_manager() {
    local os
    os=$(detect_os)

    case "$os" in
    macos)
        if command -v brew &>/dev/null; then
            echo "brew"
        else
            echo ""
        fi
        ;;
    arch)
        if command -v paru &>/dev/null; then
            echo "paru"
        elif command -v yay &>/dev/null; then
            echo "yay"
        elif command -v pacman &>/dev/null; then
            echo "pacman"
        else
            echo ""
        fi
        ;;
    *)
        echo ""
        ;;
    esac
}

# Get package name for current OS
get_package_name() {
    local dep="$1"
    local os
    os=$(detect_os)

    case "$os" in
    macos)
        case "$dep" in
        git) echo "git" ;;
        zsh) echo "zsh" ;;
        tmux) echo "tmux" ;;
        neovim) echo "neovim" ;;
        fzf) echo "fzf" ;;
        ripgrep) echo "ripgrep" ;;
        fd) echo "fd" ;;
        bat) echo "bat" ;;
        delta) echo "git-delta" ;;
        lazygit) echo "lazygit" ;;
        eza) echo "eza" ;;
        zoxide) echo "zoxide" ;;
        gum) echo "gum" ;;
        gh) echo "gh" ;;
        1password) echo "--cask 1password" ;;
        1password-cli) echo "1password-cli" ;;
        zsh-autosuggestions) echo "zsh-autosuggestions" ;;
        zsh-syntax-highlighting) echo "zsh-syntax-highlighting" ;;
        oh-my-posh) echo "oh-my-posh" ;;
        gallery-dl) echo "gallery-dl" ;;
        yt-dlp) echo "yt-dlp" ;;
        ffmpeg) echo "ffmpeg" ;;
        eyeD3) echo "eyed3" ;;
        mpd) echo "mpd" ;;
        mpc) echo "mpc" ;;
        atuin) echo "atuin" ;;
        yq) echo "yq" ;;
        rust) echo "rust" ;;
        go) echo "go" ;;
        claude-code) echo "claude-code" ;;
        claude-desktop) echo "--cask claude" ;;
        signal) echo "--cask signal" ;;
        slack) echo "--cask slack" ;;
        whatsapp) echo "--cask whatsapp" ;;
        docker) echo "--cask docker" ;;
        av) echo "aviator-co/tap/av" ;;
        paru) echo "" ;; # Arch only
        zed-preview) echo "--cask zed@preview" ;;
        *) echo "$dep" ;;
        esac
        ;;
    arch)
        case "$dep" in
        git) echo "git" ;;
        zsh) echo "zsh" ;;
        tmux) echo "tmux" ;;
        neovim) echo "neovim" ;;
        fzf) echo "fzf" ;;
        ripgrep) echo "ripgrep" ;;
        fd) echo "fd" ;;
        bat) echo "bat" ;;
        delta) echo "git-delta" ;;
        lazygit) echo "lazygit" ;;
        eza) echo "eza" ;;
        zoxide) echo "zoxide" ;;
        gum) echo "gum" ;;
        gh) echo "github-cli" ;;
        1password) echo "1password" ;;
        1password-cli) echo "1password-cli" ;;
        zsh-autosuggestions) echo "zsh-autosuggestions" ;;
        zsh-syntax-highlighting) echo "zsh-syntax-highlighting" ;;
        oh-my-posh) echo "oh-my-posh" ;;
        gallery-dl) echo "gallery-dl" ;;
        yt-dlp) echo "yt-dlp" ;;
        ffmpeg) echo "ffmpeg" ;;
        eyeD3) echo "python-eyed3" ;;
        mpd) echo "mpd" ;;
        mpc) echo "mpc" ;;
        atuin) echo "atuin" ;;
        yq) echo "go-yq" ;;
        rust) echo "rust" ;;
        go) echo "go" ;;
        claude-code) echo "claude-code" ;;
        claude-desktop) echo "claude-desktop-native" ;;
        signal) echo "signal-desktop" ;;
        slack) echo "slack-desktop" ;;
        whatsapp) echo "zapzap" ;;
        docker) echo "docker" ;;
        av) echo "av-cli-bin" ;;
        paru) echo "paru" ;;
        zed-preview) echo "zed-preview-bin" ;;
        *) echo "$dep" ;;
        esac
        ;;
    *)
        echo "$dep"
        ;;
    esac
}

# Install a single dependency
install_dependency() {
    local dep="$1"
    local pkg_manager
    local package_name

    # Special case for nvm - installed via script
    if [[ "$dep" == "nvm" ]]; then
        echo "📦 Installing nvm..."
        if command -v curl &>/dev/null; then
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
            # Source nvm to make it available immediately
            export NVM_DIR="${XDG_CONFIG_HOME:-$HOME}/.nvm"
            [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
            # Also check ~/.nvm for default install location
            [[ -s "$HOME/.nvm/nvm.sh" ]] && \. "$HOME/.nvm/nvm.sh"
            echo "✅ NVM installed"
            # Install latest LTS Node.js
            if command -v nvm &>/dev/null; then
                echo "📦 Installing Node.js LTS via nvm..."
                nvm install --lts
                nvm use --lts
                nvm alias default lts/*
                echo "✅ Node.js LTS installed"
            fi
            return 0
        else
            echo "❌ curl not available - cannot install nvm"
            return 1
        fi
    fi

    pkg_manager=$(get_package_manager)
    package_name=$(get_package_name "$dep")

    if [[ -z "$pkg_manager" ]]; then
        echo "❌ No supported package manager found"
        return 1
    fi

    # Skip if package not available for this OS
    if [[ -z "$package_name" ]]; then
        echo "⏭️  Skipping $dep (not available for this OS)"
        return 0
    fi

    echo "📦 Installing $dep..."
    case "$pkg_manager" in
    brew)
        if [[ "$package_name" == --cask* ]]; then
            brew install $package_name
        else
            brew install "$package_name"
        fi
        ;;
    paru | yay)
        "$pkg_manager" -S --needed --noconfirm "$package_name"
        ;;
    pacman)
        sudo pacman -S --needed --noconfirm "$package_name"
        ;;
    *)
        echo "❌ Unsupported package manager: $pkg_manager"
        return 1
        ;;
    esac

    # Post-install: create claude symlink on Arch (package installs to /usr/bin)
    if [[ "$dep" == "claude-code" ]] && [[ "$(detect_os)" == "arch" ]]; then
        if [[ -f "/usr/bin/claude" ]] && [[ ! -e "$HOME/.local/bin/claude" ]]; then
            mkdir -p "$HOME/.local/bin"
            ln -s /usr/bin/claude "$HOME/.local/bin/claude"
            echo "✅ Created claude symlink at ~/.local/bin/claude"
        fi
    fi
}

# Check all dependencies and return list of missing ones
check_all_dependencies() {
    local deps=("$@")
    local missing=()

    for dep_info in "${deps[@]}"; do
        local dep="${dep_info%%:*}"
        if ! check_dependency "$dep"; then
            missing+=("$dep")
        fi
    done

    # Only print if there are missing dependencies
    if [[ ${#missing[@]} -gt 0 ]]; then
        printf '%s\n' "${missing[@]}"
    fi
}

# Show missing dependencies with installation guidance
show_missing_deps_guidance() {
    local script_name="$1"
    shift
    local missing_deps=("$@")

    if [[ ${#missing_deps[@]} -eq 0 ]]; then
        return 0
    fi

    echo "❌ Missing required dependencies for '$script_name':"
    for dep in "${missing_deps[@]}"; do
        echo "  • $dep"
    done
    echo ""
    echo "🚀 Quick fix: Run 'dots install' to install all dependencies automatically"
    echo "📚 Or install manually:"
    show_manual_install_instructions "${missing_deps[@]}"
}

# Show manual installation instructions
show_manual_install_instructions() {
    local deps=("$@")
    local os
    local pkg_manager

    os=$(detect_os)
    pkg_manager=$(get_package_manager)

    case "$os" in
    macos)
        echo "  macOS: brew install ${deps[*]}"
        ;;
    arch)
        case "$pkg_manager" in
        paru | yay)
            echo "  Arch: $pkg_manager -S ${deps[*]}"
            ;;
        pacman)
            echo "  Arch: sudo pacman -S ${deps[*]}"
            ;;
        *)
            echo "  Arch: Install paru/yay or use: sudo pacman -S ${deps[*]}"
            ;;
        esac
        ;;
    *)
        echo "  Install via your system's package manager"
        ;;
    esac
}

# Install all required dependencies
install_all_dependencies() {
    local os
    local pkg_manager
    local missing_deps

    os=$(detect_os)
    pkg_manager=$(get_package_manager)

    if [[ -z "$pkg_manager" ]]; then
        echo "❌ No supported package manager found for $os"
        return 1
    fi

    echo "🔍 Detecting operating system... $os"
    echo "📦 Using package manager: $pkg_manager"
    echo ""

    # Check dependencies
    echo "📋 Checking required dependencies..."
    readarray -t missing_deps < <(check_all_dependencies "${REQUIRED_DEPS[@]}")

    # Filter out empty elements
    local filtered_missing_deps=()
    for dep in "${missing_deps[@]}"; do
        if [[ -n "$dep" ]]; then
            filtered_missing_deps+=("$dep")
        fi
    done
    missing_deps=("${filtered_missing_deps[@]}")

    # Show status
    echo ""
    echo "Required dependencies:"
    for dep_info in "${REQUIRED_DEPS[@]}"; do
        local dep="${dep_info%%:*}"
        if check_dependency "$dep"; then
            echo "  ✅ $dep - already installed"
        else
            echo "  ❌ $dep - missing"
        fi
    done

    # Install missing dependencies
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo ""
        echo "🚀 Installing dependencies..."
        for dep in "${missing_deps[@]}"; do
            if ! install_dependency "$dep"; then
                echo "❌ Failed to install $dep"
                return 1
            fi
        done
        echo "✅ All dependencies installed!"
    else
        echo ""
        echo "✅ All dependencies already installed!"
    fi

    return 0
}

# Configure system settings
configure_system() {
    local os
    os=$(detect_os)

    echo ""
    echo "⚙️  Configuring system settings..."

    # Set zsh as default shell
    local current_shell
    if command -v getent &>/dev/null; then
        current_shell=$(getent passwd "$USER" | cut -d: -f7)
    else
        # macOS doesn't have getent, use dscl instead
        current_shell=$(dscl . -read "/Users/$USER" UserShell | awk '{print $2}')
    fi
    local zsh_path
    zsh_path=$(which zsh)

    if [[ "$current_shell" != "$zsh_path" ]]; then
        echo "🐚 Setting zsh as default shell..."
        echo "  Current shell: $current_shell"
        echo "  Target shell: $zsh_path"

        if [[ "$os" == "macos" ]]; then
            # macOS: use chsh (will prompt for password)
            if chsh -s "$zsh_path"; then
                echo "✅ Default shell changed to zsh (logout/login required)"
            else
                echo "❌ Failed to change shell - you may need to run manually: chsh -s $zsh_path"
            fi
        else
            # Linux: use sudo usermod (uses sudo auth, already used for package install)
            if sudo usermod -s "$zsh_path" "$USER"; then
                echo "✅ Default shell changed to zsh (logout/login required)"
            else
                echo "❌ Failed to change shell - you may need to run manually: sudo usermod -s $zsh_path $USER"
            fi
        fi
    else
        echo "✅ zsh already set as default shell ($current_shell)"
    fi

    # Configure Git signing (if 1Password available)
    local op_ssh_sign_path=""

    # Check for op-ssh-sign in common locations
    if command -v op-ssh-sign &>/dev/null; then
        op_ssh_sign_path=$(which op-ssh-sign)
    elif [[ -x "/opt/1Password/op-ssh-sign" ]]; then
        op_ssh_sign_path="/opt/1Password/op-ssh-sign"
    elif [[ -x "/Applications/1Password.app/Contents/MacOS/op-ssh-sign" ]]; then
        op_ssh_sign_path="/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
    fi

    if [[ -n "$op_ssh_sign_path" ]]; then
        echo "🔑 Configuring Git SSH signing with 1Password..."
        git config --global gpg.ssh.program "$op_ssh_sign_path"
        echo "✅ Git signing configured with: $op_ssh_sign_path"

        # Also check if SSH agent socket exists
        if [[ -S "$HOME/.1password/agent.sock" ]] || [[ -S "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" ]]; then
            echo "✅ 1Password SSH agent is running"
        fi
    else
        echo "⚠️  1Password SSH signing tool not found - Git signing will use system SSH"
    fi

    # Install TPM (Tmux Plugin Manager) if not present
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        echo "🔌 Installing TPM (Tmux Plugin Manager)..."
        if command -v git &>/dev/null; then
            git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
            echo "✅ TPM installed - use prefix + I to install plugins"
        else
            echo "⚠️  git not available - install TPM manually"
        fi
    else
        echo "✅ TPM already installed"
    fi

    echo "✅ System configuration complete!"
}

# Validate installation
validate_dependencies() {
    echo ""
    echo "🧪 Validating installation..."

    local failed=()

    # Test required commands
    for dep_info in "${REQUIRED_DEPS[@]}"; do
        local dep="${dep_info%%:*}"
        if ! check_dependency "$dep"; then
            failed+=("$dep")
        fi
    done

    if [[ ${#failed[@]} -eq 0 ]]; then
        echo "✅ All dependencies functional!"
        return 0
    else
        echo "❌ Some dependencies still missing: ${failed[*]}"
        return 1
    fi
}
