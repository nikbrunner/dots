---
name: feedback-naming-precision
description: Nik cares deeply about naming precision and will push back on vague terminology
type: feedback
---

Nik reviews code with naming precision in mind. During the ghostty/nvim PR, he pushed back on:
- `tool` → `app` (too broad)
- `tool` field in `UpdateResult` → `app`
- Destructuring vs dot notation (`const { query } = useConfig()` → `const config = useConfig()`)
- Store mutation from lib functions (questioned whether `applyTheme` should manage store state)
- Registry being inline in `apply-theme.ts` (should be its own file)

**Why:** Nik wants code to read clearly and types to reflect the domain accurately.
**How to apply:** When naming types, variables, and files, use the most specific term. Ask if unsure. Don't use generic names like "tool", "item", "data" when a domain term exists.
