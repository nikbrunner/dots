# Claude Code Project Memories

Claude Code's per-project memory files, tracked via symlinks.

On first discovery, `dots chores` moves memory files from `~/.claude/projects/*/memory/` into this directory and replaces the originals with symlinks pointing back here. Claude Code then reads and writes directly through the symlinks, so this directory is always up to date.

Subsequent `dots chores` runs just commit any changes.

## Directory Structure

Project directories are resolved against `~/repos/` for readable names:

```
~/.claude/projects/-Users-nbr-repos-black-atom-industries-core/memory/
→ symlink → claude-memories/black-atom-industries/core/
```
