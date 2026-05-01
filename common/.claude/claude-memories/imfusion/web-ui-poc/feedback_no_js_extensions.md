---
name: No .js extensions in TypeScript imports
description: This project does not use .js extensions in import paths — do not add them
type: feedback
originSessionId: 81f92afa-e4b3-4510-972b-845f94db5759
---
Never use `.js` extensions in TypeScript import statements in this project (e.g. `import { X } from "../types/theme"` not `import { X } from "../types/theme.js"`).

**Why:** The project uses `moduleResolution: "bundler"` with `allowImportingTsExtensions: true` in tsconfig. Extensions are not needed and `.js` references don't even exist on disk.

**How to apply:** Every time you write an import path, omit the extension entirely. This applies to both `src/` code and `scripts/`. The only exception is Node built-ins which use the `node:` protocol (e.g. `import { writeFileSync } from "node:fs"`).
