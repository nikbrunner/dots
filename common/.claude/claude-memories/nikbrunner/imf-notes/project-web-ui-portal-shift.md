---
name: project-web-ui-portal-shift
description: "web-ui development is shifting to be driven by real usage in imfusion-portal-fe, not backlog-first — affects how to read Nik's daily work and web-ui ticket priorities"
metadata: 
  node_type: memory
  type: project
  originSessionId: c103311f-b151-46e7-b0ce-38b500b56668
---

Starting 2026-07-01, Nik is reworking `imfusion-portal-fe` (ImFusion Web Portal frontend — React/Vite/TS/React Router/Vitest, repo under `~/repos/imfusion/cp/imfusion-portal-fe`) using `web-ui` as its component foundation. `local-setup-portal` (`~/repos/imfusion/cp/local-setup-portal`) orchestrates the local dev stack for the whole portal system (bff, keycloak, license-server, registration-service, portal-fe).

**Why:** For the next several months, Nik expects to work on `web-ui` continuously, but *driven by* portal-fe's real needs rather than backlog order — building the portal surfaces concrete component gaps/bugs in web-ui, which then feed back into the web-ui backlog. This is a genuine, durable shift in how web-ui work gets prioritized, not a one-off detour. He explicitly flagged that foundational work (e.g. the token system, [WEBSDK-171]) should be prioritized ahead of new component work now, since retrofitting a foundation under live consumers is costlier than fixing it first.

**How to apply:** When reviewing web-ui Jira tickets or planning work, weigh "does portal-fe actually need this" and "is this foundational vs. feature" over raw backlog order/age. When portal-fe work surfaces a concrete web-ui gap, that gap should jump the queue. Don't treat the web-ui backlog as independent from portal-fe activity anymore — they're now one feedback loop. See [[imf-notes-daily-portfolio-checkin]] for the process this gets surfaced through during daily close-out.
