## ADDED Requirements

### Requirement: Task planning reads OpenSpec artifacts

The dev:plan-tasks skill SHALL read proposal.md, design.md, and specs/ from the OpenSpec change directory to produce tasks.md.

#### Scenario: Tasks produced from OpenSpec change

- **WHEN** user invokes dev:plan-tasks with an OpenSpec change
- **THEN** skill reads the approved proposal.md, design.md, and specs/
- **THEN** skill uses `openspec instructions tasks` to get the template
- **THEN** skill produces tasks.md with vertical-slice phases as checkbox items

### Requirement: Fallback to plan file without OpenSpec

The skill SHALL fall back to current plan format when no OpenSpec change exists.

#### Scenario: No OpenSpec change available

- **WHEN** user invokes dev:plan-tasks without an active OpenSpec change
- **THEN** skill falls back to reading a PRD (GitHub issue, Linear, or local file)
- **THEN** skill produces a plan file at `./plans/plan-<slug>.md`

### Requirement: Task review gate

The skill SHALL run plan-reviewer agent adapted for tasks.md format.

#### Scenario: Tasks review

- **WHEN** tasks.md is written
- **THEN** skill dispatches plan-reviewer with tasks.md and proposal.md reference
- **THEN** if approved, offers dev:executing-plans as next step
