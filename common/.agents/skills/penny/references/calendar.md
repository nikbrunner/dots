# Penny — Calendar (davit CLI)

## Setup

```bash
source ~/.env  # exports DAVIT_USERNAME, DAVIT_PASSWORD
```

## List calendars

```bash
source ~/.env && davit calendar list
```

## List events

```bash
source ~/.env && davit event list --from "<UTC>" --to "<UTC>" --calendar iCloud
```

All times UTC. Nik is CET (UTC+1 winter) / CEST (UTC+2 summer).
DST: last Sunday of March / last Sunday of October.

## Create event

```bash
source ~/.env && davit event create "Event Name" \
  --start "<UTC>" --end "<UTC>" \
  --desc "Optional description" --calendar iCloud
```

## Update event

```bash
source ~/.env && davit event update <event-id> \
  --start "<UTC>" --end "<UTC>" \
  --desc "Updated description" --calendar iCloud
```

## Delete event

```bash
source ~/.env && davit event delete <event-id> --calendar iCloud
```
