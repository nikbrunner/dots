interface SessionEntryLike {
	type: string;
	message?: { role?: string };
}

const MAX_PROMPT_CHARS = 4_000;
const MAX_TITLE_CHARS = 60;

export function findAutoNameModel<T>(
	find: (provider: string, id: string) => T | undefined,
	model: { provider: string; id: string },
): T | undefined {
	return find(model.provider, model.id);
}

export function shouldArmAutoNaming(entries: ReadonlyArray<SessionEntryLike>, currentName: string | undefined): boolean {
	return !currentName?.trim() && !entries.some((entry) => entry.type === "message" && entry.message?.role === "user");
}

export function extractUserText(content: unknown): string {
	if (typeof content === "string") return normalizePrompt(content);
	if (!Array.isArray(content)) return "";

	return normalizePrompt(
		content
			.filter(isTextPart)
			.map((part) => part.text)
			.join("\n"),
	);
}

export function sanitizeSessionName(value: string): string | undefined {
	const firstLine = value
		.replace(/^```[a-z0-9_-]*\s*/i, "")
		.replace(/```$/g, "")
		.split(/\r?\n/)
		.map((line) => line.trim())
		.find(Boolean);

	if (!firstLine) return undefined;

	let title = firstLine
		.replace(/^(title|session name)\s*:\s*/i, "")
		.replace(/^[-*]\s*/, "")
		.replace(/[.?!:;,]+$/g, "")
		.replace(/^['"`]+|['"`]+$/g, "")
		.replace(/\s+/g, " ")
		.trim();

	if (!title) return undefined;
	if (title.length <= MAX_TITLE_CHARS) return title;

	title = title.slice(0, MAX_TITLE_CHARS).trimEnd();
	const lastSpace = title.lastIndexOf(" ");
	if (lastSpace > 20) title = title.slice(0, lastSpace);
	return title.trim() || undefined;
}

function isTextPart(value: unknown): value is { type: "text"; text: string } {
	return Boolean(
		value
			&& typeof value === "object"
			&& (value as { type?: unknown }).type === "text"
			&& typeof (value as { text?: unknown }).text === "string",
	);
}

function normalizePrompt(value: string): string {
	return value.replace(/\r\n/g, "\n").trim().slice(0, MAX_PROMPT_CHARS);
}
