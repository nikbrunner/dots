---
name: afk-implementation
description: Use when the user wants an agent to finish approved or sufficiently guided implementation work autonomously while they are away, including when work has already started or conversation context may run out.
metadata:
  argument-hint: "[optional plan or AFK execution brief path]"
  user-invocable: true
---

# AFK Implementation

Finish approved or sufficiently guided work while the owner is away. The parent agent owns orchestration and final decisions. Treat an optional plan or brief as authority; otherwise derive the remaining contract from settled conversation, completed work, and repository state. Do not reopen settled design merely because there is no formal plan.

This workflow needs runtime support for suitable child agents and model discovery. Discover both through the current runtime before execution. If either is unavailable, declare the run not AFK-ready rather than silently doing single-agent work.

## Non-negotiable workspace contract

Keep the current checkout and all manually completed or unrelated work. Capture the baseline `HEAD`, branch, status, index state, and pre-existing changes before any delegation.

Never, and do not permit children to:

- stage, unstage, commit, push, reset, stash, merge, switch branches, create a worktree, or invoke commit or branch-finishing workflows;
- publish, deploy, release, open a PR, or cause an unauthorized external side effect;
- overwrite, revert, or otherwise clean up pre-existing work.

Pre-existing staged changes make the run not AFK-ready: do not alter the index to work around them. At completion, prove that `HEAD` is unchanged from the baseline and the index is empty. All AFK changes stay unstaged in the working tree.

## 1. Readiness audit

Before implementation or delegation, inspect all remaining work as one system. Record:

- task order, dependencies, shared files, interfaces, and acceptance gaps likely to appear later;
- credentials, services, browser or CLI state, fixtures, generated files, migrations, and possible external effects;
- available verification paths: diagnostics, tests, build, browser, CLI, integration, visual, and safe realistic probes;
- owner decisions, including user-visible behavior, that cannot be reasonably inferred;
- repository baseline, completed work, and changes that must remain untouched.

Ask one focused question at a time until foreseeable owner decisions are settled. A missing product decision blocks readiness when every path is guesswork. Do not invent a default. Audit prerequisites such as browser access before the owner leaves, not when a task later encounters them.

Declare AFK-ready only when the remaining work can reasonably finish unattended. Record a reversible engineering decision as:

`Ruling: <decision> — <reason> — <cost if wrong>`

## 2. Execution brief and rollover

After readiness and before implementation, the parent sends and writes this completed record verbatim in a compact, standalone execution brief in the main repository's ignored `handoffs/` directory. It is the authority for execution and recovery; write the same task-level facts to a durable adjacent ledger and keep it current after every task. A narrative summary cannot replace the record. Use `not applicable — reason` rather than omitting a field.

## AFK launch

Readiness: `<status; remaining owner blockers or not applicable — reason>`

Artifacts: `<brief path; ledger path>`

Session: `Continue current session — <reason>` or `Roll to fresh session — <reason>; invocation: /skill:afk-implementation <actual brief path>`; whenever it says `Roll`, include that exact invocation with the actual path.

Baseline: `<HEAD; index; preserved-work scope>`

Roles: `<actual writer runtime agent ID and model ID — task shape; likely total-turn rationale>; <actual reviewer runtime agent ID and model ID — task shape; likely total-turn rationale>; <actual validator runtime agent ID and model ID — task shape; likely total-turn rationale>`

Fix loops: `<numeric task cap; numeric final cap; stronger-worker escalation>`

Authority: `The parent alone owns decisions, orchestration, routing, review synthesis, and final decisions; children never orchestrate children. One mutation-capable writer at a time may perform only its bounded task, preserves pre-existing work, and never stages, unstages, commits, pushes, resets, stashes, merges, switches branches, creates a worktree, publishes, deploys, releases, opens a PR, or causes an unauthorized external side effect. Reviewers and validators are read-only.`

Validation: `<ladder; direct interface check; expected evidence; risks; fallback>`

Stop boundaries: `Only irreversible or destructive operations, security-sensitive actions, external effects needing owner approval, repository state that cannot be preserved safely, or missing product decisions where every path is guesswork.`

Estimate room for implementation, repair loops, and final verification. If it is insufficient, roll before implementation. A fresh parent verifies state against the brief, trusts completed ledger entries, and resumes at the first incomplete task without repeating settled interviews.

