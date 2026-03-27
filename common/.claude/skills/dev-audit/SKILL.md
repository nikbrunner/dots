---
name: dev:audit
description: "Audit code quality through different lenses — UI, style conventions, architecture, documentation. Invoke with an argument to pick a lens."
argument-hint: "[ui|style|arch|docs]"
user-invocable: true
---

# dev:audit

Run targeted quality audits. Read the lens doc matching `$ARGUMENTS` and follow its steps.

## Routing

| Argument | Lens doc                           | What it audits                                        |
| -------- | ---------------------------------- | ----------------------------------------------------- |
| `ui`     | [ui.md](ui.md)                     | UI quality via impeccable:audit + impeccable:critique |
| `style`  | [style.md](style.md)               | Code against dev:style:\* conventions                 |
| `arch`   | [architecture.md](architecture.md) | Structure via architecture-reviewer agent             |
| `docs`   | [docs.md](docs.md)                 | Documentation completeness + knowledge sync           |
| _(none)_ | Ask which lens                     | Or auto-detect from context                           |
