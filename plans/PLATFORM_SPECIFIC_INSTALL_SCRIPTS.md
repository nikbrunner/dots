# Platform-Specific Install Scripts Plan

## Prerequisites

**⚠️ IMPORTANT**: This plan depends on implementing `deps.json/yaml` first!

The current `deps.sh` uses hardcoded package mappings. Before implementing platform-specific install scripts, we need:

1. **deps.json/yaml** - Structured package data file
2. **Enhanced deps.sh** - Parse JSON instead of hardcoded mappings  

See TODO.md "Foundation (BLOCKERS)" section and the detailed design below.

## Current State Analysis

Your current system has:
- ✅ Excellent cross-platform `deps.sh` with OS detection
- ✅ Unified `install.sh` that tries to handle both platforms
- ✅ Smart package manager detection and mapping
- ❌ **Missing**: Structured dependency data (deps.json) - **BLOCKER**

---

## deps.json Design (Foundation Requirement)

### Simple Schema Design

**Choice: JSON over YAML** - Better bash parsing support, no additional dependencies.

**Philosophy**: Keep it as simple as possible - just package name mappings. Let package managers handle duplicate installs.

#### Core Schema
```json
{
  "package_key": {
    "macos": "brew-package-name-with-flags",
    "arch": "arch-package-name"
  }
}
```

### Complete Example

```json
{
  "git": {
    "macos": "git",
    "arch": "git"
  },
  "zsh": {
    "macos": "zsh",
    "arch": "zsh"
  },
  "tmux": {
    "macos": "tmux",
    "arch": "tmux"
  },
  "neovim": {
    "macos": "neovim",
    "arch": "neovim"
  },
  "fzf": {
    "macos": "fzf",
    "arch": "fzf"
  },
  "ripgrep": {
    "macos": "ripgrep",
    "arch": "ripgrep"
  },
  "fd": {
    "macos": "fd",
    "arch": "fd"
  },
  "bat": {
    "macos": "bat",
    "arch": "bat"
  },
  "delta": {
    "macos": "git-delta",
    "arch": "git-delta"
  },
  "lazygit": {
    "macos": "lazygit",
    "arch": "lazygit"
  },
  "eza": {
    "macos": "eza",
    "arch": "eza"
  },
  "zoxide": {
    "macos": "zoxide",
    "arch": "zoxide"
  },
  "gum": {
    "macos": "gum",
    "arch": "gum"
  },
  "gh": {
    "macos": "gh",
    "arch": "github-cli"
  },
  "1password": {
    "macos": "--cask 1password",
    "arch": "1password"
  },
  "1password-cli": {
    "macos": "1password-cli",
    "arch": "1password-cli"
  },
  "zsh-autosuggestions": {
    "macos": "zsh-autosuggestions",
    "arch": "zsh-autosuggestions"
  },
  "zsh-syntax-highlighting": {
    "macos": "zsh-syntax-highlighting",
    "arch": "zsh-syntax-highlighting"
  },
  "oh-my-posh": {
    "macos": "oh-my-posh",
    "arch": "oh-my-posh"
  },
  "gallery-dl": {
    "macos": "gallery-dl",
    "arch": "gallery-dl"
  },
  "yt-dlp": {
    "macos": "yt-dlp",
    "arch": "yt-dlp"
  },
  "ffmpeg": {
    "macos": "ffmpeg",
    "arch": "ffmpeg"
  },
  "eyed3": {
    "macos": "eyed3",
    "arch": "eyed3"
  },
  "mpd": {
    "macos": "mpd",
    "arch": "mpd"
  }
}
```

### Enhanced deps.sh Implementation Strategy

#### Simple JSON Parsing
```bash
# Get package name from deps.json
get_package_name() {
    local dep="$1"
    local os="$2"
    
    if command -v jq &>/dev/null; then
        jq -r ".$dep.$os // empty" "$DEPS_FILE"
    else
        # Simple fallback without jq
        grep -A 3 "\"$dep\"" "$DEPS_FILE" | grep "\"$os\"" | cut -d'"' -f4
    fi
}

# Install single dependency
install_dependency() {
    local dep="$1"
    local os="$2"
    
    local package=$(get_package_name "$dep" "$os")
    
    [[ -z "$package" ]] && {
        echo "❌ Package '$dep' not available for $os"
        return 1
    }
    
    echo "📦 Installing $dep..."
    
    case "$os" in
        macos)
            brew install $package  # Note: $package might include --cask flag
            ;;
        arch)
            yay -S --needed --noconfirm "$package"
            ;;
    esac
}

# Install all dependencies from current REQUIRED_DEPS array
install_all_dependencies() {
    local os=$(detect_os)
    
    for dep_info in "${REQUIRED_DEPS[@]}"; do
        local dep="${dep_info%%:*}"  # Extract package key from "key:description"
        install_dependency "$dep" "$os"
    done
}
```

