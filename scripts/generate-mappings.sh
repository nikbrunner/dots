#!/bin/bash
# Generate symlink mappings for dotfiles
# Creates JSON files with source -> target mappings for each OS

set -e

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTS_DIR="$(dirname "$SCRIPT_DIR")"

# Source OS detection
# shellcheck disable=SC1091
source "$SCRIPT_DIR/detect-os.sh"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo -e "${YELLOW}→${NC} Generating symlink mappings..."

# Function to generate file-level mappings only
generate_mappings() {
    local source_base="$1"
    local target_base="$2"
    local mappings=()

    # Skip if source doesn't exist
    [[ ! -d "$source_base" ]] && return

    # Find all files and symlinks recursively and create file-level mappings
    while IFS= read -r -d '' file; do
        local rel_path="${file#"$source_base"/}"
        local target="$target_base/$rel_path"
        mappings+=("\"$file\":\"$target\"")
    done < <(find "$source_base" \( -type f -o -type l \) -print0 2>/dev/null)

    # Print mappings
    printf '%s\n' "${mappings[@]}"
}

# Generate common mappings
echo -e "${YELLOW}→${NC} Processing common files..."
common_mappings=$(generate_mappings "$DOTS_DIR/common" "$HOME")

# Create mappings directory
mkdir -p "$DOTS_DIR/.mappings"

# Generate macOS mappings (common + macOS-specific)
echo -e "${YELLOW}→${NC} Generating macOS mappings..."
macos_mappings="$common_mappings"
if [[ -d "$DOTS_DIR/macos" ]]; then
    macos_specific=$(generate_mappings "$DOTS_DIR/macos" "$HOME")
    if [[ -n "$macos_specific" ]]; then
        macos_mappings="$common_mappings"$'\n'"$macos_specific"
    fi
fi

cat >"$DOTS_DIR/.mappings/macos.json" <<EOF
{
$(echo "$macos_mappings" | sed '$!s/$/,/')
}
EOF

# Generate Linux mappings (common + Linux-specific)
echo -e "${YELLOW}→${NC} Generating Linux mappings..."
linux_mappings="$common_mappings"
if [[ -d "$DOTS_DIR/linux" ]]; then
    linux_specific=$(generate_mappings "$DOTS_DIR/linux" "$HOME")
    if [[ -n "$linux_specific" ]]; then
        linux_mappings="$common_mappings"$'\n'"$linux_specific"
    fi
fi

cat >"$DOTS_DIR/.mappings/linux.json" <<EOF
{
$(echo "$linux_mappings" | sed '$!s/$/,/')
}
EOF

echo -e "${GREEN}✓${NC} Generated mappings:"
echo "  - Common: $(echo "$common_mappings" | wc -l | tr -d ' ') files"
if [[ -d "$DOTS_DIR/macos" ]]; then
    macos_count=$(echo "$macos_mappings" | wc -l | tr -d ' ')
    echo "  - macOS total: $macos_count files"
fi
if [[ -d "$DOTS_DIR/linux" ]]; then
    linux_count=$(echo "$linux_mappings" | wc -l | tr -d ' ')
    echo "  - Linux total: $linux_count files"
fi
