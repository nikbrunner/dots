## Why

The dev-\* skill pipeline produces PRD and plan artifacts that go stale after implementation. There's no convention for where these live, no archive cycle, and no living behavioral documentation. OpenSpec solves this structurally — active changes are in-progress, archived changes are dated history, and `openspec/specs/` is the canonical behavioral truth.

## What Changes

- **BREAKING** Rename `dev-write-prd` → `dev-propose` (produces OpenSpec proposal.md + design.md + specs/)
- **BREAKING** Rename `dev-prd-to-plan` → `dev-plan-tasks` (produces OpenSpec tasks.md)
- Modify `dev:close` to run `openspec archive` after verification and shipping
- Add `dev:openspec-init` bootstrap skill (init + guided spec population from codebase)
- Add OpenSpec detection in `dev:propose` — offer bootstrap if `openspec/` missing, fall back to current PRD format if declined
- Update `dev:start` pipeline routing to use new skill names
- Adapt `prd-reviewer` and `plan-reviewer` agents to read OpenSpec artifact format
- Add `openspec validate` as structural check before content review gates
- Reference `dev:openspec-init` in `dev:create-project` and `bai:create-project`

## Capabilities

### New Capabilities

- `openspec-proposal-workflow`: Skill-driven workflow for producing OpenSpec proposal.md + design.md + delta specs from a grilling session
- `openspec-task-planning`: Skill-driven workflow for producing OpenSpec tasks.md from approved proposal + specs + design
- `openspec-archive-workflow`: Automated archive step in dev:close that syncs delta specs into main specs/ and moves change to archive
- `openspec-bootstrap`: Codebase scanning + guided interview to initialize openspec/ and populate initial specs for brownfield projects

### Modified Capabilities

<!-- No existing specs to modify — this is a greenfield openspec/ directory -->

## Impact

- **Skills affected**: dev-write-prd (renamed), dev-prd-to-plan (renamed), dev-close, dev-start, dev-create-project, bai-create-project
- **Agents affected**: prd-reviewer, plan-reviewer (prompt updates for new artifact format)
- **Cross-references**: All skills referencing dev-write-prd or dev-prd-to-plan need updating
- **Dependencies**: Requires `openspec` CLI (v1.2.0+) installed globally
- **Fallback**: Projects without `openspec/` continue using current PRD/plan format
