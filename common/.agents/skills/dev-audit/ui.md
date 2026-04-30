# Audit: UI

**What this audits:** Visual quality, accessibility, responsiveness, and design coherence of frontend interfaces.

## How

- **`impeccable:audit`** — technical quality scan (a11y, perf, theming, responsive, anti-patterns)
- **`impeccable:critique`** — design coherence evaluation (hierarchy, IA, emotional resonance, composition)
- **`impeccable:*`** - Check out if any other of the imppecciable skills are fitting for your use case.
- **`agent-browser`** (via `dev:util:browser`) — screenshot capture for visual verification when available

## Steps

1. Determine scope: use argument if provided (`$ARGUMENTS` in Claude Code, or `/skill:dev-audit ui` args in Pi), otherwise fall back to staged changes (`git diff --staged`), then unstaged (`git diff HEAD`).
2. Run `impeccable:audit` on the target — produces a severity-rated technical report (a11y violations, perf issues, theme inconsistencies, responsive breakage, AI-slop detection).
3. Run `impeccable:critique` on the target — produces a design director's critique (visual hierarchy, information architecture, emotional resonance, affordance, composition).
4. If browser-automation is available, capture screenshots at key breakpoints (mobile, tablet, desktop) for visual evidence.
5. Merge findings into a single report, deduplicating overlapping issues.

## Output

Combined report with two sections:

- **Technical audit** — issues by severity (Critical/High/Medium/Low) with file paths, WCAG references, and recommended impeccable commands
- **Design critique** — overall impression, what works, priority design problems, questions to consider

## Fixing found issues

Reference `impeccable:polish` for a systematic fix pass. Map individual issues to specific impeccable commands (`/normalize`, `/adapt`, `/typeset`, `/colorize`, etc.).
