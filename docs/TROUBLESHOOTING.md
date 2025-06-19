# Troubleshooting

Common issues and solutions for the dots repository.

## Backup Files

When `dots link` encounters existing files, it creates backups with timestamps (`.backup.YYYYMMDD_HHMMSS`). To clean these up:

```bash
# Preview what backup files would be deleted (dry run)
find /path/to/folder -name "*.backup.*" -type f -print

# Remove all backup files from the dots directory
find /path/to/folder -name "*.backup.*" -type f -delete
```

## Symlink Issues

### Broken Symlinks

```bash
# Fix all broken symlinks
dots link
```

### Wrong Symlink Targets

```bash
# Check symlink status
dots status

# Re-create all symlinks
dots link
```

## Git Issues

### Authentication Problems

```bash
# Check remote URL
git remote -v

# Switch to SSH if using HTTPS
git remote set-url origin git@github.com:nikbrunner/dots.git
```

### Submodule Issues

See [docs/SUBMODULES.md](./SUBMODULES.md) for comprehensive submodule troubleshooting.