### Migration Strategy

#### Phase 1: Create deps.json
1. **Extract current mappings** from deps.sh hardcoded case statements
2. **Create simple JSON file** with package mappings only
3. **Test with existing REQUIRED_DEPS array**

#### Phase 2: Update deps.sh
1. **Replace hardcoded get_package_name()** function with JSON parsing
2. **Keep existing install_all_dependencies()** function structure
3. **Add fallback parsing** for systems without jq

#### Phase 3: Clean up
1. **Remove old case statements** from deps.sh
2. **Test on both platforms** to ensure compatibility
3. **Update documentation**

### Benefits Over Current System

#### Current Hardcoded Approach:
```bash
# Maintenance nightmare - 30+ hardcoded cases
case "$dep" in
    neovim) echo "neovim" ;;
    ripgrep) echo "ripgrep" ;;
    1password) echo "--cask 1password" ;;
    # ... more cases
esac
```

#### New Simple JSON Approach:
```bash
# Data-driven, simple
get_package_name "neovim" "macos"     # Returns: "neovim"
get_package_name "1password" "macos"  # Returns: "--cask 1password"
```

#### Advantages:
1. **Maintainable** - Add packages by editing JSON, not bash case statements
2. **Simple** - No complex metadata, groups, or custom logic
3. **Reliable** - Package managers handle duplicate installs automatically
4. **Collaborative** - Anyone can add packages without bash knowledge

### File Location
```
📁 Repository Root
├── deps.json          # Simple package mappings
└── scripts/deps.sh     # Enhanced to read deps.json instead of hardcoded cases
```

---

## Platform-Specific Install Scripts Architecture

### 1. **Main Dispatcher** (enhanced `install.sh`)
```bash
#!/usr/bin/env bash
# Main installation dispatcher

detect_os() {
    # Use existing logic from scripts/detect-os.sh
}

main() {
    case "$(detect_os)" in
        macos)
            exec "$SCRIPT_DIR/install-macos.sh" "$@"
            ;;
        arch)
            exec "$SCRIPT_DIR/install-arch.sh" "$@"
            ;;
        linux)
            echo "Generic Linux detected. Use install-arch.sh for Arch-based systems."
            echo "Other Linux distributions not yet supported."
            exit 1
            ;;
        *)
            echo "Unsupported OS: $(detect_os)"
            exit 1
            ;;
    esac
}
```

### 2. **macOS Install Script** (`install-macos.sh`)

Focused on macOS ecosystem with Homebrew:

```bash
#!/usr/bin/env bash
# macOS-specific installation script

# Phase 1: Homebrew Setup
install_homebrew() {
    if ! command -v brew &>/dev/null; then
        echo "📦 Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
}

# Phase 2: Core Development Tools
install_xcode_tools() {
    if ! xcode-select -p &>/dev/null; then
        echo "🛠️  Installing Xcode Command Line Tools..."
        xcode-select --install
    fi
}

# Phase 3: Essential Dependencies
install_core_deps() {
    # Use existing install_all_dependencies with deps.json backend  
    install_all_dependencies
}

# Phase 4: macOS-Specific Configuration
configure_macos() {
    # macOS system preferences
    configure_dock
    configure_finder
    configure_terminal_themes
    setup_macos_shortcuts
}

# Phase 5: Development Environment
setup_dev_environment() {
    # Node.js via Homebrew (more stable on macOS)
    brew install node
    
    # Python via Homebrew
    brew install python@3.11
    
    # Rust via rustup
    if ! command -v cargo &>/dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    fi
}
```

### 3. **Arch Linux Install Script** (`install-arch.sh`)

Inspired by Omarchy's modular approach:

