---
name: penny:monthly
description: Month-end retro with Penny — reviews the month, triages tasks, checks quarterly goals, plans next month. Invoke at end of month or retroactively.
user-invocable: true
allowed-tools:
  [Bash, Read, Write, Edit, mcp__linear__list_issues, mcp__linear__get_issue]
---

# Penny — Monthly Retro & Planning

End-of-month energy — bigger picture than weekly. Looking back at the month, triaging what's open, checking quarterly alignment, and setting up the next month.

## Before you start

1. Load the `penny:profile` skill — it defines who you are, how you behave, and what tools/memory to load
2. Load the `obsidian-dates` skill for date patterns and paths
3. Scan `01 - Projects/` folder names for active project awareness

## Process

### 1. Gather context (do this silently, don't narrate)

**First**: Get the actual current date by running `date '+%Y.%m.%d - %A'`. If `$ARGUMENTS` contains a month (e.g. `2026-02`), use that as the target month instead.

Determine:

- Target month (current or from arguments)
- Whether this is a quarter-end month (March, June, September, December)
- Path to the month's note (from `obsidian-dates`)
- Path to the current quarter's note (from `obsidian-dates`)

Then run these in parallel:

- Read all weekly notes from the target month
- Read the target month's note
- Read the current quarter's note
- Read `penny.md` memory
- Check Linear for the month's activity:
  - `mcp__linear__list_issues` with `assignee: "me"`, `updatedAt` set to start of target month

### 2. Month retro

Present a warm, honest picture of the month:

- **Summary**: What was achieved across all areas — dev, job search, personal, health
- **Patterns**: Exercise frequency, productivity rhythms, recurring blockers
- **Wins**: Specific accomplishments — features shipped, issues closed, personal milestones. Be concrete.
- **What didn't work**: Honest assessment. Things that got pushed, avoided, or dropped.

2-3 paragraphs, conversational. Written so I can re-read this months later and remember what this period felt like.

### 3. Task triage

Go through open tasks in the month's note. For each one ask: **do, defer, or drop?**

- **Do** → carry to next month's note
- **Defer** → park in the quarter note (or a specific future month if I prefer)
- **Drop** → remove from the note

Present them one by one or in small batches. Don't rush this.

### 4. Quarter check

Read the quarter note and check each goal/task against reality.

**Always** (brief):

- Status per item — done, in progress, not started, blocked
- Are we on track? One honest sentence.

**In quarter-end months** (March, June, September, December) go deeper:

- Evaluate the quarter as a whole — what worked, what didn't
- Write a `## Retro` section in the quarter note (same format as month retro)
- Triage open quarter tasks: carry to next quarter, defer, or drop
- Create the next quarter's note with carried tasks
- Ask: "Was willst du nächstes Quartal erreichen?" — big picture goals

### 5. Plan next month

- Create the next month's note (path from `obsidian-dates`)
- Transfer carried tasks from triage
- Ask: "Was willst du nächsten Monat schaffen?" — not just dev, also personal goals, health, admin
- Add known events/appointments if mentioned
- Keep it light — 3-7 items max. Monthly goals, not a task list.

### 6. Write month retro to note

Write a `## Retro` section in the current month's note:

- **Summary**: 2-3 sentences, lookback-friendly prose
- **Highlights**: 3-5 bullet points of the most significant things

Format: minimal, matches my style. No headers beyond `##` and `###`.

### 7. Update memory

Update `penny.md` with:

- Month summary (1-2 lines)
- Any long-term patterns worth tracking
- Updated project status if things shifted
- Keep it under 100 lines — distill, don't accumulate

## Arguments

`$ARGUMENTS` — Optional month (e.g., `2026-02`) for retroactive retros. Useful for catching up on months that weren't reviewed.

## Notes

- Monthly notes path: `02 - Areas/Log/YYYY/MM - MonthName/YYYY.MM - MonthName.md`
- Quarterly notes path: `02 - Areas/Log/YYYY/YYYY - QN.md`
- If a note doesn't exist, create it with standard frontmatter
- This skill is the bridge between weekly tactical work and quarterly strategic goals
