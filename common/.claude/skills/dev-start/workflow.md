# Development Workflow

The authoritative reference for the full development lifecycle. Covers every phase from initial assessment to shipping, including OpenSpec integration, responsibility boundaries, and transition signals.

## Phase 1: Assess

**Trigger:** Automatic — runs whenever `dev:start` is invoked.

**Purpose:** Determine what we're working on, whether it's already tracked, and how much ceremony it needs.

### Steps

1. Check for active OpenSpec changes (`openspec list --json`). If the user's request matches an existing change by name or description, route directly to Phase 3 via `opsx:apply`.
2. If no match, assess scope from the user's prompt:

| Scope   | Signals                           | Route                           |
| ------- | --------------------------------- | ------------------------------- |
| Trivial | One-liner, typo, config change    | Skip to Phase 3 (direct coding) |
| Small   | Single-file fix, isolated feature | Skip to Phase 3 (direct coding) |
| Medium  | Multi-file feature, new module    | Suggest Phase 2                 |
| Large   | Multi-system, cross-cutting       | Suggest Phase 2                 |

3. Present the scope assessment: "This looks [scope] — I'll [route]. Sound right?"

### Responsibility

- **Claude:** Runs the check, assesses scope, suggests the route.
- **Nik:** Confirms or overrides. Can always say "skip planning, just code."

### Transition

- Trivial/Small → Phase 3
- Medium/Large → Phase 2 (if Nik agrees)

---

## Phase 2: Shape

**Trigger:** Nik invokes `/opsx:propose` or `/dev:brainstorm`. Claude may suggest it for medium+ scope, but never forces it.

**Purpose:** Define what we're building before we build it. Produces a tracked OpenSpec change with artifacts that guide implementation.

### Steps

1. **Brainstorm** (`dev:brainstorm`) — optional. Explore the idea, pressure-test assumptions, clarify requirements. Use the visual companion if the question is visual.
2. **Propose** (`opsx:propose`) — creates the OpenSpec change:
   - `proposal.md` — why and what
   - `design.md` — how (architecture decisions, trade-offs)
   - `specs/` — delta specs per capability (testable requirements)
   - `tasks.md` — implementation checklist
3. **Review gates** — `prd-reviewer` and `plan-reviewer` agents validate the artifacts. Up to 3 iterations each.

### Responsibility

- **Nik:** Triggers brainstorm/propose. Reviews and approves artifacts.
- **Claude:** Generates artifacts, runs review agents, iterates on feedback.

### Transition

- Approved proposal → Phase 3

---

## Phase 3: Build

**Trigger:** Automatic when `dev:start` routes here, or when `opsx:apply` is invoked on a tracked change.

**Purpose:** Write the code. For tracked changes, work through tasks systematically. For untracked work, just code.

### Steps

1. **For tracked changes:**
   - Load task list from `tasks.md`
   - Implement each task in order
   - Mark each task complete (`- [ ]` → `- [x]`) immediately after finishing it
   - Run per-task verification: tests, lint, build
   - Commit after each logical unit of work
   - When the last task is marked complete, surface: "All tasks in [change] are complete — ready for `/dev:close`?"

2. **For untracked work:**
   - Implement directly
   - Verify before committing
   - Commit with conventional format

### Responsibility

- **Claude:** Implements, verifies, commits, tracks task progress, surfaces completion.
- **Nik:** Reviews, gives feedback, steers direction. Decides when to commit.

### Transition

- All tasks complete (or untracked work done) → Nik triggers Phase 4
- Claude never auto-transitions to Phase 4. Completion is Nik's call.

---

## Phase 4: Ship

**Trigger:** Nik invokes `/dev:close`.

**Purpose:** Verify everything works, choose how to ship, and archive the OpenSpec change if one exists.

### Steps

1. **Verify** (`dev:verification`):
   - Run tests, lint, build
   - Check for regressions
   - Structural completeness review (full branch diff)

2. **Ship** (`dev:finishing-branch`):
   - Choose: merge to main, create PR, keep branch, or discard
   - If PR: push and create via `gh pr create`

3. **Archive** (automatic, if a tracked OpenSpec change exists with all tasks complete):
   - Run `openspec archive <change-name>` CLI
   - This promotes delta specs to `openspec/specs/<domain>/` automatically
   - Moves the change directory to `openspec/changes/archive/`
   - Commit the archive

4. **Close tracked issue** (optional) — if work was linked to a GitHub/Linear issue.

5. **Knowledge sync** (optional) — update CLAUDE.md, skills, or docs if the work changed conventions.

### Responsibility

- **Nik:** Triggers `/dev:close`. Decides ship method (merge/PR/keep/discard).
- **Claude:** Runs verification, executes the chosen ship method, archives OpenSpec change, commits.

### Transition

- Done. Back to Phase 1 on the next task.

---

## OpenSpec Integration Points

| OpenSpec action    | When                               | Called by                |
| ------------------ | ---------------------------------- | ------------------------ |
| `openspec list`    | Phase 1 — check for active changes | Claude (automatic)       |
| `opsx:propose`     | Phase 2 — create tracked change    | Nik (manual)             |
| `opsx:apply`       | Phase 3 — resume tracked change    | Claude (automatic route) |
| `openspec archive` | Phase 4 — inside `dev:close`       | Claude (automatic)       |

### Spec Accumulation

Delta specs in each change define capabilities using `## ADDED / MODIFIED / REMOVED / RENAMED Requirements`. When `openspec archive` runs, these deltas are promoted into `openspec/specs/<domain>/`, building a living specification over time. Future changes that modify existing capabilities write delta specs against the accumulated main specs.

### When OpenSpec is Skipped

Trivial and small tasks don't need OpenSpec. No ceremony for a typo fix or a config change. The workflow exists to help with medium+ scope where planning pays off. Nik can always say "skip planning" regardless of assessed scope.

---

## Responsibility Summary

### Nik triggers (explicit)

- `/dev:brainstorm` — think before coding
- `/opsx:propose` — formal planning for medium+ scope
- `/dev:close` — work is done (Claude never assumes this)

### Claude does (automatic)

- Check for active OpenSpec changes on every `dev:start`
- Route to `opsx:apply` when a change matches
- Mark tasks complete as they're implemented
- Run verification before any done claims
- Archive OpenSpec change inside `dev:close`
- Surface "all tasks complete" when it happens

### Claude asks first

- "This looks medium — want to propose?" — scope upgrade suggestion
- "All tasks done — ready to close?" — completion nudge
- "Skip planning?" — when direct coding seems appropriate
