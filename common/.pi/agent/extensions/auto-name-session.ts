import { complete } from "@earendil-works/pi-ai/compat";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import {
	extractUserText,
	findAutoNameModel,
	sanitizeSessionName,
	shouldArmAutoNaming,
} from "./lib/auto-name-session";

const AUTO_NAME_MODEL = {
	provider: "openai-codex",
	id: "gpt-5.6-luna",
} as const;

const SYSTEM_PROMPT = `You create searchable session titles for coding and technical work.
The user uses these titles later to find old sessions, so prefer memorable, specific words over generic summaries.
Return exactly one title based only on the user's first message.

Rules:
- Prefer 2 to 6 words
- Use Title Case
- Include the task, feature, bug, file, package, command, model, or error when clear
- Avoid generic titles like Coding Help, Fix Bug, Update Code, or New Session
- If the message is vague, conversational, or lacks a clear task, return a funny but compact coding-themed title
- Funny fallback titles should be memorable, not random; examples: Mystery Bug Goblin, Keyboard Goblin Hour, Undefined Behavior Club
- No quotes
- No markdown
- No labels like Title:
- No trailing punctuation
- Maximum 60 characters`;

export default function autoNameSessionExtension(pi: ExtensionAPI): void {
	let sessionToken = 0;
	let armed = false;
	let pending = false;

	pi.on("session_start", (_event, ctx) => {
		sessionToken += 1;
		armed = shouldArmAutoNaming(ctx.sessionManager.getBranch(), pi.getSessionName());
		pending = false;
	});

	pi.on("session_shutdown", () => {
		sessionToken += 1;
		armed = false;
		pending = false;
	});

	pi.on("before_agent_start", async (event) => {
		const name = pi.getSessionName();
		if (!name) return;
		return {
			systemPrompt: `${event.systemPrompt}\n\nCurrent session name: ${name}`,
		};
	});

	pi.on("message_end", (event, ctx) => {
		if (!armed || pending || pi.getSessionName()) return;
		if (event.message.role !== "user") return;

		const prompt = extractUserText(event.message.content);
		armed = false;
		if (!prompt) return;

		pending = true;
		const token = sessionToken;
		const hasUI = ctx.hasUI;

		if (hasUI) ctx.ui.notify("Auto-naming session…", "info");

		generateSessionName(prompt, ctx)
			.then((name) => {
				if (!name || token !== sessionToken || pi.getSessionName()) return;
				pi.setSessionName(name);
				if (hasUI) ctx.ui.notify(`Session named: ${name}`, "info");
			})
			.catch((error: unknown) => {
				console.error("[auto-name-session] Failed to generate session name:", error);
			})
			.finally(() => {
				if (token === sessionToken) pending = false;
			});
	});
}

async function generateSessionName(prompt: string, ctx: ExtensionContext): Promise<string | undefined> {
	const model = findAutoNameModel((provider, id) => ctx.modelRegistry.find(provider, id), AUTO_NAME_MODEL);
	if (!model) {
		console.warn("[auto-name-session] Model not found");
		return undefined;
	}

	const auth = await ctx.modelRegistry.getApiKeyAndHeaders(model);
	if (!auth.ok || !auth.apiKey) {
		console.warn("[auto-name-session] No API key for", `${model.provider}/${model.id}`);
		return undefined;
	}

	const response = await complete(
		model,
		{
			systemPrompt: SYSTEM_PROMPT,
			messages: [
				{
					role: "user",
					content: [{ type: "text", text: prompt }],
					timestamp: Date.now(),
				},
			],
		},
		{
			apiKey: auth.apiKey,
			headers: auth.headers,
			maxTokens: 256,
		},
	);

	const text = response.content
		.filter((part): part is { type: "text"; text: string } => part.type === "text")
		.map((part) => part.text)
		.join("\n")
		.trim();

	return sanitizeSessionName(text);
}
