# Dots Add

Add a config file to the dots repository for symlink management.

## Arguments

`$ARGUMENTS` should be the path to an existing config file (e.g., `~/.config/gamemode.ini`)

## Instructions

### 1. Validate Input

- Expand `~` to `$HOME` if present
- Verify the file exists
- Check it's not already a symlink pointing to dots

### 2. Determine Target Location

Ask which section this belongs to:
- `common/` - Cross-platform configs (default)
- `arch/` - Arch Linux specific
- `macos/` - macOS specific

The file structure should mirror the home directory:
- `~/.config/foo/bar.conf` → `<section>/.config/foo/bar.conf`
- `~/.zshrc` → `<section>/.zshrc`

### 3. Copy File to Dots

```bash
# Create parent directory if needed
mkdir -p "$(dirname "$DOTS_DIR/<section>/<relative-path>")"
# Copy the file
cp "<source-file>" "$DOTS_DIR/<section>/<relative-path>"
```

### 4. Update symlinks.yml

Add entry to the appropriate section in `symlinks.yml`:
```yaml
<section>:
  <section>/<relative-path>: ~/<relative-path>
```

Keep entries alphabetically sorted within each section.

### 5. Ask About Dependencies

If this config is for a specific tool/package, ask:
- Should this tool be added to `deps.sh`?
- If yes, get the package name for each OS

If adding to deps.sh:
1. Add to `REQUIRED_DEPS` array with description
2. Add `check_dependency` case if needed
3. Add `get_package_name` cases for macos and arch

### 6. Create Symlink

```bash
# Remove original file
rm "<source-file>"
# Run dots link to create symlink
dots link
```

### 7. Verify

```bash
# Confirm symlink was created
ls -la "<source-file>"
```

## Output

Report what was done:
- File copied to: `<dots-path>`
- Added to symlinks.yml: `<section>`
- Dependency added: yes/no
- Symlink created: yes/no