```bash
#!/usr/bin/env bash
# Arch Linux installation script inspired by Omarchy

# Phase 1: AUR Helper Setup (from Omarchy)
install_yay() {
    if ! command -v yay &>/dev/null; then
        echo "📦 Installing yay AUR helper..."
        git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
        cd /tmp/yay-bin
        makepkg -si --noconfirm
        cd -
        rm -rf /tmp/yay-bin
    fi
}

# Phase 2: User Identification (from Omarchy)
setup_identification() {
    if command -v gum &>/dev/null; then
        DOTS_USER_NAME=$(gum input --placeholder "Enter your full name" --prompt "Name> ")
        DOTS_USER_EMAIL=$(gum input --placeholder "Enter your email" --prompt "Email> ")
    else
        read -p "Enter your full name: " DOTS_USER_NAME
        read -p "Enter your email: " DOTS_USER_EMAIL
    fi
    
    # Save for other scripts
    export DOTS_USER_NAME DOTS_USER_EMAIL
}

# Phase 3: Core Terminal Tools
install_terminal() {
    # Use existing install_all_dependencies with deps.json backend
    install_all_dependencies
}

# Phase 4: Desktop Environment (when on Arch desktop)
install_desktop() {
    if [[ "$DESKTOP_INSTALL" == "true" ]]; then
        # Desktop packages would need to be in deps.json and separate DESKTOP_DEPS array
        echo "Installing desktop environment..."
        local desktop_packages=("hyprland" "waybar" "wofi" "mako" "alacritty" "chromium")
        for pkg in "${desktop_packages[@]}"; do
            install_dependency "$pkg" "arch"
        done
    fi
}

# Phase 5: Development Environment
setup_development() {
    # Node.js via nvm (better for development)
    install_nvm
    
    # Rust
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    
    # Python
    yay -S --noconfirm python python-pip
}

# Phase 6: Web Applications (from Omarchy inspiration)
install_webapps() {
    # Use the web2app function from Omarchy
    source "$DOTS_DIR/scripts/webapps.sh"
    
    webapp_add "ChatGPT" "https://chatgpt.com/" "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/chatgpt.png"
    webapp_add "GitHub" "https://github.com/" "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/github-light.png"
    # ... more web apps
}
```

## Implementation Plan

### Phase 1: Create Base Scripts (Week 1)

#### 1.1 Enhanced Main Dispatcher
```bash
# Backup current install.sh
mv install.sh install-legacy.sh

# Create new dispatcher
cat > install.sh <<'EOF'
#!/usr/bin/env bash
# Platform-specific installation dispatcher

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/detect-os.sh"

echo "🎯 Dots Installation System"
echo "=========================="
echo ""

OS=$(get_os)
echo "Detected OS: $OS"

case "$OS" in
    macos)
        echo "🍎 Running macOS installation..."
        exec "$SCRIPT_DIR/install-macos.sh" "$@"
        ;;
    arch)
        echo "🏗️  Running Arch Linux installation..."
        exec "$SCRIPT_DIR/install-arch.sh" "$@"
        ;;
    linux)
        echo "🐧 Generic Linux detected."
        echo "Supported distributions:"
        echo "  • Arch Linux: Use install-arch.sh directly"
        echo "  • Others: Manual setup required"
        exit 1
        ;;
    *)
        echo "❌ Unsupported OS: $OS"
        echo "Supported systems: macOS, Arch Linux"
        exit 1
        ;;
esac
EOF
```

