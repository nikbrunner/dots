## ADDED Requirements

### Requirement: Bootstrap initializes OpenSpec in a project

The dev:openspec-init skill SHALL run `openspec init` and guide the user through initial spec population.

#### Scenario: Fresh initialization

- **WHEN** user invokes dev:openspec-init in a project without `openspec/`
- **THEN** skill runs `openspec init`
- **THEN** skill scans the codebase for major capabilities (modules, APIs, features)
- **THEN** skill presents discovered capabilities to user for confirmation
- **THEN** skill generates initial `openspec/specs/<capability>/spec.md` for each confirmed capability

#### Scenario: Already initialized

- **WHEN** user invokes dev:openspec-init in a project with existing `openspec/`
- **THEN** skill reports OpenSpec is already initialized
- **THEN** offers to scan for capabilities not yet covered by specs

### Requirement: Bootstrap is offered during project creation

The dev:create-project and bai:create-project skills SHALL offer to run dev:openspec-init during project scaffolding.

#### Scenario: Offered in create-project

- **WHEN** dev:create-project reaches the tooling setup phase
- **THEN** it offers dev:openspec-init as an optional step
- **THEN** if accepted, runs the bootstrap flow

### Requirement: Bootstrap is offered when dev:propose detects missing OpenSpec

The dev:propose skill SHALL offer dev:openspec-init when `openspec/` is not found.

#### Scenario: Offered in propose fallback

- **WHEN** dev:propose detects no `openspec/` directory
- **THEN** it offers to run dev:openspec-init
- **THEN** if declined, falls back to current PRD format
