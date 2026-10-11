# Audit report

Use exactly these H2 headings. Every Broken, Missing, Deviation, and Unverified entry carries all four fields.

## Scope

Mode (`audit` or `setup`), topics covered, the paths, and the commit (`git rev-parse --short HEAD`).

## Verdict

One short assessment of where the project stands.

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
| Broken     | The convention is followed but does not work: unwired, unmounted, or failing at runtime | high |
| Missing    | A convention expects it and the project has nothing there           | high                            |
| Deviation  | It works, and differs from what a convention says                   | high; lower only with a stated reason, named in the entry |
| Present    | The rule is met                                                     | none; one line with evidence    |
| Unverified | It could not be checked; the next action names the check            | as the unknown risks; never folded into another class |

Broken, Missing, and Deviation are high by default: the project adopted these conventions, so a gap is not a preference.

## Suggestions

Real improvements no checklist rule asks for. Never high severity, never mixed into Findings, never a reason to hold up the
work.

## Reviewer notes

Free text from Nik. Preserved verbatim when the report is rewritten.
