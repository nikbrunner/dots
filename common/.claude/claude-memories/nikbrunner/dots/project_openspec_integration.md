---
name: OpenSpec — Paused, evaluating
description: OpenSpec integration paused. Nik wants to try it but not all at once. Key open questions about what to track and how it fits the new dev:flow.
type: project
---

## Status (2026-03-30)

**Paused.** OpenSpec is installed in dots repo but not integrated into the dev:flow pipeline. The `opsx:*` skills were removed during the skill restructuring. The `openspec/` directory still exists with one archived change.

## What happened

1. OpenSpec was initialized and tested with the visual-companion-v2 change
2. The archive workflow was confusing — the CLI didn't promote specs correctly, and the archive folder felt redundant with git history
3. During the skill restructuring (2026-03-30), Nik decided to defer OpenSpec integration to avoid doing too much at once

## Open questions Nik wants to resolve through experience

1. **What to track?** Nik's instinct: only `openspec/specs/<domain>/` (the living spec). Changes and archives are redundant with git history. The community has adjacent frustrations (issues #412, #796, #802) but nobody has proposed this exact approach.
2. **Does spec-driven development earn its keep?** The code is the real source of truth. Specs are a second source that can drift. But Nik values "anyone can pick up from where I left off" — specs serve as onboarding docs that stay current.
3. **How does it fit dev:flow?** If re-enabled, propose would create changes, close would archive + promote specs. But the current flow works without it.

## If re-enabling

- Re-install `opsx:*` skills (`openspec init --tools claude`)
- Add OpenSpec check to `dev:flow` SKILL.md
- Wire `openspec archive` into `5-close.md`
- Consider `.gitignore`-ing `openspec/changes/` and `openspec/changes/archive/` (track only `openspec/specs/`)
