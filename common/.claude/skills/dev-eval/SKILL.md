---
name: dev:eval
user-invocable: true
description: Evaluate code against dev-* convention skills. Load when reviewing code for adherence to documented patterns.
argument-hint: <topic> [path]
---

Evaluate code in the current project against Nik's `dev-*` convention skills.

## Arguments

- **topic** (required) — freeform description of what to evaluate (e.g., `react folder structure`, `component separation`, `typescript conventions`)
- **path** (optional) — directory or file to scope the evaluation. Defaults to the project's source directories.

## Process

1. **Resolve topic to skills** — match the topic to relevant `dev-*` skill(s) and their supporting files. Load them using the Skill tool.
2. **Scan the target code** — read the actual source files in the target path
3. **Compare against conventions** — check each convention from the loaded skill(s) against what exists in the code
4. **Produce findings** — a flat list of actionable observations

If the topic doesn't match any `dev-*` skill, say so and list the available concept skills:
`dev:react`, `dev:typescript`, `dev:styling`, `dev:state-management`, `dev:testing`, `dev:tanstack-query`, `dev:tanstack-form`

## Findings Format

Each finding should include:

- **File path** with line reference
- **What's off** — the convention being violated or the improvement possible
- **Suggestion** — concrete, actionable next step

Findings are not limited to rule violations. Structural improvements are in scope:

- Role misclassification: "this component should be a partial" or vice versa
- Extraction opportunities: "this 200-line container could split logic into hooks or file-local subcomponents"
- Missing patterns: "this partial has its own CSS — styling should live in dumb components"
- Convention gaps: "no `data-component` attribute on root element"

## Tone

Be direct. Don't soften findings. This is a code audit, not a compliment sandwich.
