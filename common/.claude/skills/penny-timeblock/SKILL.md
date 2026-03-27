---
name: penny-timeblock
description: Build a timeblocked day plan based on existing calendar events, energy patterns, and context. Creates events via davit CLI.
invocable: true
---

# Penny Timeblock

Plan a timeblocked day for me. Reads existing events, checks context (daily notes, recent patterns), then proposes a balanced day.

## Before you start

1. Load the `penny-calendar` skill for davit CLI reference
2. Load the `obsidian-dates` skill for date handling

## Step 1: Determine the date

- Default: tomorrow
- If I specify a date, use that
- Always verify the day of week with `date` command — never guess

## Step 2: Gather context

### Existing events

```bash
source ~/.env && davit event list --from "<date>T00:00:00Z" --to "<date>T23:59:59Z" --calendar iCloud
```

These are fixed anchors. Plan around them.

### Recent daily notes

Read the last 2-3 daily notes to understand:

- What tasks have been rolling over (stale tasks → suggest admin block)
- What I've been focused on (dev projects → continue or suggest variety)
- Exercise frequency (no movement in 2+ days → prioritize it)
- Admin debt (emails, Steuer, etc. piling up → suggest admin block)

### Active projects

Check what's hot — Linear issues in progress, recent git activity, open PRs.

## Step 3: My Energy Pattern

- **08:00–10:30** — Peak focus. Always deep work. Never admin.
- **10:30–12:00** — Good focus, slightly lower. Interviews, prep, or continued dev.
- **12:00–13:00** — Energy dip. Lunch + movement.
- **13:00–16:00** — Afternoon focus. Mix of deep work and lighter tasks.
- **16:00+** — Wind down. Lower energy activities.

## Step 4: Activity Pool

Pick from these based on context. Not every day needs all of them.

| Activity             | Emoji | Duration   | When                               | Triggers                                                                    |
| -------------------- | ----- | ---------- | ---------------------------------- | --------------------------------------------------------------------------- |
| Morning Routine      | ☕    | 30min      | Always first                       | Every day                                                                   |
| Deep Work            | 🔨    | 1.5–2.5h   | Morning priority                   | Always — choose project based on what's active                              |
| Admin                | 📋    | 30–45min   | Never before 12:00                 | Stale tasks in notes, emails mentioned, Steuer etc.                         |
| Interview Prep       | 📝    | 20–30min   | Before any call                    | Interview/call on the schedule                                              |
| Reading              | 📖    | 30–45min   | Afternoon/evening                  | No interviews, lighter day, hasn't read in a while                          |
| Movement             | 🚶    | 30–60min   | Midday or evening                  | No bouldering/walk in 2+ days                                               |
| Bouldern             | 🧗    | 1.5–2h     | Afternoon/evening                  | Hasn't bouldered in a week+                                                 |
| Lunch                | 🍽️    | 30–60min   | Around 12:00                       | Every day — combine with movement when possible                             |
| Reflection / Journal | 📓    | 20–30min   | Evening                            | Wednesday ritual, or stressful week                                         |
| Job Search           | 🔍    | 45–60min   | Late morning/afternoon             | Active job hunting, no new applications in a while                          |
| Project Planning     | 🗺️    | 30–45min   | Morning (after deep work)          | New project starting, unclear next steps                                    |
| Free / Buffer        | 🎯    | 15–30min   | Before calls, between blocks       | Before interviews, after intense blocks                                     |
| Meditation           | 🧘    | 15–20min   | Morning or before stressful events | Before interviews, stressful days, or hasn't done it in a while             |
| Musik hören          | 🎧    | 30–60min   | Afternoon/evening                  | Aktives Hören (Vinyl, neue Alben) — nicht Hintergrund. Recharge-Aktivität   |
| WoW / Gaming         | 🎮    | Open-ended | Evening                            | Social time with Olli, no need to schedule — just don't over-block evenings |

### Rules

- **15min buffer before interviews/calls** — never schedule back-to-back into a call
- **No blocks before 08:00 or after 18:00** — respect personal time
- **Deep Work always gets the morning** — non-negotiable
- **Admin never before 12:00** — peak hours are for creative work
- **Don't over-schedule** — leave gaps. A full wall of blocks is stressful, not productive
- **Movement is a nudge, not a mandate** — suggest it, don't force it every day

## Step 5: Propose the plan

Show as a markdown table. Explain your reasoning briefly — why these activities, why this order.

```
Hier ist mein Vorschlag für [Tag]:

[1-2 Sätze warum dieser Mix — z.B. "Kein Bouldern seit Donnerstag, Admin stapelt sich"]

| Zeit | Block |
|-|-|
| 08:00–08:30 | ☕ Morning Routine |
| ... | ... |

Passt das? Soll ich was ändern?
```

**Always ask before creating events.** Never auto-create.

## Step 6: Create events

Only after I confirm. Use davit CLI:

```bash
source ~/.env && davit event create "Block Name" \
  --start "<UTC time>" --end "<UTC time>" \
  --desc "Description" --calendar iCloud
```

- **All times UTC** — I'm in CET (UTC+1 winter) / CEST (UTC+2 summer)
- Check DST: Germany switches last Sunday of March / last Sunday of October

## Arguments

`` — Optional: date ("morgen", "Freitag", "2026-03-20") or hints ("dev day", "light day", "hab viel admin")
