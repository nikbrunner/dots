# Audit: Architecture

**What this audits:** Module boundaries, dependency direction, separation of concerns, coupling, and structural health.

## How

- **`architecture-reviewer`** agent — dispatched as subagent for deep structural analysis
- **LSP** — `incomingCalls`/`outgoingCalls` for call hierarchy, `findReferences` for coupling analysis
- **`dev:util:design-interface`** — optionally invoked when a redesign proposal is warranted

## Steps

1. Determine scope: use `$ARGUMENTS` paths if provided, otherwise fall back to staged changes, then unstaged changes.
2. Dispatch the `architecture-reviewer` agent with the target scope. It evaluates:
   - **Separation of concerns** — are responsibilities cleanly divided?
   - **SOLID principles** — interface segregation, dependency inversion, single responsibility
   - **Module depth** (Ousterhout) — flag shallow modules where interface complexity matches implementation
   - **Dependency classification** — categorize each dependency: in-process, local-substitutable, ports & adapters, true external
   - **Scalability** — can 20 features be built on top of this without rewrites?
   - **Replace, don't layer** — flag redundant tests that duplicate boundary coverage
3. Use LSP call hierarchy to verify coupling claims with concrete reference counts.
4. If systemic issues are found, optionally invoke `dev:util:design-interface` to generate competing redesign proposals.

## Output

Architectural health report:

- **Strengths** — what's well-structured and should be preserved
- **Findings** — issues with file paths, line references, and severity
- **Dependency map** — classified dependencies with recommended test strategy per category
- **Recommendations** — prioritized by impact, with concrete refactoring steps

## Cross-references

- `dev:style:tdd` — test strategy alignment with dependency categories
- `dev:style:state` — state architecture patterns
