## ADDED Requirements

### Requirement: Skill detects OpenSpec presence

The dev:propose skill SHALL check for an `openspec/` directory in the project root before producing artifacts.

#### Scenario: OpenSpec initialized

- **WHEN** user invokes dev:propose in a project with `openspec/` directory
- **THEN** skill produces artifacts in `openspec/changes/<name>/` format (proposal.md, design.md, specs/)

#### Scenario: OpenSpec not initialized

- **WHEN** user invokes dev:propose in a project without `openspec/` directory
- **THEN** skill offers to run dev:openspec-init bootstrap
- **THEN** if user declines, skill falls back to current PRD format (GitHub issue, Linear, or local file)

### Requirement: Proposal uses openspec new change CLI

The skill SHALL use `openspec new change "<name>"` to scaffold the change directory before writing artifacts.

#### Scenario: Change scaffolding

- **WHEN** skill begins producing OpenSpec artifacts
- **THEN** it runs `openspec new change "<slug>"` to create the change directory
- **THEN** it uses `openspec instructions proposal` to get the template
- **THEN** it fills the template from the grilling session results

### Requirement: Proposal includes design and delta specs

The dev:propose skill SHALL produce proposal.md, design.md, and specs/ delta files in a single workflow — not just proposal.md alone.

#### Scenario: Complete artifact production

- **WHEN** user completes the grilling session and approves the direction
- **THEN** skill writes proposal.md (what and why)
- **THEN** skill writes design.md (how — decisions, trade-offs, migration)
- **THEN** skill writes specs/<capability>/spec.md for each new or modified capability

### Requirement: Review gate uses openspec validate plus content review

The skill SHALL run `openspec validate` for structural compliance, then dispatch the prd-reviewer agent for content quality.

#### Scenario: Structural validation passes

- **WHEN** all artifacts are written
- **THEN** skill runs `openspec validate <change-name>`
- **THEN** if validation passes, dispatches prd-reviewer with proposal.md + design.md
- **THEN** if prd-reviewer approves, offers dev:plan-tasks as next step

#### Scenario: Structural validation fails

- **WHEN** `openspec validate` reports errors
- **THEN** skill fixes the structural issues before dispatching content review
