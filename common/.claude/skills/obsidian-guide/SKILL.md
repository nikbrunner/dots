---
name: obsidian-guide
description: How to access and navigate my Obsidian notes for task management, journaling, and project context. Load when notes, tasks, or daily planning come up.
user-invocable: false
---

# Obsidian Notes Guide

## When to Access

- When I explicitly ask to check daily tasks or todos
- When the conversation is about task management, planning, or productivity
- When I mention projects and you need context from notes
- When I directly reference notes or ask to look something up
- **NOT automatically at the start of every conversation**

## Obsidian CLI

Obsidian has an official CLI (`obsidian`). **Prefer CLI commands over direct file reads/writes** — the CLI resolves paths, templates, wikilinks, and respects Obsidian's index.

> Note: CLI output includes a loading/version preamble line. Use `2>/dev/null` to suppress stderr noise.

### Daily Notes

```bash
obsidian daily:read                          # Read today's daily note
obsidian daily:path                          # Get daily note file path (works even if note doesn't exist)
obsidian daily:append content="- [ ] Task"   # Append to daily note
obsidian daily:prepend content="## Section"  # Prepend to daily note
obsidian daily                               # Open daily note in Obsidian
```

#### Creating a Daily Note

The `daily:*` commands require the note to exist first. To create today's daily note:

```bash
# Two-step pattern: resolve path, then create at that path
DAILY_PATH=$(obsidian daily:path 2>/dev/null)
obsidian create path="$DAILY_PATH" template="Periodic/Daily Note" 2>/dev/null
```

**Important:** Do NOT use `obsidian create name=` for daily notes — it doesn't resolve the daily note
naming pattern and will create a file with the wrong name. Always use `path=` with the output of
`daily:path`.

### Tasks

```bash
obsidian tasks todo daily                    # Incomplete tasks from daily note
obsidian tasks todo                          # All incomplete tasks vault-wide
obsidian tasks done daily                    # Completed tasks from daily note
obsidian tasks todo verbose                  # Tasks grouped by file with line numbers
obsidian tasks todo format=json              # JSON output for parsing
obsidian task path="path/to/file.md" line=5 done   # Mark specific task done
obsidian task daily line=3 toggle            # Toggle task in daily note
```

### Search

```bash
obsidian search query="search term"                     # Basic vault search
obsidian search:context query="term" path="01 - Projects" limit=5  # Search with context, scoped to folder
```

### Files & Notes

```bash
obsidian read file="Note Name"               # Read by name (wikilink-style)
obsidian read path="01 - Projects/foo.md"    # Read by exact path
obsidian create name="New Note" template="Company"  # Create from template
obsidian append file="Note" content="text"   # Append to any file
obsidian open file="Note Name"               # Open in Obsidian
```

### Properties (Frontmatter)

```bash
obsidian property:read name="tags" file="Note"        # Read a property
obsidian property:set name="status" value="done" file="Note"  # Set a property
obsidian properties file="Note"                        # List all properties for a file
```

### Tags & Backlinks

```bash
obsidian tags counts sort=count              # All tags sorted by usage
obsidian tag name="#project/black-atom-industries"  # Info about specific tag
obsidian backlinks file="Note Name"          # List backlinks to a note
```

### Templates

```bash
obsidian templates                           # List available templates
obsidian template:read name="Company" resolve  # Read template with resolved variables
```

## Vault Structure

- `00 - Inbox` — Capture zone
- `01 - Projects` — Active projects (Black Atom, Sonder, job search)
- `02 - Areas` — Ongoing areas (Health, Finance, Journal, Career)
- `03 - Resources` — Reference materials (Dev, AI, Philosophy)
- `04 - Archive` — Completed/inactive
- `05 - Meta` — Templates, Assets, Scripts
- `06 - GitPad` — Development project notes
- `07 - Read Later` — Saved articles

For periodic note path patterns and date formatting rules, load the `obsidian-dates` skill.

## Fallback: Direct File Access

If the CLI is unavailable, fall back to reading/writing files directly. Load `obsidian-dates` for path patterns. The CLI is preferred because it handles path resolution, template variables, and Obsidian plugin integration (tasks, properties, etc.).

## Wikilinks

**Obsidian wikilinks resolve by filename, NOT by heading or title.** A file at `01 - Projects/Self-Hosting/Calendar.md` is linked as `[[Calendar]]`, not `[[Calendar — Self-Hosted CalDAV]]` or `[[Self-Hosting/Calendar]]`. Always use the bare filename without extension.

## Guidelines

- If asked to save a conversation summary, add it with a dated headline to the conversation history file
- When saving summaries, also capture insights about preferences, knowledge gaps, or learning areas
