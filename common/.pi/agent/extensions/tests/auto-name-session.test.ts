import { findAutoNameModel } from "../lib/auto-name-session.ts";

Deno.test("selects the Codex model for automatic session names", () => {
	const calls: string[] = [];
	const model = { id: "gpt-5.6-luna" };

	const result = findAutoNameModel((provider, id) => {
		calls.push(`${provider}/${id}`);
		return model;
	}, { provider: "openai-codex", id: "gpt-5.6-luna" });

	if (result !== model) throw new Error("Expected the selected model to be returned");
	if (JSON.stringify(calls) !== JSON.stringify(["openai-codex/gpt-5.6-luna"])) {
		throw new Error(`Unexpected model lookup: ${JSON.stringify(calls)}`);
	}
});
