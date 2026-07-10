# macOS Setup

Fresh-machine setup in numbered steps.

---

## 1. Xcode

Install Xcode Command Line Tools

```sh
xcode-select --install
```

## 2. Homebrew

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Make sure Homebrew is in your $PATH
eval "$(/opt/homebrew/bin/brew shellenv)"
```

## 3. Clone dots

```sh
mkdir -p ~/repos/nikbrunner
git clone https://github.com/nikbrunner/dots.git ~/repos/nikbrunner/dots
cd ~/repos/nikbrunner/dots
```

## 4. Prepare Mac Security (Gatekeeper / Developer Tools)

Do this **before** installing runtimes and running dev servers.

**The problem:** Vite/Storybook (and other JS tooling) execute ad-hoc, linker-signed binaries — `esbuild`,
native `.node` addons like `lightningcss`, `swc`, `rollup`. On every first exec, macOS Gatekeeper assesses
them: `syspolicyd` (policy/signature check) and `trustd` (trust chain) fire. Because these assessments are
serialized, a cold Storybook start pins `syspolicyd` near 100% and **the whole terminal grinds** — every
subsequent command queues behind the backlog.

Measured on this repo: `syspolicyd` idle ≈ 5% → **≈ 78%** during Storybook cold start, with `trustd` ≈ 24%
alongside. `node` itself is fine (properly Developer ID signed); the culprit is the ad-hoc `node_modules`
binaries.

**The fix:** grant your terminal the Developer Tools entitlement so `syspolicyd` skips assessment for software
run under it.

> System Settings → Privacy & Security → **Developer Tools** → **+** → add your terminal app (Ghostty) → enable.

- One-time. Persists across reboots.
- **Reboot afterwards** — `syspolicyd` caches policy in memory and only re-reads the grant cleanly after a
  restart. Restarting only the terminal app is **not** enough (learned the hard way).
- `sudo killall syspolicyd` just restarts the daemon (launchd respawns it); it does **not** disable Gatekeeper.
- Avoid `sudo spctl --global-disable` — it drops Gatekeeper for the whole system, not just dev tooling. The
  Developer Tools grant is the surgical fix.

**Verify** after reboot — start Storybook, then in another shell:

```sh
# Should stay near idle (single digits), NOT spike to ~78%
ps -Ao pcpu,comm | grep -E 'syspolicyd|/usr/libexec/trustd$' | sort -rn | head -3
```

Background reading:

- https://sigpipe.macromates.com/2020/macos-catalina-slow-by-design/
- https://github.com/drduh/macOS-Security-and-Privacy-Guide

## 5. Dependencies & Runtimes

Install brew packages (system deps + casks). Check `./Brewfile` for the list.

```sh
brew bundle install --file=install/mac/Brewfile
```

Install [mise](https://mise.jdx.dev/) (runtime + CLI tool manager):

```sh
curl https://mise.run | sh
```

Install all tools and runtimes tracked in `common/.config/mise/config.toml`:

```sh
# Trust this repo's config
mise trust

# Install everything from common/.config/mise/config.toml
mise install
```

## 6. ProtonPass + SSH

Run the setup script — it handles login and starts the agent (no PAT needed on macOS):

```sh
./install/proton-pass-setup.sh
```

Then verify and log into GitHub CLI:

```sh
# Verify GitHub SSH (should show: "Hi $USER! You've successfully authenticated...")
ssh -T git@github.com

# Log into GitHub CLI
gh auth login
```

If SSH fails, fix it before continuing — nothing downstream works without GitHub SSH.

## 7. Switch git remote to SSH

```sh
git remote set-url origin git@github.com:nikbrunner/dots.git
```

## 8. Symlinks

```sh
# Create symlinks from symlinks.yml
./scripts/dots/symlinks.sh
```

After that, the dot binaries from `~/.local/bin` will be available in your `$PATH`.

## 9. Env Sync

Pull API keys and env vars from ProtonPass into `~/.env` and `~/.env.*`.

```sh
pp-env-sync
```

## 10. helm + Repos

> [!NOTE]
> Currently, helm only supports GitHub repos.

```sh
mkdir -p ~/repos/black-atom-industries/
git clone git@github.com:black-atom-industries/helm.git ~/repos/black-atom-industries/helm
cd ~/repos/black-atom-industries/helm && make install
```

Clone configured repos:

```sh
helm setup
```

Seed zoxide with all cloned repo paths (also runs hourly via LaunchAgent):

```sh
zoxide-seed-sync
```

## 11. Neovim

Install neovim plugins via [lazy.nvim](https://github.com/folke/lazy.nvim).

```sh
nvim --headless "+Lazy! sync" +qa
```

Enter Neovim to see if plugins are installed.

> [!NOTE]
> On entering Neovim, the Mason plugins configured in `common/.config/nvim/lua/specs/mason.lua` will be installed.

## 12. Claude Code MCP Servers

Configure MCP servers for Claude Code (requires Step 9 env sync for API keys).

```sh
claude mcp add --scope user exa -e "EXA_API_KEY=$EXA_API_KEY" -- npx -y exa-mcp-server
claude mcp add --scope user --transport http atlassian-rovo-mcp https://mcp.atlassian.com/v1/mcp/authv2
claude mcp add --scope user fff -- "$HOME/.local/bin/fff-mcp"
claude mcp add --scope user chrome-devtools -- npx chrome-devtools-mcp@latest
```

> [!NOTE]
> `claude mcp add --scope user` writes to whichever config `CLAUDE_CONFIG_DIR` points at (default `~/.claude`). If you also
> use the `claude-work` identity (see `.zshrc`), re-run the same commands with `CLAUDE_CONFIG_DIR=~/.claude-work` set —
> it's a separate config dir and won't inherit these automatically.

## 13. Git Hooks (contributing to dots)

Wire the repo's pre-commit hook (prettier + shfmt + Makefile checks) so it runs on every commit. `core.hooksPath` is per-clone, so this is needed once per machine:

```sh
./install/setup-git-hooks.sh
```

Only relevant if you'll be committing changes to this repo. Format staged work first with `make fmt`.

## Post-Install Checklist

### App Logins

- [ ] **Raycast** - Open, sign in, import settings
- [ ] **Claude** - Open, sign in
- [ ] **Obsidian** - Open, sign in and setup sync
- [ ] **Readwise Reader** - Open, sign in
- [ ] **Zed** - Open, sign in
- [ ] **Atuin** - Run `atuin login`
- [ ] **Signal** - Open, link device via phone
- [ ] **WhatsApp** - Open, link device via phone
- [ ] **Browser** - and Login into various services

### License Keys

- [ ] **Superwhisper** - Open, enter license key
- [ ] **Shottr** - Open, enter license key (or use free tier)
- [ ] **Homerow** - Open, grant accessibility permissions and add license key

### System Settings

- [ ] **Neovim** - Run `bob install stable && bob use stable`
- [ ] **Karabiner-Elements** - Grant permissions, import rules
- [ ] **Keyboard** - Set key repeat rate / delay in System Settings
- [ ] **Keyboard** - Disable Hypr and Meh Keybings from Mac System Settings
- [ ] **ProtonPass** - Enable browser extension

### Verify

- [ ] `dots status` — shows clean state
- [ ] `ssh -T git@github.com` — authenticated
- [ ] `gh auth status` — authenticated
- [ ] `pass-cli test` — authenticated
- [ ] Open a tmux session, test `helm` keybinding
