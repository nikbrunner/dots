# Install Overhaul — Fresh Machine Findings

Living log of issues hit during fresh-machine runs on the `feat/install-overhaul` branch. Append new findings as they surface. Promote to PR/tasks when run is complete.

**Branch:** `feat/install-overhaul` · **PR:** [#15](https://github.com/nikbrunner/dots/pull/15)

## Design shift — 2026-04-18

The monolithic `install/install.sh` (21 phases, ~530 LOC) has been replaced with a tiny per-OS bootstrap + numbered step scripts. See `install/README.md`. This structurally resolves the class of "silent cascade failure" bugs: steps are standalone, idempotent, re-runnable. A failure in one step does not block the rest.

**Structurally resolved by refactor:**

- **F1** — invalid YAML dry-run cascade. No more dry-run mode. Step 3 runs symlinks directly; yq presence is guaranteed by step 2 running first.
- **F7** — brew bundle failure silently non-fatal. Step 2 still tolerates partial failures, but there's no "script continues into 10 later phases that depend on the packages that failed."
- **F8** — silent exit after phase 7. No more 15-phase sequential execution. Each step is its own process; exits are explicit.
- **F9** — local bins not on PATH during install. Step scripts use absolute paths; README tells the user to reload shell after step 3.
- **F10** — brew JSON API download on every run. Cosmetic; unchanged.

**Single-file fixes applied in this PR:**

- **F2** — nvim `lib/config.lua:get_repo_path` now returns `nil` when the local repo directory doesn't exist, so lazy.nvim falls back to the remote git URL.
- **F3** — ProtonPass SSH agent setup is now step 1, which sets `SSH_AUTH_SOCK` and verifies `ssh -T git@github.com` before moving on.
- **F4** — `aviator-co/tap` + `av` removed from Brewfile and pkglist.txt; `common/.config/av/` directory deleted; symlink entry removed from `symlinks.yml`.
- **F5** — duplicate `common/.agents/AGENTS.md` key in `symlinks.yml` resolved. `common/.pi/agent/AGENTS.md` is now a relative in-repo symlink to `../../.agents/AGENTS.md`, so the `common/.pi: ~/.pi` directory link handles that target automatically. No more duplicate key.
- **F6** — `karabiner-elements` moved from `brew "..."` (formula, fails) to `cask "karabiner-elements"` in the new `install/mac/Brewfile`.
- **F11** — new `install/mac/steps/08-luarocks.sh` installs `lua@5.1` and writes `~/.luarocks/config.lua` pinning luarocks to Lua 5.1 so Mason's `luarocks install luacheck` resolves `argparse`.
- **F12** — `pick-font` is now symlinked by `install/mac/steps/09-fonts.sh` and `install/arch/steps/09-fonts.sh`; both require step 6 (helm setup) to have cloned `~/repos/nikbrunner/fonts`.

## Legend

- **Severity:** 🔴 blocks install · 🟡 degrades UX · 🟢 cosmetic
- **Status:** `open` · `in-progress` · `fixed`

---

## F1 — "Invalid YAML" during `--dry-run` 🔴

**Status:** open
**Seen:** PR #15 comment, 2026-04-15

### Symptom

```
→ Processing configuration entries...
Error: Invalid YAML in symlinks file: /Users/brunner/repos/nikbrunner/dots/symlinks.yml
```

### Root cause

`scripts/dots/symlinks.sh:114` silences `yq` stderr with `2>/dev/null`. In `--dry-run`, Phase 2 (deps) is skipped → `yq` not installed yet → `command not found` → generic "Invalid YAML" message.

### Fix options

- (a) Detect missing `yq` early in `symlinks.sh`, print honest error.
- (b) Skip Phase 4 in `--dry-run` when `--no-deps` effectively applies (or when `yq` missing), show "would create symlinks".
- (c) Install `yq` even in dry-run as prerequisite (breaks dry-run promise — reject).

Lean toward (a) + (b).

---

## F2 — nvim local plugins fail on fresh machine 🔴

**Status:** open
**Seen:** PR #15 comment, 2026-04-15

### Symptom

```
○ black-atom      ■ exists failed
  Local plugin does not exist at `/Users/brunner/repos/black-atom-industries/nvim`
○ fff-snacks.nvim
  Local plugin does not exist at `/Users/brunner/repos/nikbrunner/fff-snacks.nvim`
○ radar.nvim
  Local plugin does not exist at `/Users/brunner/repos/black-atom-industries/radar.nvim`
```

### Root cause

`common/.config/nvim/lua/config.lua:7` hardcodes `dev_mode = true`. `lib/config.lua:get_repo_path` returns the local path unconditionally when `dev_mode = true`. On a fresh machine those repos aren't cloned yet.

### Fix

Update `lib/config.lua:get_repo_path` to check `vim.fn.isdirectory(path) == 1`. Return `nil` when missing so lazy.nvim falls back to the remote git URL. Keeps dev workflow for machines with the repos, auto-falls back otherwise.

---

## F3 — SSH agent `SSH_AUTH_SOCK` export missing from README 🟡

**Status:** open
**Seen:** PR #15 comment, 2026-04-15

### Symptom

User felt chicken/egg after `pass-cli ssh-agent daemon start`. Daemon prints the required export, but it's easy to miss under stress.

### Fix

`install/README.md` Stage 1 step 3: add the explicit export before `ssh -T`:

```bash
pass-cli login
pass-cli ssh-agent daemon start
export SSH_AUTH_SOCK=$HOME/.ssh/proton-pass-agent.sock
ssh -T git@github.com
```

---

## F4 — `av` (Aviator) tap install failure 🟢

**Status:** open — user requested discard
**Seen:** PR #15 comment, 2026-04-15

### Action

Remove from `install/deps/Brewfile` if still present, and drop `common/.config/av/config.yaml` symlink entry from `symlinks.yml` if no longer used.

---

## F5 — Duplicate key in `symlinks.yml` 🟡

**Status:** open
**Seen:** static review, 2026-04-18

### Symptom

`symlinks.yml:3-4` maps `common/.agents/AGENTS.md` to two different targets:

```yaml
common/.agents/AGENTS.md: ~/.pi/agent/AGENTS.md
common/.agents/AGENTS.md: ~/.claude/CLAUDE.md
```

mikefarah `yq` keeps the last one wins → `~/.pi/agent/AGENTS.md` symlink is **never created**. Silent bug.

### Fix

Either drop one target or duplicate the source file via a second key. One source → many targets isn't supported by current parser structure.

---

## Open question — strategic

Keep the automated install or shift to docs-only? Current lean: keep it, but:

- Fix the 5 findings above first.
- Consider `--phase N` resumability so a single failure doesn't block the whole run.
- Make interactive prompts (`gh auth login`, `helm setup`) non-blocking / optional.

---

## New findings (append below during run)

---

## F6 — `karabiner-elements` install fails (wrong entry type) 🟡

**Status:** open — user installed manually 2026-04-18
**Seen:** 2026-04-18, Phase 2 on macOS Tahoe

### Symptom

```
Installing karabiner-elements
Warning: 'karabiner-elements' formula is unreadable: No available formula with the name "karabiner-elements".
Error: No formulae found for karabiner-elements.
Installing karabiner-elements has failed!
```

### Root cause

`install/deps/Brewfile:23` declares `brew "karabiner-elements"` — this is a **cask**, not a formula. `brew install karabiner-elements` from CLI works because the CLI falls back to cask search when no formula matches; `brew bundle` with `brew "..."` is strict and does not fall back.

### Fix

```diff
-brew "karabiner-elements"
+cask "karabiner-elements"
```

Check the cask section further down for an existing entry first — don't add a duplicate.

---

## F7 — `brew bundle` failure is silently non-fatal 🟡

**Status:** open
**Seen:** 2026-04-18, Phase 2

### Symptom

```
`brew bundle` failed! 1 Brewfile dependency failed to install
Done!

⚙️ Phase 3: System Configuration
```

Script continues past the failure without flagging it — user has to read the middle of the log to notice.

### Root cause

`install/deps/macos.sh:193` calls `brew bundle install` but doesn't capture its exit code. Because `install_all` is invoked as `if ! install_all; then` in `install.sh:131`, `set -e` is disabled inside the function (bash rule for guarded commands). Last statement is `echo "Done!"` → `install_all` returns 0 regardless of brew bundle result.

### Fix options

- (a) Capture exit code in `install_all`, return it so caller catches it.
- (b) Keep non-fatal (some failures are recoverable) but print a loud banner: `⚠️ N brew packages failed, see log above`.
- (c) Both: make it non-fatal by default, exit if `--strict` flag is passed.

Lean toward (b) — user needs prominent surfacing, not hard exit.

---

## F8 — Install silently exits after Phase 7 🔴

**Status:** open — confirmed, user verified full paste
**Seen:** 2026-04-18

### Symptom

Output ends after `pp-env-sync` output:

```
synced 9 vars to /Users/brunner/.env
synced 6 vars to /Users/brunner/.env.wichtel
$
```

No Phase 8 (Claude MCP), Phase 9 (rmpc), Phase 11 (GitHub auth), Phase 12 (Helm), Phase 15 (Validation), no final "Machine Setup Complete!" banner. Script exited silently with no error message.

### Most likely cause

`install.sh:223` sources `.env` files inside `set -a`/`set +a`:

```bash
for f in ~/.env ~/.env.*; do [[ -r "$f" ]] && { set -a; source "$f"; set +a; }; done
```

Under `set -e` from line 5, any non-zero exit in this loop kills the script. Candidates:

- `.env.wichtel` contains syntax that `source` rejects (e.g. values with unescaped characters under `set -a`).
- The glob `~/.env.*` has no matches → literal `~/.env.*` fails `[[ -r ]]` → loop iteration returns non-zero. Typically benign but interacts badly with `set -e`.
- `pp-env-sync` wrote a file that re-runs `set +e`-incompatible code on source.

### Action

1. Add an ERR trap to `install.sh` so silent exits become visible:

   ```bash
   trap 'echo "❌ install.sh exited unexpectedly at line $LINENO (exit $?)" >&2' ERR
   ```

2. Harden the env-source loop:

   ```bash
   for f in "$HOME/.env" "$HOME"/.env.*; do
       [[ -r "$f" ]] || continue
       set -a
       # shellcheck disable=SC1090
       source "$f" || echo "⚠️ failed to source $f"
       set +a
   done
   ```

3. Inspect `~/.env` and `~/.env.wichtel` on the new laptop — grep for unquoted `$`, unmatched quotes, or multi-line values.

---

## F9 — Local bins unavailable to user during/after install 🟡

**Status:** open
**Seen:** user memory (earlier run), 2026-04-15

### Symptom

User recalls that `pp-env-sync` and other bins from `common/.local/bin/` weren't callable after first install.

### Root cause

Install script calls internal scripts via absolute paths (`$DOTS_DIR/common/.local/bin/pp-env-sync`), so those work **inside** the script. But the user's shell doesn't have `~/.local/bin` on PATH until `~/.zshrc` is re-sourced. Until then, typing `pp-env-sync` fails.

### Fix

- Post-install banner should include: `source ~/.zshrc` as step 1 (already in current final message — confirm it's actually being printed in F8 once that's fixed).
- Optionally: Phase 6 could `export PATH="$HOME/.local/bin:$PATH"` for the current install.sh session so user-facing commands like `dots` work before shell reload. Cosmetic since install.sh itself doesn't need it.

---

## F11 — Mason `luacheck` install fails — argparse not found for Lua 5.5 🔴

**Status:** open
**Seen:** 2026-04-18, first nvim launch

### Symptom

```
Mason: Failed to install luacheck: spawn: luarocks failed with exit code 1 and signal 0.
Error: Could not satisfy dependency argparse >= 0.6.0: No results matching query were found for Lua 5.5.
```

`luarocks` is installed (`/opt/homebrew/bin/luarocks`).

### Root cause

Current Homebrew `luarocks` formula defaults to Lua 5.5 (latest). Mason calls `luarocks install luacheck` with no Lua version specified → uses 5.5 → no `argparse` rock for 5.5 yet. Neovim's embedded runtime is LuaJIT (Lua 5.1-compatible), so rocks for nvim plugins should target 5.1.

### Fix options

- (a) Add `brew "lua@5.1"` to Brewfile and set luarocks default to 5.1 in `~/.luarocks/config.lua`:

  ```lua
  lua_version = "5.1"
  ```

  Mason would then get 5.1 rocks automatically.

- (b) Configure Mason's luarocks invocation with `--lua-version=5.1` (if the Mason plugin exposes this).

- (c) Install argparse for 5.5 manually (brittle, same class of failures will recur for other rocks).

Lean toward (a). Could add a new symlink entry for `common/.config/luarocks/config.lua` OR seed `~/.luarocks/config.lua` from install.sh Phase 6-ish.

### Verify

```bash
luarocks --version        # prints which Lua it targets
luarocks config lua_version
```

---

## F12 — `pick-font` not on PATH 🟡

**Status:** open
**Seen:** 2026-04-18, post-install

### Symptom

```
$ pick-font
zsh: command not found: pick-font
```

### Root cause

Phase 13 is gated on `[[ -d "$HOME/repos/nikbrunner/fonts" ]]`. Fresh machine doesn't have this repo. Phase silently skipped → `pick-font` never symlinked into `~/.local/bin`. Fonts repo is cloned by `helm setup`, which this run never reached (blocked by F8).

### Fix options

- (a) Once F8 is fixed + helm setup runs, `pick-font` should appear (assuming helm clones `nikbrunner/fonts`).
- (b) If the fonts repo isn't in helm's list, add it. Check `common/.config/helm/config.yml`.
- (c) Long-term: remove Phase 13 from `install.sh`. Fonts repo has its own `install.sh`; run it as a one-shot after `helm setup` via the post-install checklist.

---

## F10 — Brew fetches full JSON API on every run 🟢

**Status:** open — cosmetic
**Seen:** every run

### Symptom

```
✔︎ JSON API cask.jws.json   Downloaded 15.4MB
✔︎ JSON API formula.jws.json   Downloaded 32.0MB
```

47MB of metadata downloaded every time — not a bug, but can `brew update` be skipped inside `brew bundle` when deps are already satisfied? Probably not worth optimizing.
