---
name: penny-calendar
description: Penny's calendar access — reading events, creating/updating/deleting events via davit CLI + iCloud CalDAV
invocable: true
---

# Penny Calendar

Access my iCloud calendar via `davit` CLI. Used by Penny for scheduling, briefings, and event management.

## Prerequisites

- `davit` must be installed globally (`deno task install` in the davit repo)
- Credentials from env vars managed by ProtonPass in `~/.env`
- **Always run `source ~/.env` before davit commands in Bash**

## Command Reference

**Do not rely on hardcoded examples in this skill.** Always check davit's own help for current syntax:

```bash
davit --help
davit calendar --help
davit event --help
davit event create --help
davit event update --help
```

These are the source of truth for flags, arguments, and options.

## Defaults

- Primary calendar: **iCloud** — always use `--calendar iCloud` unless I specify otherwise
- Use `--format json` when you need to parse output programmatically (e.g. extracting UID after create)

## Rules

- **All timestamps are UTC** — I'm in CET/CEST (UTC+1 winter, UTC+2 summer)
  - Check DST: Germany switches last Sunday of March / last Sunday of October
  - Use `date -u` to verify if unsure
- **Title format**: `Company/Context — What (Who)` — e.g. `ImFusion — Gehaltsgespräch (Mattia Lupetti)`
- **Location format**: Use Apple Maps-compatible addresses — `Straße Nr, Ort, Germany`. No venue prefixes like "Beim Andi" or "Restaurant XY" — these break map lookup. Put venue names in the title or description instead.
- **Use `--calendar iCloud`** on all commands for speed (avoids scanning all calendars)

## Integration with Daily Notes

Mirror important event details in the daily note alongside the calendar event:

1. Create the calendar event (time + title + description + location)
2. Add a task/entry in the daily note with context and wikilinks

Example in daily note:

```markdown
- [ ] 16:00 — Gehaltsgespräch ImFusion (Dr. Mattia Lupetti) 📅 2026-03-17
  - [[ImFusion - Senior Frontend Developer Web UX]]
```

## Known Limitations

- Recurring events show original date only (no RRULE expansion)
- No VALARM/reminder support
- No ATTENDEE support
- Use `--calendar` to limit scope on show/update/delete (avoids expensive all-calendar scan)
