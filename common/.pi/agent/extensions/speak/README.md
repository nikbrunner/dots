# pi-speak

Voice readback extension for [Pi](https://github.com/mariozechner/pi-coding-agent).

When the agent finishes a turn, pi-speak:

1. **Fires a macOS notification** with the tmux session name + summary
2. **Caches audio** for instant replay (no re-fetch on repeat)
3. **`alt+r` shortcut** — replay last response / stop current playback
4. **Status widget** — shows playback state below the editor

## Setup

1. Add your API key to `~/.env`:

   ```
   UNREAL_SPEECH_API_KEY=your-key-here
   ```

2. Reload Pi — the extension is auto-discovered from `extensions/speak/`.

## Configuration

On first run, a default config is created at `~/.config/pi-speak/config.json`:

```json
{
  "voiceId": "Sierra",
  "bitrate": "192k",
  "speed": 0,
  "pitch": 1.0,
  "maxChunkChars": 900,
  "shortcut": "alt+r",
  "debug": true
}
```

| Key             | Type    | Default    | Description                                 |
| --------------- | ------- | ---------- | ------------------------------------------- |
| `voiceId`       | string  | `"Sierra"` | Unreal Speech voice ID                      |
| `bitrate`       | string  | `"192k"`   | Audio bitrate                               |
| `speed`         | number  | `0`        | Speech speed (-1.0 to 1.0)                  |
| `pitch`         | number  | `1.0`      | Speech pitch (0.5 to 1.5)                   |
| `maxChunkChars` | number  | `900`      | Max chars per TTS request (API limit: 1000) |
| `shortcut`      | string  | `"alt+r"`  | Keyboard shortcut for replay/stop           |
| `debug`         | boolean | `true`     | Write to `~/.pi-speak-debug.log`            |

Environment variables override file config: `PI_SPEAK_VOICE`, `PI_SPEAK_BITRATE`, `PI_SPEAK_SPEED`, `PI_SPEAK_PITCH`, `PI_SPEAK_SHORTCUT`, `PI_SPEAK_DEBUG`.

## Usage

- **Notification**: When the agent finishes, a notification appears with the session name and summary. Navigate to the session yourself, then press `alt+r` to hear the response.
- **`alt+r`**: Press to replay the last response. Press again during playback to stop.

## Architecture

```
src/
├── index.ts      # Entry point — Pi lifecycle hooks
├── config.ts     # Configuration — ~/.config/pi-speak/config.json
├── platform.ts   # Platform abstraction (macOS notifications + audio)
├── tts.ts        # Unreal Speech client + TTSPlayer with caching
├── helpers.ts    # Markdown stripping, text chunking, env loading
└── debug.ts      # Timestamped logger → ~/.pi-speak-debug.log
```

## Debugging

Set `PI_SPEAK_DEBUG=0` to disable the debug log, or set `"debug": false` in config.
Log file: `~/.pi-speak-debug.log`

## Platform compatibility

Currently macOS only. The `Platform` interface in `src/platform.ts` is designed for future Linux (`notify-send`, `mpg123`) and Windows support.