#### 1.2 macOS Install Script
```bash
# install-macos.sh
#!/usr/bin/env bash
# macOS installation with Homebrew focus

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Source shared libraries
source "$SCRIPT_DIR/scripts/detect-os.sh"
source "$SCRIPT_DIR/scripts/deps.sh"

main() {
    echo -e "${BLUE}🍎 macOS Installation${NC}"
    echo "===================="
    echo ""
    
    # Parse flags
    DRY_RUN=false
    SKIP_DEPS=false
    for arg in "$@"; do
        case "$arg" in
            --dry-run) DRY_RUN=true ;;
            --no-deps) SKIP_DEPS=true ;;
        esac
    done
    
    # Installation phases
    phase_homebrew
    [[ "$SKIP_DEPS" == "false" ]] && phase_dependencies
    phase_development
    phase_configuration
    phase_finalization
}

phase_homebrew() {
    echo -e "${BLUE}📦 Phase 1: Homebrew Setup${NC}"
    
    if ! command -v brew &>/dev/null; then
        if [[ "$DRY_RUN" == "true" ]]; then
            echo -e "${YELLOW}[DRY] Would install Homebrew${NC}"
        else
            echo "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
    else
        echo -e "${GREEN}✓${NC} Homebrew already installed"
    fi
    
    # Update Homebrew
    if [[ "$DRY_RUN" == "false" ]]; then
        brew update
    fi
}

phase_dependencies() {
    echo ""
    echo -e "${BLUE}📋 Phase 2: Dependencies${NC}"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${YELLOW}[DRY] Would install all dependencies via Homebrew${NC}"
    else
        # Use existing install_all_dependencies with deps.json backend
        install_all_dependencies
    fi
}

phase_development() {
    echo ""
    echo -e "${BLUE}🛠️  Phase 3: Development Environment${NC}"
    
    # Node.js
    if ! command -v node &>/dev/null; then
        if [[ "$DRY_RUN" == "true" ]]; then
            echo -e "${YELLOW}[DRY] Would install Node.js${NC}"
        else
            brew install node
        fi
    fi
    
    # Rust
    if ! command -v cargo &>/dev/null; then
        if [[ "$DRY_RUN" == "true" ]]; then
            echo -e "${YELLOW}[DRY] Would install Rust${NC}"
        else
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        fi
    fi
}

phase_configuration() {
    echo ""
    echo -e "${BLUE}⚙️  Phase 4: macOS Configuration${NC}"
    
    if [[ "$DRY_RUN" == "false" ]]; then
        configure_system
        configure_macos_specific
    fi
}

configure_macos_specific() {
    # macOS-specific configurations
    echo "🍎 Configuring macOS-specific settings..."
    
    # Set key repeat speed
    defaults write NSGlobalDomain KeyRepeat -int 1
    defaults write NSGlobalDomain InitialKeyRepeat -int 10
    
    # Show hidden files in Finder
    defaults write com.apple.finder AppleShowAllFiles YES
    
    # Disable automatic spelling correction
    defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
    
    echo -e "${GREEN}✓${NC} macOS settings configured"
}

phase_finalization() {
    echo ""
    echo -e "${BLUE}🎉 Phase 5: Finalization${NC}"
    
    # Create symlinks
    echo "Creating symlinks..."
    "$SCRIPT_DIR/scripts/link.sh" $([ "$DRY_RUN" == "true" ] && echo "--dry-run")
    
    # Set up dots command
    if [[ "$DRY_RUN" == "false" ]]; then
        mkdir -p "$HOME/.local/bin"
        ln -sf "$SCRIPT_DIR/common/bin/dots" "$HOME/.local/bin/dots"
    fi
    
    echo -e "${GREEN}🎉 macOS installation complete!${NC}"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
```

