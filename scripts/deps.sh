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
    "1password-cli:1Password CLI"
)

# Detect operating system
detect_os() {
    case "$(uname -s)" in
        Darwin)
            echo "macos"
            ;;
        Linux)
            if [[ -f /etc/arch-release ]] || command -v pacman &> /dev/null; then
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

# Check if a dependency exists
check_dependency() {
    local dep="$1"
    command -v "$dep" &> /dev/null
}

# Get package manager for current OS
get_package_manager() {
    local os
    os=$(detect_os)
    
    case "$os" in
        macos)
            if command -v brew &> /dev/null; then
                echo "brew"
            else
                echo ""
            fi
            ;;
        arch)
            if command -v paru &> /dev/null; then
                echo "paru"
            elif command -v yay &> /dev/null; then
                echo "yay"
            elif command -v pacman &> /dev/null; then
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
    
    pkg_manager=$(get_package_manager)
    package_name=$(get_package_name "$dep")
    
    if [[ -z "$pkg_manager" ]]; then
        echo "❌ No supported package manager found"
        return 1
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
        paru|yay)
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
    
    printf '%s\n' "${missing[@]}"
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
                paru|yay)
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
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        echo "🐚 Setting zsh as default shell..."
        if command -v chsh &> /dev/null; then
            chsh -s "$(which zsh)"
            echo "✅ Default shell changed to zsh (logout/login required)"
        else
            echo "⚠️  chsh not available - manually set zsh as default shell"
        fi
    else
        echo "✅ zsh already set as default shell"
    fi
    
    # Configure Git signing (if 1Password available)
    if command -v op-ssh-sign &> /dev/null; then
        echo "🔑 Configuring Git SSH signing with 1Password..."
        local op_path
        op_path=$(which op-ssh-sign)
        git config --global gpg.ssh.program "$op_path"
        echo "✅ Git signing configured with: $op_path"
    else
        echo "⚠️  1Password SSH agent not found - Git signing will use system SSH"
    fi
    
    # Install NVM on Linux if not present
    if [[ "$os" == "arch" ]] && [[ ! -d "$HOME/.nvm" ]]; then
        echo "📦 Installing NVM for Node.js management..."
        if command -v curl &> /dev/null; then
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
            echo "✅ NVM installed - reload shell to use"
        else
            echo "⚠️  curl not available - install NVM manually"
        fi
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