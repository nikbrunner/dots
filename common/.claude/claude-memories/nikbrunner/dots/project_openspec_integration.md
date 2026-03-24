---
name: OpenSpec Integration into Dev Skills
description: Plan to replace PRD/Plan artifacts with OpenSpec format while keeping existing dev workflow skeleton and Linear integration.
type: project
---

## Goal

Integrate OpenSpec's artifact format and `specs/` accumulation into the existing `dev-*` skill pipeline. Keep the workflow, swap the artifact format, gain a living behavioral spec repository.

**Why:** Nik has no clear convention for docs/specs/plans folders. Old plans go stale and become noise. OpenSpec's archive cycle solves this structurally — active changes are clearly in-progress, archived changes are dated history, and `openspec/specs/` is the only canonical "current truth."

## Decision: Hybrid Integration

**Keep:** dev-start, dev-grill-me, dev-executing-plans, dev-close, all review gates, Linear integration (bai-\*), all domain skills.

**Replace:** PRD and Plan artifacts with OpenSpec artifacts (proposal.md, design.md, tasks.md, delta specs/).

**Add:** specs/ accumulation via archive step in dev-close.

## Skill Modifications Needed

### 1. `dev-write-prd` → Produce OpenSpec artifacts instead of a PRD

- Output: `openspec/changes/<name>/proposal.md` (what & why) + `design.md` (how) + `specs/` (delta behavioral specs)
- Use `openspec new change "<name>"` to scaffold, then `openspec instructions` for templates
- Review gate: `prd-reviewer` adapts to validate proposal.md + design.md

### 2. `dev-prd-to-plan` → Produce OpenSpec tasks.md instead of a plan file

- Output: `openspec/changes/<name>/tasks.md`
- Use `openspec instructions tasks --change "<name>"` for template
- Review gate: `plan-reviewer` adapts to validate tasks.md

### 3. `dev-close` → Add archive step

- After verification + ship, run `openspec archive` to:
  - Sync delta specs into `openspec/specs/`
  - Move change to `openspec/changes/archive/YYYY-MM-DD-<name>/`
- Replaces/complements `pr-knowledge-sync` for behavioral documentation

### 4. Review gates adapt to new artifact format

- `prd-reviewer`: reads proposal.md + design.md instead of PRD
- `plan-reviewer`: reads tasks.md instead of plan file

### 5. New: Bootstrap skill (`openspec-bootstrap` or `dev-bootstrap-specs`)

- Scan a codebase, generate initial `openspec/specs/` organized by domain
- Needed for brownfield adoption across Nik's existing projects
- Could be a global skill since it's project-agnostic

## Architecture: Where Things Live

| Concern                | Tool                      | Location          |
| ---------------------- | ------------------------- | ----------------- |
| Behavioral truth       | openspec/specs/           | Project repo      |
| Active changes         | openspec/changes/\*/      | Project repo      |
| Change history         | openspec/changes/archive/ | Project repo      |
| Assignment/status      | Linear / Jira             | External tracker  |
| Workflow orchestration | dev-\* skills             | ~/.claude/skills/ |

## OpenSpec CLI Basics

- `openspec init --tools claude` — scaffolds `openspec/` dir + Claude skills in `.claude/`
- `openspec new change "<name>"` — creates change directory with `.openspec.yaml`
- `openspec status --change "<name>" --json` — artifact completion status
- `openspec instructions <artifact-id> --change "<name>" --json` — templates + rules for each artifact
- `openspec list --json` — list active changes
- `openspec validate` — validate structure
- Default schema: "spec-driven" (proposal → design → specs → tasks)

## OpenSpec Skills (installed per-project, can be removed after integration)

The `openspec init --tools claude` command installs 4 skills:

- `openspec-propose` — one-shot artifact generation (replaced by modified dev-write-prd + dev-prd-to-plan)
- `openspec-apply-change` — task execution loop (replaced by dev-executing-plans)
- `openspec-explore` — thinking/discovery mode (replaced by dev-grill-me)
- `openspec-archive-change` — archive + spec sync (absorbed into dev-close)

After integration, these per-project skills can be removed — the global dev-\* skills handle the workflow.

## Open Questions

1. **Custom OpenSpec schema** — The default "spec-driven" schema defines artifact types. May want a custom schema that aligns with Nik's preferred artifact set. Needs investigation: `openspec schema --help`.
2. **Bootstrap skill scope** — Global skill or per-project? Probably global since it's a one-time setup per repo.
3. **openspec init automation** — Should `dev-create-project` or `dev-claude-setup` auto-run `openspec init`?

## How to Apply

Modify the global skills in `common/.claude/skills/`. Start with dev-write-prd and dev-prd-to-plan since those are the artifact producers. Then adapt review gates. Finally add the archive step to dev-close.

**Test with livery first** — it already has `openspec init` done and has an empty `openspec/specs/` ready.
