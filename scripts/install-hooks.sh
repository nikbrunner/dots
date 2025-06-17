#!/bin/bash
# Install git hooks for the dots repository

set -e

# Get the script directory and dots directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTS_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}→${NC} Installing git hooks..."

# Create hooks directory if it doesn't exist
mkdir -p "$DOTS_DIR/.git/hooks"

# Install pre-commit hook
cat >"$DOTS_DIR/.git/hooks/pre-commit" <<'EOF'
#!/bin/bash
# Pre-commit hook to clean up broken symlinks when files are deleted from dots repo

set -e

# Get the dots directory
DOTS_DIR="$(git rev-parse --show-toplevel)"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to check if a symlink target would be broken after this commit
check_and_clean_broken_links() {
    local cleaned_count=0
    
    # Get list of deleted files in this commit
    local deleted_files
    deleted_files=$(git diff --cached --name-only --diff-filter=D)
    
    if [[ -z "$deleted_files" ]]; then
        return 0
    fi
    
    echo -e "${YELLOW}→${NC} Checking for broken symlinks from deleted files..."
    
    # Get current OS and mapping file
    # shellcheck disable=SC1091
    source "$DOTS_DIR/scripts/detect-os.sh"
    local current_os
    current_os=$(get_os)
    local mapping_file="$DOTS_DIR/.mappings/$current_os.json"
    
    # Generate fresh mappings to see current state
    "$DOTS_DIR/scripts/generate-mappings.sh" >/dev/null 2>&1
    
    if [[ ! -f "$mapping_file" ]]; then
        return 0
    fi
    
    # Check each deleted file to see if it has a corresponding symlink
    while IFS= read -r deleted_file; do
        [[ -z "$deleted_file" ]] && continue
        
        local full_path="$DOTS_DIR/$deleted_file"
        
        # Look for this file in the mappings
        local target_path
        target_path=$(grep -o "\"$full_path\":\"[^\"]*\"" "$mapping_file" 2>/dev/null | sed 's/.*:"\([^"]*\)"/\1/' || true)
        
        if [[ -n "$target_path" && -L "$target_path" ]]; then
            # Check if the symlink would be broken after commit
            local link_target
            link_target=$(readlink "$target_path")
            if [[ "$link_target" == "$full_path" ]]; then
                echo -e "${RED}✗${NC} Removing broken symlink: $target_path"
                rm "$target_path"
                ((cleaned_count++))
            fi
        fi
    done <<< "$deleted_files"
    
    if [[ $cleaned_count -gt 0 ]]; then
        echo -e "${GREEN}✓${NC} Cleaned up $cleaned_count broken symlinks"
        
        # Regenerate mappings after cleanup
        echo -e "${YELLOW}→${NC} Regenerating mappings after cleanup..."
        "$DOTS_DIR/scripts/generate-mappings.sh" >/dev/null 2>&1
    fi
}

# Run the cleanup
check_and_clean_broken_links

# Continue with normal commit
exit 0
EOF

# Make hook executable
chmod +x "$DOTS_DIR/.git/hooks/pre-commit"

echo -e "${GREEN}✓${NC} Pre-commit hook installed"
echo "The hook will automatically clean up broken symlinks when you delete files from the dots repo"
