---
name: Readwise CLI
description: Nik uses @readwise/cli for terminal access to Reader library, highlights, and saved articles — installed 2026-04-03
type: reference
---

Nik installed the Readwise CLI (`@readwise/cli` via npm) on 2026-04-03. It provides terminal/AI-agent access to his Readwise Reader library.

**CLI commands:** `readwise readwise-search-highlights`, `readwise reader-list-documents`, `readwise reader-search-documents`, `readwise readwise-get-daily-review`, `readwise reader-list-tags`, etc. Use `--json` for machine-readable output. Library has 3,489 documents.

**Readwise skills (installed 2026-04-03 via readwise-skills plugin):**

- `readwise:triage` — Inbox triage, one doc at a time with personalized pitches
- `readwise:feed-catchup` — RSS feed catch-up, highlights + full browse
- `readwise:quiz` — Self-test on recently read documents
- `readwise:surprise-me` — Analyze reading history, surface surprising insights
- `readwise:build-persona` — Build personalized reading profile (used by other skills)
- `readwise:reader-recap` — Briefing on recent reading activity
- `readwise:book-review` — Long-form book review from highlights
- `readwise:now-reading-page` — Generate a "Now Reading" webpage
- `readwise:highlight-graph` — Visualize highlights as interactive 2D graph

**How to apply:** Use CLI + skills when Nik asks about saved articles, highlights, or reading history. Integrate with Penny routines — e.g. `readwise:reader-recap` in weekly retros, `readwise:triage` for inbox cleanup sessions, `readwise:surprise-me` for fun insights. The `readwise:build-persona` profile can inform how Penny understands Nik's interests.
