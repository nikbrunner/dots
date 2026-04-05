---
name: 1Password to ProtonPass Migration
description: Migrating from 1Password to ProtonPass — SSH agent, git signing, env vars, vault import. Phase 0-2 done, env sync in progress.
type: project
---

Migrating from 1Password to ProtonPass as part of broader move to Proton ecosystem.

**Why:** Consolidating into the Proton ecosystem. 1Password Developer section (SSH Agent + Environments) was the main concern — ProtonPass CLI covers both.

**How to apply:** When working on SSH, git signing, env vars, or secrets in dots, use ProtonPass patterns not 1Password.

## Status (2026-03-31)

- **Phase 0 (Git Signing):** Done. ProtonPass SSH agent works for git commit signing via standard SSH protocol. Verified badge on GitHub (commit d1fe236).
- **Phase 1 (Preparation):** Done. CLI installed, logged in, zsh completions set up.
- **Phase 2 (Import):** Done. 1088 items + 112 files imported. Identity items may have incomplete custom fields — known ProtonPass limitation.
- **Phase 3 (SSH Keys):** Partially done. GitHub key imported. `remote_manager` key still needs import.
- **Phase 4 (Env Vars):** In progress. `pp-env-sync` script created, caches env vars from ProtonPass item to `~/.env`. LaunchAgent + systemd service for autostart. Still needs all keys added to ProtonPass `.env` item.
- **Phase 5-7:** Not started.

## Key technical decisions

- **SSH config:** `~/.ssh/config` → `IdentityAgent "~/.ssh/proton-pass-agent.sock"` (was 1Password socket)
- **SSH_AUTH_SOCK:** Exported in `.zshrc` → `$HOME/.ssh/proton-pass-agent.sock`
- **Git signing:** Removed `gpg.ssh.program = op-ssh-sign` from `.gitconfig.local` (this was the main blocker — git was calling 1Password binary directly). Now uses standard `ssh-keygen` via `SSH_AUTH_SOCK`.
- **Deleted `.gitconfig.local`** for both macOS and Arch — only contained 1Password signing config.
- **Env var caching:** `pp-env-sync` script reads ProtonPass `.env` item via `pass-cli item view --output=json | jq`, writes to `~/.env`. CLI call takes ~6-12s (network), so caching is necessary — too slow for shell startup.
- **Alias:** `pp` → `pass-cli` in `.zshrc`
- **Deps:** 1password replaced with proton-pass + pass-cli in Brewfile and arch.sh
- **Autostart:** LaunchAgent (macOS) + systemd user service (Arch) for both SSH agent and env sync
- **Passkeys:** Not exportable (FIDO2 spec). Must re-register per service with ProtonPass.
- **Obsidian project note:** `01 - Projects/1Password to ProtonPass Migration.md`

## Gaps vs 1Password

- No biometric unlock for CLI
- No grouped "Environments" UI — use vaults + cached `.env`
- Git signing works but is not officially supported by Proton (community workaround)
- Identity items import with incomplete custom fields
- `pass-cli` has ~6-12s latency per network call
