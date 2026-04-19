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

## 2. Dependencies & Runtimes

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

## 2. ProtonPass + SSH

Start the Proton Pass Desktop app and sign in.

```sh
# Login into the CLI:
pass-cli login

# Start SSH agent daemon
pass-cli ssh-agent daemon start
export SSH_AUTH_SOCK="$HOME/.ssh/proton-pass-agent.sock"

# Verify GitHub SSH (should show: "Hi $USER! You've successfully authenticated...")
ssh -T git@github.com

# Log into GitHub CLI
gh auth login
```

If SSH fails, fix it before continuing — nothing downstream works without GitHub SSH.

## 3. Clone dots

```sh
mkdir -p ~/repos/nikbrunner
git clone git@github.com:nikbrunner/dots.git ~/repos/nikbrunner/dots
cd ~/repos/nikbrunner/dots
```

## 4. Symlinks

```sh
# Create symlinks from symlinks.yml
./scripts/dots/symlinks.sh
```

After that, the dot binaries from `~/.local/bin` will be available in your `$PATH`.

## 5. Env Sync

Pull API keys and env vars from ProtonPass into `~/.env` and `~/.env.*`.

```sh
pp-env-sync
```

## 6. helm + Repos

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

## 7. Neovim

Install neovim plugins via [lazy.nvim](https://github.com/folke/lazy.nvim).

```sh
nvim --headless "+Lazy! sync" +qa
```

Enter Neovim to see if plugins are installed.

> [!NOTE]
> On entering Neovim, the Mason plugins configured in `common/.config/nvim/lua/specs/mason.lua` will be installed.

## 8. Claude Code MCP Servers

Configure MCP servers for Claude Code (requires Step env sync for API keys).

```sh
claude mcp add --scope user exa -e "EXA_API_KEY=$EXA_API_KEY" -- npx -y exa-mcp-server
claude mcp add --scope user --transport http Ref https://api.ref.tools/mcp -H "x-ref-api-key: $REF_API_KEY"
claude mcp add --scope user chrome-devtools -- npx chrome-devtools-mcp@latest
```

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
