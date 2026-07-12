---
name: warm-precision-epic-status
description: "Warm Precision epic (#49) — CLOSED and MERGED to main 2026-07-05 (merge 1f8ac18, pushed); dev-local.sh swap REPLACED by deno links; hooks installed and verified; conventions + current toolchain facts"
metadata:
  node_type: memory
  type: project
  originSessionId: 6374ae24-82e7-45ee-8f9d-3679300afd0c
---

Epic #49 "Adopt the Warm Precision design system" — all sub-issues implemented except **#61**
(light appearance pass — deliberately HITL with Nik, never start autonomously). Everything on
branch `feat/warm-precision-foundation`, unmerged; Nik reviews + merges himself.

Status after the autonomous overnight session **2026-07-05 (02:03–~04:00)**, which shipped 7
commits (Nik authorized commits, no pushing — branch is 7 ahead of origin):

- **#64 Apply Rail** (needs-review): AdapterStatusRow primitive + ApplyRail replaced ApplyStrip
  (0291441 / 7a4c79d / 8476dc1). **Revised per Nik 07-05 morning (50d9a57): rail is permanently
  docked — never hidden.** `mode` prop idle/active/settled; idle previews enabled adapters as
  pending rows under READY; the 1.2s clean beat only _settles_ (hands keys back), esc BACK.
  Footer result-pip + `a REOPEN` removed. Board 3f still shows the old dismiss choreography —
  reconcile on next design re-import.
- **#62 VERIFY PATH** (needs-review): backend `verify_app_path` in `file_ops/verify.rs` +
  settings actuator with CHECK qualifier (8e410bc / ab48d3f).
- **#63 reload visibility** (needs-review): nvim reload now `--remote-expr` with per-socket
  outcomes + insert-mode safe (b708908); zed verifies the theme label exists in installed theme
  files before reporting success (ca96bee); ghostty half was 361ef73.
- Earlier: #50–#57, #59, #60 done; #58/#60 hardened through Nik's 07-04 live review.
- **Cross-repo:** `../zed` is missing NORTH themes — three dangling symlinks in
  `~/.config/zed/themes/` (north-night, north-dark-night, north-day); Nik must regenerate.
  `../core` branch `feat/expose-accents-feedback` awaits Nik's merge + JSR publish. `../nvim`
  has 4 uncommitted regenerated default themes.
- **HITL test plan for Nik:** live apply in the Tauri shell (rail 1.2s settle beat, hotkey
  handoff picking↔rail), VERIFY PATH against real config, nvim reload with live instance.
- Design-hook waivers pending Nik's confirmation: width transitions in `apply-rail.module.css`
  (progress fill, mirrors ProgressBar primitive) and `_app/route.module.css` (rail collapse —
  spec'd literally as 150ms ease-out width).
- Cosmetic follow-up: `adapter-status-row.module.css` has no `.statusOk` rule behind the cva
  variant key (harmless, cva omits undefined).

Conventions established: primitives idiom = kebab-case folder, cva + VariantProps, `type Props`,
`data-component`, className passthrough, JSDoc referencing the spec path, NO index barrels for
primitives (top-level components DO have index.ts barrels), --ba-* tokens only. Logic-only
testing (pure functions, @std/assert, co-located). Verification chain per slice: deno fmt/lint,
`sh scripts/dev-local.sh _check` + `_test`, `deno task vite:build`, cargo fmt/clippy/test for
backend, browser check via agent-browser on a vite dev server (Tauri IPC absent in plain
browser — config-dependent screens show fallbacks). Bindings regenerate only during a debug
`deno task dev` boot — run briefly and kill; the script's trap restores deno.json.

Toolchain (since 2026-07-05 evening, all merged to main at 1f8ac18): `scripts/dev-local.sh` and
the deno.json swap are GONE — local ../core resolution is via the `links` field in deno.json
(deno-native, works for dev/check/test/LSP, safe concurrently; CLAUDE.md documents the sibling
../core requirement). Tasks are plain: `deno task check` = `deno check src/` (directory form —
never shell globs; POSIX sh expanded `src/**` non-recursively and silently checked 11/66 files),
`deno task test` = `deno test -P`. Pre-commit hooks (.githooks via core.hooksPath) are INSTALLED
and verified — frontend (bindings guard, check, lint, fmt, test) + backend (cargo fmt/clippy
-D warnings/test). MSRV is 1.82. agent-browser saves screenshots relative to its daemon cwd
(repo root), not the shell cwd. Shell grep in this repo is aliased to ugrep and has missed
matches — use the fff MCP tools ([[feedback-cheap-subagent-models]] for the subagent model rule).

Follow-up candidates in issue comments: `[ d DETAILS ]` debug disclosure, no-search-match empty
state, PLAN.md stale (--lvr-/lucide era; Livery.zip already deleted by Nik).

**2026-07-05 afternoon triage session:** issue triage done per handoffs/2026-07-05-issue-triage.md
— #30/#32 commented + `state:needs-review` (close-on-merge proposals), #37 status comment (upstream
fix was Linux-only, macOS unresolved, zed.rs:13-16 header stale, needs Nik's 30s live retest),
#38/#40/#35 judgment comments. Nothing closed (all issues are Nik's).
**16:30 session: the 4 type errors FIXED (unstaged, awaiting Nik's commit)** — settings navigate
calls got `search: { section: "adapters" }`; rail expansion state retyped to `UpdateResult["app"]`
(bindings-derived) instead of `AppName`. ROOT CAUSE of the glitch-through, three stacked holes,
all fixed the same session: (1) `core.hooksPath` was never set in this clone → hooks never ran —
now installed; (2) `_check` used `src/**/*.ts` globs which POSIX sh expands non-recursively →
`deno task check` only checked 11 of 66 files — task is now `deno check src/`; (3) dev-local.sh
swapped deno.json for ALL tasks → now only `_dev` swaps; `_check`/`_test` run
`--config deno.local.json` directly, concurrency-safe next to a live dev server.
checks-frontend.ts also gained a staged-deno.json guard (rejects a committed local-core swap),
and `.impeccable/` was added to fmt/lint excludes. Full frontend chain verified green (52/52).
NOTE: deno.json task/exclude edits were applied to BOTH deno.json and deno.json.bak because the
dev server's swap was live at the time.
Nik closed 2026-07-05 afternoon: #30 #32 #58 #62 #63 #64 #49-epic (completed), #31 (merged into
#34), #33 #39 #40 #61 (not planned — #61 because livery has no own chrome, UI fully
theme-token-driven). Backlog kept (the ONLY 8 open issues): #34 #35 #36 #37 #38 #44 #46 #47.
A new settings-iteration issue is wanted ("settings still need a lot of work" — scope not yet
captured, ask Nik what's rough when settings work resumes). Branch merge to main is Nik's move;
the unstaged fix/hardening files should ride his next commit.
