---
name: "dev:ubiquitous-language"
description: "Extract and maintain a DDD-style ubiquitous language glossary from conversation context. Use when domain terminology is ambiguous, inconsistent, or needs formal definition."
---

# Ubiquitous Language Extraction

Build a canonical glossary following Domain-Driven Design principles.

## Process

1. **Scan** the conversation for domain nouns, verbs, and concepts
2. **Identify problems**:
   - Same word used for different concepts (overloaded terms)
   - Different words used for the same concept (synonyms causing confusion)
   - Vague or undefined terms everyone "just knows"
3. **Propose** a canonical glossary with opinionated term choices — pick ONE winner per concept
4. **Confirm** with the user before writing

## Output Format

Write to `UBIQUITOUS_LANGUAGE.md` in the project root.

### Structure

```markdown
# Ubiquitous Language

## Core Domain Terms

| Term           | Definition         | Aliases to Avoid     |
| -------------- | ------------------ | -------------------- |
| Canonical term | Precise definition | old-name, vague-name |

## Actions / Verbs

| Term | Definition | Aliases to Avoid |
| ---- | ---------- | ---------------- |

## Relationships

- A **Widget** belongs to exactly one **Dashboard**
- A **User** can have many **Sessions**

## Example Dialogue

> "When a user **publishes** a **draft**, it becomes a **post** visible on their **feed**."

## Flagged Ambiguities

Terms that need team discussion before canonicalizing:

- **"item"** — could mean Product, LineItem, or CartEntry depending on context
```

## Re-running

When `UBIQUITOUS_LANGUAGE.md` already exists:

1. Read the existing file
2. Merge new terms — don't duplicate
3. Mark changed definitions with "(updated)" and new entries with "(new)" in the PR/commit
4. Remove the markers after the team acknowledges

## After Output

Commit to using these canonical terms consistently in all code, comments, docs, and conversation going forward. Correct drift when spotted.