#### 1.3 Arch Install Script
```bash
# install-arch.sh
#!/usr/bin/env bash
# Arch Linux installation inspired by Omarchy

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source shared libraries
source "$SCRIPT_DIR/scripts/detect-os.sh"
source "$SCRIPT_DIR/scripts/deps.sh"

main() {
    echo -e "${BLUE}🏗️  Arch Linux Installation${NC}"
    echo "=========================="
    echo ""
    
    # Parse flags
    DRY_RUN=false
    SKIP_DEPS=false
    DESKTOP_INSTALL=false
    for arg in "$@"; do
        case "$arg" in
            --dry-run) DRY_RUN=true ;;
            --no-deps) SKIP_DEPS=true ;;
            --desktop) DESKTOP_INSTALL=true ;;
        esac
    done
    
    # Installation phases (inspired by Omarchy)
    phase_yay
    phase_identification
    [[ "$SKIP_DEPS" == "false" ]] && phase_terminal
    [[ "$DESKTOP_INSTALL" == "true" ]] && phase_desktop
    phase_development
    phase_configuration
    phase_finalization
}

phase_yay() {
    echo -e "${BLUE}📦 Phase 1: AUR Helper (YAY)${NC}"
    
    if ! command -v yay &>/dev/null; then
        if [[ "$DRY_RUN" == "true" ]]; then
            echo -e "${YELLOW}[DRY] Would install yay AUR helper${NC}"
        else
            # Install base development tools first
            sudo pacman -S --needed --noconfirm base-devel git
            
            # Clone and install yay
            git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
            cd /tmp/yay-bin
            makepkg -si --noconfirm
            cd -
            rm -rf /tmp/yay-bin
            
            echo -e "${GREEN}✓${NC} yay installed"
        fi
    else
        echo -e "${GREEN}✓${NC} yay already installed"
    fi
}

phase_identification() {
    echo ""
    echo -e "${BLUE}👤 Phase 2: User Identification${NC}"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${YELLOW}[DRY] Would collect user identification${NC}"
        return
    fi
    
    # Interactive user setup (from Omarchy)
    if command -v gum &>/dev/null; then
        DOTS_USER_NAME=$(gum input --placeholder "Enter your full name" --prompt "Name> ")
        DOTS_USER_EMAIL=$(gum input --placeholder "Enter your email" --prompt "Email> ")
    else
        read -p "Enter your full name: " DOTS_USER_NAME
        read -p "Enter your email: " DOTS_USER_EMAIL
    fi
    
    # Save for other scripts and configs
    mkdir -p "$HOME/.local/share/dots"
    cat > "$HOME/.local/share/dots/user.env" <<EOF
export DOTS_USER_NAME="$DOTS_USER_NAME"
export DOTS_USER_EMAIL="$DOTS_USER_EMAIL"
EOF
    
    # Export for current session
    export DOTS_USER_NAME DOTS_USER_EMAIL
    
    echo -e "${GREEN}✓${NC} User identification saved"
}

phase_terminal() {
    echo ""
    echo -e "${BLUE}💻 Phase 3: Terminal Tools${NC}"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${YELLOW}[DRY] Would install terminal dependencies${NC}"
    else
        # Use existing install_all_dependencies with deps.json backend
        install_all_dependencies
    fi
}

phase_desktop() {
    echo ""
    echo -e "${BLUE}🖥️  Phase 4: Desktop Environment${NC}"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${YELLOW}[DRY] Would install desktop environment${NC}"
        return
    fi
    
    echo "Installing Hyprland desktop environment..."
    yay -S --noconfirm --needed \
        hyprland hyprshot hyprpicker hyprlock hypridle \
        waybar wofi mako swaybg \
        alacritty chromium \
        brightnessctl playerctl pamixer \
        nautilus
    
    echo -e "${GREEN}✓${NC} Desktop environment installed"
}

phase_development() {
    echo ""
    echo -e "${BLUE}🛠️  Phase 5: Development Environment${NC}"
    
    if [[ "$DRY_RUN" == "false" ]]; then
        # Install NVM for Node.js
        if [[ ! -d "$HOME/.nvm" ]]; then
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        fi
        
        # Install Rust
        if ! command -v cargo &>/dev/null; then
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        fi
    fi
}

phase_configuration() {
    echo ""
    echo -e "${BLUE}⚙️  Phase 6: Configuration${NC}"
    
    if [[ "$DRY_RUN" == "false" ]]; then
        configure_system
        configure_arch_specific
    fi
}

configure_arch_specific() {
    echo "🏗️  Configuring Arch-specific settings..."
    
    # Set up XCompose with user identification
    if [[ -n "$DOTS_USER_NAME" && -n "$DOTS_USER_EMAIL" ]]; then
        cat > "$HOME/.XCompose" <<EOF
include "%L"

# User identification shortcuts
<Multi_key> <space> <n> : "$DOTS_USER_NAME"
<Multi_key> <space> <e> : "$DOTS_USER_EMAIL"

# Common emoji shortcuts
<Multi_key> <m> <s> : "😄"
<Multi_key> <m> <h> : "❤️"
<Multi_key> <m> <y> : "👍"
EOF
    fi
    
    echo -e "${GREEN}✓${NC} Arch-specific configuration complete"
}

phase_finalization() {
    echo ""
    echo -e "${BLUE}🎉 Phase 7: Finalization${NC}"
    
    # Create symlinks
    echo "Creating symlinks..."
    "$SCRIPT_DIR/scripts/link.sh" $([ "$DRY_RUN" == "true" ] && echo "--dry-run")
    
    # Set up dots command
    if [[ "$DRY_RUN" == "false" ]]; then
        mkdir -p "$HOME/.local/bin"
        ln -sf "$SCRIPT_DIR/common/bin/dots" "$HOME/.local/bin/dots"
    fi
    
    echo -e "${GREEN}🎉 Arch Linux installation complete!${NC}"
    
    if [[ "$DESKTOP_INSTALL" == "true" ]]; then
        echo ""
        echo "🖥️  Desktop environment notes:"
        echo "  • Start Hyprland: run 'Hyprland' from TTY"
        echo "  • Add to ~/.bash_profile for auto-start on login"
    fi
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
```

