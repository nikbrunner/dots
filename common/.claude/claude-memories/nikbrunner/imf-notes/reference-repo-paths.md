---
name: reference-repo-paths
description: Actual paths to ImFusion repos on disk — used by timesheet skill git log commands
metadata: 
  node_type: memory
  type: reference
  originSessionId: 0a996cfc-ce46-4553-9039-ed1138d1b54d
---

ImFusion repos live under `~/repos/imfusion/websdk/`, not `~/repos/imfusion/` directly.

Repos present (as of 2026-06-30):
- `~/repos/imfusion/websdk/web-ui`
- `~/repos/imfusion/websdk/web-viewer`
- `~/repos/imfusion/websdk/web-viewer-next`
- `~/repos/imfusion/websdk/websdk`
- `~/repos/imfusion/brunner/agents`

**Why:** The timesheet-spec.md originally pointed to `~/repos/imfusion/$REPO` which silently failed (no such directory → no git output → looked like no commits). Fixed 2026-06-30.
