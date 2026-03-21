# Testing Patterns

## Vitest Unit Tests

For lib functions and pure logic:

```tsx
// lib/format-date.test.ts
import { describe, it, expect } from "vitest";
import { formatDate } from "./format-date";

describe("formatDate", () => {
  it("formats ISO string to readable date", () => {
    expect(formatDate("2026-03-07T10:00:00Z")).toBe("March 7, 2026");
  });

  it("returns fallback for invalid input", () => {
    expect(formatDate("not-a-date")).toBe("--");
  });
});
```

## Storybook Stories

Every reusable component gets stories. Stories serve as both visual tests and living documentation.

```tsx
// components/button/stories.tsx
import type { Meta, StoryObj } from "@storybook/react";
import { Button } from "./index";

const meta: Meta<typeof Button> = {
  component: Button,
};

export default meta;
type Story = StoryObj<typeof Button>;

export const Primary: Story = {
  args: {
    label: "Click me",
    variant: "primary",
  },
};

export const Disabled: Story = {
  args: {
    label: "Disabled",
    disabled: true,
  },
};
```

## Visual Regression

Not built into Storybook for free. Options:

- **Chromatic** (paid) — Storybook's official cloud-based visual regression service
- **Custom solution** — Playwright screenshots + image diffing
- **Storybook test runner + Playwright** — DIY screenshot comparison in CI

This is a per-project decision. The key principle: component visual changes should be caught automatically, however you set it up.

## Interaction Tests (Storybook + Playwright)

For testing user flows programmatically within stories:

```tsx
import { within, userEvent } from "@storybook/testing-library";
import { expect } from "@storybook/jest";

export const FilledForm: Story = {
  play: async ({ canvasElement }) => {
    const canvas = within(canvasElement);

    await userEvent.type(canvas.getByLabelText("Name"), "Nik");
    await userEvent.click(canvas.getByRole("button", { name: "Submit" }));

    await expect(canvas.getByText("Saved")).toBeInTheDocument();
  },
};
```

Direction: Programmatic user story testing -- define user journeys as interaction tests.

## Hook/Fetch Testing (Emerging)

Area for growth. Patterns to explore:

- Custom render wrapper with QueryClientProvider for testing hooks
- MSW (Mock Service Worker) for intercepting API calls in tests
