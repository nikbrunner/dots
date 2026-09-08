---
name: things
description: Use when the user asks to create, find, schedule, update, complete, delete, or review Things 3 tasks, projects, areas, tags, checklists, or recurring items on macOS.
---

# Things

Use `things` to read from the local Things 3 database and to create/update items through Things. Use Apple Reminders only when the user explicitly asks for Reminders.

## Capture conventions

- Turn a vague request into a concrete next-action title. Preserve the user's wording when they clearly want a verbatim capture.
- Split unrelated actions into separate todos.
- Use Inbox or Anytime by default. Schedule Today only when the user says or clearly implies it.
- Run `date` for calendar arithmetic. Do not guess dates such as “next Tuesday”.
- Invoke the `things` CLI only. Never manipulate its SQLite database directly.

## Safe operating workflow

### Existing items

For an update, completion, move, or delete whose target is not already a trusted UUID:

1. **Read** with `things search`, `things tasks`, or `things templates`.
2. **Identify** the intended row and capture its UUID. If multiple items match, show the candidates and ask the human; never guess by title or recency.
3. **Preview** the exact write with `--dry-run` when the command supports it.
4. **Write** using `--id <UUID>`.
5. **Verify** by re-reading that UUID (and, for recurrence, the resolved template UUID).
6. **Report** what was requested, what was verified, and any remaining uncertainty.

### New items

Create the requested todo or project, then find it by exact title plus creation context and read it back. If more than one candidate matches, ask the human to identify it. For repeating adds, follow the repeat workflow below so the created item can be matched to its template safely.

Reads do not authorize writes. Prefer UUIDs even when a command accepts a title.

Quick start (read)
- `things inbox`
- `things today` follows the app's Today/This Evening order; select `start_bucket,today_index_reference_date,today_index` to inspect its raw ordering metadata.
- `things repeating`
- `things templates`
- `things projects` / `things areas` / `things tags`
- `things tasks --search "query" --json`
- `things tasks --query 'tag:work AND title:/review/i' --format jsonl`
- `things search --query 'tag:PLAN' --select type,title` searches both todos and projects.
- `things show --project "Project Name"`
- `things show --id <TODO_UUID> --recursive --json`

Write (URL scheme)
- `things add "Task title" --notes "..." --list "Project or Area"`
- Checklist items (repeat `--checklist-item` per item): `things add "My task" --checklist-item="Step 1" --checklist-item="Step 2" --checklist-item="Step 3"`
- `things add-project "Project title" --area "Area Name"`
- `things update --id <uuid> --notes "Updated notes"`
- Clear notes by passing an explicit empty notes value: `things update --id <uuid> --notes ""`
- Clear a deadline, scheduled date, or all tags the same way: `things update --id <uuid> --deadline=""`, `--when=""`, or `--tags=""` (also works for `update-project`)
- Checklist status by exact title: `things update --id <uuid> --complete-checklist-item "Step 1"` or `things update --id <uuid> --incomplete-checklist-item "Step 1"`
- Bulk update (preview then apply): `things update --query 'tag:work' --dry-run` then `things update --query 'tag:work' --yes --tags "Work"`
- `things update-project --id <uuid> "New project title"`
- `things rename-project --id <uuid> --title "New project title"`
- `things list-project-tasks --id <project_uuid>`
- `things delete --id <uuid>`
- Bulk delete (preview then apply): `things delete --query 'notes:/deprecated/i' --dry-run` then `things delete --query 'notes:/deprecated/i' --yes`
- Undo last bulk action: `things undo --dry-run` then `things undo --yes`
- `things delete-project --id <uuid>` or `things delete-project "Project title"`
- `things delete-area --id <uuid>` or `things delete-area "Area Name"`
- Move to Someday: `things update --id <uuid> --when=someday`
- Move to This Evening (Later): `things update --id <uuid> --later` (alias for `--when=evening`)

Repeating (database writes)
- Use after-completion mode (the default) when the next copy should depend on completion: `things update --id <UUID> --repeat=week --repeat-every=2`.
- Use schedule mode for a fixed calendar cadence: `things add "Daily standup" --repeat=day --repeat-mode=schedule`.
- `--repeat-start=YYYY-MM-DD` anchors weekday/month/day recurrence. It is not the item's ordinary `--when` schedule.
- `--repeat-deadline=N` adds a deadline so each copy appears in Today N days earlier.
- Bound a schedule with either `--repeat-until=YYYY-MM-DD` (stop after a date) or `--repeat-count=N` (stop after N occurrences). The two are mutually exclusive; count-based rules omit an end date entirely. `--repeat-count=20` creates exactly 20 occurrences.
- `--repeat-clear` removes the repeat rule; omission leaves the existing rule unchanged.
- Repeating projects are supported: `things add-project "Title" --repeat=week --repeat-mode=schedule` and `things update-project --id <UUID> --repeat=...`. Projects support the same repeat flags as todos.
- `things repeating` and `things templates` include both repeating tasks and projects.

