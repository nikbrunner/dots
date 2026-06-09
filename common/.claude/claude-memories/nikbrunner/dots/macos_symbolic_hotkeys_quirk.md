---
name: macos-symbolic-hotkeys-quirk
description: defaults write to com.apple.symbolichotkeys does not reliably apply on current macOS — use the System Settings UI instead
metadata:
  node_type: memory
  type: reference
  originSessionId: 87a9f93d-894d-4ea6-a4ce-ffdf282403e7
---

Disabling macOS keyboard shortcuts (e.g. Mission Control "Move left/right a space", symbolic hotkeys 79/81) via `defaults write com.apple.symbolichotkeys` + `activateSettings -u` updates the plist but WindowServer/System Settings keep the cached value — the shortcut stays active (observed 2026-06-09, macOS Darwin 25.3). The manual toggle in System Settings → Keyboard → Keyboard Shortcuts → Mission Control is what actually applies it. Recommend the UI path directly instead of offering the terminal route.
