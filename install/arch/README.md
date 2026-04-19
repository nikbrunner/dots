# Arch Linux Setup

Numbered steps, one command each. Each step is idempotent.

## 0. Bootstrap

Clone and run bootstrap:

```bash
mkdir -p ~/repos/nikbrunner
git clone https://github.com/nikbrunner/dots.git ~/repos/nikbrunner/dots
cd ~/repos/nikbrunner/dots
git checkout feat/install-overhaul   # until merged

./install/arch/bootstrap.sh
```

Handles: `pacman -Syu`, `base-devel`, `git`, and `paru` (AUR helper). Nothing more.

## 1. ProtonPass + SSH

```bash
./install/shared/01-protonpass.sh
```

Installs `pass-cli` + `proton-pass`, prompts you to sign in to the desktop app, runs `pass-cli login`, starts the SSH agent. After this, swap the remote to SSH:

```bash
git remote set-url origin git@github.com:nikbrunner/dots.git
```

## 2. Dependencies

```bash
./install/arch/steps/02-deps.sh
```

Installs everything in `install/arch/pkglist.txt` via paru, plus nvm, bun, qmk, claude-code, readwise-cli.

## 3. Symlinks + dots CLI + systemd services

```bash
./install/arch/steps/03-link.sh
```

Creates symlinks (includes `pass-ssh-agent` + `pass-env-sync` systemd user units), enables those services, puts `dots` on `~/.local/bin`.

## 4. Env sync from ProtonPass

```bash
./install/arch/steps/04-env-sync.sh
```

## 5. GitHub CLI auth

```bash
./install/arch/steps/05-gh-auth.sh
```

## 6. Helm + personal repos

```bash
./install/arch/steps/06-helm.sh
```

## 7. Claude Code MCP servers

```bash
./install/arch/steps/07-mcp.sh
```

## 8. Luarocks → Lua 5.1 (for Mason)

```bash
./install/arch/steps/08-luarocks.sh
```

## 9. Fonts

```bash
./install/arch/steps/09-fonts.sh
```

## 10. Bluetooth

```bash
./install/arch/steps/10-bluetooth.sh
```

## 11. Post-install checklist

```bash
./install/arch/steps/11-post-install.sh
```

Writes `~/post-install.md`.

---

## Notes

- AUR packages (`proton-pass`, `claude-desktop-native`, `helium-browser-bin`, etc.) are built from source on first install.
- Niri vs. Hyprland: both configs ship via `symlinks.yml`. Pick your preferred session manager at login.
- If a package fails to install, paru will print the error — fix the PKGBUILD or remove the line from `pkglist.txt`, then rerun step 2.
