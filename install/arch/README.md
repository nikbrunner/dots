# Arch Linux Setup

Fresh-machine setup in numbered steps.

> [!NOTE]
> This guide assumes EndeavourOS or vanilla Arch with a working internet connection.

---

## 0. Update System

```sh
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm base-devel git
```

## 1. Clone dots

```sh
mkdir -p ~/repos/nikbrunner
git clone https://github.com/nikbrunner/dots.git ~/repos/nikbrunner/dots
cd ~/repos/nikbrunner/dots
```

## 2. Install paru (AUR helper)

On EndeavourOS, paru may already be installed. If not:

```sh
TMP_DIR="$(mktemp -d)"
git clone https://aur.archlinux.org/paru.git "$TMP_DIR/paru"
(cd "$TMP_DIR/paru" && makepkg -si --noconfirm)
rm -rf "$TMP_DIR"
```

## 3. Dependencies & Runtimes

Install system packages from `pkglist.txt` via paru. Check the file for the list — it contains everything mise can't handle (system deps, desktop apps, Wayland compositor, etc.).

```sh
paru -S --needed --noconfirm $(grep -v '^\s*#\|^\s*$' install/arch/pkglist.txt)
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

## 4. ProtonPass + SSH

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

## 5. Switch git remote to SSH

```sh
git remote set-url origin git@github.com:nikbrunner/dots.git
```

## 6. Symlinks

```sh
# Create symlinks from symlinks.yml
./scripts/dots/symlinks.sh
```

After that, the dot binaries from `~/.local/bin` will be available in your `$PATH`.

## 7. Env Sync

Pull API keys and env vars from ProtonPass into `~/.env` and `~/.env.*`.

```sh
pp-env-sync
```

## 8. Helm + Repos

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

## 9. Neovim

Install neovim plugins via [lazy.nvim](https://github.com/folke/lazy.nvim).

```sh
nvim --headless "+Lazy! sync" +qa
```

Enter Neovim to see if plugins are installed.

> [!NOTE]
> On entering Neovim, the Mason plugins configured in `common/.config/nvim/lua/specs/mason.lua` will be installed.

## 10. Claude Code MCP Servers

Configure MCP servers for Claude Code (requires Step 7 env sync for API keys).

```sh
claude mcp add --scope user exa -e "EXA_API_KEY=$EXA_API_KEY" -- npx -y exa-mcp-server
claude mcp add --scope user --transport http Ref https://api.ref.tools/mcp -H "x-ref-api-key: $REF_API_KEY"
claude mcp add --scope user chrome-devtools -- npx chrome-devtools-mcp@latest
```

## 11. Fonts

Install Nerd Fonts from the AUR. Check what's available — common ones:

```sh
paru -S --needed --noconfirm \
  ttf-fira-code-nerd \
  ttf-jetbrains-mono-nerd \
  ttf-iosevka-nerd \
  ttf-maple-mono-nf \
  ttf-space-mono-nerd \
  ttf-recursive-mono-nerd
```

> [!NOTE]
> If your preferred font isn't in the AUR, search `paru -Ss ttf-<fontname>` or install manually.

## 12. Bluetooth

```sh
sudo systemctl enable bluetooth --now
bluetui
```

## 13. Docker

Enable the Docker daemon:

```sh
sudo systemctl enable docker --now
sudo usermod -aG docker "$USER"
```

Log out and back in for the group change to take effect.

---

## Post-Install Checklist

### App Logins

- [ ] **Claude** - Open, sign in
- [ ] **Obsidian** - Open, sign in and setup sync
- [ ] **Zed** - Open, sign in
- [ ] **Atuin** - Run `atuin login`
- [ ] **Signal** - Open, link device via phone
- [ ] **Browser** - and Login into various services

### System Settings

- [ ] **Neovim** - Run `bob install stable && bob use stable`
- [ ] **Docker** - Test with `docker run hello-world`
- [ ] **Keyboard** - Set repeat rate / delay if needed
- [ ] **ProtonPass** - Enable browser extension
- [ ] **Desktop compositor** - Pick Niri or Hyprland at login

### Verify

- [ ] `dots status` — shows clean state
- [ ] `ssh -T git@github.com` — authenticated
- [ ] `gh auth status` — authenticated
- [ ] `pass-cli test` — authenticated
- [ ] Open a tmux session, test `helm` keybinding
