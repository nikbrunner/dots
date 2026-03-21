# Dependency Categories

Classify every dependency in reviewed code into one of four categories. The category determines the test strategy.

## 1. In-Process

Pure computation with no I/O, no side effects, no external state. Examples: math utilities, parsers, formatters, validation logic, data transformers.

**Test strategy:** Test directly with real inputs and assertions. No mocks, no stubs, no fakes. These are the cheapest tests to write and maintain.

**Warning sign:** If you feel the need to mock something in an in-process dependency, you likely have a hidden side effect that should be extracted.

## 2. Local-Substitutable

Dependencies that have reliable test stand-ins available. Examples: in-memory databases (SQLite for Postgres), fake clocks, in-memory file systems, test mail servers.

**Test strategy:** Use the real substitute in tests — not a mock. An in-memory SQLite database exercises real SQL parsing; a mock database exercises nothing. The substitute should behave identically to the real dependency for the code paths under test.

**Warning sign:** If no reliable substitute exists, this dependency may actually be True External.

## 3. Ports & Adapters

Owned remote services accessed through an interface you control. Examples: your own microservices behind a client interface, internal APIs with defined contracts, message queues with typed producers/consumers.

**Test strategy:** Define a port (interface) and write an adapter (implementation). Mock at the port boundary in unit tests. Use contract tests or integration tests to verify the adapter against the real service.

**Warning sign:** If the port interface mirrors the external API 1:1, the abstraction is not adding value — you are just wrapping, not adapting.

## 4. True External

Third-party APIs, SDKs, and services you do not control. Examples: Stripe, GitHub API, AWS services, OAuth providers, LLM APIs.

**Test strategy:** Mock at the outermost boundary only. Create a thin wrapper that isolates the external dependency, then mock the wrapper. Never let external API types leak into your domain model.

**Warning sign:** If external types appear in your domain logic, you are coupled to the third party. Refactor to an anti-corruption layer.

## Decision Flowchart

1. Does it perform I/O? No -> **In-Process**
2. Is there a reliable test substitute? Yes -> **Local-Substitutable**
3. Do you own the service? Yes -> **Ports & Adapters**
4. Otherwise -> **True External**
