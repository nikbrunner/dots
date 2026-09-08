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

| Item | Title | Marker |
| --- | --- | --- |
| Commit | `[owner/repository] subject` | `changelog-activity:DATE:commit:FULL_SHA` |
| Pull request | `[owner/repository] PR #NUMBER: title` | `changelog-activity:DATE:pull-request:owner/repository#NUMBER` |
| Issue | `[owner/repository] Issue #NUMBER: title` | `changelog-activity:DATE:issue:owner/repository#NUMBER` |

Put the source URL and marker in the notes. Before adding a todo, search all Things states for the exact marker:

```bash
things search "$MARKER" --status any --format json
```

If a match exists, skip it. Otherwise create the completed todo for the target date:

```bash
things add --when YYYY-MM-DD --completed --completion-date YYYY-MM-DD \
  --notes "$URL
$MARKER" \
  "$TITLE"
```

`things add` has no dry-run mode. Print the title, target date, URL, and marker before running it.

Verify every add by searching for its marker, capture the returned UUID, then read it:

```bash
things show --id "$UUID" --json
```

The result must be a completed todo scheduled for the target date, with the expected URL and marker. Stop and report any item that cannot be verified. Do not create another one to retry.

## Report

State the target date and counts for created, existing, skipped-noise, and failed items. List collector errors verbatim. Do not read or edit a daily note.

## Arguments

`$ARGUMENTS` may be a date in `YYYY-MM-DD` format.
