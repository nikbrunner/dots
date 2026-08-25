import {
	buildFocusPrompt,
	getConversationStateSummaryConfig,
	buildSummaryPrompt,
	extractUserText,
	getSummaryDelay,
	shouldRefreshSummary,
} from "../pi-topbar/lib/summary.ts";

Deno.test("reads summary settings from the conversation-state provider", () => {
	const config = getConversationStateSummaryConfig([
		{ provider: "session-name" },
		{
			provider: "conversation-state",
			summary: {
				enabled: true,
				model: "openai-codex/gpt-5.6-luna",
				minIntervalMs: 10000,
				maxTokens: 80,
			},
		},
	]);
	if (!config.enabled || config.model !== "openai-codex/gpt-5.6-luna" || config.minIntervalMs !== 10000) {
		throw new Error(`Unexpected conversation-state summary config: ${JSON.stringify(config)}`);
	}
});

Deno.test("extracts the latest user focus from string and text-block messages", () => {
	if (extractUserText({ role: "user", content: "  Fix the overlay  " }) !== "Fix the overlay") {
		throw new Error("Did not extract a string user message");
	}

	const message = {
		role: "user",
		content: [
			{ type: "text", text: "Add the stable focus line" },
			{ type: "image", data: "ignored", mimeType: "image/png" },
		],
	};
	if (extractUserText(message) !== "Add the stable focus line") {
		throw new Error("Did not extract text blocks from a user message");
	}
});

Deno.test("builds an inferred goal prompt instead of requesting verbatim text", () => {
	const prompt = buildFocusPrompt({
		request: "Please clean up the topbar and make the reminder useful across sessions.",
		recentConversation: ["User: We are improving the Pi topbar.", "Assistant: The current bar shows the last response."],
	});

	if (!prompt.includes("Infer the user's underlying goal")) {
		throw new Error("Prompt does not request an inferred goal");
	}
	if (prompt.includes("Return the user request verbatim")) {
		throw new Error("Prompt allows verbatim focus text");
	}
	if (!prompt.includes("clean up the topbar")) {
		throw new Error("Prompt does not include the latest request");
	}
});

Deno.test("throttles summary generation after the first update", () => {
	if (getSummaryDelay({ lastSummaryAt: 0, now: 10_000, minIntervalMs: 60_000 }) !== 0) {
		throw new Error("The first summary should run immediately");
	}
	if (getSummaryDelay({ lastSummaryAt: 40_000, now: 50_000, minIntervalMs: 60_000 }) !== 50_000) {
		throw new Error("The next summary should wait for the remaining interval");
	}
	if (getSummaryDelay({ lastSummaryAt: 40_000, now: 110_000, minIntervalMs: 60_000 }) !== 0) {
		throw new Error("An elapsed interval should run immediately");
	}
});

Deno.test("refreshes on turns but not individual tool calls", () => {
	if (!shouldRefreshSummary("turn_end") || !shouldRefreshSummary("agent_settled")) {
		throw new Error("Expected turn boundaries to refresh summaries");
	}
	if (shouldRefreshSummary("tool_execution_end")) {
		throw new Error("Tool calls should not refresh summaries directly");
	}
});

Deno.test("builds a progress-only summary prompt", () => {
	const prompt = buildSummaryPrompt({
		request: "Please rework the topbar summary.",
		focus: "Rework the topbar summary",
		lastResponse: "The implementation is ready for testing.",
		recentActivity: ["tool: read config.json", "tool: deno test"],
	});

	if (!prompt.includes("Do not rewrite or restate the Focus")) {
		throw new Error("Prompt does not protect the stable focus");
	}
	if (!prompt.includes("Rework the topbar summary")) {
		throw new Error("Prompt does not include the focus");
	}
	if (!prompt.includes("The implementation is ready for testing.")) {
		throw new Error("Prompt does not include the last response");
	}
});
