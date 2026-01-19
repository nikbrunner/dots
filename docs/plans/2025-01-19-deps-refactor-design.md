# Deps Refactor Design

## Problem

The current `scripts/deps.sh` is 800+ lines mixing all platforms together:
- Single `REQUIRED_DEPS` array with "Arch only" comments
- Complex `get_package_name()` case statements for each OS
- Filtering logic via empty-string returns
- Arch packages showing as "missing" on macOS

## Solution

Separate OS-specific files with actual package names. No translation layer.

## File Structure

```
scripts/
├── detect-os.sh          # Shared OS detection (unchanged)
└── deps/
    ├── install.sh        # Dispatcher: detect OS → source correct file → run
    ├── macos.sh          # Homebrew packages + logic
    └── arch.sh           # Paru packages + logic
```

Old `scripts/deps.sh` gets deleted.

## Dispatcher (`install.sh`)

```bash
#!/usr/bin/env bash
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../detect-os.sh"

OS=$(get_os)

case "$OS" in
    macos) source "$SCRIPT_DIR/macos.sh" ;;
    arch)  source "$SCRIPT_DIR/arch.sh" ;;
    *)     echo "Unsupported OS: $OS"; exit 1 ;;
esac

case "${1:-install}" in
    check)   check_all ;;
    install) install_all ;;
    list)    printf '%s\n' "${DEPS[@]}" ;;
    *)       echo "Usage: $0 [check|install|list]"; exit 1 ;;
esac
```

## OS File Structure (`macos.sh` / `arch.sh`)

```bash
#!/usr/bin/env bash
DEPS=(
    package1
    package2
)

check_dep() {
    case "$1" in
        neovim) command -v nvim ;;
        git-delta) command -v delta ;;
        *) command -v "$1" ;;
    esac
}

install_dep() {
    local dep="$1"
    # Package manager install
    # Inline post-install hooks where needed
}

install_all() {
    # Loop through DEPS, check, install missing
}

check_all() {
    # Show status of all deps
}
```

## Post-install Hooks (inline)

Only 4 packages need post-install:

| Package | Action | Platform |
|---------|--------|----------|
| claude-code | Symlink to ~/.local/bin | Arch |
| bluez | Enable bluetooth service | Arch |
| docker | Add user to group + enable service | Arch |
| nvm | Curl script install + Node LTS | Both |

These stay inline in the OS files - not worth separate files.

## Claude Skill (`/dots/deps-manage`)

Interactive skill for adding/removing dependencies:

**Add flow:**
1. Which OS? (macos / arch / both)
2. Package name for each OS
3. Custom check command needed?
4. Post-install setup needed?
5. Add to file(s)

**Remove flow:**
1. Search both files
2. Confirm removal
3. Remove from file(s)

## Migration

1. Create new structure
2. Extract packages from current deps.sh into macos.sh and arch.sh
3. Update callers (dots CLI, install.sh)
4. Delete old deps.sh
5. Create skill
