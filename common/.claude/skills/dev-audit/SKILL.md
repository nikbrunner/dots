---
name: "dev:audit"
description: "Audit code quality through different lenses — UI, style conventions, architecture, documentation. Invoke with an argument to pick a lens."
user-invocable: true
---

# dev:audit

Run targeted quality audits.

## Arguments

| Invocation         | Description                                                                                                                                  |
| ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `/dev:audit`       | Prompt which lens to use.                                                                                                                    |
| `/dev:audit ui`    | Visual audit — layout, spacing, responsiveness, accessibility. Uses browser-automation for screenshots when available.                       |
| `/dev:audit style` | Style conventions — naming, formatting, lint rules, consistency with project patterns. Uses LSP diagnostics + project config.                |
| `/dev:audit arch`  | Architecture — module boundaries, dependency direction, separation of concerns, coupling. Uses LSP call hierarchy + file structure analysis. |
| `/dev:audit docs`  | Documentation — missing JSDoc, stale comments, README accuracy, inline explanation gaps.                                                     |

## Lenses

- [UI](ui.md)
- [Style](style.md)
- [Architecture](architecture.md)
- [Docs](docs.md)
