# Wallpaper Configuration

Wallpaper management for Wayland using [swww](https://github.com/LGFae/swww).

## Usage

```bash
pick-wallpaper          # Interactive single wallpaper picker
pick-wallpaper folder   # Pick folder for rotation (starts automatically)
pick-wallpaper next     # Apply next random wallpaper
pick-wallpaper stop     # Stop rotation
pick-wallpaper status   # Show current configuration
pick-wallpaper help     # Show help
```

## Configuration

Edit `config.yml`:

| Setting              | Description                              | Default |
|----------------------|------------------------------------------|---------|
| `path`               | Folder for rotation                      | -       |
| `interval`           | Rotation interval in seconds             | 1800    |
| `transition`         | swww transition type                     | fade    |
| `transition_duration`| Transition duration in seconds           | 2       |

### Transition Types

`simple`, `fade`, `left`, `right`, `top`, `bottom`, `wipe`, `wave`, `grow`, `center`, `any`, `outer`, `random`

## Dependencies

- `swww` - Wayland wallpaper daemon
- `chafa` - Terminal image preview (optional)
- `fzf` - Fuzzy finder
- `yq` - YAML parser

## Files

- `~/.config/wallpaper/config.yml` - Configuration
- `~/.cache/wallpaper/current` - Current wallpaper path
- `~/.config/systemd/user/wallpaper-rotate.timer` - Rotation timer
