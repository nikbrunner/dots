# Machine Setup

Complete bootstrap guide for setting up a new machine with dots.

## Stage 1: Bootstrap (Manual)

These steps must be done manually before the automated install can run. On a fresh machine, read these instructions on your phone via the GitHub app.

### 1. Xcode CLI Tools (macOS)

```bash
xcode-select --install
```

### 2. Homebrew (macOS)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

After install, follow the instructions to add brew to your PATH.

### 3. ProtonPass

Install ProtonPass and the CLI:

```bash
brew tap protonpass/tap
brew install pass-cli
brew install --cask proton-pass
```

Open the Proton Pass app and sign in to your account.

### 4. SSH Agent

Authenticate the CLI and start the SSH agent:

```bash
pass-cli login
pass-cli ssh-agent daemon start
```

Verify SSH access:

```bash
ssh -T git@github.com
```

You should see: `Hi <username>! You've successfully authenticated`.

**References:**

- [ProtonPass CLI docs](https://protonpass.github.io/pass-cli/)
- [SSH Agent commands](https://protonpass.github.io/pass-cli/commands/ssh-agent)

### 5. Clone dots

```bash
mkdir -p ~/repos/nikbrunner
git clone git@github.com:nikbrunner/dots.git ~/repos/nikbrunner/dots
```

## Stage 2: Automated Install

```bash
cd ~/repos/nikbrunner/dots
./install/install.sh
```

### Flags

| Flag        | Description                                    |
| ----------- | ---------------------------------------------- |
| `--dry-run` | Preview all changes without modifying anything |
| `--no-deps` | Skip dependency installation (symlinks only)   |
| `--debug`   | Enable extra diagnostics                       |

### What it does

| Phase | Description                                                  |
| ----- | ------------------------------------------------------------ |
| 1     | Detect OS                                                    |
| 2     | Install dependencies (Brewfile + nvm, bun, claude-code, qmk) |
| 3     | System configuration (zsh default shell, ProtonPass check)   |
| 4     | Create symlinks from `symlinks.yml`                          |
| 5     | Set up `dots` CLI command                                    |
| 6     | Make scripts executable                                      |
| 7     | Sync environment variables from ProtonPass (`pp-env-sync`)   |
| 8     | Configure Claude Code MCP servers                            |
| 9     | Install rmpc music client (via cargo)                        |
| 10    | Bluetooth setup (Arch only)                                  |
| 11    | GitHub authentication (`gh auth login`)                      |
| 12    | Build and install helm, offer `helm setup` for repo cloning  |
| 13    | Install fonts (if fonts repo exists)                         |
| 14    | Seed zoxide with base paths                                  |
| 15    | Validate installation                                        |

### Preview

```bash
./install/install.sh --dry-run
```

## Post-Install

After the install completes:

1. Reload your shell: `source ~/.zshrc`
2. Verify: `dots status`
3. Test SSH: `ssh -T git@github.com`

If you skipped `helm setup` during install, run it later to clone your repositories:

```bash
helm setup
```
