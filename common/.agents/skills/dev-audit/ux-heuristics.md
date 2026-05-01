# Audit: UX Heuristics

**What this audits:** UX quality against Jakob Nielsen's 10 Usability Heuristics — interaction design, information architecture, error handling, and user control patterns.

## How

- **Nielsen's 10 Heuristics** — evaluation framework applied to UI code, component tree, and interaction flows
- **`agent-browser`** (via `dev:util:browser`) — screenshot capture + interaction testing for visual evidence
- **LSP** — `findReferences`, `documentSymbol` for tracing error handling, navigation, and state propagation

## Steps

1. Determine scope: use argument path if provided (`$ARGUMENTS` in Claude Code, or `/skill:dev-audit ux` args in Pi), otherwise fall back to staged changes, then unstaged changes.
2. If browser automation is available, capture screenshots at key states (idle, loading, error, empty, success) for each scoped view.
3. Walk each heuristic against the scoped code and screenshots. For each, answer the evaluation questions below.

### Heuristic Evaluation Questions

| #   | Heuristic                                                   | Evaluate                                                                                                                                                                                                                |
| --- | ----------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | **Visibility of System Status**                             | Loading states present? Progress indicators for async operations? Toast/notification for completed actions? Current location in navigation visible? Background operations surfaced?                                     |
| 2   | **Match Between System and Real World**                     | Labels use user language, not internal jargon? Iconography maps to familiar concepts? Information order follows real-world sequence? Date/time/number formats match user locale?                                        |
| 3   | **User Control and Freedom**                                | Undo/cancel available for destructive actions? "Emergency exit" from multi-step flows? Navigation allows returning without loss? Form reset or clear options?                                                           |
| 4   | **Consistency and Standards**                               | Same patterns used for same actions across views? Platform conventions followed (native selects, scroll behavior, gestures)? Terminology consistent across the app? Visual patterns don't conflict with platform norms? |
| 5   | **Error Prevention**                                        | Destructive actions require confirmation? Input constraints enforced before submit (maxlength, pattern, required)? Impossible states made impossible in types/UI? Default values reduce chance of wrong input?          |
| 6   | **Recognition Rather than Recall**                          | Options visible rather than requiring memory? Field labels persist (not placeholder-only)? Recent/frequent items surfaced? Contextual help instead of requiring memorization?                                           |
| 7   | **Flexibility and Efficiency of Use**                       | Keyboard shortcuts for frequent actions? Search/filter for large lists? Bulk operations? Power-user features tucked but discoverable? Customizable defaults?                                                            |
| 8   | **Aesthetic and Minimalist Design**                         | Irrelevant information removed from each view? Visual hierarchy guides attention to primary action? Progressive disclosure for complex content? No competing CTAs?                                                      |
| 9   | **Help Users Recognize, Diagnose, and Recover from Errors** | Error messages in plain language (no error codes)? Error precisely identifies the problem? Suggested fix or next step provided? Error states visually distinct and noticeable?                                          |
| 10  | **Help and Documentation**                                  | Onboarding or inline help for complex flows? Searchable help content? Task-oriented (not feature-oriented) docs? Accessible at point of need?                                                                           |

4. For each heuristic, classify each finding:
   - **Violation** — clearly breaks the heuristic
   - **Weakness** — partially addresses it, room to improve
   - **Pass** — satisfactorily met
5. Merge findings into a single report.

## Output

Two-section report:

### Findings Table

| Heuristic           | Severity | Location                       | What's off                              | Suggestion                         |
| ------------------- | -------- | ------------------------------ | --------------------------------------- | ---------------------------------- |
| #1 Visibility       | High     | `src/.../UploadForm.tsx:L45`   | No progress indicator during upload     | Add progress bar or spinner with % |
| #5 Error Prevention | Medium   | `src/.../DeleteButton.tsx:L12` | Destructive delete with no confirmation | Add confirm dialog                 |

### Summary

Per-heuristic pass rate and top 3 priorities (highest severity × user impact).

## Cross-references

- `dev-audit ui` — visual quality and a11y findings that may overlap with heuristics #1, #4, #8
- `dev:style:react` — component patterns for error boundaries and loading states
- `dev:style:state` — server state patterns for loading/error indicators

## Source

Nielsen, J. (1994). _Enhancing the explanatory power of usability heuristics._ Proc. ACM CHI'94. [nngroup.com/articles/ten-usability-heuristics](https://www.nngroup.com/articles/ten-usability-heuristics)
