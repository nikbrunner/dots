#!/bin/bash
# Format files in the repository
# Formats JS/TS/JSON with prettier and shell scripts with shfmt
# Excludes dotfiles directories (common/, macos/, linux/)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the repository root directory
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Directories to exclude from formatting
EXCLUDE_DIRS=(
	"common"
	"macos"
	"linux"
	".git"
)

# Check mode (--check for validation only)
CHECK_MODE=false
if [[ "${1:-}" == "--check" ]]; then
	CHECK_MODE=true
fi

echo -e "${YELLOW}Formatting repository files...${NC}"

# Format with prettier (using specific patterns to exclude directories)
echo "Running prettier..."
PRETTIER_PATTERNS=("**/*.{js,ts,jsx,tsx,json,md,yml,yaml}" "!common/**" "!macos/**" "!linux/**" "!.git/**")

if [[ "$CHECK_MODE" == true ]]; then
	if ! npx prettier --check "${PRETTIER_PATTERNS[@]}" 2>/dev/null; then
		echo -e "${RED}❌ Prettier check failed${NC}"
		exit 1
	fi
else
	npx prettier --write "${PRETTIER_PATTERNS[@]}" 2>/dev/null
fi

# Format shell scripts with shfmt (if available)
if command -v shfmt >/dev/null 2>&1; then
	echo "Running shfmt..."

	# Build find exclude patterns
	FIND_EXCLUDE_PATTERNS=()
	for dir in "${EXCLUDE_DIRS[@]}"; do
		FIND_EXCLUDE_PATTERNS+=(-not -path "$REPO_ROOT/$dir/*")
	done

	# Find shell scripts excluding configured directories
	find "$REPO_ROOT" -name "*.sh" "${FIND_EXCLUDE_PATTERNS[@]}" | while read -r file; do
		if [[ "$CHECK_MODE" == true ]]; then
			if ! shfmt -d "$file" >/dev/null 2>&1; then
				echo -e "${RED}❌ Shell format check failed: $file${NC}"
				exit 1
			fi
		else
			shfmt -w "$file"
		fi
	done
else
	echo -e "${YELLOW}⚠️  shfmt not found, skipping shell script formatting${NC}"
fi

if [[ "$CHECK_MODE" == true ]]; then
	echo -e "${GREEN}✅ All files are properly formatted${NC}"
else
	echo -e "${GREEN}✅ Formatting complete${NC}"
fi
