---
name: penny-calendar
description: Penny's calendar access — reading events, creating/updating/deleting events via davit CLI + iCloud CalDAV
invocable: true
---

# Penny Calendar

Access Nik's iCloud calendar via `davit` CLI. Used by Penny for scheduling, briefings, and event management.

## Prerequisites

`davit` must be installed globally (`deno task install` in the davit repo). Credentials come from env vars (`CALDAV_BASE_URL`, `CALDAV_USERNAME`, `CALDAV_PASSWORD`) — sourced from `~/.env`.

**Always run `source ~/.env` before davit commands in Bash.**

## Commands

### List calendars

```bash
source ~/.env && davit calendar list
```

Primary calendar: **iCloud**. Always use `--calendar iCloud` unless Nik specifies otherwise.

### List events

```bash
source ~/.env && davit event list --from "2026-03-17T00:00:00Z" --to "2026-03-17T23:59:59Z" --calendar iCloud
```

- Use for morning briefings (penny:daily) — show today's agenda
- Use before creating events — check for conflicts
- Without `--calendar`, lists from all calendars
- Recurring events show original date (no RRULE expansion yet)

### Show event details

```bash
source ~/.env && davit event show <uid> --calendar iCloud
```

Shows: title, start, end, description, location, URL, calendar.

### Create event

```bash
source ~/.env && davit event create "Title" \
  --start "2026-03-17T15:00:00Z" \
  --end "2026-03-17T15:30:00Z" \
  --desc "Notes and details" \
  --location "ImFusion GmbH, München" \
  --url "https://meet.google.com/abc" \
  --calendar iCloud
```

### Update event

```bash
source ~/.env && davit event update <uid> \
  --title "New Title" \
  --desc "Updated notes" \
  --location "New Location" \
  --start "2026-03-17T16:00:00Z"
```

Only pass the fields you want to change. Omitted fields stay unchanged.

### Delete event

```bash
source ~/.env && davit event delete <uid> --calendar iCloud
```

## Rules

- **All timestamps are UTC** — Nik is in CET/CEST (UTC+1 winter, UTC+2 summer)
  - 16:00 CET = 15:00 UTC (winter) | 16:00 CEST = 14:00 UTC (summer)
  - Use `date -u` to verify if unsure
- **Title format**: `Company/Context — What (Who)` — e.g. `ImFusion — Gehaltsgespräch (Mattia Lupetti)`
- **Use `--calendar iCloud`** on all commands for speed (avoids scanning all calendars)
- **Use `--format json`** when you need to parse output programmatically (e.g. extracting UID after create)

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
- getEvent fetches all objects per calendar (no server-side UID filter) — use `--calendar` to limit scope
