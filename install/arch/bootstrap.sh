#!/usr/bin/env bash
# Fresh Arch Linux bootstrap — system update, ensure paru (AUR helper), git.
# Assumes you're on EndeavourOS or vanilla Arch with base-devel.
#
# After this completes, follow install/arch/README.md for the numbered steps.

set -euo pipefail

echo "╔══════════════════════════════════════╗"
echo "║      Arch Linux Bootstrap (Stage 0)  ║"
echo "╚══════════════════════════════════════╝"
echo ""

# 1. System update
echo "📦 Updating system..."
sudo pacman -Syu --noconfirm

# 2. Ensure base-devel + git (needed for AUR builds and clones)
echo "📦 Ensuring base-devel + git..."
sudo pacman -S --needed --noconfirm base-devel git

# 3. Ensure paru (AUR helper). On EndeavourOS paru is usually pre-installed.
if command -v paru >/dev/null 2>&1; then
    echo "✅ paru already installed"
elif command -v yay >/dev/null 2>&1; then
    echo "✅ yay found (will use it; paru preferred but yay works)"
else
    echo "📦 Installing paru from AUR..."
    TMP_DIR="$(mktemp -d)"
    git clone https://aur.archlinux.org/paru.git "$TMP_DIR/paru"
    (cd "$TMP_DIR/paru" && makepkg -si --noconfirm)
    rm -rf "$TMP_DIR"
fi

echo ""
echo "✅ Bootstrap complete."
echo ""
echo "Next steps:"
echo "  1. Follow install/arch/README.md step by step"
echo ""
