---
name: typescript-pinned-to-5-9
description: "TypeScript is held at 5.9.3 because typescript-eslint 8.x peer-caps at <6.1.0, not because 7.x was untested"
metadata: 
  node_type: memory
  type: project
  originSessionId: 8c195b11-61ff-4907-aa10-f2be97cdc5a1
  modified: 2026-08-03T10:32:38.532Z
---

TypeScript in this repo is pinned to 5.9.3 even though 7.0.2 is the current release. `typescript-eslint@8.65.0` declares
`peer typescript ">=4.8.4 <6.1.0"`, so installing TS 7 breaks `npm install` with ERESOLVE and takes the type-aware ESLint
rules (`strictTypeChecked`, `stylisticTypeChecked`) with it.

**Why:** the ImFusion baseline requires type-aware linting at `--max-warnings=0`, so the linter's peer range wins over
having the newest compiler.

**How to apply:** revisit the pin when typescript-eslint ships a release supporting TS 7 — bump both together, never TS
alone. Related: [[imfusion-frontend-baseline]].
