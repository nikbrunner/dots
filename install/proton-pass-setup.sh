#!/usr/bin/env bash
# One-time Proton Pass SSH agent setup.
#
# Run this on a fresh machine after installing pass-cli.
# On Linux: creates a PAT so the SSH agent auto-starts across reboots.
# On macOS: session persists via Keychain — no PAT needed.

set -euo pipefail

PAT_FILE="$HOME/.config/pass-cli/pat"
PAT_NAME="proton-pass-pat"
OS=$(uname -s)

# ── Step 1: Login ────────────────────────────────────────────────────────────

echo "==> Step 1: Proton Pass login"
if pass-cli test >/dev/null 2>&1; then
    echo "    Already logged in."
else
    pass-cli login
fi

# ── Step 2: macOS — Keychain persists session, no PAT needed ─────────────────

if [[ "$OS" == "Darwin" ]]; then
    echo "==> macOS detected — session persists via Keychain. No PAT needed."
    pass-cli ssh-agent daemon stop >/dev/null 2>&1 || true
    pass-cli ssh-agent daemon start
    export SSH_AUTH_SOCK="$HOME/.ssh/proton-pass-agent.sock"
    sleep 2
    echo "==> Loaded SSH keys:"
    ssh-add -l
    echo ""
    echo "==> Done. SSH agent is running."
    exit 0
fi

# ── Step 3: Linux — create PAT for persistent login across reboots ───────────

echo "==> Step 2: Personal Access Token setup (Linux)"

if [[ -f "$PAT_FILE" ]]; then
    echo "    PAT file already exists at $PAT_FILE — skipping creation."
    echo "    Delete the file and re-run to recreate."
else
    echo "    Available vaults:"
    pass-cli vault list
    echo ""
    read -rp "    Enter the vault name containing your SSH keys: " VAULT_NAME

    echo "    Creating PAT '$PAT_NAME'..."
    # Delete existing PAT with this name to avoid duplicates on re-runs
    pass-cli personal-access-token delete --personal-access-token-name "$PAT_NAME" >/dev/null 2>&1 || true

    PAT=$(pass-cli personal-access-token create --name "$PAT_NAME" --expiration 1y)

    mkdir -p "$(dirname "$PAT_FILE")"
    echo "$PAT" > "$PAT_FILE"
    chmod 600 "$PAT_FILE"
    echo "    Saved to $PAT_FILE"

    echo "    Granting access to vault '$VAULT_NAME'..."
    pass-cli personal-access-token access grant \
        --personal-access-token-name "$PAT_NAME" \
        --vault-name "$VAULT_NAME"
    echo "    Done."
fi

# ── Step 4: Start daemon and verify ──────────────────────────────────────────

echo "==> Step 3: Starting SSH agent daemon"
pass-cli ssh-agent daemon stop >/dev/null 2>&1 || true
pass-cli ssh-agent daemon start
export SSH_AUTH_SOCK="$HOME/.ssh/proton-pass-agent.sock"
sleep 2

echo "==> Loaded SSH keys:"
ssh-add -l

echo ""
echo "==> Setup complete. SSH agent will auto-start on next reboot via proton-pass-agent-start."