Repeat changes must use the full workflow:

```sh
# Existing todo or project: resolve and retain the UUID first.
things templates --search "Monthly bill" --format json --select uuid,title
things update --id <TEMPLATE_UUID> --repeat=month --repeat-mode=schedule \
  --repeat-start=2026-08-01 --repeat-deadline=2 --dry-run
things update --id <TEMPLATE_UUID> --repeat=month --repeat-mode=schedule \
  --repeat-start=2026-08-01 --repeat-deadline=2
things templates --search "Monthly bill" --format json
```

Treat successful output as verified template state, not as proof that Things has already spawned a visible occurrence. Repeating adds first create the item through Things, then locate and update its database row. Things spawns the visible current occurrence on its own schedule (typically a nightly pass), so a verified template may not produce a visible instance until then. If output reports partial success, a non-repeating item may remain:

- When a trusted UUID is reported, re-read that UUID and retry only the missing repeat stage.
- When creation succeeded but identity is unknown, search using the exact title plus creation time/context and ask the human to disambiguate multiple candidates.
- Do not claim rollback, do not interpolate untrusted titles into shell commands, and do not repeat the add blindly.

Filters + DB
- Use `--db` or `THINGSDB` to point to a specific Things database. Accepted forms: the `main.sqlite` file, the `Things Database.thingsdatabase` directory, or the parent `ThingsData-*` directory.
- Common filters: `--filter-project`, `--filter-area`, `--filter-tag`, `--status`, `--search`, `--limit`, `--offset`.
- Rich query: `--query` supports boolean ops, field predicates, and regex (e.g. `title:/regex/ AND tag:work`).
- Repeating tasks and projects: `things repeating` or `--query 'repeating:true'`.
- Repeating templates: `things templates --area "Area Name"` lists hidden template rows that control future recurring instances.
- Date filters: `--created-before/after`, `--modified-before/after`, `--due-before`, `--start-before`.
- URL filter: `--has-url`.
- Sorting: `--sort created,-deadline,title`.
- Output: `--format table|json|jsonl|csv`, `--select uuid,title,status`, `--no-header`. `--json` still works. `today_index_reference_date` is selectable as a raw packed integer but is not a generic `--sort` field.
- `--recursive` includes checklist items in JSON output.

Auth + permissions
- Read-only database commands may require Full Disk Access for the terminal or agent host.
- Ordinary URL-scheme updates require an auth token: run `things auth`, set `THINGS_AUTH_TOKEN`, or pass `--auth-token`.
- The CLI handles repeat-only updates through its database layer, which requires writable database access (normally Full Disk Access), but not a URL token. Never edit the database yourself.
- Repeat adds use the unauthenticated add URL plus the CLI's database layer, so they require writable database access but not a URL token.
- Repeat updates that also change ordinary fields use both paths and require both auth and writable database access.
- Use `--db` or `THINGSDB` only for an explicitly trusted Things database. Check the resolved target shown by preview before writing.
- URL scheme writes can open/foreground Things; use `--dry-run` to print URLs or `--foreground` to force focus.
- Update `--when/--later` is verified against the database by default; use `--no-verify` to skip verification.
- `--later` / `--when=evening` refuses to move tasks that are already scheduled for a non-today date; use `--allow-non-today` to override.
- Titles that look like flag assignments (e.g. `tag=work`) are rejected; pass `--allow-unsafe-title` to keep them as the title.
- For updates, an explicitly provided empty value clears the field (`--notes ""`, `--deadline=""`, `--when=""`, `--tags=""`); omitting the flag leaves the field unchanged.
- Delete commands prompt for confirmation when interactive; pass `--confirm` for single deletes in non-interactive scripts. Query deletes require `--confirm=delete` or `--yes`.
- Bulk update/delete write an action log; use `things undo` to revert the last bulk update or trash.

Notes
- macOS only.
- Use `things --help` and `things <command> --help` for the full flag list.
- Install via Homebrew: `brew install ossianhempel/tap/things3-cli`.
- When working inside the repo, prefer the repo binary (`make build` then `./bin/things`) or `go run ./cmd/things` to pick up local changes.
