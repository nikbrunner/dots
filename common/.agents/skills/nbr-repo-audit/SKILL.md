---
name: nbr-repo-audit
description:
  "Audit a project against Nik's conventions (`nbr-repo-conventions`) without changing files: code topics, agent setup,
  Git hooks, the workflow kit and its release pipeline, and dependency upgrades. Use for a project health check, a
  pre-refactor review, a drift check after setup, or one named topic. Reports broken, missing, and deviating pieces with
  evidence, then an ordered plan."
argument-hint:
  "[full | typescript | react | css | state | tanstack | agent-tooling | hooks | workflow | dependencies] [path]"
allowed-tools: Read, Glob, Grep, Bash(git log:*), Bash(git tag:*), Bash(git config --get:*), Bash(gh repo view:*), Bash(gh release view:*), Bash(gh pr list:*)
---

# Repo audit

A read-only audit: compare the project with the `nbr-repo-conventions` topics, report evidence, and end with work the
maintainer can approve. A gap against a convention is a finding; a stated, deliberate reason to differ makes it a
low-severity Deviation.

Bash runs read-only `git` and `gh` queries only (`git log`, `git tag`, `git config --get`, `gh release view`,
`gh pr list`, and `gh api` GETs, which ask first since a prefix cannot tell GET from PUT). Nothing that writes, installs,
or builds. A check that needs more is Unverified, with the command that would settle it.

## Workflow

1. Resolve the scope. No argument means `full`: every topic that applies to the repo. The code topics follow the stack
   (`package.json`, file extensions); `agent-tooling` and `hooks` always apply; `workflow` applies when the repo has a
   GitHub remote and any kit piece exists; `dependencies` applies when a `repo-dep-upgrades` skill exists. A named topic
   audits that topic only; an unknown topic is an error. An optional path narrows the files.
2. Read [`REPORT.md`](../nbr-repo-conventions/templates/REPORT.md) and the in-scope blocks of
   [`AUDIT_CHECKLIST.md`](../nbr-repo-conventions/templates/AUDIT_CHECKLIST.md). The `workflow` template-drift rule compares
   against [`nbr-repo-setup/templates/`](../nbr-repo-setup/templates/).
3. Dispatch one investigator subagent per topic with its topic file, its checklist block, the path, and the report format.
   Investigators use `Read`, `Glob`, and `Grep`, plus the read-only `git` and `gh` queries above for `hooks` and
   `workflow`; they check every rule in their block and return findings without writing. The returned reports are the
   evidence: merge them without re-reading the files. Inspect a topic inline only when its dispatch fails, and say so.
4. Merge into the `REPORT.md` format. Check that every Broken, Missing, Deviation, and Unverified entry has severity,
   evidence (`path:line` or the command and its output), impact, and a next action. Observations outside the checklist go
   under Suggestions.
5. Order the next actions into a plan, grouped by topic, cheapest first. A missing tooling piece names
   `nbr-repo-setup <topic>` as its fix. Present report and plan, and wait: the audit changes nothing.

The audit is done when every in-scope checklist rule has a class with evidence.

Write `AUDIT_REPORT.md` only when the maintainer asks for a durable report, with exactly the template's headings,
preserving `## Reviewer notes` verbatim.
