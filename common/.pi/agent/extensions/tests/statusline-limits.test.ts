import { getCodexWeeklyWindow } from "../lib/statusline-limits.ts";

Deno.test("keeps the provider snapshot across account and session changes", () => {
	const snapshot = {
		provider: "openai-codex",
		weekly: { usedPercent: 16, resetAt: 1_800_000_000 },
		fetchedAt: Date.now() - 60_000,
	};

	if (getCodexWeeklyWindow(snapshot, "openai-codex") !== snapshot.weekly) {
		throw new Error("Expected the provider snapshot to remain visible.");
	}
});

Deno.test("keeps the last valid provider snapshot after a refresh failure", () => {
	const previous = {
		provider: "openai-codex",
		weekly: { usedPercent: 16, resetAt: 1_800_000_000 },
		fetchedAt: Date.now() - 60_000,
	};

	if (getCodexWeeklyWindow(undefined, "openai-codex", previous) !== previous.weekly) {
		throw new Error("Expected the last valid provider snapshot after a refresh failure.");
	}
});
