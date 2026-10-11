# Testing

Test decisions and user behavior, not framework behavior.

- Colocate tests and name them `*.test.ts` or `*.test.tsx`.
- Unit-test pure logic: parsing, permissions, reducers, date or token calculations.
- Use an interaction test for behavior a user performs and a static story cannot show.
- A presentational component that only maps props onto HTML or a UI library gets no test.
- Pull a hook's decision into a pure function and test that function. A hook that only wraps a browser API has no decision
  to test.
- For the data layer, stub `fetch` at the transport boundary and run the real query client.
- Test a schema's accepted, rejected, and transformed values when the schema encodes product behavior.

A useful test answers something a reader could not know by reading the implementation. Coverage percentage is not the goal.
