import { extractAssistantText } from "../pi-topbar/lib/messages.ts";

Deno.test("extracts text blocks from an assistant message", () => {
	const text = extractAssistantText({
		role: "assistant",
		content: [
			{ type: "thinking", thinking: "internal" },
			{ type: "text", text: "First paragraph." },
			{ type: "text", text: "Second paragraph." },
		],
	});

	if (text !== "First paragraph.\nSecond paragraph.") {
		throw new Error(`Unexpected assistant text: ${text}`);
	}
});

Deno.test("ignores assistant messages without visible text", () => {
	const text = extractAssistantText({
		role: "assistant",
		content: [{ type: "toolCall", name: "read" }],
	});

	if (text !== undefined) throw new Error(`Expected no text, got ${text}`);
});
