#!/usr/bin/env bash
# Compile the Go tools in tools/ into common/.local/bin, where the symlink
# wildcard picks them up like any other script. The binaries are gitignored:
# the source is what's tracked, and each machine builds for its own platform.

set -e

DOTS_DIR="${DOTS_DIR:-$HOME/repos/nikbrunner/dots}"
SOURCE_DIR="$DOTS_DIR/tools"
TARGET_DIR="$DOTS_DIR/common/.local/bin"

[[ -d "$SOURCE_DIR" ]] || exit 0

if ! command -v go &>/dev/null; then
    echo "  ⚠ go not found, skipping tool build" >&2
    exit 0
fi

for dir in "$SOURCE_DIR"/*/; do
    [[ -f "$dir/go.mod" ]] || continue
    name=$(basename "$dir")
    if (cd "$dir" && go build -o "$TARGET_DIR/$name" . 2>&1); then
        echo "  ✓ $name"
    else
        echo "  ✗ $name failed to build" >&2
    fi
done
