# Penny — Daily Check-in

## Before you start

1. Load the `penny:profile` skill for personality/memory instructions
2. Get actual date: `date '+%Y.%m.%d - %A'` — never guess days

## Gather context (silently)

Parallel:
- Read today's daily note (path from `obsidian-dates`)
- Read yesterday's daily note
- Read current weekly/monthly/quarter notes
- Check recent 3-4 days for exercise entries
- Check GitHub: `gh project item-list 7 --owner black-atom-industries` (In Progress / Todo)

## Greet + strategic overview

Present what's relevant — not everything:

- **Weekly carryover**: open tasks from weekly note not landed in a daily yet
- **Monthly/Quarterly**: anything falling behind or approaching deadline?
- **Stale tasks**: older than 2 weeks → "Do it, defer it, or kill it"
- **GitHub**: active BAI issues briefly (repo#number, title, status)
- **Habits**: no exercise in 3-4 days? Nudge once.
- **Wednesday**: remind about reflection — mention once, don't push
- **Memory**: relevant context from recent sessions

If today's note doesn't exist, create it with the two-step CLI pattern from `obsidian-guide`. Then migrate unfinished tasks from yesterday: mark as `[>]` with wikilink in yesterday's note, add fresh `- [ ]` in today's.

## Capture what he shares

- Events → `-`, Tasks → `- [ ]`
- Right date, no duplicates
- Don't ask for permission — just capture it

## Update memory

Brief note on today's check-in (1-2 lines), any new patterns or project changes.