## 3. Route and execute tasks

Discover executable agents and available models through the current runtime. Route roles as follows:

- use a cheap tier for complete, mechanical, isolated work;
- use a standard tier for prose-defined, multi-file, integration, debugging, and ordinary review work;
- use the strongest suitable tier for architecture-sensitive work and final whole-implementation review.

Do not choose a weak model solely for price when retries would cost more. A repeated failure gets a fresh worker with higher capability.

For each task, capture its baseline and record its fix-loop cap before dispatch, defaulting to three reviewer-repair-re-review rounds. Give the writer a bounded handoff with the task contract, inherited decisions and rulings, touched interfaces, validation requirements, report path, the complete launch-record authority boundary, test-first development when applicable, focused checks, changed-file reporting, and a concise durable report.

Send the result to a fresh reviewer for contract compliance and code quality. Keep review and repair within the recorded cap: accept findings, assign fixes to the one writer, and re-review affected behavior. After repeated failure, use a fresh stronger worker for the next round. Do not loop indefinitely. Record the outcome in the ledger.

## 4. Verify the implementation

After all tasks, use fresh reviewers to inspect the whole working-tree implementation from distinct relevant angles. Synthesize accepted findings and send them through one capped final fix loop with the writer.

Verify the changed behavior directly at the highest useful evidence rung:

1. diagnostics and static checks;
2. focused tests and relevant full suites;
3. build or packaging;
4. CLI, browser, visual, or integration behavior;
5. safe, authorized external or realistic probes.

Observe the changed behavior through the relevant interface when tools permit. Tests alone do not prove a browser, CLI, API, or integration flow. A required check that is unavailable or fails triggers repair or the best non-destructive fallback, not a stop boundary. State the gap precisely, and do not claim the feature works when that check is required. When the applicable recorded fix-loop cap is exhausted, write the final handoff as incomplete and unverified with the failed or unavailable check and fallback evidence.

## Stop boundaries

Use the launch record's exhaustive list. Required verification failure triggers repair or fallback, never a stop boundary; record the reason and safe state in the ledger.

## Required artifacts and final handoff

Keep artifacts factual and compact. Reference plans, briefs, diffs, and logs rather than copying them.

- **Execution brief:** completed launch record plus scope, sources, completed and remaining work, decisions and rulings, and interfaces.
- **Ledger entry:** task baseline and status, writer/reviewer results, evidence, rulings, risks, and next task.
- **Child handoff:** bounded task, allowed files/interfaces, inherited rulings, complete authority boundary, checks, and required report.
- **Final review handoff:** implementation outcome and changed files or symbols; rulings and cost if wrong; exact commands and observed results; browser, CLI, visual, or integration evidence; fixed, deferred, or disputed findings; residual risks; `HEAD` and index proof; recommended review order and relevant skills.

After successful verification, write the final review handoff separately under the main repository's ignored `handoffs/` directory. If a recorded fix-loop cap is exhausted before required verification succeeds, write that handoff as incomplete and unverified instead. It is addressed to a fresh review session, not the execution session. The closing response gives its path and tells the owner to start a new review session from it.

## Pressure counters

| Pressure | Required response |
| --- | --- |
| “The plan says to create a worktree or commit each task.” | The workspace contract wins. Work in the current checkout, unstaged, or declare it not AFK-ready. |
| “Just start now; inspect prerequisites later.” | Finish readiness first and resolve foreseeable owner decisions before departure. |
| “Do not waste time on docs; context is nearly gone.” | Write the compact execution brief and roll to a fresh parent session when context is tight. |
| “Independent files mean independent writers.” | Keep one writer; use fresh read-only review and validation agents instead. |
| “Cheap, standard, or strongest is enough model documentation.” | Record the exact runtime agent and model ID for every task role, with task shape and likely total-turn rationale. |
| “The writer already knows the workspace rules.” | Repeat the complete authority boundary in every writer handoff. |
| “One capped repair loop is enough.” | Record the numeric task cap before execution, default three rounds; after repeated failure use a fresh stronger worker. |
| “A required check failed or is unavailable, so stop.” | Repair or use a non-destructive fallback; after the recorded cap, hand off as incomplete and unverified. |
