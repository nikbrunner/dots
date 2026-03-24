---
name: "dev:openspec-init"
description: "Initialize OpenSpec in a project and populate initial specs through codebase scanning and guided interview. Use when bootstrapping OpenSpec for a new or existing project."
user-invocable: true
---

# OpenSpec Init

Initialize OpenSpec and populate initial behavioral specs for a project.

## Prerequisites

Verify `openspec` CLI is installed: `command -v openspec`. If not found, instruct user to install via `npm install -g @fission-ai/openspec`.

## Step 1: Initialize

Check if `openspec/` already exists.

- **If absent**: Run `openspec init --tools claude`
- **If present**: Report already initialized, offer to scan for uncovered capabilities (skip to Step 3)

## Step 2: Scan the Codebase

Explore the project to identify major capabilities:

- Read project structure, entry points, and module boundaries
- Identify distinct features, APIs, services, or user-facing capabilities
- Check for existing documentation that describes behavior
- Note each capability with a kebab-case name and one-line description

## Step 3: Present Discoveries

Present the discovered capabilities to the user via `AskUserQuestion`:

- List each capability with its proposed name and description
- Let the user confirm, rename, remove, or add capabilities
- Only generate specs for confirmed capabilities

## Step 4: Generate Initial Specs

For each confirmed capability:

1. Create `openspec/specs/<capability>/spec.md`
2. Write behavioral requirements in WHEN/THEN format
3. Each requirement MUST have at least one `#### Scenario:` block
4. Use SHALL/MUST for normative language

Keep initial specs focused on observable behavior, not implementation details. They'll be refined as changes are made.

## Step 5: Validate

Run `openspec validate --specs` to verify all specs are structurally valid.

## Notes

- This skill is offered during `dev:create-project` and `bai:create-project`
- It is also offered by `dev:propose` when `openspec/` is not found
- For brownfield projects, initial specs will be incomplete — that's expected. They accumulate with each change cycle.
