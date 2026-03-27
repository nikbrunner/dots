---
name: "dev:util:design-interface"
description: "Generate multiple competing interface designs using parallel sub-agents, then compare and synthesize. Use when designing a new API, component interface, or module boundary."
---

# Design It Twice

From John Ousterhout's _A Philosophy of Software Design_: design each interface at least twice with fundamentally different approaches before committing.

## Workflow

### Step 1: Gather Requirements

Ask the user:

- What problem does this interface solve?
- Who are the callers / consumers?
- What are the most common use cases?
- Any hard constraints (performance, compatibility, ecosystem)?

### Step 2: Generate Designs (Parallel Sub-agents)

Spawn **3+ sub-agents**, each with a DIFFERENT constraint:

| Agent | Constraint                                                                         |
| ----- | ---------------------------------------------------------------------------------- |
| A     | Minimize the number of methods/props — radical simplicity                          |
| B     | Maximize flexibility — handle every edge case                                      |
| C     | Optimize for the most common use case — 80/20 rule                                 |
| D     | (Optional) Draw from a different paradigm — functional, builder, declarative, etc. |

Each agent outputs:

- **Interface signature** (types, function signatures, or component props)
- **Usage example** for the primary use case
- **What it hides** from the caller (encapsulation wins)
- **Trade-offs** — what you give up with this approach

**Critical**: If agents produce similar designs, reject and re-prompt with more divergent constraints. The value is in the differences.

### Step 3: Present

Show all designs side by side. Let the user read before commenting.

### Step 4: Compare

Evaluate each design on:

- **Interface simplicity** — fewer concepts to learn
- **General-purpose vs specialized** — reuse potential
- **Implementation efficiency** — does the design make the implementation harder or easier?
- **Depth** — does it hide complexity (deep module) or spread it around (shallow module)?

### Step 5: Synthesize

Combine the best elements into a final design. Explain which parts came from which approach and why.

## Anti-patterns

- Do NOT let agents see each other's work — independence produces diversity
- Do NOT skip the comparison step — that's where insight lives
- Do NOT implement yet — this skill produces a design, not code
