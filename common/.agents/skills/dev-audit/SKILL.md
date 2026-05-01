---
name: dev-audit
description: "Audit code quality through different lenses — UI, style conventions, architecture, documentation. Invoke with an argument to pick a lens."
argument-hint: "[ui|style|arch|docs|ux]"
user-invocable: true
metadata:
  argument-hint: "[ui|style|arch|docs|ux]"
  user-invocable: true
---

# dev:audit

Run targeted quality audits. Read the lens doc matching the argument and follow its steps.

## Arguments

Determine the lens:

1. If `$ARGUMENTS` is set (Claude Code), use its value
2. If invoked via `/skill:dev-audit <lens>` (Pi), use the argument after the skill name
3. If no argument provided, ask the user which lens (or auto-detect from context)

## Routing

| Argument | Lens doc                             | What it audits                                        |
| -------- | ------------------------------------ | ----------------------------------------------------- |
| `ui`     | [ui.md](ui.md)                       | UI quality via impeccable:audit + impeccable:critique |
| `style`  | [style.md](style.md)                 | Code against dev:style:\* conventions                 |
| `arch`   | [architecture.md](architecture.md)   | Structure via architecture-reviewer agent             |
| `docs`   | [docs.md](docs.md)                   | Documentation completeness + knowledge sync           |
| `ux`     | [ux-heuristics.md](ux-heuristics.md) | UX quality via Nielsen's 10 Usability Heuristics      |
