# Audit report

Use exactly these H2 headings. Every Broken, Missing, Deviation, and Unverified entry carries all four fields.

## Scope

Topics audited, the paths covered, and the commit (`git rev-parse --short HEAD`).

## Findings

One block per topic, in checklist order:

```md
### <topic>

- **Broken** · high · <rule>
  - Evidence: `path:line`
  - Impact: what goes wrong because of it
  - Next action: the smallest change that fixes it
- **Present** · <rule> · `path:line`
```

| Class      | Meaning                                                             | Severity                        |
| ---------- | ------------------------------------------------------------------- | ------------------------------- |
| Broken     | Code violates a rule in a way that blocks or risks the work         | high                            |
| Missing    | A required piece is absent                                          | high, or medium for a small gap |
| Deviation  | The project works differently from the convention                   | low when a stated reason exists |
| Present    | The rule is met                                                     | none; one line with evidence    |
| Unverified | Static reading cannot establish it; the next action names the check | as the unknown risks            |

## Suggestions

Anything noticed while reading that no checklist rule covers. Low priority, never mixed into Findings.

## Reviewer notes

Free text from Nik. Preserved verbatim when the report is rewritten.
