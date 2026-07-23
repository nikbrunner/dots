---
name: herdr-contributor-context
description: "Nik is an external contributor to ogulcancelik/herdr, uses it as a daily driver; strict approval-gated contribution process applies"
metadata:
  node_type: memory
  type: project
  originSessionId: f8fe62fd-a00d-49a3-9ea9-8a726b7e7725
---

Nik uses herdr (terminal agent runtime by ogulcancelik) as a daily driver and wants to contribute as an **external contributor** (as of July 2026). The external-contributor guardrail in the repo CLAUDE.md applies: no PRs before an accepted issue with `/approve @username`, feature ideas go to GitHub Discussions, agents must never open issues on his behalf.

Local setup notes: toolchain via mise (just, bun, zig). Repo requires **Zig 0.15.2** (vendored libghostty-vt); Nik had 0.16.0 installed — use `ZIG` env var or dir-scoped `mise use zig@0.15.2`. cargo-nextest was missing initially. As of 2026-07-18 the clone at `~/repos/ogulcancelik/herdr` had `origin` pointing at upstream, not his fork.
