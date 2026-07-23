---
name: theme-provisioning-taxonomy
description: "The 3-class theme provisioning model (External/Linked/Merged) decided 2026-07-18, why it's three and not five, and the"
metadata:
  node_type: memory
  type: project
  originSessionId: 0a3bf6dc-4682-4da3-a206-881878178936
---

**Theme provisioning** (decided 2026-07-18 after three review rounds with Nik) classifies adapters
by ONE question — who consumes the managed theme files:

- **External** (nvim, helm, delta): files provided by plugin/binary/user; livery only switches.
- **Linked** (ghostty, zed, tmux, obsidian): livery symlinks files into a location the app reads;
  switching updates a config pointer that setup may add once.
- **Merged** (lazygit): app can't read external theme files; livery YAML-merges values into
  config.yml on every switch.

Rejected on the way: "Unmanaged" (livery still manages switching), "Referenced" for tmux
(mechanism detail, not a consumer difference — tmux scans nothing, symlinks + pointer make it
ordinary Linked), "Installed" for obsidian (its specialness is a _setup precondition_ — the vault
path — not a different consumer; the vault themes dir derives from config_path like ghostty/zed).
Nik's rule: keep class count as low as honestly possible; every class needs a one-sentence
definition. Preconditions and switch pointers are per-adapter metadata, NOT classes.

Nvim's downloaded colors/*.lua were 3-line stubs requiring the plugin — that discovery triggered
the whole correction. Canonical docs: ADAPTERS.md + GLOSSARY.md "Theme Provisioning" section.

**MERGED to main 2026-07-18** (6cfa9a2, #34 closed, branch deleted). Also delivered: hermetic
smoke suite (tests/setup_smoke.rs — tempdir $HOME + LIVERY_THEMES_BASE_URL fixture server),
bindings regenerate via cargo test (lib.rs export test), tauri-plugin-opener for prerequisite
links (opener:default capability; lazy-route deps need vite optimizeDeps.include or dev 504s).
Nik's dots/live config already updated (hardlinked file): tmux themes_path
~/.config/tmux/themes, flat `source-file {themesPath}/{themeKey}.conf`; lazygit themes_path →
managed dir. Open follow-ups: #66 settings iteration (per-adapter sub-pages + backend-declared
editable fields — field-usage matrix in the issue), #65 GUI e2e (Linux build + Dockerized
tauri-driver + Cucumber user stories), #35 wizard.
