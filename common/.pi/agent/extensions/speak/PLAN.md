# Plan: Formatting and Linting Hooks

## Context
The project lacks consistent code formatting and linting. Adding Prettier + ESLint with pre-commit hooks ensures all code stays clean and consistent.

## Approach
- **Prettier** for opinionated code formatting (config provided by user)
- **ESLint** for TypeScript linting (strict mode)
- **Project-local Pi extension** for linting validation on every turn
- Extension runs Prettier + ESLint after each agent turn, shows errors as UI notifications
- Scope: `src/` directory only

## Files to create/modify
| File | Action |
|------|--------|
| `package.json` | Add scripts and dependencies |
| `prettier.config.ts` | Prettier config (as provided) |
| `eslint.config.ts` | ESLint config (TypeScript strict) |
| `.pi/extensions/lint/index.ts` | Project-local Pi extension that runs lint/format on every turn |
| `.pi/extensions/lint/package.json` | Extension package manifest |

## Reuse
- Existing `tsconfig.json` (already strict mode)
- User's Prettier config with sort-imports + tailwindcss plugins
- Standard Pi extension structure

## Steps
- [x] Install dependencies (prettier, eslint, @typescript-eslint, import sort plugin, tailwind plugin)
- [x] Create `prettier.config.ts` with user's config
- [x] Create `eslint.config.ts` with TypeScript strict mode
- [x] Add npm scripts to `package.json`:
  - `lint:check` — run eslint
  - `format:check` — run prettier --check
  - `format` — run prettier --write
  - `lint:fix` — auto-fix lint issues
- [x] Create `.pi/extensions/lint/` directory with extension files
- [x] Implement `agent_end` listener that tracks modified files via `tool_result` events
- [x] Run `npx prettier --check` and `npx eslint` on modified TypeScript files
- [x] Show lint/format errors via `ctx.ui.notify()`
- [x] Run and verify on existing `src/` files

## Verification
- Run `npm run lint:fix` to format all files
- Verify `npm run lint` passes without errors
## Extension Implementation Details

```typescript
// .pi/extensions/lint/index.ts
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  const modifiedFiles = new Set<string>();

  // Track write/edit tool calls
  pi.on("tool_result", async (event) => {
    if (event.toolName === "write" || event.toolName === "edit") {
      const path = event.input.path as string;
      if (path && path.endsWith(".ts") && !path.includes("node_modules")) {
        modifiedFiles.add(path);
      }
    }
  });

  // Run lint and format checks on agent_end
  pi.on("agent_end", async (_event, ctx) => {
    if (modifiedFiles.size === 0) return;

    const files = Array.from(modifiedFiles);
    modifiedFiles.clear();

    // Run ESLint check
    const lintResult = await pi.exec("npm", ["run", "lint:check", "--", ...files]);
    if (lintResult.code !== 0) {
      ctx.ui.notify(`Lint issues:\n${lintResult.stderr}`, "warning");
    }

    // Run Prettier check
    const formatResult = await pi.exec("npm", ["run", "format:check", "--", ...files]);
    if (formatResult.code !== 0) {
      ctx.ui.notify(`Format issues:\n${formatResult.stderr}`, "warning");
    }
  });
}
```

**package.json scripts:**
```json
{
  "scripts": {
    "lint:check": "eslint src",
    "format:check": "prettier --check src",
    "format": "prettier --write src",
    "lint:fix": "eslint --fix src && prettier --write src"
  }
}
```
