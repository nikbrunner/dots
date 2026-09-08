---
name: changelog-things
description: Use when Nik asks to log today’s development work, commits, GitHub activity, or a changelog as completed Things items instead of updating an Obsidian daily note.
user-invocable: true
---

# Changelog Things

Record collected development activity as completed Things todos. Keep the `changelog` skill for daily notes; this skill only uses Things.

## Collect activity

1. Set the target date from `$ARGUMENTS` when it is `YYYY-MM-DD`; otherwise use the local calendar date.
2. Run the existing collector from the vault root:

```bash
ACTIVITY_REPORT=$(mktemp)
node --no-warnings --experimental-strip-types .agents/skills/changelog-things/scripts/collect-activity.ts --date YYYY-MM-DD --root "$HOME/repos" > "$ACTIVITY_REPORT"
```

3. Read the JSON unchanged. Collector errors are reportable data. Keep successful local activity when GitHub collection fails.

## Create completed todos

Create one todo for every pull request, issue, and substantive commit. Open GitHub state is source metadata, not the completion state of the Things record.

Skip routine backups, formatting-only commits, WIP/index snapshots, and ignore-only `PLAN.md` housekeeping. Judge the subject, not the conventional-commit type.

Use these values for each item:

| Item | Title | Source URL |
| --- | --- | --- |
| Commit | `[owner/repository] subject` | Commit URL |
| Pull request | `[owner/repository] PR #NUMBER: title` | Pull request URL |
| Issue | `[owner/repository] Issue #NUMBER: title` | Issue URL |

Use the source URL as the deduplication key. Keep the task title human-readable and put only the source URL in the notes. Before adding a todo, search all Things states for the exact URL:

```bash
things search "$URL" --status any --format json
```

If a match exists, skip it. Otherwise create the completed todo for the target date:

```bash
things add --when YYYY-MM-DD --completed --completion-date YYYY-MM-DD \
  --notes "$URL" \
  "$TITLE"
```

`things add` has no dry-run mode. Print the title, target date, and URL before running it.

Verify every add by searching for its URL, capture the returned UUID, then read it:

```bash
things show --id "$UUID" --json
```

The search result must contain exactly the expected URL as the notes, and the shown todo must be completed and scheduled for the target date. Stop and report any item that cannot be verified. Do not create another one to retry.

## Report

State the target date and counts for created, existing, skipped-noise, and failed items. List collector errors verbatim. Do not read or edit a daily note.

## Arguments

`$ARGUMENTS` may be a date in `YYYY-MM-DD` format.
