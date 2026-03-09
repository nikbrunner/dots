---
name: dev:planning
description: "Nik's planning process -- design before code, scope-appropriate wireframing and documentation. Load when starting new projects, major features, or non-trivial changes."
user-invocable: false
---

# Planning & Kickoff

## Principle: Design Before Code

Don't jump into code. Establish direction first. The level of design depends on scope.

## When to Design

| Scope | Design Approach |
|-------|----------------|
| **Greenfield project** | Wireframe/sketch required. Establish layout, navigation, core components. |
| **Major feature** | Screenshots with annotations, or lightweight wireframes. |
| **Bug fix / small feature** | Mental model is enough. Skip formality. |

## Process

1. **Understand the domain** -- what problem are we solving?
2. **Sketch the UI** -- wireframe, screenshot annotation, or quick sketch
3. **Define the data model** -- what entities exist, how do they relate?
4. **Plan the component tree** -- which components, containers, partials?
5. **Create planning documents** -- not one monolith, but a series of focused docs
6. **Then code** -- with direction established

## Multi-Document Planning

For larger projects, create multiple focused documents rather than one giant plan:
- Architecture overview
- Component inventory
- Data model / API surface
- Implementation steps (task-by-task)

## References

- For wireframing tool options, see `wireframing-tools.md`
- For planning tool options, see `planning-tools.md`
- For LLM project setup (AGENTS.md, skills, hooks), see `llm-setup.md`
- For styling approach decisions, see skill `dev:styling`
