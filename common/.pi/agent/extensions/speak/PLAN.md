# Plan: `speak.ts` — Voice Readback Extension for Pi

## Context

You want a Pi extension that, when the agent finishes responding, synthesises the final reply as
speech via Unreal Speech and plays it back — both as a macOS notification (clickable to focus the
tmux window and trigger playback) and via an in-session keyboard shortcut.

**Settings from your screenshot:**

- Voice: `Sierra` (American Female)
- Language: US English
- Format: Standard (mp3)
- Speed: Normal (`0`)
- Pitch: `1.0`
- Bitrate: `192k`

**Stack:** macOS · Ghostty · tmux · Pi extension API (TypeScript, loaded from
`@common/.pi/agent/extensions/`)

---

## Approach

### 0. Platform abstraction layer

To make future Linux/Windows support straightforward, all OS-specific calls are isolated behind
a small `platform` module with a runtime switch on `process.platform`:

```ts
type Platform = {
  notify(title: string, body: string): void; // system notification
  playAudio(filePath: string): Promise<void>; // play an MP3 file
  focusTerminal(tmuxTarget?: string): void; // bring terminal to front
  isFocused(): boolean; // is our window focused?
};
```

| macOS                                                | Linux (future)       | Windows (future)         |
| ---------------------------------------------------- | -------------------- | ------------------------ |
| `terminal-notifier -execute` (+`osascript` fallback) | `notify-send`        | `powershell` toast       |
| `afplay`                                             | `mpg123` / `paplay`  | Windows Media Player CLI |
| `osascript` + `tmux switch-client`                   | `wmctrl` / `xdotool` | —                        |
| `osascript` window check                             | `xdotool`            | —                        |

### 1. TTS — Unreal Speech `/stream` endpoint

`POST https://api.v8.unrealspeech.com/stream`  
Body: `{ Text, VoiceId: "Sierra", Bitrate: "192k", Speed: 0, Pitch: 1.0 }`  
Response: raw MP3 bytes (binary stream, ≤ 1 000 chars per call)

**Long-response handling:** responses > 1 000 chars will be split into sentence-boundary chunks
and each chunk will be streamed + played sequentially.

**API key:** read from `~/.env` at startup (loaded via `dotenv`-style parsing of `~/.env`), with fallback to `process.env.UNREAL_SPEECH_API_KEY`.

### 2. Audio playback

`afplay` is available at `/usr/bin/afplay` (macOS built-in). We write the MP3 bytes to a temp file
in `/tmp/pi-speak-*.mp3` and play with `afplay`. The temp file is deleted after playback.

### 3. macOS notification — on agent done

`terminal-notifier` (installable via `brew install terminal-notifier`) fires an interactive notification:

```sh
terminal-notifier \
  -title "Pi ✓" \
  -subtitle "<one-line summary>" \
  -message "Click to focus session" \
  -execute "osascript -e 'tell application \"Ghostty\" to activate'; tmux switch-client -t 'SESSION:WINDOW'" \
  -group "pi-speak"
```

- **`-execute`**: runs a shell command when the notification is clicked.
  1. `osascript` brings Ghostty to the foreground.
  2. `tmux switch-client -t SESSION:WINDOW` switches to the exact session and window where Pi is running.
     The `SESSION:WINDOW` target is resolved at `agent_end` time via:
  ```ts
  const target = execSync(
    `tmux display-message -p -t ${myPaneId} "#{session_name}:#{window_index}"`,
  );
  ```
- **`-group pi-speak`**: replaces the previous notification so only one is visible at a time.
- Notifications auto-dismiss as banners (macOS default); user can pin to Alerts in System Prefs for sticky behaviour.

**Fallback:** if `terminal-notifier` is not on `$PATH`, fall back to plain `osascript` notification
(non-interactive) and log a one-time hint to `ctx.ui.notify` suggesting `brew install terminal-notifier`.

**deps note:** `terminal-notifier` is not installed automatically. A startup check logs the hint.

### 4. Hook selection

| Event       | Use                                                                                                                                        |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `agent_end` | Fires when the full agent turn is done (all tool calls finished, final reply streamed). Extract the last assistant message's text content. |

`TurnEndEvent.message` carries the `AssistantMessage` (role `"assistant"`, content array of
`TextContent | ThinkingContent | ToolCall`). We filter for `type === "text"` blocks, join them,
strip markdown formatting for cleaner speech, and synthesise.

### 5. In-session shortcut + status widget

- **`alt+r`** — registered via `pi.registerShortcut("alt+r", { ... })` — replays last synthesised
  response. If TTS is already running it is killed first.
  - **Why `alt+r`?** It does not conflict with any tmux root-table binding (`M-r` is unbound) or
    any existing Pi built-in keybinding. It is memorable ("r" for "read/replay").
- **Status widget** — `ctx.ui.setWidget("speak", ...)` displays a one-liner below the editor:
  `🔊 Ready  alt+r replay` (while idle) or `🔊 Speaking…  alt+r stop` (while playing).

### 6. Focus detection (auto-play gating)

Auto-play fires **only** when the Pi window is not currently focused:

1. Check if Ghostty is the frontmost app via `osascript`:
   ```applescript
   tell application "System Events" to get name of first application process whose frontmost is true
   ```
2. If Ghostty is not frontmost → always auto-play.
3. If Ghostty is frontmost → check if the active tmux pane is the one running this Pi session
   by comparing `$TMUX_PANE` (captured at extension load) with the current active pane
   (`tmux display-message -p '#{pane_id}'`).
