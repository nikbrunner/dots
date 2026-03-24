## ADDED Requirements

### Requirement: dev:close runs openspec archive

The dev:close skill SHALL run `openspec archive <change-name>` after successful verification and shipping when an active OpenSpec change exists.

#### Scenario: Archive after ship

- **WHEN** dev:close completes verification and shipping steps
- **THEN** if an active OpenSpec change exists for this work
- **THEN** skill runs `openspec archive <change-name>`
- **THEN** delta specs are synced into `openspec/specs/`
- **THEN** change is moved to `openspec/changes/archive/`

#### Scenario: No active OpenSpec change

- **WHEN** dev:close runs and no OpenSpec change is associated with the work
- **THEN** archive step is skipped silently

### Requirement: Archive preserves issue tracker reference

The change artifacts SHALL include a reference to the associated issue tracker item (GitHub issue URL, Linear issue ID) before archiving.

#### Scenario: Issue reference in archived change

- **WHEN** a change is archived
- **THEN** the proposal.md or a metadata file contains a link to the tracked issue
