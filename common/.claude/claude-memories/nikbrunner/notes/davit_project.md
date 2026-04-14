---
name: davit — CalDAV/CardDAV CLI
description: Nik's CalDAV + CardDAV CLI tool — replaces caldav-mcp, used by Penny for calendar access
type: project
---

davit ("DAV it") is a Deno CLI tool for CalDAV (calendar) and CardDAV (contacts) CRUD. Built 2026-03-16/17, shipped v1.0.0 same week.

**Why:** caldav-mcp was too limited (4 commands, no update, no description). Nik wanted full calendar access for Penny without self-hosting. Built on tsdav library + iCloud CalDAV.

**How to apply:** Use `davit --help` as source of truth for CLI commands. Penny accesses calendar via `penny-calendar` skill which calls davit via Bash. Config at `~/.config/davit/config.toml`, password from `DAVIT_ICLOUD_PASSWORD` env var (ProtonPass via pp-env-sync).

## Key Details

- Repo: `~/repos/nikbrunner/davit` / github.com/nikbrunner/davit
- Globally installed: `~/.deno/bin/davit`
- Natural language dates: `--from today --to "next friday"`
- Supports: events (CRUD + location, URL, description) + contacts (CRUD)
- caldav-mcp has been removed from Claude Code MCP config
- Project note: `01 - Projects/Self-Hosting/Calendar.md`

## Origin Story

Born from a Penny session (2026-03-16) where Nik wanted calendar integration. Started with caldav-mcp, hit limitations, researched tsdav, designed architecture, created repo, Claude built v1 overnight. Nik reviewed, tested, iterated. Name chosen together — "DAV it" = CalDAV + CardDAV + "do it".
