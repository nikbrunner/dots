# Zsh Configuration Cleanup Plan

## Overview
Before considering splitting .zshrc by OS, we should first clean out unused or outdated configurations.

## Audit Checklist

### 1. Environment Variables to Review

#### Potentially Unused Office/Home IPs
```bash
export BC_OFFICE_LAN_IP=10.2.0.95
export BC_OFFICE_WLAN_IP=10.2.0.109
export BC_OFFICE_ST=67S3033
export BC_HOME_LAN_IP=null
export BC_HOME_WLAN_IP=192.168.2.109
export BC_HOME_ST=4WSMH53
export BC_DANIEL_IP=10.2.0.128
export BC_BEN_IP=10.2.0.94
export BC_HOME_IP=192.168.2.107
export BC_HOME_ST=CG7L9R2
export BC_JULIA_IP=10.2.0.195
export BC_JULIA_ST=CNRFGQ2
export BC_ANGELA_ST=CNZFGQ2
```
**Questions**: 
- Are these work-related IPs still needed?
- Are these colleagues still relevant?
- Should these be in a separate, private config file?

#### Path Exports to Verify
```bash
export PATH=$HOME/Applications:$PATH  # macOS specific?
export PATH=/usr/bin/python:$PATH      # Needed with python3?
export PATH=/usr/bin/python3:$PATH     # Redundant?
export PATH=$HOME/.deno/bin:$PATH      # Still using Deno?
```

### 2. Aliases to Review

#### Potentially Redundant/Unused
- `alias vim="nvim"` - Needed if you always type nvim?
- `alias lazyvim="NVIM_APPNAME=lazyvim nvim"` - Still using LazyVim?
- `alias zj="zellij"` - Still using Zellij?
- `alias gdl="gallery-dl"` - Still using gallery-dl?
- `alias npmu="npm-upgrade"` - Still using npm-upgrade?

#### Music Download Aliases
```bash
MUSIC_DIR="$HOME/pCloud\ Drive/02_AREAS/Music"
alias ytmp3="yt-dlp -x --audio-format mp3 ..."
alias ytalbum="yt-dlp -x --audio-format mp3 ..."
```
**Questions**:
- Correct music directory?
- Still downloading music this way?
- Old commented MUSIC_DIR can be removed?

### 3. Functions to Review

#### NPM Script Selector
- Complex function with FZF integration
- Still being used? (Has keybind ^N)

#### Yazi Function
- Widget bound to ^E
- Actively used?

### 4. Git Configuration

#### Git Branch Switcher
- Two aliases: `gbr` and `gbra`
- Custom function with FZF
- Could use built-in git tools instead?

### 5. Shell Behavior

#### IP Detection
- `myip` variable set but never used?
- Needed for prompt or scripts?

#### Keybindings Summary
- `^N` - NPM script selector
- `^E` - Yazi file manager
- `^Y` - Accept autosuggestion
- `,,` - FZF file picker with bat preview

### 6. Dead Code

- Commented line 78: Old MUSIC_DIR path
- `alias :q=exit` - Vim joke or actually used?

## Cleanup Steps

### Phase 1: Information Gathering
1. Check which aliases are actually used:
   ```bash
   # Check shell history for alias usage
   history | grep -E "lazyvim|zj|gdl|npmu"
   ```

2. Verify PATH requirements:
   ```bash
   # Check if directories exist and contain executables
   ls -la $HOME/Applications
   ls -la $HOME/.deno/bin
   ```

3. Grep codebase for environment variable usage:
   ```bash
   # Search for BC_ variables in scripts
   grep -r "BC_OFFICE\|BC_HOME\|BC_DANIEL\|BC_BEN\|BC_JULIA\|BC_ANGELA" ~/bin
   ```

### Phase 2: Cleanup Actions
1. Remove confirmed unused environment variables
2. Remove redundant PATH exports
3. Remove unused aliases
4. Update/fix music directory configuration
5. Consider extracting work-specific configs to separate file
6. Remove commented dead code

### Phase 3: Reorganization
After cleanup, evaluate if splitting is still needed. The file might be much smaller and cleaner.

## Questions to Answer Before Cleanup

1. **Work Environment**: Are the BC_* variables for a current or past employer?
2. **Tools in Use**: Which tools do you actively use?
   - Zellij vs Tmux?
   - LazyVim config?
   - Gallery-dl?
   - Deno?
3. **Music Workflow**: Is the YouTube download workflow current?
4. **Git Workflow**: Do you use the custom branch switcher or prefer lazygit?
5. **Keybindings**: Which custom keybindings do you actually use?

## Expected Outcome

A significantly smaller, cleaner .zshrc that only contains:
- Actively used configurations
- Essential environment setup
- Frequently used aliases and functions
- Clear OS-specific sections (if needed)

This cleanup might eliminate the need for splitting entirely, or make the split much cleaner if still desired.