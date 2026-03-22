---
name: feedback-personal-config
description: After changing livery config structure (new apps, new fields), update Nik's personal config file too
type: feedback
---

When adding new apps or fields to livery's config defaults, also update Nik's personal config file at `~/repos/nikbrunner/dots/common/.config/black-atom/livery/config.json` (symlinked via dots). There's no automatic migration yet, so manual updates are needed.

**Why:** Nik tested the Zed updater and it silently did nothing because Zed wasn't in his config file. The merge_with_defaults adds it as disabled, but it still needs to be explicitly enabled for testing.

**How to apply:** After any change to `config/defaults.rs` that adds a new app, check the personal config and add the entry with `enabled: true` if Nik wants to test it.
