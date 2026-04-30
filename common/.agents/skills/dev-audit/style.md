# Audit: Style

**What this audits:** Code adherence to project-specific `dev:style:*` convention skills.

## How

- **`dev:style:*` skills** — detect which apply from project deps/file extensions (e.g., `dev:style:typescript`, `dev:style:react`, `dev:style:css`, `dev:style:tdd`, `dev:style:state`, `dev:style:tanstack`)
- **LSP diagnostics** — type errors, unused imports, naming violations
- **Project config** — eslint, tsconfig, biome, prettier rules as baseline

## Steps

1. Determine scope: use argument path if provided (`$ARGUMENTS` in Claude Code, or `/skill:dev-audit style` args in Pi), otherwise scan `src/` or project source directories.
2. Detect project stack from `package.json`, `tsconfig.json`, file extensions, and dependency list.
3. Load all matching `dev:style:*` skills via the Skill tool.
4. Run LSP diagnostics on target files — collect type errors, warnings.
5. Walk each loaded skill's conventions against the actual code:
   - Naming patterns (files, components, hooks, types, variables)
   - Folder structure (co-location, barrel exports, separation)
   - Typing discipline (no `any`, discriminated unions, branded types)
   - Component patterns (dumb/smart/partial, composition, props)
   - State patterns (server vs URL vs client state)
   - Test patterns (co-located tests, naming, coverage)
6. Produce a flat list of violations.

## Output

Flat findings list. Each entry:

| Field      | Content                              |
| ---------- | ------------------------------------ |
| File       | Absolute path with line reference    |
| Convention | Which `dev:style:*` rule is violated |
| What's off | Concrete description                 |
| Suggestion | Actionable fix                       |

Also flags structural improvements: role misclassification, extraction opportunities, missing patterns, convention gaps. No compliment sandwiches.
