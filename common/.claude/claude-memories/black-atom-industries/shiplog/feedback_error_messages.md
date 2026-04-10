---
name: Surface real errors, not generic wrappers
description: User wants actual API/provider errors shown, not generic "empty response" messages
type: feedback
---

When errors occur (API failures, auth errors, etc.), surface the actual error message — not a generic wrapper like "this is an empty response".

**Why:** User rejected a fix that threw "empty response" because the symptom was obvious — they wanted to see the underlying cause (e.g., "401 — authentication_error — invalid x-api-key"). The `formatErrorMessage()` function in `src/ai/client.ts` now parses JSON error bodies for this reason.

**How to apply:** When adding error handling, always propagate the original error details. Parse structured error responses to extract meaningful messages. Never swallow errors into generic strings.
