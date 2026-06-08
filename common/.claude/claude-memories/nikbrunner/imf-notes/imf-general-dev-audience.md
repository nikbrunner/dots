---
name: imf-general-dev-audience
description: "ImFusion's general/company-wide developer audience is non-frontend; keep frontend talks jargon-free and high-level"
metadata: 
  node_type: memory
  type: project
  originSessionId: 127292c4-dacf-488a-91a0-5005eaec5afd
---

ImFusion is a medical-imaging SDK company. Its "general developer meeting" / company-wide dev audience is **not** frontend developers — mostly C++/imaging/backend engineers, some of whom don't know what a UI component is.

**Why:** When Nik presents frontend work internally (e.g. the `@imfusion/web-ui` library intro), he is explicitly asked to generalize to a very high level.

**How to apply:** For any internal-audience frontend material, avoid frontend jargon (headless, unstyled, ARIA, shadcn, MUI/Mantine, tokens). Explain primitives like "component" from scratch, prefer plain-language analogies, and lead with universally-legible hooks (e.g. AI tooling) rather than framework references. Strategy/prep docs like `projects/web-ui-component-strategy.md` are Nik's personal thinking — not calibrated to this audience.
