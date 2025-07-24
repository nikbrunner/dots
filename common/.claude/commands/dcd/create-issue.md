---
description: Create a BCD issue with proper template and formatting
allowed-tools: ["Read", "Write", "Edit", "MultiEdit", "TodoWrite", "WebSearch"]
---

# Create BCD Issue

Creates a properly formatted BCD issue following the project's issue template.

## What do you need an issue for?

Please provide:
- **Topic/Feature**: What should this issue address?
- **Context**: Any additional context, requirements, or details
- **Format**: You can give me:
  - Freeform text description
  - Bullet points
  - Reference to existing documents/plans
  - List of related tasks

## BCD Issue Template

This is the issue template I'll use:

```markdown
# bc-web-client: [Title]

## Scope & Acceptance Criteria
* *Outline the criteria that need to be met for the feature to be considered complete and functional. This should include both functional and non-functional requirements.*

## Out of Scope (optional)
* *What should be excluded from this issue? Link the issue if there are some.*

## Description (optional)
* *Explain the problem, feature, or idea that this issue involves.*
* *Think about the problem. Can you split this problem into sub-issues?*
* *Does the description contain all the information so another person can work on this issue?*
* *Optional: Check the designs, are all components available? Do you need to create new components?*
* *Do we need to discuss this issue, solution, or problem together? (side-effects, global component or architecture changes like hooks, etc.) -> Assign the discuss label*
* *Add the appropriate tags to the issue (e.g. Mobile Frontend or Infrastructure)*
* *Is this issue billable? In doubt: yes.* 

## Tests (optional)
* *Do these issues have side effects and do they also need to be tested?*
* *Do we need to add a unit test?*
* *Future: Do we need a storybook integration test?*

## Steps to reproduce (optional)
* *Describe how to reproduce the issue/bug*
* *Add the version of the software component which behaves faulty* 

## Post-Merge Tasks (optional)
* *Describe open points that have to be completed after the merge of the changes, e.g. release software or post to support.*
* *Consider a follow-up issue, if the task description does not fit in one sentence.*

## Resources & References (optional)
* *Link your work in non-GitHub locations, if you assign the to verify label. (e.g. Sketch or links to a framework documentation)*
* *Link relevant other issues*
```

## Process

1. Ask clarifying questions if needed to understand the scope
2. Create focused **Scope & Acceptance Criteria** (most important - always required)
3. **Optional sections** only if they add real value:
   - **Tests** (only if side-effects expected)
   - **Resources & References** (only if relevant docs/plans exist)
   - **Description** (only if context needed)
4. Keep it short and actionable like the original follow-up issues
5. Most issues need only 2-3 lines of scope
6. **Always create markdown file** - ask for location if unsure
7. **Search for relevant resources** - find migration guides, tutorials, or documentation
8. **After ticket creation** - offer to create a detailed implementation plan

Let me know what you'd like to create an issue for: $ARGUMENTS
