#!/usr/bin/env bash
# Creates symlinks for dotfiles using shared library
# Usage: ./scripts/link.sh [--dry-run] [--no-backup] [--verbose]

set -e

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTS_DIR="$(dirname "$SCRIPT_DIR")"

# Source libraries
# shellcheck disable=SC1091
source "$SCRIPT_DIR/detect-os.sh"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/symlinks.sh"

# Check for flags
DRY_RUN=false
NO_BACKUP=false
VERBOSE=false
for arg in "$@"; do
	case $arg in
	--dry-run)
		DRY_RUN=true
		;;
	--no-backup)
		NO_BACKUP=true
		;;
	--verbose)
		VERBOSE=true
		;;
	esac
done

if [[ "$DRY_RUN" == true ]]; then
	echo -e "${YELLOW}DRY RUN MODE - No changes will be made${NC}"
	echo ""
fi

if [[ "$NO_BACKUP" == true ]]; then
	echo -e "${YELLOW}NO BACKUP MODE - Existing files will be overwritten${NC}"
	echo ""
fi

if [[ "$DEBUG" == true ]]; then
	echo -e "${YELLOW}DEBUG MODE - Extra diagnostics enabled${NC}"
	echo ""
fi

echo "Setting up dotfiles symlinks..."
echo "OS detected: $(get_os)"
echo ""

# Get current OS
CURRENT_OS=$(get_os)

# Initialize manifest tracking
init_manifest "$DOTS_DIR"

# Clean up broken symlinks BEFORE creating new ones
echo -e "${YELLOW}→${NC} Cleaning broken symlinks..."

cleanup_broken_symlinks "$DOTS_DIR" "$DRY_RUN" "$VERBOSE"

if [[ $CLEANUP_BROKEN_COUNT -eq 0 ]]; then
	echo -e "${GREEN}✓${NC} No broken symlinks found"
else
	if [[ "$DRY_RUN" == true ]]; then
		echo -e "${GREEN}✓${NC} Would remove $CLEANUP_BROKEN_COUNT broken symlinks"
	else
		echo -e "${GREEN}✓${NC} Cleaned up: $CLEANUP_BROKEN_COUNT broken symlinks"
	fi
fi
echo ""

# Function to process directory and show summary
process_directory() {
	local source_dir="$1"
	local target_base="$2"
	local dir_name="$3"

	[[ ! -d "$source_dir" ]] && return

	echo -e "${YELLOW}→${NC} Processing $dir_name files..."

	# Build options array
	local opts=()
	[[ "$DRY_RUN" == true ]] && opts+=("--dry-run")
	[[ "$NO_BACKUP" == true ]] && opts+=("--no-backup")
	[[ "$VERBOSE" == true ]] && opts+=("--verbose")
	[[ "$DEBUG" == true ]] && opts+=("--debug")

	# Process symlinks
	process_symlinks "$source_dir" "$target_base" "create" "${opts[@]}"

	# Display summary
	if [[ $STATS_TOTAL -eq 0 ]]; then
		echo -e "${YELLOW}→${NC} No files found in $dir_name"
	else
		local summary=""
		[[ $STATS_VALID -gt 0 ]] && summary+="${STATS_VALID} ok"
		[[ $STATS_CREATED -gt 0 ]] && summary+="${summary:+, }${STATS_CREATED} created"
		[[ $STATS_UPDATED -gt 0 ]] && summary+="${summary:+, }${STATS_UPDATED} updated"
		[[ $STATS_REPLACED -gt 0 ]] && summary+="${summary:+, }${STATS_REPLACED} replaced"

		echo -e "${GREEN}✓${NC} $dir_name: $STATS_TOTAL files ($summary)"
	fi
}

# Process common files first
process_directory "$DOTS_DIR/common" "$HOME" "common"

# Process OS-specific files
if [[ "$CURRENT_OS" == "macos" && -d "$DOTS_DIR/macos" ]]; then
	process_directory "$DOTS_DIR/macos" "$HOME" "macOS-specific"
elif [[ "$CURRENT_OS" == "linux" && -d "$DOTS_DIR/linux" ]]; then
	process_directory "$DOTS_DIR/linux" "$HOME" "Linux-specific"
fi

echo ""

# Save manifest file
if [[ "$DRY_RUN" != true ]]; then
	echo -e "${YELLOW}→${NC} Saving manifest..."
	save_manifest
	echo -e "${GREEN}✓${NC} Manifest saved to .dots-manifest.json"
fi

echo "Symlink setup complete!"
