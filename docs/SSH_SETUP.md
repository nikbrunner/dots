# SSH Setup Guide for nbr

Personal reference for setting up 1Password SSH integration on new machines.

> [!IMPORTANT] 
> **SSH config and known_hosts are backed up in 1Password (~/.ssh items)**

## 📋 Quick Setup Checklist

When setting up a new machine:

- [ ] Install 1Password and enable SSH agent ([Official Guide](https://developer.1password.com/docs/ssh/get-started))
- [ ] Restore SSH config from 1Password backup
- [ ] Set correct SSH permissions (`chmod 700 ~/.ssh && chmod 600 ~/.ssh/*`)
- [ ] Test GitHub SSH connection (`ssh -T git@github.com`)
- [ ] Verify Git commit signing works (dotfiles handle this automatically)

## 🚀 New Machine Setup

### 1. Install 1Password SSH Agent

Follow: [Get started with 1Password for SSH | 1Password Developer](https://developer.1password.com/docs/ssh/get-started)

**Key points:**

- Install 1Password on your platform
- Enable SSH agent in settings
- Your SSH keys are already in 1Password vault

### 2. Restore SSH Configuration

1. **Create SSH directory:**

   ```bash
   mkdir -p ~/.ssh && chmod 700 ~/.ssh
   ```

2. **Restore from 1Password:**

   - Find "~/.ssh" items in 1Password
   - Copy config content to `~/.ssh/config`
   - Copy known_hosts content to `~/.ssh/known_hosts`
   - Set permissions: `chmod 600 ~/.ssh/config ~/.ssh/known_hosts`

3. **Test connections:**
   ```bash
   ssh -T git@github.com  # Should show authentication success
   ```

## 🔧 Troubleshooting

### 1Password SSH Agent Issues

```bash
# Check if agent is working
ssh-add -l

# If not working:
# - Restart 1Password
# - Check SSH agent enabled in preferences
# - Verify socket path in SSH config
```

### Git Signing Issues

- Git signing is configured in dotfiles `.gitconfig`
- Should work automatically with 1Password SSH agent
- Test: `git log --show-signature -1`

## 📝 Notes

- **SSH keys:** Already stored in 1Password, no need to generate new ones
- **Git config:** Handled by dotfiles symlinks, includes signing setup
- **GitHub:** SSH key already added to your account
- **Backup:** Always update 1Password when SSH config changes

## 🐧 Linux-Specific Considerations

When setting up on Linux machines:

- [x] **1Password SSH agent socket path** may differ from macOS:

   - Check 1Password settings for the correct socket path
   - Update SSH config `IdentityAgent` line if needed

- [x] **Git signing program path** may be different:

   - macOS: `/Applications/1Password.app/Contents/MacOS/op-ssh-sign`
   - Linux: May be `/usr/bin/op-ssh-sign` or similar
   - Check with: `which op-ssh-sign` after 1Password installation
   - Update `.gitconfig` locally if needed:
     ```bash
     git config --global gpg.ssh.program "$(which op-ssh-sign)"
     ```

- [x] **1Password installation:**
   - Follow Linux-specific installation from 1Password docs
   - Ensure CLI tools are properly installed
