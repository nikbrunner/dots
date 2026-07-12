---
name: reference-repo-paths
description: Actual paths to ImFusion repos on disk — used by timesheet skill git log commands
metadata:
  node_type: memory
  type: reference
  originSessionId: 0a996cfc-ce46-4553-9039-ed1138d1b54d
---

ImFusion repos live under per-project subfolders of `~/repos/imfusion/`, never directly in `~/repos/imfusion/`. Known subfolders so far: `websdk/` (WebSDK + web-ui workstream) and `cp/` (Cloud Platform — the customer/web portal stack). More subfolders may exist; check with `find ~/repos/imfusion -maxdepth 3 -type d -name .git` rather than assuming only these two.

Repos present (as of 2026-07-01):

- `~/repos/imfusion/websdk/web-ui`
- `~/repos/imfusion/websdk/web-viewer`
- `~/repos/imfusion/websdk/web-viewer-next`
- `~/repos/imfusion/websdk/websdk`
- `~/repos/imfusion/brunner/agents`
- `~/repos/imfusion/cp/imfusion-portal-fe` — portal frontend, see [[project-web-ui-portal-shift]]
- `~/repos/imfusion/cp/imfusion-portal-bff`
- `~/repos/imfusion/cp/local-setup-portal` — orchestrates the local dev stack for the whole `cp` portal system
- `~/repos/imfusion/cp/license-server`
- `~/repos/imfusion/cp/keycloak`
- `~/repos/imfusion/cp/registration-service`

**Why:** The timesheet-spec.md originally pointed to `~/repos/imfusion/$REPO` which silently failed (no such directory → no git output → looked like no commits). Fixed 2026-06-30. Extended 2026-07-01 after assuming `websdk/` was the only subfolder and missing the `cp/` repos entirely during a close-out.
