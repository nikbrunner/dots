# File Templates

Templates use `{name}`, `{description}` placeholders. Replace during scaffolding.

## deno.json (Base)

```json
{
  "tasks": {
    "test": "deno test --allow-read --allow-env",
    "check": "deno check .",
    "lint": "deno lint",
    "fmt": "deno fmt",
    "fmt:check": "deno fmt --check",
    "checks": "deno task fmt:check && deno task lint && deno task check && deno task test"
  },
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true
  },
  "fmt": {
    "useTabs": false,
    "lineWidth": 100,
    "indentWidth": 4,
    "semiColons": true,
    "singleQuote": false
  }
}
```

### CLI Additions

Add to tasks:

```json
"install": "deno install --global -f --allow-run --allow-read --allow-env --allow-net --allow-write --name {name} --config deno.json src/main.ts",
"compile": "deno compile --allow-run --allow-read --allow-env --allow-net --allow-write --output {name} src/main.ts"
```

### Library Additions

Add to root:

```json
"name": "@nikbrunner/{name}",
"version": "0.1.0",
"exports": "./src/mod.ts"
```

Add to tasks:

```json
"publish": "deno publish"
```

## .gitignore (Deno)

```
# Dependencies
node_modules/

# Build output
dist/

# Environment
.env
.env.local

# Editor
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db

# Deno
.deno/
```

## .gitignore (Node)

```
node_modules/
dist/
build/
.env
.env.local
.vscode/
.idea/
.DS_Store
Thumbs.db
*.tsbuildinfo
coverage/
```

## README.md

```markdown
# {name}

{description}

## Install

### Prerequisites

- [Deno 2](https://deno.land/)

### Global Install

\`\`\`bash
deno task install
\`\`\`

## Usage

\`\`\`bash
{name} --help
\`\`\`

## Development

\`\`\`bash
deno task test     # Run tests
deno task check    # Type-check
deno task lint     # Lint
deno task fmt      # Format
deno task checks   # All checks
\`\`\`
```

## scripts/setup-git-hooks.sh

```bash
#!/bin/bash
set -e

HOOKS_DIR="$(git rev-parse --show-toplevel)/.git/hooks"
HOOK_FILE="$HOOKS_DIR/pre-commit"

cat > "$HOOK_FILE" << 'HOOK'
#!/bin/bash
set -e
deno task fmt:check
deno task lint
deno task check
deno task test
HOOK

chmod +x "$HOOK_FILE"
echo "Pre-commit hook installed."
```

## .claude/hooks/postwrite.sh

```bash
#!/bin/bash
INPUT=$(cat /dev/stdin)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
[[ -z "$FILE" ]] && exit 0
[[ "$FILE" != *.ts ]] && exit 0
deno fmt "$FILE" 2>/dev/null
deno lint "$FILE" 2>/dev/null
exit 0
```

## .claude/hooks/auto-install.sh (CLI tools only)

```bash
#!/bin/bash
# Auto-install {name} binary when source is newer than installed binary.
SRC_DIR="$(git -C "$(dirname "$0")/../.." rev-parse --show-toplevel)/src"
BIN="$HOME/.deno/bin/{name}"

# No binary → install
if [ ! -f "$BIN" ]; then
  cd "$(dirname "$SRC_DIR")" && deno task install 2>/dev/null
  exit 0
fi

# Check if any source file is newer than binary
STALE=$(find "$SRC_DIR" -name "*.ts" -newer "$BIN" 2>/dev/null | head -1)
if [ -n "$STALE" ]; then
  cd "$(dirname "$SRC_DIR")" && deno task install 2>/dev/null
fi

exit 0
```
