# Multiplexer Keybindings Reference

This document serves as the **source of truth** for all multiplexer keybindings. Both WezTerm and tmux configurations should implement these exact mappings to ensure consistent muscle memory across multiplexers.

## Philosophy

- **Portability**: Bindings work across different terminals and platforms
- **Frequency-based access**: Direct modifiers for frequent actions, leader key for infrequent ones
- **Consistency**: Similar actions use similar key patterns
- **Muscle memory**: Leverage common patterns from vim, tmux, and other tools

## Modifier Key Strategy

- `ALT`: Primary multiplexer navigation (workspaces, tabs, panes)
- `CTRL`: Application-level (vim, shell commands)  
- `CMD`: System-level and macOS enhancements (conditional)
- `Leader` (Ctrl+,): Infrequent actions (rename, configuration)

## Implementation Files

- **WezTerm**: `common/.config/wezterm/keymaps-multiplexer.lua`
- **tmux**: `common/.config/tmux/keymaps.multiplexer.conf`

## Switching Multiplexers

**To use tmux as multiplexer:**
1. Comment out lines 48-51 in `~/.config/wezterm/keymaps.lua`
2. Uncomment line 27 in `~/.config/tmux/keymaps.conf`

**To use WezTerm as multiplexer:**
1. Uncomment lines 48-51 in `~/.config/wezterm/keymaps.lua`
2. Comment out line 27 in `~/.config/tmux/keymaps.conf`

## Keybinding Categories

### Application Integration (Vim Navigation)
| Key | Description | WezTerm | tmux |
|-----|-------------|---------|------|
| `Ctrl+h` | Navigate left (Vim-aware) | ✅ | ✅ |
| `Ctrl+j` | Navigate down (Vim-aware) | ✅ | ✅ |
| `Ctrl+k` | Navigate up (Vim-aware) | ✅ | ✅ |
| `Ctrl+l` | Navigate right (Vim-aware) | ✅ | ✅ |

### Session/Workspace Management
| Key | Description | WezTerm | tmux |
|-----|-------------|---------|------|
| `Alt+s` | Session/workspace picker | ✅ | ✅ |
| `Alt+Shift+s` | Sessionizer (project picker) | ✅ | ✅ |
| `Alt+o` | Previous session/workspace | ✅ | ✅ |
| `Alt+j` | Next session/workspace | ✅ | ✅ |
| `Alt+k` | Previous session/workspace | ✅ | ✅ |
| `Alt+r` | Tab/window navigator | ✅ | ✅ |

### Tab/Window Management
| Key | Description | WezTerm | tmux |
|-----|-------------|---------|------|
| `Alt+1-9` | Select tab/window by number | ✅ | ✅ |
| `Alt+h` | Previous tab/window | ✅ | ✅ |
| `Alt+l` | Next tab/window | ✅ | ✅ |
| `Alt+c` | Create new tab/window | ✅ | ✅ |
| `Alt+x` | Close tab/window | ✅ | ✅ |
| `Alt+,` | Move tab/window left | ✅ | ✅ |
| `Alt+.` | Move tab/window right | ✅ | ✅ |

### Pane Management
| Key | Description | WezTerm | tmux |
|-----|-------------|---------|------|
| `Alt+Shift+l` | Split horizontal | ✅ | `Alt+L` |
| `Alt+Shift+j` | Split vertical | ✅ | `Alt+J` |
| `Alt+Shift+z` | Toggle pane zoom | ✅ | `Alt+Z` |
| `Alt+Shift+x` | Close pane | ✅ | `Alt+X` |

### Pane Resizing
| Key | Description | WezTerm | tmux |
|-----|-------------|---------|------|
| `Alt+Shift+←` | Resize left (10 units) | ✅ | ✅ |
| `Alt+Shift+↓` | Resize down (10 units) | ✅ | ✅ |
| `Alt+Shift+↑` | Resize up (10 units) | ✅ | ✅ |
| `Alt+Shift+→` | Resize right (10 units) | ✅ | ✅ |

### Naming
| Key | Description | WezTerm | tmux |
|-----|-------------|---------|------|
| `Leader+n` | Rename tab/window | ✅ | ✅ |
| `Leader+N` | Rename workspace/session | ✅ | ✅ |

### Quick Actions
| Key | Description | WezTerm | tmux |
|-----|-------------|---------|------|
| `Alt+g` | LazyGit popup | ✅ | ✅ |
| `Alt+f` | Yazi file manager popup | ✅ | ✅ |

## Implementation Notes

### WezTerm Specific
- Uses workspace API for session management
- Custom event handlers for Vim-aware navigation
- Supports both Leader and CMD key variants for macOS
- Direct workspace access via Leader+0-9 and Cmd+0-9

### tmux Specific
- Uses sessions for workspace management
- Vim detection via process inspection
- Window movement uses swap-window commands
- Naming functions use LEADER prefix

## Consistency Rules

1. **Alt modifier for primary actions** - Core multiplexer operations use Alt
2. **Shift for destructive/creation actions** - Alt+Shift for splits, close, etc.
3. **Ctrl combinations for resize** - Alt+Shift+Ctrl for resizing
4. **Leader for naming** - Renaming operations use Leader prefix
5. **Vim-aware navigation** - Ctrl+hjkl should always work seamlessly with Neovim

## Verification

After making changes to either implementation:
1. Test all keybindings in both WezTerm and tmux modes
2. Verify Vim navigation works correctly
3. Ensure consistent behavior for create/destroy operations
4. Check that popup utilities (lazygit, yazi) function identically