### Phase 2: Extract Shared Components (Week 2)

#### 2.1 Web App Management Script
```bash
# scripts/webapps.sh
#!/usr/bin/env bash
# Web application management (inspired by Omarchy)

WEBAPPS_DIR="$HOME/.local/share/applications"
ICONS_DIR="$WEBAPPS_DIR/icons"

webapp_add() {
    local app_name="$1"
    local app_url="$2" 
    local icon_url="$3"
    
    [[ $# -ne 3 ]] && {
        echo "Usage: webapp_add <name> <url> <icon_url>"
        return 1
    }
    
    echo "Creating web app: $app_name"
    
    mkdir -p "$ICONS_DIR"
    
    # Download icon
    if ! curl -sL -o "$ICONS_DIR/${app_name}.png" "$icon_url"; then
        echo "Error: Failed to download icon"
        return 1
    fi
    
    # Create desktop file
    cat > "$WEBAPPS_DIR/${app_name}.desktop" <<EOF
[Desktop Entry]
Version=1.0
Name=$app_name
Comment=$app_name Web Application
Exec=chromium --new-window --ozone-platform=wayland --app="$app_url" --name="$app_name" --class="$app_name"
Terminal=false
Type=Application
Icon=$ICONS_DIR/${app_name}.png
Categories=Network;
StartupNotify=true
EOF
    
    chmod +x "$WEBAPPS_DIR/${app_name}.desktop"
    echo "✓ Created web app: $app_name"
}

# Install common web apps
install_common_webapps() {
    webapp_add "ChatGPT" "https://chatgpt.com/" "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/chatgpt.png"
    webapp_add "GitHub" "https://github.com/" "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/github-light.png" 
    webapp_add "YouTube" "https://youtube.com/" "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/youtube.png"
}
```

#### 2.2 User Identification Library  
```bash
# scripts/identification.sh
#!/usr/bin/env bash
# User identification management

USER_ENV_FILE="$HOME/.local/share/dots/user.env"

load_user_info() {
    [[ -f "$USER_ENV_FILE" ]] && source "$USER_ENV_FILE"
}

save_user_info() {
    local name="$1"
    local email="$2"
    
    mkdir -p "$(dirname "$USER_ENV_FILE")"
    cat > "$USER_ENV_FILE" <<EOF
export DOTS_USER_NAME="$name"
export DOTS_USER_EMAIL="$email"
EOF
}

setup_user_identification() {
    echo "Setting up user identification..."
    
    if command -v gum &>/dev/null; then
        DOTS_USER_NAME=$(gum input --placeholder "Enter your full name" --prompt "Name> ")
        DOTS_USER_EMAIL=$(gum input --placeholder "Enter your email" --prompt "Email> ")
    else
        read -p "Enter your full name: " DOTS_USER_NAME
        read -p "Enter your email: " DOTS_USER_EMAIL
    fi
    
    save_user_info "$DOTS_USER_NAME" "$DOTS_USER_EMAIL"
    export DOTS_USER_NAME DOTS_USER_EMAIL
    
    echo "✓ User identification configured"
}
```

## Benefits of This Approach

### 1. **Platform Optimization**
- **macOS**: Homebrew-centric, macOS system preferences, native tools
- **Arch**: yay/pacman focus, desktop environment setup, Linux-specific tools

### 2. **Cleaner Architecture**
- Main dispatcher keeps simple OS detection
- Platform scripts can be specialized and focused
- Shared libraries prevent duplication

### 3. **Better User Experience**
- Platform-appropriate installation flows
- Relevant configuration for each system
- Optional components (desktop environment on Arch)

### 4. **Inspired by Omarchy**
- User identification system
- Modular phases with clear progression
- Web application integration
- Desktop environment configuration

### 5. **Maintains Your Strengths**
- Cross-platform symlink management
- Comprehensive testing system
- Unified `dots` command interface
- Submodule support

## Next Steps

1. **Create base platform scripts** - Start with simplified versions
2. **Test on both platforms** - Ensure feature parity where needed
3. **Migrate existing functionality** - Move current install.sh logic
4. **Add platform-specific features** - Web apps, themes, desktop integration
5. **Update documentation** - Reflect new installation methods

This approach gives you the best of both worlds: Omarchy's focused platform optimization with your existing cross-platform foundation!