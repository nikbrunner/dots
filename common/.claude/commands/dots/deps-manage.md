# Deps Manage

Manage dependencies in the dots repository.

## Arguments

`$ARGUMENTS` can be:
- `add <package>` - Add a new dependency
- `remove <package>` - Remove a dependency
- (empty) - Interactive mode, ask what to do

## Files

Dependencies are defined in OS-specific files:
- `scripts/deps/macos.sh` - Homebrew packages
- `scripts/deps/arch.sh` - Pacman/AUR packages

## Add Flow

### 1. Determine Target OS

Ask: Which OS(es) should this dependency be added to?
- macOS only
- Arch only
- Both

### 2. Get Package Names

For each selected OS, ask:
- What is the package name for [OS]?

Package name formats:
- **macOS**: brew name (e.g., `neovim`, `git-delta`)
- **macOS cask**: `--cask name` (e.g., `--cask 1password`)
- **macOS tap**: `user/repo/package` (e.g., `steveyegge/beads/bd`)
- **Arch**: pacman/AUR name (e.g., `neovim`, `github-cli`)

### 3. Determine Check Method

Ask: How should we check if this is installed?
- `command -v <name>` works (default)
- Custom command check needed
- Check via package manager (for packages without commands)

If custom: What command to check? (e.g., `command -v nvim` for neovim)

### 4. Post-install Hook

Ask: Does this package need any post-install setup?
- No (default)
- Yes - describe what needs to happen

Post-install examples:
- Enable systemd service
- Create symlink
- Add user to group

### 5. Add to File(s)

Add the package to the `DEPS` array in the appropriate file(s).

If custom check needed, add a case to `check_dep()`.

If post-install needed, add a case to `install_dep()`.

### 6. Verify

Run `dots deps list` to confirm the package appears.

## Remove Flow

### 1. Search for Package

Search both `macos.sh` and `arch.sh` for the package name.

### 2. Confirm Removal

Show where the package was found and ask for confirmation.

### 3. Remove from File(s)

Remove from:
- `DEPS` array
- `check_dep()` case (if exists)
- `install_dep()` post-install case (if exists)

### 4. Verify

Run `dots deps list` to confirm removal.

## File Structure Reference

```bash
# DEPS array - add new packages here
DEPS=(
    package1
    package2
    "--cask app"
)

# check_dep - add custom checks here
check_dep() {
    case "$1" in
        neovim) command -v nvim ;;  # Command differs from package
        *) command -v "$1" ;;       # Default: package name = command
    esac
}

# install_dep - add post-install hooks here
install_dep() {
    local dep="$1"
    # ... install logic ...

    case "$dep" in
        docker)
            # Post-install: add user to group
            sudo usermod -aG docker "$USER"
            ;;
    esac
}
```
