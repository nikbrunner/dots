# LLM Project Setup

## Greenfield: Set Up From the Start

Every new project should have LLM configuration from day one.

### 1. AGENTS.md

Create a lean `AGENTS.md` at the project root. This is always-on context -- keep it short.

- Project name and one-line description
- Core tech stack
- How to run, build, test (if not obvious from package.json/Makefile)
- Any non-obvious conventions that would cause costly mistakes without them

Symlink `CLAUDE.md` to `AGENTS.md` so Claude Code discovers it:

```bash
ln -s AGENTS.md CLAUDE.md
```

**The bar for including something:** Would Claude make a costly mistake without this line? If the answer is "no, it would just need to read a file first," don't include it.

### 2. Project Skills

Create `.claude/skills/` for domain knowledge and workflows:

| Type | Example | user-invocable? |
|------|---------|-----------------|
| **Domain knowledge** | `about-project/SKILL.md` -- entities, business rules, API shape | `false` |
| **Conventions** | `api-conventions/SKILL.md` -- endpoint patterns, error formats | `false` |
| **Workflows** | `deploy/SKILL.md` -- deployment steps | `true` |

Skills should contain what's NOT discoverable from the codebase itself. Don't duplicate what's in config files, package.json, or tsconfig.

### 3. Hooks

Create `.claude/hooks/enforce/` for deterministic rules:

- Rules that say "always X" or "never Y" belong in hooks, not AGENTS.md
- Hooks are bash scripts that run on PreToolUse or PostToolUse events
- Register them in `.claude/settings.json`

Common hooks:
- Commit message format enforcement
- Forbidden patterns (e.g., warn on `any` in TypeScript)
- Auto-formatting after file writes

### 4. Pre-commit Hook

Create a `scripts/setup-hooks.sh` script to install a pre-commit hook that runs checks before every commit. Run it once after cloning.

```bash
#!/usr/bin/env bash
set -e

HOOK_FILE=".git/hooks/pre-commit"

cat > "$HOOK_FILE" << 'EOF'
#!/usr/bin/env bash
set -e

# Adapt these to the project's actual commands
echo "Running pre-commit checks..."

# Type check
npm run typecheck 2>/dev/null || pnpm typecheck 2>/dev/null || true

# Lint
npm run lint 2>/dev/null || pnpm lint 2>/dev/null || true

# Tests (fast unit tests only — keep the hook quick)
npm run test:unit 2>/dev/null || pnpm test:unit 2>/dev/null || true

echo "Pre-commit checks passed."
EOF

chmod +x "$HOOK_FILE"
echo "Pre-commit hook installed at $HOOK_FILE"
```

**Adapt to the project:**
- Replace `typecheck`, `lint`, `test:unit` with the project's actual `package.json` scripts
- For non-Node projects, replace npm/pnpm with the relevant toolchain (e.g., `go vet ./...`, `cargo clippy`)
- Keep it fast — slow hooks get bypassed. Integration tests belong in CI, not here.

Mention `scripts/setup-hooks.sh` in `AGENTS.md` so Claude knows to run it after cloning.

## Feature Work: Evaluate and Extend

When implementing a major feature, check if the LLM setup needs updating:

### AGENTS.md

- Does the feature introduce new conventions that Claude should always know?
- New build/test commands?
- New non-obvious architectural decisions?

### Skills

- Does the feature introduce a new domain area? → new knowledge skill
- Does it establish a repeatable workflow? → new workflow skill
- Does it create patterns that should be followed consistently? → new convention skill

### Hooks

- Does the feature introduce rules that must always be followed? → new enforcement hook
- New file types that need special treatment? → new PostToolUse hook

### When NOT to Add

- Don't create skills for things discoverable from code (imports, config files, types)
- Don't create hooks for things that linters already catch
- Don't add to AGENTS.md what belongs in a skill (detailed domain knowledge, workflows)
