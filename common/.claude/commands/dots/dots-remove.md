# Dots Remove

Remove a config from dots symlink management.

## Arguments

`$ARGUMENTS` can be:
- A symlink path (e.g., `~/.config/gamemode.ini`)
- A dots repo path (e.g., `arch/.config/gamemode.ini`)

## Instructions

### 1. Identify the Config

If given a symlink path:
```bash
# Check if it's a symlink pointing to dots
readlink -f "<path>"
```

If given a dots repo path, verify it exists in the repo.

### 2. Find Entry in symlinks.yml

Search for the entry in `symlinks.yml` and identify:
- Which section it's in (common/arch/macos)
- The full entry line

### 3. Confirm Removal

Ask for confirmation:
- Remove from symlinks.yml? (always yes for this operation)
- Delete the file from dots repo? (ask - user might want to keep it)
- Remove related dependency from deps.sh? (ask if applicable)

### 4. Remove from symlinks.yml

Edit `symlinks.yml` to remove the entry from the appropriate section.

### 5. Handle the Symlink

```bash
# Remove the symlink
rm "<symlink-path>"
```

If user wants to keep using the config (just not managed by dots):
```bash
# Copy from dots to original location
cp "$DOTS_DIR/<section>/<path>" "<original-path>"
```

### 6. Optionally Delete from Repo

If user confirmed deletion:
```bash
rm "$DOTS_DIR/<section>/<path>"
# Remove empty parent directories
rmdir --ignore-fail-on-non-empty -p "$(dirname "$DOTS_DIR/<section>/<path>")"
```

### 7. Optionally Remove from deps.sh

If removing a dependency:
1. Remove from `REQUIRED_DEPS` array
2. Remove `check_dependency` case
3. Remove `get_package_name` cases

### 8. Clean Up

```bash
# Run dots link to clean any broken symlinks
dots link
```

## Output

Report what was done:
- Removed from symlinks.yml: yes/no
- File deleted from repo: yes/no
- Dependency removed from deps.sh: yes/no
- Symlink removed: yes/no
- Config copied back: yes/no

## Maintenance Note

After running `dots link`, check for errors about missing sources. If any exist, there are stale entries in `symlinks.yml` that should be removed. This can happen when files are deleted manually without using this skill.
