# Plan: Install System Overhaul

> Source PRD: nikbrunner/dots#14

## Architectural decisions

Durable decisions that apply across all phases:

- **Directory split**: `install/` owns bootstrap + deps. `scripts/` retains dots runtime only (detect-os, symlinks, theme-link, log, lib).
- **Bootstrap sequence**: Xcode CLT → Homebrew → Brewfile → ProtonPass env sync → non-brew deps → system config → symlinks → MCP → helm → repos
- **ProtonPass is the SSH/secrets provider**: `pass-cli test` for health check, `pp-env-sync` for env vars, `pass-cli ssh-agent` for SSH
- **Helm is the repo orchestrator**: replaces the deleted `repos` script. Built from source during install, then `helm setup` clones remaining repos.
- **`claude-mcp.sh` stays in `scripts/`**: standalone utility, not part of install/ (but called from install flow after env sync)

---

## Phase 1: Directory restructure

**User stories**: 8

### What to build

Move install script and dependency management into `install/` at repo root. Update all internal path references. Update `symlinks.yml` for moved Brewfile path.

### Acceptance criteria

- [ ] `install/install.sh` exists and is the main entry point
- [ ] `install/deps/` contains `install.sh`, `macos.sh`, `arch.sh`, `Brewfile`, `npm-globals.txt`
- [ ] `scripts/install.sh` and `scripts/deps/` are removed
- [ ] All `source` and path references within moved scripts point to correct new locations
- [ ] `symlinks.yml` Brewfile entry updated: `install/deps/Brewfile: ~/Brewfile`
- [ ] `scripts/` retains only: `dots/` (detect-os.sh, symlinks.sh, theme-link.sh, lib.sh), `log.sh`, `claude-mcp.sh`
- [ ] `chmod` block in install.sh updated to target `install/` paths instead of `scripts/install.sh`
- [ ] `validate_dependencies()` Brewfile path updated from `scripts/deps/Brewfile` to `install/deps/Brewfile`
- [ ] `CLAUDE.md` key files section updated with new paths
- [ ] `install/install.sh --dry-run` completes without path errors (path correctness only — dry-run behavior fixes are Phase 2)

---

## Phase 2: Critical bug fixes

**User stories**: 2, 3, 4, 11

### What to build

Fix all bugs that would cause install.sh to fail or misbehave on a fresh macOS machine.

### Acceptance criteria

- [ ] `install/deps/macos.sh`: auto-installs Xcode CLT if missing (`xcode-select --install`)
- [ ] `install/deps/macos.sh`: auto-installs Homebrew if missing (official install script)
- [ ] `scripts/claude-mcp.sh`: respects `--dry-run` flag (prints what would be configured, no side effects)
- [ ] `install/install.sh`: all filesystem mutations (`mkdir -p`, `ln -s`, `chmod`) wrapped in dry-run guards
- [ ] `install/install.sh`: Phase 8 (`repos setup`) replaced with helm bootstrap (Phase 3, step 14 below)
- [ ] `install/deps/install.sh`: `validate_dependencies()` guards `brew bundle check` behind macOS detection
- [ ] `install/install.sh`: dry-run dependency list matches actual Brewfile (no `1password, 1password-cli`)
- [ ] `install/install.sh`: phase numbering is sequential (1-N, no gaps or decimals)
- [ ] `install/install.sh --dry-run` completes cleanly with no side effects
- [ ] `common/.local/bin/pp-env-sync`: remove duplicate `exec zsh` (line 28)

---

## Phase 3: ProtonPass migration + install flow reorder

**User stories**: 5, 6, 7

### What to build

Replace all 1Password references in the install flow with ProtonPass equivalents. Reorder install phases so env sync happens before MCP setup. Add helm bootstrap phase.

### Acceptance criteria

- [ ] `configure_system()` in `install/deps/install.sh`: `op-ssh-sign` check replaced with `pass-cli test` health check
- [ ] `configure_system()` in `install/deps/install.sh`: prints ProtonPass status message instead of 1Password
- [ ] Install flow order: Brewfile → `pp-env-sync` → non-brew deps → system config → symlinks → MCP → helm
- [ ] `pp-env-sync` runs after Brewfile (which installs `pass-cli`) and before MCP setup (which needs API keys)
- [ ] Helm bootstrap phase: clone helm repo → `make install` → offer `helm setup`
- [ ] Helm bootstrap only runs if Go is available (installed via Brewfile)
- [ ] `helm setup` is offered interactively (gum confirm / read prompt), not forced
- [ ] Fonts setup phase moved after helm setup (fonts repo may be cloned by `helm setup`)

---

## Phase 4: Documentation

**User stories**: 1, 8, 9, 10

### What to build

Write `install/README.md` with complete bootstrap instructions. Update main `README.md`. Delete stale docs.

### Acceptance criteria

- [ ] `install/README.md` exists with Stage 1 (manual bootstrap) and Stage 2 (automated install) sections
- [ ] Stage 1 covers: Xcode CLT, Homebrew, ProtonPass install + login + SSH agent, verify SSH, clone dots
- [ ] Stage 1 includes links to ProtonPass CLI docs (https://protonpass.github.io/pass-cli/, .../commands/ssh-agent)
- [ ] Stage 2 covers: running `install/install.sh`, what each phase does, available flags
- [ ] `README.md` Installation section rewritten: prerequisites reference ProtonPass, points to `install/README.md` for details
- [ ] `docs/SSH_SETUP.md` deleted
- [ ] No remaining references to 1Password in README.md or install/ scripts
- [ ] `install/README.md` is macOS-focused for Stage 1; Arch bootstrap docs are out of scope (future enhancement)

---

## Phase 5: UTM VM validation

**User stories**: 12

### What to build

Install UTM, create a macOS VM, run the full install flow, document findings.

### Acceptance criteria

- [ ] macOS Sequoia VM created and bootable
- [ ] `install/install.sh` run on clean VM
- [ ] All phases complete without error
- [ ] `dots status` works after install
- [ ] Findings documented as comment on #14

### Optional

- [ ] UTM installed on host machine (Optional)
