#!/usr/bin/env bash
# Uninstall Homebrew packages that are now managed by mise.
# Run: bash scripts/uninstall-homebrew-dupes.sh
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

MISE_CONFIG="$HOME/repos/nikbrunner/dots/common/.config/mise/config.toml"

if [[ ! -f "$MISE_CONFIG" ]]; then
    echo -e "${RED}Mise config not found at $MISE_CONFIG${NC}"
    exit 1
fi

echo "Checking Homebrew packages that are now managed by mise..."
echo ""

# Extract tools from mise config (exclude section headers, comments, and prefixed backends)
mise_tools=$(awk -F'=' '
  /^\[/ { next }
  /^#/ { next }
  /^[[:space:]]*$/ { next }
  /^[[:space:]]*[a-zA-Z]/ {
    tool = $1
    gsub(/^[[:space:]]*"?/, "", tool)
    gsub(/"[[:space:]]*$/, "", tool)
    gsub(/[[:space:]]*$/, "", tool)
    if (tool !~ /^npm:/ && tool !~ /^go:/ && tool !~ /^pipx:/) print tool
  }
' "$MISE_CONFIG" | sort -u)

overlap=()
for tool in $mise_tools; do
    if brew list --formula "$tool" &>/dev/null 2>&1; then
        ver=$(brew list --formula --versions "$tool" 2>/dev/null | awk '{print $NF}')
        overlap+=("$tool $ver")
    fi
done

if [[ ${#overlap[@]} -eq 0 ]]; then
    echo -e "${GREEN}No Homebrew duplicates found. All clear!${NC}"
    exit 0
fi

echo -e "${YELLOW}The following are installed via both Homebrew and mise:${NC}"
echo ""
for entry in "${overlap[@]}"; do
    tool=$(echo "$entry" | awk '{print $1}')
    ver=$(echo "$entry" | awk '{print $2}')
    mise_ver=$(mise current "$tool" 2>/dev/null | awk '{print $2}' || echo "?")
    printf "  %-25s homebrew: %-15s mise: %s\n" "$tool" "$ver" "$mise_ver"
done
echo ""

read -rp "Uninstall these from Homebrew? [y/N] " answer
if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
    echo "Skipping."
    exit 0
fi

for entry in "${overlap[@]}"; do
    tool=$(echo "$entry" | awk '{print $1}')
    echo -e "${YELLOW}Uninstalling $tool from Homebrew...${NC}"
    brew uninstall --ignore-dependencies "$tool" 2>&1 || echo "  (warnings above are fine)"
done

echo ""
echo -e "${GREEN}Done. Homebrew duplicates removed.${NC}"
echo ""

read -rp "Run 'mise install' to ensure mise versions are active? [Y/n] " answer
if [[ "$answer" == "n" || "$answer" == "N" ]]; then
    echo "Skipping. Run 'mise install' manually if needed."
    exit 0
fi

echo ""
mise install
echo ""
echo -e "${GREEN}All done. Your tools are now managed exclusively by mise.${NC}"