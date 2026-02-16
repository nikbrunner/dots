# Black Atom Obsidian Adapter — Memory

## Architecture
- Pure CSS template approach, no SCSS, no npm dependencies
- Single shared template: `templates/collection.template.css` (all collections reference it)
- `build.sh` runs `black-atom-core generate` then concatenates style-settings header + generated files into `theme.css`
- Generated per-theme CSS files land flat in `templates/` (gitignored)

## Core CLI
- Command is `black-atom-core generate` (NOT `adapt` — the plan docs were wrong)
- Must be compiled and installed from core repo: `deno task cli:compile && sudo deno task cli:install`
- Output path derivation: `templatePath.replace(".template.", ".").replace(/collection/, themeKey)`
- Processes one file per theme, not one per collection

## Style Settings
- Separate dark/light dropdowns (not one combined) — prevents confusion when appearance mode doesn't match variant
- `class-select` type with `allowEmpty: false`

## Obsidian Vault
- Nik's vault: `~/repos/nikbrunner/notes`
- Theme symlinks use relative paths in `.obsidian/themes/Black Atom/`
- Nik prefers relative symlinks over absolute

## Key Patterns
- When all collections share the same template, use a single file referenced by all (not symlinks or copies per collection)
- See `details.md` for token mapping reference

## Related Issues
- DEV-177: Adapter:Obsidian - Add (DONE)
- DEV-243: Interface/layout customizations (backlog)
- DEV-244: Community theme store submission (backlog)
