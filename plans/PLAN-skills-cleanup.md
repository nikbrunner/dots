# Skills Cleanup Plan

> Status: 🗣️ Discussion — decisions being made. No files changed yet.

## Design Principles

1. **Small & concise** — Skills should be lean. If >200 lines, trim.
2. **Project-conditional → project-level** — BAI moves to `ai/` repo.
3. **Unused → drop** — Readwise trimmed to what's actually used.
4. **Prefixes** — all skills should have a namespace prefix.

## Decisions Made

### ❌ Drop (15)

| Skill | Lines | Reason |
|---|---|---|
| find-skills | 143 | Ironic |
| about-pick-theme-original | 120 | Archival |
| about-awdcs | 54 | Niche |
| about-gh-cli | 104 | gh is self-documenting |
| meta-enforcement | 62 | Add `disableModelInvocation: true`, stays on disk |
| readwise-mcp | 273 | Redundant |
| reader-recap | 131 | CLI covers it |
| triage | 82 | CLI covers it |
| feed-catchup | 87 | CLI covers it |
| quiz | 122 | CLI covers it |
| book-review | 328 | Not needed |
| highlight-graph | 140 | Novelty |
| surprise-me | 67 | Novelty |
| build-persona | 77 | One-shot |
| now-reading-page | 98 | One-shot |

### ✅ Keep — Readwise (1)

- `readwise-cli` (245) — does everything via CLI

### 🚚 Move to BAI `ai/` repo (8)

| Skill | Lines |
|---|---|
| bai-create | 88 |
| bai-create-project | 77 |
| bai-ready | 72 |
| bai-review | 82 |
| bai-status | 78 |
| bai-update | 96 |
| bai-weekly | 115 |
| about-black-atom-industries | 114 |

Implementation (separate work):
- [ ] Convert skills to sync-compatible format
- [ ] Add Pi platform config to `ai/` sync engine
- [ ] Populate `src/skills/`, run sync
- [ ] Remove from global `~/.agents/skills/`
- [ ] Write HANDOFF.md in `ai/` for another agent

### 🔀 Merge

| Group | Action | Savings |
|---|---|---|
| dev-audit-* (5) | → `dev-audit` | −4 |
| about-bm, about-dots, about-nbr-haus, about-sonder (4) | → merge into `about-nik`, rename to `about-me` | −3 |
| dev-style-react-no-use-effect + dev-style-react (2) | → `dev-style-react` | −1 |
| dev-style-css, dev-style-state, dev-style-tanstack, dev-style-typescript | Keep separate — lean, well-scoped, cross-referenced | — |

### 📐 Trim (line count reduction)

| Skill | Lines | Action |
|---|---|---|
| dev-util-browser | 832 | Major trim |
| dev-setup-llm | 234 | Trim |
| dev-setup-pre-commit | 171 | Trim |
| dev-setup-project | 155 | Trim |
| dev-setup-dep-upgrade-skill | 252 | Trim |
| dev-setup-release-please | 117 | Trim |
| dev-setup-skill | 84 | Trim |

### ✅ Keep as-is (already clean)

- `penny` (37), `penny-calendar` (64), `penny-daily` (101), `penny-monthly` (115), `penny-profile` (116), `penny-reflection` (150), `penny-timeblock` (118), `penny-weekly` (109)
- `about-me` (was `about-nik`, 77)
- `dev-flow` (58), `dev-commit` (139), `dev-improve-codebase-architecture` (71)
- `dev-util-design-interface` (62), `dev-util-glossary` (84), `dev-util-visual-companion` (222)
- `dev-style-tdd` (107), `dev-style-css` (60), `dev-style-state` (67), `dev-style-tanstack` (99), `dev-style-typescript` (75)
- `dots-add` (92), `dots-remove` (99), `dots-git-status-cleanup` (74)
- `handoff` (13), `mcp-guide` (24), `obsidian-guide` (125)
- `caveman` (72), `impeccable` (181)
- `readwise-cli` (245)

### 🏷️ Prefix Renames (post-cleanup)

| Current | → |
|---|---|
| `caveman` | `dev-caveman` |
| `handoff` | `dev-handoff` |
| `impeccable` | `dev-impeccable` |
| `mcp-guide` | `dev-mcp-guide` |
| `obsidian-guide` | `penny-obsidian-guide` |
| `dev-util-visual-companion` | `dev-visual-companion` |

## Running Tally

| Action | Count |
|---|---|
| Starting | 70 |
| Dropped | −15 |
| BAI moved out | −8 |
| Merged | −8 |
| **Remaining global** | **~39** |

## Remaining Questions

1. `penny-profile`: set `disableModelInvocation: true`? It's referenced, not invoked.
2. `impeccable` + `dev-visual-companion`: keep both separate?
3. Ready to move into execution, or more to discuss?
