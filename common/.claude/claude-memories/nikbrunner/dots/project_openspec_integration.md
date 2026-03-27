---
name: OpenSpec Integration into Dev Skills
description: Integration of OpenSpec artifact format into dev-* skill pipeline — skill renames done, active branch feat/openspec-integration with remaining work.
type: project
---

## Goal

Integrate OpenSpec's artifact format and `specs/` accumulation into the existing `dev-*` skill pipeline. Keep the workflow, swap the artifact format, gain a living behavioral spec repository.

**Why:** Nik has no clear convention for docs/specs/plans folders. Old plans go stale and become noise. OpenSpec's archive cycle solves this structurally — active changes are clearly in-progress, archived changes are dated history, and `openspec/specs/` is the only canonical "current truth."

## Current State (2026-03-26)

**Branch:** `feat/openspec-integration` (21 commits ahead of main, not yet merged)

### Completed Work

1. **OpenSpec initialized** in dots repo (`openspec/` dir with `spec-driven-custom` schema)
2. **Skill renames completed:**
   - `dev-grill-me` → `dev-brainstorm` (directory + all cross-references)
   - `dev-write-prd` → `dev-propose` (produces OpenSpec artifacts instead of PRD)
   - `dev-prd-to-plan` → `dev-plan-tasks` (produces OpenSpec tasks.md instead of plan file)
3. **New skill created:** `about-openspec` — OpenSpec context/awareness skill
4. **OpenSpec routing added to `dev-start`** — routes to OpenSpec workflow when `openspec/` exists
5. **Visual companion v2 layout** — proposed, implemented, and archived (`openspec/changes/archive/2026-03-25-visual-companion-v2-layout/`)
6. **Per-project OpenSpec skills** installed at `.claude/skills/` (openspec-propose, openspec-apply-change, openspec-explore, openspec-archive-change) — aliased as `opsx:*` prefix

### Active OpenSpec Change

`openspec/changes/openspec-skill-integration/` — the meta-change for integrating OpenSpec into the dev pipeline itself. Has proposal, design, specs (4 spec files), and tasks.

### Remaining Work

- Finish implementing remaining tasks from `openspec-skill-integration` change
- Wire `dev-close` to include OpenSpec archive step
- Adapt review gates (prd-reviewer, plan-reviewer) for new artifact format
- Bootstrap skill (`dev-openspec-init`) for brownfield adoption
- Uncommitted changes on branch: settings.json, about-openspec, visual-companion files, tmux keymaps

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
- `openspec new change "<name>"` — creates change directory
- `openspec status --change "<name>" --json` — artifact completion status
- `openspec instructions <artifact-id> --change "<name>" --json` — templates + rules
- `openspec list --json` — list active changes
- Custom schema at `openspec/schemas/spec-driven-custom/`
