---
name: Atlas is a new repo
description: atlas is a new BAI project (bookmark manager), not part of the Linear migration — has no repository topics set
type: project
---

`atlas` is a new Black Atom Industries repo — a bookmark manager (Bubbletea TUI). It was NOT part of the Linear migration and has no repository topics set on GitHub, which causes the label sync tooling to error (null repositoryTopics).

**Why:** Came up during review of .github#1 when label sync dry-run errored on atlas. Nik confirmed "atlas is new."

**How to apply:** When working with label sync or org-wide tooling, atlas needs a topic tag (or the tooling needs to handle repos without topics gracefully). The null-guard fix in sync.ts will make it skip cleanly.
