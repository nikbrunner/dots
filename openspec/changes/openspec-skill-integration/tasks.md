## 1. Create new skills

- [ ] 1.1 Create `dev-propose/SKILL.md` — adapted from dev-write-prd with OpenSpec detection, `openspec new change` scaffolding, and conditional fallback
- [ ] 1.2 Create `dev-plan-tasks/SKILL.md` — adapted from dev-prd-to-plan to read OpenSpec artifacts and produce tasks.md
- [ ] 1.3 Create `dev-openspec-init/SKILL.md` — bootstrap skill: `openspec init`, codebase scan, guided spec population

## 2. Delete old skills

- [ ] 2.1 Delete `dev-write-prd/` directory
- [ ] 2.2 Delete `dev-prd-to-plan/` directory

## 3. Modify existing skills

- [ ] 3.1 Update `dev-close/SKILL.md` — add `openspec archive` step after shipping (conditional on active change)
- [ ] 3.2 Update `dev-start/SKILL.md` — replace dev-write-prd/dev-prd-to-plan references with dev-propose/dev-plan-tasks
- [ ] 3.3 Update `dev-create-project/SKILL.md` — offer dev:openspec-init during scaffolding
- [ ] 3.4 Update `bai-create-project/SKILL.md` — offer dev:openspec-init during scaffolding

## 4. Update review agents

- [ ] 4.1 Update `prd-reviewer` agent prompt — read proposal.md + design.md instead of PRD, run `openspec validate` first
- [ ] 4.2 Update `plan-reviewer` agent prompt — read tasks.md instead of plan file

## 5. Fix cross-references

- [ ] 5.1 Grep for all references to `dev-write-prd` and `dev-prd-to-plan` across skills and update
- [ ] 5.2 Update `dev-executing-plans/SKILL.md` if it references old skill names
- [ ] 5.3 Update `dev-prd-to-issues/SKILL.md` — decide if it adapts to OpenSpec or stays PRD-only

## 6. Validate

- [ ] 6.1 Run `openspec validate` on the change itself (eating our own dogfood)
- [ ] 6.2 Test full cycle: propose → plan-tasks → executing-plans → close with archive
- [ ] 6.3 Test fallback: propose in a project without openspec/ — should offer init then fall back
- [ ] 6.4 Grep confirms no remaining references to old skill names
