---
name: dev:tdd
description: "TDD discipline and test strategy — red-green-refactor cycle, vertical slices, deep module testing, behavior-driven design. Load when doing TDD, writing tests, setting up test strategy, or discussing test infrastructure."
user-invocable: false
---

# TDD & Testing

## The Cycle: Red-Green-Refactor

No production code without a failing test first.

1. **Red**: Write ONE failing test describing ONE behavior
2. **Green**: Write the minimal code to make it pass
3. **Refactor**: Clean up while tests stay green
4. **Repeat**

Each cycle is a complete vertical slice. The test informs the interface, the implementation informs the next test.

## Anti-Pattern: Horizontal Slicing

DO NOT write all tests first, then all implementation. Tests written in bulk test imagined behavior — they encode assumptions about code that doesn't exist yet, leading to tests that pass for the wrong reasons or need rewriting once real implementation reveals the actual shape.

## Behavior Through Public Interfaces

Good tests exercise real code paths through public APIs. Bad tests mock internal collaborators or test private methods.

| Sign                                        | Meaning                           |
| ------------------------------------------- | --------------------------------- |
| Test breaks on refactor, behavior unchanged | Test is coupled to implementation |
| Test requires exposing internals            | Interface needs redesign          |
| Test mocks more than it asserts             | Testing wiring, not behavior      |
| Test name describes a method                | Should describe a behavior        |

**Test names should read as behavior specifications:**

- Bad: `test_calculateTotal_returns_number`
- Good: `test_cart_with_discount_code_reduces_total_by_percentage`

## Deep Module Testing

A deep module has a small interface but large implementation (John Ousterhout). Deep modules are inherently more testable at the boundary because the small interface constrains the test surface.

- **Test at the boundary**, not inside the implementation
- If you need many tests to cover a module's internals, the interface may be too shallow
- A well-designed deep module needs fewer tests that cover more behavior per test

When a module is hard to test through its public interface, that is a design signal — consider reshaping the interface before adding internal test hooks.

## Checklist Per Cycle

Before moving to the next cycle, verify:

- [ ] Test describes a behavior, not an implementation detail
- [ ] Test uses only public interface
- [ ] Test would survive an internal refactor
- [ ] Implementation is minimal — no speculative features
- [ ] No code exists without a corresponding test

## References

- For testing layers, tooling, and strategy, see [testing-layers.md](testing-layers.md)
- For code examples and patterns, see [testing-patterns.md](testing-patterns.md)
- `dev:arch-review` — deep module evaluation in architecture reviews
