---
name: dots-manage
description: Add or remove a config file from dots symlink management
argument-hint: "add <path> | remove <path>"
---

# Dots Manage

Add or remove a config file from the dots symlink management system.

## Usage

```
add <path>     Add an existing config file to dots
remove <path>  Remove a config from dots management
```

`<path>` can be an absolute path, a symlink path, or a dots repo-relative path.

---

## Add

### 1. Validate Input

- Expand `~` to `$HOME` if present
- Verify the file exists
- Check it's not already a symlink pointing to dots

### 2. Determine Target Location

Ask which section this belongs to: `common/` (default), `arch/`, or `macos/`.

The file structure should mirror the home directory:
- `~/.config/foo/bar.conf` → `<section>/.config/foo/bar.conf`
- `~/.zshrc` → `<section>/.zshrc`

### 3. Copy File to Dots

```bash
mkdir -p "$(dirname "$DOTS_DIR/<section>/<relative-path>")"
cp "<source-file>" "$DOTS_DIR/<section>/<relative-path>"
```

### 4. Update symlinks.yml

Add entry to the appropriate section, keeping entries alphabetically sorted.

### 5. Ask About Dependencies

If this config is for a specific tool/package, ask whether to add it as a dependency.

### 6. Create Symlink

```bash
rm "<source-file>"
dots link
```

### 7. Verify

```bash
ls -la "<source-file>"
```

---

## Remove

### 1. Identify the Config

If given a symlink path or dots repo path, find the entry in `symlinks.yml`.

### 2. Confirm Removal

Ask for confirmation on removing from symlinks.yml, deleting the file from the repo, and removing related dependencies.

### 3. Edit symlinks.yml

Remove the entry from the appropriate section.

### 4. Handle the Symlink

```bash
rm "<symlink-path>"
```

If the user wants to keep using the config (just unmanaged):
```bash
cp "$DOTS_DIR/<section>/<path>" "<original-path>"
```

### 5. Optionally Delete from Repo

```bash
rm "$DOTS_DIR/<section>/<path>"
```

### 6. Clean Up

```bash
dots link
```

---

## Output

Report what was done and which steps were skipped.

## Maintenance Note

After running `dots link`, check for errors about missing sources — these indicate stale entries in `symlinks.yml`.