4. If same pane is active → **skip** auto-play (user is watching the response).
5. Notification is still fired regardless.

---

## Files to Modify / Create

| Path                                   | Action                                                                |
| -------------------------------------- | --------------------------------------------------------------------- |
| `common/.pi/agent/extensions/speak.ts` | **Create** — new extension                                            |
| `common/.local/bin/pi-speak-focus`     | **Create** — shell helper for Ghostty/tmux focus (future convenience) |

---

## Reuse

| Existing code                       | Where                                     | Used for                                                          |
| ----------------------------------- | ----------------------------------------- | ----------------------------------------------------------------- |
| `enforce.ts` pattern                | `@common/.pi/agent/extensions/enforce.ts` | Extension structure (`export default function(pi: ExtensionAPI)`) |
| `ExtensionAPI.on("agent_end", ...)` | `types.d.ts`                              | Trigger on turn completion                                        |
| `pi.registerShortcut(...)`          | `types.d.ts`                              | `ctrl+r` keybinding                                               |
| `ctx.ui.setWidget(...)`             | `types.d.ts`                              | Status bar widget                                                 |
| `~/.env` file                       | user's home                               | API key source                                                    |
| `ctx.ui.notify(...)`                | `types.d.ts`                              | In-session notify on errors                                       |
| `osascript`                         | macOS built-in                            | System notification                                               |
| `afplay`                            | `/usr/bin/afplay`                         | MP3 playback                                                      |

---

## Steps

- [ ] **1. Create `speak.ts`**
  - **Platform abstraction** (`createPlatform()`): returns macOS-specific implementations;
    structured so Linux/Windows implementations can be dropped in with the same interface.
  - **`~/.env` loading**: at session start, read `~/.env` and extract `UNREAL_SPEECH_API_KEY`
    (simple line-by-line parser, no extra dependency).
  - Module-level state: `lastResponseText: string`, `currentPlayback: ChildProcess | null`,
    `disabled: boolean`, `myPaneId: string` (captured at `session_start`).
  - `session_start` handler:
    - Capture `process.env.TMUX_PANE` as `myPaneId`
    - Load API key from `~/.env` → if missing, set `disabled = true` + warn
    - Set initial idle widget
  - `agent_end` handler:
    - Extract final assistant text (filter `content` for `type === "text"`, join, strip markdown)
    - Store in `lastResponseText`
    - If `disabled` or text is empty or `stopReason` is `"aborted"` / `"error"` — skip
    - Generate a one-line summary for the notification (first ~80 chars)
    - Fire `platform.notify()` (non-blocking)
    - **Focus check**: call `platform.isFocused(myPaneId)` — if focused, skip auto-play
    - Else: start TTS + playback (non-blocking, background), update widget to `🔊 Speaking…`
  - `speakText(text: string)` helper:
    - Chunk text at sentence boundaries into ≤ 900 char pieces
    - For each chunk: `fetch` `/stream` → buffer response body → write to tmp file → `platform.playAudio()`
    - Sequential (await each chunk before fetching next)
    - On completion: update widget back to `🔊 Ready`
  - `registerShortcut("alt+r", ...)`:
    - If playing: kill current playback process, update widget to `🔊 Ready`
    - Else: call `speakText(lastResponseText)`
  - `setWidget` call on extension load (show initial idle state)

- [ ] **2. Create `common/.local/bin/pi-speak-focus`**
  - Bash script
  - Activates Ghostty via `osascript -e 'tell application "Ghostty" to activate'`
  - Optionally switches tmux to the pane running Pi (reads `$TMUX_PANE` from env or accepts arg)

- [ ] **3. Handle missing API key gracefully**
  - On `session_start`: if `UNREAL_SPEECH_API_KEY` is unset, show `ctx.ui.notify` warning and
    disable TTS (set a `disabled` flag)

---

## Unreal Speech API contract

```
POST https://api.v8.unrealspeech.com/stream
Authorization: Bearer <UNREAL_SPEECH_API_KEY>
Content-Type: application/json

{
  "Text": "<text>",
  "VoiceId": "Sierra",
  "Bitrate": "192k",
  "Speed": 0,
  "Pitch": 1.0
}
```

Response: `Content-Type: audio/mpeg` — binary MP3 bytes.

---

## Post-approval

After implementation, move this plan to `plans/` with a descriptive name:

```
plans/pi-extension-speak-tts.md
```

---

## Verification

1. Start a Pi session — widget `🔊 Ready  ctrl+r replay` should appear below editor
2. Send a message, wait for response — notification fires, audio plays automatically
3. Press `ctrl+r` mid-playback — playback stops
4. Press `ctrl+r` when idle — replays last response
5. Unset `UNREAL_SPEECH_API_KEY` — warning notification, no crash
6. Send a very long response (> 1 000 chars) — chunked playback, no audio corruption

---

## Resolved decisions

1. **Shortcut:** `alt+r` — free in tmux, not used by Pi built-ins, memorable.
2. **Notification:** interactive via `terminal-notifier` — clicking runs `-execute` which activates Ghostty AND `tmux switch-client` to the exact session:window. Falls back to plain `osascript` if not installed.
3. **Auto-play:** only when Ghostty is not frontmost, or when frontmost but a different tmux pane is active.
4. **API key:** read from `~/.env` at session start.
5. **Platform compatibility:** all OS-specific calls behind a `Platform` interface for future Linux/Windows support.
