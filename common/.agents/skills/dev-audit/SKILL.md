---
name: dev-audit
description: "Audit code quality across architecture, docs, style, UI, and UX — pick the focus area. Use before commits, PR reviews, or periodic sweeps."
argument-hint: "[arch|docs|style|ui|ux] [scope]"
user-invocable: true
metadata:
  argument-hint: "[arch|docs|style|ui|ux] [scope]"
  user-invocable: true
---

# dev:audit

Run one or more audit passes on the current scope. Omit the first argument to run all applicable.

## Usage

```bash
dev:audit                     # Run all applicable audits
dev:audit arch                # Architecture only
dev:audit docs --staged       # Documentation audit on staged changes
dev:audit style src/          # Style audit on specific path
dev:audit ui                  # UI quality
dev:audit ux                  # UX heuristics
```

---

## arch — Architecture Audit

Audit module boundaries, dependency direction, separation of concerns, coupling, and structural health.

**Uses**: `architecture-reviewer` agent (subagent), LSP call hierarchy, `dev-util-design-interface` for redesign proposals.

### Steps
1. Determine scope (argument → staged → unstaged).
2. Dispatch `architecture-reviewer` agent to evaluate:
   - Separation of concerns
   - SOLID principles
   - Module depth (Ousterhout) — flag shallow modules
   - Dependency classification (in-process, local-substitutable, ports & adapters, external)
   - Scalability
3. Use LSP to verify coupling claims with reference counts.
4. Optionally invoke `dev-util-design-interface` for redesign proposals.

### Output
Architectural health report: strengths, findings (with paths/severity), dependency map, prioritized recommendations.

---

## docs — Documentation Audit

Surface documentation drift. Diff-driven and conservative.

**Uses**: `git diff`, `ffgrep`, project tree scan.

### Modes
- `--staged` (default) — pre-commit gate
- `--commits N` — periodic sweep

### Steps
1. Read the diff (`--cached` or `HEAD~N`).
2. Categorize changes: structural, behavioral, configuration, patterns.
3. Discover candidate docs (non-gitignored `.md` files).
4. Map change categories to likely doc roles.
5. Read relevant docs; search for changed symbols.
6. Flag findings: STALE, GAP, DRIFT, SCHEMA.

### Skip list
`plans/*`, `tmp/*`, `ROADMAP.md`, `CHANGELOG.md`, `node_modules/**`, `dist/**`, generated files.

---

## style — Style Convention Audit

Check code adherence to project-specific style conventions.

**Uses**: `dev-style-*` skills, LSP diagnostics, project config.

### Steps
1. Determine scope.
2. Detect project stack from `package.json`, `tsconfig.json`, file extensions.
3. Load matching `dev-style-*` skills.
4. Run LSP diagnostics.
5. Walk each skill's conventions against actual code (naming, folder structure, typing, components, state, tests).
6. Produce findings list: file, convention violated, what's off, suggestion.

---

## ui — UI Quality Audit

Audit frontend UI through technical and design lenses.

**Uses**: `dev-impeccable:audit` (a11y, perf, theming), `dev-impeccable:critique` (design coherence), `dev-browser` for screenshots.

### Steps
1. Determine scope.
2. Run `dev-impeccable:audit` — technical report (a11y, perf, theme, responsive).
3. Run `dev-impeccable:critique` — design critique (hierarchy, IA, emotion, composition).
4. Capture screenshots at key breakpoints if browser available:
   ```bash
   agent-browser open <url>
   agent-browser set viewport 375 812   # mobile
   agent-browser screenshot mobile.png
   agent-browser set viewport 1280 720  # desktop
   agent-browser screenshot desktop.png
   agent-browser close
   ```
5. Merge findings into combined report.

---

## ux — UX Heuristics Audit

Audit against Nielsen's 10 Usability Heuristics.

**Uses**: `dev-browser` for screenshots at key states, LSP for tracing state/error handling.

### Steps
1. Determine scope.
2. Capture screenshots at key states (idle, loading, error, empty, success) using `dev-browser`:
   ```bash
   agent-browser open <url>
   agent-browser screenshot idle.png
   # trigger each state, capture
   agent-browser close
   ```
3. Walk each heuristic (visibility, real-world match, user control, consistency, error prevention, recognition, efficiency, minimalism, error recovery, help).
4. Classify each finding: Violation, Weakness, or Pass.
5. Produce findings table + per-heuristic pass rate and top 3 priorities.

### Nielsen's 10 Heuristics
1. Visibility of system status
2. Match between system and real world
3. User control and freedom
4. Consistency and standards
5. Error prevention
6. Recognition rather than recall
7. Flexibility and efficiency of use
8. Aesthetic and minimalist design
9. Help users recognize, diagnose, and recover from errors
10. Help and documentation

---

## Cross-references

- `dev-style-tdd` — test strategy alignment
- `dev-style-state` — state architecture patterns
- `dev-style-react` — component patterns for error boundaries and loading states
- `dev-impeccable` — deeper UI polish commands
- `dev-util-design-interface` — redesign proposals
- `dev-browser` — screenshot capture via `agent-browser`
- `dev-commit` — integrates docs audit as pre-commit gate
