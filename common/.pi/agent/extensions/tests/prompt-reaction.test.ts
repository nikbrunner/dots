import { addPromptReactionInstruction } from "../lib/prompt-reaction.ts";

Deno.test("preserves the system prompt and adds the opening reaction rules", () => {
	const result = addPromptReactionInstruction("Base system prompt");

	if (!result.startsWith("Base system prompt\n\n")) {
		throw new Error("Expected the base system prompt to remain unchanged");
	}
	if (!result.includes("Before any tool call")) {
		throw new Error("Expected reactions to precede tool calls");
	}
	if (!result.includes("Continue the task immediately")) {
		throw new Error("Expected work to continue without a confirmation gate");
	}
	if (!result.includes("material mistake, risk, or unclear assumption")) {
		throw new Error("Expected the reaction to allow warranted pushback");
	}
});
