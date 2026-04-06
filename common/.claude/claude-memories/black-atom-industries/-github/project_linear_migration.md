---
name: Linear to GitHub migration
description: Status of the Linear→GitHub Issues migration tracked in .github#1 — phases, what's done, what remains
type: project
---

Migration from Linear to GitHub Issues (.github#1) is nearly complete as of 2026-04-05.

**Phase 1 (Infrastructure):** Done — issue templates (Feature markdown, Bug YAML form), milestones on all repos (livery v1.0.0, helm v1.0.0, radar.nvim v1.0.0, core Monitor + others, ui v1.0.0), org project "Black Atom V1" (#7) with 98 items.

**Phase 2 (Migration):** Done — issues spread across repos (.github, core, livery, ui, website, obsidian). atlas issues are new (not migrated from Linear).

**Phase 3 (Cleanup):** Done — skills no longer reference Linear. Linear workspace kept as archive per PRD ("Archive or cancel after verification period").

**Remaining to close the issue:**

- Fix null-topics bug in label sync (`sync.ts:44` — `repositoryTopics` is null for repos without topics like atlas)
- Merge PR #23 (label sync tooling, branch `chore/label-system`)
- Run label sync for real across org
- Close .github#1

**Why:** Linear added tool-switching overhead and hid planning from contributors. GitHub co-locates issues with code.

**How to apply:** When creating/managing BAI issues, use GitHub Issues exclusively. Linear is read-only archive for historical context.
