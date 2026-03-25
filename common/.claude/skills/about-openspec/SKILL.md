---
name: "about:openspec"
description: "OpenSpec change management system — directory structure, key CLI commands, and skill cross-references. Load when OpenSpec, openspec/, changes, or proposals come up."
---

# OpenSpec

AI-native system for spec-driven development. Manages change proposals, designs, specs, and implementation tasks.

## Directory Structure

**The directory is `openspec/` (no dot prefix).** Not `.openspec`, not `.openspec/`.

```
openspec/                     # Project root (created by `openspec init`)
├── changes/                  # Active change proposals
│   ├── <change-name>/        # One directory per change
│   │   ├── .openspec.yaml    # Change metadata (schema, status)
│   │   ├── proposal.md       # What & why
│   │   ├── design.md         # How
│   │   ├── tasks.md          # Implementation steps
│   │   └── specs/            # Delta specs for this change
│   └── archive/              # Completed changes (YYYY-MM-DD-<name>/)
├── schemas/                  # Workflow schemas and templates
└── specs/                    # Project-level capability specs
```

## Key CLI Commands

```bash
# Discovery
openspec list --json              # List active changes (name, schema, status)
openspec status --change "<name>" --json  # Artifact completion status

# Creating
openspec new change "<name>"      # Scaffold a new change directory
openspec init --tools claude      # Initialize OpenSpec in a project

# Working
openspec instructions <artifact-id> --change "<name>" --json  # Get build instructions
openspec instructions apply --change "<name>" --json          # Get implementation instructions
openspec validate --specs         # Validate all specs
```

## Skills

| Skill | Invocation | Purpose |
|-|-|-|
| `openspec-propose` | `/opsx:propose` | Create change + generate all artifacts |
| `openspec-apply-change` | `/opsx:apply` | Implement tasks from a change |
| `openspec-explore` | `/opsx:explore` | Think through ideas (no code) |
| `openspec-archive-change` | `/opsx:archive` | Archive completed change |
| `dev:openspec-init` | `/dev-openspec-init` | Bootstrap OpenSpec in a project |

## Sources of Truth

- [CLI Reference](https://github.com/Fission-AI/OpenSpec/blob/main/docs/cli.md)
- [Commands Reference](https://github.com/Fission-AI/OpenSpec/blob/main/docs/commands.md)
