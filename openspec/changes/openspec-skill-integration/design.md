## Context

The dev-\* skill pipeline (dev-write-prd → dev-prd-to-plan → dev-executing-plans → dev-close) produces planning artifacts that go stale after implementation. OpenSpec provides a spec-driven workflow where behavioral specs accumulate as living documentation and planning artifacts have a defined lifecycle (active → archived).

Current state: 77 skills in `~/.claude/skills/`, recently refactored for enforcement reliability (SessionStart injection, smart skills-check). The pipeline works but outputs ephemeral artifacts.

## Goals / Non-Goals

**Goals:**

- Replace PRD/plan artifacts with OpenSpec format (proposal.md, design.md, specs/, tasks.md)
- Maintain fallback to current PRD format for projects without OpenSpec
- Accumulate behavioral specs over time via archive step in dev:close
- Provide bootstrap skill for brownfield projects

**Non-Goals:**

- Custom OpenSpec schema (default spec-driven schema is sufficient)
- Migrating existing docs/plans/ files to OpenSpec format
- Changing the interview/grilling process (dev:grill-me stays as-is)
- Making OpenSpec mandatory for all projects

## Decisions

### 1. Rename skills to match OpenSpec concepts

**Choice:** dev-write-prd → dev-propose, dev-prd-to-plan → dev-plan-tasks
**Alternative:** Keep old names, update descriptions only
**Rationale:** "Write PRD" producing OpenSpec artifacts is confusing. New names map directly to the workflow: propose → plan tasks. Clean break, update all cross-references.

### 2. Conditional behavior based on openspec/ presence

**Choice:** Detect `openspec/` directory, branch behavior accordingly
**Alternative:** Always use OpenSpec, require init everywhere
**Rationale:** Not every project needs OpenSpec. Config repos (dots), small scripts, and quick experiments shouldn't require spec scaffolding. The fallback preserves current behavior for simple projects.

### 3. Use openspec CLI for scaffolding and templates

**Choice:** Call `openspec new change`, `openspec instructions`, `openspec validate`, `openspec archive` from within skills
**Alternative:** Generate artifacts manually without CLI
**Rationale:** CLI handles schema compliance, template resolution, and archive mechanics. Skills focus on content quality and workflow orchestration. Separation of concerns.

### 4. Review gates: openspec validate + content reviewers

**Choice:** Structural validation via CLI, content review via existing agents
**Alternative:** Replace reviewers with openspec validate only
**Rationale:** `openspec validate` catches schema/format issues but can't judge content quality (are decisions justified? is scope clear?). The agents handle judgment; the CLI handles compliance.

### 5. Bootstrap: scan + confirm, not auto-generate

**Choice:** Scan codebase for capabilities, present to user, generate specs for confirmed ones
**Alternative:** Fully automatic spec generation
**Rationale:** Auto-generated specs without user review would be unreliable. The user knows which capabilities are worth speccing. Discovery helps, but confirmation is required.

## Risks / Trade-offs

- **OpenSpec CLI dependency** → All developers need `openspec` installed globally. Mitigated by checking CLI availability and providing install instructions.
- **Skill rename breaks muscle memory** → Users typing `/dev-write-prd` will get "unknown skill." Mitigated by clean break (no aliases) and updated dev:start routing.
- **Spec quality varies** → Early specs from bootstrap will be rough. Mitigated by treating them as living documents that improve with each change cycle.
- **Archive step adds friction to dev:close** → Extra step at end of work. Mitigated by making it automatic when OpenSpec change exists, silent skip when not.

## Migration Plan

1. Create new skill directories (dev-propose, dev-plan-tasks, dev-openspec-init)
2. Delete old skill directories (dev-write-prd, dev-prd-to-plan)
3. Update all cross-references in dev-start, dev-close, dev-create-project, bai-create-project, dev-executing-plans
4. Update prd-reviewer and plan-reviewer agent prompts
5. Test full cycle: propose → specs → design → tasks → execute → archive

Rollback: Revert the branch. Old skills are in git history.

## Open Questions

1. Should `dev:prd-to-issues` (Linear issue creation from PRD) be adapted for OpenSpec, or is it superseded by the issue tracker reference in proposal.md?
2. How should `dev:executing-plans` reference tasks.md — by path convention or by detecting the active OpenSpec change?
