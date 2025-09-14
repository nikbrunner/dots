#!/bin/bash
# Detect operating system
# Returns: "macos", "linux", "windows"

get_os() {
	case "$OSTYPE" in
	darwin*) echo "macos" ;;
	linux*)
		if [[ -f /etc/arch-release ]] || command -v pacman &> /dev/null; then
			echo "arch"
		else
			echo "linux"
		fi
		;;
	msys*) echo "windows" ;;
	*) echo "unknown" ;;
	esac
}

# If script is run directly, print the OS
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	get_os
fi
