# Plan: Migrate Pi Install from Mise to Official Install Script

## Context

Pi (the coding agent) is currently managed by mise on every machine via `common/.config/mise/config.toml`:

```toml
"npm:@mariozechner/pi-coding-agent" = "latest"
```

Two problems with this:

1. **Stale package name.** The package was renamed from `@mariozechner/pi-coding-agent` to `@earendil-works/pi-coding-agent`. Mise still pulls the old, deprecated one.
2. **Self-update doesn't work cleanly.** `pi update --self` runs `npm install -g` against whichever npm pi finds in PATH. With pi pinned in `mise.toml`, mise periodically reasserts the old package, undoing self-updates.

The official installer (`https://pi.dev/install.sh`) handles version migration (renamed packages), self-update, and node detection — it's now the recommended install path.

## Goal

- Stop managing pi through mise.
- Install pi via the official install script on every machine.
- Reinstall pi extensions via `pi install npm:<name>`.

## Files to Modify

| File                              | Action                                                         |
| --------------------------------- | -------------------------------------------------------------- |
| `common/.config/mise/config.toml` | **Edit** — remove the `npm:@mariozechner/pi-coding-agent` line |
| `plans/migrate-pi-from-mise.md`   | **This file** — delete after rollout is complete               |

No symlink changes. No new files. Pi installs to wherever the install script lands it (homebrew on macOS, apt/apk on Linux, or standalone fallback).

## Caveat: Pi's Runtime Still Resolves to Mise's Node

The install script puts the `pi` binary at e.g. `/opt/homebrew/bin/pi`, but pi's shebang is `#!/usr/bin/env node` — which resolves to mise's node when mise is first in PATH. Effect:

- Pi _binary_ lives in homebrew (or wherever the script installed it).
- Pi _runtime_ uses mise's node.
- Pi extensions (`pi install npm:X`) therefore land in mise's `node_modules/`.
- On `pi update --self`, pi calls `npm install -g` via mise's npm — so pi itself eventually migrates into mise too.

This is functionally fine. Pi works. Self-update works. The only caveat: if you ever change mise's pinned node version (`node = "lts"` → some other version), extensions disappear and pi reinstalls them on next launch. That's annoying but recoverable.

If you want pi _and_ its extensions fully outside mise, you'd need a wrapper script at higher PATH priority that sets `PATH="/opt/homebrew/bin:$PATH" exec /opt/homebrew/bin/pi "$@"`. Not part of this migration — defer until it's actually a problem.

## Steps (One-Time, in dots)

1. Edit `common/.config/mise/config.toml`: delete line `"npm:@mariozechner/pi-coding-agent" = "latest"`.
2. Commit + push.

## Steps (Per Machine)

After pulling the dots change above, on each machine:

```bash
# 1. Remove all pi-related packages from mise's node
NODE_BIN="$(mise where node)/bin"
$NODE_BIN/npm uninstall -g \
  @mariozechner/pi-coding-agent \
  @earendil-works/pi-coding-agent \
  pi-web-access pi-ask-user pi-fff pi-lean-ctx \
  @ff-labs/pi-fff @plannotator/pi-extension 2>/dev/null

# 2. Remove any stale pi from homebrew (macOS only)
/opt/homebrew/bin/npm uninstall -g \
  @mariozechner/pi-coding-agent \
  pi-web-access pi-ask-user pi-fff pi-lean-ctx \
  @ff-labs/pi-fff @plannotator/pi-extension 2>/dev/null

# 3. Install pi via the official script
#    Prepend homebrew to PATH so pi lands there (macOS).
#    Linux: drop the PATH prefix; the script picks apt/apk/standalone.
PATH="/opt/homebrew/bin:$PATH" sh -c "$(curl -fsSL https://pi.dev/install.sh)"

# 4. Verify
which pi              # should not be a mise path
pi --version

# 5. Reinstall extensions
pi install npm:pi-web-access
pi install npm:pi-ask-user
pi install npm:@ff-labs/pi-fff
pi install npm:@plannotator/pi-extension
```

The extension list above matches the `packages` array in `~/.pi/agent/settings.json`. Adjust if that list has diverged on a given machine.

## Verification

- `which pi` does not contain `mise` in the path.
- `pi --version` runs without "Cannot find module" errors.
- Pi launches with all expected extensions loaded (check the `[Extensions]` block in pi's startup banner).
- `pi update --self` reports "already up to date" or successfully updates.

## Rollback

If something breaks, revert the mise config edit and run `mise install` to restore pi via mise. The extensions in `~/.pi/agent/settings.json` will be reinstalled on next pi launch.

## Done When

- All machines pulled the dots change and ran the per-machine steps.
- No machine has `npm:@mariozechner/pi-coding-agent` or `npm:@earendil-works/pi-coding-agent` listed under mise.
- This file is deleted.
