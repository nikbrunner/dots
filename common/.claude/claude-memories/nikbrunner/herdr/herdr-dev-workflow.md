---
name: herdr-dev-workflow
description: "Verified herdr dev-environment facts on Nik's Mac — Zig workaround, dev/stable isolation, restart and seeding gotchas"
metadata:
  node_type: memory
  type: project
  originSessionId: da731df3-ce91-4dc5-8b2a-0d25f592108f
---

Verified herdr dev workflow on Nik's machine (2026-07-19), see [[herdr-contributor-context]]:

- Zig: upstream/mise 0.15.2 cannot link on macOS with Xcode 26.4 SDKs (ziglang #31669, fixed only in 0.16). Use Homebrew `zig@0.15` (carries the patch); wired via `ZIG=/opt/homebrew/opt/zig@0.15/bin/zig` in a git-excluded `mise.toml` at the herdr repo root. `cargo-nextest` via brew, `just` via mise global config.
- `herdr-dev` alias (dots `.zshrc`) runs `target/debug/herdr` with `HERDR_SOCKET_PATH`/`HERDR_CLIENT_SOCKET_PATH` stripped; debug builds use `~/.config/herdr-dev/` (config.toml + plugins symlinked to dots, own session state). Nested-herdr guard also keys on `HERDR_ENV`.
- The **server process renders TUI overlays** — after `cargo build`, restart the dev server (`pkill -f 'target/debug/herdr server'`) or changes stay invisible. Session structure persists across restarts; `pane report-agent` states are runtime-only and must be re-injected.
- `scripts/seed_navigator_demo.sh` defaults to the personal dev socket — always pass `HERDR_NAV_SOCKET_PATH` explicitly; running it twice duplicates workspaces (re-report states instead).
- Sandboxed instances: `XDG_CONFIG_HOME=<tmpdir>` isolates any herdr binary completely (herdr subdir for stable, herdr-dev for debug). Unix socket paths cap at ~104 chars — use short /tmp dirs.
