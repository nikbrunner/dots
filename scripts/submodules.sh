#!/bin/bash
# Git submodule management
# Functions for adding, updating, removing submodules

set -e

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTS_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Change to dots directory
cd "$DOTS_DIR"

# Function to add a submodule
add_submodule() {
	local repo_url="$1"
	local path="$2"
	local name
	name="$(basename "$path")"

	if [[ -z "$repo_url" || -z "$path" ]]; then
		echo -e "${RED}✗${NC} Usage: add_submodule <repo_url> <path>"
		return 1
	fi

	echo -e "${YELLOW}→${NC} Adding submodule: $name"

	if [[ -d "$path" ]]; then
		echo -e "${RED}✗${NC} Path already exists: $path"
		return 1
	fi

	git submodule add "$repo_url" "$path"
	git submodule update --init --recursive "$path"

	echo -e "${GREEN}✓${NC} Added submodule: $name"
}

# Function to update all submodules
update_submodules() {
	echo -e "${YELLOW}→${NC} Updating all submodules..."

	git submodule update --init --recursive
	git submodule foreach 'git pull origin main || git pull origin master'

	echo -e "${GREEN}✓${NC} All submodules updated"
}

# Function to remove a submodule
remove_submodule() {
	local path="$1"
	local name
	name="$(basename "$path")"

	if [[ -z "$path" ]]; then
		echo -e "${RED}✗${NC} Usage: remove_submodule <path>"
		return 1
	fi

	echo -e "${YELLOW}→${NC} Removing submodule: $name"

	# Remove the submodule entry from .git/config
	git submodule deinit -f "$path"

	# Remove the submodule directory from the working tree
	rm -rf "$path"

	# Remove the submodule directory from .git/modules
	rm -rf ".git/modules/$path"

	# Remove the entry in .gitmodules and stage the file
	git rm -f "$path"

	echo -e "${GREEN}✓${NC} Removed submodule: $name"
}

# Function to list all submodules
list_submodules() {
	echo "Current submodules:"
	git submodule status | while read -r line; do
		echo "  $line"
	done
}

# Main script logic
case "${1:-}" in
add)
	shift
	add_submodule "$@"
	;;
update)
	update_submodules
	;;
remove)
	shift
	remove_submodule "$@"
	;;
list)
	list_submodules
	;;
*)
	echo "Git submodule management script"
	echo ""
	echo "Usage:"
	echo "  $0 add <repo_url> <path>  - Add a new submodule"
	echo "  $0 update                 - Update all submodules"
	echo "  $0 remove <path>          - Remove a submodule"
	echo "  $0 list                   - List all submodules"
	;;
esac
