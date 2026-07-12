---
name: imf-notes-daily-portfolio-checkin
description: "imf-notes-daily close mode must include a full-portfolio Jira check-in, not just reconcile today's note — and never auto-carry open tickets to tomorrow without asking"
metadata:
  node_type: memory
  type: feedback
  originSessionId: c103311f-b151-46e7-b0ce-38b500b56668
---

The `imf-notes-daily` close-out (see project `imf-notes` skill at `.claude/skills/imf-notes-daily/SKILL.md`) must do a standing "meeting with yourself" step each close: pull every open Jira issue assigned to Nik (not just what today's note/commits touched), and proactively surface stale items, status/reality mismatches, and shifts in focus (e.g. commits clustering somewhere the open-ticket list doesn't reflect) — as recommendations to react to, not asserted facts.

**Why:** On 2026-07-01, I carried "[WEBSDK-184] Continue migrating Explorer to Storybook" onto the next day's note purely because the Jira ticket was still open — Nik never said that was next. He called this out twice: once for the silent carry-forward, and once for how I framed a lucky guess as if it validated the whole inference process ("turns out my guess was right" — but I'd only checked the one ticket I already knew about, not the other ~8 open ones, and hadn't actually done a portfolio-level check). Open ticket status is a signal to _ask about_, never a fact to auto-populate onto tomorrow's plate.

**How to apply:** During close-out, after writing the timesheet and before rebuilding tomorrow's note, run the portfolio check-in step (added to SKILL.md step 5): query all open assigned issues, look for staleness/mismatch/shift signals, bring them to Nik as questions, and only carry forward what his answers (interview + portfolio check-in) actually confirmed. Related: [[project-web-ui-portal-shift]] is the kind of shift this check-in is meant to catch.
