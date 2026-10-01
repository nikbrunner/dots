---
name: nbr-audit
description:
  "Audit a project against Nik's conventions (`nbr-conventions`) without changing files. Use for a project health check, a
  pre-refactor review, or one named topic. Reports broken, missing, and deviating code with evidence, then an ordered plan."
argument-hint: "[full | typescript | react | css | state | tanstack | agent-tooling] [path]"
allowed-tools: Read Glob Grep
---

# Convention audit

A read-only audit: compare the project with the `nbr-conventions` topics, report evidence, and end with work Nik can approve.
A gap against a convention is a finding; a stated, deliberate reason to differ makes it a low-severity Deviation.

## Workflow

1. Resolve the scope. No argument means `full`: `agent-tooling` plus the code topics the project's stack uses
   (`package.json`, file extensions). A named topic audits that topic only; an unknown topic is an error. An optional path
   narrows the files.
2. Read [`REPORT.md`](../nbr-conventions/templates/REPORT.md) and the in-scope blocks of
   [`AUDIT_CHECKLIST.md`](../nbr-conventions/templates/AUDIT_CHECKLIST.md).
3. Dispatch one investigator subagent per topic with its topic file, its checklist block, the path, and the report format.
   Investigators use `Read`, `Glob`, and `Grep` only, check every rule in their block, and return findings without writing.
   The returned reports are the evidence: merge them without re-reading the files. Inspect a topic inline only when its
   dispatch fails, and say so.
4. Merge into the `REPORT.md` format. Check that every Broken, Missing, Deviation, and Unverified entry has severity,
   `path:line` evidence, impact, and a next action. Observations outside the checklist go under Suggestions.
5. Order the next actions into a plan, grouped by topic, cheapest first. Present report and plan, and wait: the audit changes
   nothing.

The audit is done when every in-scope checklist rule has a class with evidence.

Write `AUDIT_REPORT.md` only when Nik asks for a durable report, with exactly the template's headings, preserving `## Reviewer
notes` verbatim.
